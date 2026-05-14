# Mosaic — Playable Rules (v0.1)

> A condensed reference for actually playing / playtesting the Mosaic variant. For full design rationale, see `BLOCK_BLAST_PVP_MOSAIC.md`. This doc is rules only — no critique, no theory.

---

## TL;DR

Two players, two boards. Drag block pieces onto a 6×6 grid. Score by **filling the whole board** (+5) or **matching colors** (+1). Color matches also drop garbage on the opponent. **No line clears.** 90 seconds. Highest score wins. Top-out = instant loss.

---

## Setup

- **Board:** 6×6 (36 cells) per player
- **Piece tray:** 4 pieces visible at a time
- **Piece queue:** shared, mirrored — both players draw from the same seeded sequence
- **Match clock:** 90 seconds
- **Both boards start empty**

---

## Pieces

- Polyomino shapes, **max 4 cells**: singles (1×1), short lines (1×2 / 1×3 / 1×4), 2×2 square, L/J/T/S/Z tetrominoes, 3-cell corners. **NOT in Mosaic pool:** 1×5 line, 5-cell plus, 3×3 square (removed to reduce soft-lock probability on the 6×6 board).
- **Rotation allowed:** tap piece in tray to cycle through rotations
- **Colored pieces:** ~25% of pieces (1 in 4) are tinted **Red**, **Yellow**, or **Blue**
  - Color is visible in the tray BEFORE placement
  - All cells of a colored piece land colored on the board
  - Cells stay colored until cleared

---

## Placement Rules

- Drag piece from tray onto board
- Piece must fit entirely on the board, on empty cells (cannot overlap occupied / garbage cells)
- Rotation: tap in tray to rotate; long-press to preview ghost on board
- Once all 4 pieces in tray are placed → new 4-piece tray draws
- **You cannot skip a piece.** All 4 must be placed.

---

## How You Score

Only two ways to score in Mosaic:

| Event | Points |
|---|---|
| **Color match** (place a colored piece touching same-color cell) | **+1** |
| **Mosaic Clear** (fully fill the 6×6 board) | **+5** |

**No line clears.** Filling a row or column does nothing on its own. The board only clears when ALL 36 cells are occupied.

When Mosaic Clear triggers:
- +5 score
- Board resets to empty
- All garbage on YOUR board is cleared (collateral benefit)
- Brief celebration animation (~0.6s)
- Match clock keeps running

---

## Color Matching

A **match** happens when you place a colored piece such that at least one of its cells is **edge-adjacent** (up/down/left/right — not diagonal) to a same-color cell already on the board.

- One placement = at most one match per color touched
- Touching multiple different colors at once = each color = a separate match event
- Cells stay colored after a match (so future placements can chain off existing clusters)
- After a match, the involved cells are **match-locked for 1 second** (prevents instant re-trigger via Color Swap)

Each match event:
- +1 score
- Sends **1 garbage cell** to opponent
- Cluster on your board briefly pulses (visual feedback)

---

## Garbage Attacks

### Sending
- Every color match sends 1 garbage cell to opponent
- Bomb Drop booster sends a 2×2 garbage block (see Boosters)

### Landing on opponent's board
- Garbage lands in a **random column**, drops to lowest empty row (gravity)
- If a chosen column is full, system picks next column with space
- Garbage cells **do NOT count for color matches** (never colored)

### Garbage decay (defensive lifeline)
Every garbage cell auto-expires:
- **Grace phase (6s):** cell is fully solid, no fade — you feel full pressure
- **Fade phase (4s):** cell visibly fades and then vanishes
- Total lifetime: 10 seconds

**Anti-stall rule:** if you haven't placed a piece in the last 2 seconds, all decay timers on your board PAUSE. Resume when you place again. Keeps stalling from being optimal.

---

## Boosters

You have 3 boosters. Slots are **hidden when empty** — appear only when you have at least 1 charge.

### Hammer (defensive — unstick)
- **Effect:** tap any one of your own cells to delete it. No score, no garbage.
- **Start:** 2 charges
- **Recharge:** +1 every **25s of active play** (idle time doesn't count)
- **Cap:** max 3 carried
- **Cooldown:** 3s after use

### Color Swap (utility — depth lever)
- **Effect:** tap one of YOUR colored cells to cycle its color (Red → Yellow → Blue → Red). If the new color creates an adjacency match, it triggers normally (+1 score, +1 garbage).
- **Start:** 0 charges
- **Earn:** 1 charge per **3 color matches** scored
- **Cap:** max 2 carried
- **Cooldown:** 2s after use
- **v1 limitation:** own board only

### Bomb Drop (offensive — the attack button)
- **Effect:** send a 2×2 garbage block to opponent's board. Uses the standard ~5s decay timing for landed cells.
- **Start:** 0 charges
- **Earn (TWO paths):**
  - +1 charge per own Mosaic Clear
  - +1 charge per **8 garbage cells absorbed** on your board
- **Cap:** max 1 carried (extra earns are wasted)
- **No cooldown** (consumed on use)

---

## Comeback Bonus

When your score is **3 or more points behind** your opponent's score at the moment of a color match:
- That match scores **+2** (instead of +1)
- That match sends **2 garbage cells** (instead of 1)

Re-evaluated in real time. If your match brings you within 2 points of the leader, the next match is normal again. No grace period.

---

## Top-Out (Losing By Filling Up)

You "top out" when no piece in your tray has any legal placement on your board.

### Emergency Hammer (first time only, per match)
The first time you'd top out:
- You're granted **+1 emergency Hammer** automatically
- UI prompts: "EMERGENCY — tap a cell to clear it" (5 second deadline)
- If you don't tap in 5s, the system auto-uses on the cell that unlocks the largest tray piece
- You continue playing

### Real top-out (second time)
The second time you have no legal placement → **instant loss.** Match ends, opponent wins.

### Danger zone (visual warning)
When your board is ≥75% occupied (27+ of 36 cells filled), the board edge gets a pulsing red glow. No gameplay effect — just a visual heads-up.

---

## Win Conditions

In priority order:

1. **Top-out:** if a player tops out (second time, after using their emergency Hammer), the OTHER player wins immediately.
2. **Timer (90s expires):** highest score wins.
3. **Tiebreak #1:** most Mosaic Clears.
4. **Tiebreak #2:** most color matches.
5. **Final fallback:** draw.

---

## Quick Reference Card

```
BOARD            7x7  (36 cells)
TRAY             4 pieces (max piece size: 4 cells)
MATCH            90 seconds
PIECE QUEUE      mirrored (both players, same sequence)
COLORS           Red / Yellow / Blue, ~25% of pieces
LINE CLEARS      none

SCORE  color match              +1
SCORE  Mosaic Clear (full fill) +5
SEND   color match              1 garbage cell
SEND   Bomb Drop                2x2 garbage block

GARBAGE DECAY    10s (6s solid + 4s fade)
STALL PAUSE      2s idle → decay pauses
TOP-OUT          1 emergency Hammer (first), then real loss

BOOSTERS         hidden until earned

HAMMER    start 2, +1 per 25s active play, max 3
SWAP      start 0, +1 per 3 matches,        max 2  (own board only)
BOMB      start 0, +1 per own clear         max 1
                  OR +1 per 8 absorbed

COMEBACK  if trailing by 3+ pts → matches double:
          +2 score AND 2 garbage per match
```

---

## Playtest Checklist

Quick sanity checks while playing:

- [ ] Did matches consistently last ~90s (not end at 30s by top-out)?
- [ ] Did at least one Mosaic Clear happen per match in skilled play?
- [ ] Did color matches feel rewarding (5+ per match for engaged players)?
- [ ] Did boosters get used (not just hoarded)?
- [ ] Did comeback bonus produce actual comebacks, or did it just delay the loss?
- [ ] Did the losing player still feel engaged at 80 seconds in?
- [ ] Did the winning feel earned, not lucky?

Note things that surprised you. The constants in `BLOCK_BLAST_PVP_MOSAIC.md` §9 are the levers — almost any tuning issue can be fixed by adjusting one number, not rewriting rules.

---

## Common Questions

**Q: Can I clear a row by filling it?**
A: No. Rows and columns being full does nothing in Mosaic. Only filling the WHOLE board scores.

**Q: What if I get colored pieces I can't match?**
A: Place them like normal pieces. They contribute to filling the board. They just don't trigger the match bonus.

**Q: Can I save my emergency Hammer for later?**
A: No. It's triggered automatically on first soft-lock. If you don't use it in 5s, system auto-uses it. You can't bank it.

**Q: Does Hammer count cells I delete toward Mosaic Clear?**
A: No, deleting an occupied cell makes it empty again. You need to fill all 36 cells to clear.

**Q: What happens to my boosters if I'm trailing? Do I get them faster?**
A: No, the boosters are skill-gated and don't favor the trailing player. The comeback bonus is the *only* explicit catch-up mechanic.

**Q: Can I see what colored pieces are coming next?**
A: Only the 4 in your tray. There is no peek beyond.

**Q: Do garbage cells eventually fall off if I never clear the board?**
A: Yes — every garbage cell auto-decays after 10s (with the anti-stall rule). They're temporary.
