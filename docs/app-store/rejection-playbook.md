# App Store Rejection Playbook — Day Trader Tycoon

Submission: 1.0 (build 9), June 2026. Prior rejection: Guideline 2.1, ATT prompt
not appearing on 1.0 (6) — fixed in build 7+ (SceneDelegate + scene manifest),
recording attached to this submission.

## How to read a rejection

- **Metadata-only rejections** (screenshots, description, privacy labels, review
  notes) can be fixed and resubmitted **without a new binary** — same build 9.
- **Binary rejections** need a code fix + new build number (**next: 10** —
  `CURRENT_PROJECT_VERSION` in `ios/App/App.xcodeproj/project.pbxproj`, both configs).
- Always reply in the same App Review thread; attachments must use lowercase
  extensions from their supported list (H.264 .mp4 works — HEVC and uppercase
  .MP4 have failed before).

## Scenario 1 — "ATT prompt still not appearing" (Guideline 2.1, repeat)

Verified working in build 9: prompt fires from `SceneDelegate.sceneDidBecomeActive`
~1s after launch; AdMob defers its first ad request until the status resolves.

Most likely cause if a reviewer still can't see it: **their device has
Settings → Privacy & Security → Tracking → "Allow Apps to Request to Track"
toggled OFF**, which makes iOS suppress the prompt system-wide (status comes
back `restricted`/`denied`, never `notDetermined`).

Reply template:
> The ATT prompt is implemented natively (SceneDelegate, on scene activation) and
> appears ~1 second after first launch on a fresh install — demonstrated in the
> attached recording DTT-ATT-recording.mp4 captured on a physical iPhone. Note
> that iOS suppresses the prompt entirely when "Allow Apps to Request to Track"
> (Settings → Privacy & Security → Tracking) is disabled on the review device,
> or when the app was previously installed and the permission already resolved.
> Could you confirm the device had tracking requests enabled and the app was a
> fresh install? We're happy to provide any further documentation.

## Scenario 2 — "App appears incomplete: Coming Soon tab" (Guideline 2.1)

Preempted in the review notes (intentional, server feature ships post-launch).
If they reject anyway:

- **Option A (reply, no new build):** point to the notes; the tab is a teaser for
  a post-launch online feature, the game is fully playable without it.
- **Option B (new build, ~5 min):** hide the LEADERS nav button while halted —
  wrap the button at `index.html` (`switchTab('rivals')` nav entry, line 2023)
  in a `LEADERBOARD_ENABLED` check or `style="display:none"`. Bump to build 10,
  re-archive, resubmit. Choose B if the reviewer explicitly says teaser tabs
  aren't acceptable.

## Scenario 3 — IAP problems (Guideline 2.1 / 3.1.1)

- "Restore Purchases" exists: Shop modal button → `Monetization.restorePurchases()`
  (index.html:2109, full implementation at :3249). Cite it if questioned.
- **First-time IAP gotcha:** new IAP products must be attached to the version
  submission and in "Ready to Submit" state. If rejected with "we could not
  locate/review your IAPs": App Store Connect → app version page → In-App
  Purchases section → add all products → resubmit (metadata-only, no new build).
- "IAP could not be purchased in review": usually the product wasn't attached or
  the Paid Apps agreement/banking isn't fully active — check
  Business → Agreements before replying.

## Scenario 4 — "Ad button does nothing"

New AdMob apps get limited fill; in review the rewarded ad may simply not load.
The code fails gracefully (callback fires with `false`, button stays usable).
Reply that ad inventory is limited for new apps, the feature degrades gracefully,
and no functionality is lost — gold/income are earnable without ads.

## Scenario 5 — Crash report attached

1. Ask for / download the .crash from the rejection.
2. Symbolicate against the build 9 archive (Xcode → Organizer → right-click
   archive → Show in Finder → dSYMs).
3. Fix, bump to build 10, resubmit with a note describing the fix.

## Scenario 6 — Privacy label mismatch (Guideline 5.1.1/5.1.2)

Current declaration (verified consistent June 2026): Device ID + Advertising
Data marked "Used to Track You" + Third-Party Advertising; Product Interaction
advertising-only; Crash Data app-functionality; everything Not Linked (no
accounts). Privacy policy names AdMob, IDFA, and the ATT prompt. If they claim
a mismatch, ask them to specify the data type — the labels were built from
Google's published AdMob disclosure guidance.

## Quick facts for any reply

- No account system; no sign-in; all progress on-device (localStorage).
- No data leaves the device in build 9 except AdMob ad requests (post-ATT) and
  StoreKit purchases. The Supabase leaderboard is fully disabled behind
  `LEADERBOARD_ENABLED = false`.
- Ads: rewarded-video only, optional, user-initiated.
- IAP: gold/megabuck packs + Starter Pack (non-consumable, removes ads).
- Contact: owenflynn2093@gmail.com / +1 602 363 3524.
