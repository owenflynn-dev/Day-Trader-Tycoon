# Day Trader Tycoon — Roadmap

*Canonical roadmap. Last updated: 2026-06-18.*
*Supersedes the older planning docs and audits now in [`archive/`](archive/). See those for the full historical detail behind any "shipped" item below.*

---

## Status

The game is **feature-complete and live on the App Store**. **v1.0 / build 9** went live 2026-06-15; **v1.0.1 / build 10** (notch / Dynamic Island safe-area fix + redesigned rocket app icon) was approved and is **Ready for Distribution** as of 2026-06-18. The web build is wrapped with Capacitor for iOS; AdMob and IAP are live in production. The Supabase global leaderboard is **staged but inert** — the consent UI ships disabled, blocked on a Supabase Pro purchase + go-live runbook.

---

## ✅ Shipped

**Core game**
- Three markets shipped: Wall Street, Tokyo, London — each with assets, managers, and currency (a fourth, Black Market, is designed but **disabled in code** — "coming in a future update")
- Options Desk, AI Rivals (with SEC-complaint counter to raids), Chicago Open Outcry Pit
- Prestige / IPO loop, milestones, perks, skills
- Economy rebalance (2026-05-22): `MILESTONE_MULT` 2.0→1.5, `COST_GROWTH` 1.12→1.14, payouts −20%, `prestigeGain()` coefficient 8→5
- Juice: confetti on milestones/prestige, float text on payouts, animated count-up modals

**Monetization & store**
- AdMob rewarded ads — production unit IDs, `ADMOB_TEST_MODE = false`, `app-ads.txt` deployed at the GitHub Pages root. **Verification pending**: AdMob needs the App Store **Marketing URL** pointing at the app-ads.txt domain (added 2026-06-18 — will verify once v1.0.1 is live). See [`app-store/lessons-learned.md`](app-store/lessons-learned.md).
- IAP: Starter Pack (non-consumable) + Megabucks consumable packs; full register→initialize→approved→verified→finished flow, restore purchases, idempotent delivery (audited clean 2026-05-29)
- "No Ads" gating — all five ad surfaces suppressed for Starter Pack owners
- ATT consent (`requestTrackingAuthorization` before AdMob), in-app privacy policy link

**Backend — global leaderboard (Supabase)**
- Rank tiers by lifetime earnings (Intern → Legend), top-100 board, anonymous by firm name
- Opt-in consent modal + Shop toggle; RLS design + consent flow documented
- XSS vulnerability fixed; 7 leaderboard bugs fixed (ATT ordering, rival seeding, raid cleanup); server-side anti-cheat plausibility check
- Go-live runbook: [`launch/leaderboard-go-live-runbook.md`](launch/leaderboard-go-live-runbook.md)

**Launch pipeline**
- TestFlight live and externally tested
- App Store screenshots (1284×2778) generated; iPhone 16 Pro Dynamic Island / safe-area overlap fixed
- App icon redesigned (rocket + moon) and installed into `AppIcon.appiconset`
- Apple rejection (GL 2.1(b)) addressed: corrected screenshot dims, re-uploaded IAP config

---

## 🔜 Open / verify before next release

- ✅ **Strip IAP debug logs** — DONE. `grep -c '\[IAP\]' index.html` → 0 remaining (verified 2026-06-18).
- **Confirm v1.0.1 release** — it's "Ready for Distribution"; if release was set to manual, click **Release** in App Store Connect to push it live.
- **AdMob app-ads.txt verification** — once v1.0.1 is live (Marketing URL visible on the listing), go to AdMob → "Check for updates" to clear verification.
- **Post-launch monitoring** — once live, watch D1/D7 retention and drop-off at: tutorial completion, first prestige, Tokyo unlock. Plan v1.1 from real data, not assumptions.

---

## 🧭 Backlog (designed, not built)

### Day Trading Desk — active-play layer (new "DESK" tab)
Sets DTT apart from pure idle clickers. Live candlestick chart (20 candles, 3s updates), GO LONG / GO SHORT, position auto-sized to 5% of cash, CLOSE anytime, auto stop-loss at −50%. Brownian-motion price sim with drift from active market events; owning 100+ of an asset biases its chart. 3 free trades/day (+3 per ad); "Trade Pass" IAP for 24h unlimited. Daily trader score → gold at day reset, with an achievement chain. *(Was "in development" as of 2026-05-22; status unconfirmed.)*

### Ticker / emoji art system
Replace every emoji with purpose-built inline SVG icons: 28 asset tickers (40×40 badges), all tab + bottom-bar icons, toast/achievement/button chrome, manager avatar badges. No external files needed for the App Store build. Polish item — not a submission blocker.

### Game Center (leaderboard + cloud saves)
A proven Game Center **leaderboard** integration blueprint (from the Summit game) is captured in [`gamecenter-integration-pattern.md`](gamecenter-integration-pattern.md) — reuse it for a global net-worth / all-time-earnings board (decide whether it supplements or replaces the staged Supabase board). Separately, **cloud saves**: replace manual Export/Import Save Code with automatic iCloud saves via `GKLocalPlayer.local.saveGameData()` / `fetchSavedGames()`. Needs a Capacitor bridge plugin to pass the save string between JS and Swift; on success, remove the Save/Export/Import buttons from the Menu. Fixes localStorage being wiped on reinstall.

### Push / local notifications
`@capacitor/push-notifications` (or Local Notifications, no server) for "vault full" (passive cap reached, ~4h) and "bull market" event alerts.

### ViewController.swift — 2-swipe home gesture
Code is ready on disk; requires the manual Xcode step (drag into Project Navigator, add to App target, point the storyboard at `customClass="ViewController" customModule="App"`).

---

## Reference

- Full pre-submission audit & verified-clean checklist: [`archive/FINAL_AUDIT.md`](archive/FINAL_AUDIT.md)
- App Store lessons / rejection playbook: [`app-store/`](app-store/)
- Leaderboard schema & SQL: [`supabase/`](supabase/)
