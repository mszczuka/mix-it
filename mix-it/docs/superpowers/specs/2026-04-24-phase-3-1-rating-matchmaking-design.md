# Phase 3.1 — Rating + Matchmaking Design

**Date:** 2026-04-24
**Parent:** Phase 3 decomposition (`2026-04-24-phase-3-decomposition.md`)
**HTML source ref:** `index-v7.html` functions `applyMatchResult`, `pickOpponent`, `stakeMultiplier`, constants `ARENAS`, `AI_PERSONAS`, persistence key `mixit_save_v7`.

## 1. Goal

Ship a headless trophy-rating system, arena resolution, and AI-opponent matchmaking service. Introduce a unified JSON save profile that replaces the ad-hoc `PlayerPrefs.SetInt` calls in Phase 1's WalletService. Wire rating delta into `FlowController.CompleteMatch` and opponent selection into `FlowController.RequestMatch`.

## 2. Non-Goals

- UI for trophy/arena/opponent display (Phase 4)
- Stake / coin economy (covered in 3.3 Shop + 3.4 BP economy)
- On-Fire streak visualization (logic only, no UI here)
- Backend/remote rating (all local)

## 3. Data model

### 3.1 Rating state
Stored in save profile:
```
Trophies: int      (default 0, floor 0, no ceiling)
ConsecWins: int    (default 0, reset on loss)
```

### 3.2 Arena definition (static)
8 arenas, hard-coded (no SO yet — table-driven):

| Id | Name | Icon | MinTrophies | TrophyBase |
|---|---|---|---:|---:|
| juice     | Juice Stand     | 🍹 | 0    | 25 |
| smoothie  | Smoothie Bar    | 🥤 | 150  | 26 |
| coffee    | Coffee House    | ☕ | 400  | 28 |
| tea       | Tea Garden      | 🍵 | 700  | 30 |
| cocktail  | Cocktail Lounge | 🍸 | 1000 | 32 |
| wine      | Wine Cellar     | 🍷 | 1500 | 34 |
| champagne | Champagne Room  | 🥂 | 2200 | 36 |
| grand     | Grand Hotel     | 🏨 | 3200 | 38 |

### 3.3 Persona roster (static)
3–4 personas per arena, total ~24. Fields: `Name`, `Icon`, `Tagline`. Trophies are generated per-match (player ±100).

## 4. Rating math

### 4.1 Current arena
`CurrentArena(trophies) → arena` where arena is the highest-threshold arena with `MinTrophies <= trophies`.

### 4.2 Depth scaling factor
Let `playerArenaIdx = CurrentArena(trophies)`, `matchArenaIdx = arena where match happens`. For Phase 3.1 match arena = player arena always, so scale = 1.0. (Depth scaling machinery lands now; will be exercised in 3.5 Venue when player can pick arenas.)

```
ScaleFactor(playerIdx, matchIdx):
    delta = matchIdx - playerIdx
    win: delta <= 0 → 1.0 ; delta == 1 → 0.5 ; delta >= 2 → 0.25
    loss: delta <= 0 → 1.0 ; delta == 1 → 0.25 ; delta >= 2 → 0.10
```

### 4.3 Stake + OnFire multipliers (forward-compat)
```
StakeMultiplier(stakeCount) = max(1, stakeCount)
OnFireMultiplier(consecWins) = consecWins >= 2 ? 2 : 1  (win only)
```

Phase 3.1 defaults: `stakeCount = 0`, so StakeMultiplier = 1. Stake plumbing added in 3.3.

### 4.4 Apply match result
```
ApplyWin(matchArenaIdx, stakeCount):
    scale = ScaleFactor(CurrentArenaIdx, matchArenaIdx, win=true)
    base = CurrentArena.TrophyBase
    onFire = OnFireMultiplier(ConsecWins)
    delta = round(base * scale) * max(1, stakeCount) * onFire
    Trophies += delta
    ConsecWins++
    return delta

ApplyLoss(matchArenaIdx):
    scale = ScaleFactor(CurrentArenaIdx, matchArenaIdx, win=false)
    base = CurrentArena.TrophyBase
    delta = round(base * scale)
    Trophies = max(0, Trophies - delta)
    ConsecWins = 0
    return -delta

ApplyDraw():
    ConsecWins = 0
    return 0
```

## 5. Matchmaking

### 5.1 PickOpponent
```
PickOpponent(playerTrophies, arenaId, rng):
    roster = PersonaRoster.ForArena(arenaId)
    persona = roster[rng.Next(roster.Count)]
    jitter = rng.NextInt(-100, 101)
    oppTrophies = max(0, playerTrophies + jitter)
    return new OpponentProfile(persona.Name, persona.Icon, persona.Tagline, oppTrophies, arenaId)
```

Instant match. No search timeout. Rating window is purely cosmetic (opponent is always AI).

### 5.2 `OpponentProfile` record
```csharp
public record OpponentProfile(string Name, string Icon, string Tagline, int Trophies, string ArenaId);
```

## 6. Architecture

### 6.1 New files
```
_Archetype/
├── Contracts/
│   ├── IRatingService.cs           (NEW)
│   ├── IMatchmakingService.cs      (NEW)
│   ├── ISaveProfile.cs             (NEW)
│   ├── OpponentProfile.cs          (NEW — record)
│   └── ArenaInfo.cs                (NEW — record: Id, Name, Icon, MinTrophies, TrophyBase, Index)
├── Runtime/
│   ├── RatingService.cs            (NEW)
│   ├── MatchmakingService.cs       (NEW)
│   ├── ArenaTable.cs               (NEW — static table + CurrentArena/Index helpers)
│   ├── PersonaRoster.cs            (NEW — static roster + ForArena lookup)
│   ├── WalletService.cs            (REWRITE — backed by SaveProfile)
│   └── Persistence/
│       ├── SaveProfile.cs          (NEW — POCO state bag)
│       └── JsonSaveStore.cs        (NEW — disk IO via PlayerPrefs + JsonUtility)
```

### 6.2 Save profile shape
```csharp
[Serializable]
public sealed class SaveProfile
{
    public int Gold;
    public int Trophies;
    public int ConsecWins;
    // future: coins, boosters, bp tier, tr progress, etc.
}
```

Single JSON string persisted under `PlayerPrefs` key `"mixit.save.v1"` (version-bumpable). JsonUtility used (Unity-native, no dependency).

### 6.3 ISaveProfile contract
```csharp
public interface ISaveProfile
{
    SaveProfile Data { get; }       // mutable state bag
    void Save();                    // serialize + persist
    void Load();                    // deserialize from disk
}
```

Consumers (Wallet, Rating) mutate `Data` directly then call `Save()` when they want to persist. Consumers can subscribe via `event Action OnSaved` if needed later.

### 6.4 WalletService refactor
```csharp
public sealed class WalletService : IWalletService
{
    readonly ISaveProfile _profile;

    public WalletService(ISaveProfile profile) { _profile = profile; }

    public int Gold => _profile.Data.Gold;

    public void AddGold(int amount)
    {
        if (amount <= 0) return;
        _profile.Data.Gold += amount;
    }

    public bool SpendGold(int amount)
    {
        if (amount > _profile.Data.Gold) return false;
        _profile.Data.Gold -= amount;
        return true;
    }

    public void Save() => _profile.Save();
    public void Load() => _profile.Load();
}
```

Existing `WalletServiceTests` will need SaveProfile stub injected. Tests still pass logic-wise.

### 6.5 RatingService
```csharp
public sealed class RatingService : IRatingService
{
    readonly ISaveProfile _profile;
    public RatingService(ISaveProfile profile) { _profile = profile; }

    public int Trophies => _profile.Data.Trophies;
    public int ConsecWins => _profile.Data.ConsecWins;
    public ArenaInfo CurrentArena => ArenaTable.Resolve(Trophies);

    public int ApplyWin(int matchArenaIdx, int stakeCount) { ... }
    public int ApplyLoss(int matchArenaIdx) { ... }
    public void ApplyDraw() { ... }
}
```

### 6.6 MatchmakingService
```csharp
public sealed class MatchmakingService : IMatchmakingService
{
    readonly IRatingService _rating;
    readonly System.Random _rng;

    public MatchmakingService(IRatingService rating, int seed = 0)
    {
        _rating = rating;
        _rng = seed == 0 ? new System.Random() : new System.Random(seed);
    }

    public OpponentProfile PickOpponent()
    {
        var arena = _rating.CurrentArena;
        var roster = PersonaRoster.ForArena(arena.Id);
        var persona = roster[_rng.Next(roster.Count)];
        int jitter = _rng.Next(-100, 101);
        int oppTrophies = Math.Max(0, _rating.Trophies + jitter);
        return new OpponentProfile(persona.Name, persona.Icon, persona.Tagline, oppTrophies, arena.Id);
    }
}
```

### 6.7 FlowController integration
```csharp
public class FlowController : IFlowController, IStartable
{
    // existing deps + new:
    readonly IRatingService _rating;
    readonly IMatchmakingService _mm;

    public OpponentProfile CurrentOpponent { get; private set; }

    public void RequestMatch()
    {
        CurrentOpponent = _mm.PickOpponent();
        _router.GoTo(PanelId.Matchmaking).Forget();
    }

    public void CompleteMatch(MatchResult result)
    {
        LastResult = result;
        var arenaIdx = _rating.CurrentArena.Index;
        LastRatingDelta = result.Win
            ? _rating.ApplyWin(arenaIdx, stakeCount: 0)
            : _rating.ApplyLoss(arenaIdx);
        LastReward = result.Win ? GoldOnWin : GoldOnLoss;
        _wallet.AddGold(LastReward);
        _wallet.Save();
        _router.GoTo(PanelId.Result).Forget();
    }

    public int LastRatingDelta { get; private set; }
}
```

New `LastRatingDelta` on `IFlowController` lets ResultPanel display trophy change. ResultPanel UI update lands in Phase 4 — for 3.1 just the state is available.

### 6.8 DI registration
```csharp
builder.Register<JsonSaveStore>(Lifetime.Singleton).As<ISaveProfile>();
builder.Register<WalletService>(Lifetime.Singleton).As<IWalletService>();
builder.Register<RatingService>(Lifetime.Singleton).As<IRatingService>();
builder.Register<MatchmakingService>(Lifetime.Singleton).As<IMatchmakingService>();
```

JsonSaveStore constructs the underlying `SaveProfile` on first `Load()` call. VContainer singleton ensures all services share the same profile.

## 7. Test strategy (EditMode)

### 7.1 ArenaTableTests
- Trophies 0 → juice
- Trophies 149 → juice
- Trophies 150 → smoothie
- Trophies 999 → tea
- Trophies 1000 → cocktail
- Trophies 10000 → grand (no ceiling)
- Arena index matches table order

### 7.2 RatingServiceTests
- New profile starts at 0 trophies
- ApplyWin in same arena, no stakes, no fire → +25 for juice
- ApplyWin in same arena after ConsecWins=2 → ×2 onFire → +50
- ApplyLoss in same arena → -25, clamped at 0
- ApplyLoss pushes player below arena threshold — arena resolution changes
- ApplyDraw → 0 delta, resets ConsecWins

### 7.3 MatchmakingServiceTests
- Deterministic seed → known persona + trophy picked
- Opponent trophies within player ±100 bound
- Opponent trophies floored at 0 (player at low trophies + jitter could go negative pre-clamp)

### 7.4 SaveProfile / JsonSaveStoreTests
- Save → Load roundtrip preserves Gold + Trophies + ConsecWins
- Missing PlayerPrefs key loads defaults (all zero)
- Corrupted JSON loads defaults (try/catch around JsonUtility)

### 7.5 WalletServiceTests (migrate)
- Existing 7 tests refactored to use `SaveProfile` injection
- Persistence test now uses `JsonSaveStore` (not raw PlayerPrefs)

Total new tests: ~20. Running total after 3.1: ~63.

## 8. Risks

- **Existing WalletService tests** — must migrate without losing coverage. If refactor churns too much, keep old tests + add new SaveProfile-specific ones.
- **PlayerPrefs key collision** — switch from `"wallet.gold"` to `"mixit.save.v1"` means old Phase 1 saves lost. Acceptable for pre-release.
- **FlowController `stakeCount: 0` hard-coded** — intentional placeholder; 3.3 Shop introduces stake loadout and updates this call site.
- **RatingService and WalletService both read/write `_profile.Data`** — concurrent mutation risk if future code calls both in the same frame. Single-threaded Unity main thread makes this safe today.

## 9. Acceptance

1. 20+ new EditMode tests green
2. Existing 43 tests still green (Wallet refactor preserves behavior)
3. FlowController wires Rating + MM without cycles
4. Play Mode smoke: one match → trophy changes visible via `_rating.Trophies` in inspector at runtime
5. Plugin boundary preserved (no plugin code changes)
