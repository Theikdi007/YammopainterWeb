-- ============================================================================
-- Fix: notifications — drop & recreate from scratch (schema + RLS + realtime)
--
-- Use this when the notifications table was deleted/recreated and the portal
-- shows errors like:
--   PostgrestException(... Could not find the 'status' column ... PGRST204)
-- or the notification list comes up empty.
--
-- Run the whole block in the Supabase SQL editor (or `supabase db push`).
-- Mirrors the canonical definition in schema.sql.
-- ============================================================================

-- 1. Remove the old table completely (also drops it from the realtime publication).
drop table if exists public.notifications cascade;

-- 2. Recreate with the exact schema the portal code expects.
create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  body         text not null,
  target       text not null default 'all'  check (target in ('all', 'user', 'group')),
  target_value text not null default '',
  status       text not null default 'sent' check (status in ('sent', 'failed', 'scheduled')),
  sent_at      timestamptz not null default now()
);

-- 3. Row Level Security — grant full access to any signed-in user
--    (without a SELECT policy the list returns an empty array).
alter table public.notifications enable row level security;

drop policy if exists "authenticated full access" on public.notifications;
create policy "authenticated full access"
  on public.notifications
  for all to authenticated
  using (true) with check (true);

-- 4. Realtime — required for the notification list's .stream() subscription.
alter publication supabase_realtime add table public.notifications;

-- 5. Refresh the PostgREST schema cache (clears the PGRST204 error immediately).
notify pgrst, 'reload schema';
