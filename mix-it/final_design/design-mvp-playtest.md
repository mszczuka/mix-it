# MixIt — MVP Playtest Design

**Status:** Design agreement (this session, 2026-05-19)
**Scope:** Vertical slice for first external playtest (3–7 day window)
**Archetype:** PvP arena 1v1 (real-time, bot-driven opponents framed as PvP)
**Not in scope:** Soft launch, full live-ops, post-MVP roadmap

---

## 1. Purpose of the test

A playtest of this size answers **four questions**:

1. **Is a single match fun and readable?** (core 90s loop)
2. **Does winning/losing feel fair?** (matchmaking + rating)
3. **Does the climb pull players back tomorrow?** (arena ladder + retention hooks)
4. **Do the core meta hooks land?** (daily missions, Star Race, Stakes wager — each gets enough exposure for telemetry, but heavy meta is cut)

The cuts are aggressive — every system not core to the MVP is disabled — but the **retention/monetization-validation hooks** that we'd lose signal without are kept: Stakes (do players take risks?), Star Race (do players come back this week?), full Daily Missions (do they engage daily?), full FTUE (does onboarding hold?).

---

## 2. What ships in the slice

### Core match (LiquidPuzzles plugin)
- Pour / mix / serve customers, 90s timer, customer queue, scoring
- Real-time tap input vs `OpponentAI` bot
- **Polish gate before test:** serve VFX, customer reactions, combo glow, basic SFX. Unjuiced playtest of a real-time skill game produces false-negative feedback.

### Match flow
- Home → Matchmaking (vs persona, ±100 trophy band) → Match → Result → Home
- Result screen: outcome banner, coins, trophy delta, mission tick

### Climb — 4 arenas only
- Juice → Smoothie → Coffee → Cocktail. See §3.
- Arenas 5–14 disabled in config (not deleted — re-enabled post-test).

### Trophy Road — truncated
- **8 milestones** (≈2 per arena). Coins + 1 booster per milestone. No pack tokens, no sticker rewards.

### Stakes ×2/×3/×4 — IN
- **Unlocks at Arena 2 (Smoothie, 150 trophies)** — proportional to final design's arena-8-of-14 unlock (~50% through ladder).
- Pure trophy + coin multiplier on outcomes. No coin entry fee (Match Masters–style — see [design-systems.md §2](design-systems.md)).
- Per-stake matchmaking pools, downgrade-to-×1 after 30 s without opponent.
- Telemetry: stake selection rate per arena, win/loss outcome per stake level.

### Daily Missions — full 3-mission slate
- **3 active daily missions per day**, refreshed at local midnight. One per verb-class (Outcome / Plugin / Mastery) — see [design-progression.md §6](design-progression.md).
- Per-mission reward: 50–100 coins (scales by arena).
- **All-3 daily bonus:** 1 free random booster from the highest unlocked tier (50/35/15 bronze/silver/gold).
- Telemetry: per-mission completion rate, all-3 completion rate, per-class engagement.

### Star Race — IN
- **Weekly leaderboard cycle, cosmetic-only**, decoupled from the trophy ladder. See [design-progression.md §7](design-progression.md).
- Star formula: outcome (win 3 / draw 1 / loss 0) + serves contribution (≥8 = +1, ≥12 = +2) + On Fire bonus (+1).
- Bucketed ~100-entity leaderboards on trophy range (±400). Bots fill thin buckets.
- Reset Monday 00:00 local. Cosmetic frame rewards per leaderboard tier.
- Telemetry: stars/match distribution, weekly bucket position, return rate on Monday morning.

### Minimum meta
- **Coins only.** No BPP, no sticker tokens, no Silver/Gold pack tokens.
- **Booster roster:** the 9-booster MVP set (see [design-boosters.md](design-boosters.md)) — Bronze (Extra Bottle, Mise en Place, Combo Primer), Silver (Color Splash, Tube Sort, Customer Lock), Gold (Clear Bottle, Bottle Lock, Time Freeze). Unlocked across the 4 arenas as appropriate (Mise en Place + Extra Bottle starters, Combo Primer at Smoothie, Color Splash at Coffee, Customer Lock at Cocktail — Tube Sort / Bottle Lock / Time Freeze locked until post-MVP arenas).
- **FTUE: full M1–M4** (M1 pour learn → M2 spawn → M3 walkaway → M4 first bot match). See [design-systems.md §8](design-systems.md). Bot match is part of MVP onboarding, not deferred.

### Tech / infra
- Fake IAP + Fake Ads stubs (already shipped)
- Logging analytics piped to a single funnel
- Local save

---

## 3. Arena ladder (4 arenas)

| Idx | Arena    | MinTrophies (floor) | Win | Loss | Net @ 50% WR |
|----:|----------|--------------------:|----:|-----:|-------------:|
| 0   | Juice    | 0                   | +25 | −15  | +5           |
| 1   | Smoothie | 150                 | +25 | −15  | +5           |
| 2   | Coffee   | 350                 | +25 | −18  | +3.5         |
| 3   | Cocktail | 700                 | +25 | −20  | +2.5         |

### Rationale

- **4 arenas, not 3**, so top 5% of testers don't cap on Day 1 and lose retention signal. Not 8 because over-extending past Cocktail produces no signal for the test.
- **Asymmetric trophies (+25/−15).** Symmetric +30/−30 leaves the loop emotionally flat — every loss erases a win 1:1, climb feels like luck. Pure Match Masters-style 5:1 (+25/−5) over-compresses the distribution in a small ceiling and feels like "litość systemu" in a skill-driven game where players know they lost on their own merit. Moderate 1.7:1 baseline keeps loss stakes real while gain-coding the loop.
- **Escalating loss penalty** (−15/−18/−20) at upper arenas: natural soft cap on speed-runners reaching Cocktail in 30 matches, without breaking onboarding.
- **On Fire ×2** stays on wins (+50 streaked). Loss never doubled.
- **Stakes ×2/×3/×4 unlocked at Smoothie (Arena 2, 150 trophies).** Pure trophy + coin multiplier on outcomes — no coin entry fee. Below Smoothie, only ×1 available, selector UI hidden.
- **Cross-arena scaling preserved** from existing `RatingService` (matched opponent at +1 arena: win +13, loss −8 via WinScale/LossScale).

### Hard floors — Match Masters "secured rank" model

Trophies cannot drop below `currentArena.MinTrophies`. Once a tester crosses 150 → Smoothie, they cannot demote back to Juice, ever. Same at every arena boundary.

No demotion banners. No protective buffer logic. No per-arena exception rules. **One rule, applied uniformly.** Reasoning:
- Genre expects loss stakes — preserved *within* an arena (you can lose 200 trophies in Coffee and feel it)
- **Genre uses hard floors below the top-tier reset threshold.** Verified: Clash Royale uses hard arena gates below 10,000 trophies with no demotion (soft reset only above 10k); Match Masters has no reset below 30k Legends League; Brawl Stars per-brawler floor at 1,000 trophies. Our 14-arena ladder (0 → 4,400) sits entirely in the "below threshold" zone of every reference, so no-reset + hard floor is the genre-correct pattern (sources: Supercell Support; RoyaleAPI 2025-07; Match Masters Fandom; Supercell News 2024-26)
- Test signal "did this tester reach Arena N?" stays clean — no oscillation noise
- Simple to implement (1 line change in `RatingService.ApplyLoss`)

---

## 4. Expected distribution

3 cohorts over 3–7 day window, ~3 min/match:

| Cohort   | Matches | Median end trophies | Likely arena   | % expected |
|----------|--------:|--------------------:|----------------|-----------:|
| Casual   | 30      | ~150 (Smoothie floor) | Smoothie     | ~65%       |
| Median   | 60      | ~300                | Smoothie / Coffee border | ~30% Coffee |
| Hardcore | 100     | ~500–600            | Coffee, ~10–15% Cocktail | ~5–10% Cocktail |

Maps cleanly to target distribution:

| Arena reached | Target  | Modelled |
|---------------|--------:|---------:|
| Juice         | 100%    | 100% ✓   |
| Smoothie ≥    | 60–70%  | ~70% ✓   |
| Coffee ≥      | 25–30%  | ~25–35% ✓ |
| Cocktail ≥    | 5–10%   | ~5–10% ✓ |

---

## 5. What is cut from the playtest

| System | Reason cut |
|---|---|
| **Bar Pass** (30 tiers + bonus bank) | Validates monetization, not core loop. Re-add post-validation. |
| **Weekly Missions** (3-of-10 rotation) | Star Race already gives the weekly retention signal. Weekly Missions duplicate that surface without distinct signal at MVP scope. |
| **Weekly Reset chest via mail** | Same. |
| **Venue** (4 districts incl. Penthouse) | Our unique system — but heavy content production. Cut from MVP. Star Race covers cosmetic meta progress for the playtest window. |
| **Album** (4 albums × 10 stickers) | Collection meta requires Pack Opener — both cut as a unit. |
| **Pack Opener** (Small/Standard/Big) | No packs without Album. |
| **Bottle Skins** | Second monetization pillar — post-MVP per [design-bottle-skins.md](design-bottle-skins.md). Without Venue + Pack Opener + Bar Pass + shop, no meaningful skin acquisition paths exist. |
| **Flash Offers** | Monetization tuning wasted on prototypes — no real IAP at MVP. |
| **Daily Login indicator** | Trivial to re-add; not informative for first test. |
| **Lucky Box** | Cut — daily missions cover mid-session pacing. |
| **Mail service** | Only existed to deliver weekly Bar Pass / mission rewards — Bar Pass and Weekly Missions both cut. |
| **Starter Pack popup + 24h red-dot** | Monetization, not core loop. |
| **Avatar frame cosmetic (beyond Star Race rewards)** | Star Race cosmetic rewards are kept — they're the test signal. Other avatar frame paths cut. |
| **Sticker tokens, Silver/Gold pack tokens, BPP, Venue Tokens, Skin Shards** | Single currency (coins) for MVP. Secondary currencies activate with their owning systems post-MVP. |
| **Arenas 5–14** | 4 is enough for ladder signal. Arenas 5–14 disabled in config (not deleted). |
| **HudBar red-dot indicators** for cut systems | Naturally gone with the systems. |

---

## 6. Code changes required

Minimal — leverages existing implementation.

1. **`Assets/_Archetype/Runtime/ArenaTable.cs`**
   - Trim `Table` to 4 entries (Juice/Smoothie/Coffee/Cocktail) with values from §3
   - Add `TrophyLossBase` field to `ArenaInfo` (or introduce parallel `LossTable`) with values 15/15/18/20
   - Keep `WinScale` / `LossScale` cross-arena helpers unchanged

2. **`Assets/_Archetype/Runtime/RatingService.cs`**
   - `ApplyWin`: unchanged (uses `TrophyBase` as win base × scale × stake × On Fire)
   - `ApplyLoss`:
     - Use `CurrentArena.TrophyLossBase` instead of `TrophyBase`
     - Change floor from `Math.Max(_profile.Trophies - delta, 0)` → `Math.Max(_profile.Trophies - delta, CurrentArena.MinTrophies)`

3. **`Assets/_Archetype/Runtime/PersonaRoster.cs`** — keep only personas tied to arenas 0–3 (12 of 24). Shelve the rest.

4. **`Assets/_Archetype/Runtime/TrophyRoadCatalog.cs`** — replace 26-milestone catalog with 8-milestone playtest set.

5. **`Assets/_Archetype/Runtime/DailyMissionCatalog.cs`** — **3 missions per day**, one per verb-class (Outcome / Plugin / Mastery). All-3 daily bonus = 1 free random booster.

6. **`Assets/_Archetype/Runtime/FtueService.cs`** — **full M1–M4 flow** (M1 pour, M2 spawn, M3 walkaway, M4 first bot match). Do NOT short-circuit at M3.

7. **`Assets/_Archetype/Runtime/BoosterCatalog.cs`** — full 9-booster MVP roster (3 bronze + 3 silver + 3 gold). Unlock schedule via Trophy Road across 4 arenas (Tube Sort, Bottle Lock, Time Freeze stay locked — they unlock at arenas 7/13/14 which aren't in MVP).

8. **`Assets/_Archetype/Runtime/RatingService.cs` Stakes wiring** — stake multiplier ×2/×3/×4 selector unlocks at Arena 2 (Smoothie, 150 trophies). Per-stake matchmaking pool support.

9. **`Assets/_Archetype/Runtime/StarRaceService.cs`** — keep enabled. Star formula per [design-progression.md §7](design-progression.md). Cosmetic-only end-of-week rewards.

10. **Service registration** (LifetimeScope) — comment out registrations for: BarPass, WeeklyMissions, WeeklyReset, Venue, Album, PackOpener, FlashOffers, Mail, LuckyBox, DailyLogin. Keep enabled: RatingService, MatchmakingService, DailyMissionService, **StarRaceService**, TrophyRoadService, BoosterInventoryService, BoosterShopService, CoinService, FtueService, FakeIAPService, FakeAdService, LoggingAnalyticsService.

11. **HudBar / BottomNav** — remove red-dot indicators and nav entries for cut systems. **Keep** the Star Race tab (it's an MVP feature).

No data migration concern — playtest is a fresh save.

---

## 7. Pre-test verification checklist

- [ ] **Bot WR calibrated to ~50%** vs target audience. If bots are "feel-good" tuned to player WR 60%, the entire trophy distribution shifts up and Cocktail floods. Re-check before locking values.
- [ ] **On Fire ×2 ceiling check.** A 5-win streak = +200 trophies. If Day 2 telemetry shows >15% in Cocktail, drop to ×1.5 or require `ConsecWins ≥ 3`.
- [ ] **Juice exposure** — match polish (juice/VFX/SFX) lands before test, not after.
- [ ] **Demotion floor verified in code** — manually test: gain trophies into Smoothie, lose 5+ matches, confirm trophies stop at 150.
- [ ] **Analytics funnel piped** to a single event sink that someone actually opens during the test.

---

## 8. KPIs to measure

| Metric | Target (band) | Source genre |
|---|---|---|
| D1 retention | 35–45% | PvP 1v1 puzzle |
| D3 retention | 18–28% | PvP 1v1 puzzle |
| Avg matches/session | 3–5 | — |
| % testers reaching Arena 2 | ~60–70% | This doc §4 |
| % testers reaching Arena 3 | ~25–30% | This doc §4 |
| % testers reaching Arena 4 | ~5–10% | This doc §4 |
| Match completion rate | >85% | Rage-quit signal |
| **Stake selection rate at Arena 2+** | 25–40% choose ×2+ | Stakes hook validation |
| **Stake-×4 usage** | 3–8% (top tier) | Whale-style risk appetite |
| **Daily missions all-3 completion** | 40–55% of active testers | Daily hook validation |
| **Star Race Monday return rate** | +10–18% bump vs flat day | Weekly hook validation |
| **FTUE completion (M1→M4)** | ≥85% | Onboarding leak |
| Subjective survey | "would you play tomorrow", match clarity, fairness | Post-test |

If those land in band, the cut meta layers re-introduce post-MVP in this order, one at a time:

1. **Bar Pass** (validates monetization willingness, 30-day seasonal cadence)
2. **Weekly Missions** + Mail (D7 retention beyond Star Race)
3. **Venue** (4 districts incl. Penthouse — our unique system, F2P bottle-skin path)
4. **Album + Pack Opener** (collection meta — ships as a unit)
5. **Bottle Skins** ([design-bottle-skins.md](design-bottle-skins.md) — needs Venue + Pack + Bar Pass for full acquisition graph)
6. **Lucky Box** (mid-session pacing)
7. **Flash Offers** (peak-emotion monetization)
8. **Real IAP / ads / server-authoritative match**
9. **Arenas 5–14** + extended trophy ladder (the final 14-arena ladder)

Do **not** skip ahead. The point of cutting is to isolate the variable being tested.

**Already in MVP** (do not need re-introduction): Stakes ×2/×3/×4, Star Race, full Daily Missions (3/day), full FTUE (M1–M4).

---

## 9. Relationship to other design docs

- **`design-v7.6-patch-14-arenas-booster-refactor.md`** is **post-MVP roadmap**, not this playtest. Its 14-arena ladder, booster refactor (Pre-Sort / Tube Sort / Time Freeze), Stakes unlock, and district expansion are queued for after the playtest succeeds. Do not apply during MVP.
- **`PHASE_7B_DONE.md`** documents the meta-loop that currently exists in code. The MVP slice **disables** most of it for the test.

---

## 10. Open questions deferred

- One-time **promotion bonus** (+25–50 trophies on first arena entry)? Adds retention juice but is outside the rating formula. Punt to post-test.
- **Loss penalty per-arena (15/15/18/20)** vs flat −15. Per-arena gives cleaner funnel; flat is simpler. Per-arena retained in §3 — revisit if implementation bandwidth is tight.
- **Promotion banner UX** — does it exist? Worth one polish pass if not.
