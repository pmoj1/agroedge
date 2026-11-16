# Bubble → Postgres migration notes

Source: `agroedge-v2` Bubble app, Data Types tab, captured 9 July 2026.
Target: `db/migrations/20260710000000_init_schema_up.sql`

## Renames and restructuring

| Bubble | Postgres | Why |
|---|---|---|
| `Creator` (built-in) | dropped | Every table already has `owner_user`. Keeping both is redundant and one of them will drift. |
| `gps_location` (geographic address) | `gps_lat numeric, gps_lng numeric` | Postgres has no native "geographic address" type. Split to two numeric columns now; if you need proper geospatial queries later (radius search, region polygons), migrate to PostGIS `geography(Point)` — flagged for Phase 2, not needed for a 1,000-farmer pilot. |
| `ActivityFile.file` / `.photo` | `activity_files.storage_path` | Bubble stores the file inline. Supabase Storage stores an object and gives you back a path, not the file itself. Never store a public URL — storage_path plus a signed URL generated per-request keeps files access-controlled. |
| `Expense.receipt` (type ActivityFile) | `expenses.receipt_file_id` → `activity_files.id` | Bubble modeled this as three separate file types (ActivityFile, ExpenseFile, IncomeFile) that are structurally identical. Collapsed into one `activity_files` table referenced by FK from whichever record owns it. Less duplication, same capability. |
| `IncomeFile` / `ExpenseFile` (separate types) | merged into `activity_files` | See above. |
| `User.email` etc. | `public.users` referencing `auth.users` | Supabase Auth owns authentication. `public.users` is your profile extension table, not your login table. |

## What's deliberately not carried over

- Bubble's built-in `Slug` field — that's a Bubble URL-routing artifact, not domain data.
- Bubble's built-in `Modified Date` — replaced with a real `updated_at` your API controls explicitly, so you know exactly when and why it changed.

## Flag for a lawyer / data policy conversation, not just engineering

`activities.gps_lat/lng` and `farm_profiles.gps_lat/lng` are precise farmer location data. Under Botswana DPA 2024, Zimbabwe CDPA 2021, and Kenya DPA 2019, precise geolocation tied to an identifiable person is sensitive personal data. Two decisions to make before Phase 2, not urgent for pilot:

1. Does the institutional dashboard ever need precise GPS, or does it only ever need ward/region-level aggregation? If the latter, the dashboard should query a rounded/region-bucketed view, never the raw lat/lng.
2. The `services/integrations/ai/` adapter must never receive `gps_lat`/`gps_lng` in a prompt — region name only. This is already stated in that package's CLAUDE.md.

## Role field added, not in Bubble

`public.users.role` (`farmer` / `institution_officer` / `admin`) and `public.users.region` didn't exist as explicit fields in your Bubble schema but are required for the institutional dashboard's role-based access rule in `apps/dashboard/CLAUDE.md`. A1 should confirm this against how Bubble's `Privacy rules` on the User type currently scope access, since that logic needs to be replicated, not just the data shape.

## Every table with a `owner_user` has

- RLS enabled in the same migration that creates it
- A policy scoping all access to `auth.uid() = owner_user`

This satisfies the standing rule in `db/CLAUDE.md`. The institutional dashboard will need a **separate, additional policy** granting `institution_officer` role read access scoped by region — intentionally not included in this initial migration, since that's dashboard-specific and should land as its own reviewed PR once `apps/dashboard` work starts.

## Not yet migrated

Nothing — this covers all 17 Bubble data types visible in the screenshots (Activity, ActivityFile, AiCropPlan, AiInsight, AiMessage, CommunicationPreference, Expense, ExpenseFile, FarmProfile, IncomeFile, IncomeRecord, Notification, NotificationDeliveryLog, Reminder, SeasonBudget, User, WeeklyReport).

## Next step

This is schema only — no data. Actual CSV export and row-by-row migration from Bubble's **Data → App data** tab is a separate, manual step per the root README's Bubble migration section. Do that only after this schema is reviewed and merged, and only against a staging Supabase project first.
