# MIX IT v6.5 — BAR CLASH

**Date:** 2026-04-17  
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
- Freeze booster removed from roster
- Workspace stabilized by starting with **2 empty bottles**
- Power-ups are now consistently referred to as **Boosters**
- Boosters are selected before the match from a persistent inventory (2 fixed slots)
- Gold is earned from match completions and match results
- Direct post-match booster drops are removed from normal match rewards
- New **Venue Progression** system added as the primary gold sink
- Home shows the current venue visually only
- New **Venue** tab added in the bottom menu for upgrades and reward claims
- Boosters are granted mainly through venue milestones and arena promotions

---

## 5. Match Layout

### Home top bar

```
HOME TOP BAR:
[Trophies]   [Gold]   [Arena]
```

### In-match layout

No gold is shown in the active match HUD.
Gold and venue progression are **meta-layer systems** and should not clutter the match HUD.

Portrait layout:

```
+--------------------------------------+
|  YOU 750      0:27    900 [av] Name  |
+--------------------------------------+
|          Opponent board (flex)       |
|     small glasses + booster dots     |
+--------------------------------------+
|           Customer zone              |
|   3 shared customers + patience      |
+--------------------------------------+
|      Booster loadout (2 slots)       |
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
| Opponent board | AI glasses (flex), booster dots (filled = unused, empty = spent) |
| Customer zone | 3 active customers, patience bars — **no floating booster bubbles** |
| Booster loadout | 2 pre-selected booster slots (tap to activate, grey out after use) |
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

## 8. Boosters

### 8.0 Booster economy philosophy

Boosters remain:
- tactical
- pre-selected
- 1-use per match if activated
- consumable

But the economy changes:
- boosters are **not** granted after every normal match
- boosters are granted mainly through venue milestones
- unused equipped boosters return to inventory after the match
- used boosters leave inventory and must be replenished

They should help the player convert skill into tempo, rescue, or workspace.

They should **not**:
- become permanent stat upgrades
- create power creep
- replace the core puzzle

This makes boosters feel more deliberate and lets the game control supply more tightly.

---

### 8.1 Loadout

- Before each match, the player selects up to **2 boosters** from inventory
- The player always has exactly **2 loadout slots**
- Each selected booster has **1 use** during the match
- A booster is consumed only if activated
- If a selected booster is not used, it returns to inventory after the match
- Empty slots are allowed

#### Design note
The loadout layer stays tactical and Match Masters-like, but booster acquisition is no longer tied to every result screen.

#### 8.1.1 Starter inventory

On first launch, the player receives:

| Booster | Starting quantity |
|---|---:|
| Extra Bottle | 2 |
| Flash Pour | 2 |
| Swap | 0 |
| Clear Bottle | 0 |

Additional first-launch grant:
- **50 Gold**

#### Why
The player should:
- understand boosters immediately
- have enough supply for the first few matches
- see the first venue rewards matter quickly
- not start with such a huge stock that venue rewards feel irrelevant

---

### 8.2 Booster roster

Keep the same four booster effects, defined as consumable inventory items.

#### Extra Bottle
- Adds one empty bottle permanently for the rest of the match
- 1 use
- Role: workspace / setup

#### Flash Pour
- Your next **3 pours** are instant
- 1 use
- Role: tempo spike / serve conversion

#### Swap
- Select any 2 bottles; their full contents swap
- 1 use
- Role: tactical rescue / route conversion

#### Clear Bottle
- Select 1 bottle; discard all contents and make it empty
- 1 use
- Role: emergency anti-deadlock

#### Design note
Flash Pour is changed from an 8-second timer to **next 3 pours are instant** because that is clearer in a puzzle-routing game and easier to value economically.

---

### 8.3 Booster unlocks by arena

| Arena | Unlocked boosters |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Flash Pour |
| Beach Bar (200-499) | + Swap |
| Cocktail Lounge (500-999) | + Clear Bottle |
| Speakeasy+ | no new booster unlocks |

#### Rule
Once a booster is unlocked, it stays available permanently for:
- pre-match loadout selection
- venue milestone reward tables
- Utility Cart emergency purchases

---

### 8.4 Booster reward sources

Normal match results do **not** grant random boosters.

Main booster sources are:
1. Starter inventory
2. Building completion rewards (5/5)
3. Full venue completion rewards
4. Arena promotion rewards
5. Utility Cart emergency purchases

#### Design goal
Boosters should feel earned and paced, not sprayed after every match.

---

### 8.5 Utility Cart

Inside the Venue tab, the player has access to a small **Utility Cart**.

It is a safety valve, not the main progression loop.

#### Purpose
The Utility Cart exists so players are never fully blocked if they run low on boosters between milestone rewards.

#### Purchase prices
| Booster | Utility Cart price |
|---|---:|
| Extra Bottle | 60 |
| Flash Pour | 70 |
| Swap | 95 |
| Clear Bottle | 120 |

#### Rules
- Only unlocked boosters can be purchased
- No bundles in MVP
- No random chest behavior
- No discount rotation required in MVP
- The cart sits below the building reward UI in the Venue tab

#### Design note
These prices are intentionally much worse value than milestone rewards. The Venue system should remain the primary booster source.

---

## 9. AI Opponent

The prototype still uses AI instead of real multiplayer.

AI does not participate in the gold economy. AI does not buy boosters in a visible way. AI inventory is simulated and not part of the player's economy model.

### 9.1 AI board
- Opponent board is visible
- It shows actual AI bottle contents
- Player can read what AI is working on
- Opponent booster inventory shown as dots (filled/empty)

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

- AI pre-selects **2 boosters** at match start from the arena's unlocked roster
- Selection is shown as dots in the opponent board zone
- Filled dot = unused, empty dot = spent

AI usage rules:

| Booster | AI usage condition |
|---|---|
| Extra Bottle | Use within first 15 seconds if workspace is tight |
| Flash Pour | Use when AI can reach a serve within the next 2 pours |
| Swap | Use when board is blocked but a swap creates a near-serve route |
| Clear Bottle | Use when board has 0 empty bottles and no clean route |

- AI usage delay: 2-4 seconds after condition is met
- AI does not collect boosters mid-match
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

## 11. Arenas + Venues

### 11.0 Arena progression purpose

Arenas now do four things:
1. Scale board depth and AI difficulty
2. Unlock boosters
3. Change the venue theme shown on Home and Venue screens
4. Open a new set of venue upgrades and milestone rewards

The player should feel:

**New arena = new tactical layer + new visual place + new gold sink + new milestone rewards**

---

### 11.1 Venue theme mapping

| Arena | Venue theme |
|---|---|
| Juice Stand | juice kiosk / stand |
| Beach Bar | beach bar |
| Cocktail Lounge | lounge interior |
| Speakeasy | hidden bar |
| Rooftop Terrace | rooftop venue |
| Grand Hotel | luxury hotel bar |

#### Rule
Home always shows the player's **current active venue theme** visually, matching the highest unlocked arena.

---

### 11.2 Venue structure

Each venue contains **5 upgradeable buildings / venue modules**.

Recommended generic structure:
1. Main Counter
2. Seating Area
3. Signage / Entrance
4. Decor / Lighting
5. Service Station / Shelf

Each building has **5 upgrade levels**.

Total venue progress:
- **25 upgrade steps**
- **5 building completion rewards**
- **1 full venue completion reward**

#### UI rule
The building art and labels change per arena theme, but the underlying structure stays the same for production simplicity.

---

### 11.3 Venue upgrade costs by arena

Each building in a venue uses the same level costs for that arena.

| Arena | L1 | L2 | L3 | L4 | L5 | Total per building | Total per venue |
|---|---:|---:|---:|---:|---:|---:|---:|
| Juice Stand | 20 | 25 | 30 | 30 | 35 | 140 | 700 |
| Beach Bar | 25 | 30 | 35 | 40 | 50 | 180 | 900 |
| Cocktail Lounge | 30 | 35 | 45 | 60 | 70 | 240 | 1200 |
| Speakeasy | 35 | 45 | 55 | 75 | 90 | 300 | 1500 |
| Rooftop Terrace | 40 | 55 | 70 | 95 | 120 | 380 | 1900 |
| Grand Hotel | 50 | 65 | 85 | 120 | 140 | 460 | 2300 |

#### Design goal
Venue completion should take a meaningful number of matches, but not feel like a months-long project.

---

### 11.4 Venue milestone rewards

#### Building completion rewards (5/5)
Completing a building grants a **2-booster reward bundle** based on the currently unlocked roster.

Example reward rules:
- Juice Stand: `1 Extra Bottle + 1 Flash Pour`
- Beach Bar: `1 common booster + 1 Swap`
- Cocktail Lounge+: `1 common booster + 1 higher-tier roll from unlocked roster`

#### Full venue completion rewards
Completing all 5 buildings grants a larger reward:

| Arena | Full venue reward |
|---|---|
| Juice Stand | 3 boosters |
| Beach Bar | 3 boosters + 25 Gold |
| Cocktail Lounge | 4 boosters + 40 Gold |
| Speakeasy | 4 boosters + 60 Gold |
| Rooftop Terrace | 5 boosters + 75 Gold |
| Grand Hotel | 5 boosters + 100 Gold |

#### Arena promotion reward
Reaching a new arena also grants a one-time promotion reward:

| Arena reached | Promotion reward |
|---|---|
| Beach Bar | Swap x1 + 30 Gold |
| Cocktail Lounge | Clear Bottle x1 + 40 Gold |
| Speakeasy | 60 Gold |
| Rooftop Terrace | 80 Gold |
| Grand Hotel | 100 Gold |

#### Design goal
The player should celebrate three separate beats:
- finishing a building
- finishing a venue
- unlocking the next arena

---

### 11.5 Prototype arenas

| Arena | Trophies | Colors | Bottles | Booster unlock | Win Gold | Lose Gold | Draw Gold | Venue total cost |
|---|---:|---:|---|---|---:|---:|---:|---:|
| Juice Stand | 0-199 | 3 | 3 full + 2 empty (5) | Extra Bottle, Flash Pour | 35 | 20 | 25 | 700 |
| Beach Bar | 200-499 | 5 | 4 full + 3 empty (7) | + Swap | 40 | 22 | 30 | 900 |
| Cocktail Lounge | 500-999 | 7 | 5 full + 3 empty (8) | + Clear Bottle | 50 | 25 | 35 | 1200 |
| Speakeasy | 1000-1499 | 7 | 6 full + 4 empty (10) | no new booster | 60 | 30 | 40 | 1500 |
| Rooftop Terrace | 1500-2499 | 7 | 7 full + 5 empty (12) | no new booster | 70 | 35 | 45 | 1900 |
| Grand Hotel | 2500+ | 7 | 8 full + 5 empty (13) | no new booster | 80 | 40 | 50 | 2300 |

#### Design note
Early arenas unlock the full tactical roster.
Later arenas stop adding more buttons and instead increase:
- board depth
- match value
- purchasing power
- status

### 11.6 Arena scaling knobs
Arenas can scale:
- number of colors
- number of bottles
- booster roster
- AI skill (pour speed, mistake rate, serve delay, booster grab chance)
- customer patience tuning

### 11.7 AI difficulty per arena
| Arena | Pour interval | Mistake rate | Serve delay | Booster grab |
|---|---|---|---|---|
| Juice Stand | 0.35-0.6s | 3% | 0.15s | 80% |
| Beach Bar | 0.3-0.5s | 2% | 0.12s | 85% |
| Cocktail Lounge | 0.25-0.45s | 1.5% | 0.1s | 88% |
| Speakeasy | 0.2-0.4s | 1% | 0.08s | 90% |
| Rooftop Terrace | 0.18-0.3s | 0.5% | 0.06s | 93% |
| Grand Hotel | 0.15-0.25s | 0.3% | 0.05s | 95% |

### 11.8 Trophy system
- Win: +25 base, +5 per 100 point margin, cap 40
- Lose: -15 base, -3 per 150 point margin, cap -25
- Draw: +5
- Arena floor: trophies cannot drop below the minimum of the highest arena reached

---

## 12. Match Flow

#### 12.1 Flow

HOME -> MATCHMAKING -> PRE-MATCH LOADOUT -> COUNTDOWN -> MATCH -> RESULT -> REWARD CLAIM -> HOME / VENUE

### 12.2 Matchmaking
- Fake search with cycling opponent avatars/names (15-22 cycles, decelerating)
- Opponent generated within +/-100 trophies, clamped to arena range
- "Opponent found!" reveal with START button

#### 12.3 Loadout screen

After the opponent is found, show a simple loadout panel:

```
+--------------------------------------+
|         CHOOSE YOUR BOOSTERS         |
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
- Tap a booster in inventory to assign it to a slot
- Tap a filled slot to remove it
- Player may leave slots empty
- READY starts the countdown
- Auto-ready timer: 10 seconds
- If timer expires, the match starts with the current selection

### 12.4 Countdown
- 3... 2... 1... MIX!
- Board visible during countdown but not interactive

### 12.5 Reward Claim

After the result screen, the player sees:
- win / lose / draw
- trophy delta
- gold earned
- arena promotion reward (if any)
- venue progress increment callout

Example:

```
REWARDS
+30 Trophies
+40 Gold
VENUE PROGRESS
Beach Bar - Main Counter can now be upgraded
```

#### Rule
Do **not** show booster rewards on a normal result screen unless the match also caused:
- a building completion
- a full venue completion
- an arena promotion

This keeps the result screen cleaner.

### 12.6 Post-match navigation

After reward claim, the player may:
- tap **Play Again**
- tap **Go to Venue**
- tap **Home**

---

## 13. Home / Venue / Result

### 13.0 Bottom navigation

Bottom menu has **2 primary tabs** in MVP:
- **Home**
- **Venue**

Optional later tabs can be added, but are not required now.

---

### 13.1 Home

Home becomes the fast-entry PvP screen.

It should show:
- Arena badge (emoji + name)
- Trophy count with progress bar to next arena
- Gold balance
- Stats (matches, win rate, best score, drinks served)
- PLAY button
- Current venue visual preview
- Small CTA: `Go to Venue`
- Reset button (bottom-right, subtle white square at 10% opacity) — confirms via popup, wipes all progress (trophies, stats, arena floor)
- Booster inventory summary

Economy panel example:

```
Gold: 185
Boosters:
Extra Bottle x2
Flash Pour x1
Swap x0
Clear Bottle x0
```

Next arena teaser:

```
NEXT ARENA: Beach Bar
Unlocks: Swap
Promotion Reward: Swap x1 + 30 Gold
```

#### Important rule
The venue shown on Home is **visual only**.

On Home, the player cannot:
- tap buildings to upgrade
- claim building rewards
- open upgrade cards

Home is for:
- immediate readability
- status
- match entry

---

### 13.2 Venue tab

The Venue tab is the dedicated progression screen.

It contains:
1. Large current venue artwork
2. Venue progress header: `17 / 25 upgrades complete`
3. Five building cards / buttons
4. Upgrade cost button on the currently selected building
5. Building reward preview: `Reward at 5/5`
6. Full venue reward bar
7. Utility Cart panel at the bottom

#### Building card content
Each building card shows:
- building name
- current level (`3/5`)
- next upgrade cost in gold
- final completion reward preview

#### Upgrade interaction
Selecting a building opens the building panel:
- current level
- next level visual preview
- next cost
- final reward at `5/5`
- primary button: `UPGRADE - 40 GOLD`

#### Reward claim behavior
- Building completion rewards are claimed immediately on upgrade to `5/5`
- Full venue completion reward is claimed immediately when the 25th upgrade is purchased

---

### 13.3 Result

- Score comparison
- Trophy delta (+/- with color)
- Trophy transition (old -> new)
- Gold earned
- Arena progress bar
- Match stats (drinks served, best combo, arena)
- Play Again / Home
- Arena unlock overlay if promoted (shows new features)
- Optional milestone reward reveal only if triggered

Example result variants:

#### Normal match
```
+35 Trophies
+50 Gold
```

#### Match that finishes a building
```
+35 Trophies
+50 Gold
BUILDING COMPLETE!
Reward: Flash Pour x1 + Swap x1
```

#### Match that finishes a venue
```
+35 Trophies
+50 Gold
VENUE COMPLETE!
Reward: Clear Bottle x2 + Flash Pour x2 + 40 Gold
```

Do **not** show:
- random booster drops from the result itself

---

## 14. Prototype Scope (v6.5)

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
- 4 prototype boosters
- Home
- Matchmaking with fake opponent search
- Result with trophy change
- Trophy progression
- Arenas with unlock overlay
- Visible opponent board with booster dots
- Pre-match loadout screen (2 slots)
- Persistent booster inventory
- Gold soft currency
- Venue tab in bottom navigation
- Home venue visual preview
- 5-building venue upgrade screen
- Building completion rewards
- Full venue completion rewards
- Arena promotion rewards
- Utility Cart emergency booster purchases
- Arena-based gold rewards after each match
- Reward claim step after match
- Home screen gold display

Not required:
- Real multiplayer
- Sound
- Collection system
- Shop as a standalone main tab
- Chest timers
- Sticker album
- Battle pass
- Booster mastery
- Weekly stars
- Direct booster rewards after every match
- Recipe book / set completion
- Village / bar renovation meta (separate from venue system)

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
- 2 boosters in loadout system:
  - Flash Pour
  - Swap
- Starter inventory for those 2 boosters
- Gold rewards for win/lose/draw
- Venue tab with at least 1 building upgradeable

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
8. Does the Venue tab make gold feel more meaningful than a plain shop?
9. Does showing the venue only visually on Home keep the main screen clean enough?
10. Do building completion rewards arrive often enough to keep boosters feeling alive?
11. Is the Utility Cart expensive enough to remain a safety valve rather than the main booster source?
12. Does venue completion feel exciting, or too far away in later arenas?
13. Do players understand the difference between trophies (climb) and gold (venue progress)?

---

## 16. Success Criteria

1. Continuous play with no dead downtime
2. No common hard-locks from lack of workspace
3. Shared customers remain the emotional center of the match
4. Matches feel closer to a competitive race, not two isolated solitaire boards
5. Boosters add tactical choice without replacing the core puzzle
6. Color Spawn keeps the board fed without feeling like a waiting game

---

## 17. Build Priority

1. Board generation + pouring
2. Serve logic + customers + scoring
3. Color Spawn system
4. AI opponent
5. Result flow + trophies
6. Boosters
7. Arena scaling
8. Venue progression
9. Polish

Cut polish first, not board readability or pacing.

---

## Economy Math

This section is the balancing backbone for the venue-based economy.

### 1. Gold income by match result

Assume a long-term average player profile:
- 50% win rate
- 10% draw rate
- 40% loss rate

Expected gold per match:

| Arena | Expected gold / match |
|---|---:|
| Juice Stand | 29.5 |
| Beach Bar | 31.8 |
| Cocktail Lounge | 38.5 |
| Speakeasy | 46.0 |
| Rooftop Terrace | 52.5 |
| Grand Hotel | 60.0 |

Example formula for Beach Bar:

```
0.5 x 40 + 0.1 x 30 + 0.4 x 22
= 20 + 3 + 8.8
= 31.8 expected gold per match
```

---

### 2. Expected matches to finish a venue

| Arena | Venue cost | Expected gold / match | Expected matches to finish venue |
|---|---:|---:|---:|
| Juice Stand | 700 | 29.5 | 23.7 |
| Beach Bar | 900 | 31.8 | 28.3 |
| Cocktail Lounge | 1200 | 38.5 | 31.2 |
| Speakeasy | 1500 | 46.0 | 32.6 |
| Rooftop Terrace | 1900 | 52.5 | 36.2 |
| Grand Hotel | 2300 | 60.0 | 38.3 |

#### Interpretation
- Early venues complete fairly quickly
- Mid venues become a medium-term goal
- Late venues stay meaningful without becoming endless

---

### 3. Booster reward supply per venue

Booster supply from venue milestones:

| Arena | Building rewards | Full venue reward | Total boosters per venue |
|---|---:|---:|---:|
| Juice Stand | 5 buildings x 2 = 10 | 3 | 13 |
| Beach Bar | 5 buildings x 2 = 10 | 3 | 13 |
| Cocktail Lounge | 5 buildings x 2 = 10 | 4 | 14 |
| Speakeasy | 5 buildings x 2 = 10 | 4 | 14 |
| Rooftop Terrace | 5 buildings x 2 = 10 | 5 | 15 |
| Grand Hotel | 5 buildings x 2 = 10 | 5 | 15 |

Booster supply per expected match:

| Arena | Boosters per venue | Expected matches | Booster supply / match |
|---|---:|---:|---:|
| Juice Stand | 13 | 23.7 | 0.55 |
| Beach Bar | 13 | 28.3 | 0.46 |
| Cocktail Lounge | 14 | 31.2 | 0.45 |
| Speakeasy | 14 | 32.6 | 0.43 |
| Rooftop Terrace | 15 | 36.2 | 0.41 |
| Grand Hotel | 15 | 38.3 | 0.39 |

---

### 4. Booster consumption assumption

Expected actual booster uses per match:

| Arena band | Expected boosters used per match |
|---|---:|
| Juice Stand | 0.30 |
| Beach Bar | 0.35 |
| Cocktail Lounge | 0.40 |
| Speakeasy | 0.45 |
| Rooftop Terrace | 0.50 |
| Grand Hotel | 0.50 |

#### Why
Players equip up to 2 boosters, but many matches use:
- zero boosters in a dominant game
- one booster in a normal game
- two boosters only in high-pressure or comeback moments

Because unused equipped boosters return to inventory, real consumption is much lower than equip count.

---

### 5. Sustainability check

Compare booster supply to expected use:

| Arena | Booster supply / match | Expected use / match | Net |
|---|---:|---:|---:|
| Juice Stand | 0.55 | 0.30 | +0.25 |
| Beach Bar | 0.46 | 0.35 | +0.11 |
| Cocktail Lounge | 0.45 | 0.40 | +0.05 |
| Speakeasy | 0.43 | 0.45 | -0.02 |
| Rooftop Terrace | 0.41 | 0.50 | -0.09 |
| Grand Hotel | 0.39 | 0.50 | -0.11 |

#### Interpretation
- Early and mid game are self-sustaining through venue rewards alone
- Late game is intentionally slightly tighter
- The Utility Cart covers occasional shortages
- Promotion rewards and venue-completion gold bonuses help smooth the curve

This is intentional: boosters should feel available, but not infinite.

---

### 6. Gold pressure and Utility Cart safety valve

Because venue upgrades are the primary gold sink, the Utility Cart must stay expensive.

Example late-game tradeoff:
- buy 1 Clear Bottle for 120 gold now
- or keep that gold toward a venue upgrade

This creates a healthy choice:
- short-term tactical safety
- versus long-term progression

That tension is desirable.

---

### 7. First win of day bonus

To help smooth weaker sessions, add:

| Arena | First win bonus |
|---|---:|
| Juice Stand | 20 |
| Beach Bar | 25 |
| Cocktail Lounge | 30 |
| Speakeasy | 35 |
| Rooftop Terrace | 40 |
| Grand Hotel | 50 |

#### Why
This gives the player a strong reason to come back daily without needing a weekly track or star system.
