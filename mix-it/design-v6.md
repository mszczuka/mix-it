# MIX IT v6.2 — BAR CLASH

**Date:** 2026-04-15  
**Status:** Design — prototype built  
**Type:** Mobile F2P PvP casual game  
**Core mechanic:** Water Sort Puzzle + real-time PvP serve-race  
**Color palette:** 8 colors (Red, Blue, Yellow, Green, Purple, Orange, Pink, Teal)  
**Reference direction:** Match Masters (shared objective PvP) — target archetype  
**Plugin (core gameplay):** Water Sort Puzzle + real-time PvP serve-race  

---

## 1. Elevator Pitch

Two bartenders. Shared customers. Parallel boards.

Both players receive the same scrambled pour-sort board and race to sort colors, fill glasses, and serve customers in the middle before the other side does.  
Color Spawn lets players inject new material into the board on a recharging timer. The match is decided by score when the timer ends.

**Player fantasy:**  
"I'm faster than you. I read the board, route colors cleanly, and steal the best customers before you can finish your drink."

**Core emotion loop:**
- Per pour: board becomes cleaner, closer to a serve
- Per serve: immediate point gain, speed-win over opponent
- Per spawn: new material to work with, fresh decisions
- Per match: continuous pressure, score swings, comeback potential

---

## 2. Design Goals

This version focuses on:

- PvP customer-racing as the core competitive loop
- Pour-sort puzzle as the skill expression layer
- Color Spawn as the material injection system to prevent boards from stalling
- Parallel boards with shared objectives to create interaction without direct interference
- A light meta loop that gives players a reason to keep playing beyond one match
- Wins should feed both competitive progression and future match preparation
- Meta should stay close to the PvP core and avoid heavy collection scaffolding

The match runs on a single board with Color Spawn providing ongoing material. Players sort, fill, and serve drinks while competing for the same customers.

---

## 3. What stays from v6

The following systems stay conceptually the same:

- Shared customer queue in the center
- Both players race to serve the same customers
- Pure full glasses are serveable
- Serve value based on layers
- First serve gets a speed bonus
- Second serve inside the grace window gets reduced value
- Customers can time out and punish both players
- Trophies, arenas, fake matchmaking, and visible AI opponent remain
- Parallel boards remain (you bottom, opponent top)
- Color Spawn button with recharging charges

---

## 4. What changes from v6

Changed:
- Freeze power-up removed from roster
- Workspace stabilized by starting with **2 empty bottles**
- Prototype power-ups aligned with pour-sort routing:
  - Extra Bottle
  - Flash Pour
  - Swap
  - Clear Bottle
- Power-ups changed from random in-match bubble spawns to **pre-match loadout selection**
- The player now has a **persistent power-up inventory** between matches
- Each selected power-up has **1 use per match**
- A new **loadout screen** is added before the countdown
- Match results now award **power-up rewards**
- A new **weekly star track** is added as a second progression layer
- The game now has a **light meta loop without collection systems**

---

## 5. Match Layout

Portrait layout:

```
+--------------------------------------+
|  YOU 750      0:27    900 [av] Name  |
+--------------------------------------+
|          Opponent board (flex)       |
|       small glasses + PU dots        |
+--------------------------------------+
|           Customer zone              |
|   3 shared customers + patience      |
+--------------------------------------+
|      Power-up loadout (2 slots)      |
+--------------------------------------+
|          Player board (flex)         |
|       full-size glasses              |
|  [Spawn]                    [Undo]   |
+--------------------------------------+
```

### Zones
| Zone | Content |
|---|---|
| Score bar | Your score left, timer center, opponent avatar + name + score right |
| Opponent board | AI glasses (flex), power-up dots (filled = unused, empty = spent) |
| Customer zone | 3 active customers, patience bars — **no floating power-up bubbles** |
| Power-up loadout | 2 pre-selected power-up slots (tap to activate, grey out after use) |
| Player board | Your interactive glasses, Spawn button, Undo button |

---

## 6. Core Match Structure

### 6.1 Match Duration
Prototype default:
- **90 seconds**

---

### 6.2 Single board with Color Spawn

A single match runs on one board. Color Spawn provides ongoing material injection to keep the board active.

#### Match loop
1. A board is generated for both players (identical).
2. Both players sort and serve customers from that board.
3. Served glasses become empty workspace.
4. Color Spawn injects new layers into random non-full glasses on a recharge timer.
5. Match continues until the main timer ends.

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
- it is **full** (exactly 4 layers / GLASS_CAPACITY)
- all layers are the **same color** (pure)
- its color matches at least one visible customer

#### Serve value
- **4 layers x 50 = 200 base points** (only full pure glasses can be served)

#### First-serve bonus
- First player to serve that customer: **+50**

#### Grace window
- Second player can still serve the same customer within **2 seconds**
- Gets **50% of base points**
- Gets **no speed bonus**

#### Serve result
- Served glass becomes empty
- It stays on board as workspace

---

### 6.5 Combo bonus

- If you serve again within **10 seconds** of your previous serve:
  - gain **+50 x combo count** bonus (escalating)
  - combo count increments with each consecutive serve within the window
- Combo resets if more than 10 seconds pass without a serve

Example: 1st serve in window = +50, 2nd = +100, 3rd = +150, etc.

---

## 7. Board Rules

### 7.1 Basic pour rules

Classic water-sort rules:

- Each bottle capacity = **4 layers**
- A pour is legal if:
  - source has at least 1 layer
  - destination is empty, or destination top color matches source top color
  - destination has room for at least 1 layer
- Full contiguous top segment transfers (up to available space)
- Illegal pour = shake, no state change
- Undo remains available and free in prototype

---

### 7.2 Starting workspace rule

Each board must start with:
- **source glasses filled** with shuffled color layers
- **2 empty bottles**

#### Prototype examples
- 4 colors, 3 full + 2 empty = 5 bottles (Juice Stand)
- 6 colors, 4 full + 2 empty = 6 bottles (Beach Bar)
- 8 colors, 5 full + 2 empty = 7 bottles (Cocktail Lounge)
- 8 colors, 6-8 full + 2 empty = 8-10 bottles (Speakeasy+)

This keeps the board readable and avoids early hard-locks.

---

### 7.3 Board generation

Both players receive the **same board**.

#### Generation algorithm (shuffle-deal)
1. Determine active color count from arena
2. Create a pool of colored layers: GLASS_CAPACITY layers per source glass, evenly distributed among colors
3. Fisher-Yates shuffle the pool using seeded RNG
4. Deal shuffled layers into source glasses (GLASS_CAPACITY each)
5. Add 2 empty glasses as workspace
6. Reject boards where any glass starts pure (all same color = too easy to serve immediately)
7. Retry with different seed offset if rejected (up to 50 attempts)
8. Use the same seed for player and AI to produce identical boards

#### Design goal
The board should feel like a scrambled pour-sort puzzle:
- readable
- solveable
- not trivial
- not instantly serveable

---

### 7.4 Color Spawn

Color Spawn is the material injection system that keeps the board active throughout the match.

#### Player spawn
- Tap the spawn button (bottom-left) to inject a color layer into a random non-full glass
- **Starting charges:** 5
- **Recharge time:** 1 second per charge
- **Max charges:** 12

#### Spawn color selection
- **60% chance:** pick a color matching an active customer (customer-weighted)
- **40% chance:** pick a random color from the arena's active color pool

#### AI spawn
- AI uses the same spawn mechanic with same color weighting
- AI spawns strategically: when charges are full, board is low on material, or randomly (30% chance per tick)

---

### 7.5 Customer-board relationship

Customers should feel related to the current board state.

#### Rule
Color Spawn biases toward customer colors (60% customer-weighted), keeping the board and queue aligned.

Customer generation biases toward colors abundant on both boards (weighted by layer count), ensuring customers request colors players are actively working with. Customers are generated infinitely — when the initial queue (10) runs out, new customers are spawned on the fly based on current board state.

---

## 8. Power-Ups (Prototype)

The prototype keeps 4 power-ups, all aligned with pour-sort routing and workspace.

#### 8.1 Loadout

- Before each match, the player selects **2 power-ups** from their inventory
- Each selected power-up has **1 use** during that match
- Tap the slot to activate the power-up
- After use, the slot becomes empty / greyed out
- If a selected power-up is **not used**, it returns to inventory after the match
- If the player owns fewer than 2 power-ups, empty slots are allowed

#### 8.1.1 Starter inventory

On first launch, the player receives:

| Power-up | Starting quantity |
|---|---|
| Extra Bottle | 5 |
| Flash Pour | 5 |
| Swap | 3 |
| Clear Bottle | 3 |

#### 8.1.2 Match rewards

| Result | Reward |
|---|---|
| Win | 2 random power-ups from the arena's unlocked roster |
| Lose | 1 random power-up from the arena's unlocked roster |
| Draw | 1 random power-up from the arena's unlocked roster |

Reward weights:

| Power-up | Weight |
|---|---|
| Extra Bottle | 30% |
| Flash Pour | 30% |
| Swap | 25% |
| Clear Bottle | 15% |

Design note:
- Keep **Clear Bottle** slightly rarer because it is the strongest rescue tool

---

#### 8.2 Power-up roster

#### Extra Bottle +
- Adds one empty bottle permanently for the rest of the match
- **1 use**
- Activates immediately on tap
- Purpose: workspace expansion / safe opener

#### Flash Pour (lightning)
- Your **next 3 pours are instant**
- **1 use**
- Activates immediately on tap
- Show remaining fast pours on the slot UI
- Purpose: tempo conversion / serve race spike

#### Swap (arrows)
- Select any 2 of your bottles
- Their entire contents swap instantly
- **1 use**
- Tap slot, then tap 2 bottles
- Purpose: tactical conversion / route rescue

#### Clear Bottle (sponge)
- Select 1 bottle
- All contents are discarded and the bottle becomes empty
- **1 use**
- Tap slot, then tap 1 bottle
- Purpose: emergency anti-deadlock / panic reset

---

#### 8.3 Power-up availability by arena

Power-ups unlock through arena progression.
Players can only select from power-ups already unlocked.

| Arena | Available power-ups |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Flash Pour |
| Beach Bar (200-499) | + Swap |
| Cocktail Lounge (500+) | + Clear Bottle |

Once unlocked, a power-up stays available in all later arenas.

---

#### 8.4 Power-up design rule

Power-ups should not replace the puzzle.
They should only do one of three jobs:
- tempo spike
- board rescue
- workspace expansion

A power-up should help the player convert a route, save a bad board, or open more workspace.
It should not solve the board automatically.

---

## 9. AI Opponent

The prototype still uses AI instead of real multiplayer.

### 9.1 AI board
- Opponent board is visible
- It shows actual AI bottle contents
- Player can read what AI is working on
- Opponent power-up inventory shown as dots (filled/empty)

### 9.2 AI undo ("back")
- AI has **3 undos per match**
- When AI makes a mistake pour (~50% chance it notices), it waits 400-800ms then reverts the board to pre-mistake state
- While an undo is pending, AI skips pour ticks
- Undos are not replenished between boards

### 9.3 AI logic
Every AI tick:
1. Read visible customers
2. Evaluate legal pours
3. Prefer moves that:
   - create a serveable full pure glass matching a customer (+5)
   - create a pure glass matching a customer (+3)
   - increase stack height toward a customer color (+2)
   - consolidate same colors (+1)
   - free up workspace by emptying a glass (+1)
4. Penalize moves that:
   - fill the last empty glass (-2)
   - break existing same-color stacks (-1)
   - target non-customer colors (-0.5)
5. Occasionally make a random legal move based on arena mistake rate
6. Serve after a reaction delay based on arena difficulty

#### 9.4 AI loadout and usage

- AI pre-selects **2 power-ups** at match start from the arena's unlocked roster
- Selection is shown as dots in the opponent board zone
- Filled dot = unused, empty dot = spent

AI usage rules:

| Power-up | AI usage condition |
|---|---|
| Extra Bottle | Use within first 15 seconds if workspace is tight |
| Flash Pour | Use when AI can reach a serve within the next 2 pours |
| Swap | Use when board is blocked but a swap creates a near-serve route |
| Clear Bottle | Use when board has 0 empty bottles and no clean route |

- AI usage delay: 2-4 seconds after condition is met
- AI does not collect power-ups mid-match
- Remove all bubble-grab logic from AI behavior

---

## 10. Scoring

### Point sources
| Event | Points |
|---|---|
| Serve full drink (4 layers) | 200 |
| First-to-serve bonus | +50 |
| Combo bonus (per streak) | +50 x combo count |
| Customer timeout | -25 to both |

---

## 11. Arenas

Arena progression scales the boards and AI difficulty.

### 11.1 Arena scaling knobs
Arenas can scale:
- number of colors
- number of bottles
- power-up roster
- AI skill (pour speed, mistake rate, serve delay, power-up grab chance)
- customer patience tuning

### 11.2 Prototype arenas
| Arena | Trophies | Colors | Bottles | Power-ups |
|---|---|---|---|---|
| Juice Stand | 0-199 | 3 | 3 full + 2 empty (5) | Extra Bottle, Flash Pour |
| Beach Bar | 200-499 | 5 | 4 full + 3 empty (7) | + Swap |
| Cocktail Lounge | 500-999 | 7 | 5 full + 3 empty (8) | + Clear Bottle |
| Speakeasy | 1000-1499 | 7 | 6 full + 4 empty (10) | All 4 |
| Rooftop Terrace | 1500-2499 | 7 | 7 full + 5 empty (12) | All 4 |
| Grand Hotel | 2500+ | 7 | 8 full + 5 empty (13) | All 4 |

### 11.3 AI difficulty per arena
| Arena | Pour interval | Mistake rate | Serve delay | Power-up grab |
|---|---|---|---|---|
| Juice Stand | 0.35-0.6s | 3% | 0.15s | 80% |
| Beach Bar | 0.3-0.5s | 2% | 0.12s | 85% |
| Cocktail Lounge | 0.25-0.45s | 1.5% | 0.1s | 88% |
| Speakeasy | 0.2-0.4s | 1% | 0.08s | 90% |
| Rooftop Terrace | 0.18-0.3s | 0.5% | 0.06s | 93% |
| Grand Hotel | 0.15-0.25s | 0.3% | 0.05s | 95% |

### 11.4 Trophy system
- Win: +25 base, +5 per 100 point margin, cap 40
- Lose: -15 base, -3 per 150 point margin, cap -25
- Draw: +5
- Arena floor: trophies cannot drop below the minimum of the highest arena reached

---

## 12. Match Flow

#### 12.1 Flow

HOME -> MATCHMAKING -> LOADOUT -> COUNTDOWN -> MATCH -> RESULT

### 12.2 Matchmaking
- Fake search with cycling opponent avatars/names (15-22 cycles, decelerating)
- Opponent generated within +/-100 trophies, clamped to arena range
- "Opponent found!" reveal with START button

#### 12.3 Loadout screen

After the opponent is found, show a simple loadout panel:

```
+--------------------------------------+
|         CHOOSE YOUR POWER-UPS        |
+--------------------------------------+
|                                      |
|  [slot 1: ___]     [slot 2: ___]     |
|                                      |
+--------------------------------------+
| Extra Bottle (x3)  Flash Pour (x4)   |
| Swap (x2)          Clear Bottle (x1) |
+--------------------------------------+
|             [ READY ]                |
+--------------------------------------+
```

Rules:
- Tap a power-up in inventory to assign it to a slot
- Tap a filled slot to remove it
- Player may leave slots empty
- READY starts the countdown
- Auto-ready timer: 10 seconds
- If timer expires, the match starts with the current selection

### 12.4 Countdown
- 3... 2... 1... MIX!
- Board visible during countdown but not interactive

---

## 13. Home / Result

### Home
- Arena badge (emoji + name)
- Trophy count with progress bar to next arena
- Stats (matches, win rate, best score, drinks served)
- PLAY button
- Reset button (bottom-right, subtle white square at 10% opacity) — confirms via popup, wipes all progress (trophies, stats, arena floor)
- Weekly progress widget (stars + next milestone)
- Power-up inventory button / summary

### Result
- Win / Lose / Draw
- Score comparison
- Trophy change (+/- with color)
- Trophy transition (old -> new)
- Arena progress bar
- Match stats (drinks served, best combo, arena)
- Play Again / Home
- Arena unlock overlay if promoted (shows new features)
- Power-up rewards panel
- Weekly stars gained this match
- Current weekly track progress

Example reward block:

```
+--------------------------------------+
|              REWARDS                 |
|   [Flash Pour]   [Extra Bottle]      |
|        +1 per reward roll            |
+--------------------------------------+
|           WEEKLY PROGRESS            |
|            Stars: +3                 |
|        14 / 20 to next reward        |
+--------------------------------------+
```

---

## Weekly Track

The weekly track is the second progression axis beyond trophies.
It exists to give the player a reason to keep playing even when ladder gain is slow.

### Weekly stars

| Match result | Stars |
|---|---|
| Win | 3 |
| Draw | 2 |
| Lose | 1 |

### Rules
- Every completed match grants stars
- Weekly stars fill a simple milestone track
- The weekly track resets once per week
- Rewards are claimable immediately when a milestone is reached

### Weekly reward types
- power-up bundles
- small soft-currency rewards (optional later)
- lightweight cosmetic rewards (optional later)

### Prototype recommendation
For prototype scope, reward only:
- power-up bundles
- one larger final weekly reward

### Example prototype track
- 5 stars -> 1 random power-up
- 12 stars -> 2 random power-ups
- 20 stars -> 3 random power-ups
- 30 stars -> 1 guaranteed rare-weight roll

Design rule:
- The weekly track should support the core loop, not overshadow it
- It is a retention support layer, not the main game

---

## 14. Prototype Scope (v6.1)

### 14.1 What to build
Required:
- Parallel player + AI boards
- Shared customers
- Full pure-glass serving
- Layer-based scoring
- Speed bonus
- Combo bonus (escalating)
- Color Spawn system
- AI opponent with arena-scaled difficulty
- 4 prototype power-ups
- Home
- Matchmaking with fake opponent search
- Result with trophy change
- Trophy progression
- Arenas with unlock overlay
- Visible opponent board with power-up dots
- Pre-match loadout screen (2 slots)
- Persistent power-up inventory
- Post-match power-up rewards
- Weekly star track
- Weekly progress UI on Home and Result

Not required:
- Real multiplayer
- Sound
- Collection system
- Sticker album
- Recipe book / set completion
- Village / bar renovation meta
- Chest timers
- Shop
- Battle pass

---

### 14.2 Smallest viable prototype
If time is tight, build this subset first:

- 1 arena only
- 3 colors
- 3 full + 2 empty bottles
- 3 shared customers
- Serve + scoring
- AI opponent
- Color Spawn
- 2 power-ups in loadout system:
  - Flash Pour
  - Swap
- Starter inventory for those 2 power-ups
- Win/Lose power-up rewards
- Weekly stars only (no full weekly reward UI required in first slice)

Design note:
- This is the smallest slice that tests both the PvP core and the reason to keep playing

---

## 15. Open Questions for Playtesting

1. Is **90 seconds** the right match length, or is 75 better?
2. Is the **1-second spawn recharge** too fast or too slow?
3. Are **2 empty bottles** enough in late arenas?
4. Does **Clear Bottle** feel fair or too strong?
5. Is the **60% customer-weighted** spawn color bias the right ratio?
6. Should combo bonus cap at some maximum multiplier?
7. Is the visible opponent board readable enough, or should the opponent status be simplified?
8. Does pre-match loadout selection make the match feel more strategic?
9. Does the player understand why winning matters beyond trophies?
10. Is the win reward rate high enough to keep loadout choice interesting?
11. Does Flash Pour feel better as "next 3 pours are instant" than as a timed buff?
12. Does the weekly track create healthy motivation, or does it feel like noise?
13. Is BAR CLASH already sticky enough with ladder + loadout + weekly track, without collection?

---

## 16. Success Criteria

1. Continuous play with no dead downtime
2. No common hard-locks from lack of workspace
3. Shared customers remain the emotional center of the match
4. Matches feel closer to a competitive race, not two isolated solitaire boards
5. Power-ups add tactical choice without replacing the core puzzle
6. Color Spawn keeps the board fed without feeling like a waiting game

---

## 17. Build Priority

1. Board generation + pouring
2. Serve logic + customers + scoring
3. Color Spawn system
4. AI opponent
5. Result flow + trophies
6. Power-ups
7. Arena scaling
8. Polish

Cut polish first, not board readability or pacing.
