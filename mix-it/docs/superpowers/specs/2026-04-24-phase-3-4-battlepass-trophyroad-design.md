# Phase 3.4 — BarPass + TrophyRoad + DailyMissions Design

**Date:** 2026-04-24
**Parent:** Phase 3 decomposition.

## 1. Goal

Port three archetype progression systems: Trophy Road (milestone coin rewards), Bar Pass (30-tier seasonal XP), Daily Missions (3 quests, auto-claim on completion). All headless services, no UI yet.

## 2. Scope

**In:**
- TrophyRoadService — 25 milestones, claim-on-reach, persistence
- BarPassService — 30 tiers × 400 BPP, AddBpp, auto-tier advance, bonus bank post-T30
- DailyMissionService — 3 daily quests, local-date reset, progress tracking, reward grant on complete
- FlowController hook: after CompleteMatch, emit progress signals (win/play)
- Reward grant bus: when milestone/tier/mission completes, deposit coins via `ICurrencyService.AddCoins` and boosters via `IBoosterInventory.Grant`

**Deferred:**
- Weekly missions (Phase 4 paired with UI)
- Star Race (Phase 4 — arena leaderboard)
- BarPass premium IAP (Phase 6 — IAP)
- Mail/mailbox system (Phase 4)
- Season reset scheduling (Phase 5 polish; for 3.4, season = static range)

## 3. Data tables

### 3.1 TrophyRoad milestones (25 entries, static)
```
id  trophies  coinReward  boosterRewards (optional)
1      50      200       -
2     100      200       -
3     200      300       extraBottle ×2
4     300      300       -
5     400      400       firstPour ×2
6     600      500       -
7    1000     1000       swap ×1
8    1200      800       -
9    1400      900       -
10   1500     1200       clearBottle ×1
11   1700     1000       -
12   2000     1500       -
13   2200     1500       autoServe ×1
14   2500     1800       -
15   2800     2000       -
16   3000     2500       customerLock ×1
17   3200     2500       -
18   3500     2800       -
19   3800     3500       doubleServe ×1
20   4000     3500       -
21   4200     4000       -
22   4500     5000       -
23   5000     5500       autoSort ×1
24   5500     6000       -
25   6000     7500       -
```

Note: arena unlock side-effect already handled by ArenaTable.Resolve — 3.4 only grants coin + booster rewards.

### 3.2 BarPass structure
- 30 tiers × 400 BPP per tier = 12 000 BPP total
- BPP source: +100 per match win, +10 per match played
- Tier advance auto (Tier N reached when `bpp >= N * 400`)
- Per-tier free reward: `100 * (1 + tier/2)` coins, rounded to nearest 10 (scales 100 → 1500)
- Post-T30 overflow: convert BPP → 100 coins / 400 BPP (ratio 0.25), cap 5000/season

### 3.3 Daily missions (pool of 4 for 3.4)
Each mission: `id`, `text`, `target`, `rewardCoins`, `progressKey`.

```
id           text                      target  coins  progressKey
win_3        Win 3 matches                3     150   "wins"
play_5       Play 5 matches               5     100   "plays"
earn_500     Earn 500 coins              500    100   "coinsEarned"
combo_3      Hit combo ×3 in one match    1     150   "bestCombo>=3"
```

At daily reset (local midnight): pick 3 random from pool, zero progress, clear claimed flag.

## 4. Contracts

```csharp
// Trophy Road
public sealed record TrophyMilestone(int Index, int Trophies, int CoinReward, string BoosterId, int BoosterAmount);

public interface ITrophyRoadService
{
    IReadOnlyList<TrophyMilestone> Milestones { get; }
    int HighestReached { get; }                    // highest trophy count seen
    IReadOnlyList<int> ClaimedIndices { get; }
    IReadOnlyList<TrophyMilestone> PendingClaimable { get; } // reached but not claimed
    void Observe(int currentTrophies);             // called after any trophy change
    bool Claim(int index);                         // grants reward, returns true if accepted
}

// Bar Pass
public sealed record BarPassTier(int Index, int CoinReward);

public interface IBarPassService
{
    int Bpp { get; }
    int CurrentTier { get; }                       // 0 means none claimed yet; 1..30 after claims
    int TotalTiers { get; }                        // 30
    int BppPerTier { get; }                        // 400
    int BonusBankCoins { get; }                    // coins banked post-T30
    IReadOnlyList<int> ClaimedTiers { get; }
    IReadOnlyList<BarPassTier> PendingClaimable { get; }
    void AddBpp(int amount);
    bool ClaimTier(int tierIdx);
    int ClaimBonusBank();                          // returns coins transferred to wallet
}

// Daily Missions
public sealed record DailyMission(string Id, string Text, int Target, int CoinReward, int Progress, bool Claimed);

public interface IDailyMissionService
{
    IReadOnlyList<DailyMission> Today { get; }     // 3 missions
    void ResetIfNeeded(System.DateTimeOffset now);
    void ReportProgress(string progressKey, int amount);
    bool ClaimIfReady(string missionId);
}
```

## 5. Services

### 5.1 TrophyRoadService
State: `ISaveProfile.TrophyRoadHighest` (int), `ISaveProfile.TrophyRoadClaimed` (List<int>).

`Observe(currentTrophies)`:
- if currentTrophies > HighestReached → update HighestReached

`PendingClaimable`:
- milestones where `milestone.Trophies <= HighestReached` AND `!ClaimedIndices.Contains(milestone.Index)`

`Claim(index)`:
- lookup milestone; must be pending claimable
- grants `CoinReward` via `ICurrencyService.AddCoins`
- grants booster via `IBoosterInventory.Grant(BoosterId, BoosterAmount)` if set
- appends to ClaimedIndices
- returns true

### 5.2 BarPassService
State: `ISaveProfile.BarPassBpp` (int), `ISaveProfile.BarPassBonusBank` (int), `ISaveProfile.BarPassClaimed` (List<int>).

Constants: `TotalTiers = 30`, `BppPerTier = 400`, `BonusBankPerTierOverflow = 100`, `BonusBankCap = 5000`.

`AddBpp(amount)`:
- if bpp < TotalTiers * BppPerTier (still in tier range): add to Bpp; overflow past cap goes to BonusBank (capped)
- else: goes straight to BonusBank (capped)

`ClaimTier(tierIdx)`:
- valid if 1..30 AND `bpp >= tierIdx * BppPerTier` AND not already claimed
- reward = 100 + 40 * tierIdx coins (simple linear)
- grants coins
- appends to ClaimedTiers

`ClaimBonusBank()`:
- transfers BonusBankCoins to wallet, resets BonusBankCoins to 0; returns amount

### 5.3 DailyMissionService
State: `ISaveProfile.DailyMissionsDate` (string ISO date), `ISaveProfile.DailyMissionsJson` (string — serialized list of mission state).

`ResetIfNeeded(now)`:
- if DailyMissionsDate != now.LocalDateTime.Date.ToString("yyyy-MM-dd"): pick 3 random from pool, reset state, update date

`ReportProgress(key, amount)`:
- for each of 3 missions with matching progressKey, increment progress (cap at target)

`ClaimIfReady(id)`:
- if mission progress >= target AND !claimed: grant coins, mark claimed, return true

### 5.4 FlowController hooks

After `CompleteMatch`:
```csharp
int bppGain = 10 + (result.Win ? 100 : 0);
_barPass.AddBpp(bppGain);

_dailyMissions.ReportProgress("plays", 1);
if (result.Win) _dailyMissions.ReportProgress("wins", 1);
_dailyMissions.ReportProgress("coinsEarned", LastReward);
if (result.Telemetry.TryGetValue("best_combo", out float bc) && bc >= 3) _dailyMissions.ReportProgress("bestCombo>=3", 1);

_trophyRoad.Observe(_rating.Trophies);
```

## 6. SaveProfile extensions

```csharp
public int TrophyRoadHighest;
public List<int> TrophyRoadClaimed = new();

public int BarPassBpp;
public int BarPassBonusBank;
public List<int> BarPassClaimedTiers = new();

public string DailyMissionsDate;           // "yyyy-MM-dd"
public List<DailyMissionState> DailyMissionsState = new();  // list of 3
```

Serialize-safe: `DailyMissionState { Id, Progress, Claimed }` as `[Serializable]` class.

## 7. Tests (~20 new)

### 7.1 TrophyRoadServiceTests
- Observe updates highest
- PendingClaimable filters claimed
- Claim grants coins, grants booster if set, marks claimed
- Double claim returns false
- Claim below threshold rejected

### 7.2 BarPassServiceTests
- AddBpp accumulates
- Tier claim requires enough BPP
- Tier claim grants correct coin amount
- BPP past T30 cap goes to BonusBank
- BonusBank respects 5000 cap
- ClaimBonusBank empties bank and returns amount

### 7.3 DailyMissionServiceTests
- ResetIfNeeded on first call picks 3 missions
- Same-day second call does NOT re-pick
- Next-day call re-picks
- ReportProgress increments matching missions
- Claim grants coins and marks claimed

## 8. DI

```csharp
builder.Register<TrophyRoadService>(Lifetime.Singleton).As<ITrophyRoadService>();
builder.Register<BarPassService>(Lifetime.Singleton).As<IBarPassService>();
builder.Register<DailyMissionService>(Lifetime.Singleton).As<IDailyMissionService>();
```

FlowController gains 3 new injected deps.

## 9. Acceptance

- 20 new tests green; total ≥ 117
- Play Mode smoke: Boot OK, no errors, running match emits BPP + mission progress (verifiable via service state inspection)
- Plugin unchanged
