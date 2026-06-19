# Leaderboard Go-Live Runbook

Everything code-side is ALREADY DONE (consent prompt, opt-out toggle, submit gate
— shipped inert behind `LEADERBOARD_ENABLED = false`). When Supabase Pro is
purchased, the steps below are all that remain. Estimated time: ~30 minutes
plus App Review.

## Prerequisites
- [ ] Supabase Pro purchased (or a free-plan slot available)
- [ ] App approved & live on the App Store (don't flip the flag before launch)

## Step 1 — Supabase project (~10 min)
1. Create project **"Day Trader Tycoon"** in org `criyajexsmlyvfxntsif`, region **us-east-1**.
2. SQL Editor → run `docs/supabase/leaderboard.sql` in full (table, guard trigger, RLS).
3. Verify: Table Editor shows `leaderboard` with RLS enabled; manually insert a
   test row via SQL, confirm anon `DELETE` is rejected.
4. Copy the **Project URL** and **anon/publishable key** (Settings → API).

## Step 2 — Code flip (one edit, 3 constants)
In root `index.html` (source of truth), near the top of the `<script>` block:
1. `SUPABASE_URL` → real project URL
2. `SUPABASE_ANON_KEY` → real anon key
3. `LEADERBOARD_ENABLED` → `true`
4. Bump the build number in Xcode (next: 10) and the marketing version if desired.
5. `npm run sync` (copies → www/ + cap sync).

## Step 3 — Privacy policy (BEFORE submitting build 10)
The live policy says "We do not retain any data on external servers" — false once
scores flow. A complete replacement page is ready at
`docs/privacy-policy-leaderboard-draft.html` (already covers opt-in leaderboard,
AdMob, IAP, children, retention): fill in the `[DATE OF BUILD 10 RELEASE]`
placeholder and copy it over
`owenflynn-dev.github.io/daytrader-tycoon-support/privacy-policy.html`.
See `docs/launch/privacy-policy-leaderboard-section.md` for the patch-instead-of-replace option.

## Step 4 — App Privacy declaration (App Store Connect)
App Store Connect → App Privacy → add, all as **Data Not Linked to You**,
purpose **App Functionality**:
- **User Content** → "Other User Content" (firm name — free text)
- **Identifiers** → "User ID" (random `p_…` player ID, not tied to identity)
- Score/IPO count: likely fits under "Gameplay Content" if Apple's categories
  list it at the time; otherwise covered by User Content. Check Apple's
  current category list when filling this in.
- NO tracking declaration needed (nothing crosses apps/companies).

## Step 5 — Device test (sandbox/TestFlight, before submission)
- [ ] Fresh install → LEADERS tab → consent modal appears ONCE per session
- [ ] "No thanks" → no row appears in Supabase Table Editor; banner offers Join
- [ ] "Join" → row appears within ~30 s (save debounce); firm name correct
- [ ] Shop toggle shows "Public — tap to hide"; tapping flips to Hidden and
      stops updates (existing row stays — expected, no anon delete)
- [ ] Existing-save upgrade: old save loads, `lbConsent` is null, prompt fires
      on first LEADERS visit, nothing was auto-submitted before that
- [ ] XSS spot check: name a firm `<b>x</b>` — renders as literal text on board

## Step 6 — Submit build 10
Normal submission. The IAP review-screenshot pain from build 9 doesn't recur
(IAPs are approved with the version; only NEW IAPs need review screenshots —
which must be 640×920, see `~/Desktop/DTT-IAP-640x920.png`).

## Consent design (why it's built this way)
- **Opt-in, not opt-out**: schema has no anon DELETE (anti-forgery), so a row
  once posted can't be removed by the client. Consent before first submit
  avoids ever posting someone who didn't ask.
- Firm names are free text → potentially real names → treated as public user
  content with explicit notice in the consent modal.
- Removal requests (if a player ever emails): delete their row with the
  service role key in the Supabase dashboard, filter by firm_name.

## Day-one launch checklist (separate from leaderboard — run when build 9 is approved)
- [ ] Download from the real App Store on-device (not TestFlight)
- [ ] Make one real production IAP (cheapest: mb_5 $0.99) — sandbox passing ≠ production receipts working
- [ ] Confirm real AdMob ads serve (not "Test Ad" labels) and ATT prompt → ad flow works on fresh install
- [ ] Check App Store Connect → Sales next day for the IAP; refund yourself via reportaproblem.apple.com if desired
- [ ] Respond to first reviews; request promo codes (100/version) for marketing
