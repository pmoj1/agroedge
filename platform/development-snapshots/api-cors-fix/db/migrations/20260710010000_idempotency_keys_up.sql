-- Backs Idempotency-Key support in services/api (see src/lib/idempotency.ts).
-- The mobile app is offline-first and will retry writes; this table lets a
-- retried write return the original response instead of creating/mutating
-- the row twice.

create table public.idempotency_keys (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  idempotency_key text not null,
  method text not null,
  route text not null,
  request_hash text not null,
  response_status integer not null,
  response_body jsonb,
  created_at timestamptz not null default now(),
  unique (owner_user, method, route, idempotency_key)
);

-- Accessed only by services/api via the service-role key, which bypasses
-- RLS. RLS is enabled anyway, per db/CLAUDE.md, and intentionally carries
-- no policies: if this table is ever queried through an anon/authenticated
-- Supabase client by mistake, the default-deny behaviour means it returns
-- nothing rather than another farmer's cached response bodies.
alter table public.idempotency_keys enable row level security;

create index idx_idempotency_keys_owner_created on public.idempotency_keys (owner_user, created_at);
