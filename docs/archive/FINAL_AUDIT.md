# Day Trader Tycoon — Final Pre-Submission Audit
_Conducted: 2026-05-29 | 7,790-line full read_

---

## Verdict

**One item requires action before submission (IAP debug logs). Everything else is clean or already fixed in this session.**

---

## 1. ADMOB_TEST_MODE

**Status: ✅ CORRECT**

```javascript
const ADMOB_TEST_MODE = false;
```

Production ad unit IDs are active. Test unit has been removed.

---

## 2. IAP Debug Logs — Must Remove Before Final Build

**Status: ⚠️ ACTION REQUIRED — not a rejection risk, but pollutes production logs**

47 `[IAP]` `console.log` / `console.warn` lines were added in the previous session to diagnose the `store.initialize()` hang on device. They are intentionally present for that debugging session.

**Remove them before the final submission build.** They are not an App Store rejection reason (Apple does not inspect console output), but they will litter Xcode device logs in production, log internal game logic, and add unnecessary string concatenation overhead on every IAP event.

**How to find them all:**
```
grep -n '\[IAP\]' index.html
```
47 matches. All are inside `initIAP()` and `_initIAPStore()`. After you get the logs you need from a device test run, strip the entire `[IAP]` instrumentation and replace with the clean minimal versions (only the `console.warn` lines on error paths).

**All other `console.warn` lines in the file are legitimate production error handlers** (AdMob prepare/show errors, IAP order errors, IAP init fail) and should stay.

---

## 3. "No Ads" — Starter Pack Suppression

**Status: ✅ ALL FIVE AD SURFACES GATED**

| Surface | Guard |
|---------|-------|
| Header `📺 2× Income` button | `(active \|\| state.starterPackOwned) ? 'none' : ''` in `updateDoublerUI()` |
| Settings modal Watch Ad button | `state.starterPackOwned ? 'none' : ''` in `openModal('settingsModal')` |
| Welcome-back "Double It!" button | `!state.starterPackOwned` condition before reveal |
| Launch ad offer banner | `if (state.starterPackOwned) return;` at top of `maybeShowLaunchAdOffer()` |
| `purchaseIAP()` web fallback | Unaffected — this path only runs on web/dev builds |

No path exists where a Starter Pack owner sees an ad prompt.

---

## 4. Privacy Policy Link

**Status: ✅ PRESENT**

```html
<a href="https://owenflynn-dev.github.io/daytrader-tycoon-support/privacy-policy.html"
   target="_blank" rel="noopener">Privacy Policy</a>
```

Located in the settings modal footer, accessible from the main ⚙️ menu. Satisfies Apple's in-app IAP privacy policy requirement.

---

## 5. IAP Flow

**Status: ✅ CORRECT**

Full flow verified:

- `store.register()` called before `store.initialize()` ✓
- `approved → transaction.verify()` ✓
- `verified → receipt.finish()` ✓
- `unverified → toast + _releaseIAPCallbacks()` ✓
- `finished → _deliverIAPProduct()` ✓
- `store.error()` clears pending callbacks (cancellation guard) ✓
- Double-tap guard with 5-minute self-expiring fallback ✓
- `store.order()` resolved-error and rejected both handled ✓
- `restorePurchases()` wired to Apple restore requirement ✓
- `starter_pack` delivery idempotent (`state.starterPackOwned` guard) ✓
- Consumable delivery via pending callback → `onMegabucksPurchased` ✓
- Starter Pack button shows "✅ Already Owned" when `state.starterPackOwned` ✓

No delivery path can double-award or skip a reward.

---

## 6. Save / Load Integrity

**Status: ✅ CLEAN — one edge-case fixed this session**

All game state fields are saved and restored. Notable checks:

- `activeEvent` is now persisted to localStorage so Black Swan rewards survive app close ✓
- `buyQty`, `tutorialStep`, `firmName`, `starterPackOwned`, all IAP-adjacent fields saved ✓
- Legacy `payoutLevel` zeroed on load (removed feature, documented) ✓
- Market guard on load prevents invalid `activeMarket` value (e.g., old `blackmkt` saves) ✓
- Rival wealth seeded correctly for existing saves that predate the rivals system ✓

**Fixed this session:** If a Black Swan event's duration expired while the app was closed, `load()` now grants the survival bonus immediately (previously it was silently lost because tick() never ran during the offline period). The celebration fires 1.2s after `boot()` completes.

---

## 7. Gameplay Bugs

**Status: ✅ ALL PREVIOUSLY IDENTIFIED BUGS FIXED**

| Bug | Status |
|-----|--------|
| "No Ads" not implemented | Fixed — all surfaces gated |
| Privacy policy missing | Fixed — link added |
| `state.staff` undefined → launch offer never showed | Fixed — uses `ASSETS.some()` |
| Whistleblower said 5× but fired 4× | Fixed — `mult: 5` |
| Black Swan bonus lost on app close | Fixed — moved to tick() + load() |
| Double `$$` in secondary market rates | Fixed |
| Time Warp deposited wrong currency | Fixed — `wallStIncomePerSec()` |
| Active leverage/pump survived prestige | Fixed — nulled in `doPrestige()` |
| Dead `crash_bailout` ad unit | Removed |
| Rivals tab "coming soon" while rewards fired | Fixed — `renderRivalsTab()` enabled |
| `maybeStartRivalRaid()` disabled despite SEC complaint UI being live | Fixed — uncommented in tick() |
| Black Swan bonus lost when app closed and reopened AFTER event expired | Fixed — `load()` detects expired Black Swan and grants reward |
| Event banner not shown when active event restored from save | Fixed — `boot()` calls `showEvent()` after load |

---

## 8. Potential JS Crashes

**Status: ✅ NONE FOUND**

Checks performed:

- All `onclick` function names verified against `function` definitions — zero orphaned references
- `document.getElementById()` calls on static DOM elements (event banner, cash display) are safe — elements always exist
- `state.activeEvent.headline` accessed only inside `showEvent()` which is only called after `state.activeEvent` is set
- `RIVALS` forEach with `r.reward?.mult` optional-chaining prevents crash on `r_bear` which has no `mult` ✓
- Import save code: base64-decode → `localStorage.setItem` → `location.reload()` — no eval, no injection ✓
- `renderRivalsTab()`: all property accesses use `?.` optional chaining ✓
- `_deliverIAPProduct()`: guarded against missing `MB_PACKAGES` entry ✓

---

## 9. App Store Rejection Risks

**Status: ✅ NONE REMAINING**

| Guideline | Check |
|-----------|-------|
| 3.1.1 Accurate metadata | "No Ads" claim now implemented ✓ |
| 2.3.12 Deceptive features | No bait-and-switch — IAP delivers as described ✓ |
| 5.1.1 Privacy policy | In-app link present, NSUserTrackingUsageDescription in Info.plist ✓ |
| 3.1.3 IAP restore | `restorePurchases()` functional ✓ |
| 2.1 App completeness | No placeholder "coming soon" UI in user-facing screens ✓ |
| ATT | `requestTrackingAuthorization()` fires in `applicationDidBecomeActive` before AdMob ✓ |

---

## 10. Known Acceptable Items (Not Rejection Risks)

- **IAP debug logs**: 47 `[IAP]` lines present for active device debugging. Must be stripped before the next release build after the hang is diagnosed.
- **`// ============ MONETIZATION (Ad & IAP stubs) ============`**: The section comment still says "stubs" — cosmetic legacy label, no functional impact.
- **Black Swan banner on reload**: When an active Black Swan is restored from save, the event banner flashes into existence when `showEvent()` fires in `boot()`. This is correct behavior but the player may notice the banner appearing a moment after the app opens. Acceptable UX tradeoff for reward correctness.

---

## What Was Checked and Found Clean

- `ADMOB_TEST_MODE = false` ✓  
- All 5 ad surfaces gated on `starterPackOwned` ✓  
- Privacy policy link in settings modal ✓  
- IAP register → initialize → approved → verified → finished flow ✓  
- IAP error handler clears pending callbacks (cancellation safety) ✓  
- Starter Pack non-consumable idempotent delivery ✓  
- All MB consumable packages deliver correct amounts ✓  
- `doPrestige()` resets cash, assets, activeEvent, activeLeverage, activePump, optionsLeverage ✓  
- `save()` / `load()` round-trips all 45+ state fields ✓  
- All `onclick` function references resolve ✓  
- No `eval()`, no dynamic script injection ✓  
- `RIVALS` array — all `r.reward?.mult` accesses safe ✓  
- Time Warp deposits Wall St cash from Wall St rate only ✓  
- Rivals leaderboard renders with SEC complaint UI ✓  
- Raid mechanic live and counteractable via SEC complaint ✓  
