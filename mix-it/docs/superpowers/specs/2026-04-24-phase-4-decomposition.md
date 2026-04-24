# Phase 4 — UI Surface Decomposition

**Date:** 2026-04-24
**Parent:** Unity port master plan.
**Sources:** `index-v7.html` (reference HTML UI), `design-v7.3-patch-mvp-completion.md`, `design-v7.4-patch-ftue-tuning.md`, `design-v7.5-patch-pre-launch-polish.md`.

## 1. Goal

Surface all Phase 3 headless services via UGUI panels. Hook routing, bind service state → view, wire button handlers back to services. No polish/animation/VFX (Phase 5). No IAP/ads (Phase 6).

## 2. Guiding principles

- UGUI (same pattern as Phase 0-2 panels: code-built MonoBehaviour panel, no prefabs unless necessary)
- Each panel reads service state on Show, subscribes to change events, unbinds on Hide
- Router flow: Home is hub; side-panels push onto stack, back button pops
- All button handlers route through services, never mutate SaveProfile directly
- Keep plugin asmdef boundary intact — UI is archetype-only

## 3. Sub-project breakdown

### 4.1 — HUD + HomePanel expansion
**Scope:** Coins label, Trophy label, Arena badge, nav buttons for each meta panel. Red-dot indicators (PendingClaimable counts via TrophyRoadService / BarPassService / DailyMissionService / VenueService).
**Deps:** ICurrencyService, IRatingService, ITrophyRoadService, IBarPassService, IDailyMissionService, IVenueService, IFtueService (starter pack red-dot).
**Effort:** ~1 session

### 4.2 — TrophyRoadPanel + BarPassPanel
**Scope:** Vertical list of milestones/tiers with claimed/claimable/locked states. Claim buttons. BarPass: BPP bar, tier N progress, bonus bank display.
**Deps:** ITrophyRoadService, IBarPassService.
**Effort:** ~1 session

### 4.3 — DailyMissionsPanel + ResultPanel upgrade
**Scope:** 3 mission cards with progress bars + claim. Result panel: trophy delta, coins earned, BPP gain, mission-progress ticks.
**Deps:** IDailyMissionService, IRatingService, IBarPassService (deltas via FlowController snapshots).
**Effort:** ~1 session

### 4.4 — ShopPanel + FlashOffer popup
**Scope:** Booster catalog grid (tier-grouped), purchase flow with coin deduction, insufficient-coins feedback. Flash offer banner/popup (comeback / refill / promotion).
**Deps:** IBoosterShop, IBoosterInventory, IFlashOfferService, ICurrencyService.
**Effort:** ~1 session

### 4.5 — VenuePanel + AlbumPanel
**Scope:** Venue: 3 district cards with unlock/claim state. Album: 4 albums, page grid of sticker slots (owned/missing), per-page + full claim buttons, sticker tokens counter. First-view album triggers FTUE welcome pack (IFtueService.OnAlbumFirstViewed).
**Deps:** IVenueService, IAlbumService, IFtueService, IPackOpener.
**Effort:** ~1 session

### 4.6 — FTUE overlays + Starter Pack popup
**Scope:** Welcome overlay (M1), patience-timer overlay (M2), Trophy Road reveal popup (post-M3), stake-teaser popup (post-M4), M5 stake tutorial overlay + result cascade, Starter Pack popup (post-M5). Overlay routing via UIRouter stack.
**Deps:** IFtueService.
**Effort:** ~1 session

### 4.7 — Avatar/frame cosmetic wiring
**Scope:** Home + Matchmaking show player avatar; render "Apprentice Bartender" frame if `HasApprenticeFrame`. Placeholder rectangle sprites (final art Phase 5).
**Deps:** ISaveProfile.HasApprenticeFrame.
**Effort:** ~0.5 session

## 4. Sub-project order

Recommended: 4.1 → 4.2 → 4.3 → 4.4 → 4.5 → 4.6 → 4.7.

Rationale:
- 4.1 gates all nav (need buttons to reach other panels for testing)
- 4.2/4.3 hit most services already shipped in Phase 3.4
- 4.4 exercises economy loop (visible coin spend / grants)
- 4.5 unlocks Album first-view → FTUE integration sanity
- 4.6 final because it overlays on top of everything else
- 4.7 can slot in anywhere late

## 5. Testing strategy

- EditMode unit tests continue for any new archetype logic (likely minimal — panels are mostly presentation)
- Add PlayMode smoke tests per sub-project: open panel, verify key elements exist, simulate tap → state changes, close panel
- Target: ≥ 162 + 10-20 new = ~175-180 total

## 6. Acceptance per sub-project

- All buttons routable back to Home
- Service state reflected on Show + updated on change
- No MissingReferenceException on panel teardown
- Emoji/sprite placeholders acceptable; real art Phase 5
- Plugin unchanged

## 7. Deferred from Phase 4

- Animation / juice / particle VFX (Phase 5)
- Real sprite/frame art (Phase 5)
- Audio (Phase 5)
- IAP UI (Phase 6)
- Rewarded video placements (Phase 6)
- Weekly missions + Star Race UI (Phase 4 candidate if scope allows; currently out)
