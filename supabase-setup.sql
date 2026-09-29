-- =====================================================================
-- Sarvin Plumbing Works – Supabase setup
-- Project: https://wkntbqgdihhpmxwamwqr.supabase.co
--
-- BEFORE running this file:
--   1. Supabase > Authentication > Users > Add user > Create new user
--        Email:    sarvinplumbing@gmail.com      (must match adminEmail in config.js)
--        Password: Sarvin@2026                  (this is the Admin password on the website)
--        Tick "Auto confirm user"
--   2. Supabase > Authentication > Sign In / Providers:
--        turn OFF "Allow new users to sign up"
--
-- THEN paste this whole file into Supabase > SQL Editor and press Run.
-- It is safe to run again; it only creates what is missing.
-- =====================================================================


-- ---------- 1. Admins list ------------------------------------------
-- Only users listed here can change website content.
create table if not exists public.admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
-- No policies on admins: the table is private (not readable or writable
-- through the public API). Only the is_admin() function below reads it.

-- Add the admin user created in step 1 (change the email if you used another).
insert into public.admins (user_id)
select id from auth.users where lower(email) = lower('sarvinplumbing@gmail.com')
on conflict (user_id) do nothing;

-- Helper used by every policy below.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;


-- ---------- 2. Website content: photos, videos, reviews -------------
create table if not exists public.items (
  id         uuid primary key default gen_random_uuid(),
  kind       text not null check (kind in ('image','video','review')),
  title      text default '',
  src        text,                  -- public file URL (photos/videos)
  path       text,                  -- file path in the storage bucket
  name       text,                  -- reviewer name (reviews)
  stars      int check (stars between 1 and 5),
  when_text  text,                  -- e.g. "2 weeks ago" (reviews)
  body       text,                  -- review text
  position   double precision not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists items_order_idx on public.items (position, created_at desc);

alter table public.items enable row level security;

drop policy if exists "Anyone can read" on public.items;
drop policy if exists "Owner can add" on public.items;
drop policy if exists "Owner can edit" on public.items;
drop policy if exists "Owner can delete" on public.items;
drop policy if exists "items_public_read"  on public.items;
drop policy if exists "items_admin_insert" on public.items;
drop policy if exists "items_admin_update" on public.items;
drop policy if exists "items_admin_delete" on public.items;

create policy "items_public_read" on public.items
  for select to anon, authenticated using (true);
create policy "items_admin_insert" on public.items
  for insert to authenticated with check (public.is_admin());
create policy "items_admin_update" on public.items
  for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "items_admin_delete" on public.items
  for delete to authenticated using (public.is_admin());


-- ---------- 3. File storage for photos and videos -------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('work', 'work', true, 52428800,   -- 50 MB per file
        array['image/jpeg','image/png','image/webp',
              'video/mp4','video/quicktime','video/webm'])
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Anyone can view work files"   on storage.objects;
drop policy if exists "Owner can upload work files"  on storage.objects;
drop policy if exists "Owner can delete work files"  on storage.objects;
drop policy if exists "work_public_read"   on storage.objects;
drop policy if exists "work_admin_insert"  on storage.objects;
drop policy if exists "work_admin_update"  on storage.objects;
drop policy if exists "work_admin_delete"  on storage.objects;

create policy "work_public_read" on storage.objects
  for select to anon, authenticated using (bucket_id = 'work');
create policy "work_admin_insert" on storage.objects
  for insert to authenticated with check (bucket_id = 'work' and public.is_admin());
create policy "work_admin_update" on storage.objects
  for update to authenticated using (bucket_id = 'work' and public.is_admin());
create policy "work_admin_delete" on storage.objects
  for delete to authenticated using (bucket_id = 'work' and public.is_admin());


-- ---------- 4. Check --------------------------------------------------
-- Should return 1 row (your admin). If it returns 0 rows, create the user
-- from step 1 first, then run this file again.
select u.email as admin_email from public.admins a join auth.users u on u.id = a.user_id;
