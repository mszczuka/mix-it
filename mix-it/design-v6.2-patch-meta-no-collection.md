# PATCH: Match Masters-Like Meta Layer (No Collection)

**Applies to:** `design-v6.md` (MIX IT v6.1 — BAR CLASH)  
**Date:** 2026-04-16  
**Purpose:** Add a light meta layer that gives the player a clear reason to keep playing and winning **without** adding a collection system, village meta, chest timers, or a heavy F2P shell.

This patch keeps BAR CLASH close to the **Match Masters direction** in structure:
- short PvP sessions
- pre-match loadout choice
- wins feeding the next match
- ladder pressure
- an extra weekly progression track

But it is **not** a 1:1 copy of Match Masters.
BAR CLASH keeps its own core identity:
- Water Sort Puzzle + real-time serve race
- shared customers as the emotional center
- Color Spawn as the board-feeding system
- arenas and visible opponent board

---

## Design intent

The goal of this patch is to answer a simple player question:

> **Why should I keep playing after one match, and why should I care about winning?**

The answer should come from **three clear meta pillars**:

1. **Ladder / Arenas**  
   Winning gives trophies, moves the player up, unlocks harder arenas, and expands the power-up roster.

2. **Booster economy + loadout mastery**  
   Winning gives more tools for future matches. The player builds a small inventory, chooses a 2-slot loadout before each match, and learns which setup works best.

3. **Weekly track**  
   Every match also pushes a separate weekly progress bar, so the player is always advancing something even outside pure ladder climb.

This creates the target loop:

**Play -> Win -> Gain trophies + power-ups + weekly progress -> Choose next loadout -> Play again**

---

## What this patch does NOT add

Do **not** add any of the following in this patch:

- sticker album
- recipe collection
- card collection
- village / bar renovation meta
- chests with timers
- shop economy
- battle pass
- deep seasonal collection content

This patch is intentionally **Match Masters-like without collection**.
The meta should stay light, readable, and close to the core PvP.

---

## Product position after this patch

After this patch, BAR CLASH should feel like:

> A competitive PvP puzzle racer where each win matters twice:  
> once for ladder progress, and once for future match preparation.

The player should feel:
- **I climbed**
- **I earned tools**
- **I can make a better choice next match**
- **I also moved my weekly progress forward**

That is enough meta for v1.

---

## Summary of changes

1. Replace random in-match power-up bubble spawning with **pre-match loadout selection**
2. Keep power-ups as **limited-use match tools**, chosen from inventory
3. Add a **persistent power-up inventory** between matches
4. Add **post-match power-up rewards** so wins feed the next match
5. Keep **trophies and arenas** as the main long-term competitive progression
6. Add a **weekly star track** as a second progression axis
7. Explicitly **exclude collection systems** from the design

---

# Section changes

## § 2 — Design Goals

Add the following bullets:

```md
- A light meta loop that gives players a reason to keep playing beyond one match
- Wins should feed both competitive progression and future match preparation
- Meta should stay close to the PvP core and avoid heavy collection scaffolding
```

---

## § 4 — What changes from v6

Replace the current changed list with:

```md
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
```

---

## § 5 — Match Layout

Keep the layout with a dedicated loadout row and no floating power-up bubbles in the customer zone.

Replace the layout diagram with:

```md
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

Update the zones table:

```md
| Zone | Content |
|---|---|
| Score bar | Your score left, timer center, opponent avatar + name + score right |
| Opponent board | AI glasses (flex), power-up dots (filled = unused, empty = spent) |
| Customer zone | 3 active customers, patience bars — **no floating power-up bubbles** |
| Power-up loadout | 2 pre-selected power-up slots (tap to activate, grey out after use) |
| Player board | Your interactive glasses, Spawn button, Undo button |
```

---

## § 8 — Power-Ups (Prototype)

Replace the current power-up section with the following structure.

### 8.1 Loadout

```md
#### 8.1 Loadout

- Before each match, the player selects **2 power-ups** from their inventory
- Each selected power-up has **1 use** during that match
- Tap the slot to activate the power-up
- After use, the slot becomes empty / greyed out
- If a selected power-up is **not used**, it returns to inventory after the match
- If the player owns fewer than 2 power-ups, empty slots are allowed
```

### 8.1.1 Starter inventory

```md
#### 8.1.1 Starter inventory

On first launch, the player receives:

| Power-up | Starting quantity |
|---|---|
| Extra Bottle | 5 |
| Flash Pour | 5 |
| Swap | 3 |
| Clear Bottle | 3 |
```

### 8.1.2 Match rewards

```md
#### 8.1.2 Match rewards

| Result | Reward |
|---|---|
| Win | 2 random power-ups from the arena's unlocked roster |
| Lose | 1 random power-up from the arena's unlocked roster |
| Draw | 1 random power-up from the arena's unlocked roster |
```

Reward weights:

```md
| Power-up | Weight |
|---|---|
| Extra Bottle | 30% |
| Flash Pour | 30% |
| Swap | 25% |
| Clear Bottle | 15% |
```

Design note:
- Keep **Clear Bottle** slightly rarer because it is the strongest rescue tool

### 8.2 Power-up roster

Replace the roster descriptions with:

```md
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
```

### 8.3 Power-up availability by arena

Replace the old spawn subsection with:

```md
#### 8.3 Power-up availability by arena

Power-ups unlock through arena progression.
Players can only select from power-ups already unlocked.

| Arena | Available power-ups |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Flash Pour |
| Beach Bar (200-499) | + Swap |
| Cocktail Lounge (500+) | + Clear Bottle |

Once unlocked, a power-up stays available in all later arenas.
```

### 8.4 Power-up design rule

Add a new subsection:

```md
#### 8.4 Power-up design rule

Power-ups should not replace the puzzle.
They should only do one of three jobs:
- tempo spike
- board rescue
- workspace expansion

A power-up should help the player convert a route, save a bad board, or open more workspace.
It should not solve the board automatically.
```

---

## § 9 — AI Opponent

Replace § 9.4 with:

```md
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
```

---

## § 12 — Match Flow

Replace § 12.1 with:

```md
#### 12.1 Flow

HOME -> MATCHMAKING -> LOADOUT -> COUNTDOWN -> MATCH -> RESULT
```

Add a new loadout subsection:

```md
#### 12.3 Loadout screen

After the opponent is found, show a simple loadout panel:

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

Rules:
- Tap a power-up in inventory to assign it to a slot
- Tap a filled slot to remove it
- Player may leave slots empty
- READY starts the countdown
- Auto-ready timer: 10 seconds
- If timer expires, the match starts with the current selection
```

Renumber the old countdown subsection accordingly.

---

## § 13 — Home / Result

Add the following changes.

### 13.1 Home additions

Add to Home:

```md
- Weekly progress widget (stars + next milestone)
- Power-up inventory button / summary
```

### 13.2 Result additions

Add to Result:

```md
- Power-up rewards panel
- Weekly stars gained this match
- Current weekly track progress
```

Example reward block:

```md
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

## NEW SECTION — Weekly Track

Add a new section after Result or after Arenas.

```md
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
```

Design rule:
- The weekly track should support the core loop, not overshadow it
- It is a retention support layer, not the main game

---

## § 14 — Prototype Scope (v6.1)

Update § 14.1 Required by adding:

```md
- Pre-match loadout screen (2 slots)
- Persistent power-up inventory
- Post-match power-up rewards
- Weekly star track
- Weekly progress UI on Home and Result
```

Update the Not Required list by explicitly adding:

```md
- Collection system
- Sticker album
- Recipe book / set completion
- Village / bar renovation meta
- Chest timers
- Shop
- Battle pass
```

### 14.2 Smallest viable prototype

Replace the smallest viable prototype subsection with:

```md
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
```

Design note:
- This is the smallest slice that tests both the PvP core and the reason to keep playing

---

## § 15 — Open Questions for Playtesting

Add the following questions:

```md
8. Does pre-match loadout selection make the match feel more strategic?
9. Does the player understand why winning matters beyond trophies?
10. Is the win reward rate high enough to keep loadout choice interesting?
11. Does Flash Pour feel better as "next 3 pours are instant" than as a timed buff?
12. Does the weekly track create healthy motivation, or does it feel like noise?
13. Is BAR CLASH already sticky enough with ladder + loadout + weekly track, without collection?
```

---

## Why this patch is the right next step

This patch gives BAR CLASH a stronger reason-to-return loop **without** overbuilding the meta.

After this patch, the player has three reasons to care about the next match:

1. **I want to climb**
2. **I want better tools for the next match**
3. **I want to move my weekly progress forward**

That is enough to make the game feel like more than a pure ladder prototype, but still much lighter and cleaner than a collection-heavy F2P economy.

---

## Implementation order for Claude Code

Use this order:

1. Remove random in-match power-up bubbles
2. Add persistent power-up inventory data
3. Add pre-match loadout screen and 2-slot selection
4. Add in-match consumption / return-unused behavior
5. Add post-match power-up rewards
6. Add weekly stars and milestone data model
7. Add weekly progress UI to Home and Result
8. Tune reward rates and power-up weights after playtests

---

## Final product statement

After applying this patch, BAR CLASH should be defined as:

> A Match Masters-like PvP puzzle racer with a light meta layer:  
> ladder progression, pre-match booster loadouts, and a weekly reward track —  
> **without** collection systems, village-building, or heavy F2P scaffolding.
