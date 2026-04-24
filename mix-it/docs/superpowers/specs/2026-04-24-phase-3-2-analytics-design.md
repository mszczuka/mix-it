# Phase 3.2 — Analytics Event Bus Design

**Date:** 2026-04-24
**Parent:** Phase 3 decomposition.

## 1. Goal

Cross-cutting event dispatch so later systems (Shop, BP, TR, FTUE) can emit structured telemetry without coupling to each other. Phase 3.2 ships local-only sink (`Debug.Log` + in-memory buffer). Network sink deferred to Phase 6.

## 2. Non-goals

- Network/HTTP sink
- Event schema validation
- Sampling / rate-limiting

## 3. Contract

```csharp
public interface IAnalyticsService
{
    void Track(string eventName, IReadOnlyDictionary<string, object> parameters = null);
    IReadOnlyList<AnalyticsEvent> RecentEvents { get; } // for tests + debug
}

public sealed record AnalyticsEvent(string Name, DateTimeOffset At, IReadOnlyDictionary<string, object> Parameters);
```

## 4. Implementation

`LoggingAnalyticsService`:
- In-memory ring buffer (last 100 events)
- Calls `UnityEngine.Debug.Log($"[analytics] {name} {params}")`
- Thread-safe via lock (Unity main thread only in practice, lock is future-proofing)

## 5. Hook points

- `FlowController.RequestMatch` → `match_requested` (opponent_name, opponent_trophies, arena_id)
- `FlowController.CompleteMatch` → `match_ended` (win, score, rating_delta, gold_reward)
- `RatingService.ApplyWin/Loss/Draw` — not emitted directly (FlowController wrapper suffices)
- `WalletService` — not instrumented (too noisy for Phase 3)

## 6. Tests

- Track stores event with name + params
- Buffer caps at 100
- Null params handled
- `RecentEvents` read-only

## 7. Architecture

Files:
- `_Archetype/Contracts/IAnalyticsService.cs`
- `_Archetype/Contracts/AnalyticsEvent.cs` (record)
- `_Archetype/Runtime/LoggingAnalyticsService.cs`
- `_Archetype/Runtime/FlowController.cs` (modify — inject IAnalyticsService, emit events)
- `_Game/Bootstrap/GameLifetimeScope.cs` (modify — register)
- `_Tests/EditMode/AnalyticsTests.cs`

## 8. Acceptance

- IAnalyticsService registered and injected into FlowController
- ~5 new tests green
- Existing 68 tests still green
- Play Mode smoke shows `[analytics] match_requested` log after clicking PLAY (manual verification)
