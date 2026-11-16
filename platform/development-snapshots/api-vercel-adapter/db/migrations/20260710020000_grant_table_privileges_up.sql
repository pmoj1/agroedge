-- Fixes a gap in 20260710000000_init_schema_up.sql: that migration enables
-- RLS and writes policies on every table, but never GRANTs base table
-- privileges. Postgres checks table-level ACL *before* RLS is evaluated,
-- so without this, every query against these tables fails with
-- "permission denied for table X" regardless of RLS policy -- including
-- for service_role, which bypasses RLS (BYPASSRLS) but is not exempt from
-- ordinary GRANT/REVOKE checks. This was caught by actually running
-- services/api's integration suite against a local Supabase instance for
-- the first time; every one of these 15 tables was affected, meaning the
-- API as originally built could not have reached any of them, in local
-- dev or in a real Supabase project.
--
-- 20260710000000_init_schema_up.sql is already on main, so this is a
-- forward-fixing migration rather than an edit to that one (never edit an
-- already-shipped migration).
--
-- Granted to `authenticated` and `service_role`, not `anon`: every RLS
-- policy here keys off auth.uid(), which is always null for an
-- unauthenticated caller, so an anon grant could never pass RLS anyway --
-- there's no reason to open that door for farmer data.

grant select, insert, update, delete on public.users to authenticated, service_role;
grant select, insert, update, delete on public.farm_profiles to authenticated, service_role;
grant select, insert, update, delete on public.activities to authenticated, service_role;
grant select, insert, update, delete on public.activity_files to authenticated, service_role;
grant select, insert, update, delete on public.expenses to authenticated, service_role;
grant select, insert, update, delete on public.income_records to authenticated, service_role;
grant select, insert, update, delete on public.season_budgets to authenticated, service_role;
grant select, insert, update, delete on public.ai_crop_plans to authenticated, service_role;
grant select, insert, update, delete on public.ai_insights to authenticated, service_role;
grant select, insert, update, delete on public.ai_messages to authenticated, service_role;
grant select, insert, update, delete on public.communication_preferences to authenticated, service_role;
grant select, insert, update, delete on public.notifications to authenticated, service_role;
grant select, insert, update, delete on public.notification_delivery_logs to authenticated, service_role;
grant select, insert, update, delete on public.reminders to authenticated, service_role;
grant select, insert, update, delete on public.weekly_reports to authenticated, service_role;

-- Every one of these tables also has a serial/identity-free uuid primary
-- key (gen_random_uuid() default), so there are no sequences to grant
-- USAGE on.
