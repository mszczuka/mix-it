# Perfect Packers — PvP Variant

**Status:** Prototype design (adapts the cozy single-player [Perfect Packers: Puzzle Game](https://play.google.com/store/apps/details?id=com.AvianHearts.PerfectPackers) by Avian Hearts Studios, 2025, into a real-time PvP race).
**Target platform:** Mobile (portrait, one-handed).
**Engine assumption:** Unity (project already set up). HTML/JS prototype is the first build target.
**Scope:** Single PvP match loop. No meta, no monetization, no progression. Prove the core is fun.

> **Source game (verified):** Perfect Packers is a single-player cozy puzzler where you play Benny the Bun, a bunny delivery driver, dragging/rotating odd-shaped items (TV, telescope, robot, sofa, etc.) into tight grid-based delivery boxes; speed earns up to 3 stars; powerups include "move" and "change the puzzle". Sources: [App Store](https://apps.apple.com/in/app/perfect-packers-puzzle-game/id6748304177), [Google Play](https://play.google.com/store/apps/details?id=com.AvianHearts.PerfectPackers), [Pocket Gamer launch coverage, 2025](https://www.pocketgamer.com/perfect-packers/launch/). This PvP variant keeps the **theme, mascot, item-style framing**, but replaces the single-player level inventory with a real-time head-to-head race.

---

## 1. High Concept

Two delivery rabbits race side-by-side to **completely pack a 6×6 delivery box**. First box packed = 1 delivery point. Among the standard gray items, **fragile/colored items** appear occasionally — packing two same-color items adjacent triggers a **Block**: a random empty cell on your opponent's board becomes temporarily unplaceable, shrinking their available space for a few seconds and forcing them to route their pieces around it.

**One-line pitch:** *Pack the box first. Match the fragile labels. Block a corner of your rival's box to slow their pack.*

**Why this works as a PvP reframing of Perfect Packers:**
- The "race to pack a tight grid" fantasy is the heart of the source game — two players on it simultaneously.
- Benny + cozy delivery-room theme + soft visuals translate to a 2-player split screen.
- Block mechanic gives PvP teeth without breaking the cozy tone — you reserve a space on their box (cardboard-divider visual), never destroy progress.

---

## 2. Core Loop

```
Match start (90s timer begins, both boxes empty)
  ↓
Each player draws their own first tray of 4 items (independent RNG per player)
  ↓
[Concurrent, real-time]
  Drag item onto your 6×6 box → snap to valid placement
  Fragile item touching same-color packed cells? → BLOCK:
    1 random EMPTY cell on opponent's board becomes unplaceable for 4s
  Box completely packed? → DELIVERY:
    +1 delivery point
    Box resets to empty (Benny cheers)
    Active blocks on your board are cleared (collateral)
  Tray empty? → new 4-item tray drawn
  Tray has no legal placements? → STUCK STATE (forces booster use, see §9)
  ↓
Loop until timer expires (90s)
  ↓
Most deliveries wins. (Tiebreak: more boxes started — see §6.)
```

**Session length:** 90 seconds.

---

## 3. Board, Items & Tray

### Board (the delivery box)
- **Size:** 6×6 (36 cells). One per player.
- **Cell states:**
  - **Empty** — placeable. Cardboard texture.
  - **Packed cell** — belongs to a parcel you placed. Renders the item slice. **Gray** by default; some cells are **colored** (Red / Yellow / Blue) if the item was Fragile. Color stays until the box is delivered (no consumption — see §5).
  - **Blocked cell** — opponent's fragile match landed here. Renders as a "reserved" marker (a cardboard divider / cute "DO NOT PACK" tag). **Functionally unplaceable** for the block duration; afterward returns to normal empty.

### Items (parcels)
Polyomino set, max 4 cells per item, themed as Perfect-Packers delivery objects:

| Polyomino | Themed name examples | Notes |
|---|---|---|
| 1×1 | Mug, candle, picture frame | Filler |
| 1×2 / 2×1 | Tablet box, book stack | |
| 1×3 / 3×1 | Skateboard, baguette | |
| 1×4 / 4×1 | Surfboard, scroll | |
| 2×2 | Microwave, stool | |
| L-tetromino | Lamp, gardening tool | 4 rotations |
| J-tetromino | Hairdryer, kettle | 4 rotations |
| T-tetromino | Hammer, anglepoise lamp | 4 rotations |
| S / Z | Plant in pot, zigzag bookshelf | 4 rotations |
| 3-cell corner | Folded chair, corner shelf | 4 rotations |

Total: ~25 unique placement options across rotations.

**Excluded from pool** (too large for 6×6 — would softlock matches frequently): 1×5, 5-cell plus, 3×3 square, and the source-game sofa.

**Rotation:** tap an item in the tray to cycle rotations. Long-press to preview ghost on the board.

### Fragile Items (the color layer)
- **Default:** items are **gray** (no special effect on placement).
- **Fragile:** ~25% of items in the queue spawn as Fragile, carrying one of 3 label colors (Red / Yellow / Blue). Visible in tray before placement.
- All cells of a fragile item are colored on placement. **Color persists on the board until the box is delivered** — you can build color clusters that future fragile items chain into (see §5).
- Mechanically identical to gray items — fragile labels only matter for the Block check.

### Tray & Queue
- **4 items visible** at a time.
- **Independent random queue per player.** Each player rolls their own sequence — including their own Fragile rate and colors. There is no shared seed. This means luck does matter on a given match, but variance over multiple matches evens out.
- **7-bag distribution** for variety within each player's stream.
- New tray draws when all 4 items in the current tray are placed.

---

## 4. The Packing Rule (Critical)

> **Lines do NOT clear.** Rows and columns being full is not a scoring event and does not free up space. The ONLY way to clear cells from your box is to fill the ENTIRE box (Delivery!).

When all 36 cells are packed:
- `+1` Delivery point
- Box resets to empty
- All Blocks currently on your board are cleared (collateral — they were on cells that just got delivered)
- Brief Benny celebration (~0.6s). Match clock keeps ticking.

This is the defining mechanic — there is no line-clear relief. Every placement matters. Repack/Undo are the only ways to "rewind" a packed cell short of completing the box.

---

## 5. Fragile Match → Block

### Match trigger
When you place a Fragile item and at least one cell of it is **edge-adjacent** (up / down / left / right — not diagonal) to a packed cell of the **same color** already on your board, it counts as a **Fragile Match**.

### What happens
For each match event:
- **No score points.** (Scoring is delivery-only — §6.)
- **Block 1 random EMPTY cell** on the opponent's board:
  - System picks uniformly at random from the opponent's currently-empty cells.
  - That cell becomes **unplaceable** for `BLOCK_DURATION` (default **4s**).
  - During the block window: no piece may overlap that cell.
  - When the timer expires: the block marker disappears, the cell is normally empty and placeable again.
- Brief pulse on your matched cluster (~0.3s) so player sees cause-and-effect.

### Multi-color rule
- Touching multiple disconnected same-color clusters with one placement = **one block** (no chain bonus in v1).
- Touching cells of multiple different colors at once = **one block per color touched** (rare, but possible).

### Color persistence
Once a cell is colored on the board, it stays colored until the box is delivered. This is the core strategic layer — you build color regions, and future fragile items chain off them for repeat blocks.

### Block caps
- `BLOCK_MAX_ACTIVE_PER_BOARD = 4` — at most 4 simultaneous block markers per player's board. Excess match events while at cap are **dropped** (no queue) — they fire visibly but the attack fizzles. Trade-off accepted: late-game block stacking would be brutal, and the cap is more readable than a queue.
- If opponent's board has **no empty cells** (i.e., they're 1 placement away from Delivery on a fully-fragile cluster) the block has no target and fizzles.

### Important: Blocks do NOT cause direct top-out
See §9. Blocks reduce space but can never force a "no legal placement" loss state on their own — the stuck-state check ignores blocks.

---

## 6. Scoring & Win Conditions

### Scoring sources (the ONLY one)
- `+1` per **Delivery** (full 36-cell pack).

Fragile matches and blocks **do not score directly** — they're PvP pressure, not points.

### Win priority
1. **Real top-out:** opponent is in a stuck state AND has 0 Repack charges AND 0 Undo charges → they lose, you win. (See §9.)
2. **Timer expires (90s):** most Deliveries wins.
3. **Tiebreaker #1:** higher current box fill % at clock expiry (closest to next delivery).
4. **Tiebreaker #2:** more Fragile Matches landed.
5. **Final fallback:** draw.

### Expected scores (designer guess, validate in playtest)
- Casual player: 1–2 deliveries / 90s
- Skilled player: 2–4 deliveries / 90s
- Top performance: 4–5 deliveries / 90s

---

## 7. Boosters

Three boosters. Slot is hidden when 0 charges, appears when ≥1 charge.

### Booster 1: Repack (defensive — unstick / freedom)
- **Effect:** tap any one of your own packed cells to unpack it (cell returns to empty). No score change, no Block sent.
- **Start charges:** 2.
- **Recharge:** +1 per `REPACK_RECHARGE_INTERVAL_SECONDS` (default **25s**) of active play. Idle time (no placement in `STALL_THRESHOLD_SECONDS`) does not count.
- **Cap:** `REPACK_MAX_CARRIED = 3`.
- **Cooldown:** `REPACK_COOLDOWN_SECONDS = 3.0`.
- **Note:** Repack is the primary unstick tool when in Stuck State (§9).

### Booster 2: Undo (utility — the cozy lever)
- **Effect:** undo your **last item placement**. The item returns to the front of your tray (same rotation as placed); the cells it occupied become empty.
- **Start charges:** 1.
- **Recharge:** +1 per `UNDO_RECHARGE_INTERVAL_SECONDS` (default **30s**) of active play.
- **Cap:** `UNDO_MAX_CARRIED = 2`.
- **Cooldown:** `UNDO_COOLDOWN_SECONDS = 2.0`.
- **Restrictions:** Undo only works on your most-recent placement. It is unavailable if:
  - The last placement triggered a **Delivery** (already scored — can't rewind a delivered box)
  - The last placement triggered a **Fragile Match** (the block already shipped to the opponent — can't undo their committed effect)
  - The tray has **refilled** since your last placement (older placements are not undoable)
- **Note:** Undo is the secondary unstick tool in Stuck State — useful when your last placement created the soft-lock.

### Booster 3: Wreck (offensive — the heist)
- **Effect:** **Block a 2×2 area** on the opponent's board for `WRECK_DURATION` (default **4s**). Auto-aim: targets the 2×2 area on the opponent's board containing the most currently-empty cells. If the chosen 2×2 has any already-blocked cells, those refresh their timer; any packed cells in the area are skipped (block only applies to empty cells within the 2×2).
- **Start charges:** 0.
- **Earn (two paths):**
  - **Charge A — offensive:** +1 charge per own **Delivery**.
  - **Charge B — defensive:** +1 charge per `WRECK_ABSORB_THRESHOLD` (default **8**) blocks that have landed on YOUR board across the match (counts blocks that expired normally — i.e., absorbed pressure earns the counter-punch).
- **Cap:** `WRECK_MAX_CARRIED = 1`. Excess earns are wasted.
- **No cooldown** beyond consumption.

---

## 8. Stuck State (Top-Out Replacement)

There is **no instant top-out** in this design. Instead, when no item in your tray has a legal placement on your board, you enter the **Stuck State**.

### How it works
1. Engine detects: every item in your tray, in every rotation, has no legal placement on your board. **Blocked cells from opponent are ignored** for this check (they expire on their own — they cannot single-handedly cause Stuck State).
2. **Tray locks** — you cannot drag items until the state is cleared. UI shows a warning glow on your box: "STUCK — use Repack or Undo."
3. **The match clock keeps running.** Sitting in Stuck State costs you race time — a hard incentive not to dawdle.
4. **You must use Repack or Undo** to escape:
   - **Repack** unpacks one of your cells, creating empty space.
   - **Undo** returns your last-placed item to the tray, freeing its cells.
5. After the booster use, the engine re-evaluates. If at least one item now has a legal placement → state cleared, normal play resumes. If still stuck → warning repeats, must use another booster.
6. **Wreck is not usable while Stuck** (its effect doesn't unblock your board — UI greys it out).

### Real top-out (the only instant-loss path)
If you enter Stuck State AND you have **0 Repack charges AND 0 Undo charges** at the same time → real top-out, **instant loss.**

This is rare by design: Repack starts with 2 charges and recharges over time, Undo starts with 1 and recharges. Reaching 0 across both requires having spent every charge prior to the stuck moment — an earned failure, not a sudden one.

### Danger zone warning (preventive)
When your board occupancy ≥ `DANGER_ZONE_OCCUPANCY` (default **0.75** — i.e., ≥27/36 packed), the box edge gets a pulsing warning glow. No mechanical effect — just signals "you're close to Stuck State." Cosmetic.

---

## 9. Controls & Layout

- **Portrait two-board layout.** Top half: opponent's 6×6 box (read-only, shows their packing in real time). Bottom half: your 6×6 box + tray + booster bar + match clock.
- **Drag** to place. **Tap-in-tray** to rotate. **Long-press** to preview ghost on board.
- **Booster bar:** 3 slots under the tray, hidden when 0 charges.
- **Score readout:** "Deliveries: YOU 1 — 2 RIVAL" prominent between the boards.
- **Match timer ring** around Benny's portrait in the middle.
- **Block indicators:** a small arrow flies from your matched cluster to the opponent's blocked cell (and vice versa for incoming blocks). Blocked cells show a return-timer ring.

---

## 10. Tuning Constants

```
// Board & tray
BOARD_WIDTH                      = 6
BOARD_HEIGHT                     = 6
PIECE_TRAY_SIZE                  = 4
PIECE_MAX_CELLS                  = 4
MATCH_DURATION_SECONDS           = 90
QUEUE_MODE                       = independent_per_player

// Fragile / colors
COLOR_PALETTE_SIZE               = 3       // Red, Yellow, Blue
FRAGILE_RATE                     = 0.25    // 1 in 4 items is fragile
COLOR_DISTRIBUTION               = uniform // each color equally likely
COLOR_PERSISTS_ON_BOARD          = true    // colored cells stay colored until Delivery

// Block (PvP)
BLOCK_DURATION                   = 4.0     // seconds a blocked cell stays unplaceable
BLOCK_MAX_ACTIVE_PER_BOARD       = 4       // hard cap; excess matches fizzle
STALL_THRESHOLD_SECONDS          = 2.0

// Scoring
DELIVERY_POINTS                  = 1

// Booster — Repack
REPACK_START_CHARGES             = 2
REPACK_RECHARGE_INTERVAL_SECONDS = 25
REPACK_MAX_CARRIED               = 3
REPACK_COOLDOWN_SECONDS          = 3.0

// Booster — Undo
UNDO_START_CHARGES               = 1
UNDO_RECHARGE_INTERVAL_SECONDS   = 30
UNDO_MAX_CARRIED                 = 2
UNDO_COOLDOWN_SECONDS            = 2.0

// Booster — Wreck
WRECK_DURATION                   = 4.0     // 2x2 block lifetime
WRECK_CHARGES_PER_DELIVERY       = 1
WRECK_ABSORB_THRESHOLD           = 8       // blocks absorbed per defensive charge
WRECK_MAX_CARRIED                = 1

// Stuck state / top-out
DANGER_ZONE_OCCUPANCY            = 0.75    // cosmetic warning threshold
// (no Emergency Repack, no Comeback bonus in this version)
```

---

## 11. AI Opponent

Heuristic bot:
- Priority: (1) placements that complete the box → (2) placements that trigger a Fragile Match → (3) general "minimize rough surface" packing.
- Bot uses Repack when in Stuck State, never offensively.
- Bot uses Undo only when its last placement objectively worsened position (creates a hole count >2).
- Bot uses Wreck immediately on charge (no hoarding).
- Difficulty levels (Easy / Medium / Hard) primarily via reaction time (0.5–2.0s) and look-ahead depth (1 / 2 / 3 placements).

---

## 12. What's NOT in the Prototype

- No real netcode (local hot-seat or bot opponent)
- No accounts / meta / progression
- No shop / monetisation
- No music or full SFX pass (placeholder cute SFX — Benny "ta-da!" on Delivery)
- No costumes / cosmetics
- No tutorial sequence beyond first-match tooltips
- No multiple box layouts (single fixed 6×6)
- No event modes / daily challenges
- No sofa (cut from item pool — too big for 6×6)
- No comeback bonus
- No emergency repack on first soft-lock (replaced by Stuck State mechanic)

---

## 13. Success Criteria

The prototype validates when:

1. New player understands "pack the box, fragile labels block the opponent" within 45 seconds.
2. Matches consistently run the full 90s — real top-outs (0 Repack + 0 Undo + Stuck) happen in <10% of matches.
3. At least one Delivery happens per match for skilled players.
4. Fragile Matches happen often enough to feel rewarding (≥4 per match for engaged players).
5. Blocks are noticed by playtesters as meaningful — players try to **route around them** rather than ignoring them.
6. Undo is used in ≥70% of matches by ≥70% of players. If players hoard Undo and never use it, its design is wrong.
7. Stuck State triggers feel like the player's mistake, not random punishment — playtesters say "I got greedy" not "the game screwed me."
8. Playtesters describe it as "Perfect Packers with a competitive feel," not "Block Blast with a bunny skin." If criterion 8 fails → the theme reskin isn't doing the work.

If 6 of 8 are met → variant validates.

---

## 14. Implementation Order

For the HTML prototype:

1. **Board, tray, independent queue** — base 6×6 renderer, tray with rotation, per-player random sequence with 7-bag.
2. **Polyomino placement & rotation** — drag/drop, snap validation, illegal-placement feedback.
3. **Delivery** — full-board detection, +1 score, reset animation, Benny cheer.
4. **Fragile tagging** — 25% of items tagged Red/Yellow/Blue, colored overlay on item sprites both in tray and on board.
5. **Fragile Match detection** — on placement, walk placed cells, check 4-neighbour adjacency to same-colored packed cells, fire match events.
6. **Block system** — pick random empty cell on opponent's board, mark blocked, render return-timer ring, expire after duration, cap at 4 active.
7. **Repack booster** — tap-to-target on own board, recharge timer, charge bar UI.
8. **Undo booster** — last-placement memory, restore item to tray + clear cells, restrictions enforced.
9. **Wreck booster** — dual-charge tracking, 2×2 auto-aim target selection, fire-and-forget.
10. **Stuck State** — detection (ignore blocked cells), tray-lock UI, must-use-booster flow, real top-out when both Repack and Undo at 0.
11. **Bot AI** — heuristic with priority order; difficulty by reaction time + lookahead.
12. **Polish pass** — Benny reactions, block animation arrows, item sprites (placeholders OK), match-end screen.

---

## 15. Design Critique — Open Issues

Honest concerns with the simplified design.

### Strengths
- **Block is on-tone:** "reserve a corner of their box with a divider" fits cozy delivery framing. No grief, no rage.
- **Color persistence creates strategy:** building color clusters → repeated blocks off the same cluster → a real reason to think before placing fragiles.
- **Stuck State is teachable:** clear cause ("you over-packed"), clear fix ("Repack or Undo"). Boosters get a forced learning moment instead of being optional.
- **Independent queues = honest scoreboard:** when you win, it's yours. No "rigged" complaints from mirrored RNG.

### Real risks

1. **Independent RNG = unfair feeling in single matches.** Across N matches it evens out, but in a single playtest one player might get 6 fragiles vs the other's 2. Player will say "I lost because of bad pieces." Mitigation: track fragile count in match-end screen, show "Fragile draws: 4 vs 6" so the variance is visible / contextualized. Long-term: if variance feels too punishing, switch to seeded mirrored queue and accept the "we got the same pieces" framing.

2. **Block targeting is still random within "empty cells".** A block landing on a cell deep in the opponent's empty area is a near-non-event; one landing in their tightest corner is a real obstacle. Same variance problem as the original snatch design — but smaller magnitude (a block only takes 1 cell vs Mosaic-style garbage of up to 12). Playtest will reveal if it matters. Mitigation if needed: bias target selection toward cells in the bottom-right (or whichever corner the opponent is currently packing into most heavily).

3. **Late-match blocks can stack uncomfortably.** Cap of 4 active blocks per board means at worst 4/36 = 11% of empty space is denied. That's significant but not catastrophic. Watch in playtest: is the cap right? If matches feel constantly blocked → drop to 3. If blocks are rarely felt → raise to 5.

4. **No comeback mechanic = matches can be decided early.** First Delivery (~30–45s in) gives a lead that's hard to overturn — Wreck charges off Delivery, so the leader gets MORE attack power. The trailing player has Wreck's defensive path (8 blocks absorbed) but that's slow. Accepted risk for now per design decision; if 50%+ of matches feel "decided at first Delivery," reconsider.

5. **Stuck State + 0 boosters = silent death.** A player who burns Repack + Undo aggressively then hits Stuck loses with no warning. The Danger Zone glow at 75% is the only signal. Risk: feels punishing without a clear "you have one charge left" warning. Mitigation: when player has 0 Repack + 0 Undo, add an explicit warning indicator on the booster bar ("⚠ No unstick available").

6. **Score sparsity:** the score readout moves only on Delivery, which is rare. Long stretches of 0-0 may feel low-momentum. Hedge: a "Fragile Matches: 5 / 3" counter under the score so players see PvP impact tick up, even though it doesn't decide the win.

7. **Wreck on its own may not feel like a payoff.** A 2×2 block for 4s is structurally similar to four normal blocks — but harder to earn. Players may not feel "yes, I earned this" when they use it. Watch: are players excited when they fire Wreck, or do they hoard it / dump it? Tune charge thresholds based on excitement, not just usage count.

8. **No Bot AI specification for difficulty curve.** Easy bot doesn't lose on purpose — it just thinks slower. Risk: at "Easy" the bot still packs well enough to crush a new player. Mitigation: at Easy, bot deliberately makes 1 sub-optimal placement per tray cycle. (This is real cheating, but is invisible and aligns expected difficulty.)

### Recommendation
Build it. The architecture is clean, the unknowns are tunable, and there are no structural exploits left after this round of stripping. Risks 1, 2, 4 are the ones to watch in the first playtest — they're not fatal but they're the most likely sources of "feels off" feedback.

---

## 16. Glossary

- **Delivery / Box Complete:** filling all 36 cells. +1 point. Replaces Mosaic's "Mosaic Clear."
- **Item / Parcel:** a polyomino piece with a Perfect-Packers theme.
- **Fragile item:** a colored item (~25% rate). Visible in tray.
- **Fragile Match:** placement of a fragile item edge-adjacent to a same-color packed cell. Triggers a Block.
- **Block:** the PvP interference event — one random empty cell on the opponent's board becomes unplaceable for ~4s. Replaces Mosaic's "garbage cell."
- **Blocked cell:** a cell currently affected by a Block. Renders as a "reserved" marker with a return-timer ring. Functionally unplaceable.
- **Repack:** booster — unpack one of your own cells. The defensive / unstick lever.
- **Undo:** booster — return your last placement to the tray (with restrictions). The cozy lever.
- **Wreck:** booster — 2×2 block on the opponent's board for 4s. The offensive lever.
- **Stuck State:** state when no tray item has a legal placement on your board. Tray locks; you must use Repack or Undo to escape. Clock keeps running.
- **Real top-out:** Stuck State with 0 Repack + 0 Undo = instant loss. The only instant-loss path in the game.
- **Danger zone:** ≥75% board occupancy → cosmetic warning glow.
- **Benny:** the bunny mascot, between the two boards, reacting to events.
