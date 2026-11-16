-- Reverses 20260710130000_grant_institutional_layer_privileges_up.sql

revoke select, insert, update, delete on public.institutions from authenticated, service_role;
revoke select, insert, update, delete on public.programmes from authenticated, service_role;
revoke select, insert, update, delete on public.seasons from authenticated, service_role;
revoke select, insert, update, delete on public.districts from authenticated, service_role;
revoke select, insert, update, delete on public.enrolments from authenticated, service_role;
revoke select, insert, update, delete on public.institution_users from authenticated, service_role;
revoke select, insert, update, delete on public.consents from authenticated, service_role;
revoke select, insert, update, delete on public.verifications from authenticated, service_role;
