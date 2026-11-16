# AgroEdge — Startup HQ

# Mission

> **We help small-scale African farmers manage farm operations and finances using AI, turning everyday farm data into practical decisions that improve productivity, profitability, and sustainability.**
> 

> 🌍 **Long-term vision:** To become the operating system for African agriculture.
> 

---

## The Team

| Name | Role | Focus Areas |
| --- | --- | --- |
| Jaydeane Huni | CEO / Product | Vision, user research, GTM, fundraising, partnerships |
| Aone Senai | CTO & AI Lead | Backend, AI models, data infrastructure, security |

## This Week's Focus

[This Week's Focus](AgroEdge%20%E2%80%94%20Startup%20HQ/This%20Week's%20Focus%201bcdc8622fe14d94a51da23d6db3a013.csv)

**Status key:** 🔲 To do · 🔄 In progress · ✅ Done · 🚫 Blocked

## Quick Links

- Product Roadmap
- Tasks & Sprints
- Build Log
- User Research
- Finance & Runway
- Go-to-Market
- Pitch & Fundraising
- Founder Brain Dump

---

# Product Roadmap

## MVP Scope (v1)

> **Goal:** Let a farmer log their activities, expenses, and income — and receive one AI insight per week about their farm performance.
> 

### Feature Tracker

[Feature Tracker](AgroEdge%20%E2%80%94%20Startup%20HQ/Feature%20Tracker%2004b4ea937a0a48f1b6582be609d6b920.csv)

**Priority key:** P0 = must have for MVP · P1 = next release · P2 = future

### Platform Modules & Build Status

> Investor framing: the farm-management core is **already built**; the pre-seed funds the AI + intelligence layer on top.
> 

| Module | Status | Funded by |
| --- | --- | --- |
| Farm profiles, income/expense, P&L, yield, analytics, reporting | ✅ Built (Bubble) | — |
| AI assistant foundation | ✅ Built (foundation) | — |
| AI Agronomist (diagnosis, recommendations, multilingual) | 🔲 This round | Pre-seed |
| Weather Intelligence (forecasts, planting windows, alerts) | 🔲 This round | Pre-seed |
| Government / NGO Dashboard | 🔲 This round | Pre-seed |
| Mobile App deployment | 🔲 This round | Pre-seed |
| SMS / WhatsApp alerts | 🔲 This round | Pre-seed |
| Disease Detection (computer vision) | ⏭️ Deferred | Pre-Series A |
| Satellite Monitoring (Sentinel + NDVI) | ⏭️ Deferred | Pre-Series A |

### Milestones

> **Sequence:** MVP built → Phase 0 validation pilot (10–30 farmers) → pilot review → $120k pre-seed raise → funded **1,000-farmer pilot** → scale to **10,000** (Year 2).
> 

| Milestone | Target Date | Description |
| --- | --- | --- |
| 🧱 MVP built |  | Core logging + one AI insight working |
| 🌱 Phase 0 validation pilot |  | 10–30 farmers, 4-week pilot (pre-raise) |
| 📊 Pilot review |  | Analyse data, gather feedback |
| 🚀 Funded pilot |  | 1,000 farmers (post-raise) → 10,000 in Year 2 |
| 💰 Pre-seed raise |  | $120k pre-seed (~12-month runway) |

---

# Tasks & Sprints

## Current Sprint

**Sprint dates:** 1 June – 14 June 2026

**Sprint goal:** Launch a working MVP foundation that allows farmer onboarding, activity logging, expense tracking, and AI insight generation.

## Task Board

[Task Board](AgroEdge%20%E2%80%94%20Startup%20HQ/Task%20Board%2031f86f7412ed41ec9fd2d47e2179e8f7.csv)

## Weekly Retro Log

| Week | What worked | What didn't | Next week's priority |
| --- | --- | --- | --- |
| Week 1 | Built full Bubble app from scratch (dashboard, activities, expenses, income, analytics, AI assistant, AI insights, crop planning, weekly report, reminders, cash flow, farm health score); successfully debugged the web app; Wix marketing site built; Notion realigned to Bubble + Wix stack | Encountered bugs during the build (analytics: net profit showing 0, yield per acre not computing, break-even unrounded, health score not binding in dashboard card); domain not yet connected; guided onboarding flow incomplete | Connect custom domain; fix remaining analytics bugs; finish guided onboarding; schedule first farmer interviews |
| Week 2 | Committed to Bubble + Wix; realigned the build plan and Notion |  |  |
| Week 3 |  |  |  |

---

# Build Log

## Tech Stack Decisions

| Layer | Choice | Why | Alternatives considered |
| --- | --- | --- | --- |
| App (UI + logic + backend) | Bubble | No-code; build, host, and run the whole farmer app in one platform — fastest path to MVP | Custom code (Next.js + FastAPI), FlutterFlow |
| Database | Bubble built-in database | Included with Bubble; data types + privacy rules, nothing separate to manage | Supabase, Postgres |
| Auth | Bubble user accounts | Native signup / login, no extra service | Supabase Auth, Auth0 |
| Hosting + file storage | Bubble (managed) | App and uploads hosted by Bubble; custom domain supported | Vercel, Railway |
| Marketing website | Wix | No-code public site at [agroedge.ai](http://agroedge.ai), separate from the app | Webflow, Framer |
| AI / Insights | Claude API (Anthropic), via Bubble API Connector | Best reasoning, easy to prompt for structured output | OpenAI GPT-4, Gemini |
| SMS / USSD | Africa's Talking API, via Bubble API Connector | Pan-African coverage, USSD support | Twilio (no USSD) |

## Data Model Overview

> Built in Bubble: every record automatically gets a unique id, Created Date, Modified Date, and Creator (so the manual id / created_at fields below aren't needed). Foreign keys become linked fields (a field whose type is another data type, e.g. Farmer), and Enum fields become Option Sets.
> 

### Farmers

| Field | Type | Notes |
| --- | --- | --- |
| id | UUID | Primary key |
| name | String |  |
| phone | String | Used for SMS |
| country | String |  |
| region | String |  |
| primary_crop | String |  |
| farm_size_acres | Float |  |
| created_at | Timestamp |  |

### Farm

| Field | Type | Notes |
| --- | --- | --- |
| id | UUID | Primary key |
| farmer_id | UUID | Foreign key → Farmers |
| farm_name | String |  |
| location | String | Region / village |
| size_acres | Float |  |
| primary_crop | String |  |
| soil_type | String | Optional |
| created_at | Timestamp |  |

### Activities

| Field | Type | Notes |
| --- | --- | --- |
| id | UUID |  |
| farmer_id | UUID | Foreign key |
| activity_type | Option Set | planting / watering / fertilising / harvesting / spraying |
| crop | String |  |
| date | Date |  |
| notes | Text |  |

### Expenses

| Field | Type | Notes |
| --- | --- | --- |
| id | UUID |  |
| farmer_id | UUID | Foreign key |
| category | Option Set | seeds / labour / tools / transport / fertiliser / other |
| amount | Float | In local currency |
| currency | String | KES, GHS, NGN etc |
| date | Date |  |
| notes | Text |  |

### Income

| Field | Type | Notes |
| --- | --- | --- |
| id | UUID |  |
| farmer_id | UUID | Foreign key |
| crop | String |  |
| quantity_kg | Float |  |
| price_per_kg | Float |  |
| total_amount | Float |  |
| buyer | String |  |
| date | Date |  |

### AI Insights

| Field | Type | Notes |
| --- | --- | --- |
| id | UUID |  |
| farmer_id | UUID | Foreign key |
| insight_type | Option Set | cost / yield / recommendation / alert |
| content | Text | The AI-generated message |
| generated_at | Timestamp |  |
| read | Boolean |  |

## Architecture Notes

> **AI insight generation flow (in Bubble):**
1. A Bubble recurring backend workflow runs weekly per active farmer
2. Pull last 30 days of activities, expenses, income
3. Compare against crop benchmarks (avg costs per region/crop)
4. Send a structured prompt to the Claude API via the API Connector
5. Save the response as a new AI Insight record
6. Deliver via dashboard + optional SMS through Africa's Talking
> 

## Bug Tracker

[Bug Tracker](AgroEdge%20%E2%80%94%20Startup%20HQ/Bug%20Tracker%209e85d99aa1664ff69b5a017a1c2f635a.csv)

---

# User Research

## Farmer Personas

> ⚠️ These are assumption-based personas — not yet validated by real farmer interviews. Treat as hypotheses to test and update once interviews are conducted.
> 

### Persona 1 — Amina, Kenya 🇰🇪

- **Age:** 34
- **Location:** Nakuru County, Kenya
- **Crops:** Maize (primary), beans (secondary)
- **Farm size:** 2 acres
- **Phone:** Basic Android smartphone, uses WhatsApp
- **Connectivity:** 2G/3G, unreliable internet
- **Income:** Sells at local market, occasional middlemen
- **Pain points:**
    - Doesn't know her exact profit per season
    - Buys too much fertiliser and wastes money
    - No way to compare her yield to neighbours
    - Can't remember what she spent last season
- **Quote:** *"I just want to know if I'm making money or losing it."*

### Persona 2 — Kwame, Ghana 🇬🇭

- **Age:** 45
- **Location:** Ashanti Region, Ghana
- **Crops:** Cocoa (primary)
- **Farm size:** 5 acres
- **Phone:** Feature phone (SMS only) + shared smartphone at home
- **Connectivity:** Very limited, mostly offline
- **Income:** Sells to licensed buying companies (LBCs)
- **Pain points:**
    - Relies on LBC prices with no negotiating power
    - Doesn't track costs so can't calculate margin
    - Disease detection is late — loses 20-30% of yield
    - Extension workers visit infrequently
- **Quote:** *"If I knew the price would drop, I would have harvested earlier."*

## Interview Question Bank

**Background**

1. Tell me about your farm — what do you grow, how big is it, where is it?
2. How long have you been farming?
3. Who else helps you on the farm?

**Current practices**

1. How do you track what you spend on the farm today? (notebook, phone, memory?) 
2. How do you track what you earn from selling your crops? 
3. At the end of a season, do you know if you made a profit?

**Pain points**

1. What is your biggest problem as a farmer right now? 
2. Have you ever made a decision that cost you money — what happened?
3. What information would help you make better decisions?

**Technology**

1. What phone do you use? How comfortable are you using apps?
2. Have you ever used an app or tool to help with your farm? What happened?
3. Would you prefer to receive information by SMS, WhatsApp, or app?

## Interview Log

> ⚠️ No farmer interviews conducted yet — these are planned, not yet done. Log each one here once completed.
> 

| # | Farmer name | Date | Country | Crop | Key insight | Recording/notes |
| --- | --- | --- | --- | --- | --- | --- |
| 1 |  |  |  |  |  |  |
| 2 |  |  |  |  |  |  |
| 3 |  |  |  |  |  |  |

## Key Pain Points Summary

| Pain point | How often mentioned | Our solution |
| --- | --- | --- |
| Don't know profit/loss |  | Expense + income tracker with AI summary |
| Overspend on inputs |  | Cost tracking + AI cost optimisation tip |
| Can't compare to others |  | Benchmark data in AI insights |
| No memory of past seasons |  | All data stored and searchable |
| Late disease detection |  | Activity logging + alert triggers |

---

# Finance & Runway

## Funding Status

[Funding Status](AgroEdge%20%E2%80%94%20Startup%20HQ/Funding%20Status%20d1f6aaa96bc24572b145a3cbc96411b6.csv)

## Monthly Burn Rate

| Category | Monthly Cost (USD) | Notes |
| --- | --- | --- |
| Bubble (app platform + hosting) | $0–32 | Free plan to build, Starter when pilot goes live |
| Wix (marketing website) | $0–17 | Free to start, Premium to connect domain |
| Claude API (Anthropic) | ~$20–100 | Scales with users |
| Africa's Talking SMS | ~$10–50 | Per SMS volume |
| Notion (Team) | $16 | This workspace |
| Domain + email | $5 |  |
| Travel (farmer visits) | $100–300 | Pilot fieldwork |
| SIM cards / data (pilot) | $20–50 | Testing in-country |
| **Total estimate** | **~$170–570/mo** | Early stage |

## Runway Calculator

| Monthly burn | Savings/funds | Runway |
| --- | --- | --- |
| $200/mo | $6,000 | 30 months |
| $400/mo | $6,000 | 15 months |
| $200/mo | $12,000 | 60 months |

> Update your actual numbers above to calculate your real runway.
> 

### Post-Raise Burn & Runway (funded period)

> Once the $120k closes, burn changes shape: one-time build / legal / pilot costs up front, then a steady monthly operating burn across the ~12-month runway. (The table above is the pre-raise bootstrap burn.)
> 

**One-time costs (paid from the raise):**

| Item | Cost (USD) |
| --- | --- |
| Build (agency) | $59,800 |
| Legal & company setup | $7,250 |
| Pilot launch | $10,000 |
| **Subtotal (one-time)** | **$77,050** |

**Monthly operating burn (funded period):**

| Category | Monthly (USD) |
| --- | --- |
| Founder stipends (both, $2,800/mo) | $2,800 |
| Tooling, API, hosting, SMS (Bubble, Wix, Claude, Africa's Talking, Notion, domain) | ~$200–570 |
| **Total monthly burn** | **~$3,000–3,400** |

**Runway:** ~$120,000 raise − ~$77,050 one-time = **~$42,950** for operating burn → **~12 months** (founder stipends $33,600 + buffer $9,350).

## Funding Pipeline

| Investor / Grant | Type | Focus | Stage | Status | Last contact |
| --- | --- | --- | --- | --- | --- |
|  | Angel |  |  |  |  |
|  | VC | Agri-tech |  |  |  |
|  | Grant | Africa agri |  |  |  |

**Relevant funds to research:** Novastar Ventures, DOB Equity, AgDevCo, Acumen, Google for Startups Africa, Tony Elumelu Foundation

## 💰 Pre-Seed Raise — $120,000 (Investor Strategy)

> **The ask:** Raising **$120,000** pre-seed for a **~12-month runway**. The farm-management core is already built in Bubble; this round funds the AI + intelligence layer, a lean founder stipend, and a paid pilot — then we raise a Pre-Series A once adoption is proven.
> 

**Positioning:** AgroEdge is the digital intelligence layer for climate-smart agriculture — complementing Zimbabwe's Pfumvudza and Botswana's Temo Letlotlo with AI agronomy, weather intelligence, programme monitoring, and productivity analytics.

### Use of Funds

| Use | Amount (USD) | % |
| --- | --- | --- |
| Build — lean (AI agronomist, weather, govt dashboard, mobile, SMS, security, infra) | $59,800 | 50% |
| Founder stipends ($2,800/mo × 12; ≈ A$4,000/mo at ~0.70) | $33,600 | 28% |
| Pilot launch (1,000 farmers) | $10,000 | 8% |
| Legal & company setup | $7,250 | 6% |
| Working capital / buffer | $9,350 | 8% |
| **Total** | **~$120,000** | **100%** |

### Build Budget — This Round (lean / deferred)

| Module | Cost (USD) |
| --- | --- |
| AI Agronomist (Claude/OpenAI integration, crop knowledge base, multilingual) | $12,000 |
| Mobile App deployment (wrapper around existing platform) | $12,000 |
| Government / NGO Dashboard | $10,000 |
| Security, testing & deployment | $7,000 |
| SMS & WhatsApp notifications | $5,000 |
| Weather Intelligence integration | $3,000 |
| Cloud infrastructure setup | $3,000 |
| Contingency (15%) | $7,800 |
| **This-round build total** | **~$59,800** |

### Deferred to Pre-Series A

> The two most complex modules — and where larger investors fund the *next* stage. Deferring them keeps the pre-seed lean and gives the Pre-Series A a clear build mandate.
> 
- Disease Detection (computer-vision crop diagnosis) — ~$18,000
- Satellite Monitoring (Sentinel + NDVI vegetation / water-stress) — ~$15,000

### Revenue Model — $10 / farmer / season

| Farmers | Revenue (USD) |
| --- | --- |
| 1,000 (pilot) | $10,000 |
| 10,000 (Year-2 target) | $100,000 |
| 100,000 | $1,000,000 |
| 1,000,000 | $10,000,000 |

### Operating Costs (once live, modelled at 10,000 farmers)

~**$28,000/year** — AI API, weather API, hosting, SMS/WhatsApp, maintenance. Pilot-scale opex at 1,000 farmers is a fraction of this.

### Pilot Framing

- **This round funds a 1,000-farmer pilot** — a realistic first deployment that runs at a planned loss against opex (expected at pilot stage).
- **10,000 farmers is the post-pilot / Year-2 target** — the point where revenue (~$100k) covers operating costs and the model turns profitable.

### Build vs. Buy

> The $59,800 build is costed as **outsourced agency work** (the AI/intelligence modules sit beyond the no-code core). Founders draw a lean stipend to run the company full-time — manage the build, land the government/NGO pilot, and run farmer validation — across the 12-month runway.
> 

---

# Go-to-Market

## Target Markets

**Pilot focus (priority):** Botswana · Mozambique · Zimbabwe

**Full rollout:** Zambia · Uganda · Tanzania · Malawi · Rwanda · South Africa

## Strategy

> **Phase 0 (pre-raise validation):** Run a scrappy 10–30 farmer validation pilot to prove core adoption and gather farmer feedback.
**Phase 1:** Raise $120k pre-seed and land a paid **1,000-farmer pilot** with a government or national programme (e.g. Botswana's Temo Letlotlo).
**Phase 2:** Use pilot outcomes and data to expand the contract, win adjacent national programmes, and raise Pre-Series A.
**Phase 3:** Scale to **10,000+ farmers** across government programmes in priority markets, with SMS/USSD reach to enrolled farmers.
> 

## Pilot Partner Tracker

[Pilot Partner Tracker](AgroEdge%20%E2%80%94%20Startup%20HQ/Pilot%20Partner%20Tracker%20a47f437b5ac4400896ca3412586d4fd3.csv)

**Status options:** 🔲 To contact · 📧 Contacted · 🤝 Meeting booked · 🔄 In negotiation · ✅ Signed · ❌ Not interested

## 90-Day Launch Plan (Phase 0 — pre-raise validation)

> The scrappy pre-raise validation sprint. The funded 1,000-farmer pilot follows the $120k raise (see Finance & Runway → Pre-Seed Raise).
> 

| Phase | Days | Focus | Key actions |
| --- | --- | --- | --- |
| Research | 1–30 | Talk to farmers + partners | 10 farmer interviews, 3 partner meetings, validate core features |
| Build | 31–60 | Ship MVP | Complete core logging features, AI insight engine, basic dashboard |
| Pilot | 61–90 | Onboard + learn | 10–30 farmers live (validation), weekly check-ins, collect feedback, measure retention |

## Key Metrics to Track (Phase 0 validation)

| Metric | Week 4 target | Week 8 target | Week 12 target |
| --- | --- | --- | --- |
| Farmers onboarded | 5 | 15 | 30 |
| Activities logged / farmer / week | 2 | 3 | 4 |
| AI insights generated | 5 | 30 | 120 |
| 30-day retention rate | 60% | 70% | 75% |
| NPS score | — | 30 | 40 |

---

# Pitch & Fundraising

## Pitch Deck Outline (10 slides)

1. **Cover** — AgroEdge · AI-powered farm management for African smallholders · Your names
2. **Problem** — Small-scale African farmers operate blind. No data, no decisions.
3. **Solution** — A simple tool to log farm activities, expenses, and income — with AI insights to guide better decisions.
4. **Product** — Screenshots / demo of the app
5. **Market** — 500M+ smallholder farmers in sub-Saharan Africa. $1T agriculture sector.
6. **Traction** — Pilot results, farmer quotes, retention data
7. **Business model** — B2G (sell to governments & national agricultural programmes that deploy to farmers) + donor/development-funded pilots
8. **Go-to-market** — Government & national-programme channel first (e.g. Temo Letlotlo), then expand across markets
9. **Team** — Your backgrounds, why you're the right people
10. **Ask** — Raising **$120k pre-seed** (~12-month runway) to add the AI + intelligence layer (AI agronomist, weather, government dashboard, mobile, SMS), pay a lean founder stipend, and run a **1,000-farmer paid pilot**. Unlocks: modules shipped · one government/NGO pilot signed · adoption data → Pre-Series A (disease detection + satellite).

## Investor Tracker

[Investor Tracker](AgroEdge%20%E2%80%94%20Startup%20HQ/Investor%20Tracker%201f79192e75614a50b4f2f946c5a41ec9.csv)

## Cold Outreach Email Template

**Subject:** AgroEdge — AI farm management for African smallholders (pre-seed)

Hi [Name],

I'm [Your name], co-founder of AgroEdge. We're building an AI-powered platform that helps small-scale African farmers track farm operations and finances — and receive weekly AI insights on cost optimisation and yield performance.

We're currently running a pilot with [X] farmers in [Country] and seeing [key metric].

Given [Fund]'s focus on [African agri / climate / fintech], I thought this might be worth a quick conversation.

Would you be open to a 20-minute call this month?

Best,

[Name]

[Phone] | [LinkedIn] | [agroedge.ai](http://agroedge.ai)

---

# Founder Brain Dump

## Ideas Parking Lot

> Drop ideas here without judgment. Review monthly and move the good ones to the roadmap.
> 
- [ ]  Seasonal crop calendar with planting reminders
- [ ]  Marketplace feature to connect farmers with buyers
- [ ]  Group/cooperative view for NGO partners
- [ ]  Offline-first PWA with background sync
- [ ]  Voice input for low-literacy farmers
- [ ]  Photo logging for crop health tracking

## Key Decisions Log

| Decision | Date | Rationale | Made by | Revisit? |
| --- | --- | --- | --- | --- |
| Build on Bubble (no-code) instead of custom code |  | Founders can build and ship the MVP directly; backend, DB, and hosting included | Both | After pilot |
| Use Wix for the marketing website |  | Fast no-code public site, separate from the app | Both | No |
| B2G go-to-market (pivoted from B2B2F) |  | Sell directly to governments / national agricultural programmes; one contract reaches farmers at national scale | Both | 6 months |
| Build mobile-responsive web app in Bubble first |  | Faster, no app store friction | Both | After pilot |

## Weekly Reflection Template

> Copy this block at the start of each week.
> 

**Week of:** ___

**What did we ship?**

- 

**What did we learn from users?**

- 

**What's our biggest blocker right now?**

- 

**One thing we'll do differently next week:**

- 

**Energy level this week (1–10):** ___

**Confidence in direction (1–10):** ___

[[Tasks & Sprints|Tasks & Sprints]]

[[Product Roadmap|Product Roadmap]]

[[Build Log|Build Log]]

[[Go-to-Market|Go-to-Market]]

[[Pitch & Fundraising|Pitch & Fundraising]]

[[Finance & Runway|Finance & Runway]]

[[Founder Brain Dump|Founder Brain Dump]]

[[User Research|User Research]]

[[Buyer × Feature Matrix — Who Pays for What (First|Buyer × Feature Matrix — Who Pays for What (First Customer Pick)]]

[[B2G Country Read — Zimbabwe · Botswana · Mozambiqu|B2G Country Read — Zimbabwe · Botswana · Mozambique]]

[[Concept Note — Botswana Ministry of Agriculture (T|Concept Note — Botswana Ministry of Agriculture (Temo Letlotlo)]]

[[Concept Note — Zimbabwe MLAFWRD (Pfumvudza Intwasa|Concept Note — Zimbabwe MLAFWRD (Pfumvudza/Intwasa + IDEA)]]

[🎯 Investor Pitch — [Date] (Mission Control)](AgroEdge%20%E2%80%94%20Startup%20HQ/%F0%9F%8E%AF%20Investor%20Pitch%20%E2%80%94%20%5BDate%5D%20(Mission%20Control)%2037c7b7d936b68155a17bed2476d2c393.md)

[[🎤 Investor Pitch — Prep Hub|🎤 Investor Pitch — Prep Hub]]