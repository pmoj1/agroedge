-- Reverses 20260710120000_institutional_layer_up.sql

drop table if exists public.verifications;
drop table if exists public.consents;
drop table if exists public.institution_users;
drop table if exists public.enrolments;
drop table if exists public.districts;
drop table if exists public.seasons;
drop table if exists public.programmes;
drop table if exists public.institutions;

drop function if exists public.institution_programme_district_distribution(uuid, uuid);
drop function if exists public.institution_programme_overview(uuid, uuid);
drop function if exists public.enrolment_has_active_consent(uuid);
drop function if exists public.enrolment_institution_id(uuid);
drop function if exists public.has_active_consent(uuid, uuid);
drop function if exists public.farmer_is_enrolled_in_programme(uuid);
drop function if exists public.programme_institution_id(uuid);
drop function if exists public.auth_institution_ids();
