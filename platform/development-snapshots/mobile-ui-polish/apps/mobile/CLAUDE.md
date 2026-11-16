# apps/mobile — Farmer App (Flutter)

**Owner: Agent B1.** Do not edit `packages/shared`, `services/`, or `db/` from here.

## Purpose
The farmer-facing Android/iOS app. Free to the farmer. This is the engagement hook
that produces the data the institutional dashboard sells.

## Users you are building for
Smallholder farmers in Botswana and Zimbabwe. Assume:
- Low-end Android devices, 2-4GB RAM, Android 9+.
- Intermittent connectivity. Often none for hours or days.
- Data cost is a real constraint. Every KB matters.
- Many users are not confident with smartphones. Some share a device.
- Not all users read English fluently.

Android is the primary target. iOS is secondary and shares the codebase.

## Non-negotiables
- **Offline-first.** All writes go to local storage first, then sync. The app must
  be fully usable with the radio off. Never block a UI action on a network call.
- Conflict resolution on sync is last-write-wins per field, with a local audit log.
- No PII in analytics events.
- Every string goes through the localisation layer from day one. Never hardcode
  user-visible text. Languages: English, Setswana, Shona, Ndebele, Swahili.
- Large tap targets. High contrast. Legible at arm's length in bright sun.
- The app must degrade gracefully to SMS. If a farmer cannot open the app, the
  critical alerts still reach them via `services/integrations`.

## Structure
```
lib/
  features/       one folder per feature, self-contained
  core/           routing, theming, error handling
  data/           local db, sync engine, repositories
  l10n/           ARB files
```

## Testing
Widget tests for every screen. Integration test for the offline sync path — that is
the highest-risk code in the app and it must have coverage before merge.
