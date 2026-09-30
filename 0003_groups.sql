-- Autoindex: groups
-- Interest-based community hubs, each with an owning creator.
-- Depends on: 0001_profiles.sql

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text,
  cover_image_url text,
  created_by uuid references public.profiles (id) on delete set null,
  member_count integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.groups enable row level security;

drop policy if exists "Groups are viewable by everyone" on public.groups;
create policy "Groups are viewable by everyone"
  on public.groups for select
  using (true);

drop policy if exists "Authenticated users can create groups" on public.groups;
create policy "Authenticated users can create groups"
  on public.groups for insert
  with check (auth.uid() = created_by);

drop policy if exists "Creators can update their own groups" on public.groups;
create policy "Creators can update their own groups"
  on public.groups for update
  using (auth.uid() = created_by);

drop policy if exists "Creators can delete their own groups" on public.groups;
create policy "Creators can delete their own groups"
  on public.groups for delete
  using (auth.uid() = created_by);
