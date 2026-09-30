-- Autoindex: dealers
-- Verified dealership profiles, each tied to the account that manages them.
-- Depends on: 0001_profiles.sql

create table if not exists public.dealers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles (id) on delete set null,
  name text not null,
  location text,
  logo_url text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.dealers enable row level security;

drop policy if exists "Dealers are viewable by everyone" on public.dealers;
create policy "Dealers are viewable by everyone"
  on public.dealers for select
  using (true);

drop policy if exists "Authenticated users can register a dealer" on public.dealers;
create policy "Authenticated users can register a dealer"
  on public.dealers for insert
  with check (auth.uid() = owner_id);

drop policy if exists "Owners can update their own dealer profile" on public.dealers;
create policy "Owners can update their own dealer profile"
  on public.dealers for update
  using (auth.uid() = owner_id);

drop policy if exists "Owners can delete their own dealer profile" on public.dealers;
create policy "Owners can delete their own dealer profile"
  on public.dealers for delete
  using (auth.uid() = owner_id);
