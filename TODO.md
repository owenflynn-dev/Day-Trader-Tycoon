# Day Trader Tycoon — To-Do

## Bugs to Fix
- [x] **Fully Staffed achievement** — fixed: description now says "10 Wall Street traders", check filters wallst only.
- [x] **Influence Spent bug** — fixed: influenceSpent tracked in all 4 spend paths.
- [x] **Offline earnings don't cover Yen** — fixed: tokyoRate * 0.5 * offlineSec applied on load.
- [x] **Offline cash skipped allTimeEarnings** — fixed: allTimeEarnings now incremented alongside lifetimeEarnings on offline load.
- [x] **Hire button directly hired instead of going to Staff tab** — fixed: now calls switchTab('managers').

## Features to Build
- [ ] **Sound effects** — Web Audio API, synthesized (no external files)
- [ ] **Options mini-game** — clicker mechanic, needs design decisions answered first (see below)
- [ ] **Chicago Open Outcry Pit** — tap/swipe commodity tickets, earns Global Influence to unlock London
- [ ] **London market** — 3rd market tab, £ currency, 6 assets, 5 managers, unlocks after Chicago

## Options Mini-Game — Open Questions
1. What drives leveling up? (Influence? Trades? Lifetime earnings? IPO count?)
2. What level unlocks Options?
3. Is the leverage per-asset or global?
4. How long does the leverage effect last?
5. How long is the cooldown?
6. What else does the level system unlock?
7. Does it replace or supplement the current Leverage system?

## Roadmap (Bigger Stuff)
- [ ] **Phase C** — Megabucks currency + visual perk tech tree
- [ ] **Phase D** — Calls/Puts/Shields (event prediction bets)
- [ ] **Phase E** — AI rival firms + leaderboard tab
- [ ] **Phase F** — Mobile wrap (Capacitor → TestFlight)
- [ ] **Phase G** — App Store launch, real backend, real multiplayer
