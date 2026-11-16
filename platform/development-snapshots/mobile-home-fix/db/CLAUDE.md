# db — Supabase / PostgreSQL

**Owner: Agent A1.**

## Rules
- Every migration has a matching `down`. No exceptions.
- Every table containing farmer data has row-level security **enabled in the same
  migration that creates the table.** Never in a follow-up.
- Every RLS policy has a test that proves an unauthorised read returns zero rows.
- No `SELECT *` in application queries. Name the columns, so a new PII column can
  never leak by accident.
- Personal identifiers live in a single table with restricted access. Everything else
  references a pseudonymous farmer ID.
- Hard-delete paths exist and are tested. Botswana DPA 2024, Zimbabwe CDPA 2021 and
  Kenya DPA 2019 all confer erasure rights. A soft-delete flag does not satisfy them.
- Region is configuration. Never hardcode a hosting region or bucket location.
- Automated backups are on, and a restore has actually been tested. An untested
  backup is not a backup.

## Migration naming
`YYYYMMDDHHMMSS_short_description.sql`
