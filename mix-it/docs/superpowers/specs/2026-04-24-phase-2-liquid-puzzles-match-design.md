# Phase 2 — Liquid Puzzles Match Design

**Date:** 2026-04-24
**Scope:** Unity port of HTML v7.x match-screen gameplay + matchmaking carousel for the Liquid Puzzles plugin.
**References:**
- `mix-it/index-v7.html` (source of truth)
- `mix-it/design-v7.0` through `design-v7.5` patch docs
- `docs/superpowers/specs/2026-04-24-unity-port-archetype-plugin-design.md` (parent spec, §Phase 2)

## 1. Goal

Deliver a playable match that feels like the HTML prototype: bartender simulator where player pours colored liquid between glasses, serves pure-color glasses to matching customers in a queue, and competes on score against a simulated opponent over 90 seconds. Ship the matchmaking avatar carousel through a shared archetype contract with a plugin-specific visual variant.

## 2. Non-Goals

Explicitly deferred to later phases:

- Boosters / perks (Phase 3)
- Multi-arena progression (juice → smoothie → coffee → tea → cocktail) — only juice arena shipped (Phase 3)
- Rating / MMR / trophies (Phase 3)
- Tutorial / FTUE match (Phase 4)
- Stake / coin economy (Phase 3)
- Customer variety beyond single persona set (Phase 3)
- Audio / music / polish animations (Phase 5–6)
- Rematch button (Phase 3+)

## 3. Core Match Loop

### 3.1 Phase state machine
- **Countdown** (3s): "3 … 2 … 1 … MIX!" overlay. Input disabled. Clock frozen.
- **Playing** (90s): Input live. Clock counts down. Customers tick. Opponent AI ticks.
- **Ended**: Winner decided by `playerScore` vs `opponentScore` at expiry (higher wins; draw → configurable tiebreak, Phase 2 treats draw as loss).

### 3.2 Board configuration (juice arena)
- 5 source glasses + 1 serve glass (player side)
- Glass capacity: 4 layers
- Palette: 8 colors (Red, Blue, Yellow, Green, Purple, Orange, Pink, Teal)
- Starting layout: 3 colors × 3 glasses filled + 2 empty (juice profile)
- Opponent side: mirrored simulated board (internal state only, not rendered glass-level in Phase 2 — just score + avatar)

### 3.3 Pour rules
`canPour(source, target)` returns true iff:
- `source.Layers.Count > 0`
- `target.Layers.Count < capacity`
- `target.Layers.Count == 0` OR `source.Top.Color == target.Top.Color`

`applyPour(source, target)`:
- Move top layer from source to target.
- Returns affected glass indices for animation.

### 3.4 Serve rules
Glass is servable iff full (layer count == capacity) AND all layers same color.

`applyServe(glassIndex)`:
1. Find first customer in visible queue (first 3) with matching order color.
2. If no match: serve rejected, no state change.
3. Compute score:
   - base = `POINTS_PER_LAYER × layerCount` (50 × 4 = 200)
   - unopposed bonus: `+SPEED_BONUS` (50) if opponent has not served this customer slot
   - combo bonus: `+COMBO_BONUS × currentCombo` (50 × n); combo increments if previous serve within 10s
4. Clear glass, advance customer queue, apply score.

### 3.5 Customer queue
- `VISIBLE_CUSTOMERS` = 3 slots
- Each customer: `color`, `patience` (24s starting), `graceWindow` (2s initial no-decay)
- Tick: patience decreases 1/s while playing. On `patience <= 0` → walkaway, −25 score penalty, advance queue.
- Spawn: `SPAWN_RECHARGE_TIME` = 1s recharge, max 12 queued, 5 pre-charged at match start.

### 3.6 Opponent AI
Single-side simulation with no rendered glasses (only score delta). AI owns a parallel board internally.

- Tick interval: `baseInterval × botCushionMult` (juice arena → 1.8s × 1.55 ≈ 2.79s)
- Each tick:
  - Roll mistake: `mistakeRate` (juice 3%) → random valid pour from candidates
  - Else: evaluate all valid pours, execute highest-scored
  - `evaluatePour(src, dst)` heuristic: +8 creates serve, +4 creates pure glass, +3 empties source, +2 matches color
  - 50% post-pour undo chance if chosen pour was low-confidence (evaluated < threshold)
- Serve check every ~2–3s: full+pure glass + matching customer → auto-serve, apply opponent score
- On opponent serve: reset player combo

### 3.7 Timer
- 90s countdown during Playing phase
- Warning threshold at 15s remaining (visual state change only)
- Expiry: transition to Ended, compute winner

### 3.8 MatchResult emission
Session returns `MatchResult(Win: playerScore > opponentScore, Score: playerScore, Telemetry: { "opp": opponentScore, "drinks": drinksServed, "combo": bestCombo })`.

## 4. Matchmaking Panel

### 4.1 Flow
Matchmaking panel shown for ~3–5s. Status transitions:
1. "Finding opponent…" (1s)
2. Carousel cycles 3 avatars (0.5s interval) — 2s
3. "Opponent found!" locks on final avatar (1s)
4. Transition to Match

### 4.2 Carousel contract
Archetype defines `IMatchIntroPresenter`:
```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IMatchIntroPresenter
    {
        UniTask Present(Transform container, CancellationToken ct);
    }
}
```

- Archetype provides `DefaultMatchIntroPresenter` (generic, text-only cycling: "Player A" → "Player B" → "Player C" → "FOUND").
- Plugin provides `LiquidPuzzlesIntroPresenter` (persona data: name + emoji + trophy stub + tagline).
- DI resolves plugin variant when active. `MatchmakingPanelView` injects `IMatchIntroPresenter`, creates intro container child, calls `Present`, awaits completion, then calls `_flow.StartMatch()`.

### 4.3 Persona data
Plugin ships `CustomerPersona` SO list (juice arena subset: ~5 personas). Each: name, emoji, tagline, stub trophy count.

## 5. Architecture

### 5.1 Plugin layering
```
MixIt.Plugin.LiquidPuzzles.Runtime  (asmdef: Contracts, UniTask, UGUI, TMP)
├── Model/           — pure C#, no UnityEngine deps
├── Simulation/      — pure C# + UniTask (MatchClock ticks)
├── Config/          — SO ScriptableObject definitions
└── LiquidPuzzlesPlugin, LiquidPuzzlesMatchSession  (entry points)

MixIt.Plugin.LiquidPuzzles.UI       (asmdef: …Runtime + UGUI + TMP)
├── MatchBoardView, GlassView, CustomerQueueView, MatchHudView
└── LiquidPuzzlesIntroPresenter
```

Model layer is engine-agnostic (pure C#) so it's fully EditMode-testable without Play Mode.

### 5.2 Archetype additions
```
MixIt.Archetype.Contracts
└── IMatchIntroPresenter.cs

MixIt.Archetype.Runtime
└── DefaultMatchIntroPresenter.cs
```

`MatchmakingPanelView` (existing) gains `[Inject] IMatchIntroPresenter` field and replaces the 1.5s delay with `await _intro.Present(introContainer, ct)`.

### 5.3 DI registration
`GameLifetimeScope.Configure`:
- `builder.Register<LiquidPuzzlesIntroPresenter>(Lifetime.Singleton).As<IMatchIntroPresenter>()` (plugin-owned, overrides default).
- Match session wiring unchanged — `LiquidPuzzlesMatchSession` instantiated per match via `LiquidPuzzlesPlugin.StartMatch(MatchRequest)`.

### 5.4 Data / SO assets
- `default-match-config.asset` (MatchConfig): timer=90, capacity=4, glassCount=5, colors[8]
- `arena-juice.asset` (ArenaProfile): botInterval=1.8, botCushionMult=1.55, mistakeRate=0.03, startingLayout (3×3 colors + 2 empty)
- `personas/*.asset` (CustomerPersona): 5 juice personas

### 5.5 Session orchestration
```csharp
public class LiquidPuzzlesMatchSession : IMatchSession
{
    public GameObject SceneRoot { get; } = new GameObject("LPRoot", typeof(RectTransform));

    public async UniTask<MatchResult> Run(CancellationToken ct)
    {
        var state = new MatchState(...);
        var board = new Board(config, arena);
        var opponent = new OpponentAI(board.OpponentSide, arena, seed);
        var queue = new CustomerQueue(config, seed);
        var clock = new MatchClock(90f, 3f); // 90s match + 3s countdown

        var view = InstantiateView(state, board, queue); // under SceneRoot
        await clock.RunCountdown(view, ct);
        await clock.RunMatch(state, board, opponent, queue, view, ct);
        return state.BuildResult();
    }
}
```

## 6. UI rendering

### 6.1 GlassView
Vertical stack of 4 Image layers (bottom-up). Layer colors from `MatchConfig.Palette`. Tap → emits `OnTap(index)` event. Highlight outline color via border Image.color:
- Default: dark gray
- Source-selected: blue (#9AD4FF)
- Pour-target valid: green (#4AE35F)
- Serveable (full + pure): gold

### 6.2 Pour animation (minimal)
When `applyPour` invoked:
- 0.4s UniTask coroutine
- Top layer of source fades/scales to 0
- Simultaneous top-layer spawn in target: scaleY 0→1 (ease-out-cubic)
- Glass outline pulse once

### 6.3 CustomerQueueView
Horizontal strip of 3 slots. Each slot: emoji avatar Image + color indicator + patience bar (Image fillAmount decreasing). On walkaway: fade out + slide left, next customer slides in from right.

### 6.4 MatchHudView
- Top-center: timer "M:SS" (TMP_Text, tabular nums)
- Top-left: player score
- Top-right: opponent score + avatar
- Below timer (when combo > 0): "COMBO ×N" (fade out after combo window)

### 6.5 No opponent board rendering
Phase 2 does not render opponent glasses. Score + avatar sufficient. Opponent board lives in Model only.

## 7. Test strategy

All tests EditMode, targeting Model/Simulation layer.

### 7.1 PourRulesTests
- Empty source → invalid
- Full target → invalid
- Color mismatch → invalid
- Empty target accepts any color → valid
- Matching top colors + target has room → valid

### 7.2 ServeRulesTests
- Not full → not serveable
- Full + mixed colors → not serveable
- Full + pure → serveable
- Serve scoring: base only, base+speed, base+combo, walkaway penalty

### 7.3 CustomerQueueTests
- Queue starts with 3 visible
- Patience ticks down each second
- Walkaway applies −25 penalty
- Queue advances on serve
- Spawn recharge fills queue up to max

### 7.4 OpponentAITests
- Mistake roll causes random pour
- evaluatePour returns +8 for serve-creating pour, +4 for pure-creating, +3 for empty-source, +2 for color-match
- AI picks highest scored pour
- Undo triggered on low-confidence pour (deterministic seed)

### 7.5 MatchClockTests
- Countdown runs 3s
- Match runs exactly 90s in deterministic time mode
- Warning threshold fires at 15s remaining

**Target:** 25+ new tests, existing 11 remain green → 36+ total.

## 8. Acceptance

Phase 2 done-criterion:
1. Match loop completes Home → Matchmaking (carousel) → Match (countdown → 90s play) → Result.
2. Player can pour, serve, score. Opponent simulates and scores.
3. Win/loss correctly reflected in ResultPanel.
4. Customer queue decays, walkaways penalize, combos compound.
5. All EditMode tests green.
6. Plugin asmdef still references only Contracts + UniTask + UGUI + TMP.
7. No meta-system coupling (Wallet untouched beyond existing Phase 1 reward).

## 9. Risks

- **Time budget for customer spawn + AI simulation** — targeting ~30 min of focused work per model subsystem; opponent AI is the highest-risk component due to evaluation heuristic complexity.
- **Pour animation glitches** — layer destruction/creation timing with UniTask coroutines on same frame. Mitigation: explicit event ordering (model mutation → view event → animation).
- **Customer walkaway race with serve** — serve must resolve same-frame as patience check. Mitigation: single game-loop tick order: input → opponent → customers → refresh.
- **SO asset authoring in subagent context** — subagents may not create .asset files cleanly via Unity MCP; fallback: author SO fields inline as constants for Phase 2, migrate to SO assets in Phase 3.

## 10. Open items

None gating Phase 2 start.
