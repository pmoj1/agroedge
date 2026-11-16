# AgroEdge Platform — Project Context

You are working on the AgroEdge platform rebuild: a migration from a Bubble no-code
MVP to a production-grade custom stack.

## What AgroEdge is

AgroEdge is a digital intelligence layer built on top of existing government farmer
registries across Southern and East Africa. It serves two customers from one platform:

- **Farmers** use it free. It is a decision tool: farm records, P&L, yield tracking,
  and an AI agronomist.
- **Institutions** (governments, NGOs, development funders) pay per enrolled farmer
  per season. For them it is a targeting, monitoring and de-risking tool.

The business model is B2G. The farmer-facing app is the engagement hook. The
**institutional dashboard is the core product**. When you are making a tradeoff
between the two, the institutional side wins.

Target markets: Botswana (Temo Letlotlo programme — beachhead), Zimbabwe
(Pfumvudza/Intwasa), Kenya (KIAMIS).

## Stack

| Layer | Technology |
|---|---|
| Farmer mobile app | Flutter (Android primary, iOS secondary) |
| Institutional dashboard | Flutter Web |
| Backend API | Node.js + Fastify (TypeScript) |
| Database | PostgreSQL via Supabase, row-level security enforced |
| AI | Claude API (Anthropic), server-side only |
| SMS / USSD | Africa's Talking |
| Weather | Open-Meteo (primary), Tomorrow.io (fallback) |
| Hosting | Railway (Phase 1) |
| CI/CD | GitHub Actions |
| Error monitoring | Sentry |

Everything is containerised and must remain portable to in-region hosting without a
rewrite. See "Data residency" below — this is not optional.

## Repository layout and ownership

Each directory has a single owning agent. **Do not edit files outside your lane.**
If your task requires a change in another lane, stop and say so rather than making it.

```
apps/mobile/            → JAYDEANE   Flutter farmer app
apps/dashboard/         → JAYDEANE   Flutter Web institutional dashboard
services/api/           → AONE       Fastify API
db/                     → AONE       Supabase migrations, RLS policies
services/integrations/  → AONE       Claude API, Africa's Talking, weather
packages/shared/        → PR ONLY    Shared Dart models + TS types (the contract)
infra/                  → PR ONLY    CI, hosting config

Lanes are owned by founder, not by agent number. Every agent running on Jaydeane's
machine works only in `apps/`. Every agent on Aone's machine works only in
`services/` and `db/`. A change to `packages/shared` or `infra/` is its own pull
request, approved by both founders, touching nothing else.
```

`packages/shared` is the contract layer. Everything imports it. It changes by pull
request only. Never modify it as a side effect of another task.

## Local port assignments

Parallel Claude Code sessions share the same machine environment. Worktrees isolate
files, not processes. Use your assigned port only.

| Service | Port |
|---|---|
| `services/api` | 3000 |
| `services/integrations` | 3001 |
| `apps/dashboard` (flutter web dev) | 5000 |
| Supabase local | 54321 |

## Data residency — hard constraint

All three target markets restrict cross-border transfer of personal data:

- Botswana Data Protection Act 2024
- Zimbabwe Cyber and Data Protection Act 2021
- Kenya Data Protection Act 2019

Consequences for how you write code:

1. **No farmer personal data leaves the region without an explicit lawful basis.**
   Never log PII to third-party services. Never send PII to the Claude API — strip
   or pseudonymise identifiers before any prompt is constructed.
2. Every table containing farmer data must have row-level security enabled. No
   exceptions, no "we'll add RLS later."
3. Hosting region and storage bucket region are configuration, never hardcoded.
4. Data deletion must be a real hard delete path, not a soft-delete flag.

Treat data protection as a product feature, not a compliance checkbox. It is a
genuine barrier to entry against competitors and it is what a government
procurement officer will interrogate first.

## Engineering conventions

- TypeScript everywhere in Node. `strict: true`. No `any` without a comment
  explaining why.
- Dart: `flutter analyze` must pass clean. No ignored lints without justification.
- Offline-first on mobile. Assume intermittent connectivity, not zero connectivity.
  Local write, queue, sync, reconcile.
- Conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`.
- Every PR touching `db/` must include both an `up` and a `down` migration.
- No secrets in the repo. Ever. Use `.env` locally and GitHub Actions secrets in CI.
  If you find a secret committed, stop and flag it.
- Write the test before you write the fix.

## Working style

- Scope each session to one concern. A branch that touches five modules cannot be
  reviewed properly and will conflict on merge.
- Prefer boring, obvious code. This platform will be audited by government IT
  departments and by investor technical due diligence.
- If a requirement is ambiguous, ask. Do not guess and build.

## Language rules for anything user-facing or documentation-facing

The following claims are **false** and must never appear in code comments, README
files, commit messages, marketing copy, or UI strings:

- That AgroEdge has signed government contracts. It does not. Government
  relationships are outreach in progress.
- That the institutional dashboard is built. It is planned.
- That the platform is live in production. It is a working MVP.
- That any letter of intent or pilot contract is executed. None are.

Accuracy about current state is a standing company principle. Apply it in code too.
