-- Reverses 20260710020000_grant_table_privileges_up.sql

revoke select, insert, update, delete on public.users from authenticated, service_role;
revoke select, insert, update, delete on public.farm_profiles from authenticated, service_role;
revoke select, insert, update, delete on public.activities from authenticated, service_role;
revoke select, insert, update, delete on public.activity_files from authenticated, service_role;
revoke select, insert, update, delete on public.expenses from authenticated, service_role;
revoke select, insert, update, delete on public.income_records from authenticated, service_role;
revoke select, insert, update, delete on public.season_budgets from authenticated, service_role;
revoke select, insert, update, delete on public.ai_crop_plans from authenticated, service_role;
revoke select, insert, update, delete on public.ai_insights from authenticated, service_role;
revoke select, insert, update, delete on public.ai_messages from authenticated, service_role;
revoke select, insert, update, delete on public.communication_preferences from authenticated, service_role;
revoke select, insert, update, delete on public.notifications from authenticated, service_role;
revoke select, insert, update, delete on public.notification_delivery_logs from authenticated, service_role;
revoke select, insert, update, delete on public.reminders from authenticated, service_role;
revoke select, insert, update, delete on public.weekly_reports from authenticated, service_role;
