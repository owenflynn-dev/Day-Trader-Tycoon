# Day Trader Tycoon — Product Roadmap
*Last updated: 2026-05-22*

---

## 1. Art & Icon System (Visual Polish)

**Goal:** Replace every emoji in the game with purpose-built SVG icons. Emojis render differently per OS, look unpolished, and break the Wall Street aesthetic.

**Scope:**
- 28 asset tickers (Wall St × 10, Tokyo × 6, London × 6, Black Market × 6) → unique SVG badge-style icons
- All tab icons (HOME, GOALS, STAFF, PERKS, SKILLS, PIT, OPTIONS, DESK, RANKS, NEWS)
- All bottom bar icons (Stats, IPO Firm, Menu)
- UI chrome: toast icons, achievement icons, button icons
- Manager portrait style: small avatar badges (no emoji faces)

**Approach:** Embed SVGs inline in the CSS/HTML. Each ticker gets a 40×40 badge with a colored background circle + a custom path or letter mark. No external files needed for App Store.

**Priority:** Medium-high. Needed before App Store wide release. Not a blocker for TestFlight.

---

## 2. Economy Rebalance

**Problem:** The game snowballs too fast. Progression that should take days takes hours. Premium items (leverage, time warps) feel optional rather than essential.

**Root cause analysis:**
- `MILESTONE_MULT = 2.0` → 11 milestones = 2,048× per asset. With 10 assets + managers, this compounds to absurdly large numbers.
- First IPO reachable in under 20 minutes, which cheapens the prestige loop.
- Leverage multipliers (5×, 10×) feel small relative to existing snowball.

**Specific changes (implemented 2026-05-22):**
- `MILESTONE_MULT`: 2.0 → 1.5 (2,048× → 86× at max milestones — still powerful, not broken)
- `COST_GROWTH`: 1.12 → 1.14 (each unit 14% more expensive)
- Base payouts reduced ~20% across Wall St assets
- `prestigeGain()` formula: coefficient 8 → 5 (raises the earnings bar for each influence token)
- Leverage pricing unchanged — make the game harder so leverage *matters*

**Target feel:**
- First IPO: ~45 min first session
- First time warp used: ~2 hours in
- First 10x leverage needed: ~4-5 hours in
- "Completing" the game (all milestones, all markets): multi-week

---

## 3. Day Trading Desk (New Core Mechanic)

**Goal:** A dedicated active-play layer that sets DTT apart from pure idle clickers. Real timing skill, real tension, real payoff.

**Tab:** New "DESK" tab replaces/merges with the existing tab strip.

**Mechanics:**
- A live simulated candlestick chart (20 candles, updates every 3s)
- Two actions: GO LONG (buy) or GO SHORT (sell)
- Position size auto-scaled to 5% of your current cash
- CLOSE button to exit at any time
- Stop-loss: auto-closes at −50% of position size (you can't blow up)
- Take-profit: optional manual close at any profit level
- Session resets each real-world day (3 free trades; watch ad for +3)

**Price simulation:**
- Brownian motion (random walk) with drift bias from current market events
- Bull event active → upward drift; Bear event → downward drift
- Owning 100+ of an asset gives a slight positive bias on that asset's chart
- Chart tied to `state.activeMarket` (switches when you switch markets)

**Rewards:**
- Winning trade: direct cash bonus (P&L × 1 added to wallet)
- Losing trade: partial cash loss (capped at −2.5% of wallet max)
- Daily trading score tracked → high scores earn gold at day reset
- "Trader Score" achievement chain in GOALS tab

**Monetization:**
- 3 free trades/day → watch ad for +3
- MB purchase: "Trade Pass" (unlimited trades for 24h)

**Status:** In development.

---

## 4. Global Leaderboard + Ranks (Rivals → Ranks)

**Goal:** Replace the placeholder Rivals tab with a real Supabase-backed global leaderboard. Gives players a reason to keep playing and to flex.

**Rank tiers (by lifetime earnings, all-time):**
| Rank | Threshold |
|------|-----------|
| Intern | < $1M |
| Analyst | $1M+ |
| Associate | $1B+ |
| VP | $1T+ |
| Director | $1Qa+ |
| Managing Director | $1Qi+ |
| Partner | $1Si+ |
| Legend | $1Oc+ |

**Backend (Supabase):**
- Table: `leaderboard(id uuid, firm_name text, lifetime_earnings float8, total_ipos int, rank_tier text, updated_at timestamptz)`
- Upsert on each save (throttled to 1/min max)
- Read top 100 on tab open
- No auth required — anonymous by firm name

**Anti-cheat:** Server-side plausibility check (earnings per hour cap based on IPO count). Obvious cheaters hidden from public board, still visible to themselves.

**Status:** Planned. Requires Supabase schema + edge function. Do after economy rebalance lands.

---

## 5. Premium Currency & Monetization Tightening

**Once economy is harder:**
- Time Warps become genuinely valuable (a 24h warp mid-session is a big deal)
- Leverage 10×/20×/100× become exciting moments not background features
- Consider: "Starter Pack" IAP (5 MB + 1h time warp + 3 leverage charges) for ~$2.99
- Ad frequency: launch offer + income doubler + crash bailout covers the free layer well

---

## 6. Game Center Cloud Saves

**Goal:** Replace the Export/Import Save Code buttons with automatic iCloud cloud saves via Game Center. Players never lose progress on reinstall or device switch.

**Why:** localStorage is wiped on iOS app reinstall. Export/Import is a clunky manual workaround. Game Center cloud saves are the proper solution and let us remove those buttons from the Menu.

**Scope:**
- Enable Game Center capability in Xcode
- Use `GKLocalPlayer.local.saveGameData()` to write the save string on each auto-save
- Fetch on launch with `fetchSavedGames()` — if cloud save is newer than localStorage, prompt player to restore
- Capacitor bridge plugin needed to pass save string between JS game layer and native Swift
- On success: remove Save Now, Export Save Code, and Import Save Code buttons from Menu

**Status:** Planned. Do after IAP and leaderboard are stable.

---

## 7. ViewController.swift — 2-Swipe Home Gesture

**Status:** Code is ready on disk. Owen must manually drag `ViewController.swift` into Xcode Project Navigator → add to App target → update storyboard to reference `customClass="ViewController" customModule="App"`.

---

## Session Order of Operations

1. ✅ Fix AdMob 3-tap bug (done)
2. ✅ Launch ad offer (done)
3. ✅ Bottom bar flush fix (done)
4. 🔄 Economy rebalance (this session)
5. 🔄 Day Trading Desk (this session)
6. ⏳ Ticker art / emoji removal
7. ⏳ Global leaderboard + Ranks
8. ⏳ ViewController.swift manual Xcode step
9. ⏳ ADMOB_TEST_MODE = false (before App Store)
