# Phase 3.5 — Venue + Album Design

**Date:** 2026-04-24
**Parent:** Phase 3 decomposition.

## 1. Goal

Port Venue (district progression) + Album (sticker collection) + Pack opening + Sticker Tokens as headless archetype services. No UI yet.

## 2. Scope

**In:**
- VenueService: 3 districts, gated by arena index (not trophy directly — district = group of arenas)
- AlbumService: 4 albums × 10 stickers, per-page + full-album rewards, sticker token currency
- PackOpener: rarity-weighted roll (White/Silver/Gold/Diamond), grants to album, converts dupes to tokens
- Extension points: Trophy Road claim → grant sticker pack; flash offer reward stub

**Deferred:**
- Building upgrades within districts (Phase 5 polish)
- Seasonal album rotation (Phase 6)
- Daily sticker deal pricing (Phase 5)
- Skin/frame cosmetics from token spend (Phase 4+ UI)

## 3. Data

### 3.1 District table (3 entries)
```
id          name         MinArenaIdx  CoinReward  BoosterReward
cafeRow     Café Row     0            400         extraBottle ×3
boulevard   Boulevard    3            1200        clearBottle ×2
uptown      Uptown       5            3000        autoSort ×1
```

### 3.2 Album table (4 entries)
```
id                      name              StickerCount  PageSize
barClassics             Bar Classics           10           5
cityNights              City Nights            10           5
grandHotel              Grand Hotel            10           5
seasonSummerRooftop     Summer Rooftop         10           5
```

Per-page reward: 150 coins per page claim.
Full-album reward: 2000 coins + 1 sticker token.

### 3.3 Rarity table
```
rarity      weight  dupeTokens
White       60      0
Silver      28      0
Gold        10      0
Diamond      2      1
```

### 3.4 Pack types
```
id           slots  forceGold  source
small         3      false     Trophy Road early
standard      5      false     Trophy Road mid / daily missions
big          10       true     Trophy Road milestones / full album
```

## 4. Contracts

```csharp
public sealed record District(string Id, string Name, int MinArenaIdx, int CoinReward, string BoosterId, int BoosterAmount);
public sealed record AlbumDef(string Id, string Name, int StickerCount, int PageSize);
public enum StickerRarity { White, Silver, Gold, Diamond }
public sealed record StickerPull(string AlbumId, int StickerIdx, StickerRarity Rarity, bool IsDupe, int TokensAwarded);
public enum PackType { Small, Standard, Big }

public interface IVenueService
{
    IReadOnlyList<District> All { get; }
    IReadOnlyList<District> Unlocked { get; }           // arena-idx gated
    IReadOnlyList<District> PendingClaimable { get; }   // unlocked but not claimed
    IReadOnlyList<string> ClaimedIds { get; }
    bool Claim(string districtId);
}

public interface IAlbumService
{
    IReadOnlyList<AlbumDef> All { get; }
    bool IsOwned(string albumId, int idx);
    int OwnedCount(string albumId);
    bool IsPageClaimed(string albumId, int page);
    bool IsAlbumClaimed(string albumId);
    int StickerTokens { get; }
    bool ClaimPage(string albumId, int page);
    bool ClaimAlbum(string albumId);
}

public interface IPackOpener
{
    IReadOnlyList<StickerPull> Open(PackType type);
}
```

## 5. Services

### 5.1 VenueService
Gates unlocked districts via `IRatingService.CurrentArena.Index >= district.MinArenaIdx`. Claim grants coin + booster reward.

### 5.2 AlbumService
Stickers stored via `ISaveProfile.OwnedStickerKeys` (List<string>). Key format: `"{albumId}:{idx}"`.

Per-page claim requires all stickers in page range owned. Full-album claim requires all stickers owned AND all pages claimed (or just all stickers — spec says: all stickers). Use: all stickers + all pages claimed.

### 5.3 PackOpener
Uses injected RNG seed. For each slot:
1. Pick album: random from 4
2. Pick index: random uniform 0..StickerCount-1
3. Roll rarity: weighted (weights vary based on `forceGold`)
4. If already owned: dupe → if Diamond, grant 1 token; else no reward
5. If new: grant ownership
6. Return `StickerPull` record

Rarity is cosmetic for now (doesn't gate sticker index — each sticker has implicit rarity from HTML but we model it as a roll per pull).

### 5.4 FlowController hook
No new hooks. PackOpener + AlbumService + VenueService exposed via DI for future UI / mission reward integration. Trophy Road can be extended later to grant packs; for 3.5 just the services.

## 6. SaveProfile extensions

```csharp
public List<string> ClaimedDistricts = new();       // district ids
public List<string> OwnedStickerKeys = new();       // "{albumId}:{idx}"
public List<string> ClaimedAlbumPages = new();      // "{albumId}:{pageIdx}"
public List<string> ClaimedAlbumFulls = new();      // album ids
public int StickerTokens;
```

## 7. Tests (~15 new)

### 7.1 VenueServiceTests
- Unlocked depends on arena index (mock IRatingService)
- PendingClaimable excludes claimed
- Claim grants coin + booster
- Double claim rejected
- Claim locked district rejected

### 7.2 AlbumServiceTests
- IsOwned false by default
- Grant makes owned
- Dupe grant returns dupe flag (indirectly via PackOpener test)
- ClaimPage requires all stickers in page
- ClaimAlbum requires all stickers + all pages
- Claim grants coins + token

### 7.3 PackOpenerTests
- Small pack returns 3 pulls
- Big pack returns 10 pulls, all Gold+ (forceGold)
- Dupe Diamond grants 1 token
- Deterministic with seed

## 8. Architecture

```
_Archetype/Contracts/
├── District.cs                    (NEW)
├── AlbumDef.cs                    (NEW)
├── StickerRarity.cs               (NEW)
├── StickerPull.cs                 (NEW)
├── PackType.cs                    (NEW)
├── IVenueService.cs               (NEW)
├── IAlbumService.cs               (NEW)
└── IPackOpener.cs                 (NEW)

_Archetype/Runtime/
├── DistrictCatalog.cs             (NEW — 3 districts)
├── AlbumCatalog.cs                (NEW — 4 albums)
├── VenueService.cs                (NEW)
├── AlbumService.cs                (NEW)
└── PackOpener.cs                  (NEW)

_Tests/EditMode/
├── VenueServiceTests.cs           (NEW)
├── AlbumServiceTests.cs           (NEW)
└── PackOpenerTests.cs             (NEW)

_Game/Bootstrap/GameLifetimeScope.cs  (MODIFY — register 3 services)
```

## 9. Acceptance

- 15 new tests green; total ≥ 135
- Plugin unchanged
- Play Mode smoke: Boot OK
