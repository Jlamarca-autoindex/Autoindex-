-- Autoindex: listings
-- Marketplace listings, each owned by a seller (profiles.id).
-- Depends on: 0001_profiles.sql

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  price numeric(12, 2) not null,
  market_price numeric(12, 2),
  mileage integer,
  transmission text check (transmission in ('manual', 'automatic', 'dsg', 'cvt')),
  drivetrain text check (drivetrain in ('fwd', 'rwd', 'awd', '4wd')),
  title_status text not null default 'clean' check (title_status in ('clean', 'salvage', 'rebuilt', 'lien')),
  status text not null default 'active' check (status in ('active', 'pending', 'sold', 'removed')),
  image_url text,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists listings_seller_id_idx on public.listings (seller_id);
create index if not exists listings_status_idx on public.listings (status);

alter table public.listings enable row level security;

drop policy if exists "Active listings are viewable by everyone" on public.listings;
create policy "Active listings are viewable by everyone"
  on public.listings for select
  using (status = 'active' or auth.uid() = seller_id);

drop policy if exists "Sellers can insert their own listings" on public.listings;
create policy "Sellers can insert their own listings"
  on public.listings for insert
  with check (auth.uid() = seller_id);

drop policy if exists "Sellers can update their own listings" on public.listings;
create policy "Sellers can update their own listings"
  on public.listings for update
  using (auth.uid() = seller_id);

drop policy if exists "Sellers can delete their own listings" on public.listings;
create policy "Sellers can delete their own listings"
  on public.listings for delete
  using (auth.uid() = seller_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists listings_set_updated_at on public.listings;
create trigger listings_set_updated_at
  before update on public.listings
  for each row execute procedure public.set_updated_at();
