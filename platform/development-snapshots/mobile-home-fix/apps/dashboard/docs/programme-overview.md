# Screen Spec: Programme Overview

**Lane:** `apps/dashboard` (Jaydeane)
**Reads:** root `CLAUDE.md`, `apps/CLAUDE.md`. Both govern. This file adds detail, never overrides.
**Status:** Build against mock data. Types land in `packages/shared` when the institutional schema is agreed (see open issue).

---

## What this screen is

The first thing a programme officer sees on opening AgroEdge for a programme they administer. Temo Letlotlo, first. Pfumvudza second.

It is the control tower. It answers, in one glance:

- How many farmers are enrolled, and how many are actually verified
- Where they are
- What is wrong

It is not a farmer app dashboard rendered larger. It is a different product for a different person.

---

## The N=3 problem — read this before laying anything out

At pilot, this programme has **three enrolled farmers.**

A dashboard designed for 10,000 renders badly at 3. Charts look empty. A choropleth map with one shaded district looks broken. A histogram of three bars is not a distribution. A "0.03% flagged" figure is arithmetic noise.

**Design for 3. Verify it holds at 10,000.** Not the other way round.

Two consequences:

1. **Below a threshold, show records, not distributions.** When enrolled count is under, say, 25, the district distribution component renders as a **short list** — district, count — not a chart. Above the threshold it becomes a chart. Same component, two states. Build the list state first; it is the one that will be on screen in front of the Ministry.

2. **Every empty state is a real design task, not a placeholder.** "No anomalies detected" for a three-farmer programme is a true, meaningful, good-news statement. Design it as such. Do not render an empty chart axis with nothing in it.

---

## Honesty rules — non-negotiable

Root `CLAUDE.md` forbids overclaiming in code, comments, and UI strings. This screen is where that rule earns its keep.

- **Never render simulated data without labelling it.** If a component is populated by mock data during development or demo, it carries a visible `Sample data` chip. Not a code comment. A chip, on the screen, that a Ministry officer can read.
- **Never inflate.** If three farmers are enrolled, the number on screen is `3`. Not a projection, not an illustrative figure.
- **Never render an individual farmer's name, phone, or national ID.** The dashboard shows aggregates. If a Ministry officer needs to reach a farmer, that is a different, permissioned, audited screen — not this one.
- The dashboard is **planned, not built.** Nothing in the code, README, or a UI string may imply otherwise.

The `Sample data` chip is not an embarrassment. In a room with a procurement officer, it is the single most credible thing on the screen.

---

## Layout

Desktop first, 1440px. The officer is at a desk. Responsive down to 1024. Below that, do not attempt — this screen is not for phones and pretending otherwise wastes your time.

```
┌────────────────────────────────────────────────────────────────┐
│ MASTHEAD  forest-900                                           │
│  Temo Letlotlo · Ministry of Lands & Agriculture · 2026/27     │
│  [ Season selector ▾ ]                        [Sample data]    │
└────────────────────────────────────────────────────────────────┘

┌──────────┬──────────┬──────────┬──────────┐
│ ENROLLED │ VERIFIED │ UNVERIF. │ HECTARES │    ← metric row
│    3     │    3     │    0     │   4.2    │
└──────────┴──────────┴──────────┴──────────┘

┌──────────────────────────────┬─────────────────────────────────┐
│ DISTRIBUTION                 │ NEEDS ATTENTION                 │
│ (list at N<25, chart above)  │                                 │
│                              │  No anomalies detected.         │
│  Mahalapye        2          │  All 3 enrolments verified.     │
│  Serowe           1          │                                 │
│                              │                                 │
└──────────────────────────────┴─────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ ENROLMENT OVER TIME                                            │
│ (sparkline / step chart — honest with 3 points)                │
└────────────────────────────────────────────────────────────────┘
```

---

## Components

### 1. Masthead

`forest-900` background, `cream-100` text. Programme name at `26`, institution and season at `14` in `ink-500` on light — invert appropriately for dark ground.

Season selector on the left of the row. It is a filter, not decoration: every number below it is scoped to the selected season, because **the season is the billing period**. Getting this wrong means invoicing the wrong number.

`Sample data` chip, `gold-500` border, `gold-500` text, transparent fill, `12` Calibri, uppercase. Present whenever any component on the screen is mock-fed. Absent otherwise.

### 2. Metric row

Four cards. `cream-100` background, `24` padding, `4` gap between. Numbers at `34` in Calibri. Labels at `12`, `ink-500`, uppercase, letter-spaced.

- **Enrolled** — `count(enrolments) where status = 'active'`. This is the invoice number. Treat it with respect.
- **Verified** — `count where verified_at is not null`
- **Unverified** — the difference. **This is the ghost-farmer number.** If it is above zero, this card is the most important thing on the screen: border it `gold-500` and make the number the same. If zero, it is quiet — `ink-500`, no emphasis.
- **Hectares under plan** — sum across active enrolments

Never colour-code by red/green alone. Pair every emphasised state with a word. Sunlight, colourblindness, and screenshots in a procurement PDF all defeat colour.

### 3. Distribution

**Under 25 enrolments:** a plain two-column list. District name, count. Right-aligned numbers, Calibri, tabular figures. Sorted descending.

**25 and above:** horizontal bars, `forest-700`, single colour. Not a pie chart. Not a map, not yet — a choropleth of Botswana with two shaded districts communicates nothing and takes a week.

Build only the list state now. Leave a `// TODO: bar state above threshold` and move on.

### 4. Needs attention

The product, in one panel. Anomaly flags, surfaced as sentences a human can act on:

- `2 enrolments unverified for over 30 days`
- `1 farm profile has no logged activity this season`
- `1 enrolment shares a national ID hash with another programme`

At N=3, all of these will likely be empty, and the panel reads: **"No anomalies detected. All 3 enrolments verified."** In `forest-700`, with a check icon.

That is the correct, honest, and genuinely impressive output. A Ministry officer who has spent years with a registry that cannot tell them this will notice.

Do not invent anomaly rules. The three above are illustrative. The real rules come from the schema conversation and belong in `services/api`, not here. **The panel renders whatever the API sends. It computes nothing.**

### 5. Enrolment over time

Step chart, not a smoothed line. Three farmers enrolled on three dates is three steps, and a smoothed curve through three points is a lie about the shape of the data.

`forest-700` line. No fill. No gradient. Axis labels at `12`.

---

## Data

Nothing is fetched directly from Supabase. **The dashboard calls `services/api` and receives aggregates.** It never queries `farm_profiles`.

This is deliberate and it is a selling point: it lets you say to a procurement officer, truthfully, *the dashboard is architecturally incapable of returning an individual farmer's record.*

One endpoint, one shape:

```
GET /programmes/:id/overview?season=:seasonId

{
  programme:  { id, name, institution, countryCode },
  season:     { id, name, startsOn, endsOn },
  metrics:    { enrolled, verified, unverified, hectaresUnderPlan },
  byDistrict: [ { districtId, name, count } ],
  anomalies:  [ { severity, message, count } ],
  timeline:   [ { date, cumulativeEnrolled } ],
  isSampleData: boolean
}
```

`isSampleData` comes from the server, not from a client-side flag. A frontend flag can be forgotten. A server flag cannot be forgotten in a demo, because the demo runs against the server.

Until the endpoint exists: a single mock module returning this exact shape, `isSampleData: true`, three farmers, Mahalapye and Serowe. **One module. Not mocks scattered across components.** When the endpoint lands you delete one file.

Types live in `packages/shared` and are a joint PR. Do not define them locally in `apps/dashboard`, not even temporarily. A local shadow type is how the contract layer dies.

---

## Build order

1. Static layout, hardcoded values, no state. Confirm it looks right at N=3.
2. Mock module returning the shape above.
3. Wire components to the mock.
4. Empty states, loading states, error states. **The N=3 case is the primary case, not an edge case.**
5. Season selector filters against the mock.
6. Swap mock for endpoint when it lands.

Do not build the bar chart state. Do not build the map. Do not build drill-down. Every one of those is a week you do not have, and none is on screen in the Ministry meeting.

---

## Definition of done

An officer opens the screen, sees three enrolled farmers in two districts, sees that all three are verified, sees no anomalies, and understands the programme's state in under eight seconds.

An investor sees the same screen and understands that at 10,000 farmers, the layout does not change — only the numbers.

Nobody in either room is misled about how many farmers exist.
