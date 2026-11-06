# Meta Ads Reference for Agara Ajans (Turkey SMB clients) — researched 2026-11-06

Legend: **[V]** verified in a page fetched this session (URL given). **[H]** practitioner/secondary source, not Meta policy. **[R]** my recommendation or derived arithmetic. **[DOĞRULANMADI]** unverified / primary source unreadable. Meta Business Help Center bodies (facebook.com/business/help/…) render empty to non-browser fetches; claims citing them rely on search snippets/secondary sources and are flagged.

---
## 1. Account structure (2026)

**Objectives (ODAX):** Awareness, Traffic, Engagement, Leads, App promotion, Sales; each has a *conversion location* (website, app, messaging apps, instant forms, calls) and a *performance goal* that can differ from the objective. [DOĞRULANMADI body; Help Center https://www.facebook.com/business/help/1438417719786914 , /2035196646663270 , /355670007911605] API: `OUTCOME_SALES`, `OUTCOME_LEADS`, … [V https://developers.facebook.com/documentation/ads-commerce/marketing-api/advantage-campaigns.md]

**Advantage+ campaigns replaced ASC/AAC** [V same URL]
- Advantage+ sales/app/leads is now a *state* (`ADVANTAGE_PLUS_SALES|APP|LEADS`) of a normal campaign, reached only if all 3 levers are on: (1) budget at **campaign level**, (2) **Advantage+ audience** (or only `geo_locations` set), (3) **Advantage+ placements** (no placement targeting/exclusions on any ad set; account-level exclusions OK). Any lever off → `DISABLED`.
- Legacy ASC/AAC creation removed in API v25.0; legacy edits blocked at v26.0; migration (`migrate_to_advantage_plus`) forces re-learning. Docs now reference v27.0. Advantage+ sales allows >1 ad set. `existing_customer_budget_percentage` is gone → replicate with 2 ad sets (existing-customer custom audience with `daily_spend_cap` + duplicate excluding it).
- **Placement control is being removed for Sales and Leads objectives** (Ads Manager alert; still allowed for Awareness/Traffic/Engagement and via account-level exclusions). Loomer: use value rules instead. [H, Sep 2026 https://pubcast.jonloomer.com/what-does-the-removal-of-placement-control-mean/] → always Advantage+ placements for Leads/Sales.

**Budget:** campaign-level budget (CBO / Advantage+ campaign budget) is required for the Advantage+ state; Meta's CAPI best practices also recommend automatic placements + CBO + simple structure. [V https://developers.facebook.com/documentation/ads-commerce/conversions-api/best-practices.md] Use ABO only for hard per-segment spend limits or equal-budget tests. [R]

**Learning phase / consolidation**
- ~**50 optimization events per ad set per 7 days** to exit learning, else "Learning limited". [H https://pubcast.jonloomer.com/the-learning-phase-is-just-a-label/ ; Meta https://www.facebook.com/business/help/269269737396981 body DOĞRULANMADI]
- Meta's Peak Season 2026 guide (as quoted by Loomer): ad sets under ~50 conv/week ran **~28% costlier per purchase**; max ad sets = `weekly budget ÷ (cost per result × 50)`. Loomer: start with 1 campaign/1 ad set; add a 2nd only at ≥100 conv/week with a concrete reason; creative-test ad sets only if budget supports. [H https://pubcast.jonloomer.com/your-extra-ad-sets-are-costing-you-28-more/ ; original Meta article not read]
- Significant edits (new ads, ad/targeting changes, big budget jumps) can restart learning; no published % threshold; "High performing" ad sets can be raised without re-entering learning; the label is "just a label" – the algorithm always learns. [H Loomer; Meta https://www.facebook.com/business/help/316478108955072 body DOĞRULANMADI]
- **Turkey math** [R]: if CPL ≈ 60–100 TL (§8, illustrative), 50 leads/wk ≈ 3,000–5,000 TL/wk ≈ 430–715 TL/day in ONE ad set. Below that: optimize a higher-volume event (form submit / messaging conversation started), keep one ad set, accept "learning limited" rather than splitting.

**Split only when:** different conversion goal; different country/language; special-ad-category vs not; separate budget control (existing vs new customers, two branches); ≥100 conv/wk per ad set. Otherwise consolidate.

---
## 2. Creative

**Andromeda / creative = targeting.** Retrieval (Andromeda) scans tens of millions of ads → thousands of candidates; GEM-type models rank. The system **groups visually/thematically similar ads as one creative** – learnings are shared at creative level, so near-duplicates add no reach. Meta separates *iteration* (same visual, new CTA text) from *diversification* (distinct personas/use cases/formats); recommends a broad portfolio of genuinely different concepts. Meta-reported: image-gen +11% CTR/+7.6% CVR, text-gen +3% CTR, Advantage+ sales adopters +22% ROAS. Fatigue = overexposure; similarity = ads look alike (also causes fatigue). Creative insights (fatigue flags, ~150 themes) being tested in Ads Manager. [V https://www.facebook.com/business/news/demystifying-creative-diversification (16 Dec 2025)]

**Specs** (Meta Ads Guide as relayed, Oct 2026; confirm in preview) [H https://kive.ai/learn/meta-ad-sizes]
| Placement | Ratio / size | Notes |
|---|---|---|
| FB/IG Feed | **4:5**, 1440×1800 (1:1 ok; use for carousels) | JPG/PNG ≤30 MB |
| Stories/Reels | **9:16**, 1440×2560 | keep text/logos out of top **14%**, bottom **35%**, sides **6%** (Reels w/ disclaimer: bottom 40%) |
| Text | FB Feed primary 50–150 ch, headline 27; IG Feed primary 125, headline 40; FB Reels primary 40; IG Reels primary 44 | ratio tolerance 3% FB, 1% IG |
Ads Manager "Safe zone guardrail" overlay exists; Meta auto-fills missing ratios – upload own 4:5 + 9:16 per concept and review auto variants. (Meta https://www.facebook.com/business/help/980593475366490 body unreadable)

**Hook/text/UGC** [R/H; no numeric Meta rule fetched]: show offer/outcome in first 1–3 s (not logo); readable with sound off; handheld UGC-style/real-person beats studio for SMB services; minimal on-image text inside safe zone; one CTA; Turkish copy must avoid implied personal attributes (§7).

**Testing method** [R]: (1) 4–8 *distinct concepts* as ads in ONE ad set; (2) run ≥7 days and ≥2–3× target CPL spend per ad before judging; (3) judge on cost per **qualified** lead (CRM); (4) winners → new iterations (hook/first frame/CTA), losers off; (5) formal tests via Ads Manager A/B test https://developers.facebook.com/documentation/ads-commerce/marketing-api/guides/split-testing

**Fatigue signals:** Meta's creative-fatigue label/insight; CPM↑ + link CTR↓ + CPL↑ at constant targeting; frequency rising in a narrow audience. **No universal frequency threshold**: Loomer's $450k broad-US campaign sat at frequency 4.5 without fatigue; ads dying in 1–2 weeks usually means they only worked on warm audiences. [H https://pubcast.jonloomer.com/when-does-frequency-lead-to-creative-fatigue/] Small local geos saturate fast → refresh every 2–4 weeks or sooner [R].

---
## 3. Messaging ads and lead forms

**Click-to-WhatsApp/Messenger/IG Direct** suit Turkish SMBs (renovation, beauty, auto, restaurants). Best practices (welcome message, ice breakers/FAQ, fast replies): https://www.facebook.com/business/help/269324800441478 [DOĞRULANMADI body]. [R] Turkish welcome message stating what you do + 2–4 ice-breakers matching the ad ("Fiyat al", "Randevu", "Konum"); reply in minutes; use WhatsApp Business app/Cloud API + CRM.
- **Measure via CAPI:** `action_source:"business_messaging"`, `messaging_channel:"whatsapp"|"messenger"`, `user_data.ctwa_clid` (from message-webhook `referral` object; store per conversation) + `whatsapp_business_account_id`; Messenger: `page_id` + `page_scoped_user_id`. No ctwa_clid → hashed em/ph **plus `page_id`** (`external_id` alone is ignored). Events: `Purchase`/`Lead` with `custom_data.value,currency`. [V https://developers.facebook.com/documentation/ads-commerce/conversions-api/business-messaging.md] CTWA is also subject to the Turkey location fee (§7).

**Instant Forms:** types **More volume** (quick mobile submit), **Higher intent** (context under contact fields + review/confirm screen; certain mobile feed placements only), **Rich creative**. Meta claims Higher intent cuts marginal submissions, gives no quantified lift. Conditional logic (route/close on non-qualifying answers) may *raise* CPL. Test form length vs completion rate, CPL, cost per conversion. [H https://www.variafy.com/guides/facebook-instant-forms-more-volume-vs-higher-intent citing Meta help 252352181957512, 435270316658768, 3373123166040766 – bodies unreadable]

**Lead-quality tactics**
1. **CRM → CAPI "Conversion Leads"** (native instant forms): send *every* stage (lead → MQL → opportunity → converted); `event_name` = CRM stage, `action_source:"system_generated"`, `custom_data.lead_event_source`=tool name, `custom_data.event_source:"crm"`; identify by `lead_id` (15–17 digits, `leadgen_id` webhook; highest priority) or hashed email/phone; `event_time` ≤7 days old and after lead creation. [V https://developers.facebook.com/documentation/ads-commerce/conversions-api/conversion-leads-integration/payload-specification.md]
2. [R] 1–2 qualifying custom questions (budget band, timing, district, service); phone required.
3. [R] Honest "from X TL" framing filters tyre-kickers; call/WhatsApp within minutes; track reached → appointment → won.
4. [R] Compare forms by cost per *qualified* lead after comparable follow-up time, not CPL.

---
## 4. Measurement

**Pixel + CAPI redundancy** [V https://developers.facebook.com/documentation/ads-commerce/conversions-api/best-practices.md]: send same events from browser and server; dedup needs identical `event_name` + `event_id` (or `external_id`+`fbp`). Required on server events: `action_source`; web: `event_source_url`, `client_user_agent`; include `external_id` and `event_id` on all events; send near real time; use Test Events + Payload Helper; Business SDK hashes for you; agencies send `partner_agent`; offline events via CAPI with non-`website` `action_source`. Events with only (ct+country+st+zp+ge+UA), (db+UA), (fn+ge) or (ln+ge) are rejected.
**EMQ** (/10) shows in Events Manager for **web events only**; only *matched* events count for attribution/optimization. Strong keys: em, ph, fn, ln, client_ip_address, client_user_agent, fbp, fbc, external_id.

**Hashing (SHA-256 hex, after normalization)** [V https://developers.facebook.com/documentation/ads-commerce/conversions-api/parameters/customer-information-parameters.md]
| Field | Rule |
|---|---|
| `em` | trim + lowercase |
| `ph` | digits only, no leading zeros, **country code required** → `0532 123 45 67` → `905321234567` |
| `fn`,`ln` | lowercase, no punctuation; Roman a–z recommended, else UTF-8 |
| `ct`,`st`,`zp`,`country` | lowercase, no spaces/punctuation (`istanbul`); country ISO-2 `tr` |
| `ge`,`db` | `f`/`m`; `YYYYMMDD` |
| `external_id` | hashing recommended |
| **never hash** | `client_ip_address`, `client_user_agent`, `fbc`, `fbp`, `lead_id`, `ctwa_clid`, `page_id`, `page_scoped_user_id` |
`fbc` = `fb.{idx}.{ts}.{fbclid}`; `fbp` = `fb.{idx}.{ts}.{rand}`; refresh periodically. [R] Turkish chars: lowercase with a locale-independent function (tr-locale `İ/I` lowercasing corrupts) and consider ASCII transliteration (ç→c, ş→s, ğ→g, ı→i, ö→o, ü→u); validate in Test Events [which yields better EMQ: DOĞRULANMADI].

**Attribution (2026).** Default = **7-day click + 1-day view + 1-day engage-through**. *3 Mar 2026:* click-through for website/in-store conversions = **link clicks only**; likes/shares/saves → engage-through (video 5 s). *12 Jan 2026:* Insights API stopped returning `7d_view`/`28d_view` (1d_click, 7d_click, 28d_click, 1d_view, 1d_ev remain); frequency breakdown 6 months, hourly/unique-count breakdowns 13 months, totals 37 months. The ad-set attribution setting also steers optimization; "Compare attribution settings" views other windows without changing delivery. For instant-form leads the window matters little; for website leads a lot. Reported leads can drop vs CRM since March 2026 without a real drop. [V https://developers.facebook.com/blog/post/2025/10/16/ads-insights-api-metric-availability-updates ; H https://www.variafy.com/guides/facebook-ads-attribution-settings (cites Meta …/news/click-attribution)]

**AEM (iOS):** domain verification + prioritized events; historic limit 8 events/domain — [DOĞRULANMADI, may have been relaxed in 2025]. [R] Verify domain; Lead/Purchase (+Contact/Schedule) top priority.

**UTM** [R; Meta macros `{{campaign.name}} {{adset.name}} {{ad.name}} {{campaign.id}} {{placement}} {{site_source_name}}` – DOĞRULANMADI this session]: `?utm_source=meta&utm_medium=paid_social&utm_campaign={{campaign.name}}&utm_content={{ad.name}}&utm_term={{adset.name}}&utm_id={{campaign.id}}`; names ASCII, no spaces; scheme `client_objective_offer_YYYYMM`.

**Lead → won loop** [R on V docs]: store `fbclid/fbc`, `lead_id`, `ctwa_clid` at capture – cannot be retrofitted. Instant forms → Conversion Leads; website leads → CAPI hashed em/ph + fbc/fbp, then "qualified"/"won" (`Purchase` with value); CTWA → business_messaging CAPI.

---
## 5. Audiences
- **Default: broad + Advantage+ audience** (targeting = suggestions; geo, optionally age are hard limits); individual options can be relaxed (Advantage Lookalike/Custom Audience/Detailed Targeting). [V advantage-campaigns doc]
- **Custom audiences:** website (pixel/CAPI), Meta engagement (IG/FB/video/forms), customer list (hashed em/ph), WhatsApp/Messenger interactions. Retention ≤180 d website / ≤365 d engagement – from memory [DOĞRULANMADI].
- **Lookalikes:** fine outside special categories (1–10% scale, [DOĞRULANMADI]); **blocked in Housing/Employment/Financial**. [V special-ad-category doc, §7]
- **Exclusions** [R]: exclude customers (+ last 30–90 d leads) from prospecting; converted leads from lead campaigns.
- **Retargeting windows** [R/H]: 0–7 d hot, 8–30 d, 31–90/180 d; small local audiences exhaust fast and inflate frequency; remarketing flatters ROAS and doesn't scale → judge scale-worthiness on the *new-audience* segment and 1-day-click/incremental results. [H https://pubcast.jonloomer.com/how-do-you-scale-your-meta-ads-budget/]

---
## 6. Optimization playbook

**CPL rising – check in order** [R]:
1. Tracking: Events Manager volume/EMQ/dedup; CRM vs Meta lead count (Mar-2026 attribution change).
2. Auction/cost: CPM up? (TR CPM 2.5× in a year, §8; Q4/BFCM) and the 5% location fee not shown in Ads Manager (§7).
3. Creative: fatigue label, CTR↓, similarity → add *different* concepts.
4. Audience: narrow geo/remarketing-heavy → widen/Advantage+.
5. Structure: <50 conv/wk per ad set → consolidate; recent significant edits.
6. Funnel: landing speed/mobile, form friction, WhatsApp reply time, CPQL not just CPL.
7. Offer/price/competition; rejected ads shifting delivery.

**Kill/scale** [R]: kill an ad after ~2–3× target CPL with no qualified lead (ad, not ad set). Scale only ad sets profitable on new-audience 1-day-click. Budget steps: "+20%/2–3 days" is a community heuristic; Loomer uses ~**15%**, waits a few days, repeats; no official threshold; expect temporary dip after any increase; for big jumps duplicate to a new campaign (restarts learning). [H Loomer scaling episode]
**Frequency caps:** no universal number; manage via audience size + refresh. [H] **A/B & lift:** one variable, equal budget, pre-set decision metric (cost per qualified lead); Conversion Lift for incrementality. [V links in CAPI best practices]

---
## 7. Policy, restrictions, Turkey specifics

**Special ad categories (real estate!)** `HOUSING`, `EMPLOYMENT`, `FINANCIAL_PRODUCTS_SERVICES` (replaced CREDIT; US-required from Jan 2025), `ISSUES_ELECTIONS_POLITICS`, `NONE`. Every API-created campaign must set `special_ad_categories` (`NONE`/empty if none) and `special_ad_category_country` when a category is chosen. [V https://developers.facebook.com/documentation/ads-commerce/marketing-api/audiences/special-ad-category.md]
- Restrictions (Housing/Employment/Financial): age fixed 18–65+; all genders; no zip/neighborhood/metro/subcity; min radius 15 km Europe / 25 km US-CA; no location or detailed-targeting exclusions; no behavior/demographic targeting; **no lookalikes/saved audiences**; custom audiences + Advantage+ audience OK; no bid multipliers; hard errors. [V same]
- **Scope:** mandatory for US-based/US-reaching, Canada (Dec 2020), Europe (Dec 2021). *"Businesses outside the U.S. and reaching audiences outside the U.S., Canada, and Europe… must also pass the field but can choose to opt-in or opt-out"* of restrictions (`NONE` = opt-out). [V same] Whether Turkey counts as "Europe" is **[DOĞRULANMADI]** (leadsync assumes UK+EU: https://leadsync.me/blog/special-ad-category-meta/). [R] Turkey-only real-estate client: try `NONE`; if Meta flags/rejects, rebuild as `HOUSING`, country `TR`, broad/Advantage+ audience + CRM Conversion Leads. Discriminatory Practices standard applies regardless. TR help page: https://tr-tr.facebook.com/business/help/1198401317374558 [body unreadable]. Instant forms in these categories shouldn't collect age/gender/relationship fields. [H leadsync]
- Turkish law layer [DOĞRULANMADI if it covers paid social]: real-estate brokerage needs *Taşınmaz Ticareti Yetki Belgesi* (Ticaret İl Müdürlüğü; https://kocaeli.ticaret.gov.tr/yayinlar/ic-ticaret/tasinmaz-ticareti-yetki-belgesi) – confirm client holds it. Reklam Kurulu rules not researched.

**Common rejections** [H https://inspectad.com/guides/meta-ad-policy ← Meta Advertising Standards https://transparency.meta.com/policies/ad-standards/]: personal attributes ("Do you have…?", "Ready to look younger?"); negative self-perception (beauty/weight-loss); health clickbait/guaranteed results in a timeframe; cure claims; prohibited commercial practices (fake discounts, unauthorized endorsements, guaranteed returns); landing-page mismatch/prohibited content; restricted goods without conditions. Health/weight/cosmetic-procedure ads need 18+; cosmetic before/after allowed under conditions. Review ≤24 h typically, re-review possible after live, landing page is reviewed; appeal in Account Quality. Safe pattern: describe the product, never assert the viewer's condition.

**Account restrictions / avoiding bans** [snippets https://www.facebook.com/business/help/975570072950669 , /1256440956255650 – bodies unreadable; rest R]: Meta may limit spend, restrict payment methods (verification + temporary hold), restrict Page/Business Account or disable for policy breaches or "unusual/high-risk activity"; repeated rejections count. Practice: client-owned Business Portfolio with agency as partner (never mix clients in one account); 2FA for all admins; business verification when offered; stable advertiser-owned payment method (avoid failed payments/card swaps); ramp spend gradually on new accounts (new-account limits: exact values DOĞRULANMADI); domain verified + privacy policy + accurate Page identity; don't resubmit the same violation repeatedly.

**Turkey money/tax** (secondary; confirm with mali müşavir)
| Item | Rule | Source |
|---|---|---|
| KDV | genel oran **%20**. Meta TR page: Meta ads in Turkey subject to local KDV since 1 Apr 2019 – whether Meta charges it or the advertiser self-assesses (KDV-2) depends on the invoicing entity: **DOĞRULANMADI, read the invoice** | https://tr-tr.facebook.com/business/help/1020947424780313 (unreadable); https://verabilisim.com/sosyal-medya-reklam-faturasi-kdv |
| Foreign invoice | sorumlu sıfatıyla KDV (KDV-2, 2 No.lu beyanname) by advertiser | Vera |
| Stopaj (476 CB Kararı) | %15 on ad payments to non-resident platforms by payers listed in GVK 94/1 & KVK 15/1; %0 to Turkish full-taxpayer intermediaries (agency) | Vera; bossydigital |
| Dijital Hizmet Vergisi | **%5 in 2026, %2.5 from 1 Jan 2027** (CBK 10767, RG 25 Dec 2025); payer = platform, not shown on invoice | https://www.alomaliye.com/2025/12/25/dijital-hizmet-vergisi-orani-dusuruldu-2026-yilinda-yuzde-5-2027-yilinda-yuzde-2-5 ; Vera |
| **Meta location fee** | **5% on ads delivered to Türkiye from 1 Jul 2026** (UK 2%, FR/IT/ES 3%, AT 5%); on top of budget, separate invoice line after delivery, **absent from Ads Manager spend/reports**; VAT on spend+fee; applies to CTWA; by delivery location; Google charges 7% in TR | https://www.digitalapplied.com/blog/meta-europe-location-fees-july-2026-advertiser-guide (cites Meta https://www.facebook.com/business/help/1238737454289085, unreadable); https://bossydigital.com/turkiyede-meta-reklam-maliyetleri-neden-bu-kadar-artti/ |
Implications [R]: (1) client cap = Ads Manager spend × 1.05 (×1.20 KDV if applicable) – report **invoice-truth** spend (Billing & Payments; API `business_invoices`→`invoice_campaigns`→`billed_amount_details.additional_fee_association`); (2) automated rules under-count spend; (3) tighten CPA/ROAS targets ~5%; (4) with no company registered, the agency should **not** be the payer: advertiser pays Meta from its own ad account/card; agency fee billed separately (withholding on agency invoices = accountant's call, DOĞRULANMADI).
**Currency/payment:** TRY ad accounts possible; currency fixed at creation [DOĞRULANMADI]; accepted payment options https://www.facebook.com/business/help/212763688755026 and budget/spending-limit/threshold differences https://www.facebook.com/business/help/998181913623584 [bodies unreadable]. In the Agara panel amounts are in **kuruş**.

---
## 8. Benchmarks — Turkey (INDICATIVE ONLY)
- **BossyDigital managed e-commerce accounts, TL, spend-weighted, self-reported** [H https://bossydigital.com/turkiyede-meta-reklam-maliyetleri-neden-bu-kadar-artti/]:
| Period | Meta CPM | Link-click cost | Meta ROAS |
|---|---|---|---|
| Q4 2025 | 61.7 | 2.40 | 3.78 |
| Q1 2026 | 68.9 | 2.75 | 4.57 |
| Q2 2026 | 137.6 | 8.17 | 5.41 |
| Q3 2026 | **154.9** | **8.52** | 4.31 |
  Q3-2026 account CPMs ranged **63–586 TL** (9× spread). CPI 29.73% (Sep 2026). Plan on the last 3 months' CPM. Implied link CTR ≈ 154.9/(1000×8.52) ≈ 1.8% [derived].
- Feb-2025 agency claim (CPC 1–5 TL, CPM 15–60 TL, test 50–100 TL/day) is **stale**. [H https://ycfdigital.com/blog/instagram-reklam-ucretleri] Superads TR CPM/CPC pages are JS-rendered – numbers unreadable [DOĞRULANMADI] (https://www.superads.ai/facebook-ads-costs/cpm-cost-per-mille/turkey).
- **CPL by sector (construction/renovation, restaurants, beauty, real estate, auto): no reliable public TR data → DOĞRULANMADI.** Planning formula [R]: CPL ≈ CPM ÷ (1000 × link CTR × completion rate); e.g., 155 TL, 1.8%, 10–20% → ~45–85 TL (illustrative arithmetic, NOT observed). Build baselines per client from first 2–4 weeks. Add +5% location fee (+KDV) to every forecast.

---
## Appendix — agent notes (Agara panel + Meta Ads MCP)
- Meta MCP: `ads_get_ad_accounts` → `ads_get_ad_entities` (before trend/recommendation tools); create tools (`ads_create_campaign/ad_set/ad/creative`) create **PAUSED**; `ads_activate_entity` starts spend → explicit user confirmation; `ads_get_errors` for blockers; `ads_get_dataset_quality` for EMQ.
- Agara panel: `workspace_ads` → `ads_create_draft` → `ads_get_draft` (level:error blocks) → `ads_send_for_approval` → `ads_create_on_platform` (PAUSED) → `ads_publish_draft`; `set_campaign_budget/status` are real changes; never call without approval.
- Pre-flight: objective/conversion location; special-ad-category decision; Advantage+ placements/audience/campaign budget; pixel+CAPI with `event_id`; UTMs; ≥4 distinct creatives in 4:5 + 9:16 safe zone; budget ≈ 50 events/wk or single ad set; fee+KDV in client cap; welcome message/ice-breakers or form questions set.
