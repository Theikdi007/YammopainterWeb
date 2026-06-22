-- ============================================================================
-- Remove the placeholder/sample rows that seed.sql inserted into a previously
-- provisioned database, leaving a clean portal for real content.
--
-- Targeted by the exact seed values so any real rows the operator added are
-- left untouched. Reports how many rows were removed per table.
-- ============================================================================
do $$
declare
  n integer;
begin
  delete from public.posts
    where user_email in ('kid1@example.com', 'artist@example.com', 'gamer@example.com');
  get diagnostics n = row_count; raise notice 'posts deleted: %', n;

  delete from public.user_rewards
    where user_email in ('kid1@example.com', 'artist@example.com');
  get diagnostics n = row_count; raise notice 'user_rewards deleted: %', n;

  delete from public.rewards
    where name in ('Welcome Bonus', 'Master Painter Badge', 'Premium Puzzle Pack');
  get diagnostics n = row_count; raise notice 'rewards deleted: %', n;

  delete from public.notifications
    where title in ('New SVGs added!', 'Weekend painting challenge');
  get diagnostics n = row_count; raise notice 'notifications deleted: %', n;

  delete from public.svg_assets
    where name in ('Cartoon Cat', 'Sunflower', 'Jigsaw Bear');
  get diagnostics n = row_count; raise notice 'svg_assets deleted: %', n;

  delete from public.portal_users
    where email in ('admin@yammo.app', 'editor@yammo.app', 'reviewer@yammo.app');
  get diagnostics n = row_count; raise notice 'portal_users deleted: %', n;
end $$;
