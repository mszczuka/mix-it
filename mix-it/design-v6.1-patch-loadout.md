# PATCH: Pre-Match Loadout System

**Applies to:** design-v6.md (MIX IT v6.1 — BAR CLASH)  
**Date:** 2026-04-16  
**Purpose:** Replace random in-match power-up bubble spawns with a pre-match loadout selection and earn loop. This aligns the core match flow with the Match Masters archetype (pre-committed consumable boosters) and creates a minimal earn-spend cycle between matches.

---

## Summary of changes

1. Power-ups are now **selected before the match** from the player's inventory (2 slots)
2. Each power-up has **1 use per match** — tap to activate, slot goes empty
3. In-match bubble spawning is **removed entirely**
4. Players **earn power-ups from match results** (win = 2, lose = 1)
5. Players start with a **starter inventory** of power-ups
6. AI pre-selects a loadout per match based on arena rules
7. Match layout updated — customer zone no longer contains power-up bubbles
8. New **pre-match screen** added to match flow

---

## Section changes

### § 4 — What changes from v6

Add to the "Changed" list:

```
- Power-ups changed from random in-match bubble spawns to pre-match loadout selection
- Each power-up is a single-use consumable per match
- New pre-match screen added for loadout selection
- Players earn power-ups from match results (win/lose rewards)
```

---

### § 5 — Match Layout

Replace the layout diagram with:

```
+--------------------------------------+
|  YOU 750      0:27    900 [av] Name  |
+--------------------------------------+
|          Opponent board (flex)        |
|       small glasses + PU dots         |
+--------------------------------------+
|           Customer zone               |
|   3 shared customers + patience       |
+--------------------------------------+
|      Power-up loadout (2 slots)       |
+--------------------------------------+
|          Player board (flex)          |
|       full-size glasses               |
|  [Spawn]                    [Undo]   |
+--------------------------------------+
```

Update the zones table:

| Zone | Content |
|---|---|
| Score bar | Your score left, timer center, opponent avatar + name + score right |
| Opponent board | AI glasses (flex), power-up dots (filled = unused, empty = spent) |
| Customer zone | 3 active customers, patience bars — **no floating power-up bubbles** |
| Power-up loadout | 2 pre-selected power-up slots (tap to activate, greys out after use) |
| Player board | Your interactive glasses (flex), spawn button, undo button |

---

### § 8 — Power-Ups (Prototype)

Replace **§ 8.1 Inventory** with:

#### 8.1 Loadout

- Before each match, the player selects **2 power-ups** from their inventory
- Each selected power-up has **1 use** during the match
- Tap the power-up slot to activate — the slot greys out after use
- Unused power-ups are **returned** to inventory after the match (not consumed)
- If the player owns fewer than 2 power-ups, empty slots are allowed

#### 8.1.1 Starter inventory

On first launch, the player receives:

| Power-up | Starting quantity |
|---|---|
| Extra Bottle | 5 |
| Flash Pour | 5 |
| Swap | 3 |
| Clear Bottle | 3 |

Total: 16 power-ups to start. Enough for ~8 matches using 2 per match.

#### 8.1.2 Match rewards

| Result | Reward |
|---|---|
| Win | 2 random power-ups from the arena's available roster |
| Lose | 1 random power-up from the arena's available roster |
| Draw | 1 random power-up from the arena's available roster |

Power-up reward probabilities (per roll):

| Power-up | Weight |
|---|---|
| Extra Bottle | 30% |
| Flash Pour | 30% |
| Swap | 25% |
| Clear Bottle | 15% |

This keeps Clear Bottle (the strongest) slightly scarcer.

---

Replace **§ 8.2 Power-up roster** — update usage descriptions:

#### 8.2 Power-up roster

#### Extra Bottle +
- Adds one empty bottle **permanently** for the rest of the match
- **1 use.** Activates immediately on tap.
- Purpose: workspace expansion — strong as an opener

#### Flash Pour (lightning)
- Your pours become instant for **8 seconds**
- **1 use.** Activates immediately on tap. Timer shown on slot.
- Purpose: speed conversion when you see a route — strong mid-match

#### Swap (arrows)
- Select any 2 of your bottles — their entire contents swap instantly
- **1 use.** Tap slot, then tap 2 bottles.
- Purpose: repositioning / route rescue — tactical, flexible timing

#### Clear Bottle (sponge)
- Select one bottle — all contents discarded, bottle becomes empty
- **1 use.** Tap slot, then tap 1 bottle.
- Purpose: emergency anti-deadlock — save for crisis moments

---

Replace **§ 8.3 Power-up spawning** entirely with:

#### 8.3 Power-up availability by arena

Power-ups unlock as arenas are reached. Players can only select from unlocked power-ups.

| Arena | Available power-ups |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Flash Pour |
| Beach Bar (200-499) | + Swap |
| Cocktail Lounge (500+) | + Clear Bottle |

Once unlocked, a power-up stays available in all arenas.

---

### § 9 — AI Opponent

Replace **§ 9.4 AI power-up usage** with:

#### 9.4 AI loadout and usage

- AI **pre-selects 2 power-ups** at match start from the arena's available roster
- Selection shown as dots in the opponent board zone (filled = unused, empty = spent)
- AI uses power-ups based on arena-tuned timing and conditions:

| Power-up | AI usage condition |
|---|---|
| Extra Bottle | Uses within first 15 seconds |
| Flash Pour | Uses when AI has a serveable route within 2 pours |
| Swap | Uses when board has 0 empty glasses |
| Clear Bottle | Uses when board has 0 empty glasses and no pure stacks |

- AI usage delay: **2-4 seconds** after condition is met (varies by arena)
- AI does not "grab" power-ups mid-match — the bubble system is removed

---

### § 12 — Match Flow

Replace **§ 12.1 Flow** with:

#### 12.1 Flow

```
HOME -> MATCHMAKING -> PRE-MATCH -> LOADOUT -> COUNTDOWN -> MATCH -> RESULT
```

#### 12.2 Matchmaking
_(unchanged)_

#### 12.3 Loadout screen (NEW)

After opponent is found:

```
+--------------------------------------+
|         CHOOSE YOUR POWER-UPS        |
+--------------------------------------+
|                                      |
|  [slot 1: ___]     [slot 2: ___]     |
|                                      |
+--------------------------------------+
|  Extra Bottle (x3)  Flash Pour (x4)  |
|  Swap (x2)          Clear Bottle (x1)|
+--------------------------------------+
|             [ READY ]                |
+--------------------------------------+
```

- Player taps a power-up from inventory to assign it to a slot
- Tap a filled slot to remove the selection
- Player can leave slots empty if they choose
- "READY" button starts the countdown
- **Auto-ready timer: 10 seconds** — if player doesn't tap READY, match starts with current selection (empty slots stay empty)

#### 12.4 Countdown
_(previously 12.3 — unchanged)_

---

### § 13 — Home / Result

Update **Result** section to include power-up rewards:

#### Result screen additions

After score comparison and trophy change:

```
+--------------------------------------+
|           REWARDS                     |
|   [Flash Pour]  [Extra Bottle]       |
|       +1 power-up per reward          |
+--------------------------------------+
```

- Win: 2 power-up icons revealed with a small animation
- Lose: 1 power-up icon
- Draw: 1 power-up icon
- Power-ups are added to inventory immediately

---

### § 14 — Prototype Scope (v6.1)

Update **§ 14.1 What to build** — add to Required:

```
- Pre-match loadout screen (2 slots)
- Power-up inventory (persistent between matches)
- Match result power-up rewards
- Starter inventory on first launch
```

Update **§ 14.2 Smallest viable prototype**:

Replace the power-up line:
```
- 2 power-ups only:
  - Flash Pour
  - Clear Bottle
```

With:
```
- 2 power-ups in loadout system:
  - Flash Pour
  - Clear Bottle
- Starter inventory: 5x Flash Pour, 3x Clear Bottle
- Win = 2, Lose = 1 random power-up reward
```

---

### § 15 — Open Questions for Playtesting

Add:

```
8. Does 1 use per power-up feel impactful enough, or should some power-ups get 2 uses?
9. Is the power-up earn rate (2 win / 1 lose) enough to sustain play without running dry?
10. Does the 10-second auto-ready on loadout screen feel rushed or about right?
11. Do players engage with loadout selection or just spam READY with whatever is default?
```

---

### § 7 — Reference direction (header update)

Update the document header's reference direction to explicitly declare the target archetype:

```
**Reference direction:** Match Masters (shared objective PvP) — target archetype  
**Plugin (core gameplay):** Water Sort Puzzle + real-time PvP serve-race  
```

This makes the archetype/plugin split explicit in the document header.

---

## What this patch does NOT change

- Board generation, pour rules, Color Spawn — unchanged
- Customer system, scoring, combos — unchanged
- AI logic for pouring and serving — unchanged
- Trophy system, arenas, arena scaling — unchanged
- Match duration (90s) — unchanged

## What this patch removes

- In-match power-up bubble spawning (§ 8.3 old)
- AI power-up "grab chance" mechanic (no longer relevant)
- Floating power-up bubble in customer zone
