-- AgroEdge — institutional layer
-- Adds the tenant dimension the business model depends on: which institution
-- is paying for which enrolled farmer, in which programme and season.
-- Proposed in GitHub issue #6 ("Institutional layer missing from schema");
-- table shapes follow that issue's resolution thread — Aone's comment there
-- settled aggregates-only dashboard access, standalone seasons, consents as
-- their own audited table, and verifications as their own audited table.
--
-- Every table in this migration has RLS enabled in this same migration, per
-- db/CLAUDE.md.
--
-- RLS design notes:
--   * Institution users get ZERO row-level access to farm_profiles. The only
--     institutional read path to farmer-linked data is a set of SECURITY
--     DEFINER aggregate functions (institution_programme_overview,
--     institution_programme_district_distribution) whose return types have
--     no farmer-identifying column. This is a structural guarantee, not a
--     policy choice.
--   * institution_programme_district_distribution enforces a minimum cell
--     size of 5 enrolments per district; districts below that are pooled
--     into a single district_id = null "other" bucket so a small district
--     can never identify an individual farmer.
--   * Every institution-side policy that exposes a farmer-linked row
--     (enrolments, verifications) requires an active, unwithdrawn consent
--     for that farmer + programme via has_active_consent() /
--     enrolment_has_active_consent(). consents_select_institution_member is
--     deliberately NOT gated on its own active-consent state — an officer
--     must be able to see a withdrawal event to know to stop processing.
--   * Cross-table checks between programmes and enrolments (and, for
--     verifications, the enrolments/programmes pair) are routed through
--     SECURITY DEFINER helper functions rather than raw joins in a policy's
--     USING clause. Postgres does not inline SECURITY DEFINER functions, so
--     the table access inside them runs under the function owner and never
--     gets the caller's RLS quals reattached — this is what breaks the
--     programmes <-> enrolments mutual-recursion risk, not just avoids it.

-- ---------------------------------------------------------------------
-- institutions
-- The paying tenant: a government ministry, an NGO, a development funder.
-- ---------------------------------------------------------------------
create table public.institutions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  country_code text not null check (country_code ~ '^[A-Z]{2}$'),
  institution_type text not null check (institution_type in ('government', 'ngo', 'funder')),
  data_region text not null,   -- hosting/storage region for this tenant's data; configuration, never hardcoded
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.institutions enable row level security;

-- ---------------------------------------------------------------------
-- programmes  (what an institution actually contracts for)
-- ---------------------------------------------------------------------
create table public.programmes (
  id uuid primary key default gen_random_uuid(),
  institution_id uuid not null references public.institutions(id) on delete cascade,
  name text not null,
  country_code text not null check (country_code ~ '^[A-Z]{2}$'),
  starts_on date not null,
  ends_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.programmes enable row level security;

-- ---------------------------------------------------------------------
-- seasons  (standalone per issue #6 — shared across programmes within a
-- country, not owned by a single programme)
-- ---------------------------------------------------------------------
create table public.seasons (
  id uuid primary key default gen_random_uuid(),
  country_code text not null check (country_code ~ '^[A-Z]{2}$'),
  name text not null,
  starts_on date not null,
  ends_on date not null,
  created_at timestamptz not null default now(),
  unique (country_code, name)
);

alter table public.seasons enable row level security;

-- ---------------------------------------------------------------------
-- districts  (administrative geography, self-referential)
-- ---------------------------------------------------------------------
create table public.districts (
  id uuid primary key default gen_random_uuid(),
  country_code text not null check (country_code ~ '^[A-Z]{2}$'),
  name text not null,
  parent_id uuid references public.districts(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.districts enable row level security;

-- ---------------------------------------------------------------------
-- enrolments  (farmer x programme x season — the invoice line)
-- district_id is nullable: registry-sourced enrolments can arrive without a
-- confirmed district and get located later.
-- unique is (farm_profile_id, programme_id, season_id), not
-- (farm_profile_id, season_id): seasons are now shared across programmes in
-- a country, so a farmer must be able to hold concurrent enrolments in two
-- different programmes within the same season. A one-programme-per-season
-- cap, if ever wanted, is a deliberate application rule, not a side effect
-- of this constraint.
-- ---------------------------------------------------------------------
create table public.enrolments (
  id uuid primary key default gen_random_uuid(),
  farm_profile_id uuid not null references public.farm_profiles(id) on delete cascade,
  programme_id uuid not null references public.programmes(id) on delete restrict,
  season_id uuid not null references public.seasons(id) on delete restrict,
  district_id uuid references public.districts(id) on delete set null,
  status text not null default 'pending' check (status in ('pending', 'active', 'withdrawn', 'flagged')),
  enrolled_at timestamptz not null default now(),
  verified_at timestamptz,   -- denormalized from verifications.verified_at; not the source of truth
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (farm_profile_id, programme_id, season_id)
);

alter table public.enrolments enable row level security;

-- ---------------------------------------------------------------------
-- institution_users  (programme officers — distinct from farmers)
-- ---------------------------------------------------------------------
create table public.institution_users (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  institution_id uuid not null references public.institutions(id) on delete cascade,
  role text not null default 'officer' check (role in ('admin', 'officer', 'read_only')),
  created_at timestamptz not null default now(),
  unique (user_id, institution_id)
);

alter table public.institution_users enable row level security;

-- ---------------------------------------------------------------------
-- consents  (lawful basis for processing — own audited table, not a column
-- on enrolments. Required by Botswana DPA 2024, Zimbabwe CDPA 2021, Kenya
-- DPA 2019; see issue #6, open question 3.)
-- ---------------------------------------------------------------------
create table public.consents (
  id uuid primary key default gen_random_uuid(),
  farm_profile_id uuid not null references public.farm_profiles(id) on delete cascade,
  programme_id uuid not null references public.programmes(id) on delete restrict,
  consent_text_version text not null,
  channel text not null check (channel in ('in_person', 'sms', 'app', 'ussd')),
  granted_at timestamptz not null default now(),
  withdrawn_at timestamptz,
  recorded_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.consents enable row level security;

-- ---------------------------------------------------------------------
-- verifications  (ghost-farmer control — full audit record, not just a
-- timestamp. See issue #6, open question 4.)
-- ---------------------------------------------------------------------
create table public.verifications (
  id uuid primary key default gen_random_uuid(),
  enrolment_id uuid not null references public.enrolments(id) on delete cascade,
  verified_by uuid references public.institution_users(id) on delete set null,
  method text not null check (method in ('field_visit', 'phone_call', 'document_check', 'satellite')),
  outcome text not null check (outcome in ('confirmed', 'flagged', 'rejected')),
  notes text,
  verified_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.verifications enable row level security;

-- ---------------------------------------------------------------------
-- RLS / aggregate helper functions
-- All are SECURITY DEFINER with a pinned search_path: this bypasses RLS on
-- the tables they read internally (breaking any policy-recursion risk,
-- since SECURITY DEFINER functions are never inlined by the planner) and
-- prevents search_path hijacking. Each is revoked from PUBLIC and granted
-- only to authenticated.
-- ---------------------------------------------------------------------

create or replace function public.auth_institution_ids()
returns setof uuid
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select institution_id
  from public.institution_users
  where user_id = auth.uid();
$$;

revoke all on function public.auth_institution_ids() from public;
grant execute on function public.auth_institution_ids() to authenticated;

create or replace function public.programme_institution_id(p_programme_id uuid)
returns uuid
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select institution_id from public.programmes where id = p_programme_id;
$$;

revoke all on function public.programme_institution_id(uuid) from public;
grant execute on function public.programme_institution_id(uuid) to authenticated;

create or replace function public.farmer_is_enrolled_in_programme(p_programme_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.enrolments e
    join public.farm_profiles fp on fp.id = e.farm_profile_id
    where e.programme_id = p_programme_id
      and fp.owner_user = auth.uid()
  );
$$;

revoke all on function public.farmer_is_enrolled_in_programme(uuid) from public;
grant execute on function public.farmer_is_enrolled_in_programme(uuid) to authenticated;

create or replace function public.has_active_consent(p_farm_profile_id uuid, p_programme_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.consents c
    where c.farm_profile_id = p_farm_profile_id
      and c.programme_id = p_programme_id
      and c.withdrawn_at is null
  );
$$;

revoke all on function public.has_active_consent(uuid, uuid) from public;
grant execute on function public.has_active_consent(uuid, uuid) to authenticated;

create or replace function public.enrolment_institution_id(p_enrolment_id uuid)
returns uuid
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select p.institution_id
  from public.enrolments e
  join public.programmes p on p.id = e.programme_id
  where e.id = p_enrolment_id;
$$;

revoke all on function public.enrolment_institution_id(uuid) from public;
grant execute on function public.enrolment_institution_id(uuid) to authenticated;

create or replace function public.enrolment_has_active_consent(p_enrolment_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.enrolments e
    join public.consents c
      on c.farm_profile_id = e.farm_profile_id
      and c.programme_id = e.programme_id
    where e.id = p_enrolment_id
      and c.withdrawn_at is null
  );
$$;

revoke all on function public.enrolment_has_active_consent(uuid) from public;
grant execute on function public.enrolment_has_active_consent(uuid) to authenticated;

-- The only institutional read path to farmer-linked data. Aggregate-only:
-- the return type carries no farmer-identifying column, so the database is
-- structurally incapable of returning an individual farmer record here.
create or replace function public.institution_programme_overview(
  p_programme_id uuid,
  p_season_id uuid
)
returns table (
  enrolled_count bigint,
  verified_count bigint,
  unverified_count bigint,
  hectares_under_plan numeric
)
language sql
security definer
stable
set search_path = public, pg_temp
as $$
  select
    count(*) as enrolled_count,
    count(*) filter (where e.verified_at is not null) as verified_count,
    count(*) filter (where e.verified_at is null) as unverified_count,
    coalesce(sum(fp.farm_size), 0) as hectares_under_plan
  from public.enrolments e
  join public.farm_profiles fp on fp.id = e.farm_profile_id
  where e.programme_id = p_programme_id
    and e.season_id = p_season_id
    and e.status = 'active'
    and public.programme_institution_id(e.programme_id) in (select public.auth_institution_ids())
    and public.has_active_consent(e.farm_profile_id, e.programme_id);
$$;

revoke all on function public.institution_programme_overview(uuid, uuid) from public;
grant execute on function public.institution_programme_overview(uuid, uuid) to authenticated;

-- District breakdown with a minimum-cell-size guard: any district with
-- fewer than min_cell_size active enrolments is pooled into a single
-- district_id = null "other" row rather than shown individually, so a
-- sparsely-enrolled district can never single out a specific farmer.
create or replace function public.institution_programme_district_distribution(
  p_programme_id uuid,
  p_season_id uuid
)
returns table (
  district_id uuid,
  enrolled_count bigint
)
language plpgsql
security definer
stable
set search_path = public, pg_temp
as $$
declare
  min_cell_size constant int := 5;
begin
  return query
  with counts as (
    select
      e.district_id as d_id,
      count(*) as d_count
    from public.enrolments e
    where e.programme_id = p_programme_id
      and e.season_id = p_season_id
      and e.status = 'active'
      and public.programme_institution_id(e.programme_id) in (select public.auth_institution_ids())
      and public.has_active_consent(e.farm_profile_id, e.programme_id)
    group by e.district_id
  )
  select d_id, d_count from counts where d_count >= min_cell_size
  union all
  select null::uuid, sum(d_count) from counts where d_count < min_cell_size
  having sum(d_count) > 0;
end;
$$;

revoke all on function public.institution_programme_district_distribution(uuid, uuid) from public;
grant execute on function public.institution_programme_district_distribution(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------
-- RLS policies
-- ---------------------------------------------------------------------

-- institutions: visible only to your own institution's members.
create policy institutions_select_member on public.institutions
  for select using (id in (select public.auth_institution_ids()));

-- programmes: visible to the owning institution's officers, and to a
-- farmer who has ever been enrolled in it.
create policy programmes_select_institution_member on public.programmes
  for select using (institution_id in (select public.auth_institution_ids()));

create policy programmes_select_enrolled_farmer on public.programmes
  for select using (public.farmer_is_enrolled_in_programme(programmes.id));

-- seasons and districts carry no personal data — shared reference data,
-- readable by any authenticated user.
create policy seasons_select_authenticated on public.seasons
  for select using (auth.uid() is not null);

create policy districts_select_authenticated on public.districts
  for select using (auth.uid() is not null);

-- enrolments: the isolation boundary the compliance story rests on. A
-- farmer sees their own enrolment; an institution officer sees an enrolment
-- only if it belongs to one of their own institution's programmes AND the
-- farmer's consent for that programme is still active.
create policy enrolments_select_own_farmer on public.enrolments
  for select using (
    exists (
      select 1 from public.farm_profiles fp
      where fp.id = enrolments.farm_profile_id
        and fp.owner_user = auth.uid()
    )
  );

create policy enrolments_select_institution_member on public.enrolments
  for select using (
    public.programme_institution_id(enrolments.programme_id) in (select public.auth_institution_ids())
    and public.has_active_consent(enrolments.farm_profile_id, enrolments.programme_id)
  );

-- institution_users: officers can see their own institution's directory,
-- never another institution's.
create policy institution_users_select_member on public.institution_users
  for select using (institution_id in (select public.auth_institution_ids()));

-- consents: farmer sees their own consent history; institution officer sees
-- consents recorded against their own institution's programmes. Not gated
-- on its own active-consent state — an officer must see a withdrawal event
-- to know to stop processing that farmer.
create policy consents_select_own_farmer on public.consents
  for select using (
    exists (
      select 1 from public.farm_profiles fp
      where fp.id = consents.farm_profile_id
        and fp.owner_user = auth.uid()
    )
  );

create policy consents_select_institution_member on public.consents
  for select using (
    exists (
      select 1 from public.programmes p
      where p.id = consents.programme_id
        and p.institution_id in (select public.auth_institution_ids())
    )
  );

-- verifications: same shape as enrolments — farmer sees their own, officer
-- sees their own institution's, gated on active consent.
create policy verifications_select_own_farmer on public.verifications
  for select using (
    exists (
      select 1
      from public.enrolments e
      join public.farm_profiles fp on fp.id = e.farm_profile_id
      where e.id = verifications.enrolment_id
        and fp.owner_user = auth.uid()
    )
  );

create policy verifications_select_institution_member on public.verifications
  for select using (
    public.enrolment_institution_id(verifications.enrolment_id) in (select public.auth_institution_ids())
    and public.enrolment_has_active_consent(verifications.enrolment_id)
  );

-- No policy is added to farm_profiles or ai_messages in this migration.
-- farm_profiles: institution users get zero row-level access — see
-- institution_programme_overview / institution_programme_district_distribution
-- above. ai_messages keeps its farmer-only policy from the init migration —
-- a farmer's conversation with the AI agronomist is not programme data.

-- ---------------------------------------------------------------------
-- Indexes for the queries the institutional dashboard will actually run
-- ---------------------------------------------------------------------
create index idx_programmes_institution on public.programmes (institution_id);
create index idx_enrolments_programme_season_status on public.enrolments (programme_id, season_id, status);
create index idx_enrolments_farm_profile on public.enrolments (farm_profile_id);
create index idx_enrolments_district on public.enrolments (district_id);
create index idx_institution_users_user on public.institution_users (user_id);
create index idx_institution_users_institution on public.institution_users (institution_id);
create index idx_consents_farm_profile on public.consents (farm_profile_id);
create index idx_consents_programme on public.consents (programme_id);
create index idx_verifications_enrolment on public.verifications (enrolment_id);
create index idx_districts_parent on public.districts (parent_id);
create index idx_districts_country on public.districts (country_code);
