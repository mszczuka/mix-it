# Arrows GO! v6 — Design Doc (Revised v3)

> **Tagline:** Walled exits. Line chains. Color storms. Multiple arenas — one ruleset, four flavors.

This document is the spec for v6. It is parametric: rules scale with grid size `N`. It is also intentional: each arena gets exactly **one** distinctive modifier so they don't all play the same.

Where this document conflicts with code, **this document wins**.

---

## 0. What this revision fixes

The previous draft had four real holes (caught in design review):

1. Line Chain almost never triggered on small arenas — too few arrows per line.
2. Legendary tier was unspawnable on Backyard — blocker requirement too high for sparse boards.
3. Color Storm thresholds did not scale **down** for small arenas — Storm never charged on Backyard.
4. Storm × Line Chain interaction was undefined — ambiguous spec.

Also patched:
- Arenas only differed in size → added one distinctive modifier per arena.
- Meter overflow during long chains was undefined → bank up to 2× threshold.
- Line Chain "next arrow on line" was ambiguous with perpendicular blockers → explicit rule.
- Move budget was constant regardless of `N` → scales with `N`.
- HUD overcrowding from 8 meter widgets → opponent meters compact.
- No chain-preview before tap → long-press preview.

---

## 1. Identity

Two players share one walled board. They release arrows trying to fly them out through narrow **gates** in the walls. Three layers of action:

1. **Manual tap** — release one arrow. Deterministic Arrow-Go puzzle.
2. **Line Chain** — when the tapped arrow heads a queue of same-direction arrows on the same line, the queue auto-fires as one move. Mechanical cascade. Removes tedium.
3. **Color Storm** — charged across turns; player-triggered; releases every arrow of one color simultaneously, phasing through other arrows. Spectacle event.

The player computes Layer 2 by reading the line. The player schedules Layer 3 by watching the meter. The game never auto-resolves anything the player didn't already see.

---

## 2. Parametric system

All rules are functions of `N` (grid edge) and `G` (gates per side). Arena presets in Section 3 pick concrete values.

### 2.1. Grid

`N × N` square. Continuous walls except at gate positions.

### 2.2. Gate positions

```
GATE_POS[i] = round((i + 1) * N / (G + 1) - 0.5)   for i in 0..G-1
```

Examples:
- `N=8, G=2` → `[2, 5]`
- `N=10, G=2` → `[3, 6]`
- `N=12, G=3` → `[2, 5, 8]`
- `N=14, G=3` → `[3, 7, 10]`

Gates are **directional**: top gates accept `up` only, etc.

### 2.3. Arrow shapes

| Grid range  | Allowed templates                                                  |
|-------------|--------------------------------------------------------------------|
| `N ≤ 10`    | short-2, long-3, L-3                                               |
| `11 ≤ N ≤ 13` | short-2, long-3, L-3, long-4                                     |
| `N ≥ 14`    | short-2, long-3, L-3, long-4, long-5, L-4                          |

Spawn weight by length: `{2: 50, 3: 35, 4: 10, 5: 5}` (within available pool, normalized). L-shapes share their length bucket 70/30 with straights.

### 2.4. Tiers

| Tier       | Color   | Points | Weight | Required blockers in firing line at spawn |
|------------|---------|--------|--------|--------------------------------------------|
| Common     | 🟢 green | 1      | 60%    | 0                                          |
| Rare       | 🔵 blue  | 2      | 25%    | `N ≤ 10 ? 0 : 1`                            |
| Epic       | 🟣 purple| 3      | 12%    | `N ≤ 10 ? 1 : 2`                            |
| Legendary  | 🟡 gold  | 4      | 3%     | `N ≤ 10 ? 1 : 2`                            |

Small arenas have looser blocker requirements so all tiers actually spawn (previously: legendary unspawnable on N=8).

### 2.5. Density

- **Seed:** 45–55% of `N²` (rolled per match).
- **Mid-match top-up:** 35–45%.

Same fraction across arenas. Density is the master dial.

### 2.6. Turn structure

```
MOVES_PER_TURN = max(3, floor(N / 3))      // 8:3, 10:3, 12:4, 14:4
TURN_MS        = (10 + N/2) seconds        // 8:14, 10:15, 12:16, 14:17
MATCH_MS       = per-arena (see §3)
```

Larger arenas get more moves per turn so each turn meaningfully changes the board.

### 2.7. Color Storm thresholds

```
THRESHOLD[tier] = max(2, round(BASE[tier] * N / 10))
BASE            = [4, 3, 2, 2]   // green, blue, purple, gold
```

| `N`  | Green | Blue | Purple | Gold |
|------|-------|------|--------|------|
| 8    | 3     | 2    | 2      | 2    |
| 10   | 4     | 3    | 2      | 2    |
| 12   | 5     | 4    | 2      | 2    |
| 14   | 6     | 4    | 3      | 3    |

Small arenas now charge Storm regularly. Gold's floor stays at 2.

### 2.8. Storm cap

`STORM_MAX_POINTS = N + 5` → `8:13, 10:15, 12:17, 14:19`.

### 2.9. Spawn axis bias

```
DIRECT_BONUS   = max(1, 4 - G)   // G=2 → +2, G=3 → +1, G=4 → +0 (use floor 1)
ADJACENT_BONUS = max(0, 2 - G)   // G=2 → 0, G=3 → 0 (was +1, redundant when G≥3)
```

Wait — that flips too aggressively. Practical values:

- `G = 2`: head on gate axis `+3`, within 1 cell `+1`.
- `G = 3`: head on gate axis `+2`, within 1 cell `+1`.
- `G = 4`: head on gate axis `+1`, no adjacency bonus.

Bonus weakens as gates proliferate, so the bias doesn't become "every spawn aligned."

### 2.10. Queue-building bias (new)

To make Line Chain actually trigger on small arenas, candidate spawn gets **+4** if its head lies directly behind an existing same-direction arrow on the same firing line (i.e. it would form a 2-arrow queue facing the same gate). This is in addition to the axis bias.

Effect: roughly 30–50% of spawns build or extend a queue when one is available. On Backyard this lifts Line Chain from "rare" to "happens most matches."

---

## 3. Arena presets — and per-arena modifiers

Every arena uses the parametric system above. **Each also gets exactly one distinctive modifier** so the four arenas feel different beyond size.

| Arena       | `N` | `G` | Gate pos     | Moves | Turn | Match | Storm thresh. | Cap | Arrow pool       | **Modifier** |
|-------------|-----|-----|--------------|-------|------|-------|---------------|-----|------------------|---|
| **Backyard**| 8   | 2   | `[2, 5]`     | 3     | 14 s | 90 s  | `3 / 2 / 2 / 2` | 13  | 2–3              | **No legendary tier.** 3% legendary weight redistributes to common (+2%) and rare (+1%). Simpler scoreboard, faster onboarding. |
| **Court**   | 10  | 2   | `[3, 6]`     | 3     | 15 s | 120 s | `4 / 3 / 2 / 2` | 15  | 2–3              | **Baseline. No modifier.** This is the ranked default. |
| **Stadium** | 12  | 3   | `[2, 5, 8]`  | 4     | 16 s | 150 s | `5 / 4 / 2 / 2` | 17  | 2–4              | **Shifting gates.** Every 30 s one random gate closes for 6 s (5 s warning, gate icon dims and pulses). Adds a timing layer; long setups can get stranded. |
| **Arena**   | 14  | 3   | `[3, 7, 10]` | 4     | 17 s | 210 s | `6 / 4 / 3 / 3` | 19  | 2–5 + L-4        | **Comet legendary.** Every 75 s a legendary spawns on the center cross, bypassing normal spawn rules. Creates a recurring "race to the gold" moment. |

Backyard onboards (smaller, faster, no top tier). Court is the standard. Stadium tests timing. Arena rewards specialization.

---

## 4. Core loop

- Match runs for arena's `MATCH_MS`.
- Turns alternate. Each turn: `MOVES_PER_TURN` moves, `TURN_MS` clock.
- **A move:** tap an arrow. It advances in its direction.
  - Clear path to a matching gate → exits, scores. May trigger Line Chain (§4a).
  - Head hits another arrow or wall-without-gate → slides as far as it can. Setup move.
  - Cannot move at all → tap shakes, no move consumed.
- End of turn → smart refill → opponent's turn.
- A **Color Storm tap** can be inserted at any point during the player's turn; it does not consume a move.
- A **Long-press** on any arrow shows a chain preview (§4b) without consuming anything.

## 4a. Line Chain — the mechanical cascade

When a manual tap clears the front of a same-direction queue on a single firing line, the queue empties in one action.

### Trigger rule (precise)

After arrow `A` exits via a manual tap:

1. Identify A's firing line `L` (row = `A.headY` if A is horizontal; column = `A.headX` if A is vertical).
2. From A's old tail position, walk along `L` **opposite to A's firing direction**.
3. The first cell in that walk that contains another arrow `B` is the candidate.
4. `B` is a valid chain link if **all** of:
   - `B.dir === A.dir`,
   - `B`'s firing line is also `L` (i.e. `B`'s head sits on `L`),
   - `B`'s current `slideDistance` indicates `offBoard === true` (clear path to a matching gate),
   - the cells between A's old tail and `B`'s head (exclusive) on `L` are now empty (no foreign-direction body cells crossing the line).
5. If `B` qualifies → fire it. Repeat from `B`'s old tail (recursive walk).
6. Chain stops when no qualifying `B` is found.

### Scoring

- Each chain link scores its base tier value plus `(linkIndex - 1)` chain bonus. Manual tap is link 1.
- Total chain payout clamped to `STORM_MAX_POINTS` (same cap as Storm).
- All points credit the player who initiated the manual tap.

### Move cost

The whole chain is **one move**. `consumeMove` is called exactly once.

### Meter feeding

Each chain link bumps its tier's meter for the chain-owner. See §7.2 for overflow.

### What chains and what doesn't

| Situation                                                                      | Chains? |
|--------------------------------------------------------------------------------|---------|
| Three `right` arrows tail-to-head on row 6, player taps the front              | Yes — all three |
| Two `up` arrows in column 3, front exits, back now has clear path              | Yes |
| `right` arrow on row 6 unblocks a perpendicular `up` arrow                     | No — different line |
| Two `right` arrows on row 6 with a `left` arrow between them                   | No — foreign-dir blocker on line |
| Two `right` arrows, one on row 6 one on row 7                                  | No — different lines |
| `right` L-shape exits, freeing row 5 cells; an `up` arrow now has a path       | No — perpendicular reaction, manual only |

The last row is where foresight stays in play: perpendicular reactions are not chained.

## 4b. Chain preview (long-press)

- Hold any arrow ≥ 250 ms → ghost overlay shows:
  - The exit path of the tapped arrow (dotted gate-bound line).
  - Faded silhouettes of all arrows that would Line-Chain off this tap.
  - A chip showing potential payout: `+N pts (3 chain)`.
- Release without dragging away → execute the tap.
- Drag away or onto another arrow → cancel.

This is essential UX — without it the player can't decide whether to burn a Color Storm or just tap into a long chain.

---

## 5. Spawning

Validity:
- All cells in-bounds, empty.
- Touches an existing arrow (or first arrow lies in center 2×2).
- Does not create a blocker cycle.
- Leaves the board playable (≥1 arrow can still fire after placement).

Candidate score (higher = preferred):

```
score  =  -2 * |blockersInFront - requiredBlockers(tier, N)|
       +   min(2, blocksExisting)
       +   lengthBias * (templateLen - 3)
       +   axisBonus              // §2.9
       +   queueBuildingBonus     // §2.10 — +4 if forming a same-dir queue
```

`lengthBias` rolled per refill: `Uniform(-1, +1)` for `N ≤ 11`, `Uniform(-1.5, +1.5)` for `N ≥ 12`.

If no candidate meets the legendary blocker requirement → downgrade tier and retry, until one fits.

Refill to seed target (45–55%) or mid-match target (35–45%) of `N²`. If we can't reach the target (all candidates fail) — stop refilling at whatever fill we managed. Board ends up sparser; gameplay continues.

---

## 6. Scoring

- Only an arrow that fully exits a matching gate scores.
- Flat per tier: 1 / 2 / 3 / 4. No length multiplier.
- Points credit the player who initiated the action.

---

## 7. Color Storm

### 7.1. Trigger

- Manual tap on a ready meter icon.
- Costs **0 moves**.
- **Max one Storm per player per turn** (`stormUsedThisTurn` flag, reset on turn switch).

### 7.2. Meters & overflow

- Each player owns 4 meters, persistent across turns.
- A meter increments by 1 each time **that player** exits an arrow of that tier (manual, Line Chain link, or Storm chain).
- When a meter reaches threshold → flagged "ready," visual pulse.
- **Banking:** a meter can hold up to `2 × threshold`. Increments beyond that are lost. This means a long Line Chain that exits 5 greens while green meter was at threshold 3 → meter ends at 6 (i.e. one ready Storm plus a half-charged next one). Players are not punished for big chains.
- **On trigger:** meter resets to `current − threshold`. If still ≥ threshold, the meter stays ready (player can fire a second Storm next turn).

### 7.3. Storm execution

When player P triggers Storm of tier T:

1. Collect every arrow of tier T currently on the board.
2. Sort by `slideDistanceIgnoringArrows` ascending (closest to gate fires first — cleanest visual).
3. Fire sequentially with 120 ms stagger.
4. For each:
   - Recompute `slideDistanceIgnoringArrows` (treats other arrows as transparent; walls still solid).
   - If head reaches a matching gate → animate exit, award `baseTierValue + chainIndex - 1`, capped so the running total ≤ `STORM_MAX_POINTS`. Bump meter for that tier.
   - If head hits non-gate wall → **dispel** animation (fade-shrink), no points, no meter bump.
5. After the last arrow: clear ready flag for tier T (per banking rule above), set `stormUsedThisTurn[P] = true`.

### 7.4. Storm × Line Chain interaction (resolved)

**Storm exits do NOT trigger Line Chain.** Reasons:

- Storm has its own chain mechanic (sequential firing, own bonus, own cap). Nesting another chain on top is opaque to the player.
- Storm already ignores blockers — the "queue clears as one" intuition of Line Chain doesn't apply.
- Player triggered Storm, not a manual tap. Line Chain is the manual-tap promise: "your tap clears the visible queue."

Storm exits still bump meters normally. So a Storm can leave one of the other meters ready for next turn. But within the Storm itself: only the explicit Storm chain runs.

### 7.5. Defensive Storm (strategic note)

Storm fires **every** arrow of the chosen color on the shared board. That includes arrows the opponent had set up to exit next turn. **Stealing setups by Storm is a legitimate, intended strategy.** The player who burns the Storm scores all the points, regardless of who set them up.

Bot is aware of this — see §9.

### 7.6. Other edge cases

- Storm on opponent's turn → not allowed.
- Storm with 0 arrows of that color → tap allowed but warned; meter still resets per banking rule (player chose to discharge).
- Storm during turn-timer expiry → Storm finishes; turn switches after the animation completes.

---

## 8. Side bonuses

- **Green Streak** — 3 consecutive green exits on the same player's turns (no non-green exit between) → **+1 move** this turn. Gold "bonus" dot on the moves track. Resets on non-green exit or turn switch.

Only this. Tight design.

---

## 9. Bot

Heuristic order each move:

1. **Defensive Storm:** if a Storm meter is ready AND the opponent's "next-turn projection" shows ≥2 same-tier arrows lined up on a gate axis they would naturally fire → **trigger Storm now** to steal their setup.
2. **Offensive Storm:** if a Storm meter is ready AND ≥3 same-tier arrows of that color are on the board (own potential) → trigger Storm.
3. **Manual fire:** scan all arrows. Prefer arrows that trigger a Line Chain (count chain length × tier value as projected payout). Otherwise pick the single highest-tier exit.
4. **Setup:** pick the arrow with the longest slide.

"Next-turn projection" is a cheap simulation: assume opponent gets `MOVES_PER_TURN` greedy moves; flag any same-tier arrow that becomes fireable in any of those moves.

Bot fires Storms at most once per turn (rules apply equally).

---

## 10. Win condition

- After `MATCH_MS`, higher score wins.
- **Tiebreak:** sudden-death turn — one legendary spawns at the center cross, both players get 1 move each (you first, then opp). Highest of the resulting scores wins. If still tied, local player wins (placeholder for ranking).

---

## 11. Implementation notes

### 11.1. Arena config builder

```js
const ARENAS = {
  backyard: { N: 8,  G: 2, modifier: 'noLegendary' },
  court:    { N: 10, G: 2, modifier: null },
  stadium:  { N: 12, G: 3, modifier: 'shiftingGates' },
  arena:    { N: 14, G: 3, modifier: 'cometLegendary' },
};

function buildArenaConfig(N, G, modifier) {
  const gates = Array.from({length: G}, (_, i) =>
    Math.round((i + 1) * N / (G + 1) - 0.5)
  );
  return {
    N, G,
    GATE_POS: gates,
    MOVES_PER_TURN: Math.max(3, Math.floor(N / 3)),
    TURN_MS: (10 + N / 2) * 1000,
    MATCH_MS: matchMsForArena(N),
    STORM_THRESHOLDS: [4, 3, 2, 2].map(b => Math.max(2, Math.round(b * N / 10))),
    STORM_MAX_POINTS: N + 5,
    TEMPLATES: pickTemplatesForGrid(N),
    LENGTH_BIAS_RANGE: N >= 12 ? 1.5 : 1.0,
    AXIS_BONUS_DIRECT: G === 2 ? 3 : (G === 3 ? 2 : 1),
    AXIS_BONUS_ADJACENT: G <= 2 ? 1 : 0,
    QUEUE_BUILD_BONUS: 4,
    REQUIRED_BLOCKERS: [0, N <= 10 ? 0 : 1, N <= 10 ? 1 : 2, N <= 10 ? 1 : 2],
    TIER_WEIGHTS: modifier === 'noLegendary' ? [62, 26, 12, 0] : [60, 25, 12, 3],
    modifier,
  };
}
```

`matchMsForArena(N)`: 8→90s, 10→120s, 12→150s, 14→210s. Simple lookup, not formula (humans tune match length per arena, not math).

### 11.2. Master templates

```js
const ALL_TEMPLATES = [
  { len:2, cells:[[-1,0],[0,0]] },
  { len:3, cells:[[-2,0],[-1,0],[0,0]] },
  { len:3, cells:[[-1,-1],[-1,0],[0,0]] },
  { len:3, cells:[[-1, 1],[-1,0],[0,0]] },
  { len:4, cells:[[-3,0],[-2,0],[-1,0],[0,0]] },
  { len:4, cells:[[-2,-1],[-2,0],[-1,0],[0,0]] },
  { len:5, cells:[[-4,0],[-3,0],[-2,0],[-1,0],[0,0]] },
];
```

### 11.3. Gate logic

```js
function isExitCell(x, y, dir, cfg) {
  switch (dir) {
    case 'up':    return y === 0          && cfg.GATE_POS.includes(x);
    case 'down':  return y === cfg.N - 1  && cfg.GATE_POS.includes(x);
    case 'left':  return x === 0          && cfg.GATE_POS.includes(y);
    case 'right': return x === cfg.N - 1  && cfg.GATE_POS.includes(y);
  }
}
```

For `shiftingGates` modifier: maintain `state.closedGates = Set<"dir:pos">`. `isExitCell` returns false when the gate is currently closed. Run a timer that closes one random gate every 30 s for 6 s (5 s pre-warning).

### 11.4. Line Chain implementation

```js
function tryLineChain(firedArrow, byPlayer, chainPayoutSoFar) {
  const axis = firedArrow.dir === 'left' || firedArrow.dir === 'right' ? 'row' : 'col';
  const fixedCoord = axis === 'row' ? firedArrow.oldTail.y : firedArrow.oldTail.x;
  const dirSign = (DIRS[firedArrow.dir].dx + DIRS[firedArrow.dir].dy); // +1 or -1
  const startAxis = axis === 'row' ? firedArrow.oldTail.x : firedArrow.oldTail.y;

  let candidate = null, candidateDist = Infinity;
  for (const id in state.arrows) {
    const B = state.arrows[id];
    if (B.dir !== firedArrow.dir) continue;
    const bFixed = axis === 'row' ? B.headY : B.headX;
    if (bFixed !== fixedCoord) continue;
    const bAxis = axis === 'row' ? B.headX : B.headY;
    const behind = dirSign > 0 ? (bAxis < startAxis) : (bAxis > startAxis);
    if (!behind) continue;
    const dist = Math.abs(bAxis - startAxis);
    if (dist < candidateDist) { candidate = B; candidateDist = dist; }
  }
  if (!candidate) return chainPayoutSoFar;

  // Verify no foreign-dir body cells cross the line between firedArrow.oldTail and candidate.head.
  if (!lineSegmentClear(fixedCoord, startAxis, /*candidate.head*/, axis, firedArrow.id, candidate.id)) {
    return chainPayoutSoFar;
  }

  const { offBoard } = slideDistance(state.grid, candidate);
  if (!offBoard) return chainPayoutSoFar;

  // Fire candidate as chain link.
  const chainIndex = /* derived from chainPayoutSoFar context */;
  const award = Math.min(
    arrowMult(candidate) + chainIndex - 1,
    Math.max(0, cfg.STORM_MAX_POINTS - chainPayoutSoFar)
  );
  // ...animate exit, credit byPlayer, bumpColorMeter...
  return tryLineChain(candidate, byPlayer, chainPayoutSoFar + award);
}
```

`tryRelease` (manual path) calls `tryLineChain(arr, byPlayer, baseValue)` after the manual exit animation. `consumeMove` is called once before the chain runs.

### 11.5. Color Storm

State:
```js
state.stormMeter = { you: [0,0,0,0], opp: [0,0,0,0] };
state.stormUsedThisTurn = { you: false, opp: false };
```

`bumpColorMeter(player, tierIdx)`: increment with cap at `2 * cfg.STORM_THRESHOLDS[tierIdx]`. Mark ready when `meter >= threshold`.

`triggerStorm(player, tierIdx)`: gated by `meter >= threshold && !stormUsedThisTurn[player]`. Execute per §7.3. On finish: `meter -= threshold` (clamp at 0).

`slideDistanceIgnoringArrows(grid, arr)`: same as `slideDistance` but skips cells occupied by **other arrows** (`arrId !== arr.id`); walls still stop.

**Important:** Storm exits do NOT call `tryLineChain`. They are a separate subsystem.

### 11.6. UI

- **Your side of HUD:** 4 meter widgets, each ~28×28 px with fill ring + tier-color glyph. Tap-targetable.
- **Opponent's side of HUD:** 4 dots, ~10 px each, lit when their meter is ready, dim otherwise. Not tap-targetable (theirs).
- **Banner:** "GREEN STORM!", "GOLD STORM!" etc. on Storm trigger.
- **Floater per Storm exit:** `×N` chain counter.
- **Long-press preview:** 250 ms hold → ghost overlay (per §4b).
- **Shifting gates UI:** gate icon dims + pulses during closed phase; 5 s before close, gate flashes warning.

### 11.7. Per-arena modifier hooks

- `noLegendary`: skip legendary entirely in `pickTierIdx`. Tier 3 weight = 0.
- `shiftingGates`: timer in `tick` toggles a random `closedGates` entry every 30 s.
- `cometLegendary`: timer in `tick` runs a center-cross legendary spawn every 75 s, bypassing `touchesExisting` and `requiredBlockers`.

---

## 12. Open questions (tuning, not blockers)

1. Backyard at 90 s might be too short for 3 moves × 6 turns = 18 manual moves. If it feels rushed, push to 100 s.
2. Stadium gate-closure of 6 s — duration may need tuning. Could be cruel mid-Line-Chain. Test.
3. Arena's comet legendary at 75 s cadence — first one lands at 75 s into a 210 s match. Test whether earlier (60 s) feels better.
4. `2× threshold` banking cap on meters — if Storm-then-Storm-next-turn feels broken on Backyard (low thresholds), drop to `1.5× threshold`.

---

## 13. Design philosophy

- **Three cascade layers, three roles.** Manual = control. Line Chain = remove tedium. Color Storm = spectacle.
- **Foresight beats automation.** Line Chain only follows what the player already saw. Perpendicular reactions remain manual.
- **Density is the master dial.** Same fraction across arenas, tuned first.
- **Arenas differ by one feature each.** No quirks beyond the one modifier — keep mastery transferable but make each arena feel like its own room.
- **Defense is real.** Storm steals opponent setups. Long-press preview lets you read the board. The shared board is contested, not parallel.
