# apps/dashboard — Institutional Dashboard (Flutter Web)

**Owner: Agent A2.** Do not edit `packages/shared`, `services/`, or `db/` from here.

## Purpose
This is the product AgroEdge actually sells. Governments, NGOs and development
funders pay per enrolled farmer per season for this view.

The one-liner that defines the scope:

> "Temo CMS tells you who your farmers are. AgroEdge tells you what to do about it."

Registries answer *who*. This dashboard answers *what now*.

## Users you are building for
Ministry of Agriculture programme officers, NGO M&E staff, agricultural lenders.
Assume:
- Desktop, Chrome, decent connection.
- Comfortable with spreadsheets, not with dashboards. Favour tables and exports over
  clever visualisations.
- They must be able to defend every number to a minister or a donor. Every figure
  needs visible provenance: source, date, method, confidence.
- CSV and PDF export are core features, not afterthoughts.

## Core views (build in this order)
1. **Enrolment** — farmer counts by region, ward, crop, gender, cohort.
2. **Programme monitoring** — input distribution vs planting vs reported yield.
3. **Subsidy targeting** — who qualifies, who received, gap analysis.
4. **Anomaly / ghost-farmer detection** — duplicate identities, implausible plot
   sizes, farmers with inputs but no activity. Flag, never auto-penalise. Always
   surface why a record was flagged and allow an officer to dismiss it with a reason.
5. **Food security forecasting** — projected regional yield, confidence intervals.
6. **Credit de-risking** — repayment-relevant farmer history, exportable.

## Non-negotiables
- Role-based access. An officer for one district must not see another district.
- Never display an individual farmer's identity in an aggregate view without an
  explicit, logged drill-down action.
- Every export is audit-logged: who, what, when.
- Confidence must be visible. An estimated yield forecast must never render as if it
  were a measured fact.
