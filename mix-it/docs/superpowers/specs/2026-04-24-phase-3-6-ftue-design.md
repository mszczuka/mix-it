# Phase 3.6 — FTUE Design

**Date:** 2026-04-24
**Parent:** Phase 3 decomposition.
**Source of truth:** `design-v7.5-patch-pre-launch-polish.md` §1 + §2 (v7.5 supersedes the v7.4 §7 3-level overlay tutorial).

## 1. Goal

Port v7.5 FTUE as headless state machine: 5-stage progression (M1 solo → M2 timer intro → M3 easy bot + Trophy Road reveal → M4 consolidation + stake teaser → M5 scripted ×2 stake) with stage-gated reward grants and FlowController hooks. No UI surface; tutorial overlays + popups come in Phase 4.

## 2. Scope

**In:**
- FTUEService: 5-stage linear state machine (M1..M5, then Completed)
- Stage transitions advance on `CompleteMatch` when player in FTUE
- Reward grant per stage per v7.5 table §1
- M3 post-match flag → `albumFirstViewPending` (consumed when Album panel opens)
- M4 post-match flag → `stakeTeaserPending`
- M5 pre-match: grant free Silver booster, mark stake-equipped
- M5 post-match: replacement Silver booster on loss; Starter Pack popup flag
- `starterPackRedDotExpiresAtTicks` — 24h persistence on dismiss
- FTUEGate utility: `IsStageUnlocked(feature)` — simple predicate (stake UI before M5 = locked, etc.)
- SaveProfile extensions: `FtueStage`, `AlbumFirstViewPending`, `StakeTeaserPending`, `StarterPackPending`, `StarterPackRedDotExpiresAtTicks`, `CushionFaded`
- FlowController: on `CompleteMatch` call `_ftue.OnMatchCompleted(result)`; on `RequestMatch` call `_ftue.GetMatchConfig()` returning stage-specific config

**Deferred:**
- UI overlays + popups (Phase 4)
- Solo puzzle scene logic for M1/M2 (Phase 4 — headless stub: FTUE reports win immediately for M1/M2)
- Bot skill cushion curve fidelity (Phase 3.7 or later — MM runtime per v7.5 §3)
- Rewarded-video Color Spawn recharge (Phase 6)
- Server-authoritative rage-quit handling (Phase 6)
- `m5_redo` crash-recovery flag (Phase 6)
- Avatar frame cosmetics ("Apprentice Bartender") — flag only, no rendering (Phase 4)
- Starter Pack IAP (Phase 6)

## 3. Data

### 3.1 FTUE stages
```
enum FtueStage { M1, M2, M3, M4, M5, Completed }
```

### 3.2 Stage reward table
```
stage  coins  booster               extras
M1      100   -                     -
M2      200   -                     avatarFrame:apprenticeBartender
M3      600   extraBottle ×1        starterChest (lucky box 50% pre-fill, coin-only)
M4     std*   -                     -
M5      ×2*   replacementSilver**   starterPackPopup
```
* std = arena-standard coin payout (no override; arena 1 win = 20, loss = 8)
* ×2 = coin payout doubled on win; replacement granted on loss only
** replacement Silver booster: `swap` (first Silver in catalog)

### 3.3 M3 album pack drop
Triggered by first Album panel view after M3 completion (flag-gated). Grants: 1 Silver-weighted pack (5 slots, forceGold=false) + 1 sticker token. Implementation: `IAlbumService.GrantWelcomePack()` (new method) or `IPackOpener.Open(PackType.Standard)` + token increment.

### 3.4 M5 stake-equipped booster
Free Silver booster = `swap` (Id="swap"). Granted at M5 start, marked as equipped stake. On M5 win: stays in inventory. On M5 loss: removed, replacement `swap` granted.

## 4. Contracts

```csharp
public enum FtueStage { M1, M2, M3, M4, M5, Completed }

public sealed record FtueMatchConfig(
    FtueStage Stage,
    bool IsSolo,              // M1, M2 — no opponent
    bool EnforceTimer,        // M1=false, M2+=true
    float BotWinRateTarget,   // M3=0.30, M4=0.70, M5=0.65, else 0 (unused for solo)
    int ForcedStakeMultiplier // M5=2, else 0
);

public interface IFtueService
{
    FtueStage CurrentStage { get; }
    bool IsCompleted { get; }                 // CurrentStage == Completed
    bool AlbumFirstViewPending { get; }
    bool StakeTeaserPending { get; }
    bool StarterPackPending { get; }
    bool CushionFaded { get; }                // true post-Arena-5 entry; never flips back
    FtueMatchConfig GetMatchConfig();         // inspected by FlowController + MM
    void OnMatchCompleted(bool win);          // drives stage transitions + grants
    void OnAlbumFirstViewed();                // consumes AlbumFirstViewPending, grants welcome pack + token
    void OnStakeTeaserDismissed();            // consumes StakeTeaserPending
    void OnStarterPackDismissed();            // starts 24h red-dot, clears pending
    void OnArenaEntered(int arenaIdx);        // if arenaIdx >= 4 (Cocktail), set CushionFaded
}
```

## 5. Services

### 5.1 FtueService
State:
- `ISaveProfile.FtueStage` (int; enum cast)
- `ISaveProfile.AlbumFirstViewPending` (bool)
- `ISaveProfile.StakeTeaserPending` (bool)
- `ISaveProfile.StarterPackPending` (bool)
- `ISaveProfile.StarterPackRedDotExpiresAtTicks` (long)
- `ISaveProfile.CushionFaded` (bool)

Deps: `ISaveProfile`, `ICurrencyService`, `IBoosterInventory`, `IAnalyticsService`.

`OnMatchCompleted(win)`:
- Stage M1: grant 100c, advance M1→M2, emit `ftue_m1_complete`
- Stage M2: grant 200c + avatar frame flag (save field `HasApprenticeFrame=true`), advance M2→M3, emit `ftue_m2_complete`
- Stage M3: grant 600c + Grant("extraBottle", 1), set `AlbumFirstViewPending=true`, advance M3→M4, emit `ftue_m3_complete`
- Stage M4: no extra reward (std payout already applied by FlowController), set `StakeTeaserPending=true`, advance M4→M5, emit `ftue_m4_complete`
- Stage M5: on WIN grant doubled coins (FlowController already paid std; FtueService tops up `+arenaPayout`); on LOSS grant replacement Silver booster (`Grant("swap", 1)`); set `StarterPackPending=true`, advance M5→Completed, emit `ftue_m5_complete` + `m5_stake_outcome` + maybe `m5_replacement_booster_granted`
- Stage Completed: no-op

`GetMatchConfig()` returns stage-specific config. M5 additionally grants "swap" booster on entry if not already equipped-for-stake (track separately: `M5StakeBoosterGranted` bool).

### 5.2 FlowController integration
```csharp
public void CompleteMatch(MatchResult result)
{
    // existing payout + rating + BPP + missions + TR observe
    _ftue.OnMatchCompleted(result.Win);
    // M5 win double-up: FtueService adds additional LastReward if stage was M5
    _router.GoTo(PanelId.Result).Forget();
}

public FtueMatchConfig? GetFtueConfig() => _ftue.IsCompleted ? null : _ftue.GetMatchConfig();
```

M5 doubling: simplest — FtueService reads arena payout via injected `IMatchPayoutTable`, top-up on win.

### 5.3 RatingService hook
On arena change (trophy threshold crossed), FtueService.OnArenaEntered must be called. Simplest: FlowController reads `_rating.CurrentArena.Index` before+after match; if it crossed to ≥4, call OnArenaEntered(4).

### 5.4 Album welcome pack
`IFtueService.OnAlbumFirstViewed` (called by Album panel on first view once `AlbumFirstViewPending` is true):
- Open Standard pack via IPackOpener → results discarded for sticker grants (already persisted by PackOpener)
- Increment `ISaveProfile.StickerTokens += 1`
- Clear `AlbumFirstViewPending`
- Emit `ftue_album_welcome_pack_granted`

### 5.5 Stage skip / dev-cheat
Expose `IFtueService.SkipAll()` for editor-only testing (behind `#if UNITY_EDITOR`). Sets CurrentStage = Completed, clears all pending flags.

## 6. SaveProfile extensions

```csharp
public int FtueStage;                          // 0..5 (0=M1, 5=Completed)
public bool AlbumFirstViewPending;
public bool StakeTeaserPending;
public bool StarterPackPending;
public long StarterPackRedDotExpiresAtTicks;
public bool CushionFaded;
public bool HasApprenticeFrame;
public bool M5StakeBoosterGranted;
```

ISaveProfile exposes getters/setters.

## 7. Tests (~15 new)

### 7.1 FtueServiceTests
- CurrentStage defaults to M1
- OnMatchCompleted(win=true) at M1 advances to M2, grants 100c
- M2 complete grants 200c + sets HasApprenticeFrame
- M3 complete grants 600c + extraBottle×1 + sets AlbumFirstViewPending
- M4 complete sets StakeTeaserPending
- M5 win complete grants double arena payout + sets StarterPackPending + advances to Completed
- M5 loss complete grants replacement swap × 1 + StarterPackPending + advances
- OnMatchCompleted when Completed is no-op
- GetMatchConfig returns correct per-stage config (M1 solo/no-timer, M2 solo/timer, M3-4 bot WR, M5 stake=2)
- OnAlbumFirstViewed while pending grants token + clears flag (verify StickerTokens +1, flag=false)
- OnAlbumFirstViewed when not pending is no-op
- OnArenaEntered(4) sets CushionFaded=true
- OnArenaEntered(3) does NOT set CushionFaded
- CushionFaded once set stays true even if OnArenaEntered(0) called
- SkipAll (editor-only) jumps to Completed

## 8. Architecture

```
_Archetype/Contracts/
├── FtueStage.cs                 (NEW enum)
├── FtueMatchConfig.cs           (NEW record)
└── IFtueService.cs              (NEW)

_Archetype/Runtime/
├── FtueService.cs               (NEW)
└── FlowController.cs            (MODIFY — inject IFtueService, call OnMatchCompleted, arena-cross detection)

_Archetype/Runtime/Persistence/
├── SaveProfile.cs               (MODIFY — 8 new fields)
└── JsonSaveStore.cs             (MODIFY — expose new fields via ISaveProfile)

_Archetype/Contracts/
└── ISaveProfile.cs              (MODIFY — new members)

_Game/Bootstrap/
└── GameLifetimeScope.cs         (MODIFY — register FtueService)

_Tests/EditMode/
└── FtueServiceTests.cs          (NEW — 15 tests)
```

## 9. DI

```csharp
builder.Register<FtueService>(Lifetime.Singleton).As<IFtueService>();
```

FlowController gains 1 new injected dep.

## 10. Acceptance

- 15 new tests green; total ≥ 157
- Plugin unchanged
- Play Mode smoke: Boot OK; new profile → CurrentStage = M1
- M5 replacement-on-loss path covered by unit test (no UI verification in 3.6)

## 11. Open questions

- Avatar frame "Apprentice Bartender": Phase 3.6 stores bool flag; no cosmetic rendering. Phase 4 UI picks it up. OK.
- M1/M2 solo scene: deferred. For 3.6, FlowController treats M1/M2 as standard matches; `FtueMatchConfig.IsSolo=true` informs future scene loader but 3.6 match ends normally (bot ignores IsSolo flag). Tests verify config output only.
- Starter Chest (v7.5 §1 M3 extras, "Lucky Box 50% pre-fill coin-only"): Lucky Box system not yet ported. Deferred to Phase 5 polish — for 3.6, grant flat 250c as coin-only stand-in (documented in FtueService), fix in Phase 5 when Lucky Box ships.
