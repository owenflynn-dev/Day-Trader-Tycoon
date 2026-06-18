# Game Center Integration Pattern (reference from Summit)

> Reusable blueprint for adding a global Game Center leaderboard to **Day Trader Tycoon**
> (likely a net-worth / all-time-earnings board). Lifted from the working implementation in
> Owen's other game, **Summit** ("highest climb" height leaderboard). DTT already has the same
> ATT-after-SceneDelegate + AdMob launch flow, so the auth-sequencing trick (§3) applies directly.

## Overview

Game Center is integrated for a single purpose: a global leaderboard. The implementation is
centralized, defensive (no-ops when unavailable), and carefully sequenced so its sign-in UI never
collides with the ads consent flow on launch. Fully wired end-to-end: capability → authentication →
score submission → leaderboard display.

## 1. Capability & Entitlements

`Summit/Summit.entitlements`:
```xml
<key>com.apple.developer.game-center</key>
<true/>
```
- Game Center capability enabled on the app target in Xcode (Signing & Capabilities).
- App ID registered with Game Center enabled in the Apple Developer portal / App Store Connect.

App Store Connect setup (one-time):
- Leaderboard ID: `com.summit.leaderboard.height`
- Type: Integer (meters)
- Sort order: Highest value first

## 2. Architecture — `GameKitManager.swift`

All Game Center logic lives in one singleton (`GameKitManager.shared`), so the rest of the app never
touches GameKit directly. It exposes:

| Member | Purpose |
|---|---|
| `isAuthenticated` | Read-only flag gating all submissions/UI |
| `authenticateLocalPlayer(presentingViewController:)` | Signs the local player in |
| `submitScore(heightInMeters:)` | Posts a run's score to the leaderboard |
| `showLeaderboard(from:)` | Presents the native Game Center sheet |

A small private `GameCenterDismissDelegate` handles sheet dismissal, keeping the manager clean.

## 3. Authentication Flow — key design decision

Called from `SceneDelegate.sceneDidBecomeActive`, but **deferred inside the `AdManager` completion handler**:
```swift
AdManager.shared.initialize(from: vc) {
    GameKitManager.shared.authenticateLocalPlayer(presentingViewController: vc)
}
```
On a fresh launch the app must show the UMP consent → ATT prompt → SDK start chain. If Game Center's
sign-in UI tried to present at the same time, two view controllers would fight over the same
presentation context and one would fail silently. Nesting auth in the ads completion means sign-in
fires only after consent/ATT resolves. On later activations the ads flow is already done, so the
completion fires immediately and re-auth runs right away.

Auth is **idempotent**: `authenticateLocalPlayer` early-returns if already authenticated, so repeated
calls on every activation are safe no-ops.

## 4. Score Submission

At game over (`GameScene.swift`):
```swift
GameKitManager.shared.submitScore(heightInMeters: heightInMeters)
```
Uses the modern async API (`GKLeaderboard.submitScore`), double-guarded:
- No-ops if `!isAuthenticated` (offline / not signed in → silent skip, no crash)
- Skips non-positive scores (`score > 0`)

Game Center is the **online mirror** of the player's best, not the source of truth, so a failed
submission never affects gameplay or local records (sits alongside local persistence).

## 5. Leaderboard UI

Native `GKGameCenterViewController`, scope `.global`, all-time. Entry points:
- Main menu leaderboard button (`MenuScene.swift`)
- Settings screen (`SettingsScene.swift`)

If the user taps the leaderboard while not authenticated, `showLeaderboard` transparently triggers an
auth attempt instead of failing — no dead button for signed-out users.

## 6. Resilience Summary

| Scenario | Behavior |
|---|---|
| Not signed in / offline | All calls silently no-op; gameplay unaffected |
| Repeated activations | Auth is idempotent; re-runs harmlessly |
| Auth UI vs. ATT/consent collision | Avoided by deferring auth into ads-init completion |
| Submission failure | Caught, logged, swallowed — local bests still stand |
| Leaderboard tap while signed out | Falls back to triggering authentication |

## Status & Caveats

- ✅ In Summit: code complete and wired across launch, game over, menu, and settings.
- ⚠️ Before the leaderboard goes live, confirm the leaderboard ID actually exists in App Store Connect
  with the correct type / sort order. The code no-ops gracefully on a missing/mismatched ID, so it shows
  an **empty leaderboard rather than crashing** — easy to miss in testing. Keep the ID in one constant.
- ℹ️ Game Center sign-in requires a **real device** with an Apple ID signed into Game Center; the
  Simulator's sandbox behavior is unreliable for final verification.

## DTT-specific notes

- Leaderboard will likely track net worth / all-time earnings (Integer, highest-first).
- Decide whether Game Center supplements or replaces the staged Supabase leaderboard
  (see `docs/launch/leaderboard-go-live-runbook.md`).
