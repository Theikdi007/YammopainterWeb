-- ============================================================================
-- Sample data for the Yammo Admin Portal.
-- Run in Supabase → SQL Editor (runs as the postgres role, so RLS is bypassed).
-- Safe to run once; re-running adds duplicate rows.
-- ============================================================================

insert into public.portal_users (email, full_name, role, is_active) values
  ('admin@yammo.app',  'Super Admin',     'admin',  true),
  ('editor@yammo.app', 'Content Editor',  'editor', true),
  ('reviewer@yammo.app','Jane Reviewer',  'editor', false);

insert into public.svg_assets (name, description, category, target_app, file_path, public_url, is_active) values
  ('Cartoon Cat',  'A friendly cat outline for kids.',        'Drawing',  'AR Drawing', 'demo/cat.svg',       '', true),
  ('Sunflower',    'Bright sunflower for painting practice.',  'Painting', 'Painting',   'demo/sunflower.svg', '', true),
  ('Jigsaw Bear',  'Bear shaped puzzle pieces.',               'Puzzle',   'Puzzle',     'demo/bear.svg',      '', false);

insert into public.notifications (title, body, target, target_value, status) values
  ('New SVGs added!',           'Check out 12 new drawings in the AR Drawing app.', 'all',   '',         'sent'),
  ('Weekend painting challenge','Join the weekend challenge and earn 100 coins.',   'group', 'painters', 'sent');

insert into public.rewards (name, description, points, type, is_active) values
  ('Welcome Bonus',        '50 coins for new users.',                 50,  'coins',  true),
  ('Master Painter Badge', 'Awarded after completing 20 paintings.',  0,   'badge',  true),
  ('Premium Puzzle Pack',  'Unlocks an exclusive puzzle pack.',       200, 'unlock', false);

insert into public.user_rewards (user_email, reward_name, points, status) values
  ('kid1@example.com',   'Welcome Bonus',        50,  'granted'),
  ('artist@example.com', 'Master Painter Badge', 0,   'granted'),
  ('kid1@example.com',   'Premium Puzzle Pack',  200, 'redeemed');

insert into public.posts (user_name, user_email, image_url, description, likes_count, comments_count, status) values
  ('Little Picasso', 'kid1@example.com',   'https://picsum.photos/seed/art1/600/400', 'My first AR drawing of a dinosaur!',     124, 18, 'active'),
  ('ColorQueen',     'artist@example.com', 'https://picsum.photos/seed/art2/600/400', 'Sunset painting finished today.',         89,  7, 'reported'),
  ('PuzzleMaster',   'gamer@example.com',  'https://picsum.photos/seed/art3/600/400', 'Completed the 500 piece bear puzzle!',    56,  4, 'active');
