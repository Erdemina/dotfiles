# Google Ads + Cross-Channel + Turkey Legal — Reference (as of 2026-11-06)

Scope: Agara Ajans (Erdem), Turkish SMB clients (construction/renovation, restaurants, beauty, real estate, auto, e-com). Tags: **[G]** primary doc read this session; **[S]** secondary (law firm/vendor) — verify; **[P]** practitioner convention, unsourced; **[DOĞRULANMADI]** unverified. Not legal advice.

## 0. 2026 changes (read first)
| Date | Change | Src |
|---|---|---|
| Jun 2026 | Labels renamed: "Max conversions w/ Target CPA" → **Target CPA**; "Max conv. value w/ Target ROAS" → **Target ROAS** (behavior unchanged) | [G] https://support.google.com/google-ads/answer/7065882 |
| Jun 15 2026 | Offline conversion import + enhanced-conversions-for-leads uploads **moved to Data Manager API; blocked in Google Ads API** | [G] https://support.google.com/google-ads/answer/13321563 |
| ~Jun 2026 | Enhanced conversions web+leads merged into one toggle; tag/Data Manager/API can feed together | [S] https://www.relevantaudience.com/google-ads-en/google-ads-enhanced-conversions-2026-update/ ; [G] https://support.google.com/google-ads/answer/9888656 |
| Jun 2026→ | Display campaigns migrating into **Demand Gen**; new Display creation to be blocked later | [G] https://support.google.com/google-ads/answer/13695777 |
| Aug 17 2026 | Budget-limited tCPA/tROAS campaigns (Search, Shopping, PMax, Demand Gen) now deliver **closer to the stated target**; over-performers drift to target; Google won't auto-adjust targets → reset targets to recent actuals or raise budget | [G] https://support.google.com/google-ads/answer/17061251 |
| ~Nov 2026 | PMax troubleshooting page: stable performance needs **≥15 conversions/30 days** (unit unspecified, no penalty stated) | [S] https://www.relevantaudience.com/google-ads-en/google-performance-max-15-conversions-30-days ; https://support.google.com/google-ads/answer/12200334 |
| Feb 2026 / Feb 2027 | Call-only ads: creation removed / existing stop serving. Use RSA + **call assets** | [G] https://support.google.com/google-ads/answer/16619010 |
| 1 Aug 2026 | TR Ticari Reklam Yönetmeliği amendment (RG 1 Jul 2026 no. 33297): influencer labeling, AI disclosure, targeted-ad/child rules (§5.3) | [S] https://www.cbhukuk.com/influencer-reklam-kurallari |

## 1. Google Ads

### 1.1 Campaign chooser
| Situation | Use |
|---|---|
| Demand exists in search (tadilat, diş, ikinci el araç, emlak) | **Search** (RSA, Smart Bidding). Exact-match Search keyword outranks PMax on identical query; phrase/broad share priority with PMax search themes [G] https://support.google.com/google-ads/answer/7478529 |
| ≥15 conv/30d, assets/feed available, e-com | **PMax** + Search for brand/exact. Controls: brand exclusions, negative keywords, search themes, final-URL expansion, channel prioritization [G] https://support.google.com/google-ads/answer/10724817 |
| Create demand (restaurants, beauty, new projects) | **Demand Gen** (YouTube/Shorts, Discover, Gmail, GDN); budget ≥ **10× tCPA** (Google); lookalikes, creative A/B [G] 13695777 |
| Local walk-in/call | Search + **location asset (GBP-linked) + call asset**; PMax store goals. Local Services Ads in TR **[DOĞRULANMADI]** |
| <15 conv/30d, small budget | Search only, Maximize Conversions without target; never force PMax/tROAS |

### 1.2 Search
**Match types** [G] 7478529: *Broad* (default) = related searches, uses recent activity, landing-page content, other keywords; Google says pair with Smart Bidding. *Phrase* `"kw"` = includes the keyword's meaning. *Exact* `[kw]` = same meaning/intent. Broader types include narrower ones; near-duplicates share one bid. Rule [P]: ≥30 conv/mo → broad + Smart Bidding + mature negatives; <30 → phrase/exact. Review Search terms weekly for first 6 weeks.

**Negatives**: exclude searches containing the term; negatives don't auto-expand to synonyms/variants (add plurals, diacritic variants yourself) [G] https://support.google.com/google-ads/answer/2453972 (not re-read). Starter list [P]: ücretsiz, bedava, iş ilanı, maaş, nedir, pdf, ikinci el (adapt per client). PMax supports campaign negatives + brand exclusions.

**RSA rules** [G] https://support.google.com/google-ads/answer/7684791
- Headlines min 3 / max **15**, **30 chars**; descriptions min 2 / max **4**, **90 chars**; 2 path fields × 15 chars. Turkish letters count 1.
- Any order/combination → each asset must stand alone. ≥1 keyword in a headline.
- Pinning: only H1/H2/D1 pins guarantee display; pin 2–3 variants per slot (one pin kills testing); mandatory legal text → pin to H1/H2/D1.
- Google tip: ≥2 RSAs/ad group at "Good/Excellent" Ad Strength, unique final URL each; Poor→Excellent ≈ +15% clicks/conv (Google internal, Aug 2025). Editing/removing assets changes serving.

### 1.3 Smart Bidding thresholds
| Strategy | Stated threshold | Src |
|---|---|---|
| All Smart Bidding | Judge over periods with **≥30 conversions** (≥50 for tROAS); can start without history | [G] 7065882 |
| tCPA | Judge on last 30 d incl. ≥30 conv; default target = 30-d avg CPA adj. for delay; avoid bid limits; day spend may reach **2× daily budget**, month ≤ 30.4× daily | [G] https://support.google.com/google-ads/answer/6268632 |
| tROAS Search/Shopping | **≥15 conv in 30 d**, with value | [G] https://support.google.com/google-ads/answer/6268637 |
| tROAS Demand Gen | ≥50 conv/35 d (10 in last 7) per campaign, or ≥100/35 d across Demand Gen | same |
| tROAS Display / Video action | ≥15 valued conv/30 d (account) / ≥30 conv/30 d | same |
| Demand Gen tCPA | budget ≥10× tCPA | [G] 13695777 |
- Budget to reach a threshold ≈ threshold × CPA (CPA 600 → 15 conv = 9,000 TL/mo; 30 conv = 18,000) [P arithmetic].
- After target/budget/strategy changes wait **1–2 conversion cycles** [G 17061251]; use "Save as experiment".
- Judge with "(by conv. time)" columns; last 7–14 days lag with long lead→sale delay.
- "Include in Conversions" decides what is optimized — don't promote cheap micro-actions just to hit a threshold.

### 1.4 Conversion tracking (build order)
1. **Auto-tagging ON**; capture GCLID/GBRAID/WBRAID into hidden form fields → CRM.
2. Google tag/GTM actions: form submit (thank-you URL/event), call from ad, call from site (dynamic number), WhatsApp click (secondary), **imported qualified lead / won sale** (primary when volume allows).
3. **Enhanced conversions**: Goals → Settings → Customer data use → accept Customer Data Terms **per account** (not only MCC) [S]; SHA-256 hashed email/phone/address matched to signed-in Google accounts [G 9888656]. Verify fields actually populate.
4. **Offline import** [G] 13321563: action source "Import from clicks"; GCLID valid **90 d**; click ≥**6 h** old; conversion time not before click; phone **E.164**; email lowercase/trimmed; don't hash country/zip. Processing <12 h (≤72 h for GBRAID/WBRAID); count "One" discards repeats. "Unknown click" under EC-for-leads is expected. Upload ≥weekly, at qualified-lead stage and won-sale; use Data Manager API.
5. **WhatsApp-first funnels**: GCLID can't enter WhatsApp chat → track click as secondary; agent logs phone in CRM; upload via EC-for-leads (match rate **[DOĞRULANMADI]**).
6. QA: Goals → Conversions → Diagnostics; drops in tag fires degrade bidding [S].

### 1.5 Consent Mode v2 — EEA vs Turkey
- Google EU User Consent Policy covers users in **EEA, UK, Switzerland** [G] https://www.google.com/about/company/user-consent-policy-help/. Required signals: `ad_storage`, `analytics_storage` + v2 **`ad_user_data`**, **`ad_personalization`** [G] https://support.google.com/google-ads/answer/13695607. Blocking Google tags until interaction prevents Google verifying consent → data loss.
- **Turkey is outside that scope** → Google doesn't mandate v2 for TR-only traffic [inference]. But **KVKK requires opt-in for ad/analytics cookies** (§5.1): CMP on every client site, tags blocked/denied-by-default until consent, consent state passed to Google tags. Implement v2 fully for EU-diaspora targeting. Whether modeled conversions for non-consenting TR users are KVKK-acceptable: **[DOĞRULANMADI]**.

### 1.6 Google Business Profile (local SMBs)
[G] https://support.google.com/business/answer/3038177 (verification https://support.google.com/business/answer/7107242 — method set by Google; review replies need verification https://support.google.com/business/answer/3474050):
- Name = real-world signage name; **no** keywords/taglines/hours/phone/service/location text. One profile per location; fewest categories.
- Real staffed address; no PO box/virtual office/unstaffed coworking. **Service-area businesses** (renovation, plumbing): one profile, hide address, area ≈ ≤2 h drive.
- Individual practitioners (doctors, **real-estate agents**) allowed if public-facing at verified location; corporate sales/lead-gen agents aren't eligible. Restaurants: dine-in hours; appointment-only: no hours.
- Ops [P]: full categories/services, 10+ real photos (before/after, menu), weekly posts, reply to all reviews ≤48 h, never gate/buy reviews, UTM on website link, link to Ads (location + call assets), report calls/direction requests.

### 1.7 TR money flows [S]
Per https://yeezypay.io/blog/google-ads-turkey-2026-digital-tax (verify vs https://support.google.com/google-ads/answer/9750227 + mali müşavir): Google surcharge **4.5% (2026)**, 2.5% from 2027, on top of budget; **15% withholding** if invoiced by non-resident Google Ireland (~+18% of invoice grossed-up; none if Google Reklamcılık ve Pazarlama Ltd. Şti.); 20% KDV reverse charge (recoverable if VAT-registered). 100 media → ~104.5 invoiced → ≈122.9 cash (Ireland). A conflicting secondary source cites DST 7.5% → all rates **[DOĞRULANMADI]**. No registered company yet → clients pay Google under own entity; agency fee separate; confirm invoicing entity per client.

## 2. Funnel and strategy
| Stage | Channels | KPI | Offer |
|---|---|---|---|
| TOFU | Meta Reels, TikTok, YouTube/Shorts, Demand Gen | CPM, 3-s view rate, CTR, reach | Proof content, before/after, price transparency |
| MOFU | Generic Search, 7–30 d retargeting, lead forms | CTR, CPC, CPL, qualified-lead rate | Free keşif/ölçü, teklif, menü/rezervasyon, deneme |
| BOFU | Brand/high-intent Search, GBP, retargeting | CVR, CPA, ROAS, cost/qualified lead | Real time-boxed offer, garanti, easy contact |

**Offer** [P]: one promise + one risk-reverser + one *true* limit (fake scarcity is fined, §5.3); name the next step ("2 saat içinde WhatsApp'tan dönüş").
**Landing page** [P]: one goal; message match with ad; CTA above fold on mobile (tap-to-call, WhatsApp, short form: ad, telefon, ihtiyaç); real reviews/projects/belgeler; price or "from" price; company identity; KVKK aydınlatma link + **separate unticked** commercial-message checkbox (§5.2); thank-you URL for the tag.
**Speed**: Core Web Vitals good = LCP ≤2.5 s, INP ≤200 ms, CLS ≤0.1 (75th pct) [G, https://web.dev/articles/vitals, from knowledge, not re-read]. WebP images, no sliders, defer chat widgets.
**Follow-up**: MIT/InsideSales study [S; 2007 US B2B, directional]: odds of contacting drop >10× and of qualifying ~6× within the first hour; 5-min vs 30-min response ≈ 100× contact / 21× qualification https://dzamukov.com/research/mit-lead-response-study.pdf. SLA [P]: first human reply ≤5 min in business hours, ≤30 min otherwise; 3+ attempts over 2 days; CRM statuses (new/reached/qualified/quote/won/lost+reason) double as OCI upload events.

## 3. KPIs and formulas
| Metric | Formula |
|---|---|
| CPM | spend/impr × 1000 |
| CTR | clicks/impr |
| CPC | spend/clicks = CPM/(1000×CTR) |
| CVR | leads/clicks |
| CPL | spend/leads = CPC/CVR |
| Close rate r | sales/leads (state whether per lead or per qualified lead) |
| CPA (per sale) | spend/sales = CPL/r |
| CAC | all acquisition cost/new customers — report media-only and fully-loaded |
| ROAS | attributed revenue/spend |
| GM% | (revenue − variable costs)/revenue (include returns, commission, shipping, surcharge/tax overhead) |
| **Break-even ROAS** | **1/GM** (40% → 2.5; 25% → 4.0) |
| Break-even CPA | AOV × GM (e-com) / gross profit per customer (services) |
| LTV (gross-profit) | AOV × orders/yr × years × GM; one-off services ≈ first-job GP + referral value |
| LTV:CAC | ≥3 healthy [P heuristic] |
| MER | total revenue/total marketing spend (attribution-proof) |
| tCPA start | last-30-d actual CPA; tROAS start = break-even ROAS × 1.2–1.5 when scaling [P] |

### Budget from sales goal and CPL
Inputs: sales goal **S**, lead→sale rate **r**, gross profit/sale **GP**, max CAC share **k** (services 20–35% [P]).
1. Leads **L = S/r**. 2. Max CAC = k×GP; **max CPL = max CAC × r** (check L×maxCPL = S×maxCAC). 3. Media **M = L × target CPL** (+15–20% test reserve). 4. Cash = M × overhead (§1.7: ~1.045 Google Turkey; ~1.23 Ireland). 5. Daily = M/30.4; sanity-check §1.3 (M ≥15×CPA for PMax; ≥30×CPA to judge tCPA; Demand Gen daily ≥10×tCPA). 6. Split [P]: Search 60–70% / Meta + Demand Gen 20–30% / tests 10%.
Example (renovation, illustrative): S=8, r=12%, GP=40,000, k=20% → max CAC 8,000; max CPL 960; L≈67; M≈64,000 TL; cash ≈78,700 (Ireland). Real CPL 1,400 ⇒ ~46 leads/5.5 jobs unless r or CPL improves. Never budget from "what client wants to spend".

## 4. Client reporting
SMB owners ask: how many messages/calls/bookings, how many became sales, what did I spend vs earn, what next. Impressions/QS stay internal.
Monthly report (1–2 pages) [P]:
1. Headline box: spend, leads, CPL, qualified leads, sales/revenue (client CRM), ROAS or cost/sale — vs target and last month.
2. Goals scorecard vs agreed monthly KPIs.
3. Funnel: impressions→clicks→leads→qualified→quotes→sales; name biggest leak.
4. Channel/campaign table: spend, leads, CPL; top/bottom performer.
5. Lead quality: lost reasons, call samples, median minutes-to-first-contact (client speed is often the bottleneck).
6. Done (3–5 bullets) + test results. 7. Next month: 2–3 actions, decisions needed, budget recommendation with expected leads. 8. Health: tracking, consent banner, GBP rating/review count, open KVKK/İYS items.
Rules: outcomes first; TL not only %; distinguish platform-reported vs CRM-confirmed; flag conversion lag; deliver by working day 5; 15-min monthly call; weekly 5-line WhatsApp update.

## 5. Turkey legal (flag for avukat)

### 5.1 KVKK (6698)
- **Çerez Uygulamaları Hakkında Rehber** [G] https://www.kvkk.gov.tr/SharedFolderServer/CMSFiles/fb193dbb-b159-4221-8a7b-3addc083d33f.pdf: strictly necessary cookies need no açık rıza; **ad/marketing cookies rest on açık rıza** (Meta Pixel, Google Ads/remarketing, TikTok pixel). Consent = opt-in by affirmative act: no pre-ticked boxes, no "by using this site you accept", cookie walls generally invalidate consent. Equal-prominence "Kabul et / Reddet / Tercihler" buttons are the guide's *good-practice* example; its sample banners without equal reject are flagged non-compliant. Banner states purposes + 1st/3rd parties and links aydınlatma (m.10). Don't fire third-party scripts pre-consent.
- Vendor claims "reject button mandatory", "fine up to 1,000,000 TL" [S] https://cerez.io/en/blog/kvkk-cerez-rehberi-2026 → **[DOĞRULANMADI]**; fine caps revalued yearly — check kvkk.gov.tr.
- **Cross-border** (m.9, regime since 1 Jun 2024): adequacy decision (none issued yet) → safeguards (standard contract + notification, BCR…) → incidental exceptions (explicit consent only for non-regular transfers) [G] https://www.kvkk.gov.tr/Icerik/2053/Yurtdisina-Aktarim. Lawfulness of routine pixel transfers to Meta/Google/TikTok: **[DOĞRULANMADI] — legal review**. Stance: açık rıza + disclose transfer abroad; no sensitive data (health for clinics/beauty) into ad platforms.
- Lead forms: aydınlatma at collection (controller, purposes, recipients incl. Google/Meta, retention, rights); marketing consent separate from inquiry handling. Hashed email/phone for EC/CAPI/Customer Match is still personal data → cover in aydınlatma + consent. Agency = veri işleyen; get written processing terms from each client. VERBİS thresholds **[DOĞRULANMADI]**. Call recordings need notice.

### 5.2 ETK (6563) / İYS
- Commercial electronic messages (SMS, e-mail, automated/call-center calls, "benzeri vasıtalar") to consumers need **prior opt-in**; to tacir/esnaf no prior consent but İYS registration/opt-out apply [S] https://www.gunespartners.com/makale/iys-nedir ; law https://iys.org.tr/iys/kanun ; regulation https://iys.org.tr/iys/yonetmelik.
- Service providers sending commercial messages must register at iys.org.tr (MERSİS + e-signature per [S]); since **31 Mar 2025** consents/rejections only via official **İYS integrators** [S]. Sole operator without company registering: **[DOĞRULANMADI]**. The client (not agency) is the hizmet sağlayıcı and owns the İYS account.
- Mechanics [S]: record outside-İYS consents within **3 business days**; honor opt-out within **3 business days**; separate explicit checkbox naming channels and brand; check İYS before every send; records retained "10 years" per [S] **[DOĞRULANMADI]**. Consumer complaint within 3 months at tiss.ticaret.gov.tr.
- 2026 fines (approx., +25.49%) [S]: unauthorized message ≤~14,300 TL; bulk ×10; ignoring opt-out ≤~42,900; repeat in 1 yr doubles. Verify in Resmi Gazete.
- Transactional notices (delivery, appointment confirmation) outside consent scope [S]; any promo content makes them commercial.
- **WhatsApp**: business-initiated promo messages treated as commercial electronic messages → need İYS consent (explicit statutory enumeration **[DOĞRULANMADI]**). Replying in a customer-initiated chat is not a campaign; don't add to broadcast lists without separate opt-in.
- A lead-form phone number ≠ marketing consent. Unticked checkbox "Ticari elektronik ileti (SMS/arama/e-posta/WhatsApp) almayı onaylıyorum"; log timestamp, text version, source URL.

### 5.3 Reklam Kurulu / Ticari Reklam ve Haksız Ticari Uygulamalar Yönetmeliği (6502 m.61–63, 77)
- Advertiser must **prove every factual claim** (6502 m.61/6); hidden ads and misleading/unfair practices banned. Decisions: https://ticaret.gov.tr/tuketici/ticari-reklamlar/reklam-kurulu-kararlari.
- **2026 fine caps** [S citing tebliğ RG 33116, 23 Dec 2025]: internet/satellite TV ≤**10,837,065 TL**; national TV 39,916,524; billboard/other 1,083,706; plus stoppage/correction. Example 1 Nov 2026: 1,083,706 TL + stop for "14 günün en düşük fiyatı"/"sepette %80 indirim" with permanent discounts [G-news] https://www.dha.com.tr/gundem/yaniltici-indirim-reklamina-1-milyon-83-bin-tl-ceza-2973512.
- **Price/discount** — Kılavuz (Kurul 341, 9 Jan 2024) [G] https://tuketici.ticaret.gov.tr/data/65a6387813b876fb4cb78471/F%C4%B0YAT%20B%C4%B0LG%C4%B0S%C4%B0%20%C4%B0%C3%87EREN%20REKLAMLAR%20%C4%B0LE%20%C4%B0ND%C4%B0R%C4%B0ML%C4%B0%20SATI%C5%9E%20REKLAMLARI%20VE%20T%C4%B0CAR%C4%B0%20UYGULAMALARI%20HAKKINDA%20KILAVUZ16012024.pdf : "before" price = **lowest price applied in the 30 days before the discount** (perishables: previous price); recommended price can't pose as reference; state validity period/stock limit if any; fake urgency ("son 3 oda") banned; no "bedava/ücretsiz" if consumer pays beyond reasonable delivery; delivery fees shown with price; no pre-selected paid add-ons; personalized prices shown beside current list price; blanket "%20 indirim" ads need per-product prior price on product pages.
- **Comparative/superlative** (Yönetmelik m.8–9) [S] https://gun.av.tr/tr/goruslerimiz/guncel-yazilar/gercekten-daha-iyi-mi : allowed only if non-misleading, objective, verifiable, comparable goods; claims proven by **universities / accredited or independent test-research bodies**, covering the *whole* relevant market, valid at publication. "En ucuz / 1 numara / en iyi / en çok tercih edilen / tek / ilk" = superlative needing proof (Kurul rejected "Türkiye'nin 1 numarası" backed by a 21,600-person survey of narrower scope). Copy rule [P]: use documentable facts ("12 yıllık deneyim", "1.200+ tamamlanan proje"); never unproven "en ucuz/en iyi/garantili sonuç". Health/beauty claims (kesin sonuç, ağrısız, before/after) are high-risk [S] https://omerb.co/rehber/reklam-kurulu-cezalari.
- **Influencer/creator ads, in force 1 Aug 2026** (m.23/A) [S] https://www.cbhukuk.com/influencer-reklam-kurallari ; verify at https://mevzuat.gov.tr:
  - Any content tied to a **benefit** (cash, free/discounted product, commission/affiliate, discount code, trip, event invite, giveaway) is advertising, any follower count; platform "paid partnership" tag alone insufficient.
  - Must show **"Reklam" or "Tanıtım"** *plus* advertiser identity: brand/trade name, or "@marka tarafından sağlandı", "Ürünleri bana gönderdiği için @marka'ya teşekkürler", "@marka'ya teşekkürler". **#işbirliği / #sponsorlu / #ortaklık / #hediye alone no longer enough.**
  - Visible at first glance (no scroll/"devamını oku"), **before** hashtags, legible, not under UI; **every frame** of multi-frame stories; re-label reposts/story-shares; podcasts: spoken at start and before ad segment.
  - AI people/voices/virtual influencers must be disclosed (m.18/8); cloning a real person to fake experience/endorsement **banned** (m.27/12).
  - **m.25/A**: profiling-based targeted ads must disclose criteria and how to change them; **no profiling-based targeting where consumer is known/expected to be a child** → exclude <18 for such campaigns.
  - Agency checklist [P]: brief + contract clause with exact label text; keep proof of benefit; approve label pre-post; fix live non-compliant posts (good faith affects amount only). Owner/staff personal accounts promoting own business need disclosure [S].
  - Sector rules (alcohol, tobacco, medicines/health, real estate, auto financing/faiz disclosure) **[DOĞRULANMADI] — research per vertical before launch**.

## 6. TikTok Ads basics (later) [G] https://ads.tiktok.com/resources/help/article/budget?lang=en (Jul 2026)
- Campaign → ad group (bids) → ad; budget at ad-group or campaign level; Daily or Lifetime (no switching once live).
- **Minimums (USD)**: daily — campaign >$50, ad group >$20; lifetime — campaign >$50, ad group = days × $20 (31 d ⇒ $620). Campaign budget ≥ ad-group budget. TRY equivalents **[DOĞRULANMADI]**.
- Scaling: ≤**40%** per change in learning, ≤**30%** after; ≥2 days apart. Start with daily.
- Creative [P]: 9:16, hook ≤2 s, UGC style, captions; Spark Ads for creator posts (details **[DOĞRULANMADI]**). TikTok Pixel/Events API only behind KVKK consent; §5.2–5.3 apply. Fits restaurants, beauty, e-com; weak for high-ticket renovation/real estate except awareness.

## 7. Open items
1. 2026 KVKK fine caps, VERBİS thresholds, pixel-transfer legality.
2. İYS eligibility for non-company operator, retention period, WhatsApp scope.
3. Google invoicing entity per client; current surcharge/withholding.
4. Local Services Ads / store-goals availability in TR.
5. TR vertical CPC/CPL benchmarks — none sourced; build from first 90 days.
6. Sector-specific ad rules (health, real estate, auto finance, alcohol).
