# Day Trader Tycoon — Executable Development Plan
*Last updated: 2026-05-20*

---

## Status snapshot

The game is feature-complete (all markets, Options Desk, AI Rivals, Chicago Pit, Capacitor iOS wrap). What remains is polish, mobile infrastructure, and the App Store submission pipeline.

**Already done that the old ROADMAP hadn't marked off:**
- Confetti — `celebrate()` already spawns 24 colored squares on every milestone, prestige, and major event. ✅
- Capacitor iOS wrap + iPhone dev loop. ✅
- All 4 markets, all monetization stubs. ✅

---

## Phase 1 — Polish (1–2 sessions, ~2 hrs total)
*Makes the game feel great on a real iPhone before anything else.*

### 1A · CSS safe-area fix (30 min)
**Problem:** On iPhones with a home indicator (iPhone X and later), the bottom navigation bar sits flush against the bottom edge. The home indicator sits on top of the buttons.

**What to change in `index.html`:**
1. Viewport meta tag — add `viewport-fit=cover`:
   ```html
   <!-- change this line (~line 3): -->
   <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
   <!-- to: -->
   <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
   ```
2. Bottom bar CSS — add safe-area inset to padding:
   ```css
   /* change .bottom-bar padding (~line 1181): */
   padding: 10px 10px;
   /* to: */
   padding: 10px 10px calc(10px + env(safe-area-inset-bottom));
   ```
3. `#app` padding-bottom — account for taller bar:
   ```css
   /* change ~line 56: */
   padding-bottom: 90px;
   /* to: */
   padding-bottom: calc(90px + env(safe-area-inset-bottom));
   ```

**Done when:** Home indicator no longer overlaps nav buttons on a physical iPhone.

---

### 1B · Dramatic offline earnings modal (1–1.5 hrs)
**Problem:** The Welcome Back modal instantly shows a static number. The "rolling cash tally" described in the roadmap — where the hero number counts up — is not implemented.

**What to change in `index.html`:**
- In `showWelcomeBackModal()` (~line 3055): instead of setting `wbTotal.textContent = hero.str` directly, animate the hero number from 0 to the final value over ~1.2 seconds using `requestAnimationFrame`.
- Add a slight delay before opening the modal (100ms) so the count-up is the first thing the player sees.
- Optional: add a subtle "ka-ching" SFX trigger at the end of the count-up (use the existing Web Audio engine).

**Rough implementation pattern:**
```js
function animateCount(el, targetVal, currency, durationMs) {
  const start = performance.now();
  function step(now) {
    const t = Math.min((now - start) / durationMs, 1);
    const eased = 1 - Math.pow(1 - t, 3); // ease-out cubic
    el.textContent = fmt(targetVal * eased, currency);
    if (t < 1) requestAnimationFrame(step);
  }
  requestAnimationFrame(step);
}
```
Call `animateCount(wbTotal, hero.val, hero.currency, 1200)` instead of the direct `.textContent` set.

**Done when:** On first open after being away, the hero dollar/yen/£ number visibly counts up from 0 to final value.

---

## Phase 2 — Mobile infrastructure (2–3 sessions, ~4 hrs + external setup)
*Needed before TestFlight. Requires npm installs and external developer accounts.*

### 2A · AdMob rewarded ads (2–3 hrs)
**Problem:** `Monetization.showRewardedAd()` runs a 5-second countdown simulation on web. In the Capacitor build it hits a commented-out stub. No real ads fire on the iPhone.

**External prerequisite:**
- Google AdMob account (free) → create an app → create 3 rewarded ad units: `offline_double`, `income_boost`, and `crash_bailout`. Note the ad unit IDs.

**Steps:**
1. Install the plugin: `npm install @capacitor-community/admob` in the project folder, then `npx cap sync`.
2. In `AppDelegate.swift` (ios/ folder), initialize AdMob on app start with your app ID.
3. In `index.html` around line 2812, replace the stub `showRewardedAd()` with:
   ```js
   if (window.Capacitor?.isNativePlatform()) {
     const { AdMob } = Capacitor.Plugins;
     await AdMob.prepareRewardVideoAd({ adId: AD_UNIT_IDS[placement] });
     const result = await AdMob.showRewardVideoAd();
     callback(result.type === 'Rewarded');
   } else {
     // existing web sim stays
   }
   ```
4. Add an `AD_UNIT_IDS` map at the top of the Monetization object with your real unit IDs.

**Done when:** On iPhone, tapping "Watch Ad" shows a real Google rewarded ad and credits the reward on completion.

---

### 2B · Push notifications (1–2 hrs)
**Problem:** No push notifications implemented. Roadmap calls for "vault full" and "bull market" alerts.

**External prerequisite:**
- Apple Developer account ($99/yr) — required for push entitlements and TestFlight anyway.

**Steps:**
1. Install: `npm install @capacitor/push-notifications`, then `npx cap sync`.
2. Add Push Notifications entitlement in Xcode (Signing & Capabilities → + Capability → Push Notifications).
3. In `index.html` (near the boot sequence), add a permissions request on first launch:
   ```js
   if (window.Capacitor?.isNativePlatform()) {
     const { PushNotifications, LocalNotifications } = Capacitor.Plugins;
     await PushNotifications.requestPermissions();
   }
   ```
4. Use **Local Notifications** (no server needed) for the two triggers:
   - **Vault full** — when `state.cash` reaches the passive income cap (~4hr), schedule a local notification: "Your vault is overflowing 💰 — come collect."
   - **Bull market** — when a positive market event fires, optionally schedule a 2-min notification (in case player closed the app).
5. Schedule notifications in `scheduleLocalNotif(title, body, delaySeconds)` helper, called from the existing event system.

**Done when:** With the app backgrounded, a notification appears on the iPhone lock screen at the right time.

---

## Phase 3 — Analytics + TestFlight prep (1–2 sessions)
*Instrument the game. Get it into testers' hands.*

### 3A · Analytics (1–2 hrs)
**Recommended:** GameAnalytics (simpler than Firebase for games, free tier).

**Steps:**
1. Create account at gameanalytics.com → add iOS app → get Game Key + Secret Key.
2. Install `capacitor-game-analytics` or use the JS SDK via CDN.
3. Initialize on boot with your keys.
4. Add the following event calls in `index.html`:
   - `GA:progression_start` — on game start
   - `GA:progression_complete:first_prestige` — in `doPrestige()` on first IPO
   - `GA:resource_source:gold_ad_watch` — in the rewarded ad callback
   - `GA:design:market_unlock_tokyo` — when Tokyo unlocks
   - `GA:design:market_unlock_london` — when London unlocks
   - `GA:design:options_first_use` — in the Options tab first unlock

**Done when:** Events appear in the GameAnalytics dashboard within 24 hrs of a test run.

---

### 3B · App Store assets (2–4 hrs, design work)
**What's needed:**
- **App icon** — 1024×1024 PNG, no transparency, no rounded corners (Apple applies rounding). The `day_trader_tycoon_cover.svg` is a good starting point but needs to be a square icon format.
- **Screenshots** — Required sizes: 6.7" (1290×2796px) and 5.5" (1242×2208px). Take 3–5 per device showing: home screen, Tokyo/London market, Options Desk, prestige modal.
- **App name:** "Day Trader Tycoon" (check App Store availability)
- **Subtitle:** "Wall Street Idle Clicker" (30 char max)
- **Description:** ~200 words. Key hooks: idle clicker, 4 markets, prestige system, no pay-to-win.
- **Keywords:** idle, tycoon, trading, stocks, clicker, wall street, investor, finance (100 char total)
- **Privacy policy URL** — required for any app with ads. A simple single-page site or GitHub Pages page works.

---

### 3C · Apple Developer account + TestFlight ✅ DONE
- Apple Developer account purchased.
- App is live on TestFlight and has been tested by external testers.
- Next step is App Store submission (Phase 4).

---

## Phase 4 — Launch (when TestFlight feedback is clear)

### 4A · App Store submission
1. In App Store Connect: fill in all metadata (name, description, keywords, screenshots, support URL, privacy policy URL).
2. Set pricing: Free (with IAP).
3. Add all IAP products: starter_pack, mb_5, mb_15, mb_50, mb_150 (match `purchaseIAP` product IDs in code).
4. Submit for review. Apple review: 1–3 days typical, up to 7 days for first submission.

### 4B · Post-launch monitoring
- Watch D1 and D7 retention in GameAnalytics.
- Common drop-off points to watch: tutorial completion rate, first prestige rate, Tokyo unlock rate.
- Plan v1.1 fixes from actual TestFlight and launch feedback — don't build new features blind.

---

## Dependency map

```
1A (safe-area)        ← no dependencies, do first
1B (offline modal)    ← no dependencies, do first
      ↓
2A (AdMob)            ← needs AdMob account + Apple Dev account
2B (push notifs)      ← needs Apple Dev account ($99)
      ↓
3A (analytics)        ← needs GameAnalytics account
3B (App Store assets) ← needs screenshots from real iPhone (after 1A fix)
3C (TestFlight)       ← needs 2A + 2B + Apple Dev account + built archive
      ↓
4A (App Store)        ← needs 3B + 3C complete + IAP products configured
4B (monitor)          ← needs 3A + 4A live
```

---

## Open questions before starting Phase 2

- Do you have an AdMob account already, or need to create one?
- For analytics, preference for GameAnalytics vs. Firebase?
