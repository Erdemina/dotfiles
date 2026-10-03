---
name: web-craft
description: Pipeline for designing or redesigning any website or landing page: brief, direction, Figma, build, browser screenshots, critique, responsive QA. Use for every site build, redesign or "it looks generic/AI" complaint.
---

# Web craft pipeline

Compiling, tests passing or a clean build is not done. Done is: you looked at the rendered page at every viewport, it holds a point of view specific to this business, and `qa.mjs` is clean.

Design knowledge lives in the **impeccable** skill (`craft-floor.md` before any UI edit, `critique.md` for reviews, `new-work.md` for a new visual world). This skill is the order of work and the gates. Don't also load `frontend-design`; impeccable is its superset.

## Stages and their gate

Each stage leaves a file in the project's `design/` folder (commit it). A later stage never starts without the earlier file.

1. **Research → `design/brief.md`.** Business, audience, the visitor's one job on the page, real content inventory (prices, hours, products, photos the client really has). 5+ references from the business's own world, not other websites: signage, packaging, workwear, receipts, tools, the street it sits on. Write what each reference gives you (a colour, a lettering style, a material, a layout habit).
2. **Character → design language, `design/direction.md`.** First the character: three adjectives plus one sentence of what it must never feel like. Then derive: type (families, scale, why they fit this trade), 4-6 named hex colours taken from the references, grid (columns, margin, max measure), an ASCII composition for every section, and the one signature element the page will be remembered by. Test: would you have produced this for a different business in the same sector? If yes, redo that part and note what changed.
3. **Figma → board.** Build a direction board in Figma (tokens, hero, two key sections at 1440 and 390) through the Figma MCP so the user can see and edit the direction before code. Budget rules below. If Figma is unavailable, render the same board as one static HTML page and screenshot it. Show the user the board when the job is a client site.
4. **Build.** Real content only. Use components only where they serve this design. Never install a UI kit and accept its defaults. Self-host fonts.
5. **Render → screenshot → critique → fix.** Run `scripts/qa.mjs` (below) on the local or staging URL. Open the slices yourself (`*@1440-s*.png`, `*@390-s*.png`, plus the folds) and write the critique against the ban list and `direction.md`, worst first. Fix in one batch and rerun. Do at least two rounds and stop when a round finds nothing above cosmetic.
6. **Responsive + final QA.** Check 390/768/1024/1440 slices one by one: no horizontal scroll, no orphaned single words in headings, tap targets ≥44px, the nav works with touch and keyboard. axe at 0 serious/critical, impeccable detector clean or each finding consciously waived. Run `--baseline <previous run dir>` after late fixes to see what really moved.

## Never ship (unless the brief literally asks for it)

Generic SaaS landing structure; gradient decoration or gradient text; glow and coloured halos; one big radius on everything; rounded cards as the default container; cards inside cards; pills and badges that carry no state; eyebrow label above every heading; giant generic hero headline + subline + two buttons + floating stat badge; meaningless metrics ("2009'dan beri", "%98 memnuniyet") used as decoration; 3-column icon + title + text feature grids; every section the same "heading left, content right" split; alternating cream/grey/navy section bands as the only rhythm; padding that inflates the page instead of grouping it; random Lucide icons (icons only when they label something, one set, one stroke); fake dashboards or UI mockups; generic AI copy ("seamless", "elevate", "yolculuğunuz başlıyor"); shadcn/Tailwind template defaults left untouched; stock photos from unrelated shoots side by side. Also impeccable's saturated looks: cream + serif + terracotta, black + acid accent, hairline newspaper columns.

What to spend effort on instead: typography (it carries the identity), hierarchy that reads in 3 seconds, a real grid with deliberate breaks, varied section compositions, imagery with one photographic voice (crop, colour grade, subject distance), interaction that answers the visitor (state, feedback), clear IA, and copy in the business's own vocabulary.

## Tools

- **QA script:** `node <skill-dir>/scripts/qa.mjs <url...> [--out dir] [--vp 390,768,1024,1440] [--baseline dir]`. First use on a machine: `npm ci --prefix <skill-dir>/scripts` and `npx --prefix <skill-dir>/scripts playwright install chromium`. It writes `report.md` (page status, horizontal overflow with the offending elements, broken images, failed requests, console errors, text <12px, axe WCAG 2.2 AA at min/max viewport, baseline pixel diff), full and fold screenshots, viewable slices, and runs `impeccable detect` on each URL with Playwright's Chromium.
- **Interactive checks:** omp's `browser` tabs (hover, menus, forms, focus order); in Claude Code, Playwright through Bash.
- **Figma MCP** (`https://mcp.figma.com/mcp`, OAuth). Account Erdemina is on the **Starter** plan: about 20 read calls per month (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`...). Write calls (`use_figma`, `create_new_file`, `generate_figma_design`, `upload_assets`) don't count. So: build boards with writes, read back at most once per board, never read in a loop. From omp without native auth: `cd /tmp && timeout 300 claude -p "<prompt>" --model sonnet --allowedTools "mcp__figma__use_figma,mcp__figma__create_new_file"`. The prompt goes before the flags.
- **Fonts:** Fontshare, Google Fonts, Velvetyne, Collletttivo, uncut.wtf. Pick from the brief's character. Bricolage Grotesque, Inter, Figtree, Space Grotesk, DM Sans and Instrument Serif are the current AI defaults; they need a reason.
- **Icons:** only when an icon labels something. Phosphor or Tabler (one weight), or authored SVG for the trade's own objects.

## Agara sites

The panel contract (KB onboarding §6: `data-pe`/`data-el` editor markers, collections, forms) and the publish pattern (static export, nginx, Traefik `proxy-net`) stay intact through a redesign. Grep the markers before and after; the count must not drop unless a section was removed on purpose.
