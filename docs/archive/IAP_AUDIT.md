# Day Trader Tycoon — Pre-Submission Audit
_Conducted: 2026-05-29 | Full codebase read (7,649 lines)_
_Prior IAP audits appended at bottom_

---

## BLOCKING — Will Get Rejected or Cause User Backlash

### 1. "No Ads" is advertised but not implemented

**Severity: Critical / App Store violation**

The Starter Pack button reads "Starter Pack — 50 Gold + **No Ads** · $2.99". The `openModal('settingsModal')` code regenerates that label every time the shop opens (`index.html:7009`). However, there is zero code anywhere that checks `state.starterPackOwned` before showing an ad. The "📺 2× Income" button in the header, the "Watch Ad" button in the settings modal, the offline-doubling ad button — all remain fully visible and functional after purchase.

Apple's review team purchases non-consumables during review. If a reviewer pays $2.99 for "No Ads" and then sees ad buttons, this is rejected under guideline 3.1.1 (accurate metadata) and likely 2.3.12 (deceptive features).

**Your options:** Either implement the feature (hide all ad-related UI elements when `state.starterPackOwned`) or remove "No Ads" from the description. There is no middle ground here.

---

### 2. No in-app privacy policy link

**Severity: App Store requirement**

Apps with in-app purchases are required by Apple to have a privacy policy link accessible from within the app. There is no such link anywhere in the game — not in settings, not in the shop modal, nowhere. You have a `privacy-policy.html` file in the project but it is never linked from inside the game.

Apple will reject without this. Add it to the settings modal.

---

## Critical — Broken Functionality

### 3. Launch ad offer never shows (`state.staff` is undefined)

**Location: `index.html:3276`**

```javascript
const hasTrader = Object.values(state.staff || {}).some(s => s > 0);
if (!hasTrader) return;
```

`state.staff` is never defined, never initialized in the state object, never saved, never loaded. It is always `undefined`, collapsing to `{}`. `hasTrader` is always `false`. `maybeShowLaunchAdOffer()` returns before it can ever show.

The actual data for "player has a hired trader" lives in `state.assets[id].hired`. The check should be:

```javascript
const hasTrader = ASSETS.some(a => state.assets[a.id]?.hired);
```

This is a dead monetization surface — the launch ad offer has never triggered for any user.

---

### 4. Whistleblower: advertised as 5× but fires a 4× event

**Location: `index.html:2448`, `4276`, `6498`**

The premium manager description says: *"trigger a guaranteed **5x** bullish event for 30s."*
The USE button label says: *"Trigger **5x** event"*

The actual event created in `useWhistleblower()`:
```javascript
const ev = { sector: 'all', mult: 4, dur: 30, ... };
celebrate('LEAKED!', '4x all payouts for 30 seconds');
```

It fires a 4× event, not 5×. The celebration even says "4x". This has been inconsistent for at least one release cycle. Either fix the mult to `5` or fix the description/button to say "4×".

---

### 5. Black Swan bonus is lost if the app closes during the event

**Location: `index.html:4100`**

When a Black Swan fires, `blackSwansExperienced` is incremented and saved immediately. The survival reward (+25% `blackSwanBonus`, +1 Megabuck) is scheduled via `setTimeout(callback, sw.dur * 1000 + 200)`. If the player closes the app during the event window, the `setTimeout` is cleared by iOS, the callback never fires, but `blackSwansExperienced` is already 1. The player burned one of their two lifetime Black Swan slots and received nothing.

Fix: when the event ends in `tick()` (already handled via `state.activeEvent.until` expiry), check if the expired event was a black swan and award the bonus there, not via a transient `setTimeout`.

---

## Moderate — Visible Bugs Players Will Notice

### 6. Double dollar sign in secondary market rate display

**Location: `index.html:5944`**

```javascript
parts.push('$' + fmt(r) + '/s');
```

`fmt(r)` with no currency argument already prepends `$`. Result: players with both Wall Street and Tokyo/London active see **`$$1.23M/s`** in the header's secondary rates line.

Fix: `parts.push(fmt(r) + '/s')`.

---

### 7. Time Warp deposits wrong currency when used on Tokyo or London tab

**Location: `index.html:3940`, `4490–4496`**

`totalIncomePerSec()` only sums assets in `state.activeMarket`. `useTimeWarp()` always deposits the result as `state.cash` (Wall St dollars) regardless of which market is active.

If a player is on the Tokyo tab with ¥1M/sec income and zero Wall St income, `totalIncomePerSec()` returns 1,000,000 and the Time Warp deposits `$1,000,000` — a cross-currency exploit where yen rates are treated as dollar amounts. The display preview in the Perks tab also shows the projected amount with a `$` symbol even when on Tokyo/London.

Expected behavior: Time Warp should either (a) always use Wall St income regardless of active tab, or (b) deposit in the correct currency per market. Currently it does neither consistently.

---

### 8. Active leverage survives prestige (IPO)

**Location: `index.html:5776`**

`doPrestige()` resets assets, cash, and `activeEvent`, but does NOT reset `state.activeLeverage`, `state.activePump`, or `state.optionsLeverage`. A player who activates a 10× leverage multiplier and immediately IPOs retains the multiplier through the prestige reset — multiplying their fresh-start income until the timer expires. This is unintended and breaks the run reset contract.

---

### 9. `crash_bailout` ad unit defined but never used

**Location: `index.html:2919`**

```javascript
crash_bailout: 'ca-app-pub-2363991569160794/2343394206',
```

This AdMob unit ID is defined in production. There is no call to `Monetization.showRewardedAd('crash_bailout', ...)` anywhere in the codebase. When an Options Desk contract crashes, the result screen shows only "Ready for next launch" with no ad-to-salvage-leverage button. Either wire it up or remove the dead unit to avoid registered-but-unused ad inventory.

---

## UX Problems / Confusing to Players

### 10. Rivals tab shows "Coming soon" but rival system fully runs in the background

**Location: `index.html:5634`**

```javascript
function renderRivalsTab() {
  // Leaderboards tab is a placeholder until Phase G backend — do not overwrite the HTML.
  return;
  // ... 100+ lines of working UI code below that never execute
```

The rival system runs every tick: rivals accumulate wealth, players beat them, rewards are granted (gold, megabucks), SEC complaints can theoretically be filed. But `renderRivalsTab()` returns immediately — the tab always shows the static "No players yet / Coming in a future update" placeholder.

Result: players receive toast notifications and news items about rival milestones ("RIVAL BEATEN: The Bear") but go to the Rivals tab and see nothing. The SEC complaint button is built but unreachable. This actively undermines trust in the game's completeness at a moment of excitement.

Decision needed: either enable the local rivals leaderboard (which is fully coded) or remove the rival-related notifications so the "coming soon" experience is self-consistent.

---

## Minor — Low Priority

### 11. `launchAdOffer` div has `display:none` declared twice

**Location: `index.html:2158`**

```html
<div id="launchAdOffer" style="display:none;...;display:none;flex-direction:column;gap:10px;...">
```

Two `display:none` values in a single style attribute. The JS correctly overrides both by setting `el.style.display = 'flex'`, so it works, but it signals copy-paste confusion and will trigger "why does this show as flex-direction:column on the element but display:none in the style attribute?" confusion during debugging.

---

## IAP Audit (Prior — v2, 2026-05-29)

### Bug fixed: Cancelled StoreKit sheet permanently blocked retry

When `store.order()` resolved successfully, `_iapPendingCallbacks[productId]` was set and the StoreKit sheet appeared. If the user cancelled, `store.error()` was never registered — the pending callback was never cleared. The double-tap guard then permanently blocked all future taps on that product until app restart.

**Fixes applied (all three files):**
1. `store.error()` handler now calls `_releaseIAPCallbacks()` — clears pending map and calls each callback with `false`
2. `.unverified()` added to `store.when()` chain — unhandled before, caused same leak on receipt verification failure
3. 5-minute self-expiring `setTimeout` in `purchaseIAP()` — belt-and-suspenders in case `store.error()` silently swallows a cancellation

---

## IAP Audit (Prior — v1, 2026-05-28)

### Bug fixed: Double-delivery of 50 Gold on Starter Pack

`_deliverIAPProduct()` called `onStarterPackPurchased(true)` directly AND then called `cb(true)` (where `cb` was the same function). Double-awarded 50 Gold.

### Bug fixed: `store.order()` resolved-error silently swallowed

`store.order()` resolves (not rejects) with an `IError` on failure. The code only had `.catch()`, which never fires for resolved promises. Unhandled errors left `_iapPendingCallbacks` populated with no user feedback.

### Bug fixed: `onStarterPackPurchased` double-award safety guard

Added `|| state.starterPackOwned` check to prevent re-award if called from unexpected path.
