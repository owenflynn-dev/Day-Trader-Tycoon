# SVG Icon System + Global Leaderboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all emoji/HTML-entity icons in `www/index.html` with inline SVG sprites, and add a real Supabase-backed global leaderboard to the Rivals tab.

**Architecture:**
- Single file (`www/index.html`, 7722 lines). Everything lives in here — HTML, CSS, and all JS.
- SVG approach: one `<svg>` sprite block (all `<symbol>` elements) injected at top of `<body>`, plus a `svgIcon(name)` JS helper that emits `<svg><use href="#name"/></svg>`. Data arrays change their `icon:` values from HTML entities to short name strings.
- Supabase approach: pure REST (`fetch`) with anon key — no SDK. Player identified by a UUID in `localStorage`. Score submitted on every `save()` call, debounced to once per 30 s. Global leaderboard shown at the top of the Rivals tab; AI rivals mechanic moves below it.

**Tech Stack:** Vanilla JS, inline SVG sprites (24×24 viewBox, stroke-based), Supabase REST API (anon key), `localStorage` for player UUID persistence.

---

## Icon Name Mapping Reference

This is the master lookup used in Tasks 1–4. The `old` column is the HTML entity currently in the file; `name` is what the `icon:` field becomes.

| name | old entity | used in |
|------|-----------|---------|
| `home` | `&#127968;` | bottom-bar HOME |
| `menu` | `&#9783;` | bottom-bar NAVIGATE |
| `gear` | `&#9881;` | bottom-bar MENU |
| `briefcase` | `&#128188;` | nav STAFF, PRVT asset, CFO manager, STAFFED achievement, Hedge Mgr quest |
| `lightning` | `&#9889;` | nav PERKS, quantum HFT, speed skill branch, several achievements/quests |
| `star` | `&#11088;` | nav GOALS |
| `chart-up` | `&#128200;` | nav OPTIONS, compound skill, achievement/quests |
| `columns` | `&#127963;` | nav PIT, Congressional Buddy, Senate Connections, daily pit quest |
| `trophy` | `&#127942;` | nav LEADERS, ms-amp skill |
| `newspaper` | `&#128240;` | nav NEWS, event daily quest |
| `building` | `&#127970;` | IPO btn, FEDS asset, corner-office perk, fed-friend, lifestyle fed-chair, buy-positions quest |
| `medal` | `&#129689;` | gold chip, goldsmith quest |
| `diamond` | `&#128142;` | megabucks chip, diamond-hands achievement |
| `speaker` | `&#128266;` | mute button |
| `dollar` | `&#128181;` | PNNY asset, first-trade achievement, penny-pincher, first-steps quest, big-spender quest |
| `rocket` | `&#128640;` | MEME asset, meme-lord, leverage-king, all LEVERAGE_TIERS, light-speed skill, q_leverage_rush |
| `candy` | `&#127852;` | DOGZ asset, crypto-curious quest |
| `robot` | `&#129302;` | AIBL asset, T_SUMO asset, algo-edge skill, quant manager, dq_trades_2k, the-algorithm |
| `coins` | `&#128176;` | HEDG asset, capital skill branch, first-million achievement, century-club, trillion-club |
| `boat` | `&#128674;` | YACT asset, yacht-club achievement, yacht-bound quest, lifestyle yacht |
| `shield` | `&#128737;` | SOVR asset, plutocracy influence shop |
| `globe` | `&#127760;` | GLBL asset |
| `sushi` | `&#127843;` | T_SUSHI asset |
| `sparkle` | `&#127884;` | T_ANIME asset, tokyo-tourist achievement, q_neo_tokyo |
| `mic` | `&#127908;` | T_KARAOKE asset |
| `train` | `&#128646;` | T_NEKO asset |
| `paw` | `&#128050;` | T_TOYOTA asset |
| `flag` | `&#127981;` | L_STERLING asset, governor manager, london-calling achievement |
| `tea` | `&#127861;` | L_TEA asset |
| `card` | `&#128179;` | L_BANK asset |
| `crown` | `&#128081;` | L_CROWN asset, dynasty achievement, sk_dynasty |
| `oil` | `&#128739;` | L_OIL asset |
| `castle` | `&#127984;` | L_PALACE asset, q_last_samurai |
| `coffee` | `&#9749;` | morningCoffee boost |
| `laptop` | `&#128187;` | bloomberg boost |
| `plane` | `&#128747;` | privateJet boost, lifestyle jet |
| `computer` | `&#128421;` | fiber_link HFT, q_speed_freak |
| `signal` | `&#128225;` | microwave HFT, intel skill branch |
| `server` | `&#128442;` | colocation HFT |
| `hand` | `&#128075;` | sk_fast_hands, q_click_trader, dq_manual_50 |
| `clock` | `&#128338;` | sk_pre_market |
| `chart` | `&#128202;` | sk_scanner, dark-pool influence, diversified achievement, q_diversified, dq_day_trader icon |
| `brain` | `&#129504;` | sk_sentiment, the-algorithm manager |
| `clipboard` | `&#128203;` | sk_portfolio |
| `circle-up` | `&#128994;` | sk_bull_ext |
| `circle-down` | `&#128308;` | sk_bear_buf |
| `star-glow` | `&#127775;` | sk_bias, sk_legend, first-million, triple-digit achievements |
| `city` | `&#127961;` | lifestyle penthouse |
| `palette` | `&#127912;` | lifestyle art |
| `island` | `&#127965;` | lifestyle island |
| `medal-sport` | `&#127944;` | lifestyle nfl_team |
| `moon` | `&#127769;` | lifestyle moon-colony |
| `bell` | `&#128276;` | heavens-lottery influence, ipo-day achievement, influencer quest |
| `link` | `&#128279;` | penny-pipeline influence |
| `cloud` | `&#127774;` | volatility-hedge influence |
| `hourglass` | `&#9203;` | TIME_WARPS, time-lord quest |
| `wolf` | `&#128054;` | wolf-of-wall-st achievement |
| `person` | `&#128104;&#8205;&#128188;` | first-hire achievement |
| `muscle` | `&#128170;` | dq_manual_200 |
| `cart` | `&#128722;` | q_buying_in, dq_buy_25 |
| `bill` | `&#128184;` | day-trader quest, dq_buy_500 |
| `guitar` | `&#127929;` | q_mega_holder ("Mega Ticket" — musical keyboard emoji used as placeholder) |
| `yen-sign` | `&#165;` | q_yen_millionaire, dq_yen_earn |
| `heart` | `&#129505;` | q_survivor |
| `sword` | `&#129354;` | dq_pit_20 (Pit Champion) |
| `building-old` | `&#127974;` | ipo-veteran, ipo-machine achievements |
| `hat` | none (literal 🎩) | r_old rival |
| `bear-face` | none (literal 🐻) | r_bear rival |
| `moon-dark` | none (literal 🌑) | r_dark rival |

---

## SVG Path Data

All icons use `viewBox="0 0 24 24"`, `fill="none"`, `stroke="currentColor"`, `stroke-width="2"`, `stroke-linecap="round"`, `stroke-linejoin="round"` unless stated otherwise.

```
home:        "M3 12L12 3l9 9M5 10v9a1 1 0 001 1h4v-5h4v5h4a1 1 0 001-1v-9"
menu:        "M3 6h18M3 12h18M3 18h18"
gear:        "M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"
briefcase:   "M6 6V4a2 2 0 012-2h8a2 2 0 012 2v2M4 6h16v14a2 2 0 01-2 2H6a2 2 0 01-2-2zM8 11h8"
lightning:   "M13 2L3 14h9l-1 8 10-12h-9z"
star:        "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z"
chart-up:    "M3 17l4-4 4 3 5-7 3 3M21 21H3"
columns:     "M4 20V4h16v16H4zM4 4l5 8-5 8M20 4l-5 8 5 8M4 12h16"
trophy:      "M8 21h8M12 17v4M5 3h14v9a7 7 0 01-14 0zM5 3H2v5a3 3 0 003 3M19 3h3v5a3 3 0 01-3 3"
newspaper:   "M4 4h12v14H4zM14 4h6v4h-6zM14 12h6M14 16h6M7 8h6M7 12h4M7 16h4"
building:    "M4 21h16M4 21V4a1 1 0 011-1h14a1 1 0 011 1v17M9 9h2M9 13h2M13 9h2M13 13h2M10 21v-4h4v4"
medal:       "M12 2l1.5 4.6h4.8l-3.9 2.8 1.5 4.6L12 11.2l-3.9 2.8 1.5-4.6L5.7 6.6h4.8z"
diamond:     "M12 3L4 10l8 11 8-11zM4 10h16"
speaker:     "M11 5L6 9H2v6h4l5 4zM19.07 4.93a10 10 0 010 14.14M15.54 8.46a5 5 0 010 7.07"
dollar:      "M12 2v20M17 5H9.5a3.5 3.5 0 100 7h5a3.5 3.5 0 110 7H6"
rocket:      "M12 2c-3 4-4 8-4 11a4 4 0 008 0c0-3-1-7-4-11zM9 13l-4 3M15 13l4 3M10 17h4"
candy:       "M9.5 9.5a4.5 4.5 0 106.36 6.36M9.5 9.5L15.86 15.86M9.5 9.5l-5-5M15.86 15.86l5 5"
robot:       "M9 3h6M10 3v2M14 3v2M5 7h14a1 1 0 011 1v8a1 1 0 01-1 1H5a1 1 0 01-1-1V8a1 1 0 011-1zM8 12h0M16 12h0M10 15h4M12 17v5M9 22h6"
coins:       "M12 2a5 5 0 100 10A5 5 0 0012 2zM4 15a4 4 0 018 0M8 15h8M9 21h6M8 18h8"
boat:        "M3 18h18M5 18V10l7-5 7 5v8M12 5v6M9 11h6"
shield:      "M12 2l8 3v6c0 5.5-3.5 9.74-8 11C7.5 20.74 4 16.5 4 11V5z"
globe:       "M12 2a10 10 0 100 20A10 10 0 0012 2zM2 12h20M12 2a15.3 15.3 0 010 20M12 2a15.3 15.3 0 000 20"
sushi:       "M6 12a6 6 0 0012 0H6zM6 12V9a3 3 0 013-3M18 12V9a3 3 0 00-3-3M9 6h6M12 3v3"
sparkle:     "M12 3v2M12 19v2M3 12h2M19 12h2M6.34 6.34l1.42 1.42M16.24 16.24l1.42 1.42M6.34 17.66l1.42-1.42M16.24 7.76l1.42-1.42M12 8a4 4 0 100 8 4 4 0 000-8z"
mic:         "M12 2a3 3 0 00-3 3v6a3 3 0 006 0V5a3 3 0 00-3-3zM5 11a7 7 0 0014 0M12 19v3M9 22h6"
train:       "M4 11V8a2 2 0 012-2h12a2 2 0 012 2v3M4 11v7a2 2 0 002 2h12a2 2 0 002-2v-7M4 11h16M9 20l-2 2M15 20l2 2M9 11h0M15 11h0"
paw:         "M11 5.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM15 5.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM7.5 8a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM17 8.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM12 12c-3 0-6 2-6 5 0 4 2.5 5 6 5s6-1 6-5c0-3-3-5-6-5z"
flag:        "M4 15V5M4 5h12l-3 5 3 5H4"
tea:         "M5 8h14l-2 10H7zM17 8V6a1 1 0 00-1-1H8a1 1 0 00-1 1v2M16 18a2 2 0 012 2H6a2 2 0 012-2"
card:        "M2 7h20v12H2zM2 11h20M6 15h4"
crown:       "M2 19h20M2 19l3-10 5 5L12 5l2 9 5-5 3 10"
oil:         "M12 2l5 10H7zM7 12h10v5a5 5 0 01-10 0zM10 17v5M14 17v5"
castle:      "M4 21h16M6 21V12l6-9 6 9v9M3 12h18M10 21v-5h4v5"
coffee:      "M17 8h1a4 4 0 010 8h-1M3 8h14v9a2 2 0 01-2 2H5a2 2 0 01-2-2zM6 2v2M10 2v2M14 2v2"
laptop:      "M4 14h16M4 14V6a1 1 0 011-1h14a1 1 0 011 1v8M4 14H2v4h20v-4h-2M9 21h6"
plane:       "M22 2L11 13M22 2l-5 20-4-9-9-4z"
computer:    "M4 4h16a1 1 0 011 1v11a1 1 0 01-1 1H4a1 1 0 01-1-1V5a1 1 0 011-1zM8 20h8M12 16v4"
signal:      "M2 12h2M22 12h-2M12 2v2M12 20v2M6 6l1.41 1.41M16.59 16.59L18 18M6 18l1.41-1.41M16.59 7.41L18 6M12 7a5 5 0 100 10 5 5 0 000-10z"
server:      "M4 5h16a1 1 0 011 1v4a1 1 0 01-1 1H4a1 1 0 01-1-1V6a1 1 0 011-1zM4 13h16a1 1 0 011 1v4a1 1 0 01-1 1H4a1 1 0 01-1-1v-4a1 1 0 011-1zM7 8h0M7 16h0M10 8h4M10 16h4"
hand:        "M8 10V6a2 2 0 014 0v4M12 10V4a2 2 0 014 0v6M16 10a2 2 0 014 0v4l-4 6H8l-4-4a2 2 0 010-4l4 2V10a2 2 0 014 0z"
clock:       "M12 2a10 10 0 100 20A10 10 0 0012 2zM12 6v6l4 2"
chart:       "M4 18V9l4 4 4-8 4 5 4-5M4 22h16"
brain:       "M12 5a7 7 0 00-7 7c0 2.5 1.4 4.7 3.5 5.9M12 5a7 7 0 017 7c0 2.5-1.4 4.7-3.5 5.9M12 5v14M8.5 17.9L12 19l3.5-1.1M9 12h6M10 9v6M14 9v6"
clipboard:   "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 012-2h2a2 2 0 012 2M9 12h6M9 16h4"
circle-up:   "M12 22a10 10 0 100-20 10 10 0 000 20zM12 8v8M8 12l4-4 4 4"
circle-down: "M12 2a10 10 0 100 20A10 10 0 0012 2zM12 16V8M8 12l4 4 4-4"
star-glow:   "M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.3L12 17l-6.2 4.2 2.4-7.3L2 9.4h7.6z"
city:        "M2 21h20M4 21V9h6V4h8v17M7 13h2M7 17h2M15 8h2M15 12h2M15 16h2M4 9h2M4 13h2M4 17h2"
palette:     "M12 2a10 10 0 00-7 17c1.5 1.5 3 2 5 2 1 0 2-1 2-2 0-.5-.1-.8-.3-1.1.4-.6.3-1.5-.5-2.5-1-1.3-.2-3.4 1.8-3.4 3 0 5 2.5 5 5.5 0 5-4 9-9 9z"
island:      "M12 10V2M9 5l3-3 3 3M8 21c0-3.5 4-8 4-8s4 4.5 4 8M2 21h20M7 21c1-2 2-4 5-4s4 2 5 4"
medal-sport: "M12 15l-7 7M12 15l7 7M5 3h14M5 3a7 7 0 007 12 7 7 0 007-12"
moon:        "M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"
bell:        "M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"
link:        "M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"
cloud:       "M18 10h-1.26A8 8 0 109 20h9a5 5 0 000-10z"
hourglass:   "M5 3h14M5 21h14M8 3v5l4 5-4 5v3M16 3v5l-4 5 4 5v3"
wolf:        "M8 3L4 8l-1 6 3 4 6 2 6-2 3-4-1-6-4-5M12 3l2 5M12 3l-2 5M12 14c0 2 0 4-2 6M12 14c0 2 0 4 2 6"
person:      "M12 11a4 4 0 100-8 4 4 0 000 8zM3 21a9 9 0 0118 0"
muscle:      "M6.5 6.5A3.5 3.5 0 003 10c0 2.5 3 4.5 3.5 5L12 22l5.5-7S21 13 21 10a3.5 3.5 0 00-6.5-1.5 3.5 3.5 0 00-8 0"
cart:        "M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4zM3 6h18M16 10a4 4 0 01-8 0"
bill:        "M2 6h20v12H2zM6 10h12M6 14h8"
guitar:      "M12 12a4 4 0 100-8 4 4 0 000 8zM12 12l5 9M9 15l-5 7"
yen-sign:    "M12 2L6 10h12zM6 10l6 4 6-4M12 14v8M9 18h6"
heart:       "M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"
sword:       "M5 19l14-14M9 5h10v10M15 5l4 4"
building-old:"M2 20h20M4 20V9h16v11M10 9V5h4v4M7 14h10M7 17h10"
hat:         "M4 14c0-4 3.6-7 8-7s8 3 8 7M3 14h18M6 14v5h12v-5"
bear-face:   "M5 8a3 3 0 000 6M19 8a3 3 0 010 6M7 7h10v9a5 5 0 01-10 0zM10 12h0M14 12h0M10 16a2.5 2.5 0 005 0"
moon-dark:   "M12 22a10 10 0 01-7.07-17.07A8 8 0 1019.07 14.93 10 10 0 0112 22z"
```

---

## File Map

| File | Change |
|------|--------|
| `www/index.html` lines 1760-1762 (just after `<body>`) | Add SVG sprite block |
| `www/index.html` lines 1760-1762 (just after SVG block) | Add `svgIcon()` helper in `<script>` tag |
| `www/index.html` lines 86-131 | Add `.svg-icon` CSS |
| `www/index.html` lines 2185-2214 | ASSETS `icon:` → name strings |
| `www/index.html` lines 2245-2260 | BOOSTS + HFT_PERKS `icon:` → name strings |
| `www/index.html` lines 2284-2315 | SKILL_TREE `icon:` → name strings |
| `www/index.html` lines 2346-2374 | UNLOCKS `icon:` → name strings |
| `www/index.html` lines 2378-2414 | QUESTS `icon:` → name strings |
| `www/index.html` lines 2484-2501 | LIFESTYLE `icon:` → name strings |
| `www/index.html` lines 2506-2525 | INFLUENCE_SHOP `icon:` → name strings |
| `www/index.html` lines 2534-2557 | LEVERAGE_TIERS + TIME_WARPS `icon:` → name strings |
| `www/index.html` lines 2428-2478 | PREMIUM_MANAGERS `icon:` → name strings |
| `www/index.html` lines 3300-3317 | DAILY_QUEST_POOL `icon:` → name strings |
| `www/index.html` lines 5498-5538 | RIVALS `icon:` → name strings |
| `www/index.html` lines 6949-6962 | WELCOME_SLIDES `icon:` → name strings |
| `www/index.html` render functions | Replace `${x.icon}` with `${svgIcon(x.icon)}` |
| `www/index.html` static nav HTML (~1875-1913) | Replace HTML entity icons with `<svg><use>` |
| `www/index.html` lines 5636-5760 | Rivals tab: add global LB section on top |
| `www/index.html` lines 3350-3370 (save function) | Hook in Supabase score submission |
| `www/index.html` `<head>` section | Add SUPABASE_URL / SUPABASE_ANON_KEY constants |

---

## Task 1: Add SVG Sprite Block, Helper, and CSS

**Files:**
- Modify: `www/index.html` — insert after `<body>` opening tag (line 1760), and add `<script>` with helper just after

- [ ] **Step 1.1: Insert SVG sprite block**

Locate line 1760: `<body>`. Insert immediately after it:

```html
<svg xmlns="http://www.w3.org/2000/svg" style="display:none" id="svg-sprite">
  <symbol id="home" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12L12 3l9 9M5 10v9a1 1 0 001 1h4v-5h4v5h4a1 1 0 001-1v-9"/></symbol>
  <symbol id="menu" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M3 12h18M3 18h18"/></symbol>
  <symbol id="gear" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></symbol>
  <symbol id="briefcase" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 6V4a2 2 0 012-2h8a2 2 0 012 2v2M4 6h16v14a2 2 0 01-2 2H6a2 2 0 01-2-2zM8 11h8"/></symbol>
  <symbol id="lightning" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9z"/></symbol>
  <symbol id="star" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z"/></symbol>
  <symbol id="chart-up" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 17l4-4 4 3 5-7 3 3M21 21H3"/></symbol>
  <symbol id="columns" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 20h20M2 4h20M4 4v16M12 4v16M20 4v16M2 9h20M2 15h20"/></symbol>
  <symbol id="trophy" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 21h8M12 17v4M5 3h14v9a7 7 0 01-14 0zM5 3H2v5a3 3 0 003 3M19 3h3v5a3 3 0 01-3 3"/></symbol>
  <symbol id="newspaper" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h12v14H4zM14 4h6v4h-6zM14 12h6M14 16h6M7 8h6M7 12h4M7 16h4"/></symbol>
  <symbol id="building" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 21h16M4 21V4a1 1 0 011-1h14a1 1 0 011 1v17M9 9h2M9 13h2M13 9h2M13 13h2M10 21v-4h4v4"/></symbol>
  <symbol id="medal" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l1.5 4.6h4.8l-3.9 2.8 1.5 4.6L12 11.2l-3.9 2.8 1.5-4.6L5.7 6.6h4.8z"/></symbol>
  <symbol id="diamond" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3L4 10l8 11 8-11zM4 10h16"/></symbol>
  <symbol id="speaker" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5L6 9H2v6h4l5 4zM19.07 4.93a10 10 0 010 14.14M15.54 8.46a5 5 0 010 7.07"/></symbol>
  <symbol id="dollar" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 100 7h5a3.5 3.5 0 110 7H6"/></symbol>
  <symbol id="rocket" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2c-3 4-4 8-4 11a4 4 0 008 0c0-3-1-7-4-11zM9 13l-4 3M15 13l4 3M10 17h4"/></symbol>
  <symbol id="candy" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.5 9.5a4.5 4.5 0 106.36 6.36M9.5 9.5L15.86 15.86M9.5 9.5l-5-5M15.86 15.86l5 5"/></symbol>
  <symbol id="robot" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 3h6M10 3v2M14 3v2M5 7h14a1 1 0 011 1v8a1 1 0 01-1 1H5a1 1 0 01-1-1V8a1 1 0 011-1zM8 12h0M16 12h0M10 15h4M12 17v5M9 22h6"/></symbol>
  <symbol id="coins" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a5 5 0 100 10A5 5 0 0012 2zM4 15a4 4 0 018 0M8 15h8M9 21h6M8 18h8"/></symbol>
  <symbol id="boat" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 18h18M5 18V10l7-5 7 5v8M12 5v6M9 11h6"/></symbol>
  <symbol id="shield" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l8 3v6c0 5.5-3.5 9.74-8 11C7.5 20.74 4 16.5 4 11V5z"/></symbol>
  <symbol id="globe" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 100 20A10 10 0 0012 2zM2 12h20M12 2a15.3 15.3 0 010 20M12 2a15.3 15.3 0 000 20"/></symbol>
  <symbol id="sushi" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 12a6 6 0 0012 0H6zM6 12V9a3 3 0 013-3M18 12V9a3 3 0 00-3-3M9 6h6M12 3v3"/></symbol>
  <symbol id="sparkle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v2M12 19v2M3 12h2M19 12h2M6.34 6.34l1.42 1.42M16.24 16.24l1.42 1.42M6.34 17.66l1.42-1.42M16.24 7.76l1.42-1.42M12 8a4 4 0 100 8 4 4 0 000-8z"/></symbol>
  <symbol id="mic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a3 3 0 00-3 3v6a3 3 0 006 0V5a3 3 0 00-3-3zM5 11a7 7 0 0014 0M12 19v3M9 22h6"/></symbol>
  <symbol id="train" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 11V8a2 2 0 012-2h12a2 2 0 012 2v3M4 11v7a2 2 0 002 2h12a2 2 0 002-2v-7M4 11h16M9 20l-2 2M15 20l2 2M9 11h0M15 11h0"/></symbol>
  <symbol id="paw" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM15 5.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM7.5 8a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM17 8.5a1.5 1.5 0 100 3 1.5 1.5 0 000-3zM12 12c-3 0-6 2-6 5 0 4 2.5 5 6 5s6-1 6-5c0-3-3-5-6-5z"/></symbol>
  <symbol id="flag" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 15V5M4 5h12l-3 5 3 5H4"/></symbol>
  <symbol id="tea" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 8h14l-2 10H7zM17 8V6a1 1 0 00-1-1H8a1 1 0 00-1 1v2M16 18a2 2 0 012 2H6a2 2 0 012-2"/></symbol>
  <symbol id="card" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 7h20v12H2zM2 11h20M6 15h4"/></symbol>
  <symbol id="crown" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 19h20M2 19l3-10 5 5L12 5l2 9 5-5 3 10"/></symbol>
  <symbol id="oil" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l5 10H7zM7 12h10v5a5 5 0 01-10 0zM10 17v5M14 17v5"/></symbol>
  <symbol id="castle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 21h16M6 21V12l6-9 6 9v9M3 12h18M10 21v-5h4v5"/></symbol>
  <symbol id="coffee" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 8h1a4 4 0 010 8h-1M3 8h14v9a2 2 0 01-2 2H5a2 2 0 01-2-2zM6 2v2M10 2v2M14 2v2"/></symbol>
  <symbol id="laptop" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 14h16M4 14V6a1 1 0 011-1h14a1 1 0 011 1v8M4 14H2v4h20v-4h-2M9 21h6"/></symbol>
  <symbol id="plane" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 2L11 13M22 2l-5 20-4-9-9-4z"/></symbol>
  <symbol id="computer" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16a1 1 0 011 1v11a1 1 0 01-1 1H4a1 1 0 01-1-1V5a1 1 0 011-1zM8 20h8M12 16v4"/></symbol>
  <symbol id="signal" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 12m-1 0a1 1 0 102 0 1 1 0 10-2 0M9.17 9.17a4 4 0 000 5.66M14.83 14.83a4 4 0 000-5.66M6.34 6.34a8 8 0 000 11.32M17.66 17.66a8 8 0 000-11.32"/></symbol>
  <symbol id="server" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5h16a1 1 0 011 1v4a1 1 0 01-1 1H4a1 1 0 01-1-1V6a1 1 0 011-1zM4 13h16a1 1 0 011 1v4a1 1 0 01-1 1H4a1 1 0 01-1-1v-4a1 1 0 011-1zM7 8h0M7 16h0M10 8h4M10 16h4"/></symbol>
  <symbol id="hand" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 10V6a2 2 0 014 0v4M12 10V4a2 2 0 014 0v6M16 10a2 2 0 014 0v4l-4 6H8l-4-4a2 2 0 010-4l4 2V10a2 2 0 014 0z"/></symbol>
  <symbol id="clock" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 100 20A10 10 0 0012 2zM12 6v6l4 2"/></symbol>
  <symbol id="chart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 18V9l4 4 4-8 4 5 4-5M4 22h16"/></symbol>
  <symbol id="brain" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5a7 7 0 00-7 7c0 2.5 1.4 4.7 3.5 5.9M12 5a7 7 0 017 7c0 2.5-1.4 4.7-3.5 5.9M12 5v14M8.5 17.9L12 19l3.5-1.1M9 12h6M10 9v6M14 9v6"/></symbol>
  <symbol id="clipboard" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 012-2h2a2 2 0 012 2M9 12h6M9 16h4"/></symbol>
  <symbol id="circle-up" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22a10 10 0 100-20 10 10 0 000 20zM12 8v8M8 12l4-4 4 4"/></symbol>
  <symbol id="circle-down" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 100 20A10 10 0 0012 2zM12 16V8M8 12l4 4 4-4"/></symbol>
  <symbol id="star-glow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.3L12 17l-6.2 4.2 2.4-7.3L2 9.4h7.6z"/></symbol>
  <symbol id="city" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 21h20M4 21V9h6V4h8v17M7 13h2M7 17h2M15 8h2M15 12h2M15 16h2M4 9h2M4 13h2M4 17h2"/></symbol>
  <symbol id="palette" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 13.5A10 10 0 1012 22c1.7 0 2-1 2-2 0-.5-.1-.9-.2-1.2.4-.6.2-1.5-.5-2.5-1-1.5-.2-3.3 1.7-3.3 3 0 5 2.5 5 5.5C20 22 16 24 12 24A12 12 0 012 13.5z"/></symbol>
  <symbol id="island" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 10V2M9 5l3-3 3 3M8 21c0-3.5 4-8 4-8s4 4.5 4 8M2 21h20M7 21c1-2 2-4 5-4s4 2 5 4"/></symbol>
  <symbol id="medal-sport" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15l-7 7M12 15l7 7M5 3h14M5 3a7 7 0 007 12 7 7 0 007-12"/></symbol>
  <symbol id="moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"/></symbol>
  <symbol id="bell" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"/></symbol>
  <symbol id="link" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></symbol>
  <symbol id="cloud" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 10h-1.26A8 8 0 109 20h9a5 5 0 000-10z"/></symbol>
  <symbol id="hourglass" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 3h14M5 21h14M8 3v5l4 5-4 5v3M16 3v5l-4 5 4 5v3"/></symbol>
  <symbol id="wolf" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3L4 8l-1 6 3 4 6 2 6-2 3-4-1-6-4-5M12 3l2 5M12 3l-2 5M9 14c0 2 0 4-2 5M15 14c0 2 0 4 2 5M9 10h6"/></symbol>
  <symbol id="person" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 11a4 4 0 100-8 4 4 0 000 8zM3 21a9 9 0 0118 0"/></symbol>
  <symbol id="muscle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6.5 6.5A3.5 3.5 0 003 10c0 2.5 3 4.5 3.5 5L12 22l5.5-7S21 13 21 10a3.5 3.5 0 00-6.5-1.5 3.5 3.5 0 00-8 0"/></symbol>
  <symbol id="cart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4zM3 6h18M16 10a4 4 0 01-8 0"/></symbol>
  <symbol id="bill" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 6h20v12H2zM6 10h12M6 14h8"/></symbol>
  <symbol id="guitar" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 12a4 4 0 100-8 4 4 0 000 8zM12 12l5 9M12 12l-7 9"/></symbol>
  <symbol id="yen-sign" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L6 10h12zM6 10l6 4 6-4M12 14v8M9 18h6"/></symbol>
  <symbol id="heart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></symbol>
  <symbol id="sword" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 19l14-14M9 5h10v10M15 5l4 4"/></symbol>
  <symbol id="building-old" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 20h20M4 20V9h16v11M10 9V5h4v4M7 14h10M7 17h10"/></symbol>
  <symbol id="hat" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 14c0-4 3.6-7 8-7s8 3 8 7M3 14h18M6 14v5h12v-5"/></symbol>
  <symbol id="bear-face" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 8a3 3 0 000 6M19 8a3 3 0 010 6M7 7h10v9a5 5 0 01-10 0zM10 12h0M14 12h0M10 16a2.5 2.5 0 005 0"/></symbol>
  <symbol id="moon-dark" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22a10 10 0 01-7.07-17.07A8 8 0 1019.07 14.93 10 10 0 0112 22z"/></symbol>
</svg>
```

- [ ] **Step 1.2: Add svgIcon() helper and CSS**

Insert immediately after the SVG sprite block:

```html
<script>
function svgIcon(name, cls) {
  return '<svg class="svg-icon' + (cls ? ' ' + cls : '') + '" aria-hidden="true"><use href="#' + name + '"/></svg>';
}
</script>
```

Also add these CSS rules to the existing `<style>` block (after line 131, before the `/* Generic panel section heading */` comment):

```css
  .svg-icon {
    width: 1em;
    height: 1em;
    display: inline-block;
    vertical-align: middle;
    overflow: visible;
  }
  .tab-btn .svg-icon, .nav-btn .svg-icon, .bb-btn .svg-icon {
    font-size: 22px;
    display: block;
    margin-bottom: 1px;
  }
  .tab-btn.active .svg-icon { color: #0a0e1a; }
  .asset-icon .svg-icon  { font-size: 32px; }
  .perk-icon .svg-icon   { font-size: 20px; }
  .unlock-icon .svg-icon { font-size: 24px; }
  .quest-icon .svg-icon  { font-size: 22px; }
  .dq-icon .svg-icon     { font-size: 22px; }
  .skill-node-icon .svg-icon { font-size: 24px; }
  .manager-portrait .svg-icon { font-size: 36px; }
  .lb-icon .svg-icon     { font-size: 22px; }
```

- [ ] **Step 1.3: Verify sprite loads with a quick smoke test**

Open `www/index.html` in a browser. Open DevTools console and run:
```js
document.getElementById('svg-sprite').querySelectorAll('symbol').length
```
Expected output: `62` (the number of symbols added). If you see 0, the SVG block was inserted incorrectly.

- [ ] **Step 1.4: Commit**

```bash
git add www/index.html
git commit -m "feat: add SVG sprite block and svgIcon() helper"
```

---

## Task 2: Update ASSETS, RIVALS, and Data Arrays to Use Icon Names

**Files:**
- Modify: `www/index.html` — data array `icon:` values

- [ ] **Step 2.1: Update ASSETS array (lines ~2185–2214)**

Change each `icon:` from HTML entity to the name string. Find and replace these exact strings:

| Old value | New value |
|-----------|-----------|
| `icon: '&#128181;'` (PNNY) | `icon: 'dollar'` |
| `icon: '&#128640;'` (MEME) | `icon: 'rocket'` |
| `icon: '&#127852;'` (DOGZ) | `icon: 'candy'` |
| `icon: '&#129302;'` (AIBL) | `icon: 'robot'` |
| `icon: '&#128176;'` (HEDG) | `icon: 'coins'` |
| `icon: '&#128674;'` (YACT) | `icon: 'boat'` |
| `icon: '&#128188;'` (PRVT) | `icon: 'briefcase'` |
| `icon: '&#128737;'` (SOVR) | `icon: 'shield'` |
| `icon: '&#127970;'` (FEDS) | `icon: 'building'` |
| `icon: '&#127760;'` (GLBL) | `icon: 'globe'` |
| `icon: '&#127843;'` (T_SUSHI) | `icon: 'sushi'` |
| `icon: '&#127884;'` (T_ANIME) | `icon: 'sparkle'` |
| `icon: '&#127908;'` (T_KARAOKE) | `icon: 'mic'` |
| `icon: '&#128646;'` (T_NEKO) | `icon: 'train'` |
| `icon: '&#129302;'` (T_SUMO) | `icon: 'robot'` |
| `icon: '&#128050;'` (T_TOYOTA) | `icon: 'paw'` |
| `icon: '&#127981;'` (L_STERLING) | `icon: 'flag'` |
| `icon: '&#127861;'` (L_TEA) | `icon: 'tea'` |
| `icon: '&#128179;'` (L_BANK) | `icon: 'card'` |
| `icon: '&#128081;'` (L_CROWN) | `icon: 'crown'` |
| `icon: '&#128739;'` (L_OIL) | `icon: 'oil'` |
| `icon: '&#127984;'` (L_PALACE) | `icon: 'castle'` |

**Note:** Some entities are reused across arrays. Use the surrounding context (asset id, array name) to confirm you're editing the right line.

- [ ] **Step 2.2: Update BOOSTS array (lines ~2245–2251)**

| Old | New |
|-----|-----|
| `icon: '&#9749;'` | `icon: 'coffee'` |
| `icon: '&#128187;'` | `icon: 'laptop'` |
| `icon: '&#127970;'` | `icon: 'building'` |
| `icon: '&#128747;'` | `icon: 'plane'` |
| `icon: '&#127963;'` | `icon: 'columns'` |

- [ ] **Step 2.3: Update HFT_PERKS array (lines ~2255–2260)**

| Old | New |
|-----|-----|
| `icon: '&#128421;'` | `icon: 'computer'` |
| `icon: '&#128225;'` | `icon: 'signal'` |
| `icon: '&#128442;'` | `icon: 'server'` |
| `icon: '&#9889;'` (quantum) | `icon: 'lightning'` |

- [ ] **Step 2.4: Update SKILL_TREE (lines ~2284–2315)**

Branch icons:
| Old | New |
|-----|-----|
| `icon: '&#9889;'` (speed branch) | `icon: 'lightning'` |
| `icon: '&#128225;'` (intel branch) | `icon: 'signal'` |
| `icon: '&#128176;'` (capital branch) | `icon: 'coins'` |

Node icons:
| Old | New |
|-----|-----|
| `icon: '&#128075;'` (sk_fast_hands) | `icon: 'hand'` |
| `icon: '&#128338;'` (sk_pre_market) | `icon: 'clock'` |
| `icon: '&#129302;'` (sk_algo_edge) | `icon: 'robot'` |
| `icon: '&#128640;'` (sk_light_speed) | `icon: 'rocket'` |
| `icon: '&#127756;'` (sk_dark_pool) | `icon: 'moon-dark'` |
| `icon: '&#128202;'` (sk_scanner) | `icon: 'chart'` |
| `icon: '&#128994;'` (sk_bull_ext) | `icon: 'circle-up'` |
| `icon: '&#128308;'` (sk_bear_buf) | `icon: 'circle-down'` |
| `icon: '&#127775;'` (sk_bias) | `icon: 'star-glow'` |
| `icon: '&#129504;'` (sk_sentiment) | `icon: 'brain'` |
| `icon: '&#128200;'` (sk_compound) | `icon: 'chart-up'` |
| `icon: '&#128203;'` (sk_portfolio) | `icon: 'clipboard'` |
| `icon: '&#127942;'` (sk_ms_amp) | `icon: 'trophy'` |
| `icon: '&#127775;'` (sk_legend) | `icon: 'star-glow'` |
| `icon: '&#128081;'` (sk_dynasty) | `icon: 'crown'` |

- [ ] **Step 2.5: Update UNLOCKS (lines ~2346–2374)**

| Old | New |
|-----|-----|
| `icon: '&#128176;'` | `icon: 'coins'` |
| `icon: '&#128104;&#8205;&#128188;'` (person+briefcase) | `icon: 'person'` |
| `icon: '&#128181;'` | `icon: 'dollar'` |
| `icon: '&#128640;'` | `icon: 'rocket'` |
| `icon: '&#128202;'` | `icon: 'chart'` |
| `icon: '&#127775;'` | `icon: 'star-glow'` |
| `icon: '&#128054;'` (wolf) | `icon: 'wolf'` |
| `icon: '&#128142;'` | `icon: 'diamond'` |
| `icon: '&#128674;'` | `icon: 'boat'` |
| `icon: '&#128276;'` | `icon: 'bell'` |
| `icon: '&#9889;'` | `icon: 'lightning'` |
| `icon: '&#128188;'` | `icon: 'briefcase'` |
| `icon: '&#127884;'` | `icon: 'sparkle'` |
| `icon: '&#127974;'` | `icon: 'building-old'` |
| `icon: '&#128200;'` | `icon: 'chart-up'` |
| `icon: '&#128081;'` | `icon: 'crown'` |
| `icon: '&#127980;'` | `icon: 'flag'` |

- [ ] **Step 2.6: Update QUESTS (lines ~2378–2414)**

| Old | New |
|-----|-----|
| `icon: '&#128181;'` | `icon: 'dollar'` |
| `icon: '&#128722;'` | `icon: 'cart'` |
| `icon: '&#128202;'` | `icon: 'chart'` |
| `icon: '&#127852;'` | `icon: 'candy'` |
| `icon: '&#127775;'` | `icon: 'star-glow'` |
| `icon: '&#128188;'` | `icon: 'briefcase'` |
| `icon: '&#127970;'` | `icon: 'building'` |
| `icon: '&#128674;'` | `icon: 'boat'` |
| `icon: '&#128075;'` | `icon: 'hand'` |
| `icon: '&#9889;'` | `icon: 'lightning'` |
| `icon: '&#128184;'` | `icon: 'bill'` |
| `icon: '&#128200;'` | `icon: 'chart-up'` |
| `icon: '&#129689;'` | `icon: 'medal'` |
| `icon: '&#9203;'` | `icon: 'hourglass'` |
| `icon: '&#128276;'` | `icon: 'bell'` |
| `icon: '&#129505;'` | `icon: 'heart'` |
| `icon: '&#165;'` | `icon: 'yen-sign'` |
| `icon: '&#127929;'` | `icon: 'guitar'` |
| `icon: '&#128421;'` | `icon: 'computer'` |
| `icon: '&#128640;'` | `icon: 'rocket'` |
| `icon: '&#127884;'` | `icon: 'sparkle'` |
| `icon: '&#129686;'` | `icon: 'castle'` |

- [ ] **Step 2.7: Update LIFESTYLE (lines ~2484–2501)**

| Old | New |
|-----|-----|
| `icon: '&#127961;'` | `icon: 'city'` |
| `icon: '&#128674;'` | `icon: 'boat'` |
| `icon: '&#128747;'` | `icon: 'plane'` |
| `icon: '&#127912;'` | `icon: 'palette'` |
| `icon: '&#127965;'` | `icon: 'island'` |
| `icon: '&#127944;'` | `icon: 'medal-sport'` |
| `icon: '&#127769;'` | `icon: 'moon'` |
| `icon: '&#127970;'` | `icon: 'building'` |

- [ ] **Step 2.8: Update INFLUENCE_SHOP (lines ~2506–2525)**

| Old | New |
|-----|-----|
| `icon: '&#128276;'` | `icon: 'bell'` |
| `icon: '&#127970;'` | `icon: 'building'` |
| `icon: '&#127963;'` | `icon: 'columns'` |
| `icon: '&#128737;'` | `icon: 'shield'` |
| `icon: '&#128279;'` | `icon: 'link'` |
| `icon: '&#127774;'` | `icon: 'cloud'` |
| `icon: '&#128202;'` | `icon: 'chart'` |

- [ ] **Step 2.9: Update LEVERAGE_TIERS and TIME_WARPS (lines ~2551–2563)**

All five leverage tiers: `icon: '&#128640;'` → `icon: 'rocket'`

TIME_WARPS: `icon: '&#9203;'` → `icon: 'hourglass'`

- [ ] **Step 2.10: Update PREMIUM_MANAGERS (lines ~2428–2478)**

| Old | New |
|-----|-----|
| `icon: '&#127963;'` (senator) | `icon: 'columns'` |
| `icon: '&#129302;'` (quant) | `icon: 'robot'` |
| `icon: '&#128188;'` (cfo) | `icon: 'briefcase'` |
| `icon: '&#128264;'` (whistleblower) | `icon: 'speaker'` |
| `icon: '&#128104;&#8205;&#128188;'` (salaryman) | `icon: 'person'` |
| `icon: '&#128483;'` (shogun) | `icon: 'sword'` |
| `icon: '&#127891;'` (sensei) | `icon: 'star-glow'` |
| `icon: '&#129422;'` (kaiju) | `icon: 'paw'` |
| `icon: '&#127981;'` (governor) | `icon: 'flag'` |
| `icon: '&#9876;'` (knight) | `icon: 'sword'` |
| `icon: '&#129504;'` (the_algorithm) | `icon: 'brain'` |

- [ ] **Step 2.11: Update DAILY_QUEST_POOL (lines ~3300–3317)**

| Old | New |
|-----|-----|
| `icon: '&#128200;'` | `icon: 'chart-up'` |
| `icon: '&#9889;'` | `icon: 'lightning'` |
| `icon: '&#129302;'` | `icon: 'robot'` |
| `icon: '&#128722;'` | `icon: 'cart'` |
| `icon: '&#127970;'` | `icon: 'building'` |
| `icon: '&#128184;'` | `icon: 'bill'` |
| `icon: '&#128176;'` | `icon: 'coins'` |
| `icon: '&#129297;'` (billion club) | `icon: 'person'` |
| `icon: '&#127775;'` | `icon: 'star-glow'` |
| `icon: '&#128075;'` | `icon: 'hand'` |
| `icon: '&#128170;'` | `icon: 'muscle'` |
| `icon: '&#128240;'` | `icon: 'newspaper'` |
| `icon: '&#127963;'` | `icon: 'columns'` |
| `icon: '&#129354;'` | `icon: 'sword'` |
| `icon: '&#165;'` | `icon: 'yen-sign'` |
| `icon: '&#163;'` | `icon: 'card'` |

- [ ] **Step 2.12: Update RIVALS data (lines ~5498–5538)**

| Old literal emoji | New value |
|-------------------|-----------|
| `icon: '🐻'` | `icon: 'bear-face'` |
| `icon: '🚀'` | `icon: 'rocket'` |
| `icon: '🤖'` | `icon: 'robot'` |
| `icon: '🎩'` | `icon: 'hat'` |
| `icon: '🌑'` | `icon: 'moon-dark'` |

- [ ] **Step 2.13: Update WELCOME_SLIDES tutorial (lines ~6949–6962)**

| Old | New |
|-----|-----|
| `icon: '&#128176;'` | `icon: 'coins'` |
| `icon: '&#127795;'` (tree) | `icon: 'lightning'` |
| `icon: '&#127942;'` | `icon: 'trophy'` |
| `icon: '&#11088;'` | `icon: 'star'` |
| `icon: '&#127963;'` | `icon: 'columns'` |

- [ ] **Step 2.14: Commit**

```bash
git add www/index.html
git commit -m "feat: convert all data array icon values to SVG name strings"
```

---

## Task 3: Update Render Functions to Use svgIcon()

Every place in the JS that interpolates `${x.icon}` into HTML must become `${svgIcon(x.icon)}`. The render sites are:

| Line (approx) | Template expression | Change to |
|---------------|---------------------|-----------|
| 3422 | `${q.icon}` (renderDailyQuestsSection) | `${svgIcon(q.icon)}` |
| 4652 | `${branch.icon} ${branch.name}` (renderSkillTree) | `${svgIcon(branch.icon)} ${branch.name}` |
| 4667 | `${node.icon}` (renderSkillTree) | `${svgIcon(node.icon)}` |
| 5709 | `${p.icon}` (renderRivalsTab — beaten rival) | `${svgIcon(p.icon)}` |
| 5738 | `${p.icon}` (renderRivalsTab — unbeaten rival) | `${svgIcon(p.icon)}` |
| 6112 | `${asset.icon}` (renderAssets — asset-icon div) | `${svgIcon(asset.icon)}` |
| 6357 | `${u.icon}` (renderUnlocksTab) | `${svgIcon(u.icon)}` |
| 6427 | `${q.icon}` (renderQuestsTab) | `${svgIcon(q.icon)}` |
| 6471 | `${a.icon}` (renderManagersTab — manager portrait) | `${svgIcon(a.icon)}` |
| 6503 | `${p.icon}` (renderManagersTab — premium portrait) | `${svgIcon(p.icon)}` |
| 6542 | `${b.icon \|\| '&#9889;'}` (renderPerksTab — boost) | `${svgIcon(b.icon \|\| 'lightning')}` |
| 6565 | `${p.icon}` (renderPerksTab — HFT perk) | `${svgIcon(p.icon)}` |
| 6594 | `${l.icon \|\| '&#127961;'}` (renderPerksTab — lifestyle) | `${svgIcon(l.icon \|\| 'city')}` |
| 6640 | `${asset.icon}` (renderPerksTab — mega ticket) | `${svgIcon(asset.icon)}` |
| 6695 | `${t.icon}` (renderPerksTab — leverage tier) | `${svgIcon(t.icon)}` |
| 6733 | `${w.icon}` (renderPerksTab — time warp) | `${svgIcon(w.icon)}` |
| 6834 | `${s.icon}` (renderPerksTab — influence shop) | `${svgIcon(s.icon)}` |
| 6923 | `node.icon` (showSkillDetail modal) | `svgIcon(node.icon)` |
| 6925 | `branch.icon + ' ' + branch.name` (showSkillDetail) | `svgIcon(branch.icon) + ' ' + branch.name` |
| 6977 | `step.icon` (renderWelcomeSlide) | `svgIcon(step.icon)` |

- [ ] **Step 3.1: Apply all icon interpolation changes above**

Go through each line in the table. Use the function context (comment in the table) to confirm you're at the right site. The change is always: `x.icon` → `svgIcon(x.icon)` within a template literal.

The special cases:
- Line 6542: `${b.icon || '&#9889;'}` → `${svgIcon(b.icon || 'lightning')}`
- Line 6594: `${l.icon || '&#127961;'}` → `${svgIcon(l.icon || 'city')}`
- Line 6923/6925/6977: these set `.innerHTML` directly — still use `svgIcon()` since it returns an HTML string

- [ ] **Step 3.2: Visual spot check**

Open `www/index.html` in Chrome. Check these tabs:
1. Home tab → asset cards should show SVG icons instead of emoji
2. Nav overlay (tap NAVIGATE) → all 8 buttons should show SVG icons
3. Goals tab → quest and achievement icons should be SVG
4. Perks tab → all perk rows should show SVG icons
5. Skills tab → branch headers and nodes should show SVG icons
6. Leaders tab → rival icons should be SVG bears/rockets/etc.
7. Managers tab → all portrait images should be SVG

If any show blank space instead of an icon, the name doesn't match a symbol id. Check the console for errors.

- [ ] **Step 3.3: Commit**

```bash
git add www/index.html
git commit -m "feat: update all render templates to use svgIcon() helper"
```

---

## Task 4: Update Static HTML Navigation Icons

The bottom bar and nav overlay use static HTML. These still have the old HTML entities.

- [ ] **Step 4.1: Update bottom bar (lines ~1903–1913)**

Find and replace:
```html
<!-- BEFORE -->
<button class="bb-btn" onclick="switchTab('home')">
  <span class="bb-icon">&#127968;</span>HOME
</button>
<button class="bb-btn" onclick="openNav()">
  <span class="bb-icon">&#9783;</span>NAVIGATE
</button>
<button class="bb-btn" onclick="openModal('settingsModal')">
  <span class="bb-icon">&#9881;</span>MENU
</button>
```

```html
<!-- AFTER -->
<button class="bb-btn" onclick="switchTab('home')">
  <svg class="svg-icon" aria-hidden="true"><use href="#home"/></svg>HOME
</button>
<button class="bb-btn" onclick="openNav()">
  <svg class="svg-icon" aria-hidden="true"><use href="#menu"/></svg>NAVIGATE
</button>
<button class="bb-btn" onclick="openModal('settingsModal')">
  <svg class="svg-icon" aria-hidden="true"><use href="#gear"/></svg>MENU
</button>
```

Also update the `.bb-icon` → `.svg-icon` CSS reference if needed. The `.bb-icon` CSS rule sets `font-size: 22px` and `display: block` — those will now apply via the `.tab-btn .svg-icon` rule added in Task 1. Confirm the bottom bar icon size looks correct (should still be ~22px).

- [ ] **Step 4.2: Update nav overlay grid (lines ~1875–1898)**

Replace each `<span class="nav-icon">&#xxx;</span>` with `<svg class="svg-icon" aria-hidden="true"><use href="#NAME"/></svg>`:

```html
<button class="nav-btn" id="nav-staff-btn" onclick="closeNav();switchTab('managers')">
  <svg class="svg-icon" aria-hidden="true"><use href="#briefcase"/></svg>STAFF<span class="nav-dot"></span>
</button>
<button class="nav-btn" id="nav-skills-btn" onclick="closeNav();switchTab('skills')">
  <svg class="svg-icon" aria-hidden="true"><use href="#lightning"/></svg>SKILLS<span class="nav-dot"></span>
</button>
<button class="nav-btn" id="nav-perks-btn" onclick="closeNav();switchTab('perks')">
  <svg class="svg-icon" aria-hidden="true"><use href="#lightning"/></svg>PERKS<span class="nav-dot"></span>
</button>
<button class="nav-btn" id="nav-goals-btn" onclick="closeNav();switchTab('unlocks')">
  <svg class="svg-icon" aria-hidden="true"><use href="#star"/></svg>GOALS<span class="nav-dot"></span>
</button>
<button class="nav-btn" onclick="closeNav();switchTab('options')">
  <svg class="svg-icon" aria-hidden="true"><use href="#chart-up"/></svg>OPTIONS
</button>
<button class="nav-btn" onclick="closeNav();switchTab('pit')">
  <svg class="svg-icon" aria-hidden="true"><use href="#columns"/></svg>PIT
</button>
<button class="nav-btn" onclick="closeNav();switchTab('rivals')">
  <svg class="svg-icon" aria-hidden="true"><use href="#trophy"/></svg>LEADERS
</button>
<button class="nav-btn" id="nav-news-btn" onclick="closeNav();switchTab('news')">
  <svg class="svg-icon" aria-hidden="true"><use href="#newspaper"/></svg>NEWS<span class="nav-dot"></span>
</button>
```

- [ ] **Step 4.3: Update IPO button (line ~1871)**

```html
<!-- BEFORE -->
<button id="navIpoBtn" class="nav-ipo-btn" onclick="closeNav();openModal('prestigeModal')">
  &#127970; IPO Your Firm &mdash; Ring the Bell
</button>

<!-- AFTER -->
<button id="navIpoBtn" class="nav-ipo-btn" onclick="closeNav();openModal('prestigeModal')">
  <svg class="svg-icon" aria-hidden="true" style="font-size:20px;vertical-align:-3px;"><use href="#building"/></svg> IPO Your Firm &mdash; Ring the Bell
</button>
```

- [ ] **Step 4.4: Update gold and megabucks chips (lines ~1775–1776)**

The gold chip uses `&#129689;` (gold medal) and the megabucks chip uses `&#128142;` (diamond). These live inside `.gold-chip` divs:

```html
<!-- BEFORE -->
<div class="gold-chip" id="goldChip" ...><span class="gold-icon">&#129689;</span>...
<div class="gold-chip" id="megabucksChip" ...><span class="gold-icon">&#128142;</span>...
```

```html
<!-- AFTER -->
<div class="gold-chip" id="goldChip" ...><span class="gold-icon"><svg class="svg-icon" aria-hidden="true" style="font-size:16px;"><use href="#medal"/></svg></span>...
<div class="gold-chip" id="megabucksChip" ...><span class="gold-icon"><svg class="svg-icon" aria-hidden="true" style="font-size:16px;"><use href="#diamond"/></svg></span>...
```

- [ ] **Step 4.5: Update mute button (line ~1778)**

```html
<!-- BEFORE -->
<button id="muteBtn" ...>&#128266;</button>

<!-- AFTER -->
<button id="muteBtn" ...><svg class="svg-icon" aria-hidden="true" style="font-size:16px;vertical-align:-2px;"><use href="#speaker"/></svg></button>
```

- [ ] **Step 4.6: Final visual check**

Reload the page. All navigation should now show clean SVG icons. The icon color should follow the button's text color (because SVGs use `stroke="currentColor"`). The active tab should invert the icon color (dark on gold).

- [ ] **Step 4.7: Commit**

```bash
git add www/index.html
git commit -m "feat: replace static nav HTML emoji with inline SVG icons"
```

---

## Task 5: Global Leaderboard — Supabase Setup Constants

**Files:**
- Modify: `www/index.html` — add Supabase config constants near top of `<script>` section

The Supabase project does not exist yet (free plan limit hit). The user will need to:
1. Go to https://supabase.com/dashboard and pause or delete one of the existing projects ("AI Flashcard Reader" or "Hand Me Downs")
2. Create a new project named "Day Trader Tycoon" in the `criyajexsmlyvfxntsif` organization
3. Run this SQL in the Supabase SQL editor to create the leaderboard table:

```sql
-- Run in Supabase SQL Editor after creating the project
create table public.leaderboard (
  id           uuid primary key default gen_random_uuid(),
  player_id    text not null unique,
  firm_name    text not null default 'Anonymous Firm',
  score        bigint not null default 0,
  prestige_count integer not null default 0,
  updated_at   timestamptz not null default now()
);

-- Index for leaderboard queries
create index leaderboard_score_idx on public.leaderboard(score desc);

-- Enable RLS
alter table public.leaderboard enable row level security;

-- Anyone can read (public leaderboard)
create policy "public read" on public.leaderboard
  for select using (true);

-- Players can insert their own row
create policy "player insert" on public.leaderboard
  for insert with check (true);

-- Players can only update their own row
create policy "player update" on public.leaderboard
  for update using (player_id = player_id);
```

4. Copy the Project URL and anon key from Settings → API
5. Fill them into the constants below

- [ ] **Step 5.1: Find the top of the main `<script>` block**

Look for the line: `'use strict';` or the first JS variable declaration (around line 2185). Insert immediately before it:

```js
// ── Supabase Global Leaderboard ──────────────────────────────────────────────
// Fill these in after creating the Supabase project (see docs/superpowers/plans/)
const SUPABASE_URL      = 'https://YOUR_PROJECT_REF.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
const LB_SUBMIT_DEBOUNCE_MS = 30000; // submit at most once per 30 s
let   _lbLastSubmit = 0;

function _lbPlayerId() {
  let id = localStorage.getItem('dtt_player_id');
  if (!id) {
    id = 'p_' + Math.random().toString(36).slice(2) + Date.now().toString(36);
    localStorage.setItem('dtt_player_id', id);
  }
  return id;
}

async function submitLeaderboardScore() {
  if (!SUPABASE_URL.startsWith('https://')) return; // not configured yet
  const now = Date.now();
  if (now - _lbLastSubmit < LB_SUBMIT_DEBOUNCE_MS) return;
  _lbLastSubmit = now;
  const playerId  = _lbPlayerId();
  const firmName  = (state.firmName || 'Anonymous Firm').slice(0, 64);
  const score     = Math.floor(state.allTimeEarnings || 0);
  const prestige  = state.totalIPOs || 0;
  try {
    await fetch(SUPABASE_URL + '/rest/v1/leaderboard', {
      method: 'POST',
      headers: {
        'apikey':       SUPABASE_ANON_KEY,
        'Authorization':'Bearer ' + SUPABASE_ANON_KEY,
        'Content-Type': 'application/json',
        'Prefer':       'resolution=merge-duplicates',
      },
      body: JSON.stringify({
        player_id:      playerId,
        firm_name:      firmName,
        score:          score,
        prestige_count: prestige,
        updated_at:     new Date().toISOString(),
      }),
    });
  } catch(_) { /* silent fail — leaderboard is non-critical */ }
}

async function fetchGlobalLeaderboard() {
  if (!SUPABASE_URL.startsWith('https://')) return null;
  try {
    const res = await fetch(
      SUPABASE_URL + '/rest/v1/leaderboard?select=firm_name,score,prestige_count,player_id&order=score.desc&limit=50',
      { headers: { 'apikey': SUPABASE_ANON_KEY, 'Authorization': 'Bearer ' + SUPABASE_ANON_KEY } }
    );
    if (!res.ok) return null;
    return await res.json();
  } catch(_) { return null; }
}
// ─────────────────────────────────────────────────────────────────────────────
```

- [ ] **Step 5.2: Hook submitLeaderboardScore() into save()**

Find the `save()` function. It calls `localStorage.setItem(...)`. Add the submission call at the END of `save()`, after the localStorage write:

```js
// at the end of the save() function, after localStorage.setItem:
submitLeaderboardScore(); // async, fire-and-forget — non-blocking
```

- [ ] **Step 5.3: Commit**

```bash
git add www/index.html
git commit -m "feat: add Supabase leaderboard submit/fetch helpers"
```

---

## Task 6: Global Leaderboard — Update Rivals Tab UI

The Rivals tab (`renderRivalsTab()` at line ~5636) currently renders only AI rivals. We add a global leaderboard section at the top, with the AI rivals section below it.

- [ ] **Step 6.1: Add CSS for global leaderboard**

In the `<style>` block, after the `.lb-champion-banner` rule (~line 703), add:

```css
  .glb-section-title {
    font-family: 'Lilita One', sans-serif;
    color: var(--gold); font-size: 15px;
    padding: 10px 14px 4px; letter-spacing: 0.5px;
  }
  .glb-row {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 12px; margin: 3px 6px;
    background: linear-gradient(180deg, var(--panel), var(--bg-2));
    border: 1px solid var(--panel-2); border-radius: 8px;
    font-size: 12px;
  }
  .glb-row.glb-self { border-color: #4af; background: linear-gradient(180deg, #0a1a2a, #060e18); }
  .glb-rank { font-family: 'Lilita One', sans-serif; font-size: 14px; min-width: 28px; text-align: center; }
  .glb-name { flex: 1; font-weight: 800; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .glb-score { color: var(--gold); font-size: 11px; text-align: right; }
  .glb-loading { text-align: center; color: var(--text-dim); font-size: 12px; padding: 12px; }
  .glb-divider {
    margin: 8px 6px; border: none; border-top: 1px solid var(--panel-2);
  }
  .glb-ai-title {
    font-family: 'Lilita One', sans-serif;
    color: var(--text-dim); font-size: 13px;
    padding: 8px 14px 2px; letter-spacing: 0.5px; text-transform: uppercase;
  }
```

- [ ] **Step 6.2: Rewrite renderRivalsTab() to include global leaderboard**

Find `function renderRivalsTab()` (line ~5636). Replace the first part of the function (up to and including the champion banner logic) with:

```js
function renderRivalsTab() {
  const root = document.getElementById('tab-rivals');
  if (!root) return;

  // ── Global Leaderboard section (async fetch) ─────────────────────────────
  const playerId = _lbPlayerId();
  const selfScore = Math.floor(state.allTimeEarnings || 0);
  const selfName  = (state.firmName || 'Wall St. Capital Partners LLC').slice(0, 64);

  let globalHtml = `<div class="glb-section-title">${svgIcon('globe')} Global Leaderboard</div>`;
  globalHtml += `<div class="panel-sub" style="margin-top:0;">Top 50 firms worldwide by all-time earnings.</div>`;
  globalHtml += `<div id="glb-list" class="glb-loading">Loading...</div>`;
  globalHtml += `<hr class="glb-divider">`;

  // ── AI Rivals section (existing local leaderboard) ───────────────────────
  const RANK_BADGES = ['🥇','🥈','🥉','4','5','6'];
  const now = Date.now();
  const playerVal = selfScore;
  const participants = [
    { isPlayer: true, wealth: playerVal },
    ...RIVALS.map(r => ({
      ...r,
      wealth: state.rivalWealth?.[r.id] || 0,
      beaten:       !!state.rivalsBeaten?.[r.id],
      investigated: !!(state.secComplaints?.[r.id] && now < state.secComplaints[r.id]),
    })),
  ].sort((a, b) => b.wealth - a.wealth);

  const topWealth = Math.max(1, participants[0].wealth);
  const beatenCount = RIVALS.filter(r => state.rivalsBeaten?.[r.id]).length;

  let aiHtml = `<div class="glb-ai-title">${svgIcon('trophy')} Rival Firms — Local</div>`;
  aiHtml += `<div class="panel-sub">Beat every rival to earn permanent bonuses. ${beatenCount}/5 rivals crushed.</div>`;
```

Then keep the rest of the existing `renderRivalsTab()` body (champion banner, raid warning, SEC buff, leaderboard rows) but rename the closing variable assignment so the final HTML assignment looks like:

```js
  root.innerHTML = globalHtml + aiHtml + /* ... rest of existing html ... */;

  // Async: fetch and inject global leaderboard
  fetchGlobalLeaderboard().then(rows => {
    const el = document.getElementById('glb-list');
    if (!el) return;
    if (!rows || rows.length === 0) {
      const notConfigured = !SUPABASE_URL.startsWith('https://YOUR');
      el.innerHTML = notConfigured
        ? '<span style="color:var(--text-dim);font-size:11px;">Global leaderboard not configured yet — see setup notes.</span>'
        : '<span style="color:var(--text-dim);font-size:11px;">No entries yet. Be the first!</span>';
      return;
    }
    let lbHtml = '';
    const selfIdx = rows.findIndex(r => r.player_id === playerId);
    rows.forEach((r, i) => {
      const isSelf = r.player_id === playerId;
      const rankBadge = i === 0 ? '🥇' : i === 1 ? '🥈' : i === 2 ? '🥉' : (i + 1).toString();
      lbHtml += `<div class="glb-row${isSelf ? ' glb-self' : ''}">
        <div class="glb-rank">${rankBadge}</div>
        <div class="glb-name" title="${r.firm_name}">${r.firm_name}${isSelf ? ' <span style="color:#4af;font-size:10px;">(you)</span>' : ''}</div>
        <div class="glb-score">${fmt(r.score)}<div style="font-size:9px;color:var(--text-dim);">${r.prestige_count} IPO${r.prestige_count !== 1 ? 's' : ''}</div></div>
      </div>`;
    });
    // If player isn't in top 50, append their row at bottom
    if (selfIdx === -1) {
      lbHtml += `<div style="text-align:center;font-size:10px;color:var(--text-dim);padding:4px;">· · ·</div>`;
      lbHtml += `<div class="glb-row glb-self">
        <div class="glb-rank">?</div>
        <div class="glb-name">${selfName} <span style="color:#4af;font-size:10px;">(you)</span></div>
        <div class="glb-score">${fmt(selfScore)}<div style="font-size:9px;color:var(--text-dim);">${state.totalIPOs || 0} IPO${(state.totalIPOs || 0) !== 1 ? 's' : ''}</div></div>
      </div>`;
    }
    el.className = '';
    el.innerHTML = lbHtml;
  });
}
```

**Important:** Keep all the existing logic for `beatRival`, `fileSecComplaint`, `checkRivalChampion`, `maybeStartRivalRaid`, and `tickRivals` — only `renderRivalsTab()` changes.

- [ ] **Step 6.3: Refresh leaderboard on tab open**

Find `function switchTab(name)` (~line 6317). It already calls `renderRivalsTab()` when the rivals tab is selected (line ~6337). No change needed — the async fetch fires on every tab open.

- [ ] **Step 6.4: Verify local-only mode works before Supabase is configured**

Reload the page. Open the Leaders tab. You should see:
- "Loading..." briefly, then "Global leaderboard not configured yet — see setup notes."
- Below the divider: the existing AI rivals leaderboard, unchanged

The AI rivals mechanic (beatRival, SEC complaint, raids) should still work exactly as before.

- [ ] **Step 6.5: Commit**

```bash
git add www/index.html
git commit -m "feat: global leaderboard UI in Rivals tab (Supabase REST)"
```

---

## Task 7: Copy Changes to Root index.html

The project has two `index.html` files: `www/index.html` (the source) and `index.html` in the root (used for the GitHub Pages / itch.io web build). They must stay in sync.

- [ ] **Step 7.1: Check if root index.html needs updating**

```bash
diff index.html www/index.html | head -20
```

If the diff shows the root is behind (usually the case after major edits), copy:

```bash
cp www/index.html index.html
```

- [ ] **Step 7.2: Commit**

```bash
git add index.html
git commit -m "sync: propagate SVG icon + leaderboard changes to root index.html"
```

---

## Task 8: Sync and iOS Build

- [ ] **Step 8.1: Run Capacitor sync**

```bash
npx cap sync ios
```

Expected: "Syncing iOS..." with no errors. This copies `www/` into the Xcode project.

- [ ] **Step 8.2: Open Xcode and verify**

```bash
npx cap open ios
```

Build and run on simulator. Verify:
- Bottom bar shows SVG icons (not emoji)
- Asset cards show SVG icons
- Leaders tab shows global leaderboard section

- [ ] **Step 8.3: ViewController.swift note**

The `ViewController.swift` file at `ios/App/App/ViewController.swift` may need to be manually added to the Xcode project target via drag-and-drop in Xcode if it appears in the Finder but not in Xcode's project navigator. This is a manual step for the user — it does not block the web build.

---

## Supabase Setup Checklist (for user)

When ready to enable the global leaderboard:

1. Go to https://supabase.com/dashboard
2. In organization `criyajexsmlyvfxntsif`, pause one of the existing two projects (you're at the free limit)
3. Create a new project: **"Day Trader Tycoon"**, region **us-east-1**
4. Wait for it to spin up (~2 min)
5. Go to SQL Editor → paste and run the SQL from Task 5
6. Go to Settings → API → copy **Project URL** and **anon public** key
7. In `www/index.html`, replace the two constants:
   ```js
   const SUPABASE_URL      = 'https://YOUR_PROJECT_REF.supabase.co';
   const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
   ```
8. Run `cp www/index.html index.html && npx cap sync ios`

---

## Self-Review

**Spec coverage:**
- ✅ SVG icon system: sprite block, helper, CSS, data arrays updated, render templates updated, static nav updated
- ✅ Global leaderboard: Supabase REST client, score submission on save(), UI in Rivals tab (top section), AI rivals preserved below
- ✅ ViewController.swift: explicitly noted as manual user step, does not block anything

**Placeholder scan:**
- SUPABASE_URL / SUPABASE_ANON_KEY are intentional placeholders that the user fills in — documented with exact instructions
- All SVG paths are complete in the path data table and the sprite block in Task 1.1
- All render sites are listed with exact line numbers and exact code changes

**Type consistency:**
- `svgIcon(name)` is defined in Task 1.2 and called consistently throughout Tasks 3 and 4
- `_lbPlayerId()`, `submitLeaderboardScore()`, `fetchGlobalLeaderboard()` are all defined in Task 5.1 before use in Tasks 5.2 and 6.2
- `fmt()` is an existing helper in the codebase — used correctly for score formatting
- The `glb-*` CSS classes are defined in Task 6.1 before being used in Task 6.2 HTML
