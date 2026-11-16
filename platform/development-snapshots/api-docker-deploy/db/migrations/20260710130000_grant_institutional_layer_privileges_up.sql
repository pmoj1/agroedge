-- Fixes the same gap as 20260710020000_grant_table_privileges_up.sql, this
-- time for the institutional-layer tables added in
-- 20260710120000_institutional_layer_up.sql: RLS is enabled and policies
-- exist for every table, but no base table privileges were granted, so
-- service_role -- which bypasses RLS but is not exempt from ordinary
-- GRANT/REVOKE checks -- would get "permission denied" the moment
-- anything touches these tables directly. The aggregate dashboard
-- functions (institution_programme_overview,
-- institution_programme_district_distribution) are unaffected: they're
-- SECURITY DEFINER and run under the function owner's privileges, not
-- the caller's, so they never needed a table grant to work.
--
-- authenticated gets SELECT only, matching what actually exists: every
-- policy in 20260710120000_institutional_layer_up.sql is a `for select`
-- policy -- there is no authenticated-facing write path in this schema
-- yet (writes are presumably meant to go through service_role, e.g. a
-- future services/api institutional endpoint). Granting authenticated
-- write privileges here would be needlessly broad for a schema whose own
-- design notes are explicit about structural guarantees ("This is a
-- structural guarantee, not a policy choice") rather than leaning on RLS
-- alone to catch what a grant should never have allowed in the first
-- place.
--
-- service_role gets full CRUD on all 8 tables, since it bypasses RLS and
-- will need it to actually manage institutional data once that lands in
-- services/api.

grant select on public.institutions to authenticated;
grant select, insert, update, delete on public.institutions to service_role;

grant select on public.programmes to authenticated;
grant select, insert, update, delete on public.programmes to service_role;

grant select on public.seasons to authenticated;
grant select, insert, update, delete on public.seasons to service_role;

grant select on public.districts to authenticated;
grant select, insert, update, delete on public.districts to service_role;

grant select on public.enrolments to authenticated;
grant select, insert, update, delete on public.enrolments to service_role;

grant select on public.institution_users to authenticated;
grant select, insert, update, delete on public.institution_users to service_role;

grant select on public.consents to authenticated;
grant select, insert, update, delete on public.consents to service_role;

grant select on public.verifications to authenticated;
grant select, insert, update, delete on public.verifications to service_role;
