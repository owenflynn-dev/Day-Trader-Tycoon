# Day Trader Tycoon — Code Review
*Reviewed: 2026-05-27 · File: index.html (7,615 lines)*

---

## Summary

The codebase is well-structured for a single-file game. The IAP lifecycle follows cordova-plugin-purchase v13 correctly. No App Store compliance blockers found. Four actionable fixes are called out below (two state bugs, one IAP guard, one fragile utility function). The rest are dead code callouts and low-priority notes.

---

## Critical

*None.*

---

## Medium — Fix before resubmit

### M1 · Tokyo unlock has no `save()` — duplicate ¥100 bonus possible
**Line:** 5934–5938 (`renderAssets()`)

```js
if (tokyoUnlockedNow && !state.tokyoUnlocked) {
  state.tokyoUnlocked = true;
  state.yen = (state.yen || 0) + 100;
  addNews('TOKYO UNLOCKED', ...);
  // ← no save() here
}
```

`renderAssets()` is a render function, not a save checkpoint. If the app is force-killed within the 5-second autosave window after the player's first IPO, `state.tokyoUnlocked` won't be in the save. On next load, `influence >= 1` is still true, so the block runs again and awards another ¥100.

**Fix:** Add `save()` after `addNews()` on line 5937.

---

### M2 · London unlock has no `save()` — duplicate £10,000 bonus possible
**Line:** 5940–5946 (`renderAssets()`)

Same issue as M1. If the app dies within 5 seconds of the player crossing 1,000 pit credits, London re-unlocks on next launch and awards another £10,000 welcome bonus.

**Fix:** Add `save()` after `SFX.ipo()` on line 5945.

---

### M3 · `purchaseIAP` double-tap overwrites pending callback
**Line:** 3016–3017 (`purchaseIAP()`)

```js
window._iapPendingCallbacks = window._iapPendingCallbacks || {};
window._iapPendingCallbacks[productId] = callback;  // overwrites if already set
```

If the player taps a purchase button twice before the first transaction resolves, the second callback replaces the first. The first callback is orphaned — it never fires. The purchase still goes through (Apple processes both), but the first tap's UI callback (toast, celebrate, state update for MB) is silently dropped.

**Fix:** Guard the order call if a callback is already pending for that product:

```js
if (window._iapPendingCallbacks?.[productId]) {
  toast('Purchase already in progress…');
  return;
}
window._iapPendingCallbacks = window._iapPendingCallbacks || {};
window._iapPendingCallbacks[productId] = callback;
offer.order().catch(...);
```

---

### M4 · `_b64Encode` spreads Uint8Array as function arguments — fragile on large saves
**Line:** 7447 (`_b64Encode()`)

```js
return btoa(String.fromCharCode(...bytes));
```

Spreading a Uint8Array passes each byte as a separate argument to `String.fromCharCode`. JavaScriptCore (iOS WKWebView) has an argument-count limit. For saves above ~65 KB this throws a `RangeError`. Current saves are small because `newsLog` is excluded, but this is a ticking time bomb if more fields are added.

**Fix:**

```js
function _b64Encode(str) {
  const bytes = new TextEncoder().encode(str);
  let binary = '';
  for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
  return btoa(binary);
}
```

---

## Low — Polish / cleanup

### L1 · Stale `delete` pattern in `_deliverIAPProduct` and `purchaseIAP`
**Lines:** 3020, 3122

```js
delete (window._iapPendingCallbacks || {})[productId];
```

When `_iapPendingCallbacks` is `undefined`, `|| {}` creates a fresh object and the delete is a no-op on it. No functional harm but misleading. Prefer:

```js
if (window._iapPendingCallbacks) delete window._iapPendingCallbacks[productId];
```

---

### L2 · `maybeStartRivalRaid()` is defined but never called
**Line:** 5542

The call at tick line 5753 is commented out (`// maybeStartRivalRaid() — disabled`). The function body (lines 5542–5554) and `fileSecComplaint()` (5556–5574) are reachable from the UI (SEC complaint button), but the raid initiation path is dead. No fix needed — leave commented until Phase G — but noting for clarity.

---

### L3 · `renderRivalsTab()` has ~100 lines of unreachable code
**Line:** 5577–5700+

The function returns immediately at line 5579:

```js
function renderRivalsTab() {
  // Leaderboards tab is a placeholder until Phase G backend
  return;
  const root = ...   // dead
```

Intentional placeholder. No fix needed, but if this grows it should be wrapped in `/* */` to make the intent clear.

---

### L4 · `isBlack = false` in `renderCash()` — dead ternary branches
**Lines:** 5874, 5879–5881, 5898–5901

```js
const isBlack = false; // Black Market removed
const cur = isLondon ? 'gbp' : isTokyo ? 'yen' : isBlack ? 'gold' : 'cash';
```

`isBlack` is hardcoded `false`, so the `gold` branches are unreachable. `state.activeMarket === 'blackmkt'` is also blocked by `load()` (line 7353) and `switchMarket()`. The BM branches in `payoutOf`, `costOf`, `getMoney`, etc. are similarly vestigial. Not a bug, just dead code from the BM removal.

---

### L5 · Google Fonts loaded from CDN — no offline fallback
**Lines:** 9–11

```html
<link href="https://fonts.googleapis.com/css2?family=Lilita+One&family=Nunito:wght@700;800;900&display=swap" />
```

If the device has no internet on first launch, fonts fall back to system sans-serif. The game still works. Not a compliance issue, but App Store review is sometimes done on restricted networks — the reviewer sees system fonts. Low risk.

---

## Performance — Notes (no action required)

| Area | Finding |
|------|---------|
| `renderCash()` in `tick()` | Called every 100ms (10×/sec), updates 10+ DOM nodes. Acceptable for an idle game. Would benefit from a dirty flag if frame rate issues appear on low-end iPhones. |
| `renderProgressBars()` at 30fps | 4 `classList.toggle` calls × 28 assets = 112 style ops per frame. Standard for this genre. |
| `getElementById` in RAF loop | 2 lookups per asset per frame (prog-{id}, timer-{id}). Caching these at render time would halve the lookups; not needed unless profiling shows a bottleneck. |
| `buildTicker` every 8s | Cosmetic only. Fine. |
| `pitTick()` every 100ms | Fast early return when tab is inactive. Fine. |

---

## State Management — Notes

| Area | Finding |
|------|---------|
| `save()` frequency | Called on every user action (buy, hire, prestige, etc.) plus autosave every 5 seconds. Frequency is appropriate. localStorage writes are synchronous and cheap at this data size. |
| Prestige reset | `doPrestige()` resets cash, lifetimeEarnings, and all asset positions, but correctly leaves yen, GBP, gold, influence, and persistent unlocks intact. ✓ |
| Offline earnings | `payoutOf()` is called in `load()` for offline calc, which includes the income doubler via `globalMult()`. If the doubler expired while offline, `Date.now() > incomeDoublerUntil` is correctly false — no exploit. ✓ |
| `pitOrders` not persisted | Intentional. Orders are real-time and short-lived; they respawn from the timing state which is persisted. ✓ |

---

## IAP Lifecycle — Assessment

The cordova-plugin-purchase v13 lifecycle is correctly implemented:

```
store.when()
  .approved(t => t.verify())      ✓ approved → verify
  .verified(r => r.finish())      ✓ verified → finish
  .finished(t => _deliver(t))     ✓ finished → deliver
```

- Product registration before `initialize()` ✓
- `_iapReady` flag gates `purchaseIAP` so no order can be placed before the store is initialized ✓
- Non-consumable `starter_pack` checks `!state.starterPackOwned` before delivering, preventing duplicate grants ✓
- `restorePurchases()` implemented (required by Apple) ✓
- Web fallback auto-confirms (only fires when `!isNativePlatform()`) ✓

Only issue: M3 above (double-tap guard).

---

## App Store Compliance — Assessment

| Check | Status |
|-------|--------|
| No web payment flows | ✓ All purchases go through `purchaseIAP` → cordova-plugin-purchase |
| No external links bypassing IAP | ✓ No `window.open` or external URLs for purchases |
| ATT handled in native layer | ✓ AppDelegate.swift handles ATT before AdMob initializes; `requestTrackingAuthorization: false` passed to SDK to prevent double-prompt |
| `ADMOB_TEST_MODE` | ✓ Set to `false` — real ad unit IDs in use |
| `restorePurchases` available | ✓ Required by App Store guidelines for non-consumables |
| Privacy policy | ✓ `privacy-policy.html` exists |

No compliance blockers identified.

---

## Fixes Applied in This Session

| # | Issue | Fix Applied |
|---|-------|-------------|
| M1 | Tokyo unlock no `save()` | `save()` added after Tokyo unlock block |
| M2 | London unlock no `save()` | `save()` added after London unlock block |
| M3 | IAP double-tap guard | Guard added before `offer.order()` |
| M4 | `_b64Encode` spread overflow | Replaced spread with for-loop |
| L1 | Stale `delete` pattern | Cleaned up in both locations |
