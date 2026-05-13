# PATCH: Cascade & Turn Streak

**Applies to:** index-arrows-v5.html (ARROWS GO! v5 — Match Masters style)
**Date:** 2026-05-13
**Purpose:** Add a Match Masters-style chain-reaction layer on top of the existing turn-based tap loop. A single well-timed release now propagates through previously-blocked arrows ("cascade"), and consecutive successful releases within a turn build a multiplier ("streak"). Two distinct systems, two distinct purposes: cascade rewards a single great tap, streak rewards a great turn.

---

## Summary of changes

1. **Cascade** — when a tapped arrow exits the board, every arrow it just unblocked (i.e. was `offBoard: false` before, is `offBoard: true` after) auto-fires with an escalating multiplier. Chains recursively.
2. **Streak** — every successful off-board exit in a single turn (including cascade hits, at reduced weight) increments a per-player streak counter. Thresholds trigger escalating rewards. Resets on partial slide or turn end.
3. The existing **3-green-streak → +1 move** rule is **removed** — its job is absorbed into the new streak system (threshold 3).
4. Bot evaluates cascade potential when picking a move.
5. New UI: cascade banner with depth, streak bar above the turn timer.

---

## § 1 — Definitions

**Cascade**
A chain of auto-fired arrows triggered by a manual release within the same move. An arrow joins the cascade if and only if **all** of the following hold:
- it existed on the board at the moment of the trigger tap, **AND**
- `slideDistance(grid, arr).offBoard === false` immediately **before** the trigger tap resolved, **AND**
- `slideDistance(grid, arr).offBoard === true` immediately **after** the trigger tap's cells were cleared, **AND**
- **Adjacency rule (NEW):** the arrow's **head** is in a cell that is 4-directionally adjacent to at least one cell previously occupied by the trigger arrow's body. I.e. it was pressed right up against the trigger — not just somewhere down the same firing line.

Cascade depth starts at 1 (the manual tap is depth 0). Newly-freed arrows can themselves free further arrows on exit — those count at depth 2, 3, …

**Streak**
A counter, one per player, of successful off-board exits during the player's current turn. Both manual exits (weight 1.0) and cascade exits (weight 0.5, rounded down on accumulation) contribute. Resets to 0 on:
- partial slide (a tap that consumed a move but did NOT exit the board), OR
- end of turn (switchTurn).

---

## § 2 — Cascade rules

### 2.1 Trigger
Only a **manual** release (player tap or bot pick) can start a cascade. Cascade arrows do not start nested independent cascades — they continue the same chain at depth+1.

### 2.2 Eligibility check
Computed at the moment the trigger arrow's cells are removed from the grid, before any movement animation begins.

```
triggerCellSet = set of cells the trigger arrow occupied just before removal

For every other arrow A on the board:
  was_blocked = !slideDistance(gridBefore, A).offBoard
  is_free_now =  slideDistance(gridAfter,  A).offBoard
  is_adjacent = any of the 4 neighbors of A.head (head only, not body)
                is contained in triggerCellSet
  if was_blocked && is_free_now && is_adjacent → A joins the cascade queue
```

Why head-only adjacency: the head is the firing point. An L-shaped arrow whose tail happens to brush the trigger arrow but whose head is 4 cells away is NOT a domino — it just got lucky on geometry. The head must have been the thing pressed up against the trigger.

Recursive step: when a cascade arrow B exits at depth `d`, it can itself unblock further arrows at depth `d+1` — but those further arrows must satisfy the **same adjacency rule** against B's old body cells (not against the original trigger). This is what makes the chain feel like dominos pushed sequentially, not a single explosion through a corridor.

Order of resolution: by **distance from the trigger arrow's old head** (closest first). Ties broken by tier (higher first), then by id (deterministic).

### 2.3 Resolution
Each cascade arrow fires sequentially with a stagger of **220 ms** between releases. While the cascade is resolving:
- `state.inputLocked = true` (no new manual taps)
- The turn timer continues counting (does NOT pause)
- Each released cascade arrow's exit may free further arrows; those are appended to the queue at depth+1

### 2.4 Scoring
A cascade arrow scores: `tierMult(arr) × depth`

| Depth | Manual tap | Cascade #1 | Cascade #2 | Cascade #3 | Cascade #4+ |
|---|---|---|---|---|---|
| Multiplier on tier value | ×1 | ×2 | ×3 | ×4 | ×4 (capped) |

Cap at ×4 to prevent a single lucky lane from running away with the game. Worked example: legendary (5pt) hit at cascade depth 3 → `5 × 3 = 15 pt`.

### 2.5 Hard limits
With the adjacency rule from § 2.2, runaway chains are largely self-limiting (each step requires a head-adjacent neighbor, which doesn't exist that often). Soft caps kept as safety net only:
- Maximum cascade depth: **5** (after that, remaining queued arrows are discarded — they remain on the board, blocked).
- A cascade chain is interrupted if it would trigger more than **6 total arrow releases** in a single move.

In practice, expect typical cascades to land at depth 1-2 with occasional depth-3 highlight moments. Depth 5 should be rare ("oh my god" territory). If playtest shows median chain length ≥ 3, the adjacency rule may be too loose — consider also requiring head-adjacency to the *trigger arrow's head cell only* (not the whole body).

### 2.6 Refill timing
`refillBoard()` is called once at the end of the move that started the cascade, **after** the entire cascade resolves — not after each individual arrow. This means the player sees the full cascade play out on a depleting board before any new arrows spawn.

---

## § 3 — Streak rules

### 3.1 Accumulation
Streak is tracked as a float internally:
- Manual successful off-board exit: `streak += 1.0`
- Cascade off-board exit: `streak += 0.5`
- Partial slide (no exit): `streak = 0`
- Tap with `moveDist === 0` (invalid, no move consumed): no change

Streak is **floored** when compared against thresholds. So a player can reach threshold 3 via 3 manual exits, or 2 manual + 2 cascade hits (1.0 + 1.0 + 0.5 + 0.5 = 3.0).

### 3.2 Thresholds and rewards

| Streak (floored) | Reward | Banner |
|---|---|---|
| 2 | +20% pts on the player's next manual exit this turn (cascade hits ignore this) | "STREAK ×2" |
| 3 | +1 extra move on the current turn (one-shot, must be unspent) | "STREAK ×3 — +1 MOVE" |
| 4 | All off-board pts this turn (incl. queued cascades) ×2 retroactively for remaining exits | "STREAK ×4 — DOUBLE" |
| 5+ | "FIRESTORM" — remaining off-board pts this turn ×3 | "FIRESTORM ×3" |

Each threshold fires **once per turn**. A turn that hits streak 4 cannot re-trigger the "+1 move" reward by dropping back to 3 — those flags are sticky for the turn.

### 3.3 Reset
- On `switchTurn()`: both players' streak counters → 0.
- On any move that consumed a move but produced no off-board exit (partial slide).
- On match end.

### 3.4 Removal of v5 mechanic
The `greenStreakYou / greenStreakOpp` state and the 3-green-commons → +1 move rule in [tryRelease()](index-arrows-v5.html#L563-L582) are **deleted**. The new streak system covers it at threshold 3, and rewards all tiers instead of only commons (commons remain easiest to chain, so common-heavy boards still feel rewarding — but legendary exits also count, removing the perverse incentive to delay legendary releases).

---

## § 4 — Bot AI changes

`botPickAndMove()` in [v5](index-arrows-v5.html#L886) currently picks `bestScoring` (highest tier exit) or falls back to `bestSlide` (longest slide). Add a third comparator: **cascade potential**.

For each arrow A where `offBoard: true`:
1. Simulate removing A's cells from a grid copy.
2. Count how many other arrows would become `offBoard: true`.
3. Estimate cascade score: `Σ (tierMult × min(depth, 4))` for the freed set, depth bumped by chain length (cheap heuristic: assume each freed arrow frees ~0.4 more, capped at depth 3 average).

Pick by score: `arrow.tierMult + cascadePotential × 0.85`. The 0.85 weighting keeps the bot from over-committing to speculative chains — it still prefers a guaranteed high-tier exit over a marginal long-chain.

If no arrow can exit, fall back to `bestSlide` as today.

---

## § 5 — UI changes

### 5.1 Cascade banner
Reuse the existing `.bonus-banner` style. On each cascade-depth increment ≥ 1, show:
```
CASCADE ×N
+P points
```
Position: same as bonus banner. Duration: 800 ms (shorter than the current 1600 ms, because multiple may stack visually during a deep chain). Stack vertically if a new one arrives while the previous is still on-screen, offsetting by 40 px each.

### 5.2 Streak bar
Add a thin secondary bar **below** the turn timer bar in `.turn-row`. Width fills proportionally to `floor(streak) / 5`. Segmented at 2 / 3 / 4 / 5 with small tick marks. Color matches the active player's turn color (blue / red). At each threshold crossing, the bar pulses and a small inline banner appears beside the moves dots (not over the board).

### 5.3 Cascade arrow visual emphasis
During cascade resolution, each auto-firing arrow gets a brief white outline glow (0.04 stroke-width white halo on the SVG path) for the first 80 ms of its slide animation. Signals to the player "I didn't tap this — the game did". Without this, deep cascades look like the game is teleporting arrows off the board for no reason.

### 5.4 Float score color shift
At cascade depth ≥ 2, the `+N` float-score uses a gradient text effect (color → white → color) to distinguish cascade points from manual points. Optional polish, not required for first build.

---

## § 6 — Edge cases

| Case | Handling |
|---|---|
| Turn timer expires mid-cascade | Cascade completes fully, THEN `switchTurn()` runs. Streak resets on turn switch regardless. |
| Match timer expires mid-cascade | Cascade completes fully (last hurrah), then `endByTimeout()`. Final score includes cascade pts. |
| Cascade frees an arrow that is itself currently mid-slide-animation | Cannot happen — cascade resolves on grid state, not animation state. Animations run independently. |
| Player taps during cascade | Ignored (`inputLocked === true`). |
| All arrows on board cleared by one cascade | Refill runs at end of move as normal; the next turn starts on the refilled board. No special bonus for "board clear" in this patch (could be a v5.2 addition). |
| Bonus move from streak threshold 3 arrives when player has 0 moves left | Adds 1 move, turn does NOT end yet. `consumeMove()` already handles the dot count via `Math.max(MOVES_PER_TURN, state.movesLeft)`. |
| Streak threshold 3 fires while cascade is still resolving | Bonus move is granted immediately; banner shows after cascade finishes (queue the banner). |
| Tap on an arrow that becomes invalid due to in-flight cascade | Cannot happen — input locked during cascade. |

---

## § 7 — State changes

### Remove
```js
greenStreakYou: 0,
greenStreakOpp: 0,
```

### Add
```js
streakYou: 0,           // float
streakOpp: 0,           // float
streakFlagsYou: { t2:false, t3:false, t4:false, t5:false },
streakFlagsOpp: { t2:false, t3:false, t4:false, t5:false },
cascadeDepth: 0,        // 0 when idle, >0 during active cascade
cascadeQueue: [],       // [{id, depth}]
cascadeOwner: null,     // 'you' | 'opp' — who gets the points
```

Reset all of the above on `switchTurn()` (streak + flags) and `startMatch()` (everything).

---

## § 8 — Function-level changes

| Function | Change |
|---|---|
| [tryRelease()](index-arrows-v5.html#L541) | After `delete state.arrows[id]` in the `offBoard` branch, compute the freed set and call `startCascade(freed, byPlayer)`. Apply streak increment here. Apply streak threshold rewards after the increment. |
| New `startCascade(initialFreed, byPlayer)` | Initializes `state.cascadeDepth = 1`, queues initialFreed, sets `cascadeOwner`, locks input, kicks off `processCascadeStep()`. |
| New `processCascadeStep()` | Pops next arrow from queue, computes its pts at current depth, calls a stripped-down release path (no move consumption, no streak-as-manual). If exit frees more arrows, append to queue at depth+1. After 220 ms stagger, recurse. When queue empty: `state.cascadeDepth = 0; refillBoard(); state.inputLocked = false;` (or trigger turn switch if movesLeft === 0). |
| `consumeMove()` | No change to signature. Called from manual releases only — cascade releases skip it. |
| `switchTurn()` | Reset streak floats and threshold flags for the new turn's player. (Could also reset both — simpler — since the inactive player can't streak anyway.) |
| [botPickAndMove()](index-arrows-v5.html#L886) | Add cascade-potential scoring as described in §4. |
| `refillBoard()` | No change; just ensure it's called once after cascade completes, not after each cascade arrow. |
| New `updateStreakBar()` | Called on every streak change. |

---

## § 9 — Tuning knobs (constants to expose at top of script)

```js
const CASCADE_DEPTH_CAP = 4;          // multiplier cap (depth 5+ stays at ×4)
const CASCADE_HARD_LIMIT = 5;         // absolute max chain depth
const CASCADE_ARROW_LIMIT = 6;        // max total arrows per chain
const CASCADE_REQUIRE_ADJACENCY = true; // head must be 4-neighbor of trigger body
const CASCADE_STAGGER_MS = 220;       // delay between cascade releases
const STREAK_CASCADE_WEIGHT = 0.5;    // how much each cascade hit contributes
const STREAK_T2_BONUS = 0.20;         // +20% on next manual exit
const STREAK_T4_MULT = 2;             // ×2 retroactive on remaining exits
const STREAK_T5_MULT = 3;             // ×3 firestorm
```

First-build values are intentionally conservative. Once played, expect at least these to move:
- `CASCADE_DEPTH_CAP` may go to 5 if depth-4 hits feel rare.
- `CASCADE_STAGGER_MS` may drop to 160 ms if chains feel slow.
- `STREAK_CASCADE_WEIGHT` may go to 0.33 if streak fills too fast on cascade-heavy turns.

---

## § 10 — Balance risks

1. **Runaway chains.** With the adjacency rule (§ 2.2) chains are self-limiting: deep cascades require the player to deliberately stack arrows head-to-body in a domino formation. Expect typical taps to score in the 1-6 pt range with occasional 10-20 pt highlight moments and rare 30+ pt "perfect domino" turns. This is the intended Match Masters texture — most moves are flat, a few sing. If playtest shows highlight moments are TOO rare (no "wow" reactions in a 3-minute match), loosen by setting `CASCADE_REQUIRE_ADJACENCY = false`.
2. **Streak 4/5 + cascade compounding.** Streak threshold 4 (×2) stacks multiplicatively with cascade depth (×N). At streak 4, a cascade-3 legendary scores `5 × 3 × 2 = 30 pt`. Watch this in playtest — if turns regularly close above 40 pt, drop `STREAK_T4_MULT` to 1.5 (which rounds awkwardly — alternatively switch to `+50%` flat additive on top of cascade mult).
3. **Bot dominates with chain heuristic.** Bot can "see" cascade potential perfectly while the player must read the board. If bot win rate climbs above ~55% after this patch, weight cascadePotential lower (0.5 → 0.7 of intended) or add a 1-cell lookahead noise to the bot.
4. **The 3-green removal weakens the new-player streak hook.** Old rule rewarded commons specifically — easy to read, easy to chain. New rule rewards any exit. Mitigation: streak threshold 2 (+20%) lands fast on any board, so the player still gets early feedback on turn 1.

---

## § 11 — Out of scope (not in this patch)

- Per-player arrow ownership / colored arrows. Cascade still scores for the **tapper**, regardless of who spawned the arrow.
- Board-clear bonus (clearing the whole board with one cascade). Candidate for v5.2.
- Cascade SFX / haptics — visual only for now.
- Cross-turn streak preservation. Streak intentionally resets each turn — preserving across turns turns the game into a snowball.
- Cosmetic cascade trails (particles between exiting arrows). Polish pass later.

---

## § 12 — Acceptance checklist

- [ ] Tapping an arrow that exits and unblocks exactly one other arrow triggers a cascade of length 1 with ×2 mult on that arrow.
- [ ] Tapping an arrow with no unblock effect triggers no cascade banner.
- [ ] During cascade, no manual taps are accepted.
- [ ] Streak counter increments on cascade hits at the documented weight (0.5).
- [ ] Streak resets to 0 on partial slide.
- [ ] Streak resets to 0 on turn switch.
- [ ] Bonus move from streak threshold 3 is visible in the moves-dots row immediately.
- [ ] Bot occasionally picks a lower-tier arrow when it would start a bigger cascade.
- [ ] Cap at depth 6 / 8 arrows prevents the game from freezing during pathological chains.
- [ ] Removing the old `greenStreakYou/Opp` does not regress: a 3-commons-in-a-row turn still rewards (now via streak threshold 3 instead of green-specific).
