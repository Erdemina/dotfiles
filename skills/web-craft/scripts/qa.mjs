#!/usr/bin/env node
// Visual QA: screenshots per viewport, horizontal overflow, broken assets,
// console errors, axe (WCAG 2.2 AA), Impeccable slop detector, optional
// pixel diff against a previous run.
// Usage: qa.mjs <url> [more urls] [--out dir] [--vp 390,768,1024,1440]
//        [--baseline dir] [--no-axe] [--no-detect]
import { chromium } from 'playwright';
import { AxeBuilder } from '@axe-core/playwright';
import pixelmatch from 'pixelmatch';
import { PNG } from 'pngjs';
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const args = process.argv.slice(2);
const flag = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i === -1 ? fallback : args.splice(i, 2)[1];
};
const out = resolve(flag('out', `/tmp/qa-${new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-')}`));
const viewports = flag('vp', '390,768,1024,1440').split(',').map(Number);
const baseline = flag('baseline', null);
const noAxe = args.includes('--no-axe');
const noDetect = args.includes('--no-detect');
const urls = args.filter((a) => !a.startsWith('--'));
if (!urls.length) {
  console.error('usage: qa.mjs <url...> [--out dir] [--vp 390,768,1024,1440] [--baseline dir] [--no-axe] [--no-detect]');
  process.exit(1);
}
mkdirSync(out, { recursive: true });

const slug = (url) => {
  const u = new URL(url);
  return (u.host + u.pathname).replace(/\/+$/, '').replace(/[^a-z0-9]+/gi, '_') || 'root';
};

const browser = await chromium.launch();
const report = [];

for (const url of urls) {
  for (const width of viewports) {
    const height = width < 600 ? 844 : width < 1100 ? 1024 : 900;
    const ctx = await browser.newContext({
      viewport: { width, height },
      deviceScaleFactor: 1,
      isMobile: width < 600,
      hasTouch: width < 1100,
      reducedMotion: 'reduce',
    });
    const page = await ctx.newPage();
    const consoleErrors = [];
    const failed = [];
    page.on('console', (m) => m.type() === 'error' && consoleErrors.push(m.text().slice(0, 200)));
    page.on('pageerror', (e) => consoleErrors.push(String(e).slice(0, 200)));
    page.on('response', (r) => r.status() >= 400 && failed.push(`${r.status()} ${r.url()}`));

    const status = (await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 }))?.status() ?? 0;
    // Scroll through so lazy images and scroll-triggered content load.
    await page.evaluate(async () => {
      for (let y = 0; y < document.body.scrollHeight; y += innerHeight / 2) {
        scrollTo(0, y);
        await new Promise((r) => setTimeout(r, 80));
      }
      scrollTo(0, 0);
    });
    await page.waitForLoadState('networkidle').catch(() => {});

    const base = `${slug(url)}@${width}`;
    await page.screenshot({ path: join(out, `${base}-fold.png`), animations: 'disabled' });
    await page.screenshot({ path: join(out, `${base}-full.png`), fullPage: true, animations: 'disabled' });

    const layout = await page.evaluate(() => {
      const vw = document.documentElement.clientWidth;
      const describe = (el) => {
        const cls = typeof el.className === 'string' ? el.className.trim().split(/\s+/).slice(0, 2).join('.') : '';
        return `${el.tagName.toLowerCase()}${el.id ? `#${el.id}` : ''}${cls ? `.${cls}` : ''}`;
      };
      const overflow = [];
      for (const el of document.querySelectorAll('body *')) {
        const r = el.getBoundingClientRect();
        if (r.width && (r.right > vw + 1 || r.left < -1) && getComputedStyle(el).position !== 'fixed') {
          if (!el.closest('[aria-hidden="true"], .sr-only')) overflow.push(`${describe(el)} [${Math.round(r.left)}..${Math.round(r.right)}]`);
        }
      }
      const smallText = new Set();
      for (const el of document.querySelectorAll('p, li, a, span, label, td, button')) {
        const fs = parseFloat(getComputedStyle(el).fontSize);
        if (fs < 12 && el.textContent.trim() && el.offsetParent) smallText.add(`${describe(el)} ${fs}px`);
      }
      return {
        scrollWidth: document.documentElement.scrollWidth,
        clientWidth: vw,
        pageHeight: document.documentElement.scrollHeight,
        overflow: overflow.slice(0, 15),
        brokenImages: [...document.images].filter((i) => i.complete && i.naturalWidth === 0).map((i) => i.currentSrc || i.src),
        smallText: [...smallText].slice(0, 10),
        fonts: [...new Set([...document.querySelectorAll('h1,h2,h3,p,a,button')].map((e) => getComputedStyle(e).fontFamily.split(',')[0].trim()))],
      };
    });

    // Viewable slices of the full page (models downscale tall images to mush).
    const full = PNG.sync.read(readFileSync(join(out, `${base}-full.png`)));
    const sliceH = height * 2;
    for (let y = 0, i = 0; y < full.height; y += sliceH, i++) {
      const h = Math.min(sliceH, full.height - y);
      const s = new PNG({ width: full.width, height: h });
      PNG.bitblt(full, s, 0, y, full.width, h, 0, 0);
      writeFileSync(join(out, `${base}-s${String(i).padStart(2, '0')}.png`), PNG.sync.write(s));
    }

    let axe = null;
    if (!noAxe && (width === Math.min(...viewports) || width === Math.max(...viewports))) {
      const res = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa']).analyze();
      axe = res.violations.map((v) => ({ id: v.id, impact: v.impact, count: v.nodes.length, help: v.help, sample: v.nodes[0]?.target.join(' ') }));
    }

    let diff = null;
    if (baseline) {
      const prev = join(resolve(baseline), `${base}-full.png`);
      if (existsSync(prev)) {
        const a = PNG.sync.read(readFileSync(prev));
        const b = PNG.sync.read(readFileSync(join(out, `${base}-full.png`)));
        const w = Math.min(a.width, b.width);
        const h = Math.min(a.height, b.height);
        const crop = (img) => {
          const c = new PNG({ width: w, height: h });
          PNG.bitblt(img, c, 0, 0, w, h, 0, 0);
          return c;
        };
        const d = new PNG({ width: w, height: h });
        const changed = pixelmatch(crop(a).data, crop(b).data, d.data, w, h, { threshold: 0.1 });
        writeFileSync(join(out, `${base}-diff.png`), PNG.sync.write(d));
        diff = { changedPct: +((changed / (w * h)) * 100).toFixed(2), heightDelta: b.height - a.height };
      }
    }

    report.push({ url, width, status, ...layout, consoleErrors, failedRequests: failed, axe, diff });
    await ctx.close();
  }
}
await browser.close();

const detect = {};
if (!noDetect) {
  const chrome = chromium.executablePath();
  for (const url of urls) {
    try {
      execFileSync('impeccable', ['detect', '--json', url], { env: { ...process.env, IMPECCABLE_BROWSER: chrome }, stdio: ['ignore', 'pipe', 'ignore'] });
      detect[url] = [];
    } catch (e) {
      if (e.status === 2) detect[url] = JSON.parse(e.stdout.toString()).map((f) => `${f.antipattern}: ${f.snippet}`);
      else detect[url] = [`detector failed (exit ${e.status ?? e.code}); is impeccable installed?`];
    }
  }
}

writeFileSync(join(out, 'report.json'), JSON.stringify({ report, detect }, null, 2));
const lines = [`# QA ${new Date().toISOString()}`, `Screens: ${out}`, ''];
for (const r of report) {
  const issues = [
    r.status >= 400 && `PAGE STATUS ${r.status}`,
    r.scrollWidth > r.clientWidth && `HORIZONTAL SCROLL ${r.scrollWidth}>${r.clientWidth}`,
    r.overflow.length && `overflowing: ${r.overflow.slice(0, 5).join(', ')}`,
    r.brokenImages.length && `broken images: ${r.brokenImages.join(', ')}`,
    r.failedRequests.length && `failed requests: ${r.failedRequests.slice(0, 5).join(', ')}`,
    r.consoleErrors.length && `console errors: ${r.consoleErrors.slice(0, 3).join(' | ')}`,
    r.smallText.length && `text <12px: ${r.smallText.slice(0, 4).join(', ')}`,
    r.axe?.length && `axe: ${r.axe.map((v) => `${v.id}(${v.impact},${v.count}) e.g. ${v.sample}`).join('; ')}`,
    r.diff && `diff vs baseline: ${r.diff.changedPct}% px, height ${r.diff.heightDelta >= 0 ? '+' : ''}${r.diff.heightDelta}`,
  ].filter(Boolean);
  lines.push(`## ${r.url} @${r.width}  (height ${r.pageHeight}px, fonts: ${r.fonts.join(', ')})`);
  lines.push(...(issues.length ? issues.map((i) => `- ${i}`) : ['- clean']), '');
}
for (const [url, findings] of Object.entries(detect)) {
  lines.push(`## impeccable detect ${url}`, ...(findings.length ? findings.map((f) => `- ${f}`) : ['- clean']), '');
}
writeFileSync(join(out, 'report.md'), lines.join('\n'));
console.log(lines.join('\n'));
