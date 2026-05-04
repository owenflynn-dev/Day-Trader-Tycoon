# Day Trader Tycoon — To-Do

## Bugs to Fix
- [ ] **Fully Staffed achievement** — says "Hire all 6 traders" but checks all 16 (Wall St + Tokyo). Fix the check or fix the description.
- [ ] **Influence Spent bug** — buying from the Influence Shop reduces your future IPO token count. `influenceSpent` is never tracked, so spending influence makes future IPOs give fewer tokens.
- [ ] **Offline earnings don't cover Yen** — closing the game while on Tokyo gives zero offline catch-up for ¥.

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
