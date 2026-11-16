-- AgroEdge — initial schema
-- Migrated from the Bubble MVP data types (agroedge-v2 app, July 2026).
-- Every table with a farmer/user relationship has RLS enabled in this same
-- migration, per db/CLAUDE.md.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- users
-- Supabase Auth already provides auth.users. This table holds AgroEdge-
-- specific profile fields and is the target of every owner_user FK below.
-- ---------------------------------------------------------------------
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'farmer' check (role in ('farmer', 'institution_officer', 'admin')),
  region text,               -- for institution_officer scoping (district/region access)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.users enable row level security;

create policy users_select_own on public.users
  for select using (auth.uid() = id);

create policy users_update_own on public.users
  for update using (auth.uid() = id);

-- ---------------------------------------------------------------------
-- farm_profiles  (Bubble: FarmProfile)
-- ---------------------------------------------------------------------
create table public.farm_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  farm_name text,
  farm_size numeric,
  farm_type text,
  country text,
  region text,
  gps_lat numeric,
  gps_lng numeric,
  primary_crop text,
  secondary_crop text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.farm_profiles enable row level security;

create policy farm_profiles_owner on public.farm_profiles
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- activities  (Bubble: Activity)
-- ---------------------------------------------------------------------
create table public.activities (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  activity_type text not null,
  crop text,
  activity_date date not null,
  gps_lat numeric,
  gps_lng numeric,
  notes text,
  season_label text,
  yield_quantity numeric,
  yield_unit text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.activities enable row level security;

create policy activities_owner on public.activities
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- activity_files  (Bubble: ActivityFile — used as "photo"/"receipt"/"document"
-- attachment type across Activity, Expense, IncomeRecord)
-- ---------------------------------------------------------------------
create table public.activity_files (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid references public.activities(id) on delete cascade,
  storage_path text not null,   -- Supabase Storage object path, not a public URL
  file_type text,
  created_at timestamptz not null default now()
);

alter table public.activity_files enable row level security;

create policy activity_files_owner on public.activity_files
  for all using (
    exists (
      select 1 from public.activities a
      where a.id = activity_files.activity_id and a.owner_user = auth.uid()
    )
  );

-- ---------------------------------------------------------------------
-- expenses  (Bubble: Expense)
-- ---------------------------------------------------------------------
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  amount numeric not null,
  category text,
  expense_date date not null,
  notes text,
  season_label text,
  receipt_file_id uuid references public.activity_files(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.expenses enable row level security;

create policy expenses_owner on public.expenses
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- income_records  (Bubble: IncomeRecord)
-- ---------------------------------------------------------------------
create table public.income_records (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  crop text,
  buyer text,
  income_date date not null,
  price_per_unit numeric,
  quantity_sold numeric,
  total_revenue numeric,
  season_label text,
  document_file_id uuid references public.activity_files(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.income_records enable row level security;

create policy income_records_owner on public.income_records
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- season_budgets  (Bubble: SeasonBudget)
-- ---------------------------------------------------------------------
create table public.season_budgets (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  season_label text not null,
  category text,
  budget_amount numeric not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.season_budgets enable row level security;

create policy season_budgets_owner on public.season_budgets
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- ai_crop_plans  (Bubble: AiCropPlan)
-- ---------------------------------------------------------------------
create table public.ai_crop_plans (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  crop text,
  priority_action text,
  recommendation_text text,
  created_at timestamptz not null default now()
);

alter table public.ai_crop_plans enable row level security;

create policy ai_crop_plans_owner on public.ai_crop_plans
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- ai_insights  (Bubble: AiInsight)
-- ---------------------------------------------------------------------
create table public.ai_insights (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  category text,
  insight_text text,
  created_at timestamptz not null default now()
);

alter table public.ai_insights enable row level security;

create policy ai_insights_owner on public.ai_insights
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- ai_messages  (Bubble: AiMessage — chat log with the AI agronomist)
-- ---------------------------------------------------------------------
create table public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  sender text not null check (sender in ('farmer', 'ai')),
  message_text text not null,
  created_at timestamptz not null default now()
);

alter table public.ai_messages enable row level security;

create policy ai_messages_owner on public.ai_messages
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- communication_preferences  (Bubble: CommunicationPreference)
-- ---------------------------------------------------------------------
create table public.communication_preferences (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null unique references public.users(id) on delete cascade,
  default_channel text,
  notification_type text,
  email_enabled boolean not null default false,
  sms_enabled boolean not null default false,
  whatsapp_enabled boolean not null default false,
  in_app_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.communication_preferences enable row level security;

create policy communication_preferences_owner on public.communication_preferences
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- notifications  (Bubble: Notification)
-- ---------------------------------------------------------------------
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  notification_type text,
  title text,
  short_message text,
  status text not null default 'pending' check (status in ('pending', 'sent', 'failed', 'read')),
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

create policy notifications_owner on public.notifications
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- notification_delivery_logs  (Bubble: NotificationDeliveryLog)
-- Delivery metadata only. No message content duplicated here.
-- ---------------------------------------------------------------------
create table public.notification_delivery_logs (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid not null references public.notifications(id) on delete cascade,
  channel text not null,
  delivery_status text not null,
  delivered_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.notification_delivery_logs enable row level security;

create policy notification_delivery_logs_owner on public.notification_delivery_logs
  for all using (
    exists (
      select 1 from public.notifications n
      where n.id = notification_delivery_logs.notification_id
        and n.owner_user = auth.uid()
    )
  );

-- ---------------------------------------------------------------------
-- reminders  (Bubble: Reminder)
-- ---------------------------------------------------------------------
create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  related_activity_id uuid references public.activities(id) on delete set null,
  related_crop text,
  title text,
  reminder_datetime timestamptz not null,
  delivery_channel text,
  status text not null default 'scheduled' check (status in ('scheduled', 'sent', 'dismissed', 'cancelled')),
  created_at timestamptz not null default now()
);

alter table public.reminders enable row level security;

create policy reminders_owner on public.reminders
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- weekly_reports  (Bubble: WeeklyReport)
-- ---------------------------------------------------------------------
create table public.weekly_reports (
  id uuid primary key default gen_random_uuid(),
  owner_user uuid not null references public.users(id) on delete cascade,
  report_text text,
  delivery_preference text,
  created_at timestamptz not null default now()
);

alter table public.weekly_reports enable row level security;

create policy weekly_reports_owner on public.weekly_reports
  for all using (auth.uid() = owner_user);

-- ---------------------------------------------------------------------
-- Indexes for the queries the dashboard will actually run
-- ---------------------------------------------------------------------
create index idx_activities_owner_date on public.activities (owner_user, activity_date);
create index idx_expenses_owner_date on public.expenses (owner_user, expense_date);
create index idx_income_records_owner_date on public.income_records (owner_user, income_date);
create index idx_farm_profiles_region on public.farm_profiles (region, country);
create index idx_reminders_owner_datetime on public.reminders (owner_user, reminder_datetime);
