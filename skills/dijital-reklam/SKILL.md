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
- Business portfolio: **Agara Ajans `1727452101693798`** — the only agency Business. Owns the page (IG `@agaraajans` `17841417308591682`) and the panel's Meta app **"Agara Reklam" `1853939885788684`** (created 2026-11-07; use cases: Marketing API ads, measure, leads, Instagram; redirect `https://reklam.agarajans.com/reklam/oauth/meta`; creds in VDS `~/agarajans_root/websites/agara-reklam/.env`). Panel `meta_business` = A. Clients share assets to this ID.
- Deleted 2026-11-07: old app `1855093689003066` (removed) and Business `1129570899397320` (scheduled, final after 24 h). Do not reuse these IDs.
- Client assets: client shares ad account + page to the agency Business as partner; card stays on the client's account.
- Chrome via omp relay is available for UI-only steps (see `~/erdem-memory/machine.md`), only while Erdem's PC and Chrome are open. Never design anything that needs the PC to stay on: unattended work must live on Meta (automations, message templates) or the VDS panel (hourly sync, alerts, caps, portal).

## New client onboarding (once per client)
1. Agara MCP `create_client_invite` (no `workspace_id` = client opens a new business; with it = existing business; `login_name` suggests a username, e.g. `mcg`; `send_to` mails the link — default to Erdem's `erdem.uluta@gmail.com`, he forwards). Link: 7 days, single use. Staff UI: `/davetler` or workspace tab `tercihler`.
2. Client fills the form: contact, e-mail, optional username, own password, budget proposal, regions, audience, offer, goals. Panel opens the business (if new), the `client_admin` user, portal sections `overview, ads, requests, goals, settings`, then sends the client to `/portal/meta-baglanti`.
3. Client shares ad account (full control) + page + IG to agency Business `1727452101693798`, adds card, optional spend limit, clicks "Kontrol et" (or `client_meta_check`). Panel links the account and notifies managers.
4. Read `get_client_prefs` (client's own budget/regions/offer/goals; updates notify managers). Budget proposal is NOT a cap: propose `set_monthly_cap` to Erdem and set it only with his approval; `set_goals` from the client's goals.
5. Meta MCP sees the client account after the hourly business sync; verify with `ads_get_ad_accounts`.
6. First campaign: workflow below; plan from client prefs. First real campaign doubles as the test of image creative + messaging via Meta MCP.
Manual alternative without invite: `create_workspace`, `portal_settings`, `create_client_user` (temp password).

Chrome-only steps (PC must be on during the session): client Page auto DM / ice breakers, Instant Forms, per-ad message templates. Everything else is MCP.

## Standard workflow
1. **Brief:** client, goal (lead/message/sale/traffic), offer, region, budget, duration, creative from Erdem. Ask only for what's missing.
2. **Research:** sector, region, competitors (web search, Meta Ad Library). Set target CPL from the budget worksheet.
3. **Plan:** objective, one campaign, few ad sets, Advantage+ audience by default, 2–4 copy variants. For messaging ads (Erdem's choice 2026-11-07): no per-option survey; one automatic DM. Meta MCP creatives use the Page's default greeting, so set the client Page's automatic message once (Business Suite > Gelen kutusu > Otomasyonlar > Anlık yanıt, Messenger + Instagram; via Chrome during onboarding). It runs on Meta, PC not needed, and also answers organic DMs — word it for both.
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
- Instagram poll sticker in ads (Stories/Reels): Meta gives counts only; Instagram does not share poll votes with apps, so no automatic DM to voters ([Chatfuel](https://chatfuel.com/blog/instagram-polls-guide)). DMing people who only viewed an ad is impossible and against policy. Use: poll for engagement + click-to-Instagram-Direct button → Page auto DM; or ice breakers in DM as the "poll" (answers arrive as messages).
- Lead forms (Instant Forms) are not creatable via Meta MCP → Ads Manager by hand or Chrome.

## Known panel gaps (Agara Reklam)
No pixel install on client sites, no Conversions API, no CRM→Meta "won" event upload. Proposed to Erdem 2026-11-07; not built yet. Check `MODULES.md` in `~/dev_space/agara-reklam-workspace/agara-reklam` before assuming.
