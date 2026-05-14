# Block Blast PvP — Mosaic Variant

**Status:** Prototype variant (parallel to `BLOCK_BLAST_PVP_TETRIS_LIKE.md`)
**Target platform:** Mobile (portrait, one-handed)
**Engine assumption:** Unity (project already set up)
**Scope:** Single PvP match loop. No meta, no monetization, no progression. Prove the core is fun.

> **Read this in parallel with the Tetris-like variant.** They share the piece model, controls, mirrored queue, and bot scaffolding — but they are fundamentally different games. Mosaic is the more experimental of the two.

---

## 1. High Concept

A real-time, mobile-first head-to-head puzzle game where players race to **completely fill a small board** to score. Among the standard piece stream, colored pieces appear occasionally — connecting same-color pieces grants bonus points and drops a tiny garbage cell on the opponent's board. The board only clears when fully filled.

**One-line pitch:** *Race to complete the mosaic. Match colors for bonuses and small jabs at your rival.*

**How it differs from the Tetris-like variant:**
| | Tetris-like | Mosaic |
|---|---|---|
| Board | 9×9 (81 cells) | 6×6 (36 cells) |
| Scoring | (not in scope — top-out / occupancy win) | Score-based: full board + color matches |
| Line clears | Yes — central mechanic | **No** — board only resets when completely filled |
| Garbage volume | Up to 12 cells per attack | 1×1 per match |
| Garbage lifetime | 6s + 4s fade | ~5s, no grace |
| PvP intensity | Big swings | Gentle interference |
| Match feel | Combat | Race + sabotage |

---

## 2. Core Loop

```
Match start
  ↓
Both players receive identical 3-piece tray (mirrored queue, ~25% pieces colored)
  ↓
[Player turn — concurrent, real-time]
  Drag piece onto 6×6 board → snap to valid placement
  Colored piece touching same-color cells? → MATCH:
    +1 score
    Send 1×1 garbage to opponent (decays in ~5s)
  Board completely filled? → MOSAIC CLEAR:
    +5 score
    Board resets to empty
    Brief celebration animation
  Tray empty? → new 3-piece tray
  ↓
Loop until timer expires or one player tops out
  ↓
Highest score wins (top-out = instant loss)
```

**Session length:** 90 seconds (matches Tetris-like for fair side-by-side playtesting).

---

## 3. Board & Pieces

### Board
- **Size:** 6×6 grid (36 cells)
- **Cell states:**
  - **Empty** — placeable
  - **Player cell** — placed by you. May be **colored** (Red / Yellow / Blue) or **neutral**.
  - **Garbage cell** — 1×1, sent by opponent. Blocks placement. Auto-decays.
- **Visual:** clean grid, no Sudoku subdivision (smaller board doesn't need it). Colored cells use saturated fills with subtle inner glow when matched.

### Pieces

**Piece pool is intentionally SMALLER than Tetris-like to reduce soft-lock probability on the 6×6 grid.** Max piece size is 4 cells. The Tetris-like 5-cell pieces (1×5 line, 5-cell plus) and the 3×3 square are excluded from Mosaic.

Final Mosaic piece pool (rotation enabled on all):

| Category | Pieces |
|---|---|
| Singles & short lines | 1×1, 1×2, 1×3, 1×4 (and vertical) |
| Squares | 2×2 |
| Tetrominoes | L, J, T, S, Z (all 4 rotations) |
| Corners | 3-cell L-corner (4 rotations) |

Total: ~9 base shapes × rotations = ~25 placement options when you count all unique orientations.

**Why no 5-cell pieces and no 3×3:** on a 6×6 board, those pieces take 14–25% of the playable area. Combined with 3 random pieces in tray, they're the single biggest cause of unrecoverable soft-locks. Removing them shifts soft-lock probability from "common frustration" to "rare and earned."

- **Color tagging:** every Nth piece in the queue is "colored" (default 1 in 4 = 25%).
  - When colored, every cell of that piece carries the color.
  - Color is purely visual — placement rules identical to neutral pieces.
  - The colored piece is visible as colored in the tray, so players plan around it.
- **Color palette:** 3 colors — Red, Yellow, Blue. Simple, readable, no overlap with garbage (use a neutral grey or hatched pattern for garbage).

### Piece Tray & Queue
- **4 pieces visible** (increased from 3). More options per cycle = more chances at least one piece fits = less soft-lock pressure.
- Mirrored, seeded queue (both players draw identical sequences — including identical color assignments).
- 7-bag piece distribution (variety guarantee).
- New tray drawn when ALL 4 pieces are placed (no partial refresh).

---

## 4. The Filling Rule (Critical)

> **Lines do NOT clear.** Rows and columns being full is not a scoring event and does not free up space. The ONLY way to clear cells from the board is to fill the ENTIRE board.

When all 36 cells are filled (6×6) (regardless of colors / garbage):
- `+5` score (Mosaic clear bonus)
- Board resets to empty
- All garbage timers on this board are cancelled (they're cleared with everything else)
- A short animation (~0.6s) celebrates the fill — does not pause gameplay clock

**This is the defining mechanic.** Players cannot escape bad placements by clearing lines. Every placement matters. The pressure is constant.

---

## 5. Color Matching

### Match trigger
When a player places a colored piece and AT LEAST one cell of the placed piece is **edge-adjacent** (up/down/left/right, not diagonal) to a cell of the **same color** already on the board, it counts as a **match**.

### Match resolution
- Whether the placed piece touches one or many same-color cells, it's **one match event** per placement.
- Touching multiple disconnected clusters of the same color counts as one match (we're not rewarding chains in v1 — keep it simple).
- Touching multiple DIFFERENT colors simultaneously: each color counts as a separate match event (rare but possible).

### Match rewards
For each match event:
- `+1` score
- Send **1 garbage cell** (1×1) to the opponent's board
- The connected color cluster on your board briefly pulses for feedback (~0.3s)

### Cells stay colored
Once a cell is colored on the board, it remains colored until cleared. This means subsequent same-color placements can chain matches off existing clusters. This is the main strategic layer — you're building color regions.

---

## 6. Garbage System

### Sending
- Triggered ONLY by color matches (not by any other mechanic in this variant).
- 1 garbage cell per match event.
- Caps at `MOSAIC_MAX_GARBAGE_PER_TICK` (default **3**) to prevent multi-color combo spam.

### Landing
- Lands in a **random column** on the opponent's board, falls to the lowest empty row (gravity).
- If the chosen column is full, system picks the next column with space.
- If the entire opponent's board is full, garbage is dropped (no effect — they were about to clear anyway).

### Decay
- `MOSAIC_GARBAGE_DECAY_SECONDS` (default **5s**) — short, soft pressure.
- No grace phase. Cell fades smoothly over its full lifetime.
- Anti-stall: same rule as Tetris-like — decay pauses if the player hasn't placed for >2s.
- Garbage cells are NOT colored and never count as match material.

---

## 7. Scoring & Win Conditions

### Score sources (the ONLY two)
- `+1` per color match event
- `+5` per Mosaic clear (full board fill)

### Win priority
1. **Top out (instant loss):** no legal placement for any tray piece → opponent wins immediately.
2. **Timer expiry (90s):** highest score wins.
3. **Tiebreaker:** most Mosaic clears.
4. **Final tiebreaker:** most color matches.
5. **Last resort:** draw.

### Expected score ranges (designer guess, validate in playtest)

Updated for 6×6 board:
- Casual player: 8–15 score / match (frequent matches, 1–2 mosaic clears)
- Skilled player: 20–35 score / match (frequent matches, 2–3 mosaic clears)
- Top performance: 40+ (clean play, multi-match placements, 3–4 mosaic clears)

If actual playtest scores cluster too low (<8 average) → game feels pointless. Tune `COLOR_RATE` up or `MOSAIC_CLEAR_BONUS` up.
If scores cluster too high (>50 average) → climax events feel cheap. Consider raising grid back to 7×7 or lowering `MOSAIC_CLEAR_BONUS`.

---

## 8. Controls & Layout
Identical to Tetris-like (drag, tap-to-rotate, long-press preview). Portrait two-board layout. Score counters replace lines-cleared counters.

---

## 9. Tuning Constants

```
// Board & tray
MOSAIC_BOARD_WIDTH               = 6
MOSAIC_BOARD_HEIGHT              = 6
MOSAIC_PIECE_TRAY_SIZE           = 4    // raised from 3 — reduces soft-lock probability
MOSAIC_PIECE_MAX_CELLS           = 4    // pieces above this size are excluded from the pool
MOSAIC_MATCH_DURATION_SECONDS    = 90

// Colors
COLOR_PALETTE_SIZE               = 3           // Red, Yellow, Blue
COLOR_RATE                       = 0.25        // 1 in 4 pieces is colored
COLOR_DISTRIBUTION               = uniform     // each of the 3 colors equally likely

// Scoring
MATCH_POINTS                     = 1
MOSAIC_CLEAR_BONUS               = 5

// Garbage
MOSAIC_GARBAGE_DECAY_SECONDS     = 5.0
MOSAIC_GARBAGE_GRAVITY           = true
MOSAIC_MAX_GARBAGE_PER_TICK      = 3
STALL_THRESHOLD_SECONDS          = 2.0         // shared with Tetris-like

// Boosters — Hammer
HAMMER_START_CHARGES             = 2
HAMMER_RECHARGE_INTERVAL_SECONDS = 25
HAMMER_MAX_CARRIED               = 3
HAMMER_COOLDOWN_SECONDS          = 3.0

// Boosters — Color Swap
COLOR_SWAP_CHARGE_COST           = 3
COLOR_SWAP_MAX_CARRIED           = 2
COLOR_SWAP_COOLDOWN_SECONDS      = 2.0
COLOR_MATCH_LOCK_SECONDS         = 1.0

// Boosters — Bomb Drop
BOMB_DROP_CHARGES_PER_FULL_CLEAR   = 1
BOMB_DROP_GARBAGE_ABSORB_THRESHOLD = 8
BOMB_DROP_MAX_CARRIED              = 1
BOMB_DROP_GARBAGE_SHAPE            = 2x2

// Comeback
COMEBACK_DEFICIT_THRESHOLD       = 3
COMEBACK_MATCH_MULTIPLIER        = 2

// Top-out softening
DANGER_ZONE_OCCUPANCY            = 0.75
EMERGENCY_HAMMER_PER_MATCH       = 1
EMERGENCY_HAMMER_DEADLINE_SECONDS = 5.0
```

---

## 10. AI Opponent

Same scaffolding as Tetris-like. Heuristic tweaks for Mosaic:
- Prioritize placements that complete board cells > color matches > general placement.
- Bot deliberately ignores chasing low-value matches if it would soft-lock its fill plan.
- Difficulty levels: Easy / Medium / Hard mostly controlled by reaction time (0.5–2.0s).

---

## 11. What's NOT in the Prototype
Identical exclusion list to Tetris-like variant (no netcode, no shop, no meta, no music, etc.). Prototype proves the moment-to-moment loop.

---

## 12. Success Criteria

The Mosaic prototype validates when:

1. New player understands "fill the board / match colors" within 45 seconds.
2. Matches consistently last the full 90s (top-outs are rare — <30% of matches).
3. Mosaic clears happen at least once for skilled players in a match.
4. Color matches happen frequently enough to feel rewarding (target: 5+ per match).
5. PvP interference (garbage) is noticed by playtesters as meaningful but not dominant.
6. Playtesters describe both Tetris-like AND Mosaic as "different games worth playing" — not "Tetris-like is just better".

If 4 of 6 are met → variant validates. If criterion 6 fails → Mosaic should be cut or radically redesigned.

---

## 13. Implementation Order

If Tetris-like is built first, much of the scaffolding is reusable. Order for Mosaic-specific layer:

1. **Board resize & line-clear disable** — change grid to 6×6, remove clear-on-line logic.
2. **Piece pool & tray** — implement the 4-cell-max piece set; tray size 4; mirrored seeded queue.
3. **Color system** — color enum on cells, colored variant of piece sprites, colored piece in queue.
4. **Match detection** — on placement, walk the placed piece's cells, check edge-adjacency for same color, fire match events.
5. **Scoring UI** — score counters per player, animated bumps on score changes.
6. **Mosaic clear** — detect full board, trigger reset + bonus + celebration.
7. **Garbage** — 1×1 random-column landing with short decay.
8. **Comeback bonus** — score-difference check at every match event, apply ×2 multiplier when threshold met.
9. **Boosters** — Hammer first (the safety valve), then Color Swap, then Bomb Drop.
10. **Top-out softening** — danger zone visual + emergency Hammer on first soft-lock; real top-out on second.
11. **Bot AI tweaks** — heuristic adjustments including basic booster usage.

---

## 14. Design Critique — Pros, Cons, Open Concerns

I designed this. I also have to argue against it. Here's the honest read.

### Pros (real strengths)

- **Distinct identity from Tetris-like.** Different feel, different audience, valuable A/B in playtest.
- **Strong dramatic moment.** "Filling the entire board" is a binary, rare, satisfying climax. Tetris-likes give you constant small wins; Mosaic gives you fewer, bigger ones.
- **Elegant unified mechanic.** Color matching does three jobs at once: scoring, attack, visual feedback. Few moving parts.
- **Visually marketable.** A colorful, slowly-completing mosaic is a much better marketing asset than a grey block grid.
- **Broader audience potential.** Lower-stress PvP appeals to players who bounce off Tetris-pace combat.
- **Fills a market gap.** Mobile PvP puzzle is mostly fake-PvP match-3 with async opponents. A real-time fill-and-match game has no obvious incumbent on mobile.

### Cons (real risks)

- **🚨 "Fill the whole board" is brutally hard with random pieces.** A single awkward gap and you can't complete. Average player might fill 0 boards per 90s. If `MOSAIC_CLEAR_BONUS = 5` and you never clear, scoring collapses to "who matched more colors", which is a much smaller game.
- **🚨 No line clears = no escape from bad placements.** Tetris-likes use clears as the player's safety valve. Mosaic removes it. First mistake echoes for the rest of the match. High frustration risk, high abandonment.
- **🚨 1×1 garbage is barely PvP.** A single cell that fades in 5s is a nudge, not a punch. Players might feel they're playing parallel singleplayer with a leaderboard. The competitive hook weakens.
- **Color frequency is fragile.** Too few colored pieces (≤15%) = matches are rare, no PvP signal. Too many (>40%) = match-spam dominates, "fill" identity erodes. The window is narrow and only playtests will find it.
- **No comeback mechanic.** Falling behind in score = hope opponent tops out. There's no equivalent of Tetris-like's pressure bonus. Once you're losing, you have nothing to dramatically swing things.
- **Strategic depth might be shallow.** Yes you're planning color placement, but the core placement problem (where do shapes fit) is already what Block Blast does. Adding a color layer might feel cosmetic rather than transformative.
- **Color match adjacency has fiddly edge cases.** Piece touches red on one side, another red region on the other — one match or two? Spec says one in v1. But that's a designer call against player intuition (visually it's two clusters). Will produce "feels wrong" feedback.
- **The visual celebration of Mosaic clear has to carry a lot.** If filling the whole board feels like a chore rather than a peak, the entire identity falls apart. Animation/SFX work is more critical here than in Tetris-like.

### Honest comparison vs. Tetris-like

| Question | Tetris-like | Mosaic |
|---|---|---|
| Easier to balance? | Yes (more moving parts but each is tunable) | No (narrow windows on color rate, decay, scoring) |
| More familiar feel? | Yes (Tetris/Block Blast lineage) | No (genuinely novel — risk + opportunity) |
| Higher ceiling for "fun"? | Medium — proven pattern | Higher IF it lands, lower if it doesn't |
| Higher floor? | Yes — won't be terrible | No — could feel empty |
| Better mobile-marketable? | OK | Better (colors, mosaic visual) |
| Better as a competitive game? | Yes | No (gentler swings, harder to read tension) |

### My recommendation
**Build both. Mosaic is the riskier bet but it's where the differentiation lives.** Tetris-like is the safety net — it's where you go if Mosaic playtests dead. The prototype should let testers play both back-to-back so you get real comparative data, not just absolute reactions.

If forced to pick one to ship without playtesting: **Tetris-like**. Lower ceiling, much higher floor.

### Tunable hedges (in case prototype reveals problems)

If Mosaic feels too brittle:
- Enable line clears as a **rescue mechanic** only (clears the line but gives 0 points and 0 garbage). Just a survival valve.
- Increase color rate to 35% to give more PvP moments.
- Increase garbage cells per match to 2 to make attacks feel real.
- Add a "stuck reset" button (consumable, 1-2 uses per match) that lets player wipe board for 0 points.

Park these. Don't pre-build them. But know they're cheap drop-in fixes if needed.

---

## 15. Boosters

**Layered safety design.** Mosaic uses TWO independent layers against soft-lock and difficulty problems, and both stay in v1:

1. **Core safety** (specified in §3): **4-piece tray** (raised from 3), **pieces capped at 4 cells** (5-cell line, 5-cell plus, and 3×3 square removed from pool). These reduce the BASE rate of soft-locks on a 6×6 grid. Not optional, not booster-replaceable.
2. **Boosters** (this section): three player-driven abilities — Hammer (defensive), Color Swap (utility/depth), Bomb Drop (offensive). Handle the residual difficulty PLUS add depth and PvP punch.

The two layers are complementary, not redundant. Core fixes lower the baseline soft-lock rate; boosters give the player tools when it happens anyway, plus enrich the strategy and PvP feel.

This section was developed from a competitive research pass over Block Blast, Royal Match, Toon Blast, Wood Block puzzles, Tetris Mobile Royale, and Match Masters. Conventions taken from the genre:

- **Hammer / single-cell delete** is the canonical unstick tool in 1010-style block puzzles (Wood Plus Block Puzzle, Wood Block Puzzle — Google Play, 2025). No board-wide clears, only surgical.
- **Charge-via-in-match-action** is the PvP pattern (Match Masters, Candivore Helpshift 2025) — boosters earned by playing, not just by inventory, keep PvP active.
- **Combos / charge-gated big boosters** (Royal Match's Hammer + Rocket combos; Toon Blast's Disco Ball at 9+ cubes; Dream Games Helpshift 2025; Fandom 2024) — earn-by-skill plus a rare payoff button.

Three boosters for the prototype. Start narrow. Add more only if playtests demand them.

### Booster 1: Hammer (defensive — the unstick lever)
- **Effect:** Tap any single occupied cell on your own board to delete it. No score change. No garbage sent.
- **Acquisition:** 2 free charges at match start. Recharges by **+1 per `HAMMER_RECHARGE_INTERVAL_SECONDS` of active play** (active = a piece was placed within the last `STALL_THRESHOLD_SECONDS`; idle / stalling time does NOT count).
- **Critically: Hammer recharge is NOT tied to Mosaic Clear.** Decoupled deliberately to prevent rush-to-clear meta (see §17 analysis below).
- **Caps:** `HAMMER_START_CHARGES = 2`, `HAMMER_RECHARGE_INTERVAL_SECONDS = 25`, `HAMMER_MAX_CARRIED = 3`.
- **Cooldown after use:** `HAMMER_COOLDOWN_SECONDS = 3.0` (prevents spam).
- **Why this works for Mosaic:** surgical, can't be hoarded indefinitely, replaces the line-clear safety valve at a cost (consumes a limited resource), and gives BOTH players the same recharge opportunity regardless of who's leading.
- **Risk:** too generous = trivialises the "fill the board" tension. Watch the cap; if players hammer-spam in playtests, drop to 1 start charge or extend the interval.

### Booster 2: Color Swap (utility — Mosaic's unique depth lever)
- **Effect:** Tap any colored cell on **your own board** to cycle its color (Red → Yellow → Blue → Red). If the new color creates an adjacency match → it triggers normally (+1 score, +1 garbage to opponent).
- **Acquisition:** charged by scoring 3 color matches in a match. Starts at 0 charges.
- **Caps:** `COLOR_SWAP_CHARGE_COST = 3 matches`, `COLOR_SWAP_MAX_CARRIED = 2`.
- **Cooldown after use:** `COLOR_SWAP_COOLDOWN_SECONDS = 2.0`.
- **Why this works for Mosaic:** leans directly into the 3-color system you already built — depth without new mechanics. Skill-gated (you must already be playing well to earn it). Creates moments of cleverness ("if I swap that yellow to blue, I trigger a match AND set up the next one").
- **v1 limitation — own board only.** Targeting opponent's board is the cooler version but requires (a) targeting UI on the opponent's board, (b) opens a grief vector (destroying their near-completion setup feels rage-inducing). Park "swap opponent's cells" as a v2 expansion if playtests show players want more interaction.
- **Risk:** color-cycle on a cell that's part of a current cluster might re-trigger a match repeatedly if not guarded. Implementation note: a cell that just matched is "match-locked" for `COLOR_MATCH_LOCK_SECONDS = 1.0` (cannot re-fire the match event during that window).

### Booster 3: Bomb Drop (offensive — fixes weak PvP, dual-charged)
- **Effect:** Send a 2×2 garbage block to a random column on the opponent's board (gravity drop). All 4 cells share the standard ~5s decay.
- **Acquisition (TWO sources — important):**
  - **Charge A — offensive:** +1 charge per own Mosaic Clear (winning-player path).
  - **Charge B — defensive:** +1 charge per `BOMB_DROP_GARBAGE_ABSORB_THRESHOLD` garbage cells absorbed (default **8** — losing-player path. "Eat their barrage, hit back.").
- **Caps:** `BOMB_DROP_MAX_CARRIED = 1`. Hitting either threshold while already at cap = wasted charge (no carryover).
- **No cooldown beyond consumption.**
- **Why dual-charged:** the original single-source design (Mosaic Clear only) created a rich-get-richer problem — whoever cleared first got a free weapon to swing at the trailing player. Adding the absorb-based path gives the losing player a way to charge through being attacked. Whoever's eating pressure earns the counter-punch.
- **Why this works for Mosaic:** the standard 1×1-per-color-match garbage is too gentle (§14). Bomb Drop gives players a satisfying "I'm hitting them" button without flooding the opponent with constant pressure.
- **Risk:** absorb threshold of 8 may be too low (trailing player turns matches around too fast) or too high (charge never accumulates because of decay clearing absorbed cells). Tune on playtest data — start at 8 and adjust.
- **Secondary risk:** late-match bomb spam → opponent tops out from a single bomb when their board is full. Mitigation: 2×2 only, same 5s decay, no combo with color-match garbage.

### Comeback mechanic (point-deficit bonus)

Mosaic has no natural comeback — boosters don't help the trailing player intrinsically (all skill-gated). Without an explicit comeback, falling behind in the first 30s means 60s of dead match. Borrowed from Tetris-like's pressure-bonus principle:

- **Trigger:** when your score is at least `COMEBACK_DEFICIT_THRESHOLD` points BEHIND your opponent's score at the moment of a color match.
- **Effect (single rule, doubled):** that color match scores `+2` instead of `+1`, AND sends `2 garbage cells` instead of `1`.
- **Boundary behaviour:** evaluated per-match, real-time. If your match brings you back within threshold, the NEXT match is normal again. No latching, no grace period.
- **Tunable:** `COMEBACK_DEFICIT_THRESHOLD = 3`. `COMEBACK_MATCH_MULTIPLIER = 2`.
- **Risk:** flip-flop matches where lead changes hands every 10s feels chaotic. Watch in playtest; if matches feel unstable, reduce to score-only doubling (no garbage doubling) as first lever.

### Danger zone & emergency Hammer (top-out softening)

Raw top-out (no legal placement = instant loss) is brutal for new players. Add two layers:

**Danger zone visual** (cosmetic warning):
- When player's board occupancy ≥ `DANGER_ZONE_OCCUPANCY` (default **0.75**, i.e., ≥27 of 36 cells), the board edge gets a pulsing red glow.
- No gameplay effect — just signals "you're close to losing."
- Persists until occupancy drops below threshold.

**Emergency Hammer** (mechanical save):
- The engine continuously monitors whether the player has at least one legal placement for at least one tray piece.
- If at any point ALL three tray pieces have no legal placement on the board:
  - **First occurrence in the match:** grant **+1 emergency Hammer charge** automatically (bypasses cap). UI prompts "EMERGENCY — tap a cell to clear it." Player must use it within `EMERGENCY_HAMMER_DEADLINE_SECONDS` (default **5s**) or system auto-uses on the cell that would unlock the largest tray piece.
  - **Second occurrence in the match:** real top-out, instant loss.
- **Constants:** `EMERGENCY_HAMMER_PER_MATCH = 1`, `EMERGENCY_HAMMER_DEADLINE_SECONDS = 5.0`.
- **Why:** sudden-death is a known mobile abandonment trigger. One freebie save per match is a known mitigation (Block Blast's revive pattern, fan-source). After that, the loss is earned.
- **Risk:** players may play recklessly knowing they have a freebie. Caps it at one per match — second time is real death.

### Shared properties
- **UI:** booster bar of 3 icons under the tray. **Slots with 0 charges are HIDDEN (not greyed)** — reduces cognitive load and screen density (Mosaic was supposed to be the visually-cleaner variant; we keep that promise). Charge counter on each visible icon. Brief glow animation when a new charge is earned (also serves to alert the player that a slot just appeared).
- **Targeting:** Hammer and Color Swap require a tap on a board cell after activation (cancellable). Bomb Drop is fire-and-forget.
- **Match-end:** unused boosters do not carry over (no meta in prototype).
- **Anti-stall interaction:** booster activation counts as "active play" for the decay anti-stall safeguard (resets the stall timer).

### Tuning constants (add to §9)
```
// Boosters — Hammer
HAMMER_START_CHARGES               = 2
HAMMER_RECHARGE_INTERVAL_SECONDS   = 25   // active-play seconds per charge; decoupled from Mosaic Clear
HAMMER_MAX_CARRIED                 = 3
HAMMER_COOLDOWN_SECONDS            = 3.0

// Boosters — Color Swap
COLOR_SWAP_CHARGE_COST             = 3    // color matches needed per charge
COLOR_SWAP_MAX_CARRIED             = 2
COLOR_SWAP_COOLDOWN_SECONDS        = 2.0
COLOR_MATCH_LOCK_SECONDS           = 1.0  // re-match guard after a placement / swap

// Boosters — Bomb Drop (dual-charged)
BOMB_DROP_CHARGES_PER_FULL_CLEAR   = 1    // charge A: own mosaic clear
BOMB_DROP_GARBAGE_ABSORB_THRESHOLD = 8    // charge B: garbage cells absorbed per charge
BOMB_DROP_MAX_CARRIED              = 1
BOMB_DROP_GARBAGE_SHAPE            = 2x2

// Comeback mechanic
COMEBACK_DEFICIT_THRESHOLD         = 3    // score points behind to activate
COMEBACK_MATCH_MULTIPLIER          = 2    // applies to BOTH score and garbage on a match

// Top-out softening
DANGER_ZONE_OCCUPANCY              = 0.75 // visual warning threshold (fraction of board filled)
EMERGENCY_HAMMER_PER_MATCH         = 1    // free save on first soft-lock
EMERGENCY_HAMMER_DEADLINE_SECONDS  = 5.0  // time to manually pick cell before auto-use
```

### Expected booster usage per 90s match (designer guess, validate)

Recalibrated for 6×6 board (mosaic clears more frequent → Bomb Drop charges more frequent):
- **Hammer:** ~4–5 uses (2 start + ~2–3 from 25s recharges over ~75s of active play)
- **Color Swap:** ~2–3 uses (more matches happen on smaller board)
- **Bomb Drop:** ~1–3 uses (1–2 from mosaic clears + occasional absorbs)
- **Emergency Hammer:** ~0.3 uses (only fires on near-top-outs; expected slightly more common on 6×6 due to tighter board, but still rare)
- **Comeback bonus:** active during ~30–50% of trailing-player matches (depends on opponent skill gap)

If actual playtest shows zero booster activations from average players → the acquisition costs are too high, drop thresholds. If matches degenerate into booster-spam → tighten caps.

### Why NOT a 4th booster (Reroll Tray)
The analyst's research surfaced a "Reroll Tray" booster — discard your current tray, draw the next 3 pieces. I cut it for the prototype because it conflicts with the mirrored-seeded queue. The whole point of mirroring is "you and your opponent get the same pieces — pure skill expression." Reroll lets one player advance their queue pointer independently, desyncing the fairness narrative. Hammer already covers "I'm stuck and need an escape." Adding Reroll dilutes both the mirror identity and the unstick role of Hammer. Park it as a candidate for the non-mirrored future variant if Mosaic validates.

### Future expansion (out of prototype scope)
Booster set is intentionally narrow for v1. If Mosaic validates and we want more depth, candidates documented for v2 include:
- Color Swap on opponent's board (with grief mitigation)
- Tray Peek (see the next 3 pieces beyond your current tray)
- Shield (one-time block on incoming garbage)
- Mosaic Skip (auto-fill remaining empty cells to trigger clear — very expensive to earn)
- Time Steal (PvP — shave 5s off opponent's effective match clock by adding 5s to your decay timers)

These are not implemented. They are documentation of where the design can extend.

---

## 16. Post-Fix Design Analysis

After applying the 5 fixes (Hammer decoupling, Bomb Drop dual-charge, comeback bonus, danger zone + emergency hammer, hide-when-empty UI), here is the honest re-evaluation.

### What's solved

| Original hole | Fix applied | Verdict |
|---|---|---|
| Bomb Drop = rich-get-richer | Dual charge (own clear OR absorb 8 garbage) | **Solved.** Both players have a path. Leading player path is faster but losing player isn't shut out. |
| No comeback mechanic | Doubled score + garbage on matches when ≥3pt deficit | **Solved structurally,** tuning unknown until playtest. |
| Rush-to-clear meta | Hammer recharge decoupled from Mosaic Clear (time-based) | **Solved.** Mosaic Clear still rewards (+5 score, +1 Bomb Drop charge), but is no longer the *only* way to recover board. Color-matching layer is no longer just a feeder. |
| Top-out cliff | Danger zone visual + 1 emergency Hammer per match | **Mostly solved.** First near-top-out is a freebie save. Second is real. Removes the abandonment trigger while keeping stakes. |
| UI density | Hide booster slots with 0 charges | **Partially solved.** At match start, only Hammer is visible (2 charges). Color Swap and Bomb Drop appear as they're earned. Density grows with progression — manageable. |

### New problems the fixes introduced

These are the holes I have to flag honestly. Fixes are never free.

#### 1. Comeback bonus could create flip-flop matches
Doubling BOTH score and garbage on every match while trailing is a strong rubber-band. Realistic scenario: Player A leads by 4 (8 vs 4). Player B matches twice (+4 with comeback) → 8 vs 8 → no comeback. Player A matches once (+1) → 9 vs 8 → comeback re-activates for B. Lead changes every ~10s.

This may be *exciting* OR may feel *random/chaotic*. Cannot know without playtest. The mitigation is already documented (drop garbage doubling first, keep score doubling) — but if even score-doubling feels flip-floppy, the threshold itself needs to rise (3 → 5 or 6).

#### 2. Bomb Drop dual-charge can stack absurdly
A skilled trailing player can: absorb 8 garbage (Bomb Drop charge B), then do their own Mosaic Clear (Bomb Drop charge A). With `MAX_CARRIED = 1`, the second charge is wasted — but the timing of carrying then firing means a player could in theory fire one bomb, then immediately re-earn from the next 8 cells absorbed. If matches generate lots of garbage, Bomb Drop could become frequent enough to feel oppressive.

Watch: bombs-per-match in playtest. If >3 average → raise absorb threshold to 12. If <0.5 → lower to 6.

#### 3. Emergency Hammer creates "cliff edge gameplay"
Players who learn the system will deliberately drive their board to near-top-out to "bank" the emergency Hammer for a useful moment (e.g., right before they'd otherwise top out for real). This is RATIONAL exploit, not a bug. Mitigation in design: emergency Hammer fires automatically with `DEADLINE = 5s` AND placement on the cell that unlocks the largest piece — so a player who tries to bank it might find the auto-use makes a different choice than they wanted.

Still: optimal play in v1 may involve courting the danger zone. Not a fatal issue but worth observing.

#### 4. Hammer-recharge-by-time creates an idle-but-active strategy
The recharge is gated on `STALL_THRESHOLD_SECONDS` (must place every 2s). A player who has nothing better to do may place pieces in "junk corners" just to keep the recharge timer ticking. This is a less-bad version of the original stalling exploit, but it's still suboptimal play that's rewarded.

Possible v2 mitigation: tie recharge to "meaningful placements" (e.g., piece must touch at least one existing cell or fill ≥3 cells). Defer to playtest data.

#### 5. UI hide-when-empty has a teaching cost
New players see one booster (Hammer) at match start. They don't know Color Swap or Bomb Drop exist until they pop in. This means:
- First few matches: player doesn't know how Color Swap works when it appears mid-game → may not use it.
- Without tutorial, the booster systems take 3-5 matches to be discovered fully.

This was a deliberate trade against UI density. The alternative — always-visible greyed slots — would teach the system upfront but at the cost of a more cluttered screen. For prototype: keep hide-when-empty, add a one-line on-first-appearance tooltip ("New booster ready: Color Swap — cycle a cell's color"). Cheap.

### Updated risk profile (revised from §14)

| Concern | Pre-fix severity | Post-fix severity |
|---|---|---|
| "Fill the board" too hard with random pieces | HIGH | HIGH (boosters help but identity intact — Hammer is the safety net) |
| No line clears = no recovery | HIGH | LOW (Hammer + emergency Hammer cover it) |
| 1×1 garbage = no PvP feel | HIGH | MEDIUM (Bomb Drop adds punch; color-match garbage still light) |
| Color rate fragile to tune | MEDIUM | MEDIUM (unchanged) |
| No comeback mechanic | HIGH | MEDIUM (fix in place, tuning uncertain) |
| Strategic depth shallow | MEDIUM | LOW (Color Swap + Bomb Drop charge paths add real decisions) |
| Top-out cliff | HIGH | LOW (emergency Hammer + danger zone) |
| Bomb Drop snowball | (new, post-boosters) | LOW (dual-charge solved it) |
| Flip-flop matches from comeback | (new) | UNKNOWN (depends on playtest) |
| Booster discoverability | (new) | LOW (tooltip on first appearance) |

### Bottom line

Mosaic before boosters: ~30% chance of being a playable prototype.
Mosaic with boosters (first round): ~60% — but with structural rich-get-richer + no-comeback problems.
Mosaic with these fixes: **~80%** — structural problems addressed, remaining concerns are tuning-level (need playtest data, not design rework).

The design is now **ready to build**. The unknowns left are numbers, not architecture:
- Is `COMEBACK_DEFICIT_THRESHOLD = 3` the right number?
- Is `BOMB_DROP_GARBAGE_ABSORB_THRESHOLD = 8` right?
- Is `HAMMER_RECHARGE_INTERVAL_SECONDS = 25` right?
- Is `COLOR_RATE = 0.25` right?

All four are single-constant tunes after playtest. None require redesigning the system. That's the difference between "ready to prototype" and "still designing."

### What I'd still NOT do without more data

- Add a 4th or 5th booster. Three is enough. Adding more before validating these three is premature.
- Add booster trees / leveling / progression. That's monetization layer, not prototype scope.
- Auto-balance comeback bonus dynamically (e.g., scale with deficit). Single threshold first; if it fails, then tier it.

---

## 17. Glossary (deltas from Tetris-like)

- **Mosaic clear:** the event of filling the entire 6×6 board → +5 score and reset.
- **Match event:** placing a colored piece such that it touches a same-color cell already on the board.
- **Colored piece:** a piece whose cells carry one of the 3 palette colors. ~25% of pieces in the queue.
- **Color cluster:** an edge-connected group of same-color cells on the board. Used for visual feedback only in v1 (no chain bonus).
- **Hammer:** booster — deletes a single own-board cell. The unstick lever.
- **Color Swap:** booster — cycles a single own-board colored cell to the next color, potentially triggering a match.
- **Bomb Drop:** booster — sends 2×2 garbage to opponent. The "attack" button.
- **Match-lock:** brief post-match cooldown on a cell to prevent re-firing the match event when a Color Swap moves through colors that re-trigger adjacency.
- **Comeback bonus:** doubled score + garbage on a color match when the player is trailing by ≥3 points.
- **Danger zone:** visual warning when a player's board is ≥75% occupied.
- **Emergency Hammer:** auto-granted +1 Hammer charge on first soft-lock per match; second soft-lock is a real top-out.
