-- Ein persönlicher Daten-Snapshot pro Konto.
-- Vor dem Anlegen der Tabelle zuerst das öffentliche Schema und RLS prüfen.
create table if not exists public.herzenssache_state (
  user_id uuid primary key references auth.users (id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.herzenssache_state enable row level security;
revoke all on table public.herzenssache_state from anon;
revoke all on table public.herzenssache_state from authenticated;
grant select, insert, update on table public.herzenssache_state to authenticated;

drop policy if exists "Users can read their own Herzenssache data" on public.herzenssache_state;
create policy "Users can read their own Herzenssache data"
  on public.herzenssache_state for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own Herzenssache data" on public.herzenssache_state;
create policy "Users can create their own Herzenssache data"
  on public.herzenssache_state for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own Herzenssache data" on public.herzenssache_state;
create policy "Users can update their own Herzenssache data"
  on public.herzenssache_state for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

