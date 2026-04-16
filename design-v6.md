# MIX IT v6.2 — BAR CLASH (No-Spawn Boards)

**Date:** 2026-04-15  
**Status:** Design — ready for prototype rewrite  
**Type:** Mobile F2P PvP casual game  
**Core mechanic:** Water Sort Puzzle + real-time PvP serve-race + board refresh rounds  
**Reference direction:** Match Masters (shared objective PvP), Rush Royale (parallel boards, ladder/meta)  

---

## 1. Elevator Pitch

Two bartenders. Shared customers. Parallel boards.

Both players receive the same short pour-sort board and race to serve customers in the middle before the other side does.  
When a board is exhausted, a new board drops in instantly. The match is decided by score when the timer ends.

**Player fantasy:**  
"I'm faster than you. I read the board, route colors cleanly, and steal the best customers before you can finish your drink."

**Core emotion loop:**
- Per pour: board becomes cleaner, closer to a serve
- Per serve: immediate point gain, speed-win over opponent
- Per board: short tactical puzzle with clear pressure
- Per match: multiple close micro-rounds, score swings, comeback potential

---

## 2. Design Goal of v6.2

This version fixes the biggest pacing problem from v6:

- In v6, served glasses already became empty workspace.
- But the match could still stall because the only way to inject new material was the time-gated Color Spawn system.
- That created downtime: strong players could clear the board faster than the game could feed new decisions.

**v6.2 removes Color Spawn from the core loop.**

Instead:
- the match is played on a **sequence of short finite boards**
- each board is a normal pour-sort puzzle with enough workspace
- when a board is exhausted or stalls, both players get a fresh board instantly

This keeps the PvP customer race, but makes the board feel more like a real pour-sort game and less like a waiting game.

---

## 3. What stays from v6

The following systems stay conceptually the same:

- Shared customer queue in the center
- Both players race to serve the same customers
- Pure glasses are serveable
- Serve value scales with number of layers
- First serve gets a speed bonus
- Second serve inside the grace window gets reduced value
- Customers can time out and punish both players
- Trophies, arenas, fake matchmaking, and visible AI opponent remain
- Parallel boards remain (you bottom, opponent top)

---

## 4. What changes from v6

Removed from core match:
- Color Spawn button
- Spawn charges
- Spawn recharge timers
- AI spawn logic
- Spawn-based pacing

Changed:
- Match now consists of **multiple short boards**, not one long board fed by new color injections
- Board refresh becomes a core pacing mechanic
- Workspace is stabilized by starting with **2 empty bottles**
- Prototype power-ups become more pour-sort native:
  - Extra Bottle
  - Flash Pour
  - Swap
  - Clear Bottle

Removed from prototype power-up roster:
- Freeze

---

## 5. Match Layout

Portrait layout remains close to v6:

```
┌──────────────────────────────────────┐
│  YOU 750        0:27        900 OPP │
├──────────────────────────────────────┤
│          Opponent board              │
│       5-7 small glasses              │
├──────────────────────────────────────┤
│           Customer zone              │
│   3 shared customers + patience      │
├──────────────────────────────────────┤
│      Power-up inventory (2 slots)    │
├──────────────────────────────────────┤
│            Player board              │
│       5-7 full-size glasses          │
└──────────────────────────────────────┘
```

### Zones
| Zone | Content |
|---|---|
| Score bar | Timer center, your score left, opponent score right |
| Opponent board | AI glasses, visible state only |
| Customer zone | 3 active customers, patience bars |
| Power-up inventory | 2 held power-up slots |
| Player board | Your interactive glasses |

---

## 6. Core Match Structure

### 6.1 Match Duration
Prototype default:
- **90 seconds**

Recommended test variants later:
- 75s
- 90s

---

### 6.2 Match = sequence of micro-boards

A single match contains multiple short pour-sort boards.

#### Board loop
1. A board appears for both players.
2. Both players sort and serve customers from that board.
3. Served glasses become empty workspace.
4. When the board is exhausted or stalls, a new board is generated.
5. Match continues until the main match timer ends.

#### Expected pacing
A 90-second match should typically contain:
- **3 to 5 boards**

This keeps the game active without requiring artificial material spawning.

---

### 6.3 Shared customers

Customers remain the shared objective.

#### Rules
- 3 customers visible at all times
- Each customer wants **one specific color**
- Both players can work toward the same customer simultaneously
- First player to serve gets the full reward + speed bonus
- Second player may still serve within a short grace window for reduced reward
- If patience expires, both players lose points

#### Customer patience
- Default patience: **20 seconds**
- Patience bar:
  - green > 8s
  - yellow 4-8s
  - red < 4s

#### Timeout
- Customer leaves angry
- **-25 points to both players**
- Immediately replaced by a new customer

---

### 6.4 Serving drinks

A glass is serveable if:
- it contains only one color
- it has at least 1 layer
- its color matches at least one visible customer

#### Serve values
| Layers | Type | Base points |
|---|---|---|
| 1 | Shot | 50 |
| 2 | Small drink | 100 |
| 3 | Regular drink | 150 |
| 4 | Full cocktail | 200 |

#### First-serve bonus
- First player to serve that customer: **+50**

#### Grace window
- Second player can still serve the same customer within **3 seconds**
- Gets **50% of base points**
- Gets **no speed bonus**

#### Serve result
- Served glass becomes empty
- It stays on board as workspace

---

### 6.5 Combo bonus

- If you serve again within **10 seconds** of your previous serve:
  - gain **+50 combo bonus**
- Combo resets if more than 10 seconds pass without a serve

---

## 7. Board Rules

### 7.1 Basic pour rules

Classic water-sort rules:

- Each bottle capacity = **4 layers**
- A pour is legal if:
  - source has at least 1 layer
  - destination is empty, or destination top color matches source top color
  - destination has room for the full contiguous top segment
- Full contiguous top segment transfers
- Illegal pour = shake, no state change
- Undo remains available and free in prototype

---

### 7.2 Starting workspace rule

Each board must start with:
- **one full source bottle per color**
- **2 empty bottles**

This is the default workspace rule for v6.2.

#### Prototype examples
- 3 colors → 3 full + 2 empty = 5 bottles
- 4 colors → 4 full + 2 empty = 6 bottles
- 5 colors → 5 full + 2 empty = 7 bottles

This keeps the board readable and avoids early hard-locks.

---

### 7.3 Board generation

Both players receive the **same board**.

#### Generation algorithm
1. Determine active color count from arena
2. Create solved source layout:
   - one full bottle per color
   - two empty bottles
3. Apply 40-60 random legal pours to scramble
4. Reject very weak boards if needed:
   - too many instant pure serves
   - too few interesting routes
5. Use the same seeded board for player and AI

#### Design goal
The board should feel like a short tactical puzzle:
- readable
- solveable
- not trivial
- not deadlocked on spawn

---

### 7.4 Board refresh

Board refresh replaces Color Spawn as the pacing engine.

A fresh board appears when the current board is no longer producing good play.

#### Refresh triggers
A board refresh happens when **any** of these is true:

**A. Stall timer**
- No player has served a customer for **5 seconds**

**B. Board exhaustion**
- A player's board has very low remaining material:
  - **4 or fewer total layers remaining**
- If both sides are nearly exhausted, refresh immediately

**C. Hard deadlock**
- No legal pours remain on both boards

#### Refresh flow
1. Current board fades out quickly
2. New board fades/slides in
3. Existing match timer continues
4. Customer queue continues
5. Scores remain
6. Power-up inventory remains

#### Important rule
Board refresh is **global**:
- both players get the new board at the same time

This prevents desync and keeps the duel fair.

---

### 7.5 Customer-board relationship

Customers should feel related to the current board.

#### Rule
Each board should bias customer generation toward colors that are actually present and likely to be served.

Prototype recommendation:
- **70%** of new customers use dominant colors from the current board
- **30%** can come from the full active color pool

This keeps the board and queue aligned without becoming deterministic.

---

## 8. Power-Ups (Prototype)

The prototype keeps 4 power-ups, but all are now aligned with pour-sort routing and workspace.

### 8.1 Inventory
- Max held power-ups: **2**
- Power-ups spawn in the center zone
- Player taps to collect before AI does
- Tap a held power-up to activate
- If inventory is full, player must use one before grabbing another

---

### 8.2 Power-up roster

#### Extra Bottle ➕
- Adds one empty bottle
- Lasts for the **rest of the current board**
- If a board refresh happens, the temporary extra bottle disappears with the old board
- Purpose: workspace expansion

#### Flash Pour ⚡
- Your pours become instant for **8 seconds**
- Purpose: speed conversion when you already see the route

#### Swap 🔄
- Select any 2 of your bottles
- Their entire contents swap instantly
- Purpose: repositioning / route rescue

#### Clear Bottle 🧽
- Select one of your bottles
- All contents are discarded
- Bottle becomes empty
- Purpose: emergency anti-deadlock valve

---

### 8.3 Power-up spawning
- First spawn: **8 seconds** into the match
- Next spawns: every **12-18 seconds**
- Power-up bubble lingers for **6 seconds**
- AI may collect it if player does not

Power-ups stay as variance and comeback tools, but no longer replace the board engine.

---

## 9. AI Opponent

The prototype still uses AI instead of real multiplayer.

### 9.1 AI board
- Opponent board is visible
- It shows actual AI bottle contents
- Player can read what AI is working on

### 9.2 AI logic
Every AI tick:
1. Read visible customers
2. Evaluate legal pours
3. Prefer moves that:
   - create a serveable pure bottle
   - increase stack height toward a customer color
   - preserve workspace
4. Occasionally make a suboptimal move based on arena difficulty
5. Serve after a short reaction delay if possible

### 9.3 AI power-up usage
- **Extra Bottle:** when board is tight
- **Flash Pour:** when several good moves are lined up
- **Swap:** when it creates a strong serve route
- **Clear Bottle:** when board is clogged and no efficient route exists

---

## 10. Scoring

### Point sources
| Event | Points |
|---|---|
| Serve 1-layer drink | 50 |
| Serve 2-layer drink | 100 |
| Serve 3-layer drink | 150 |
| Serve 4-layer drink | 200 |
| First-to-serve bonus | +50 |
| Combo bonus | +50 |
| Customer timeout | -25 to both |

### Optional board-end bonus (prototype test)
This is optional and can be tested later:
- **+25 Efficiency Bonus** if a board ends while you still have at least 1 empty bottle

Only use this if the base score race feels too flat.

---

## 11. Arenas

The ladder/meta from v6 stays, but arena progression now scales the boards instead of spawn complexity.

### 11.1 Arena scaling knobs
Arenas can scale:
- number of colors
- number of bottles
- power-up roster
- AI skill
- customer patience tuning

### 11.2 Prototype arenas
| Arena | Trophies | Colors | Bottles | Power-ups |
|---|---|---|---|---|
| Juice Stand | 0-199 | 3 | 3 full + 2 empty | Extra Bottle, Flash Pour |
| Beach Bar | 200-499 | 3 | 3 full + 2 empty | + Swap |
| Cocktail Lounge | 500-999 | 4 | 4 full + 2 empty | + Clear Bottle |
| Speakeasy | 1000-1499 | 4 | 4 full + 2 empty | All 4 |
| Rooftop Terrace | 1500-2499 | 5 | 5 full + 2 empty | All 4 |
| Grand Hotel | 2500+ | 5 | 5 full + 2 empty | All 4 |

---

## 12. Match Flow

### 12.1 Flow
HOME → MATCHMAKING → PRE-MATCH → COUNTDOWN → MATCH → RESULT

### 12.2 Match timeline example
- 0:00 Board 1 begins
- 0:08 First power-up spawns
- 0:18 Board 2 refresh
- 0:35 Board 3 refresh
- 0:52 Board 4 refresh
- 1:10 Board 5 refresh
- 1:30 Match ends

This is illustrative, not hardcoded.

---

## 13. Home / Matchmaking / Result

These stay mostly unchanged from v6:

### Home
- Arena badge
- Trophy progress
- Stats
- PLAY button

### Matchmaking
- Fake search 2-4 seconds
- Opponent generated within same arena band
- MATCH FOUND intro card

### Result
- Win / Lose / Draw
- Score comparison
- Trophy gain/loss
- Arena progress bar
- Play Again / Home

---

## 14. Prototype Scope (v6.2)

### 14.1 What to build
Required:
- Parallel player + AI boards
- Shared customers
- Pure-glass serving
- Layer-based scoring
- Speed bonus
- Combo bonus
- Board refresh system
- AI opponent
- 4 prototype power-ups
- Home
- Matchmaking
- Result
- Trophy progression
- Arenas
- Visible opponent board

Not required:
- Real multiplayer
- Chests
- Battle pass
- Sticker album
- Shop
- Sound

---

### 14.2 Smallest viable prototype
If time is tight, build this subset first:

- 1 arena only
- 3 colors
- 3 full + 2 empty bottles
- 3 shared customers
- Serve + scoring
- AI opponent
- Board refresh
- 2 power-ups only:
  - Flash Pour
  - Clear Bottle

This smallest slice is enough to answer the main question:
**Is PvP customer-racing fun when there is no downtime and no Color Spawn waiting?**

---

## 15. Open Questions for Playtesting

1. Is **90 seconds** the right match length, or is 75 better?
2. Is **5 seconds without a serve** the right board refresh trigger?
3. Are **2 empty bottles** enough in late arenas?
4. Does **Clear Bottle** feel fair or too strong?
5. Are customers readable enough when the board changes multiple times per match?
6. Does the game need a small board-intro overlay ("Round 2", "Fresh order mix")?
7. Is the visible opponent board readable enough, or should the opponent status be simplified?

---

## 16. Success Criteria

1. No dead downtime waiting for material
2. No common hard-locks from lack of workspace
3. Shared customers remain the emotional center of the match
4. Matches feel closer to a competitive race, not two isolated solitaire boards
5. Power-ups add tactical choice without replacing the core puzzle
6. The game feels more native to pour-sort logic than v6 did

---

## 17. Build Priority

1. Board generation + pouring
2. Serve logic + customers + scoring
3. Board refresh system
4. AI opponent
5. Result flow + trophies
6. Power-ups
7. Arena scaling
8. Polish

Cut polish first, not board readability or pacing.
