-- Autoindex: valuation_series
-- Time-series pricing data behind the Auto-Ticker charts. This is market
-- data compiled by Autoindex, not user-generated content, so there's no
-- public insert/update policy — writes are expected to come from a backend
-- job using the service role key, which bypasses RLS entirely.

create table if not exists public.valuation_series (
  id uuid primary key default gen_random_uuid(),
  model_name text not null,
  as_of_date date not null,
  price numeric(12, 2) not null,
  created_at timestamptz not null default now(),
  unique (model_name, as_of_date)
);

create index if not exists valuation_series_model_name_idx on public.valuation_series (model_name);

alter table public.valuation_series enable row level security;

drop policy if exists "Valuation data is viewable by everyone" on public.valuation_series;
create policy "Valuation data is viewable by everyone"
  on public.valuation_series for select
  using (true);
