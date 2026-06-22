-- ============================================================================
-- Yammo Admin Portal — Supabase schema
-- Run this in the Supabase SQL editor (or `supabase db push`) to provision the
-- tables, storage bucket and policies the portal expects.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Portal users (admins / editors of the portal itself)
-- ---------------------------------------------------------------------------
create table if not exists public.portal_users (
  id          uuid primary key default gen_random_uuid(),
  email       text unique not null,
  full_name   text not null default '',
  role        text not null default 'editor' check (role in ('admin', 'editor')),
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- SVG assets (Drawing / Painting / Puzzle images)
-- ---------------------------------------------------------------------------
create table if not exists public.svg_assets (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text not null default '',
  category    text not null check (category in ('Drawing', 'Painting', 'Puzzle')),
  target_app  text not null,
  file_path   text not null,
  public_url  text not null default '',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Notifications history
-- ---------------------------------------------------------------------------
create table if not exists public.notifications (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  body         text not null,
  target       text not null default 'all' check (target in ('all', 'user', 'group')),
  target_value text not null default '',
  status       text not null default 'sent' check (status in ('sent', 'failed', 'scheduled')),
  sent_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Rewards
-- ---------------------------------------------------------------------------
create table if not exists public.rewards (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text not null default '',
  points      integer not null default 0,
  type        text not null default 'coins' check (type in ('coins', 'badge', 'unlock')),
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- User rewards (grants to individual app users)
-- ---------------------------------------------------------------------------
create table if not exists public.user_rewards (
  id          uuid primary key default gen_random_uuid(),
  user_email  text not null,
  reward_name text not null,
  points      integer not null default 0,
  status      text not null default 'granted' check (status in ('granted', 'redeemed')),
  awarded_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Community posts
-- ---------------------------------------------------------------------------
create table if not exists public.posts (
  id             uuid primary key default gen_random_uuid(),
  user_name      text not null default 'Unknown',
  user_email     text not null default '',
  image_url      text not null default '',
  description    text not null default '',
  likes_count    integer not null default 0,
  comments_count integer not null default 0,
  status         text not null default 'active' check (status in ('active', 'reported', 'removed')),
  created_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Storage bucket for SVG files
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('svg_assets', 'svg_assets', true)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- Portal data should only be reachable by authenticated admins. These policies
-- grant full access to any signed-in user; tighten them (e.g. check a role in
-- portal_users) for production.
-- ---------------------------------------------------------------------------
alter table public.portal_users  enable row level security;
alter table public.svg_assets    enable row level security;
alter table public.notifications enable row level security;
alter table public.rewards       enable row level security;
alter table public.user_rewards  enable row level security;
alter table public.posts         enable row level security;

do $$
declare
  t text;
begin
  foreach t in array array[
    'portal_users', 'svg_assets', 'notifications',
    'rewards', 'user_rewards', 'posts'
  ]
  loop
    begin
      execute format(
        'create policy "authenticated full access" on public.%I
           for all to authenticated using (true) with check (true);', t);
    exception
      when duplicate_object then null; -- policy already exists
    end;
  end loop;
end $$;

-- Allow authenticated users to manage objects in the svg_assets bucket.
-- (drop-if-exists keeps this re-runnable; storage.objects has no `create policy if not exists`.)
drop policy if exists "svg read"   on storage.objects;
create policy "svg read"   on storage.objects for select to authenticated using (bucket_id = 'svg_assets');
drop policy if exists "svg write"  on storage.objects;
create policy "svg write"  on storage.objects for insert to authenticated with check (bucket_id = 'svg_assets');
drop policy if exists "svg update" on storage.objects;
create policy "svg update" on storage.objects for update to authenticated using (bucket_id = 'svg_assets');
drop policy if exists "svg delete" on storage.objects;
create policy "svg delete" on storage.objects for delete to authenticated using (bucket_id = 'svg_assets');

-- ---------------------------------------------------------------------------
-- Realtime
-- Add every table to the `supabase_realtime` publication so the portal receives
-- live INSERT/UPDATE/DELETE events. Safe to run more than once.
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array[
    'portal_users', 'svg_assets', 'notifications',
    'rewards', 'user_rewards', 'posts'
  ]
  loop
    begin
      execute format(
        'alter publication supabase_realtime add table public.%I', t);
    exception
      when duplicate_object then null; -- already in the publication
    end;
  end loop;
end $$;
