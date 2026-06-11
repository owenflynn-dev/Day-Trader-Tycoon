-- ─────────────────────────────────────────────────────────────────────────────
-- Day Trader Tycoon — Global Leaderboard schema (run once when creating the
-- Supabase project, before flipping LEADERBOARD_ENABLED to true in index.html).
--
-- Threat model: the app writes with the public anon key (no user auth), so
-- anyone can POST arbitrary rows. These protections limit the damage:
--   1. RLS — anon can read and upsert, never delete.
--   2. CHECK constraints — score ceiling, sane lengths/formats, no negatives.
--   3. Guard trigger — server-owned timestamps, scores only increase,
--      identity fields immutable, per-row rate limit (one update / 25 s,
--      matching the client's 30 s debounce).
--
-- Hard truth: with only the anon key, a determined cheater can still submit a
-- fake-but-plausible score under a fresh player_id. The ceiling and rate limit
-- stop Infinity-style and spam griefing; full anti-cheat needs Supabase
-- Anonymous Auth (see "Upgrade path" at the bottom).
-- ─────────────────────────────────────────────────────────────────────────────

create table public.leaderboard (
  player_id      text primary key
                 check (player_id ~ '^p_[a-z0-9]{10,40}$'),
  firm_name      text not null default 'Anonymous Firm'
                 check (char_length(firm_name) between 1 and 64),
  -- numeric (not bigint): late-game earnings exceed int8 range.
  -- Ceiling cuts off forged Infinity/1e308 values; raise it if legit
  -- players ever approach it.
  score          numeric not null default 0
                 check (score >= 0 and score <= 1e24),
  prestige_count integer not null default 0
                 check (prestige_count between 0 and 100000),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- The app reads: ?select=...&order=score.desc&limit=50
create index leaderboard_score_idx on public.leaderboard (score desc);

-- ── Guard trigger ────────────────────────────────────────────────────────────
create or replace function public.leaderboard_guard()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Timestamps are server-owned; ignore whatever the client sent.
  new.updated_at := now();
  if tg_op = 'INSERT' then
    new.created_at := now();
    return new;
  end if;

  -- Rate limit: one update per row per 25 s (client debounces at 30 s,
  -- so legit traffic never hits this).
  if old.updated_at > now() - interval '25 seconds' then
    raise exception 'rate limited' using errcode = 'P0001';
  end if;

  -- Identity is immutable; progress only moves forward.
  new.player_id      := old.player_id;
  new.created_at     := old.created_at;
  if new.score < old.score then new.score := old.score; end if;
  if new.prestige_count < old.prestige_count then new.prestige_count := old.prestige_count; end if;
  return new;
end
$$;

create trigger leaderboard_guard
  before insert or update on public.leaderboard
  for each row execute function public.leaderboard_guard();

-- ── Row Level Security ──────────────────────────────────────────────────────
alter table public.leaderboard enable row level security;

-- Anyone may read the board.
create policy "leaderboard_select" on public.leaderboard
  for select using (true);

-- Anon may insert rows that pass the sanity checks (CHECK constraints also
-- apply; duplicated here so policy violations fail before constraint errors).
create policy "leaderboard_insert" on public.leaderboard
  for insert to anon
  with check (
    player_id ~ '^p_[a-z0-9]{10,40}$'
    and char_length(firm_name) between 1 and 64
    and score >= 0 and score <= 1e24
    and prestige_count between 0 and 100000
  );

-- Anon may update (the app upserts with Prefer: resolution=merge-duplicates,
-- which needs both INSERT and UPDATE). The guard trigger enforces
-- monotonicity + rate limiting.
create policy "leaderboard_update" on public.leaderboard
  for update to anon
  using (true)
  with check (
    char_length(firm_name) between 1 and 64
    and score >= 0 and score <= 1e24
    and prestige_count between 0 and 100000
  );

-- No DELETE/TRUNCATE policy → anon cannot remove rows. Use the service role
-- (dashboard / server-side only) for moderation and cleanup.

-- ── Upgrade path: real anti-forgery (post-launch, optional) ─────────────────
-- 1. Enable Anonymous Sign-ins (Auth → Providers) and call
--    supabase.auth.signInAnonymously() in the app.
-- 2. add column user_id uuid not null default auth.uid();
-- 3. Replace the anon insert/update policies with:
--      with check (user_id = auth.uid())  /  using (user_id = auth.uid())
--    granted to the `authenticated` role instead of `anon`.
-- That ties each row to a device-bound auth identity, so players can only
-- ever write their own row.
