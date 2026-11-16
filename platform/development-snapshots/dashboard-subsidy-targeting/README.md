# AgroEdge Platform

Production rebuild of the AgroEdge platform, migrating from a Bubble no-code MVP to
a custom full stack.

**Status:** pre-incorporation, pre-revenue, pre-seed. Working MVP on Bubble. This
repository is the rebuild. Nothing here is in production.

## Read this first

`CLAUDE.md` at the repo root is the project brief. Every Claude Code session picks
it up automatically. Each package has its own `CLAUDE.md` with lane-specific rules.

## Ownership lanes

Each directory has one owning agent. Nobody edits outside their lane.

| Lane | Agent | Machine |
|---|---|---|
| `services/api` + `db` | A1 | Jaydeane (M1) |
| `apps/dashboard` | A2 | Jaydeane (M1) |
| `apps/mobile` | B1 | Aone (M3 Pro) |
| `packages/shared` | B2 | Aone (M3 Pro) |
| `services/integrations` | B3 | Aone (M3 Pro) |

`packages/shared` is the contract layer. It changes by pull request only.

## First-time setup

```bash
git clone git@github.com:AgroEdge/agroedge-platform.git
cd agroedge-platform
cp .env.example .env      # fill from the shared vault, never commit
```

## Running a parallel agent session

Two Claude Code sessions in the same folder do NOT isolate just because they are in
different terminal windows. Use a worktree per session.

```bash
# Terminal 1
claude -w api-service

# Terminal 2
claude -w dashboard
```

Each gets its own directory under `.claude/worktrees/` and its own branch, branched
from `main`. The `.worktreeinclude` file copies your `.env` files in automatically.

Worktrees isolate files, not processes. Ports are assigned in the root `CLAUDE.md` —
stick to yours.

Housekeeping: `git worktree list` weekly, `git worktree remove` after merging.

## Sequencing

**Week 0 — one agent only.** A1 defines the Postgres schema, the RLS policies, and
the OpenAPI contract in `packages/shared`. Merge to `main`. Nobody else runs.

**Week 1 onwards.** Everyone branches from that contract.

Five agents working against five different assumptions about the data model is the
main way this fails.

## Branch protection

`main` requires: a pull request, one approval, passing status checks, no force push.
Two founders reviewing each other is slower and it is correct. It is also the commit
history a technical due diligence reviewer will read.

## Bubble migration

1. Export every data type to CSV from Bubble → Data → App data (requires a paid plan).
2. Hand-write the mapping doc: Bubble field → Postgres column. Do this manually. It
   is where silent data loss happens.
3. Seed into a staging Supabase project first.
4. Keep Bubble live and paid until the pilot data is verified in the new stack.
