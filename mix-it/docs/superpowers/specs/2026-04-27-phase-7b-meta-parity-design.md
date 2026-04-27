# Phase 7B — Meta-loop parity (weekly cadence + leaderboard)

**Date:** 2026-04-27
**Author:** parity audit (post-Phase-7A `a5e53c5`)
**Goal:** Close the **core** functional gaps between v7 HTML and Unity port. Focus on weekly cadence and leaderboard reward grants — the loops that drive 7-day retention and competitive engagement. Skip cosmetic / social-identity / whale-pacing systems (VIP perks, public profile, username) — deferred to Phase 8.

## Context

Post-`a5e53c5` audit (see CONTINUATION.md and the v7 design docs `design-v7.0…v7.5`):
- **Match plugin parity:** complete (90 s timer, combo, autoserve, booster activations, stake×4, On Fire×2, per-arena cushion 0.70→0.50 across all 8 arenas).
- **Daily-cadence meta:** complete (DailyMissions, DailyLogin, FTUE M1–M5, LuckyBox, SecondChance, IAP×12, Loadout, PackReveal, StickerDetail, Mail).
- **Weekly-cadence meta: MISSING.** No `IWeeklyMissionService`, no `WeeklyResetService`, StarRace is lite-mode (flat 500 c at ≥3★, no per-arena leaderboard rank rewards).
- **MatchmakingService:** needs verification it follows v7.4 §2 (trophy-only band ±100), not v7.3 hybrid.
- **FTUE M5:** stake-tutorial overlay ships, but the M5 match config does not pin the opponent for a guaranteed first-stake-win (v7.4 §7 forced-win).

Tests baseline: 260 EditMode green, 0 compile errors.

## In scope

### 7B.1 — Weekly Missions service
Source: `design-v7.3-patch-mvp-completion.md` §5.

- **Pool:** 10 missions (e.g. _Win 20 matches_, _Earn 5,000 coins_, _Open 3 packs_, _Reach Trophy 1,000_, _Complete 5 Daily missions_, _Use 30 boosters in matches_, _Win 3 ×2-stake matches_, _Pull 5 Rare stickers_, _Reach 5★ in Star Race_, _Spend 2,000 coins in Shop_).
- **Active set:** 3 concurrent, deterministic-shuffled per UTC week (seed = `iso-year * 100 + iso-week`).
- **Reward per mission:** 300 c + 1 Silver pack token.
- **Full-clear bonus:** 1,500 c + 1 Gold pack token (granted on claiming the 3rd of 3).
- **Reset:** Monday 00:00 UTC; unclaimed missions are forfeited.
- **Persistence:** `SaveProfile.WeeklyMissionsIsoWeek` (int) + `WeeklyMissionsState` (`List<MissionProgress>`) + `WeeklyFullClearClaimed` (bool).
- **UI:** populate the "Weekly" tab in `DailyMissionsPanelView` (currently "Coming soon" placeholder).

### 7B.2 — Weekly Reset chest
Source: `design-v7.3` §5 (threshold chest at Monday reset).

- **Trigger:** first `Tick(now)` call after `now.IsoWeek != SaveProfile.LastWeeklyResetIsoWeek`.
- **Reward by current arena tier (highest reached this week):**
  - Arenas 1–2 (Juice, Smoothie): 300 c + 1 Silver pack
  - Arenas 3–5 (Coffee, Tea, Cocktail): 1,000 c + 1 Silver pack + 5 sticker shards
  - Arenas 6–8 (Wine, Champagne, GrandHotel): 2,500 c + 1 Gold pack + 10 sticker shards
- **Delivery:** push into `IMailService.Inbox` as a single mail item titled "Weekly Chest" so the player claims it actively (mirrors v7).
- **Persistence:** `SaveProfile.LastWeeklyResetIsoWeek` (int), `HighestArenaIdxThisWeek` (int).
- **Hook:** `FlowController.CompleteMatch` → after rating delta, update `HighestArenaIdxThisWeek`; on game start (`Bootstrap`) call `WeeklyResetService.TickIfNeeded(DateTime.UtcNow)`.

### 7B.3 — Star Race v2 (per-arena leaderboard + rank rewards)
Source: `design-v7.3` §4. Replaces current lite implementation in [`StarRaceService.cs`](MixIt/Assets/_Archetype/Runtime/StarRaceService.cs).

- **Star earn (unchanged from v7):** 3★ on win-margin ≥30 %, 2★ on any win, 1★ on loss; per-arena tally.
- **Synthetic local leaderboard:** for prototype, generate 100 fake competitors per arena seeded by `(IsoWeek, ArenaIdx)` — names from a static pool, star totals from `Normal(μ=star_count_after_N_matches, σ)` so the player's rank is plausible. **No server, no live data.**
- **Rank tier rewards (granted at Monday reset, mailed via `IMailService`):**
  - Top 1 %: 2,000 c + 1 Gold pack + 1 Diamond shard
  - Top 5 %: 1,000 c + 1 Silver pack
  - Top 25 %: 500 c
  - Participation: 100 c
- **Per-arena scope:** rewards scale ×1 / ×1.5 / ×2 for arena tiers 1-2 / 3-5 / 6-8 (matches Weekly Reset philosophy).
- **Persistence:** `SaveProfile.StarRaceArenaStars` (`List<Pair<arenaIdx,int>>`), `LastStarRaceIsoWeek`, `StarRaceRankClaimedThisWeek`.
- **API:** keep `IStarRaceService.Stars`, add `GetStarsByArena(int arenaIdx)`, `GetSyntheticRank(int arenaIdx)` (returns 1-based rank in fake leaderboard of 101), `Tick(DateTime utcNow)`.
- **HomePanel chip:** unchanged shape, label updated to show current-arena stars + synthetic rank ("12★ · Top 8 %").

### 7B.4 — Matchmaking trophy-only audit
Source: `design-v7.4` §2 Q3 (final decision: trophy band ±100, no hidden WR second-pass).

- Read [`MatchmakingService.cs`](MixIt/Assets/_Archetype/Runtime/MatchmakingService.cs) end-to-end; document selection algorithm in a header comment citing v7.4 §2.
- **If hybrid logic is present:** strip it, keep trophy-band selection only.
- Add `MatchmakingServiceTests.SelectsWithinTrophyBand_NoWinRateBias` test that runs 1,000 rolls and asserts opponent trophies ∈ `[player−100, player+100]` and that low-WR opponents are not preferentially picked.

### 7B.5 — FTUE M5 forced-win match config
Source: `design-v7.4` §7.

- M5 should guarantee a player win on the staked match so the player experiences the "+coins on stake" payoff before the post-tutorial difficulty curve.
- In `FtueService` for `FtueStage.M5`: pass an `FtueMatchConfig` with `ForcePlayerWin = true` (new bool); plumb to `OpponentAI` as a `forceLossUntil = MatchEnd` flag that holds back pours after the player has scored ≥30 % margin. **Do not stop opponent from playing entirely** (keeps the screen alive); just cap their rate so player wins.

## Out of scope (Phase 8 — Cosmetic / Social parity)

- VIP service (10 tiers, point grants, perk wiring to CoinService/BoosterShop/DailyMissions/LuckyBox)
- Public profile view + leaderboard tap routing
- Username field + profanity filter + report button
- District selector widget on Home
- Star Race full leaderboard panel (v7 has a dedicated panel; chip on Home is sufficient for prototype)
- Real Apple/Google IAP, real ad mediation, analytics backend, server matchmaking — all Phase 9 (Launch).

## Acceptance

- New profile: ticks through 4 simulated weekly resets (`IUtcClock` injected) without crashing.
- 3 weekly missions appear in Weekly tab, claim grants 300 c + Silver pack each, full-clear grants 1,500 c + Gold.
- Weekly Reset chest mail appears in inbox on first match after week rollover; reward matches arena tier.
- Star Race chip on Home shows per-arena stars and a plausible synthetic rank; ranking rewards mail at week rollover.
- `MatchmakingServiceTests` includes the trophy-band assertion.
- FTUE M5: opponent is throttled so player wins the staked match.

## Tests target

- 7B.1 Weekly Missions: ~10 tests (rollover, deterministic shuffle, claim grants, full-clear, persist, week-mismatch reset, forfeit unclaimed, idempotent Tick, IsoWeek math, edge week-53)
- 7B.2 Weekly Reset chest: ~6 tests (trigger only on rollover, mail item created, arena-tier reward variants 1–2 / 3–5 / 6–8, idempotent within same week, persists `LastWeeklyResetIsoWeek`)
- 7B.3 Star Race v2: ~10 tests (per-arena tally, synthetic rank determinism, rank-reward tiers ×1/1.5/2, weekly reset clears stars, mail integration, claim once, lite→v2 migration of legacy `Stars` field)
- 7B.4 MM audit: ~2 tests (trophy band, no WR bias)
- 7B.5 FTUE M5 forced-win: ~2 tests (M5 sets ForcePlayerWin, opponent rate capped)

**Total: ~30 new tests → target ≥ 290 EditMode green.**

## Sub-project order

1. **7B.4** MM audit (small, unblocks confidence)
2. **7B.1** Weekly Missions (largest, single-commit)
3. **7B.2** Weekly Reset chest (depends on 7B.1's IsoWeek helper)
4. **7B.3** Star Race v2 (depends on 7B.2's mail wiring)
5. **7B.5** FTUE M5 forced-win (smallest, ships last)

Each ships as its own atomic commit. No UI polish, no sprite work — all panel additions are layout-only on placeholder colors per Phase 5 conventions.

## Risks / open questions

- **IsoWeek implementation:** Unity .NET supports `ISOWeek.GetWeekOfYear` (System namespace). Verify on target Unity 6.3 BCL before relying on it; fall back to manual Thursday-of-week algorithm if missing.
- **Synthetic leaderboard fairness:** seed must be stable across save/load so a player's rank doesn't jitter. Use `(IsoYear, IsoWeek, ArenaIdx)` as the System.Random seed.
- **Mail integration:** current `IMailService` is a 3-item static stub from Phase 6.3d. Adding mutable `Add(MailItem)` is required for 7B.2 and 7B.3. Will need to decide if pre-existing static items stay (recommended: yes, append-only).
- **Migration of legacy `StarRaceService` save data:** existing `SaveProfile.StarRace.Stars` is a flat int. On 7B.3 first run, copy it into `StarRaceArenaStars[currentArena]` so live profiles don't lose progress.
