-- Autoindex: notifications
-- Per-user notifications. Like valuation_series, these are system-generated
-- rather than user-authored, so only select/update-as-read policies exist
-- for end users; inserts are expected from a backend using the service role.
-- Depends on: 0001_profiles.sql

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('price', 'reply', 'message', 'like', 'group')),
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_id_idx on public.notifications (user_id);

alter table public.notifications enable row level security;

drop policy if exists "Users can view their own notifications" on public.notifications;
create policy "Users can view their own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

drop policy if exists "Users can mark their own notifications as read" on public.notifications;
create policy "Users can mark their own notifications as read"
  on public.notifications for update
  using (auth.uid() = user_id);
