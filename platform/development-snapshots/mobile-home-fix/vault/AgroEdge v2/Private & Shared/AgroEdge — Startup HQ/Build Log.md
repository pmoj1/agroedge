# Build Log

## Tech Stack Decisions

| Layer | Choice | Why |
| --- | --- | --- |
| App (UI + logic + backend) | Bubble | No-code; build, host, and run the whole farmer app in one platform — fastest path to MVP |
| Database | Bubble built-in database | Comes with Bubble; define data types + privacy rules, nothing separate to manage |
| Auth | Bubble user accounts | Native signup / login, no extra auth service |
| Hosting + file storage | Bubble (managed) | App and uploads hosted by Bubble; custom domain supported |
| Marketing website | Wix | No-code public site at [agroedge.ai](http://agroedge.ai), separate from the app |
| AI / Insights | Claude API (via Bubble API Connector) | Strong reasoning and structured outputs |
| SMS / USSD | Africa's Talking API (via Bubble API Connector) | Pan-African coverage and USSD support |

## Data Model Overview (Bubble data types)

> In Bubble, every record automatically gets a unique id, Created Date, Modified Date, and Creator — so you don't add those manually. A link between types (e.g. Activity → Farmer) is a field of that type, not a foreign key. "Enum" fields become Option Sets.
> 

### Farmer

- `name` (text), `phone` (text), `country` (text), `region` (text), `primary_crop` (text), `farm_size_acres` (number)

### Activity

- `Farmer` (Farmer), `activity_type` (Option Set: planting / watering / fertilising / harvesting / spraying), `crop` (text), `date` (date), `notes` (text)

### Expense

- `Farmer` (Farmer), `category` (Option Set: seeds / labour / tools / transport / fertiliser / other), `amount` (number), `currency` (text), `date` (date), `notes` (text)

### Income

- `Farmer` (Farmer), `crop` (text), `quantity_kg` (number), `price_per_kg` (number), `total_amount` (number), `buyer` (text), `date` (date)

### AI Insight

- `Farmer` (Farmer), `insight_type` (Option Set: cost / yield / recommendation / alert), `content` (text), `read` (yes / no)

## Architecture Notes

> **AI insight generation flow (in Bubble):**
1. A Bubble recurring backend workflow runs weekly per active farmer
2. Pull the last 30 days of activities, expenses, and income
3. Compare against crop benchmarks
4. Send a structured prompt to the Claude API via the API Connector
5. Save the response as a new AI Insight record
6. Deliver via the farmer's dashboard + optional SMS through Africa's Talking
> 

## Progress Log

### 5 June 2026

- Locked in the build approach: **Bubble** for the farmer app, **Wix** for the marketing website ([agroedge.ai](http://agroedge.ai)).
- Realigned the whole workspace to match: tech stack, data model (now Bubble data types + Option Sets), AI insight flow (Bubble recurring backend workflow + API Connector), burn rate, key decisions, and sprint tasks.
- Confirmed Claude API and Africa's Talking stay in the plan — now called from Bubble via the API Connector.

### Build status — 5 June 2026

**Bubble app (AgriAI) — core MVP is live in preview:**

- Dashboard (income, expenses, net, activities logged, farm health score, yield snapshot, latest AI insight)
- Farm profile, Activities (22 logged), Expenses, Income
- Analytics: revenue vs expenses, monthly profit trend, P&L statement, yield trends, expense/revenue trends, seasonal comparison, cost per acre
- Cash flow + break-even summary
- AI Assistant chat, AI Insights (cost / revenue / productivity / alerts), Crop planning suggestions, Weekly farm report
- Reminders + in-app alerts; Documents and Communication settings pages stubbed in nav

**Wix marketing site:** built — custom domain not yet connected.

**Also done:** debugging pass on the web app.

**Next up:** connect domain, finish guided onboarding, fix the analytics calc bugs (see Bug Tracker), then weather + smart intervention suggestions.

### Open items & decisions — 5 June 2026

- **Naming:** decide between **AgriAI** (current in-app name) and **AgroEdge** (company / Notion name), then reconcile across the app, Wix site, and domain before going live.
- **Roadmap additions logged:** weather integration, water & electricity intervention alerts, and smart crop-specific suggestions are now in the Feature Tracker (v2 / v3) and the ideas list.
- **Farmer interviews:** none conducted yet — planned, not started. Interview log cleared so it no longer implies any have happened.