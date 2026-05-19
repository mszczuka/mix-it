# Mix-It — Match Design

In-match rules. Match config, color palette, starting state, pour mechanics, customer queue, scoring, auto-serve, match end. For meta progression and boosters see companion docs.

---

## 1. Match config

| Parameter             | Value | Notes |
|-----------------------|------:|-------|
| Match duration        | 90 s  | Real-time, identical for both players |
| Pre-match countdown   | 3 s   | Both boards visible during countdown, no input |
| Glass (bottle) capacity | 4 layers | Constant across all arenas |
| Warning threshold     | 15 s remaining | Visual cue (timer flash / SFX) |
| Players per match     | 2     | One player + one opponent (human or bot) |
| Boards per match      | 2     | Both visible to both players in real time |
| Customer queue        | 1 (shared) | Both players race for the same customers |

Per-arena board sizing (color count, source bottle count, empty bottle count) is in [design-progression.md](design-progression.md).

---

## 2. Color palette

Eight canonical colors. Arenas use a prefix of this list — Arena 1 uses the first 3 (Red, Blue, Yellow); Grand Hotel uses all 8.

| Order | Color  | Use from arena |
|-------|--------|----------------|
| 1     | Red    | 1 |
| 2     | Blue   | 1 |
| 3     | Yellow | 1 |
| 4     | Green  | 4 (Boba Tea) |
| 5     | Purple | 6 (Tea Garden) |
| 6     | Orange | 9 (Tiki Bar) |
| 7     | Pink   | 12 (Champagne Room) |
| 8     | Teal   | 14 (Grand Hotel) |

Exact RGB values are owned by the art / theme spec, not this doc. Colors must pass colorblind simulation and sub-300ms peripheral recognition on the smallest supported device, especially the 8th-color (Teal) introduction at Grand Hotel.

---

## 3. Starting state rule

At match start, **every source bottle contains 4 layers of mixed colors**. The starting layout generator must guarantee:

- No bottle is **monochrome** (all same color)
- No bottle is **auto-servable** in frame 0
- Each source bottle's stack contains at least 2 distinct colors when palette size permits

Empty bottles start empty. Source bottles start full (4 layers, mixed).

This rule is **non-negotiable by any booster**. Boosters that affect match start must operate on the customer queue, the timer, scoring, or grant extra empty bottles — never on the entropy of source bottles.

---

## 4. Pour mechanics

### Pour validity

A pour from bottle A → bottle B is valid if and only if:

1. A is **not empty**
2. B is **not full**
3. Either **B is empty**, OR **B's top layer color equals A's top layer color**

### Pour resolution (cascading)

A valid pour is **greedy**: it transfers **all consecutive top layers of A's top color** to B, limited by B's free capacity. Pour stops when:

- A becomes empty, OR
- A's top color changes (a different color is exposed), OR
- B becomes full

### Bottle states

| State        | Definition |
|--------------|------------|
| Empty        | 0 layers |
| Full         | 4 layers |
| Monochrome   | All layers same color (any layer count > 0) |
| Servable     | Full AND monochrome |
| Mixed        | Layers of more than one color (any non-monochrome non-empty bottle) |

A servable bottle auto-serves immediately if there is a matching waiting customer (see §6).

### Source bottles do not refill on their own

When a source bottle is emptied (either by pouring out or by clear-bottle booster), it stays empty unless the player uses the spawn button (see §5) to push a new layer into it. The board's bottle count is fixed at match start; only the contents flow.

---

## 5. Spawn

Spawn is the mechanic that keeps fresh layers entering the board during the 90-second match. Without it, the starting layer pool would run out after a few serves and the match would stall.

### Charges, not cooldown

Spawn is **charge-based**. Each match, the player has a stock of spawn charges that recharges over time.

| Parameter            | Value | Notes |
|----------------------|------:|-------|
| Starting charges     | 5     | At match start (both players, both bots) |
| Max charges          | 12    | Charges accumulate up to this cap |
| Recharge time        | 1 s   | One charge added per second, capped at max |

Tapping the spawn button consumes **1 charge**. If the player has 0 charges, the button is disabled until the recharge timer pushes the count back up.

The recharge timer **always ticks**, even when at max charges (where additional ticks are a no-op). This means a player who never uses spawn still has 12 charges available, just unused.

### Spawn target — auto-pick, no player choice

When the player taps spawn, the layer is added to one of the player's bottles automatically. The player does not pick the target. The rule, in priority order:

1. **A non-full bottle whose top color matches the spawn color** (extends an existing same-color stack). If multiple, take the leftmost.
2. **The first empty bottle** (leftmost).
3. **Any non-full bottle** (leftmost).

If every bottle is full, the spawn tap is silently rejected (no charge consumed). This is rare but possible mid-match.

### Spawn color — fully random, no preview

Each spawn drops **one layer of one color**. The color is picked **uniformly at random from the active arena palette** at the moment the player taps the button:

- Arena 1 (3 colors): random from {Red, Blue, Yellow}
- Arena 4 (4 colors): random from {Red, Blue, Yellow, Green}
- ...
- Arena 14 (8 colors): random from the full 8-color palette

**The spawn button does not preview the next color.** The roll happens at tap time and the result lands on the board immediately. This means every spawn is a small risk-versus-reward decision: do I tap now (and live with whatever color shows up), or wait for a better board state where any color helps?

The randomness is the design's main pacing mechanism — the player cannot perfectly plan ahead, which keeps the 90-second loop alive even at high skill.

### Auto-serve after spawn

If a spawn tap fills a bottle to 4 same-color layers AND a matching customer is waiting in the shared queue, **auto-serve fires immediately** — same rule as for manual pours (see §6).

### Spawn during the FTUE

The FTUE introduces spawn in M2 with a forced color (always blue) so the lesson is unambiguous. In M3 the spawn color is auto-derived from the lowest-patience customer (a tutorial convenience to keep the lesson focused on patience and walkaway). In M4 spawn returns to its real-game behavior: random from palette. See [design-systems.md §8](design-systems.md) for full FTUE spec.

---

## 6. Customer queue

### Shared between both players

The customer queue is **a single shared queue visible to both players**. Both players see the same customers in the same order. Either player can serve any customer.

When a customer is served by one player, they're marked **served by that player** but remain in the queue until either (a) the other player also serves them, or (b) the grace window expires. A served customer cannot be served again by the same player.

### Visible slots

**Exactly 3 customers are visible at any time.** This is fixed. No booster, no arena, no event can extend the visible queue beyond 3.

When a visible slot empties (customer served-out or walked away), the next customer from the spawn buffer steps forward.

### Customer parameters

| Parameter           | Value | Notes |
|---------------------|------:|-------|
| Default patience    | 24 s  | How long a customer waits before walking away |
| Grace window        | 2 s   | After one player serves, the customer stays visible 2s more (the other player can still serve it) |
| Spawn recharge time | 1 s   | A new customer is added to the spawn buffer every 1 s |
| Max queue size      | 12    | Buffer hard cap |
| Pre-charged buffer  | 5     | At match start, 5 customers are pre-loaded in the spawn buffer |

### Customer color spawn (weighted)

When a new customer is generated, the color order is picked by a **70/30 weighted RNG**:

- **70%:** pick a color **proportionally to the layers currently present on the boards** (both players' boards counted together). Common colors → common orders.
- **30%:** pick a fully random color from the active palette.

If no colors are present on the boards (e.g., all bottles empty), fall back to pure random.

This rule prevents the game from spawning customers that no board can serve (e.g., asking for a color absent from the current pool).

### Walkaway penalty

If a customer's patience timer reaches 0 without being served by either player:

- The customer leaves
- **Both players lose −25 points** (the penalty is mutual — the game punishes the queue not being serviced)
- The slot is replaced by the next customer from the buffer

---

## 7. Auto-serve

### Trigger

The moment a bottle becomes **servable** (full AND monochrome), the game searches the visible queue for a customer matching the bottle's color who has not yet been served by the bottle's owner. If found:

1. Mark the customer as served by that player
2. Award points (see §7)
3. Empty the bottle
4. Arm the customer's grace window (2 s)

### Target selection

When multiple visible customers match the bottle's color, the system selects the customer with the **lowest remaining patience** (closest to walking away). The player has no manual override.

### A servable bottle with no matching customer

The bottle holds in "ready" state. The moment a matching customer arrives in a visible slot (either spawned or stepped forward from the buffer), auto-serve fires.

The player may choose to free the slot using the Clear Bottle booster (see [design-boosters.md](design-boosters.md)).

### Multiple bottles complete in the same frame

All servable bottles serve simultaneously, each picking the lowest-patience matching customer for the bottle's owner. If two of the player's bottles match the same single customer, only one bottle serves that customer; the other holds.

---

## 8. Scoring

### Per-serve point award

```
points = (layer_count × 50)
       + (speed_bonus if unopposed)
       + (combo_count × 50 if within combo window)
```

| Component         | Value | When |
|-------------------|-------|------|
| Per-layer base    | 50 points × 4 layers = **200** | Every successful serve |
| Speed bonus       | +50 | If this player serves BEFORE the opponent serves the same customer (unopposed) |
| Combo bonus       | +50 × combo count | Combo count is the running streak of this player's serves within 10 s of each other |
| Combo window      | 10 s | Time between serves; if exceeded, combo count resets to 0 |

### Combo system

- The first serve in a match (or after a combo break) starts with combo count **1**, contributes **0 bonus**, and arms the combo timer.
- The second serve within 10 s of the first: combo count becomes **2**, bonus = **+100**.
- The third serve within 10 s of the second: combo count **3**, bonus = **+150**.
- ...and so on. Bonus uses the *new* combo count, not the previous one.

If 10 s elapse between serves, combo count resets. The opponent serving does **not** break the player's combo (each player has their own combo).

### Walkaway penalty

When a customer walks away without being served by either player, **both players lose −25 points**. This applies regardless of who was "closer" to serving — the game treats unserved customers as a shared failure.

### On Fire

`On Fire` is a **session-streak multiplier applied at match end**, not a per-serve scoring effect.

- **Trigger:** the player has won 3+ matches in a row in the current session
- **Effect at match end:** if the player wins this match, trophy and coin rewards are multiplied ×2
- **Reset:** any loss, or session end
- **Never applied to losses:** a player on On Fire who loses suffers normal loss values, not ×2

### Final match score

Each player's final score = sum of all per-serve points minus 25 × number of walkaways during the match. Scores can be negative if walkaways outpace serves.

---

## 9. Match end conditions

The match ends when the 90-second timer reaches 0. At that moment:

| Condition                       | Outcome |
|---------------------------------|---------|
| Player score > Opponent score   | Player wins |
| Player score < Opponent score   | Player loses |
| Player score == Opponent score  | Draw |
| Both scores ≤ 0 (rare)          | Draw |

The match has **no early-termination win condition**. Players cannot "score out" or knock the opponent out before the timer.

### Forfeit / disconnect

If the player closes the app or disconnects mid-match, the match is **counted as a loss for the player**. The opponent receives a win. Trophy and coin movements apply normally. There is no grace return-window.

---

## 10. Booster effects in-match

Boosters affect the match in specific, scoped ways. Full booster definitions live in [design-boosters.md](design-boosters.md). The match-side spec for each booster's interaction with this doc's rules:

| Booster         | Affects |
|-----------------|---------|
| Extra Bottle    | Adds 1 empty bottle to the player's board at match start |
| Mise en Place   | Adds +10 s to the first customer's patience timer at match start |
| Combo Primer    | Sets the player's combo timer to 10 s at match start, so the first serve qualifies as combo count 2 (+50 bonus) |
| Color Splash    | Recolors the top contiguous monochrome segment of a chosen bottle (up to 2 layers) to a chosen color. Does not pour. |
| Tube Sort       | Iterates the player's bottles; pops top layers matching a chosen color; pushes them onto a chosen target bottle up to capacity |
| Customer Lock   | Freezes the patience timer of one customer in slot 0 of the shared queue for 8 s. During lock, that customer's patience does not tick down. |
| Clear Bottle    | Empties one of the player's bottles instantly. Layers are discarded. |
| Bottle Lock     | Locks one of the opponent's bottles for 10 s — opponent cannot pour to or from it. Contents preserved. |
| Time Freeze    | Pauses the opponent's match timer for 5 s. The opponent's customers continue to age (shared queue ticks normally) but the opponent's score window shrinks. |

### Booster rules with the shared queue

- **Customer Lock targets the shared queue.** Locking customer slot 0 prevents *anyone* from losing that customer to walkaway for 8 s. The player gains by buying themselves time on a customer they want to serve; the opponent loses if they wanted that customer too.
- **Time Freeze does not pause the shared customer queue.** Only the opponent's *timer* freezes. Customers continue to age out, walkaways continue to penalize both players, and the player can keep serving.
- **Bottle Lock affects only the opponent's board**, not the queue.

---

## 11. Match flow

```
Home
 → tap Play
 → select stake (×1 / ×2 / ×3 / ×4)
 → matchmaking (see design-systems.md)
 → 3 s countdown (both boards visible, no input)
 → 90 s match (auto-serve runs)
 → result screen (see design-systems.md)
 → Play Again (re-enter matchmaking) or Home
```

All visual feedback (serve animations, particle effects, combo callouts, On Fire flame, opponent's serve highlights) is owned by the polish spec, not this doc. This doc spec'es what happens; the polish spec spec'es what it looks like.
