# Phase 6 — Playable Prototype Scope

**Date:** 2026-04-25
**Goal:** Game fully playable end-to-end with fake stand-ins for IAP/ads/network. No real billing, no real ad mediation, no analytics backend, no server matchmaking. All currently real systems stay; missing systems get fake implementations.

## Out of scope (deferred to Phase 7 — Launch)
- Real Apple/Google IAP integration
- Real ad mediation (ironSource/MAX/AdMob)
- Analytics backend (HTTP/Firebase sink). LoggingAnalyticsService stays.
- Server matchmaking (queue + cushion bot-fill). Local fake matchmaking stays.
- Server-authoritative match results / anti-cheat
- Reconnection / offline replay
- Localization tables (string passes deferred)
- iOS/Android build pipelines
- Real account/cloud save sync

## In scope

### 6.1 — Fake IAP service
- `IIAPService` contract + `FakeIAPService`
- `IAPCatalog` static: 12 products (Starter Pack, 5 coin packs, 3 bundles, 2 sticker packs, Bar Pass premium)
- `Purchase(productId)` immediately grants items via existing services (ICurrencyService/IBoosterInventory/IPackOpener/ISaveProfile), emits `iap_purchase` analytics, marks one-time products as owned
- SaveProfile: `HasBarPassPremium`, `OwnedIAPProducts`
- Wire all Shop tab Buy buttons (Coins/Bundles/Sticker tabs) to `_iap.Purchase(id)` via product-id-named buttons
- Wire StarterPackPopup buy button to `_iap.Purchase("starter_pack")`
- Tests: ~10 (catalog, grant variants, one-time gating, analytics emit)

### 6.2 — Fake rewarded ad service
- `IAdService.ShowRewardedAd(placementId)` returns `AdResult` (Completed/Skipped/Failed)
- `FakeAdService` routes to `PanelId.Ad`, runs 10s countdown, returns Completed
- New AdPanel prefab: fullscreen black, "AD" big center, countdown timer, "Skip" button (returns Failed)
- Wire ResultPanel post-match: "Double Coins via Ad" button on Win → ShowRewardedAd("post_match_double") → on Completed grant `LastReward` again
- Tests: ~3

### 6.3 — Missing screens
Add panels still empty in PanelRegistry:

#### LoadoutPanel
- PanelId.Loadout already exists. Pre-match loadout: shows player avatar + 3 booster equip slots + Stake selector (×1/×2/×3/×4 — gates by trophy threshold per v7.5).
- For 6.3: 3 equip slots reading from IBoosterInventory, click slot → opens picker modal listing owned boosters → click booster equips. Stake selector: visual ×1/×2/×3/×4 buttons, gated `_save.Trophies >= threshold`. Confirm button → MatchmakingService.SetEquippedBoosters + SetStakeMultiplier (NEW api).
- Route: Home Play button → Loadout → Confirm → Matchmaking → Match.
- Currently: Home Play directly requests match. Insert Loadout step.
- New service additions: IBoosterInventory.GetEquipped (List<string>) + IMatchmakingService.SetStakeMultiplier(int).

#### Mail/Inbox panel
- New PanelId.Mail. Vertical list of mail items (from internal stub data — gift coins, daily reward, friend reward).
- Each mail: title, body, claim button, expiry timer.
- For 6.3 hardcode 3 mail items as static stub. Mail service `IMailService.Inbox`, `Claim(id)`. Backend deferred.

#### Pack Reveal overlay
- After IPackOpener.Open or sticker pack purchase, show full-screen reveal overlay with card-flip animation per sticker
- Existing PanelId not yet — add `PanelId.PackReveal`
- PackRevealView: takes List<StickerPull>, animates one card at a time (tap to reveal), shows summary at end
- For 6.3: simple non-animated reveal — list shows all pulls in vertical scroll with rarity color, "Tap to continue" button. Animation = Phase 7 polish.

#### Sticker Detail modal
- Click sticker slot in AlbumCard → opens modal showing single sticker info (name, album, rarity, owned count)
- For 6.3 use static names per albumId+idx (hardcoded "House Red" etc.)
- New PanelId.StickerDetail. StickerDetailPanelView with Bind(albumId, idx).

#### Daily Missions modal style
- Current DailyMissionsPanel works as full panel. v7 uses modal popup with Daily/Weekly tabs.
- For 6.3: keep panel form (functional), add Daily/Weekly tabs at top. Weekly tab shows placeholder "Coming soon" content (no IWeeklyMissionService until Phase 7).

#### M5 Stake Tutorial overlay
- Currently FtueService advances stages on match complete; no UI overlay before M5 explains "stake mechanic" (per v7.5 §2)
- For 6.3 add StakeTutorialOverlay shown when entering match while stage==M5 and stake-tutorial-not-shown
- Static copy: "Stake a booster for ×2 rewards. Booster lost on loss." Single CTA "Got it" → router.GoTo(Match).

### 6.4 — Stake button on Matchmaking
- v7 has stake selector pre-match
- For 6.4 (folded into Loadout 6.3): same behavior. Confirmation: skip if redundant after 6.3 ships.

### 6.5 — Lucky Box second-chance
- Match loss → "Watch ad to retry?" popup (uses IAdService)
- For 6.5: post-loss popup on ResultPanel "Watch ad for second chance" button → ShowRewardedAd → on Completed reset match state? Too invasive for prototype. **Defer to Phase 7.**
- Instead: Result panel ad button only doubles coins (already in 6.2).

## Acceptance — playability
- New profile boots → FTUE M1 plays → progresses through M2-M5 → Completed
- Home → Play → Loadout → Matchmaking → Match → Result loop runs forever
- All 5 BottomNav tabs reachable (Shop/Teams/Home/Venue/Albums); all panels render content
- Shop purchases grant items immediately
- Result panel ad button doubles coins
- Mail panel shows stub items, claim works
- Sticker detail opens on click
- Pack reveal overlay shows pulls after pack purchase

## Tests target
- Currently 164 EditMode green
- Phase 6 adds: ~10 IAP + ~3 Ad + ~5 Mail + ~3 Loadout = ~21 new tests
- Target: ≥185 green

## Sub-project order
1. **6.1** Fake IAP
2. **6.2** Fake rewarded ad + AdPanel
3. **6.3a** LoadoutPanel + booster equip flow
4. **6.3b** PackReveal overlay
5. **6.3c** StickerDetail modal
6. **6.3d** Mail panel
7. **6.3e** Daily Missions tabs (Daily/Weekly)
8. **6.3f** M5 stake tutorial overlay
9. **6.4** verify full game loop end-to-end (manual + automated smoke)

Each ships own commit, runs tests, no UI polish (Phase 7).
