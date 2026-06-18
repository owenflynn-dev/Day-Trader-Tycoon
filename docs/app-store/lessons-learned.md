# App Store Submission — Lessons Learned (from DTT v1.0)

Reference doc for future apps (Summit, Potato Peeler, anything else). DTT got rejected once (ATT issue), fixed it, then passed clean on resubmission. Below is what actually mattered, generalized beyond DTT's specific code.

## 1. ATT (App Tracking Transparency) — the thing that got DTT rejected

If your app shows ads (AdMob, etc.) or does any tracking, the ATT prompt ("Allow tracking?") has to actually fire on a fresh install, and it has to fire **before** any ad SDK makes its first ad request.

What went wrong in DTT v1.0: the ad SDK's preload was racing ahead of the ATT prompt by about a second. Reviewer saw ads loading before the tracking prompt appeared — instant rejection under Guideline 2.1.

The fix, generalized:
- Request ATT permission as early as possible in the app lifecycle (on scene/view becoming active, not buried behind menus).
- Gate ANY ad SDK initialization and first ad request behind the ATT authorization status resolving (`authorized`, `denied`, or `restricted` — anything but `notDetermined`). Use a timeout fallback (~10s) in case the user never responds.
- Test this on a **fresh install** on a **physical device**. Simulator and re-installs over an existing install won't show the prompt (iOS remembers the choice), so you'll think it's broken or think it's fine when it isn't.
- If Apple rejects again citing "ATT prompt not appearing": the most common cause on their end is the reviewer's test device has Settings → Privacy & Security → Tracking → "Allow Apps to Request to Track" toggled OFF globally. That makes iOS suppress the prompt entirely (status comes back `restricted`, never `notDetermined`) — it's not your bug. You can push back on this politely with a screen recording as evidence (see #5).

**Applies to:** Summit if it ever adds ads/AdMob. Not relevant to Potato Peeler unless it monetizes via ads.

## 2. In-App Purchases — the part nobody tells you

This one cost real time on DTT and will bite again on any app with IAP (Summit's monetization plan likely included).

- **First-time IAP products must be attached to the app version you're submitting**, not submitted standalone. The "Submit for Review" button on an individual IAP product page stays greyed out forever for first-time products — that's normal, not a bug. They only get reviewed when bundled with an app version submission.
- Before submitting: go to the version page in App Store Connect and confirm an "In-App Purchases" section appears showing your products in "Ready to Submit" / "Waiting for Review" state. If it's missing, the binary can still get approved but your IAPs won't be reviewed — meaning purchases will fail in production after launch.
- **IAP review screenshots have a strict, weird size requirement: 640×920.** Raw device screenshots (e.g. 1170×2532) and App Store marketing screenshot sizes (e.g. 1290×2796) both get rejected by the uploader with no useful error. Take any screenshot of the purchase screen, scale/letterbox it to exactly 640×920 (e.g. via `sips` on Mac), and you can reuse the same image for every product.
- Screenshot uploads on the IAP page auto-save — a greyed-out "Save" button means it already saved, don't go looking for a confirmation.
- A "Developer Action Needed" badge on an IAP product doesn't clear just because you fixed and saved it — it clears once the app version (with the product attached) gets resubmitted.

**Applies to:** any app with IAP — Summit especially.

## 3. Binary attachments (screen recordings, etc.)

If you're attaching a screen recording to justify something (ATT, a feature, anything):
- **Must be H.264 codec, `.mp4` extension, lowercase.** HEVC (the default on newer iPhones) and uppercase `.MP4` both silently fail the upload or get rejected.
- Record on a **physical device**, not simulator — reviewers trust it more and some behaviors (ATT, permissions) don't replicate properly in simulator anyway.
- Convert with `ffmpeg` if needed: `ffmpeg -i input.mov -c:v libx264 output.mp4`.

## 4. Reading a rejection correctly (saves a resubmission cycle)

Two categories, and they're handled completely differently:
- **Metadata-only rejection** (screenshots, description text, privacy labels, review notes, missing IAP attachment) → fix in App Store Connect and resubmit. **No new binary needed**, same build number.
- **Binary rejection** (actual code/behavior issue) → fix the code, **bump the build number**, re-archive, re-upload, resubmit.

Don't bump the build number unnecessarily — if it's metadata-only, a new binary just adds review queue time for nothing.

Always reply in the same App Review thread (don't start a new submission unless told to) — keeps context for the reviewer.

## 5. Review Notes are your first line of defense

If your app has anything that might look "incomplete" to a reviewer who's never seen it before — a "Coming Soon" tab, a feature gated behind a server flag, a placeholder screen — **explain it in the App Review notes before they find it**. DTT's "Coming Soon" leaderboard tab was preempted this way and never got flagged.

If they reject anyway despite the note: have a fallback ready (e.g., a quick build that hides the placeholder element entirely via a feature flag / `display:none`). Cheap insurance — write the flag into the code *before* submitting, not after a rejection.

## 6. Privacy labels (App Privacy section)

These need to match what the code actually does, and Apple checks. Build the declaration from your actual SDK's published guidance (e.g. Google's AdMob data-collection disclosure doc), not guesswork. Common categories to get right:
- Device ID / Advertising Data → "Used to Track You" + linked to Third-Party Advertising, if you show ads.
- Crash/diagnostic data → app-functionality only, not linked to identity (unless you tie it to accounts).
- Anything with no account system → mark data as "Not Linked to You" where true.

Your privacy policy page should explicitly name every SDK that collects data (AdMob, etc.) and describe the ATT prompt if applicable.

## 7. Security audit before submission — what actually matters

Don't over-engineer this. The real question is: **if someone reads your shipped code (and on a web-wrapped app like Capacitor, they can — it's unminified HTML/JS sitting in the bundle), can they do anything harmful?**
- No backend / no accounts / no server-side state → worst case is a player editing their own local save to cheat in single-player. That harms nobody, ship it.
- The moment you add a real backend (Supabase, leaderboards, accounts) — that's when secrets, RLS policies, and rate-limiting actually matter. Audit *then*, not before.
- Public IDs (AdMob ad unit IDs, etc.) in shipped code are fine — they're meant to be public.

**Applies most to:** Summit and Potato Peeler if/when they add any server-side leaderboard or account system.

## 8. Build hygiene & encryption compliance (Capacitor / native config)

Small project-config things that block an archive or add friction every submit:
- Set **`ITSAppUsesNonExemptEncryption`** in `Info.plist` (almost always `false` for an app that only uses standard HTTPS) so you skip the export-compliance questionnaire on every single submission.
- On a **Capacitor / WebView app**, double-check the native scaffolding actually made it into the `.xcodeproj`: a valid `UIApplicationSceneManifest` + registered scene delegate, and **arm64** capability. The Capacitor templates have drifted here, and a missing scene manifest is what silently breaks ATT (see #1) — the scene callbacks never fire.
- Bump `CURRENT_PROJECT_VERSION` in **both** the Debug and Release build configs. A stale number in one config has caused confusing archive states.
- Set the right **primary category** early (DTT had to add "Games" mid-process).

**Applies to:** any Capacitor/web-wrapped app — Summit and Potato Peeler both.

## 9. Input / XSS hardening for web-wrapped apps

Web-wrapped apps (Capacitor, etc.) get extra scrutiny because the JS is right there in the bundle, and any user-controlled string rendered into the DOM is a potential injection. On DTT we escaped user-entered names before rendering and removed a raw save import/export feature that was an injection vector.
- **Escape anything user-controlled before `innerHTML`** (names, custom labels, anything typed).
- Don't ship import/export of raw save blobs unless you sanitize them — it's an easy code-execution path and a reviewer red flag.

**Applies to:** any app that renders user-entered or dynamic text — most things.

## 10. General pre-submission checklist (condensed)

1. Fresh install on physical device — test ATT prompt timing if you have ads.
2. Confirm IAP products are attached to the version and in "Ready to Submit" state (if app has IAP).
3. IAP screenshots are exactly 640×920.
4. Any video attachments: H.264, lowercase `.mp4`.
5. Privacy labels match actual SDK behavior.
6. Anything that could look "incomplete" → explained in Review Notes, with a feature-flag fallback ready.
7. Restore Purchases works and is reachable (if IAP) — Apple checks this on every review.
8. Build number bumped only if shipping new binary code (and bumped in *both* build configs).
9. `ITSAppUsesNonExemptEncryption` set in Info.plist; scene manifest + arm64 present (Capacitor).
10. User-controlled strings escaped before rendering; no raw save import/export.

## 11. AdMob ads showing nothing after a fresh launch (NOT a code bug)

Post-launch, DTT's rewarded ads served nothing — every tap toasted "Ad skipped." Spent the investigation proving it was **account/serving setup, not code.** On a freshly launched app this is almost always the case: if the integration ever worked in testing, don't rewrite ad code.

**Diagnose from the AdMob dashboard (App overview), read two numbers:**
- **Requests > 0** → your app's ad code is firing correctly. ✅
- **Match rate = 0%** → AdMob has no ad to serve (no-fill) → the blocker is account/review, not code.
  (DTT showed 24 requests, 0% match → integration perfect, serving blocked.)

**Prove the integration (optional):** flip an `ADMOB_TEST_MODE` flag to Google's official test ad unit IDs, run **on-device via Xcode (`Run`, not Archive)**. Test ads always fill → confirms code/plugin/ATT/native config are all fine.
⚠️ **NEVER Archive/submit with test mode on, and never click your own real ads** — either = AdMob account ban. Flip back to `false` + re-sync immediately after testing.

**The three gates for real ads to actually serve:**
1. **Payments account** — payment method + **tax info** completed. (Identity verification is earnings-gated, not an upfront blocker.)
2. **App linked + reviewed** — link the AdMob app to its App Store listing (App settings → App store details). Then **"Approval status: Requires review" clears automatically over a few days**; real ads serve once it's **"Ready."**
3. **app-ads.txt verified** — see below.

**app-ads.txt — the #1 gotcha:**
- Content is one line AdMob gives you: `google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0`
- Must live at the **DOMAIN ROOT** of the developer URL on your store listing: `https://yourdomain.com/app-ads.txt` — **never a subfolder.**
- **GitHub Pages trick:** create a repo named **exactly** `username.github.io` (user-site), put `app-ads.txt` at its root, enable Pages (main / root). Serves at `https://username.github.io/app-ads.txt`. A *project* repo (`/repo-name/`) will **NOT** work — AdMob strips the path to the root domain.
- Verify with `curl https://username.github.io/app-ads.txt` → must return **200** + the exact line (a 404 returns GitHub's HTML error page).
- Then in AdMob → App settings → App verification → **click "Verify app"** (it does NOT auto-verify instantly; the button triggers the crawl).
- **Reusable across all your apps:** the same `app-ads.txt` (same publisher line) covers every app under one AdMob account. Only the per-app **App ID** and ad **unit IDs** differ.
- **⚠️ The listing MUST have a developer website, or verification can't even start.** AdMob's exact error is *"We didn't find a developer website in your app listing on App Store."* AdMob reads the **Marketing URL** off your App Store product page → derives the domain → crawls `<domain>/app-ads.txt`. No Marketing URL = no domain to crawl = the file is never even checked (the file being correct is irrelevant). DTT v1.0 shipped with **no Marketing URL**, so verification kept failing despite a perfect, 200-OK app-ads.txt.
  - **Fix:** App Store Connect → version → **General Information → Marketing URL** = the domain hosting app-ads.txt (e.g. `https://username.github.io`). Then in AdMob click **"Check for updates" / "Verify app."**
  - **⏱️ Do this BEFORE your first submission.** Marketing URL is **version-locked metadata** — once a version is live you can only change it via a *new* version/metadata update (build can be reused). The "Developer Website" link also only appears on the public product page once that version is **live**, so verification can't complete until then. Set it on v1.0 to avoid an extra metadata-only release.
  - Not required for Apple **approval** and does **not** stop ads serving — it only gates AdMob's ownership *verification*. So never pull a version from review just to add it; add it now if the field is still editable, else in the next metadata update.

**Auto vs. manual:**
| Item | Automatic? |
|------|-----------|
| Approval status ("Requires review" → "Ready") | ✅ Auto (a few days) |
| Developer website (Marketing URL) on listing | ⚠️ Must set manually — verification can't start without it |
| App verification (app-ads.txt) | ⚠️ Click **"Verify app"** (needs Marketing URL live first) |
| Match rate rising above 0% | ✅ Auto once Ready + verified |

**Applies to:** any app monetizing via AdMob (Summit, future games). Tie-in with #1 (ATT must fire before the first ad request).

## 12. iOS background save (data-loss gap in WKWebView games)

`window.addEventListener('beforeunload', save)` is **unreliable on iOS/WKWebView** — it often doesn't fire when the OS suspends or kills a backgrounded app. A periodic autosave (e.g. every 5s) still loses up to that interval of progress, plus the `lastSavedAt` timestamp that offline-earnings math depends on.

**Fix:** also save on `visibilitychange` when `document.hidden` — the dependable mobile signal:
```js
document.addEventListener('visibilitychange', () => {
  if (document.hidden) save();
});
```
Keep `beforeunload` too (fine on desktop/web).

**Applies to:** any Capacitor/WKWebView app that persists state to localStorage.

---
*Written 2026-06-13 after DTT build 9 passed review. Updated 2026-06-15 with AdMob serving + iOS background-save lessons after going live. Updated 2026-06-17 with the app-ads.txt "no developer website / Marketing URL on listing" verification gotcha. Update this file as new apps surface new gotchas.*
