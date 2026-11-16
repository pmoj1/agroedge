# AgroEdge — Next.js MVP (V1 + Water & Energy AI)

Farm health, finances, water and electricity at a glance. This is the Next.js
rebuild of the Bubble V1 dashboard, plus the new AI resource-management layer.

## What's inside

**V1 (mirrors the Bubble screenshots)**
- Login / sign-up page (demo auth — any email + 6-character password)
- Dashboard: welcome, profile-setup banner, income/expense/net/activities stats,
  farm health score, my farm, yield snapshot, latest AI insight, cash flow, break-even
- Analytics: revenue vs expenses, monthly profit trend, P&L statement, yield trends,
  best-performing crops, expense/revenue trends, seasonal comparison, cost & yield
  per acre, farm health breakdown
- AI Assistant & Reminders: working chat, suggested prompts, reminders, in-app alerts
- Crop planning: per-crop AI suggestions (Cassava, Maize, Cocoa, Groundnut)
- AI Insights + Weekly farm report
- Farm profile, Activities, Expenses, Income, Reminders, Documents, Communication settings

**New: Water & Energy AI (`/resources`)**
- Best irrigation windows for today, scored by evaporation, tariff and grid risk
- Soil-moisture by block with stage-based targets
- 5-day weather outlook that auto-skips irrigation before heavy rain
- Pump & electricity schedule: off-peak / standard / peak tariffs, grid-risk window,
  diesel-backup warning, per-cycle cost and savings
- Weekly water (kL) and electricity (kWh) usage chart
- AI resource insights, also surfaced on the dashboard and Insights page

## Run it

```bash
npm install
npm run dev
```

Open http://localhost:3000 — you'll land on the login page.

## Live Claude AI (optional)

The assistant and resource insights work out of the box with a built-in
rule-based engine. To make the chat answer with Claude:

```bash
cp .env.example .env.local
# add your key:
ANTHROPIC_API_KEY=sk-ant-...
```

The API route (`app/api/assistant/route.js`) sends farm context to Claude and
falls back to the local engine if no key is set or the call fails.

## Production next steps

- Replace demo auth with Supabase Auth or NextAuth
- Replace `lib/data.js` mock data with PostgreSQL (Supabase) per the data model:
  Farmer, Farm, Activity, Expense, Income, AI Insight
- Feed `lib/resource-ai.js` with real weather (OpenWeather), soil-moisture sensors,
  and your local DisCo tariff bands
- SMS/WhatsApp alerts via Africa's Talking (V2 roadmap)
