# Day Trader Tycoon — Project Guide

Wall Street satire **idle / incremental clicker game**, shipped on the iOS App Store
(App ID 6769673373, bundle `com.owenflynndev.daytradertycoon`). Solo dev: Owen Flynn.

> **Audit pass (2026-06-25, Claude) — full report in `docs/AUDIT.md`.** Headline: monetization
> code is careful and correct (IAP lifecycle, AdMob ships real units, leaderboard SQL well-designed).
> Applied this pass: **hardened `.gitignore` + untracked `node_modules`** (1,892 files were committed;
> removed from the index, working files intact — change is **staged, not committed**, since `main` had
> other uncommitted work). Open: resolve the `index.html`↔`www/index.html` duplication into one source
> of truth; add the planned boot/economy tests.

## Architecture (read this first)

This is a **single-file web game wrapped in Capacitor for iOS**. There is no framework, no
bundler, no build step beyond a file copy.

- **`index.html`** — the ENTIRE app (~8,000 lines: HTML + CSS + all game JS inline). **This is the
  source of truth.** Edit here.
- **`www/index.html`** — a *copy* of the root `index.html`; this is Capacitor's `webDir`. Never edit
  directly — it's overwritten by the sync step.
- **`ios/App/`** — the native iOS wrapper (Xcode project). `App.xcworkspace` is what you open.
  Web assets are copied into `ios/App/App/public/` by `cap sync`/`cap copy`.

### Build / sync / run
```bash
npm run sync        # = cp index.html www/index.html && npx cap sync   (run after EVERY index.html edit)
npx cap copy ios    # faster: just re-copies web assets into the iOS project
```
Open `ios/App/App.xcworkspace` in Xcode to run/archive. Device builds need **Any iOS Device (arm64)**.

There is **no `index.html` → `www` automation** other than `npm run sync`. If you edit `index.html`
and forget to sync, the app won't reflect your change. (The CSS/logic both live in `index.html`.)

## Code map (search by name — line numbers drift)

- **Game state**: `let state = {...}` — one big mutable object. Currencies (`cash`, `gold`, `yen`,
  `gbp`), per-asset map `state.assets[id] = {owned, progress, hired, speedLevel, payoutLevel}`,
  plus unlocks/quests/skills/boosts/prestige fields.
- **Save/load**: `const SAVE_KEY = 'dayTraderTycoonSave_v1'`; `save()` persists a *subset* to
  localStorage, `load()` restores. Most progression is derived, not stored — see `save()` for the
  exact persisted fields. Offline earnings use `lastSavedAt`.
- **Game loop**: `tick()` runs every 100ms (`setInterval(tick, 100)`); `boot()` at end of file
  bootstraps everything.
- **Rendering**: `renderAll()` (= `renderCash()` + `renderAssets()`), plus per-tab renderers
  (`renderManagersTab`, `renderOptionsTab`, `renderSkillTree`, etc.). Navigation: `switchTab(name)`,
  `openNav()`/`closeNav()`. Header values set inside `renderCash()`.
- **Economy math (pure, the high-value stuff)**: `costOf` (16% growth via `COST_GROWTH`),
  `payoutOf`, `marketMult`/`globalMult`, `milestoneMultOf` (`MILESTONE_MULT = 1.5`), speed
  milestones, `totalIncomePerSec`, prestige/influence gain.
- **Content arrays**: `ASSETS` (Wall St / Tokyo / London assets), `EVENTS`, `BOOSTS`, `HFT_PERKS`,
  `MILESTONES`, `INFLUENCE_SHOP`, skill tree. To add an asset/event, append to the relevant array.

## Monetization

- **AdMob** rewarded ads via `@capacitor-community/admob`. `const ADMOB_TEST_MODE` toggles test vs.
  real ad units. **⚠️ Must be `false` before any App Store build** — shipping with test mode on, or
  clicking your own real ads, = AdMob account ban. Flip back to `false` + re-sync immediately after testing.
- `GADApplicationIdentifier` lives in `ios/App/App/Info.plist`.
- **`app-ads.txt`** (root of repo + hosted at `https://owenflynn-dev.github.io/app-ads.txt`) — single
  publisher line. AdMob verification needs a **Marketing URL on the App Store listing** pointing at
  that domain (see `docs/app-store/lessons-learned.md`).
- **IAP** (via `cordova-plugin-purchase`): `starter_pack` (non-consumable; also acts as "No Ads")
  plus Megabucks consumable packs `mb_5` / `mb_15` / `mb_50` / `mb_150`. Rewarded ad gives a temporary
  2× income boost. (`gold` is an in-game currency, not an IAP.)

## iOS / App Store essentials

- **Version bumps** live in `ios/App/App.xcodeproj/project.pbxproj` — update **both** the Debug AND
  Release configs: `MARKETING_VERSION` (e.g. 1.0.1) and `CURRENT_PROJECT_VERSION` (build number,
  must increase). A live version is locked; ship changes via a NEW version.
- **App icon**: single 1024×1024, no alpha. Source `assets/app-icon-1024.png` is mirrored into
  `ios/App/App/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png` (that copy is what actually
  ships — it's a native asset, NOT uploaded to App Store Connect separately).
- **Screenshots**: `dtt-app-store-screenshots/` (6.5" display, 1284×2778). Uploaded by hand in ASC.
  First 3 are what show on the search/installation sheet.
- **ATT (App Tracking Transparency)**: the prompt fires in `SceneDelegate` ~1s after launch and MUST
  resolve **before** the first ad request (Apple requirement; this got DTT rejected once). Don't
  reorder this.
- **Safe area**: `capacitor.config.json` uses `contentInset: "never"` + `viewport-fit=cover`, so the
  web content runs under the notch/Dynamic Island. Top UI (`.ticker-wrap`) reserves
  `env(safe-area-inset-top)`; bottom nav reserves `env(safe-area-inset-bottom)`. Keep new edge UI inset.
- **iOS background save**: `beforeunload` is unreliable in WKWebView — saving also happens on
  `visibilitychange` when `document.hidden`. Keep that.

## Common gotchas

1. **Forgot to `npm run sync`** → your `index.html` edit doesn't show in the app.
2. **`ADMOB_TEST_MODE` left `true`** in a release build → ban risk.
3. **Bumped version in only one build config** → archive uses the stale one.
4. **New top/bottom UI without safe-area insets** → clipped by notch / home indicator.

## Docs & memory

- `docs/app-store/lessons-learned.md` — reusable App Store / AdMob / submission gotchas (ATT, IAP,
  app-ads.txt, encryption compliance, etc.). **Read before any submission work.**
- `docs/app-store/rejection-playbook.md`, `docs/launch/` (Supabase leaderboard go-live runbook +
  privacy policy section), `docs/gamecenter-integration-pattern.md` (blueprint for adding Game
  Center), `docs/archive/` (older roadmap/TODO/PLAN + security/IAP/code-review audits),
  `docs/supabase/` (leaderboard SQL).
- Other top-level files: `index.html`, `app-ads.txt`, `capacitor.config.json`, `privacy-policy.html`;
  marketing/icon source art lives in `assets/`; App Store screenshots in `dtt-app-store-screenshots/`.
- Leaderboard: a Supabase global leaderboard is **staged but inert** (consent UI shipped disabled);
  see `docs/launch/leaderboard-go-live-runbook.md`.

## Testing

None yet. Planned: a headless-Chrome **boot smoke test** (no console errors + key screens render)
and **economy/save-load unit tests** that call the global functions in a real browser (zero
production refactor needed, since game functions are globals on `window`).

## Conventions

- Match the existing inline style — vanilla JS, global functions, no modules/TypeScript.
- Currencies/large numbers go through `fmt()`/`fmtNum()`; don't hand-format.
- Commit messages end with the Co-Authored-By trailer. Branch off `main` for risky work; `main` is
  the working branch for this solo repo. Commit/push only when asked.
