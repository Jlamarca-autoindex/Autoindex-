# Autoindex — Supabase setup

This scaffold wires Supabase auth/session handling into a Next.js App Router
project, following the steps you provided.

## What's here

- `package.json` — includes `@supabase/supabase-js` and `@supabase/ssr`
- `.env.local` — your project URL + publishable key
- `utils/supabase/server.ts` — Supabase client for Server Components
- `utils/supabase/client.ts` — Supabase client for Client Components
- `utils/supabase/middleware.ts` — session-refresh helper
- `middleware.ts` — root middleware that actually invokes the helper above
  on every request (this file wasn't in your pasted snippet but is required —
  without it the middleware helper is never called and sessions won't refresh)
- `app/page.tsx` — queries `listings` joined with `profiles` and renders them
- `tsconfig.json` — adds the `@/*` path alias the Supabase imports rely on
- `supabase/migrations/` — one file per table, in dependency order:
  - `0001_profiles.sql` — `profiles` + RLS + the auto-create-on-signup trigger
  - `0002_listings.sql` — `listings` + RLS + an `updated_at` trigger
  - `0003_groups.sql` — `groups` + RLS
  - `0004_dealers.sql` — `dealers` + RLS
  - `0005_valuation_series.sql` — `valuation_series` + RLS
  - `0006_notifications.sql` — `notifications` + RLS

## Running it

This container has no network access, so I couldn't run `npm install` or the
skills command for you. On your machine:

```
npm install
npx skills add supabase/agent-skills   # optional
npm run dev
```

## Applying the migrations

Run the six files in `supabase/migrations/` **in order** (0001 through 0006)
in the Supabase SQL editor, or `supabase db push` if you're using the CLI —
`0002` through `0006` all reference `profiles.id`, so `0001` has to go first.
`app/page.tsx` queries `listings` and `profiles` directly, so the app will
error until at least those two exist. Each file is safe to re-run on its own
if you need to.

## What's stubbed vs. wired up

`profiles` and `listings` are queried from `app/page.tsx`. `groups`, `dealers`,
`valuation_series`, and `notifications` now have tables and RLS policies, but
nothing in the app queries them yet — `valuation_series` and `notifications`
are designed to be written by a backend job using the service role key rather
than by end users directly, so no client-side insert code is needed for those
until that job exists. Say the word when you want pages wired up against any
of these.
