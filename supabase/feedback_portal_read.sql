-- ============================================================================
-- Portal read access for the mobile `feedback` table
--
-- The mobile app already created public.feedback. Its RLS lets a user INSERT
-- their own feedback but has NO select policy on purpose, so the rows are only
-- reachable with the service-role key.
--
-- The admin portal, however, is a Flutter web client: it signs in with Supabase
-- auth (so it runs as the `authenticated` role) and uses the public ANON key —
-- it can NOT safely hold a service-role key. Without a SELECT policy the portal
-- gets an empty list. This script adds the read + realtime access it needs.
--
-- Run in the Supabase Dashboard -> SQL Editor (idempotent; safe to re-run).
-- ============================================================================

-- 1) Let signed-in portal users read every feedback row.
--    NOTE: mobile + portal share one Supabase project, so this also lets any
--    authenticated app user read feedback — the same posture as the portal's
--    other tables in schema.sql. To restrict reads to registered portal admins
--    only, use the commented "admin-only" variant below INSTEAD of this one.
drop policy if exists "feedback_portal_read" on public.feedback;
create policy "feedback_portal_read"
  on public.feedback
  for select
  to authenticated
  using (true);

-- 1b) (OPTIONAL, tighter) Admin-only read — replaces the policy above.
--     Only users whose email is an active row in portal_users can read.
--     Requires portal_users to contain each admin's auth email.
--
-- drop policy if exists "feedback_portal_read" on public.feedback;
-- create policy "feedback_portal_read"
--   on public.feedback
--   for select
--   to authenticated
--   using (
--     exists (
--       select 1 from public.portal_users pu
--       where lower(pu.email) = lower(auth.jwt() ->> 'email')
--         and pu.is_active
--     )
--   );

-- 2) Stream live feedback into the portal (the list uses .stream()).
do $$
begin
  alter publication supabase_realtime add table public.feedback;
exception
  when duplicate_object then null; -- already in the publication
end $$;
