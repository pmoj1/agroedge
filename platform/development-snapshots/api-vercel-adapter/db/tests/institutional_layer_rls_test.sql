-- Proves the institutional-layer RLS model:
--   1. A Botswana institution officer cannot read a Zimbabwean farmer's
--      enrolment, even though both farmers are enrolled in structurally
--      identical programmes/seasons.
--   2. Withdrawing a farmer's consent removes the institution's read
--      access to that farmer's enrolment.
--   3. A district with fewer than 5 active enrolments is never returned by
--      district_id in the aggregate breakdown — it is pooled into a
--      district_id = null bucket instead, so a small district can never
--      identify an individual farmer.
--
-- Requires the Supabase Auth schema (run against `supabase start`'s local
-- Postgres, not bare Postgres). Adjust the auth.users insert if your local
-- Supabase CLI version requires additional NOT NULL columns.
--
-- Run with: psql "$DATABASE_URL" -f db/tests/institutional_layer_rls_test.sql

begin;

-- ---------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------
insert into auth.users (id) values
  ('11111111-1111-1111-1111-111111111111'), -- BW officer
  ('22222222-2222-2222-2222-222222222222'), -- BW farmer
  ('33333333-3333-3333-3333-333333333333'); -- ZW farmer

insert into public.users (id, email, role) values
  ('11111111-1111-1111-1111-111111111111', 'officer@moa.gov.bw', 'institution_officer'),
  ('22222222-2222-2222-2222-222222222222', 'farmer.bw@example.com', 'farmer'),
  ('33333333-3333-3333-3333-333333333333', 'farmer.zw@example.com', 'farmer');

insert into public.institutions (id, name, country_code, institution_type, data_region) values
  ('a1111111-1111-1111-1111-111111111111', 'Botswana Ministry of Agriculture', 'BW', 'government', 'af-south-1'),
  ('a2222222-2222-2222-2222-222222222222', 'Zimbabwe Ministry of Agriculture', 'ZW', 'government', 'af-south-1');

insert into public.institution_users (user_id, institution_id, role) values
  ('11111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'officer');

insert into public.programmes (id, institution_id, name, country_code, starts_on) values
  ('b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'Temo Letlotlo', 'BW', '2026-10-01'),
  ('b2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222', 'Pfumvudza/Intwasa', 'ZW', '2026-10-01');

insert into public.seasons (id, country_code, name, starts_on, ends_on) values
  ('c1111111-1111-1111-1111-111111111111', 'BW', '2026/27 Summer', '2026-10-01', '2027-04-30'),
  ('c2222222-2222-2222-2222-222222222222', 'ZW', '2026/27 Summer', '2026-10-01', '2027-04-30');

insert into public.farm_profiles (id, owner_user, farm_name, country) values
  ('d1111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'BW test farm', 'Botswana'),
  ('d2222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'ZW test farm', 'Zimbabwe');

insert into public.districts (id, country_code, name) values
  ('e1111111-1111-1111-1111-111111111111', 'BW', 'Serowe');

insert into public.enrolments (farm_profile_id, programme_id, season_id, district_id, status) values
  ('d1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111', 'e1111111-1111-1111-1111-111111111111', 'active'),
  ('d2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222', null, 'active');

insert into public.consents (farm_profile_id, programme_id, consent_text_version, channel, granted_at) values
  ('d1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 'v1', 'in_person', now());

-- ---------------------------------------------------------------------
-- Act as the Botswana officer (non-superuser role, so RLS actually applies)
-- ---------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', true);

-- Scenario 1: cross-institution denial, consent still active
do $$
declare
  bw_enrolment int;
  zw_enrolment int;
begin
  select count(*) into bw_enrolment from public.enrolments
    where farm_profile_id = 'd1111111-1111-1111-1111-111111111111';
  select count(*) into zw_enrolment from public.enrolments
    where farm_profile_id = 'd2222222-2222-2222-2222-222222222222';

  if bw_enrolment != 1 then
    raise exception 'FAIL: BW officer could not read own institution''s enrolment (got % rows, expected 1)', bw_enrolment;
  end if;

  if zw_enrolment != 0 then
    raise exception 'FAIL: BW officer read a Zimbabwean enrolment (got % rows, expected 0) — cross-border breach', zw_enrolment;
  end if;

  raise notice 'PASS: BW officer sees own-institution enrolment only, ZW enrolment denied';
end $$;

-- Scenario 3: district with 1 enrolment is suppressed / bucketed, not shown as 1
do $$
declare
  serowe_id uuid := 'e1111111-1111-1111-1111-111111111111';
  exposed_count int;
  bucketed_count int;
begin
  select count(*) into exposed_count
  from public.institution_programme_district_distribution(
    'b1111111-1111-1111-1111-111111111111',
    'c1111111-1111-1111-1111-111111111111'
  )
  where district_id = serowe_id;

  if exposed_count != 0 then
    raise exception 'FAIL: district with 1 enrolment was returned by district_id (got % rows) — small-cell disclosure', exposed_count;
  end if;

  select coalesce(sum(enrolled_count), 0) into bucketed_count
  from public.institution_programme_district_distribution(
    'b1111111-1111-1111-1111-111111111111',
    'c1111111-1111-1111-1111-111111111111'
  )
  where district_id is null;

  if bucketed_count != 1 then
    raise exception 'FAIL: suppressed district count was not bucketed correctly (got %, expected 1)', bucketed_count;
  end if;

  raise notice 'PASS: district with 1 enrolment is suppressed from per-district breakdown, bucketed instead';
end $$;

-- Scenario 2: withdrawing consent removes institution read access
reset role;  -- back to the seeding role, which bypasses RLS, to perform the write

update public.consents
  set withdrawn_at = now()
  where farm_profile_id = 'd1111111-1111-1111-1111-111111111111'
    and programme_id = 'b1111111-1111-1111-1111-111111111111';

set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', true);

do $$
declare
  visible_after_withdrawal int;
begin
  select count(*) into visible_after_withdrawal
  from public.enrolments
  where farm_profile_id = 'd1111111-1111-1111-1111-111111111111';

  if visible_after_withdrawal != 0 then
    raise exception 'FAIL: BW officer still reads the enrolment after consent was withdrawn (got % rows, expected 0)', visible_after_withdrawal;
  end if;

  raise notice 'PASS: withdrawing consent removes institution read access to the enrolment';
end $$;

rollback;
