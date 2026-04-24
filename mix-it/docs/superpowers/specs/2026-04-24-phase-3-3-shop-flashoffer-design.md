# Phase 3.3 — Coins, Boosters, Shop, Flash Offers Design

**Date:** 2026-04-24
**Parent:** Phase 3 decomposition.

## 1. Goal

Port HTML v7.3.1 economy: Coins as soft currency (replacing Phase 1 Gold placeholder), booster inventory with 9 items across 3 tiers, booster shop (coin-priced), and flash offer system (4 triggers with expiry timers).

## 2. Scope

**In:**
- Rename Gold → Coins end-to-end (archetype + plugin UI text)
- Arena-specific coin payout table (match end)
- Booster registry (9 items, tier, unlock-arena, cost)
- `IBoosterInventory` + `IBoosterShop` services
- `IFlashOfferService` + 4 offer types (Comeback / Promotion / Refill / Sticker)
- Loss streak tracking in SaveProfile
- FlowController integration (arena payout, streak increment, flash trigger)

**Deferred to later phases:**
- Sticker packs (Phase 3.5 Album)
- Star Chest shortcut (Phase 3.4 progression)
- Premium IAP bundles (Phase 6)
- Lucky Box respawn (Phase 5 polish)
- Daily deal rotation (Phase 5)
- On-Fire coin bonus (plumbing exists via RatingService.ConsecWins; applied in FlowController reward calc)
- Perk slots (Phase 4 UI)

## 3. Data

### 3.1 SaveProfile extension
Add fields: `Coins` (replacing `Gold`), `ConsecLosses`, `BoosterInventory` (Dictionary<string,int>), `ActiveFlashOfferId`, `FlashOfferExpiresAtTicks` (long).

`Gold` field removed; migration = skip (pre-release, no live saves).

### 3.2 Arena coin payout (v7.3.1 §2)
```
| Arena       | Win | Loss | Draw |
| juice       |  20 |    8 |   15 |
| smoothie    |  30 |   12 |   20 |
| coffee      |  40 |   15 |   25 |
| tea         |  55 |   20 |   30 |
| cocktail    |  50 |   25 |   35 |
| wine        |  65 |   30 |   40 |
| champagne   |  80 |   35 |   45 |
| grand       |  90 |   40 |   50 |
```

### 3.3 Booster catalog
```
id              tier     unlock-arena-idx   cost   stakeable
extraBottle     Bronze   0 (juice)          20     false
firstPour       Bronze   0                  20     false
colorSplash     Bronze   0                  40     false
swap            Silver   1 (smoothie)       150    true
autoServe       Silver   4 (cocktail)       180    true
customerLock    Silver   5 (wine)           500    true
clearBottle     Gold     3 (tea)            400    true
doubleServe     Gold     6 (champagne)      600    true
autoSort        Gold     7 (grand)          800    true
```

### 3.4 Flash offers
```
id          trigger                                  duration     price
comeback    ConsecLosses >= 3 post-loss              30 min       (hard $)
promotion   on arena unlock (future; stub trigger)   24 h         (hard $)
refill      Coins < 200 post-match                    2 h         (hard $)
sticker     (deferred: Phase 3.5)                    —            —
```

Only one active at a time (first-come wins, new triggers ignored while active).

## 4. Contracts

```csharp
public interface ICurrencyService  // replaces Gold-only IWalletService
{
    int Coins { get; }
    void AddCoins(int amount);
    bool SpendCoins(int amount);
    void Save();
    void Load();
}

public interface IBoosterInventory
{
    int Count(string boosterId);
    void Grant(string boosterId, int amount = 1);
    bool Consume(string boosterId, int amount = 1);
    IReadOnlyDictionary<string, int> All { get; }
}

public sealed record BoosterDefinition(string Id, string DisplayName, BoosterTier Tier, int UnlockArenaIdx, int Cost, bool Stakeable);
public enum BoosterTier { Bronze, Silver, Gold }

public interface IBoosterShop
{
    IReadOnlyList<BoosterDefinition> AvailableFor(int playerArenaIdx);
    ShopPurchaseResult Purchase(string boosterId, int playerArenaIdx);
}
public enum ShopPurchaseResult { Ok, NotUnlocked, InsufficientCoins, UnknownItem }

public sealed record FlashOffer(string Id, string Title, string Description, TimeSpan Duration);

public interface IFlashOfferService
{
    FlashOffer Active { get; }          // null if none active or expired
    bool IsExpired { get; }
    void TryTrigger(string id);
    void ClearIfExpired();
}

public interface IMatchPayoutTable
{
    int Coins(int arenaIdx, MatchOutcome outcome);
}
public enum MatchOutcome { Win, Loss, Draw }
```

### 4.1 Existing IWalletService
Rename to `ICurrencyService`. Keep `IWalletService` as `[Obsolete]` alias (extending `ICurrencyService`) for one phase to avoid churn in plugin code. Actually plugin doesn't use it — only archetype. Clean rename, remove `IWalletService` entirely.

## 5. Services

### 5.1 CoinService (replaces WalletService)
Backed by `ISaveProfile.Coins`. Same AddCoins/SpendCoins semantics as old WalletService.AddGold/SpendGold.

### 5.2 BoosterInventoryService
Backed by `ISaveProfile.BoosterInventory` (Dictionary serialized via JsonUtility fallback: actually JsonUtility doesn't serialize Dictionary directly — use List<KeyValue> or migrate to Newtonsoft.Json).

Simpler: store as `List<BoosterCount>` serializable pair. Expose Dictionary view at runtime.

### 5.3 BoosterCatalog (static)
```csharp
public static class BoosterCatalog
{
    public static readonly BoosterDefinition[] All = { ... 9 entries ... };
    public static BoosterDefinition FindById(string id);
}
```

### 5.4 BoosterShopService
`AvailableFor(arenaIdx)` filters catalog by `UnlockArenaIdx <= arenaIdx`. `Purchase` deducts coins, grants inventory, emits analytics.

### 5.5 MatchPayoutTable
Hard-coded table per spec §3.2.

### 5.6 FlashOfferService
Checks `ISaveProfile.ActiveFlashOfferId` + `FlashOfferExpiresAtTicks` against `DateTimeOffset.UtcNow.Ticks`. Clears if expired.

### 5.7 FlowController wiring
```csharp
public void CompleteMatch(MatchResult result)
{
    LastResult = result;
    int arenaIdx = _rating.CurrentArena.Index;
    var outcome = result.Win ? MatchOutcome.Win : MatchOutcome.Loss; // draws not yet modeled
    LastRatingDelta = result.Win ? _rating.ApplyWin(arenaIdx, 0) : _rating.ApplyLoss(arenaIdx);
    LastReward = _payoutTable.Coins(arenaIdx, outcome);
    _coins.AddCoins(LastReward);
    if (!result.Win) _saveProfile.ConsecLosses++;
    else _saveProfile.ConsecLosses = 0;
    _coins.Save();

    // Flash offer triggers
    if (_saveProfile.ConsecLosses >= 3) _flash.TryTrigger("comeback");
    else if (_coins.Coins < 200) _flash.TryTrigger("refill");

    _analytics.Track("match_ended", ...);
    _router.GoTo(PanelId.Result).Forget();
}
```

## 6. Tests (~25 new)

- `CoinServiceTests` (rename of WalletServiceTests, same cases)
- `BoosterInventoryTests` (grant, consume, insufficient)
- `BoosterShopTests` (availability by arena, purchase success/fail)
- `MatchPayoutTableTests` (arena × outcome lookup correctness)
- `FlashOfferServiceTests` (trigger, active, expiry, single-active rule)

## 7. Files

```
_Archetype/Contracts/
├── ICurrencyService.cs             (NEW — renamed from IWalletService)
├── IBoosterInventory.cs            (NEW)
├── BoosterDefinition.cs            (NEW)
├── IBoosterShop.cs                 (NEW)
├── IFlashOfferService.cs           (NEW)
├── IMatchPayoutTable.cs            (NEW)
├── MatchOutcome.cs                 (NEW enum)
├── FlashOffer.cs                   (NEW record)
├── ShopPurchaseResult.cs           (NEW enum)
├── BoosterTier.cs                  (NEW enum)
└── IWalletService.cs               (DELETE)

_Archetype/Runtime/
├── CoinService.cs                  (RENAME from WalletService.cs)
├── BoosterCatalog.cs               (NEW)
├── BoosterInventoryService.cs      (NEW)
├── BoosterShopService.cs           (NEW)
├── MatchPayoutTable.cs             (NEW)
├── FlashOfferService.cs            (NEW)
├── Persistence/SaveProfile.cs      (MODIFY — add Coins, ConsecLosses, BoosterCounts, ActiveFlashOfferId, FlashOfferExpiresAtTicks; REMOVE Gold)
├── Persistence/JsonSaveStore.cs    (MODIFY — expose new fields)
└── FlowController.cs               (MODIFY)

_Archetype/UI/Panels/
├── HomePanelView.cs                (MODIFY — "Coins: N" text)
└── ResultPanelView.cs              (MODIFY — "+N Coins" text)

_Game/Bootstrap/
└── GameLifetimeScope.cs            (MODIFY)

_Tests/EditMode/
├── WalletServiceTests.cs           (RENAME → CoinServiceTests.cs)
├── BoosterInventoryTests.cs        (NEW)
├── BoosterShopTests.cs             (NEW)
├── MatchPayoutTableTests.cs        (NEW)
└── FlashOfferServiceTests.cs       (NEW)
```

## 8. Acceptance

- 25 new tests + migrated coin tests = ~95 total pass
- Play Mode smoke: match → coins visible via `ICurrencyService`, shop flow wired (no UI yet — verified via test)
- FlowController emits analytics events as before
- Plugin boundary unchanged
