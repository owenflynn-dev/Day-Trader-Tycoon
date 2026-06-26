# Day Trader Tycoon (DTT) — Codebase Audit

_Audit date: 2026-06-25 · Auditor: Claude (Opus 4.8) · Branch: main_

## Scope & method
Static review of the game (`index.html`, ~8,000 lines), Capacitor iOS wrapper, AdMob + IAP
integration (`@capacitor-community/admob`, `cordova-plugin-purchase` v13), and the Supabase
leaderboard schema (`docs/supabase/leaderboard.sql`). No code changed.

## Architecture (as found)
- **Single-file vanilla-JS game**: all logic, markup, and styles live in `index.html`.
  `www/index.html` is a byte-identical copy (the Capacitor `webDir` build target).
- Monetization: rewarded AdMob ads (2× income / offline doubler) + 5 IAP products
  (1 non-consumable starter pack, 4 consumable "Megabucks" packs).
- Optional **global leaderboard** via Supabase REST with the anon key — currently
  **feature-flagged OFF** (`LEADERBOARD_ENABLED` false) and keys are placeholders.

## Headline
Monetization code is careful and correct; the comments show real understanding of the IAP
lifecycle and AdMob's event API. The one genuine hygiene problem is **`node_modules/`
committed to git**. Most other items are maintainability/process, not bugs.

---

## Prioritized findings

### 🔴 High

**H1. `node_modules/` is committed to git (1,892 files) and not in `.gitignore`.**
`.gitignore` only lists `.DS_Store` and `.playwright-mcp/`. The entire dependency tree is
tracked, which bloats the repo (`.git` is 32 MB), pollutes diffs, and lets vendored deps
drift from `package-lock.json`. **Fix (safe, going-forward):** add `node_modules/`,
`ios/App/Pods/`, and build dirs to `.gitignore`, then `git rm -r --cached node_modules` and
commit. This stops tracking without deleting your working files. (History still contains the
blobs; a full `git filter-repo` purge is optional and riskier — flagged for Step 4, with your
go-ahead before any git operation.)

### 🟠 Medium

**M1. IAP uses client-side receipt verification only.**
The flow `approved → transaction.verify() → finish() → deliver` is correct and the code
comment explicitly acknowledges client-side is "sufficient for a game of this scale," with a
documented hook to swap in a server `fetch()`. Acceptable for a single-player game **today**,
but note: once the leaderboard goes live, locally-granted currency (and trivially-editable
`localStorage` state) means the board is inherently spoofable. If leaderboard integrity ever
matters, follow the **upgrade path already written in `leaderboard.sql`** (Supabase Anonymous
Auth + row-bound RLS) and consider server-side receipt validation then.

**M2. Single 8,000-line `index.html`.**
Everything (state, rendering, monetization, save system) is inline. It works and is
well-commented, but it's the project's biggest maintainability risk — hard to test, easy to
introduce cross-cutting regressions. **Recommendation:** if/when touched, extract the
monetization module and the save/state system into separate `<script src>` files. Not urgent.

**M3. No automated tests, and no test harness.**
`package.json` has no test script; there are zero asserts in the game. The save/migration
logic and the IAP delivery/double-award guards (`_deliverIAPProduct`) are the highest-value
candidates for unit tests — they handle money and edge cases (restore, cancel, double-tap).

### 🟡 Low

**L1. `www/index.html` is a byte-identical duplicate of root `index.html`.**
Two copies must be kept in sync by hand. Confirm which is the source of truth; ideally the
build step copies root→www (or `webDir` points at root) so there's a single edited file.

**L2. `.gitignore` is missing standard entries.**
Beyond `node_modules/`: `ios/App/Pods/`, `ios/App/build/`, `.vercel`, `*.log`. Folded into H1's
fix and the Step 4 consistency sweep.

**L3. Two copies of a 596 KB `app-icon-1024.png` are tracked** (`assets/` and the iOS
asset catalog). Minor; expected for iOS, just noting the duplication.

---

## Explicitly checked and CLEAN ✅
- **AdMob ships real ad units in production** — `ADMOB_TEST_MODE = false`; Google's test unit
  IDs are only used when the flag is on. Correct.
- **No real secrets exposed** — `SUPABASE_URL`/`SUPABASE_ANON_KEY` are `YOUR_PROJECT_REF`
  placeholders; leaderboard is gated off. No API keys in source.
- **IAP lifecycle is correct** — registers products, verifies, finishes consumables, handles
  cancel/unverified/error, resets the double-tap guard, and implements `restorePurchases`
  (Apple requirement). Double-award and restore edge cases are explicitly handled.
- **Leaderboard SQL is genuinely well-designed** — documented threat model, CHECK constraints
  (score ceiling cuts off forged Infinity), `security definer` guard trigger enforcing
  monotonic scores + immutable identity + per-row rate limit, and RLS with no anon DELETE.

## Suggested order if we proceed to fixes (Step 2)
1. H1 — `.gitignore` + `git rm --cached node_modules` (with your OK before the git step).
2. L1 — resolve the `index.html` / `www` duplication into one source of truth.
3. M3 — add a minimal test harness; first tests on IAP delivery + save migration.
4. M2 — begin extracting the monetization/save modules out of `index.html`.
