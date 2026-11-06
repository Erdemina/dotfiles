---
name: dijital-reklam
description: Use for any digital marketing/ads work for Agara Ajans or its clients — Meta/Instagram/WhatsApp, Google, TikTok ads; campaign planning, creative, targeting, pixel/CAPI, budgets, reports, Turkish ad law. Triggers: "reklam", "kampanya", "kitle", "piksel", "lead", "bütçe".
---

# Dijital reklam (Agara Ajans)

Erdem runs all digital marketing through the agent. Replies in Turkish (STE rules from AGENTS.md). Read the reference that matches the task:
- `references/meta.md` — Meta structure, creative, messaging ads, Pixel/CAPI, audiences, optimization, policy, Turkey fees, benchmarks.
- `references/google-olcum-hukuk.md` — Google Ads, funnel, KPI formulas, budget worksheet, client reporting, KVKK/İYS/Ticari Reklam law, TikTok.

Tags in references: `[V]/[G]` verified primary source, `[H]/[S]` secondary, `[R]/[P]` recommendation, `[DOĞRULANMADI]` unverified — say so to the user before relying on it.

## Tools and who does what
| Need | Tool |
|---|---|
| Clients, CRM, goals, requests, reports, client approval link, portal | Agara Reklam MCP (`mcp__agara_reklam_*`), panel `reklam.agarajans.com` |
| Build campaign / ad set / creative with image, audiences, pixel/dataset quality, insights | Meta Ads MCP (`mcp__meta_ads_*`, `https://mcp.facebook.com/ads`) |
| UI-only steps (Business settings, billing, sharing assets) | Chrome via omp browser relay (`browser.open({app:{relay:true}})`) |

Meta MCP auth: connected as Erdem Ulutaş's personal Facebook user (normal; Meta MCP always authenticates a person). omp `mcp.json` entry `meta-ads` uses `oauth.clientId 4510005499318155`, redirect `http://127.0.0.1:3000/callback` (Meta rejects DCR for "oh-my-pi"). Re-login: `/mcp reload` then `/mcp reauth meta-ads`.

## Known assets (verify, may be stale — checked 2026-11-07)
- Agara Ajans Facebook page `1395368806994583`.
- Ad account `38910131548630571` (TRY, no payment method yet, not inside any Business portfolio).
- Two Business portfolios both named "Agara Ajans", both unverified, no ad accounts. Decision 2026-11-07: keep both, move nothing, delete nothing.
  - A `1727452101693798`: owns the page (page is linked to IG `@agaraajans` `17841417308591682`; Meta blocks removing an IG-linked page from a Business). Give clients A's ID for sharing assets.
  - B `1129570899397320` (renamed "Agara Ajans - Uygulama" 2026-11-07; app ownership transfer to A fails with "unexpected technical issue"): owns Meta app "Agara Ajans Reklam" `1855093689003066`; the Agara Reklam panel's selected `meta_business` is B. Never delete B. When the first client shares to A, switch the panel's Meta business to A (`ads_set_meta_business`) with Erdem's approval, or clients' assets won't sync.
- Client assets: client shares ad account + page to the agency Business as partner; card stays on the client's account.
- Chrome via omp relay is available for UI-only steps (see `~/erdem-memory/machine.md`).

## Standard workflow
1. **Brief:** client, goal (lead/message/sale/traffic), offer, region, budget, duration, creative from Erdem. Ask only for what's missing.
2. **Research:** sector, region, competitors (web search, Meta Ad Library). Set target CPL from the budget worksheet.
3. **Plan:** objective, one campaign, few ad sets, Advantage+ audience by default, 2–4 copy variants. For messaging ads: welcome message + up to 4 ice-breaker options and a reply per option.
4. **Agara Reklam:** draft (`ads_create_draft`) → checks (`ads_get_draft`) → client approval link (`ads_send_for_approval`).
5. **Meta MCP:** create everything **PAUSED**; upload creative; show preview (`ads_get_ad_preview`).
6. **Publish only on Erdem's explicit "yayına al"**. Same for budget/status changes on live campaigns. Never enter payment data.
7. **Monitor:** day 3, day 7, weekly; playbook in `meta.md` §6 (learning phase, CPL rise, fatigue, +20% scaling).
8. **Report monthly:** structure in `google-olcum-hukuk.md` §4; CRM outcomes (won deals), not only platform leads.

## Hard rules
- Real-money and live changes need explicit approval each time.
- Real estate → special ad category check (`meta.md` §7). Discount claims → 30-day lowest-price rule; "en ucuz/1 numara" needs proof; influencer → "Reklam/Tanıtım" label.
- Tracking needs KVKK cookie opt-in on client sites; commercial SMS/WhatsApp/e-mail needs İYS consent.
- Budget math includes the Türkiye 5% Meta location fee (from 1 Jul 2026, billed separately) and taxes; tell the client.
- Lead forms (Instant Forms) are not creatable via Meta MCP → Ads Manager by hand or Chrome.

## Known panel gaps (Agara Reklam)
No pixel install on client sites, no Conversions API, no CRM→Meta "won" event upload. Proposed to Erdem 2026-11-07; not built yet. Check `MODULES.md` in `~/dev_space/agara-reklam-workspace/agara-reklam` before assuming.
