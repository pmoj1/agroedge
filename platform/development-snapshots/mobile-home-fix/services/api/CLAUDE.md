# services/api — Backend API (Node + Fastify + TypeScript)

**Owner: Agent A1.** You also own `db/`. Do not edit `apps/` or `packages/shared`.

## Purpose
The single source of truth. Both the mobile app and the dashboard talk only to this
service. No client touches Supabase directly.

## Non-negotiables
- The OpenAPI spec in `packages/shared` is the contract. If the spec and the
  implementation disagree, the implementation is wrong. To change the contract, open
  a PR against `packages/shared` first and get it merged.
- Every endpoint is authenticated. Every endpoint is authorised. Authentication is
  not authorisation — check both.
- Row-level security in Postgres is the backstop, not the primary defence. Enforce
  access control in the API layer as well. Assume RLS will one day be misconfigured.
- Validate every input at the boundary with a schema. Never trust the client.
- Structured JSON logging. Never log PII, tokens, phone numbers, or national ID
  numbers. Redact by default; allowlist what may be logged.
- Rate limit everything. Institutional export endpoints especially.
- Idempotency keys on every write endpoint. The mobile app is offline-first and will
  retry.

## Port
Runs on `:3000` locally.

## Testing
Contract tests against the OpenAPI spec. Integration tests against a local Supabase.
Every RLS policy needs a test that proves an unauthorised read fails.
