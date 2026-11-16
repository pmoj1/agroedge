# agroedge_mobile — Farmer App (Pilot Build)

Scoped-down pilot for 3 known, tech-comfortable farmers. Flutter Web, not the
full offline-first multilingual product described in `CLAUDE.md` -- see that
file for the long-term vision this intentionally narrows down from.

## What this is

- Supabase Auth email/password sign-in.
- One-time farm setup (farm name, size, primary crop, region) after first sign-in.
- Home screen: today's date, shortcuts, recent activities.
- Log Activity / Log Expense / Log Income, each mapped to the matching
  `services/api` resource using the generated models in `packages/shared`.
- AI Chat: stubbed "coming soon" state. `services/integrations` has no working
  AI adapter yet (Claude API is server-side only, per root `CLAUDE.md`).

## Prerequisites

- Flutter 3.24+ (this was built and tested against Flutter 3.44.5).
- A Supabase project with the schema in `db/migrations/` applied, and at
  least one `auth.users` row (+ matching `public.users` row) for each pilot
  farmer, created via the Supabase dashboard or `supabase auth` CLI --
  this app has no sign-up flow, only sign-in.
- `services/api` running locally on port 3000 (see root `CLAUDE.md` for the
  port table). **As of this build, `services/api` has no implementation --
  only its `CLAUDE.md` placeholder.** Auth will work end-to-end today; the
  farm setup, activity, expense, and income screens will show a network
  error until `services/api` exists and implements the routes in
  `packages/shared/openapi/openapi.yaml`.

## Running it

Supabase credentials and the API host are passed at build/run time, never
hardcoded. Create a dart-define file (not committed -- see root
`.gitignore`):

```json
// apps/mobile/dart_define.local.json
{
  "SUPABASE_URL": "https://<your-project>.supabase.co",
  "SUPABASE_ANON_KEY": "<your-anon-key>",
  "API_BASE_URL": "http://localhost:3000"
}
```

Then:

```bash
cd apps/mobile
flutter pub get
flutter run -d chrome --dart-define-from-file=dart_define.local.json
```

`API_BASE_URL` defaults to `http://localhost:3000` if omitted.

To produce a static build (e.g. to hand a pilot farmer a URL):

```bash
flutter build web --dart-define-from-file=dart_define.local.json
# serve build/web with any static file server
```

## Testing with a real pilot farmer

1. Create their Supabase Auth user (email/password) and a matching
   `public.users` row -- there is no self-serve sign-up in this build.
2. Have `services/api` running and reachable at `API_BASE_URL`.
3. Send them the sign-in URL. First sign-in routes to farm setup
   automatically; every sign-in after that goes straight to Home.

## Deployment

This app is configured to deploy automatically to Netlify on push/merge to the `main` branch via GitHub Actions.

Live URL: [https://bucolic-stardust-e9b878.netlify.app](https://bucolic-stardust-e9b878.netlify.app)

