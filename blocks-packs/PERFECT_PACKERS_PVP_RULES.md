# Perfect Packers PvP — Playable Rules (v0.2)

> Condensed reference for playing / playtesting. For full design rationale, see `PERFECT_PACKERS_PVP.md`. This doc is rules only.

---

## TL;DR

Two delivery rabbits, two boxes. Drag odd-shaped items onto a 6×6 grid. **Pack the whole box = 1 Delivery point.** Some items are **Fragile** (colored). Placing a Fragile item next to a same-color packed cell **Blocks** a random empty cell on your opponent's box for ~4 seconds — they can't pack there until it expires. **No line clears.** **90 seconds. Most Deliveries wins.** Three boosters: **Repack**, **Undo**, **Wreck**. No legal placement? You enter **Stuck State** — must use a booster to continue.

---

## Setup

- **Delivery box:** 6×6 grid (36 cells) per player
- **Item tray:** 4 items visible at once
- **Item queue:** **independent per player** — each rolls their own sequence
- **Match clock:** 90 seconds
- **Both boxes start empty**

---

## Items (Parcels)

- Polyomino shapes, **max 4 cells**: 1×1 (mug), 1×2/1×3/1×4 (books, surfboards), 2×2 (microwave), L / J / T / S / Z tetrominoes (lamp, kettle, etc.), 3-cell L corners.
- **Not in pool:** 1×5, 5-cell plus, 3×3 square, sofa — all too big for 6×6.
- **Rotation:** tap an item in the tray to rotate. Long-press to preview ghost.
- **Gray vs Fragile:** ~75% of items are plain gray. ~25% are **Fragile** with one of 3 colors — **Red / Yellow / Blue**. Fragile color is visible in the tray before placement.

---

## Placement Rules

- Drag item from tray onto your box. Must fit entirely on empty (non-blocked) cells. No overlapping.
- Once all 4 tray items are placed → new tray draws.
- **You cannot skip an item.** All 4 must be placed before the next tray.

---

## How You Score

| Event | Points |
|---|---|
| **Delivery** — full 6×6 packed | **+1** |

That's the only scoring event. Fragile matches don't give points — they fuel the Block attack instead.

When Delivery triggers:
- +1 delivery point
- Box resets to empty
- Any active Blocks on your box are cancelled (collateral)
- Brief Benny celebration (~0.6s)
- Match clock keeps running

---

## Fragile Match → Block

A **Fragile Match** happens when you place a Fragile item such that at least one cell of it is **edge-adjacent** (up / down / left / right — NOT diagonal) to a same-color packed cell on your board.

Each Fragile Match:
- **No score points.**
- **Blocks 1 random empty cell** on the opponent's board:
  - System picks uniformly at random from currently-empty cells.
  - That cell becomes **unplaceable** for **4 seconds**.
  - During the block: no piece may overlap that cell.
  - After 4s: block marker disappears, cell is normal empty again.

### Multi-color rule
- Touching multiple disconnected same-color clusters with one placement = **1 block** (no chain bonus).
- Touching cells of multiple DIFFERENT colors with one placement = **one block per color**.

### Color persistence
Once a cell is colored on the board (by Fragile placement), it stays colored **until the box is delivered**. You can build color clusters; future Fragile items chain off them for repeated blocks.

### Block caps
- Max **4 simultaneous blocks** per board. Excess Fragile Matches while at cap → block fizzles (no effect).
- If opponent's board has **no empty cells** → block has no target, fizzles.

---

## Boosters

3 boosters. Slot is **hidden when empty** — appears when you have ≥1 charge.

### Repack (defensive — unstick)
- **Effect:** tap one of your own packed cells to unpack it. No score, no block sent.
- **Start:** 2 charges
- **Recharge:** +1 every **25s of active play** (idle = no placement in 2s doesn't count)
- **Cap:** max 3
- **Cooldown:** 3s

### Undo (utility — cozy lever)
- **Effect:** undo your **last item placement**. Item returns to the front of your tray (same rotation). Cells become empty.
- **Start:** 1 charge
- **Recharge:** +1 every **30s of active play**
- **Cap:** max 2
- **Cooldown:** 2s
- **You CANNOT Undo if:**
  - The last placement triggered a **Delivery**
  - The last placement triggered a **Fragile Match** (block already shipped)
  - The tray has **refilled** since your last placement

### Wreck (offensive — the heist)
- **Effect:** Block a **2×2 area** on opponent's board for 4s (auto-aim: targets the 2×2 with most empty cells).
- **Start:** 0 charges
- **Earn (two paths):**
  - +1 charge per own **Delivery**
  - +1 charge per **8 blocks** that have landed on YOUR board (defensive earn — eating pressure pays out)
- **Cap:** max 1 (extra is wasted)
- **No cooldown** beyond consumption

---

## Stuck State (Can't Place Anything)

You enter the **Stuck State** when none of the 4 items in your tray has any legal placement on your board, in any rotation.

**Important:** opponent's Blocks on your board are **ignored** for this check. They expire on their own — they cannot single-handedly cause Stuck State.

### What happens
1. Tray locks — you can't drag items.
2. UI shows a warning glow on your box: "STUCK — use Repack or Undo."
3. **The match clock KEEPS RUNNING.** You bleed race time while stuck.
4. You must use **Repack** (unpack one of your cells) or **Undo** (return last placement to tray) to escape.
5. After use, system re-evaluates. If something now fits → normal play resumes. If still stuck → warning again, must use another booster.
6. **Wreck is unusable in Stuck State** (it doesn't free your board).

### Real top-out
If you enter Stuck State **with 0 Repack and 0 Undo charges at the same time** → real top-out, **instant loss**. This is the ONLY way to lose before the clock runs out.

### Danger zone (preventive warning)
When your box is ≥75% packed (≥27/36 cells), the box edge glows red. Just a heads-up — no mechanical effect. "You're close to Stuck."

---

## Win Conditions

In priority order:

1. **Real top-out:** opponent hits Stuck with 0 Repack + 0 Undo → you win immediately.
2. **Timer (90s expires):** most Deliveries wins.
3. **Tiebreak #1:** higher current box fill %.
4. **Tiebreak #2:** more Fragile Matches landed.
5. **Final fallback:** draw.

---

## Quick Reference Card

```
BOARD            6x6 (36 cells)
TRAY             4 items (max item size: 4 cells)
MATCH            90 seconds
ITEM QUEUE       independent per player
FRAGILE          Red / Yellow / Blue, ~25% of items, color persists on board
LINE CLEARS      none

SCORE  Delivery (fill 6x6)              +1
        (Fragile Matches do NOT score)

BLOCK on Fragile Match: 1 random EMPTY cell on opponent, unplaceable for 4s
                        cap: 4 active per board, excess fizzles
                        fizzles if opponent has no empty cells

BOOSTERS         hidden until earned

REPACK   start 2, +1 per 25s active play, max 3, cd 3s
UNDO     start 1, +1 per 30s active play, max 2, cd 2s
                  (no undo of Delivery / Fragile Match / post-refill)
WRECK    start 0, +1 per own Delivery OR per 8 blocks absorbed, max 1
                  2x2 block on opponent, 4s, auto-aim

STUCK    no legal placement → tray locks, clock keeps running
         must use Repack or Undo
         Wreck disabled while stuck
         0 Repack + 0 Undo + Stuck = real top-out (instant loss)
```

---

## Playtest Checklist

- [ ] Did matches reach the full 90s (real top-outs <10% of games)?
- [ ] Did at least one Delivery happen per match in skilled play?
- [ ] Did Fragile Matches happen often enough to feel rewarding (≥4 per match)?
- [ ] Did Blocks visibly slow down packing (players routing around them)?
- [ ] Did Undo get used by ≥70% of players?
- [ ] Did Stuck State trigger feel earned ("I got greedy") not random ("the game screwed me")?
- [ ] Did the losing player still feel engaged at 80s in?
- [ ] Did playtesters describe this as "Perfect Packers + competitive" rather than "Block Blast skinned"?

---

## Common Questions

**Q: Can I clear a row by filling it?**
A: No. Only filling the entire 6×6 scores a Delivery.

**Q: What does a Fragile item do if I can't match it?**
A: Place it like a normal item — it still fills the box. The color stays on those cells, and a future Fragile of the same color placed adjacent will trigger the block.

**Q: My block landed but nothing seemed to happen on the opponent's board.**
A: Either the random target picked an empty cell deep in their empty area (not where they were packing right now), or your block hit their 4-active cap and fizzled. Check their board — you'll see a "reserved" marker with a timer ring somewhere.

**Q: Can opponent's blocks cause me to top-out?**
A: No. Stuck State detection ignores blocked cells (they expire on their own). Only your OWN packing decisions can put you in Stuck State.

**Q: Can I Undo a Delivery?**
A: No. Once you've delivered the box, it's shipped. Undo doesn't rewind a delivered box.

**Q: Can I Undo a placement that triggered a Fragile Match?**
A: No. Once the block leaves your board, the attack is committed. Undo only works on placements that didn't send PvP effects.

**Q: Can I Undo two placements back?**
A: No. Only your most-recent placement, within the current tray cycle.

**Q: Wreck targeted a 2×2 area — what if some of those cells are already packed?**
A: Wreck only blocks the empty cells inside the chosen 2×2. Packed cells are skipped. Auto-aim picks the 2×2 with the most empty cells.

**Q: Do colors stay on the board after a match?**
A: Yes. Cells stay colored until the box is delivered. This lets you build clusters and chain blocks off them.

**Q: Why are the queues independent? Won't one player just get luckier?**
A: Yes, some variance is real. Match-end screen shows fragile count for both players so the variance is visible. Over many matches, it averages out.

**Q: Do boosters carry between matches?**
A: Not in the prototype. Each match starts fresh.

**Q: Why is there no sofa?**
A: A sofa would be too big for a 6×6 PvP grid — it'd softlock matches too often. Cut from the PvP item pool. May return in a v2 with a larger box mode.
