# Privacy Policy — Leaderboard Update (for build 10)

**Primary artifact: `docs/privacy-policy-leaderboard-draft.html`** — a complete
replacement privacy-policy page (leaderboard + AdMob + IAP + children +
retention + contact), already updated for the opt-in consent design. To
publish: fill in the `[DATE OF BUILD 10 RELEASE]` placeholder and copy it over
`privacy-policy.html` on `owenflynn-dev.github.io/daytrader-tycoon-support`.

Key requirements either way:
- The live policy's "We do not retain any data on external servers" sentence
  must be removed/amended — it becomes false once scores flow to Supabase.
- Must state participation is **opt-in only**, with the Shop toggle to stop
  sharing, and that opting out leaves the last entry on the board (removal by
  email request — service-role delete in the Supabase dashboard).
- Data listed: firm name (warn against real names), score, IPO/prestige
  count, random player ID (not linked to identity).

If you'd rather patch the existing live page instead of replacing it
wholesale, lift the `<h2>Global Leaderboard</h2>` and Data Retention sections
from the HTML draft.
