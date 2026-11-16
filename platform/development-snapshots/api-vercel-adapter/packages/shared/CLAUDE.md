# packages/shared — The Contract Layer

**Owner: Agent B2. This package changes by pull request only.**

Every other package imports this one. An unreviewed change here breaks four agents
simultaneously. If you are not B2 and you believe this package must change, stop and
open an issue.

## Contents
- `openapi/` — the OpenAPI 3.1 spec. This is the source of truth for the API.
- `types/` — TypeScript types generated from the spec. Generated, never hand-edited.
- `models/` — Dart models generated from the spec. Generated, never hand-edited.
- `constants/` — enums shared across platforms: crop types, regions, programme codes,
  units.

## Rules
- The spec is written first. Types and models are generated from it. If you find
  yourself hand-editing a generated file, the generator is wrong — fix the generator.
- Breaking changes require a version bump and a migration note in the PR body.
- Additive changes only, wherever possible. The mobile app in a farmer's hand may be
  three versions behind.
- Regenerate and commit generated output in the same PR as the spec change.

## Known limitations
- `readOnly` fields (`id`, `owner_user`, `created_at`, `updated_at`) come out nullable
  in the generated Dart models, even where the OpenAPI spec lists them as `required`.
  This is `swagger_dart_code_generator`'s deliberate handling of `readOnly` — it makes
  no exception for fields that are also required — not a spec error. The API always
  populates these fields; the generated Dart type just doesn't reflect that. Consumers
  in `apps/mobile` and `apps/dashboard` should expect `String?`/`DateTime?` here and
  may need a null-check or `!` when reading them. Revisit if a better Dart generator
  becomes available.
