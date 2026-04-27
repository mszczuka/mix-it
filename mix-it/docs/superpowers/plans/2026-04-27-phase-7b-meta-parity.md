# Phase 7B — Meta-loop parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Each numbered Task = one atomic commit. Run `run-tests.bat` after every Task; do not advance until green.

**Spec:** [`../specs/2026-04-27-phase-7b-meta-parity-design.md`](../specs/2026-04-27-phase-7b-meta-parity-design.md)
**Unity project root:** `d:\ClaudeUnityProjects\mix-it\MixIt` (Unity 6000.3.14f1)
**Baseline:** 260 EditMode green at commit `a5e53c5` (Phase 7A functional parity).
**Target:** ≥ 290 EditMode green.

---

## File map

```
Assets/_Archetype/
├── Contracts/
│   ├── IUtcClock.cs                    (NEW — testable clock)
│   ├── IWeeklyMissionService.cs        (NEW)
│   ├── IWeeklyResetService.cs          (NEW)
│   ├── IMailService.cs                 (MODIFY — add Add(MailItem))
│   ├── WeeklyMission.cs                (NEW record)
│   ├── MailItem.cs                     (MODIFY — confirm mutable list-friendly)
│   └── ISaveProfile.cs                 (MODIFY — add weekly fields)
├── Runtime/
│   ├── SystemUtcClock.cs               (NEW)
│   ├── IsoWeek.cs                      (NEW — wraps System.Globalization.ISOWeek)
│   ├── WeeklyMissionCatalog.cs         (NEW — pool of 10)
│   ├── WeeklyMissionService.cs         (NEW)
│   ├── WeeklyResetService.cs           (NEW)
│   ├── StarRaceService.cs              (REWRITE — per-arena + rank)
│   ├── MailService.cs                  (MODIFY — append-only Add)
│   ├── MatchmakingService.cs           (AUDIT — verify trophy-only, header comment)
│   ├── FtueService.cs                  (MODIFY — M5 ForcePlayerWin)
│   ├── FlowController.cs               (MODIFY — wire weekly tick + arena tracking)
│   └── Persistence/SaveProfile.cs      (MODIFY — new fields)
├── UI/Panels/
│   └── DailyMissionsPanelView.cs       (MODIFY — Weekly tab populates from WeeklyMissionService)
└── _Game/Bootstrap/
    └── GameLifetimeScope.cs            (MODIFY — register new services)

Assets/_Plugins/LiquidPuzzles/Runtime/
├── Config/FtueMatchConfig.cs           (MODIFY — add ForcePlayerWin bool)
└── Simulation/OpponentAI.cs            (MODIFY — honour ForcePlayerWin throttle)

Assets/_Tests/EditMode/
├── IsoWeekTests.cs                     (NEW)
├── WeeklyMissionServiceTests.cs        (NEW, ~10)
├── WeeklyResetServiceTests.cs          (NEW, ~6)
├── StarRaceServiceTests.cs             (REWRITE/EXTEND, ~10)
├── MatchmakingServiceTests.cs          (EXTEND, ~2)
└── FtueServiceTests.cs                 (EXTEND, ~2)
```

---

## Task 1 — Matchmaking trophy-only audit (warm-up, ships first)

**Why first:** smallest, builds confidence the existing service matches v7.4 §2 before piling new code on top.

- [ ] **1.1** Read `MatchmakingService.cs` end-to-end. Record current selection algorithm.
- [ ] **1.2** If hidden-WR / hybrid logic exists, strip it. Keep only trophy band ±100.
- [ ] **1.3** Add file-header comment citing `design-v7.4` §2 Q3 (trophy-only band).
- [ ] **1.4** Add `MatchmakingServiceTests.SelectsWithinTrophyBand_NoWinRateBias`:
  - Seed 1,000 deterministic rolls with player at 1,500 trophies.
  - Assert every selection's trophies ∈ `[1400, 1600]`.
  - Assert no statistically significant bias toward low-WR personas (split selections by WR<0.5 vs ≥0.5; expect ~50/50 ± 5 %).
- [ ] **1.5** Run `run-tests.bat` — expect 261 green.
- [ ] **1.6** Commit: `audit(mm): trophy-only band confirmed per v7.4 §2 (+test)`

---

## Task 2 — IUtcClock + IsoWeek helper

**Why before 7B.1:** weekly logic across three services needs a single injectable clock + week-math source. Doing this once avoids three ad-hoc copies.

- [ ] **2.1** Create `Contracts/IUtcClock.cs` — `DateTime UtcNow { get; }`.
- [ ] **2.2** Create `Runtime/SystemUtcClock.cs` — returns `DateTime.UtcNow`.
- [ ] **2.3** Create `Runtime/IsoWeek.cs`:
  - `int Of(DateTime utc)` → packed `IsoYear * 100 + IsoWeek` using `System.Globalization.ISOWeek.GetYear/GetWeekOfYear`.
  - Verify ISOWeek availability on Unity 6.3 BCL; if missing, hand-roll Thursday-of-week algorithm.
  - `DateTime MondayUtcOf(DateTime utc)` for reset-time anchoring.
- [ ] **2.4** `IsoWeekTests.cs`: tests for week-1, week-53 (2020 had it), Sunday-vs-Monday boundary, year boundary 2024→2025.
- [ ] **2.5** Register `SystemUtcClock` as `IUtcClock` in `GameLifetimeScope`.
- [ ] **2.6** `run-tests.bat` — expect ~265 green.
- [ ] **2.7** Commit: `feat(archetype): IUtcClock + IsoWeek helper`

---

## Task 3 — Weekly Missions service (7B.1)

- [ ] **3.1** Create `Contracts/WeeklyMission.cs` (record): `Id, Title, ProgressTarget, RewardCoins, RewardSilverTokens`.
- [ ] **3.2** Create `Contracts/IWeeklyMissionService.cs`:
  - `IReadOnlyList<MissionProgress> Active { get; }`
  - `void Track(string eventKey, int delta)`
  - `bool Claim(int missionIdx)` (returns false if not complete or already claimed)
  - `bool FullClearAvailable { get; }`
  - `bool ClaimFullClear()`
  - `void Tick(DateTime utcNow)` (rolls over week, re-rolls active set)
- [ ] **3.3** Create `Runtime/WeeklyMissionCatalog.cs`: static `IReadOnlyList<WeeklyMission> All` of 10 missions per spec §7B.1.
- [ ] **3.4** Create `Runtime/WeeklyMissionService.cs`:
  - Ctor: `(ISaveProfile, IUtcClock, ICurrencyService, IPackOpener, IAnalyticsService)`
  - On construct: call `Tick(_clock.UtcNow)`.
  - Active set picked by `new System.Random(IsoWeek.Of(now)).Sample(catalog, 3)` — deterministic per week.
  - Track maps event keys → matching mission predicates (e.g. `"match_won"`, `"coins_earned"`, `"pack_opened"`, `"trophy_reached"`, `"daily_claimed"`, `"booster_used"`, `"stake_match_won"`, `"rare_pulled"`, `"star_earned"`, `"shop_spent"`).
  - Claim grants 300 c + 1 SilverPackToken, marks claimed in `SaveProfile.WeeklyMissionsState`.
  - FullClear: when all 3 are claimed, grant 1,500 c + 1 GoldPackToken once.
- [ ] **3.5** Modify `SaveProfile.cs`: add `WeeklyMissionsIsoWeek` (int), `WeeklyMissionsState` (`List<MissionProgress>`), `WeeklyFullClearClaimed` (bool). Mirror in `JsonSaveStore` write/read.
- [ ] **3.6** Modify `DailyMissionsPanelView.cs`: Weekly tab now binds to `IWeeklyMissionService.Active`; render same row template as Daily; Claim button calls `Claim(idx)`; show full-clear chest CTA when `FullClearAvailable`.
- [ ] **3.7** Hook tracking calls in `FlowController.CompleteMatch`, `CoinService.AddCoins`, `PackOpener.Open`, `RatingService.OnTrophyChanged`, `DailyMissionService.Claim`, `BoosterInventoryService.Use`, `AlbumService.OnPullReceived`, `BoosterShopService.Buy`, `StarRaceService.OnStarEarned`.
- [ ] **3.8** Register `WeeklyMissionService` in `GameLifetimeScope` (singleton, `IWeeklyMissionService`).
- [ ] **3.9** `WeeklyMissionServiceTests.cs` — 10 tests:
  1. First Tick on empty profile sets IsoWeek + populates 3 active.
  2. Same week → second Tick is no-op.
  3. Different week → new shuffle, claimed flags reset, FullClearClaimed reset.
  4. Track increments matching mission progress, ignores others.
  5. Claim refuses when below target.
  6. Claim grants 300 c + 1 SilverToken, marks claimed.
  7. Claim refuses second time on same idx.
  8. FullClearAvailable true only when 3/3 claimed.
  9. ClaimFullClear grants 1,500 c + 1 GoldToken once.
  10. Deterministic shuffle: same IsoWeek → same 3 missions across two services.
- [ ] **3.10** `run-tests.bat` — expect ~275 green.
- [ ] **3.11** Commit: `feat(archetype): Weekly Missions service + UI binding (v7.3 §5)`

---

## Task 4 — Weekly Reset chest (7B.2)

- [ ] **4.1** Modify `IMailService` + `MailService`:
  - Add `void Add(MailItem item)` (append-only).
  - Ensure `MailItem` reward shape can carry coins + pack tokens + sticker shards.
- [ ] **4.2** Create `Contracts/IWeeklyResetService.cs`: `void TickIfNeeded(DateTime utcNow)`.
- [ ] **4.3** Create `Runtime/WeeklyResetService.cs`:
  - Ctor: `(ISaveProfile, IUtcClock, IMailService)`.
  - On `TickIfNeeded`, if `IsoWeek.Of(utcNow) != save.LastWeeklyResetIsoWeek`:
    - Compute reward bundle from `save.HighestArenaIdxThisWeek` (0..7) per spec §7B.2 tiers.
    - `mail.Add(new MailItem("Weekly Chest", body, rewards))`.
    - `save.LastWeeklyResetIsoWeek = currentIsoWeek; save.HighestArenaIdxThisWeek = currentArenaIdx;`
- [ ] **4.4** Modify `SaveProfile.cs`: `LastWeeklyResetIsoWeek` (int), `HighestArenaIdxThisWeek` (int).
- [ ] **4.5** Hook `FlowController.CompleteMatch`: after rating delta, `save.HighestArenaIdxThisWeek = max(save.HighestArenaIdxThisWeek, currentArenaIdx)`.
- [ ] **4.6** Hook `Bootstrap` / `GameLifetimeScope.OnStart`: call `IWeeklyResetService.TickIfNeeded`.
- [ ] **4.7** Register in DI.
- [ ] **4.8** `WeeklyResetServiceTests.cs` — 6 tests:
  1. First Tick on fresh profile creates mail (counts as week-rollover).
  2. Same-week second Tick no-ops.
  3. Different IsoWeek → mail created, state advanced.
  4. Reward variant for HighestArenaIdx 0 → 300c + Silver.
  5. Reward variant for idx 4 → 1000c + Silver + 5 shards.
  6. Reward variant for idx 7 → 2500c + Gold + 10 shards.
- [ ] **4.9** `run-tests.bat` — expect ~281 green.
- [ ] **4.10** Commit: `feat(archetype): Weekly Reset chest via mail (v7.3 §5)`

---

## Task 5 — Star Race v2 (7B.3)

- [ ] **5.1** Modify `IStarRaceService`:
  - `int GetStarsByArena(int arenaIdx)`
  - `int GetSyntheticRank(int arenaIdx)` (1-based, leaderboard size 101)
  - `int GetSyntheticPercentile(int arenaIdx)`
  - keep `Stars` (deprecated, returns sum across arenas)
- [ ] **5.2** Rewrite `Runtime/StarRaceService.cs`:
  - Ctor: `(ISaveProfile, IUtcClock, IMailService, ICurrencyService)`.
  - `OnMatchCompleted(arenaIdx, MatchOutcome, marginPct)`: tally stars per arena (3 / 2 / 1).
  - `Tick(utcNow)`: on week rollover, compute rank-tier reward per arena where stars>0, mail it, then clear `StarRaceArenaStars`.
  - Synthetic leaderboard: `new System.Random((isoWeek * 100) + arenaIdx).Sample()` generates 100 fake competitor star totals from `Normal(μ=playerStars × 1.05, σ=playerStars × 0.4)` clamped to ≥0; player's rank = `1 + count(competitors > playerStars)`.
- [ ] **5.3** Modify `SaveProfile.cs`:
  - Add `StarRaceArenaStars` (`List<Pair<int,int>>` arenaIdx → stars).
  - Add `LastStarRaceIsoWeek` (int).
  - Add `StarRaceRankClaimedThisWeek` (bool — used to gate reward grant idempotently).
  - Migration: on first read, if legacy `StarRace.Stars > 0`, push `(currentArenaIdx, legacyStars)` into the new list and zero the legacy field.
- [ ] **5.4** Modify `FlowController.CompleteMatch`: pass `arenaIdx` and `marginPct` (already computed) to `IStarRaceService.OnMatchCompleted`.
- [ ] **5.5** Modify `HomePanelView`: chip text becomes `"{stars}★ · Top {percentile} %"` for the player's current arena.
- [ ] **5.6** `StarRaceServiceTests.cs` — 10 tests:
  1. 3★ on win-margin ≥30 %.
  2. 2★ on win <30 % margin.
  3. 1★ on loss.
  4. Stars are tallied per arena, not pooled.
  5. Synthetic rank deterministic: same `(IsoWeek, arenaIdx, playerStars)` → same rank twice.
  6. Synthetic rank scales: 0 stars ≈ bottom; very-high stars ≈ rank 1.
  7. Tick on rollover creates mail per arena with stars > 0.
  8. Reward tier ×1 for arena 0–1, ×1.5 for 2–4, ×2 for 5–7.
  9. Tick clears arena stars and advances `LastStarRaceIsoWeek`.
  10. Migration: legacy `Stars=4, currentArena=2` → new list contains `(2,4)` and legacy zeroed.
- [ ] **5.7** `run-tests.bat` — expect ~291 green.
- [ ] **5.8** Commit: `feat(archetype): Star Race v2 — per-arena leaderboard + rank rewards (v7.3 §4)`

---

## Task 6 — FTUE M5 forced-win (7B.5)

- [ ] **6.1** Modify `Plugin/LiquidPuzzles/Runtime/Config/FtueMatchConfig.cs`: add `bool ForcePlayerWin = false`.
- [ ] **6.2** Modify `Plugin/LiquidPuzzles/Runtime/Simulation/OpponentAI.cs`:
  - Read a `forcePlayerWin` flag (passed via session config).
  - When set and player's score margin <30 %, behave normally; when margin ≥30 %, throttle pour interval ×3 so player widens the lead.
- [ ] **6.3** Modify `FtueService` for `FtueStage.M5`: set `ForcePlayerWin = true` on the emitted `FtueMatchConfig`.
- [ ] **6.4** Modify `LiquidPuzzlesMatchSession` to plumb `ForcePlayerWin` from config into `OpponentAI`.
- [ ] **6.5** `FtueServiceTests.M5_ForcesPlayerWin`:
  - Stub `OpponentAI` with a recorder; assert `forcePlayerWin == true` on M5 entry, `false` on all other stages.
- [ ] **6.6** `OpponentAITests.ForcedLossThrottlesAfterMargin`:
  - Drive AI with player at +35 % margin; assert pour interval is ×3 baseline.
- [ ] **6.7** `run-tests.bat` — expect ~293 green.
- [ ] **6.8** Commit: `feat(plugin): FTUE M5 forced-win for stake-payoff moment (v7.4 §7)`

---

## Task 8 — HudBar (top menu) + BottomNav parity audit

**Why added (post-hoc, 2026-04-27):** user request — verify both persistent overlays display all HTML v7 info and react correctly. Read-only audit unless gaps found.

- [ ] **8.1** Read `MixIt/Assets/_Archetype/UI/Panels/HudBarView.cs` + `BottomNavView.cs` (or whatever the persistent-overlay class names are — check `_Archetype/UI/` and the persistent-HUD/BottomNav refactor commit `cae26a2`).
- [ ] **8.2** Read v7 sources: `index-v7.html` HUD/footer DOM + `design-v7.0` §UI + any `design-v7.x` patches that touched HUD/BottomNav (esp. `design-v7.5-patch-pre-launch-polish.md`). Enumerate every chip/button/icon/label v7 shows.
- [ ] **8.3** For each v7 element, classify Unity status: present-correct / present-but-wrong-binding / present-but-stale-data / missing.
  - HudBar candidates: avatar + frame, username, trophy count + arena name, coins, gems (if any), star-race chip, login-bonus indicator, lucky-box %, settings/profile gear.
  - BottomNav candidates: 5 tabs (Shop / Teams / Home / Venue / Album), active-state highlighting, badge dots for unread mail / claimable missions / claimable lucky-box / claimable star-race / pending pack-reveal.
- [ ] **8.4** Verify routing: each nav button's onClick goes to the correct `PanelId` via `IUIRouter`. Active-state visual updates when route changes (check for an `IUIRouter.OnPanelChanged` listener or equivalent).
- [ ] **8.5** Verify reactivity: HudBar values update when the underlying service mutates. Specifically:
  - Coins: `ICurrencyService.OnBalanceChanged` (or polling in Update) is wired.
  - Trophies: `IRatingService` change event is wired.
  - StarRace chip: `IStarRaceService` star-earned event is wired (post-Task 5 expected).
  - Mail badge: `IMailService.UnclaimedCount` re-read after Add/Claim.
  - LuckyBox %: `ILuckyBoxService` progress event.
- [ ] **8.6** Produce a markdown audit report at `docs/superpowers/specs/2026-04-27-phase-7b-task8-hudbar-bottomnav-audit.md` with: matrix of v7 element × Unity status × evidence (file:line). Recommend fix tasks for any gaps; classify each as blocker / important / nice-to-have.
- [ ] **8.7** If gaps are blocker-tier, ship a follow-up commit fixing them inline; otherwise leave for Phase 7C / 8.
- [ ] **8.8** Commit the audit doc: `docs(audit): HudBar + BottomNav v7 parity report`.

---

## Task 7 — PHASE_7B_DONE marker

- [ ] **7.1** Create `MixIt/Assets/_Game/PHASE_7B_DONE.md` summarising what shipped, test count, deferred items (VIP perks, public profile, username, district selector, full StarRace panel, real IAP/ads/server).
- [ ] **7.2** Update `docs/superpowers/CONTINUATION.md`:
  - Bump "Last updated".
  - Add Phase 7B to "Shipped" list.
  - Update test count (≥ 290).
- [ ] **7.3** Commit: `docs: Phase 7B done marker — meta-loop parity`

---

## Sequencing notes

- Tasks 1, 2 are **independent** of each other and of the rest — could parallelise across worktrees, but commit order must remain `1 → 2 → 3 → 4 → 5 → 6` since 3-5 depend on 2's IsoWeek and 4-5 depend on the mutable mail API.
- After Task 2 ships, Tasks 3, 4, 6 are **independent** and could be dispatched as parallel subagents; Task 5 must follow Task 4 (uses `IMailService.Add`).
- Recommended execution: serial through Task 1-2, then dispatch 3 + 6 in parallel (no shared files), then 4, then 5, then 7.

## Risks

- **ISOWeek BCL availability:** verify in Task 2.3 before relying on it. Manual fallback adds ~30 min if missing.
- **DailyMissionsPanelView coupling:** Weekly tab and Daily tab now share row-template code. Refactor to a `MissionRowView` if the panel becomes hard to read; otherwise leave duplicated.
- **Synthetic leaderboard plausibility:** if playtesters notice rank changes that don't track their effort, tweak `Normal` σ or switch to a curve seeded by total stars across all players (server-side, Phase 9).
- **Save migration:** Task 5.3 migration must be tested with a legacy save fixture; otherwise live profiles regress to 0 stars on first load.
