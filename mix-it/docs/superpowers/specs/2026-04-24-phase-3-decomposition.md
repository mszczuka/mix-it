# Phase 3 — Archetype Meta Systems Decomposition

**Date:** 2026-04-24
**Parent spec:** `2026-04-24-unity-port-archetype-plugin-design.md` §Phase 3

Phase 3 ships all archetype meta/backend services as headless, testable C# services. Split into 6 sub-projects, each with its own spec + plan + execution cycle.

## Execution order (dependency-driven)

1. **3.1 — Rating + Matchmaking** (plus Wallet refactor if needed)
2. **3.2 — Analytics event bus** (cross-cutting; land early so later systems emit)
3. **3.3 — Shop + FlashOfferRules**
4. **3.4 — BattlePass + TrophyRoad**
5. **3.5 — Venue + Album**
6. **3.6 — FtueService**

## Dependency graph

```
Wallet (done Phase 1) ──┐
                        ├─→ Rating ─→ Matchmaking ─→ (used by all)
                        │
                        ├─→ Shop ─→ BattlePass
                        │          └─→ TrophyRoad ─→ Venue ─→ Album
                        │
Analytics ──────────────┴─→ (emitted by all)
                                     ↑
FtueService ─────────────────────────┘
```

## Per sub-project scope

### 3.1 Rating + Matchmaking
- **New contracts:** `IRatingService` (trophies int, win/loss delta), `IMatchmakingService` (find opponent by rating ±50)
- **New runtime:** `RatingService` (ELO-lite curve), `MatchmakingService` (opponent roster + rating window + fake persona lookup)
- **Refactor:** Wallet persistence scheme may need reload semantics for rating coexistence
- **Flow hook:** `FlowController.CompleteMatch` applies rating delta
- **Tests:** rating math, matchmaking window filtering
- **Telemetry:** trophy gain/loss amounts in `MatchResult`

### 3.2 Analytics event bus
- **New contract:** `IAnalyticsService` (`Track(string eventName, Dictionary<string,object> params)`)
- **New runtime:** `AnalyticsService` (buffered in-memory dispatcher, log sink for Phase 3, network sink deferred)
- **Hooks:** FlowController, WalletService, RatingService emit events
- **Tests:** event buffering, replay, param passing
- **No UI**

### 3.3 Shop + FlashOfferRules
- **New contracts:** `IShopService`, `IShopOffer`, `IFlashOfferRules`
- **New runtime:** `ShopService` (fixed + rotating offers), `FlashOfferRulesEngine` (trigger-on-X conditions)
- **SO data:** offer definitions (coin cost, reward tier)
- **Integration:** wallet spend, analytics emit
- **Tests:** offer availability, purchase transaction, flash trigger rules

### 3.4 BattlePass + TrophyRoad
- **New contracts:** `IBattlePassService`, `ITrophyRoadService`
- **New runtime:** progression trackers, tier unlock, quest completion
- **SO data:** BP tier rewards, TR milestone rewards, daily/weekly quests
- **Integration:** match wins increment progress, wallet grants rewards, analytics
- **Tests:** progression math, tier claim, quest completion

### 3.5 Venue + Album
- **New contracts:** `IVenueService`, `IAlbumService`
- **New runtime:** arena unlock state, collectible inventory
- **SO data:** venue definitions (trophy threshold), album cards
- **Integration:** trophy road milestone → venue unlock; match result → potential card drop
- **Tests:** unlock gating, drop rate stub

### 3.6 FtueService
- **New contract:** `IFtueService`
- **New runtime:** step sequence state machine, trigger hooks
- **Integration:** FlowController queries `ShouldShowTutorial(step)`, feeds into panel views later (Phase 4 UI)
- **Tests:** step progression, replay blocking

## Out of scope for Phase 3
- UI for shop/BP/TR/venue/album (Phase 4 "social + venue UI")
- Tutorial UI overlay (Phase 4 FTUE UI)
- Real analytics network sink (Phase 6 integration)
- Audio, VFX, polish (Phase 5)

## Shared infrastructure to add in 3.1
- `ISaveProfile` abstraction so Rating + BattlePass + TrophyRoad + Venue + Album can persist via single JSON file (replacing scattered PlayerPrefs). Wallet migrates from raw PlayerPrefs to this in 3.1 refactor.
- `Assets/_Archetype/Runtime/Persistence/SaveProfile.cs` + `JsonSaveStore.cs`

## Test count projection
Each sub-project: 10–20 new EditMode tests. Phase 3 total: ~80–100 new tests. Running total after Phase 3: ~125–145 tests.

## Gate criteria
- All 6 sub-projects merged, tests green
- FlowController cleanly integrated with Rating, Analytics, FTUE hooks
- Headless smoke: run 10 matches in a loop, verify trophies/wallet/BP/TR all update
- PHASE_3_DONE.md covers every sub-project
