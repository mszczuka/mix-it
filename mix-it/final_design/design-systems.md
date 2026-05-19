# Mix-It — Systems Design

Matchmaking, stakes wager flow, coin economy, defeat UX, time investment math, bot AI, persistence model, FTUE.

For in-match rules see [design-match.md](design-match.md). For arena progression see [design-progression.md](design-progression.md). For booster details see [design-boosters.md](design-boosters.md).

---

## 1. Matchmaking

### Search bands

| Stage                | Trophy band | Arena band | Stake | Bot allowed |
|----------------------|-------------|------------|-------|-------------|
| 0–15 s (primary)     | ±100        | same arena | same stake | no |
| 15–30 s (widen)      | ±200        | ±1 arena   | same stake | no |
| 30 s+ (fallback)     | any         | any        | same stake | yes (bot pool) |

The bot pool is **invisible to the player** — no "you're playing a bot" indicator. Bot quality is configured to match the player's rolling win rate (target 50%).

### Per-stake pools

Each stake level (×1 / ×2 / ×3 / ×4) has a **separate matchmaking pool**. A player searching at ×3 only matches another ×3 player or a same-stake bot. Mixing stakes would break the symmetric-risk premise.

Higher-stake pools are thinner. ×4 in particular may resolve to bot matches almost always — accepted by design (high-stake players opt in to the variance).

### Cross-arena scaling — how it lands

Cross-arena trophy scaling (win × 0.5, loss × 0.25 at +1 arena; win × 0.25, loss × 0.10 at +2) fires whenever matchmaking pairs the player with an adjacent-arena opponent. The ±100 / ±200 band interacts with arena floor gaps:

- **Early ladder (arenas 1–3):** floor gaps are 100–150 trophies. ±100 band frequently crosses boundaries; scaling fires often.
- **Late ladder (arenas 11–14):** floor gaps are 500–700 trophies. ±100 band stays within one arena; scaling rarely fires.

This asymmetry is intentional and acceptable.

### Recovery pool

A silent matchmaking intervention for stuck players. See [design-progression.md §3](design-progression.md). Trigger: 20 consecutive losses at arena floor. Exit: 10 matches or 3 wins (whichever first). The trophy formula is unchanged during recovery pool; only opponent selection changes.

---

## 2. Stakes wager flow

Stakes unlock at Arena 8 (Cocktail Lounge). Below Arena 8, only ×1 is available and the stake selector UI is hidden.

Stakes follow the **Match Masters model: pure trophy-and-coin multiplier, no coin entry fee.** The player wagers in the currency of identity (trophies). Coin payouts amplify on win as bonus upside.

### UI flow

1. Player taps **Play** on Home
2. Stake selector appears with four options: **×1 / ×2 / ×3 / ×4**
3. Each stake shows the resulting trophy/coin range so the player sees the upside and downside
4. Player selects a stake. **No coins are debited.**
5. Matchmaking begins on the chosen stake's pool

### Payout

| Outcome | Trophies                                  | Coins                                  |
|---------|-------------------------------------------|----------------------------------------|
| Win     | win_base × stake × on_fire                | coin_win × stake × on_fire             |
| Draw    | 0                                         | coin_draw × stake                      |
| Loss    | loss_base × stake                         | 0                                      |

- The stake multiplier applies symmetrically to trophy *win* and *loss* — wagering trophies in both directions
- The stake also amplifies coin payout on win and draw (matching the trophy stake — high-stake play is more lucrative when it works)
- A loss never costs coins at the match layer (consistent with the no-stake-fee rule below)
- On Fire (×2) applies on wins only, after the stake multiplier

### Per-stake matchmaking pools

Each stake level has a separate matchmaking pool. A ×3 search matches another ×3 player or a same-stake bot. Mixing stakes would break the symmetric-risk premise.

Higher-stake pools are thinner. ×4 in particular may resolve to bot matches almost always — accepted by design (high-stake players opt in to the variance).

### Downgrade / cancel

If no opponent is found at the chosen stake within 30 s, the player is offered:

- **Downgrade to ×1** — search continues on the ×1 pool
- **Keep waiting** — search continues on the original stake
- **Cancel** — return to Home

Since there is no coin entry fee, no refund logic is needed. Cancel / downgrade is friction-free.

---

## 3. Coin payouts per arena

Coins are awarded on every match result. The base coin payout scales by arena.

| Arena             | Win | Loss | Draw |
|-------------------|----:|-----:|-----:|
| Juice Stand       | 20  | 8    | 15   |
| Lemonade Stand    | 25  | 10   | 18   |
| Smoothie Bar      | 30  | 12   | 20   |
| Boba Tea          | 35  | 14   | 22   |
| Coffee House      | 40  | 15   | 25   |
| Tea Garden        | 45  | 17   | 27   |
| Iced Café         | 50  | 19   | 30   |
| Cocktail Lounge   | 55  | 22   | 32   |
| Tiki Bar          | 60  | 25   | 35   |
| Wine Cellar       | 65  | 28   | 38   |
| Whiskey Den       | 72  | 30   | 40   |
| Champagne Room    | 80  | 33   | 43   |
| Penthouse Bar     | 85  | 37   | 47   |
| Grand Hotel       | 90  | 40   | 50   |

These values multiply by stake (×N for ×N stakes) and by On Fire (×2 on wins only).

### Coin sinks

- Booster shop (50 / 150 / 400 coins per tier)

No other coin sinks exist in this design. Coins are the only currency. Stakes do **not** consume coins on entry (see §2).

---

## 4. Result screen

After every match (win, loss, draw), the player sees a rich summary screen with sequentially-revealed reward rows and progression notes. The screen is the player's main feedback loop and the primary place where meta progression "lands" emotionally.

### Header

| Outcome | Header text |
|---------|-------------|
| Win     | **VICTORY** (gold/green) |
| Loss    | **DEFEAT** (red) |
| Draw    | **DRAW** (neutral) |

The framing is direct — "DEFEAT" is fine, players understand the genre. No softening.

### Sub-header

`vs. [opponent name] — [your score] to [their score]`

The opponent name is tappable and opens the opponent's public profile (basic stats — owned by a separate profile spec).

### Match stats row

One row above the rewards block:

`🍹 [N] served · [M]× combo`

Where N = drinks served by the player and M = best combo achieved in the match.

### Rewards block (sequentially animated)

Each row reveals with a ~180 ms stagger. The order:

1. **Trophies** — `+N 🏆` (green) or `−N 🏆` (red). Stake suffix shown when applicable: `(×3 stake)`.
2. **Coins** — `+N 🪙` with a breakdown text: `[Arena] base [X] × [stake] stake × [On Fire]`.
3. **Stars** — `+N ⭐` with the weekly total: `(Star Race [Arena]: [W]★ this week)`.
4. **On Fire** (gold, only when triggered) — `×2 applied`.
5. **Stake** (only when stake > ×1) — `Stake ×N: trophy and coin payouts multiplied`.

### Notes block (sequentially animated, after rewards)

Notes appear only when relevant — empty rows are skipped. Order (each delayed ~250 ms after the previous):

1. **Trophy Road milestone ready** — `📍 Trophy Road: Milestone [N] ready to claim — [reward]`
2. **Star Race tier achievement** — `🥇 Star Race: [Tier] tier in [Arena] ([W]★)` where tier ∈ {Top 10, Top 100, Top 500, Participation}
3. **Daily missions progress** — `✅ Daily Missions: [n]/3` (or `Daily Bonus claimed` if all 3 done)
4. **On Fire activated for next match** — `🔥 Next match: On Fire — 2× trophies & coins`
5. **Arena promotion** (win only, when trophies crossed a new floor this match) — `⬆️ Promoted to [Arena name]!`

### CTAs

- **Primary:** "Play Again" — re-enters matchmaking at the same stake
- **Secondary:** "Home" — returns to Home

### Forced beat

The Play Again button is disabled for a moment after the result screen opens:

- **Loss:** 2 seconds (gives the player time to feel the cost before rage-clicking into the next match)
- **Win / Draw:** 1 second (smaller pause; not rage-quit prevention, just letting the rewards finish their animation)

The disabled button is visibly greyed out so the player sees the pause is intentional, not a bug.

### Tilt economics — silent interventions on losing streaks

Independent of the result screen. Both intervene without surfacing to the UI. Players who notice the pattern read it as luck.

| Streak | Intervention |
|--------|--------------|
| 3 consecutive losses | Next match: matchmaking widens trophy band by 50% — potentially weaker opponents |
| 5 consecutive losses | The easiest active daily mission ticks +1 progress as silent compensation for variance |
| 20 consecutive losses at arena floor | Enter recovery pool (see §1) |

---

## 5. Time investment math

The single most important number in this design — how long does the ladder take.

### Climb to Grand Hotel at 50% WR

| Range                | Trophies      | Net @ 50% | Matches |
|----------------------|---------------|-----------|---------|
| Juice → Smoothie     | 0 → 250       | +5.0      | 50      |
| Smoothie → Coffee    | 250 → 600     | +4.7 avg  | 75      |
| Coffee → Iced Café   | 600 → 1,100   | +4.2 avg  | 119     |
| Iced Café → Tiki     | 1,100 → 1,750 | +3.5 avg  | 186     |
| Tiki → Whiskey       | 1,750 → 2,600 | +3.0 avg  | 283     |
| Whiskey → Penthouse  | 2,600 → 3,700 | +2.5 avg  | 440     |
| Penthouse → Grand    | 3,700 → 4,400 | +2.5      | 280     |
| **Total**            | **0 → 4,400** | —         | **~1,430 matches** |

### Real time per match

- Active match: ~80 s gameplay + ~15 s result/transition = 95 s
- Matchmaking overhead: ~10 s
- **Per match total: ~105 seconds ≈ 1.75 minutes**

**~1,430 matches × 1.75 min ≈ 42 hours of screen time to reach Grand Hotel at exactly 50% WR.**

### Time horizons by player profile

| Profile                   | Play volume                  | Time to Grand Hotel |
|---------------------------|------------------------------|---------------------|
| Casual (15 min/day)        | ~8 matches/day               | ~6 months           |
| Engaged (30 min/day)       | ~115 matches/week            | ~3 months           |
| Heavy (60 min/day)         | ~240 matches/week            | ~6 weeks            |
| Skilled & heavy (60% WR)   | same volume, +6.5 net/match  | ~3 weeks            |

The ladder is sized for approximately **three months of engaged play to reach the top**.

---

## 6. Bot AI

Bots fill matchmaking when human opponents are unavailable (low population, mismatched stake, high-arena thinness). Bots are configured to feel like real opponents — same UI presentation, no indicator.

### Per-arena tuning

The bot's behaviour is controlled by four parameters, scaled by arena:

| Parameter             | Juice  | Smoothie | Coffee | Tea/Cocktail | Wine/Champagne | Grand |
|-----------------------|-------:|---------:|-------:|-------------:|---------------:|------:|
| Base serve interval   | 1.80 s | 1.75 s   | 1.70 s | 1.65 / 1.60  | 1.55 / 1.50    | 1.45 s |
| Cushion multiplier    | 1.55   | 1.50     | 1.45   | 1.40 / 1.35  | 1.30 / 1.25    | 1.20  |
| Mistake rate          | 3%     | 3%       | 3%     | 3%           | 3%             | 3%    |
| Target player WR      | 70%    | 65%      | 60%    | 55% / 50%    | 50%            | 50%   |

Mapping these arena buckets onto the 14-arena ladder uses the closest-by-color count match. Interpolation between arenas is acceptable.

### Behaviour

- **Serve interval:** the average time between bot serves. The bot uses this as a target rate — actual serves trigger when a bottle becomes servable and a matching customer exists.
- **Cushion multiplier:** when the bot is **behind** the player in score, it slows down (interval × cushion); when **ahead**, it stays at base. This creates artificial drama — close losses, comeback feel.
- **Mistake rate:** 3% chance per move to make a suboptimal pour (deliberate skill leak).
- **Target player win rate:** the bot's overall difficulty target. The early arenas favour the player (70% → 50%) to absorb skill onboarding without crushing new players.

### Bot decision making

The bot uses a heuristic pour scorer: each valid pour gets a score based on whether it (a) matches an existing color top, (b) empties a source bottle, (c) completes a monochrome bottle. Higher score = better pour. The bot picks the highest-score pour each turn, modulo the mistake rate.

The bot does not use boosters in this design.

---

## 7. Persistence model

What's saved between sessions, in player profile state:

| Field                    | Persistence | Notes |
|--------------------------|-------------|-------|
| Trophies                 | local + server (when online) | Single integer; clamped to current arena floor on save |
| Coins                    | local + server | Single integer |
| Booster inventory        | local + server | One count per booster ID; stackable |
| Current arena            | derived from trophies | Computed on load, not stored |
| Daily mission state      | local + server | 3 mission instances with current progress; reset at local midnight |
| Star Race state          | local + server | Current week stars total, leaderboard bucket assignment, last week payout claimed flag |
| Trophy Road milestones   | local + server | Bitmask or list of claimed milestone IDs |
| FTUE state               | local | Which onboarding step the player has completed |
| Session win streak       | runtime only | On Fire eligibility — reset on session start |
| Match history (last N)   | local | Last 20 matches for tilt detection (used by silent interventions) |
| Stake selection          | local | Last-used stake, defaults to ×1 |

### Server authority

Server is the source of truth for trophies, coins, booster inventory, Trophy Road milestones, daily missions, Star Race. Local cache is read-through; offline play is permitted but writes queue to server on reconnect.

Conflict resolution on reconnect: **server wins** for trophies, coins, milestone claims. Local-only state (FTUE, last stake, match history) is never sent to the server.

---

## 8. FTUE

First-time user experience runs as **four guided steps**. Each step introduces exactly one new concept and gates the next. The 4-step structure was validated against a playable prototype (`ftue-prototype.html`).

### Pedagogical principle

One new concept per step:
- **M1:** how to pour layers between bottles + auto-serve
- **M2:** how to use the spawn button to bring fresh layers in
- **M3:** how customer patience works + walkaway penalty
- **M4:** how a real PvP match feels with a shared queue and a live opponent

### M1 — Pouring + auto-serve

| Field | Value |
|---|---|
| Board | **3 bottles** (smaller than real Juice — minimal scenario): `[red, red]`, `[red, red]`, `[]` |
| Customers visible | **1**, color = red, no patience timer |
| Spawn button | **Hidden** |
| Match timer | **None** |
| Completion | The single customer is auto-served (one pour fills a bottle to 4 reds → auto-serves) |
| Failure state | None — board is set up so the only valid pour completes the serve |

**Tooltips:**
- On entry: *"Tap a bottle, then tap another to pour. Match 4 same-color layers to serve."*
- After first serve: *"Nice. That bottle held 4 reds matching the customer's order → it served automatically."*

### M2 — Spawn

| Field | Value |
|---|---|
| Board | **5 bottles** (Juice config — 3 source + 2 empty): `[blue]`, `[]`, `[]`, `[]`, `[]` |
| Customers visible | **1**, color = blue, no patience timer |
| Spawn button | **Visible**, forced color = blue (always blue regardless of who's in queue) |
| Spawn charges | Start 5, max 12, recharge 1 s/charge (per §11 below) |
| Match timer | **None** |
| Completion | Player serves the single blue customer (typically 3 spawn taps + 1 starting layer = 4 blue → auto-serve) |
| Failure state | None |

**Tooltips:**
- On entry: *"Tap the spawn button to add a colored layer to a bottle. Fill 4 same colors to auto-serve."*
- After spawn used: *"Nice pour! In real matches, spawn keeps fresh layers coming so you never run out."*

### M3 — Patience + walkaway

| Field | Value |
|---|---|
| Board | **5 bottles** (Juice config), source bottles pre-filled with mixed colors |
| Customers visible | **3** (red / blue / yellow), patience = 24 s each |
| Spawn pool | **Empty** — no additional customers spawn after the starting 3 |
| Spawn button | **Visible**, color = `auto` (matches the lowest-patience customer in the queue) |
| Match timer | **None** — M3 has no global timer |
| Completion | The visible customer queue empties — every starting customer has either been served or walked away. No spawn pool means once these 3 are gone, the step ends. |
| Walkaway demo | When a customer's patience hits 0, that customer leaves and the player loses 25 points. First walkaway in M3 triggers a one-time toast: *"A customer left — you (and your opponent in real matches) lose 25 points. Keep serving!"* |
| Failure state | None — walkaways are part of the lesson, not a fail. Step still completes when queue empties. |

### M4 — First bot match

| Field | Value |
|---|---|
| Board | **5 bottles** (Juice config), player + opponent boards visible (opponent board scaled down, non-interactive) |
| Customers | **Shared queue, 3 visible**, random colors, patience = 24 s, spawn pool with continuous replacement during the match |
| Spawn button | **Visible**, color = `random` (random pick from the active 3-color palette — same as real game) |
| Match timer | **60 seconds** — shorter than a real Juice match (90 s) to keep FTUE compact |
| Opponent | Bot tuned to Juice difficulty (base interval 1.80 s, cushion 1.55 when behind, 3% mistake rate, target player WR 70%) |
| Completion | Timer expires. Win / loss / draw — all three outcomes complete M4. |
| Failure state | A loss does not fail M4. The player is shown the result and proceeds. |

After M4 completes, FTUE is done. The player is dropped into the normal Home flow and receives the **starter pair**: Extra Bottle + Mise en Place (equivalent to Trophy Road milestone #1).

### Completion criteria summary

| Step | Trigger to finish step |
|------|------------------------|
| M1   | One customer served |
| M2   | One customer served (using spawn) |
| M3   | All starting customers handled (served OR walked away) |
| M4   | 60 s timer expires (any match outcome) |

### Save points and restart

- FTUE state is **saved between steps, not within steps.** If the player closes the app mid-step, the step restarts from the beginning on reopen.
- Persisted flag: `LastCompletedFtueStep ∈ {none, M1, M2, M3, M4}`. After `M4` → flag flips to `done`.
- The next-step button on the success popup has a forced beat (1 s for success, 2 s for a loss in M4) before enabling, to prevent rage-click skipping.

### FTUE rules

- FTUE cannot be skipped on a fresh account
- FTUE state is **local-only** — reinstalling the app re-runs FTUE
- During FTUE, no trophies, coins, or Trophy Road milestones are awarded
- FTUE matches do not use boosters
- FTUE M4 does **not** count toward the session win-streak (On Fire eligibility starts with the player's first non-FTUE match)
- FTUE M4 uses a scripted-difficulty bot (Juice tuning), not full matchmaking

---

## 9. HUD elements (rule layer, not visual spec)

What's on screen during a match (rules — visual spec owned by polish doc):

| Element                          | Source of truth | Updates |
|----------------------------------|-----------------|---------|
| Match timer                      | MatchClock      | Continuous |
| Player score / Opponent score    | MatchState      | On each serve / walkaway |
| Shared customer queue (3 slots)  | CustomerQueue   | On serve / walkaway / spawn |
| Player bottle board              | Player Glass[]  | On pour / booster |
| Opponent bottle board            | Opponent Glass[] | On opponent pour (animated as the bot/player serves) |
| Booster slots (3, with icons)    | Equipped boosters | Bronze fades on match start (passively applied); silver/gold tappable until used |
| Combo callout                    | MatchState.ComboCount | On serve when combo > 1 |
| On Fire flame                    | Session streak  | Active for entire match if player entered match with On Fire eligible |
| Walkaway pulse                   | MatchState.ApplyWalkaway | On each walkaway |

Both players see both score totals continuously. There is no hidden information.
