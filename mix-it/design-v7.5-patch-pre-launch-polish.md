# Mix-It Design Patch v7.5 — Pre-Launch Polish (Deferred Subsystems)

**Patch date:** 2026-04-23
**Applies to:** v7.4-patch-ftue-tuning (2026-04-23)
**Purpose:** Holds the v7.4-scoped subsystems that were deliberately **not** implemented in the HTML prototype because they are execution-shaped (prefabs, server schema, matchmaking runtime) rather than tuning-shaped. These ship during the Unity port so the HTML prototype stays a clean source of truth for *numbers and design decisions*, and Unity becomes the source of truth for *systems*.

**Scope:** System specs moved verbatim from v7.4. No design changes vs v7.4 — this is a file move, not a redesign.

---

## Rationale for the split

The HTML prototype's job is to **validate design decisions** that need playtesting — tuning curves, FTUE pacing feel, shop psychology. Those live in v7.4 and are implemented there.

Scripted FTUE flows, matchmaking queue/bot-fill runtime, and `star_source` schema are different in kind: they need prefabs + ScriptableObjects (FTUE), networked queue code (MM), and a real DB schema (star_source). Writing them in DOM first is throwaway work.

**Unity target structure** (mirrors v7.4 tag system 🟢 🟣):
- `/archetype/` — 🟢 MM/CR/8BP-aligned systems (trophy ladder, bar pass, trophy road, stakes)
- `/plugin/` — 🟣 Mix-It innovations (districts, venue tokens, sticker albums, mix-it mechanic)
- `/tuning/` — ScriptableObjects for tables (arena gates, shop SKUs, bot cushion curve, Trophy Road) — iteration surface, version-controlled independently

---

## §1 — FTUE final structure (moved from v7.4 §7)

### Principle
Progressive mechanic drip (CR + Royal Match pattern). Minimal coach-markers. Royal Match cushion model adapted for PvP. Combo NOT taught explicitly — emerges as ambient juice.

### Sequence

| # | Format | Mechanics introduced | Reward | Duration | Completion | Forced popups |
|---|---|---|---|---|---|---|
| **M1** | Solo puzzle A | Pour, Fill, Serve, Color Spawn. No timer, no opponent. | **100 coins** | ~90s | Auto-pass on correct solve; fail → auto-retry with hint | Welcome overlay pre-match; solve celebration post-match |
| **M2** | Solo puzzle B | **Customer patience timer** (20s) introduced | **200 coins + avatar frame "Apprentice Bartender"** | ~75s | Auto-pass; timer-out → retry with timer paused + tutorial callout | Patience-timer overlay pre-match |
| **M3** | Easy bot (cushion ~30–40% bot WR) | Full plugin live; **first-serve competition** emerges organically from shared queue | **600 coins + 1 Bronze booster + Starter Chest (Lucky Box 50% pre-fill, coin component only, doesn't stack with M3-earned progress)** | ~90s | Standard match end; loss allowed, framed "good match, keep going" | Post-match Trophy Road reveal popup (first milestone #1 claimed = 50 trophies) |
| **M4** | Easy bot (cushion WR ~70%) | Standard PvP framing; no new mechanics — consolidation match | Standard match coin + trophies | ~90s | Standard | Post-match: §2 stake-teaser popup |
| **M5** | **Scripted ×2 stake match** (bot tuned ~65% player WR) | **Stake multiplier** introduced; free Silver booster equipped as stake | ×2 coin + trophy on win; replacement booster grant on loss | ~90s | Win or loss both resolve cleanly; rage-quit = loss path | Pre: stake tutorial overlay. Post: result cascade. Post-post: Starter Pack $2.99 popup |
| **M6+** | Real PvP with cushion (per §3) | Real opponents + bot fallback; arena-tied cushion WR curve kicks in (70% Arena 1, 65% Arena 2, ...) | Standard match rewards | ~90s | Standard | None — FTUE ends |

### Post-M3 first album screen discovery
- Natural flow via Trophy Road milestone #1 → player visits album screen
- First-time-view of album triggers: **1 Welcome Silver Sticker Pack + 1 Sticker Token** drop
- Introduces stickers + Sticker Token mechanic (v7.3.1 §7 F2P supply valve)
- NO Gold pack — preserves "Gold is aspirational" semantics

### Day-1 coin projection
- FTUE rewards: ~900c coin-equivalent
- Post-M3 album pack: ~500c (Silver)
- First real PvP matches (4–5 × Arena 1 base × 70% WR): ~70c
- First Lucky Box claim (pre-filled 50%): ~50c
- Daily Missions if completed session 1: ~600c
- **Total: ~1,700c on Day 1** = 1.25× F2P casual daily ceiling → retention-hook appropriate (validated by economy agent 2026-04-23)

### FTUE reward principle (locked for v7.4+)
> **FTUE rewards must be items the player has seen or used within the last 30 seconds of gameplay, or immediately visible on the screen they return to.**
>
> No mystery rewards. No collection items before the collection system is visible. No VIP/boosters/stakes before those mechanics exist.

### Starter Pack trigger
- Post-M5 (after scripted stake match resolves) OR D1 return, whichever first
- Contents per v7.3.1 §15.F
- Red-dot persists on Shop for 24h after dismissal

### Unity notes
- Each M1–M5 is a ScriptableObject `FTUEStageConfig` referencing a puzzle state (M1/M2), bot skill preset (M3/M4), or stake-tutorial override (M5).
- Popup sequence driven by a simple state machine; rage-quit handling is server-authoritative on M5 only.

---

## §2 — M4→M5 scripted stake-pressure moment (moved from v7.4 §8)

### Intent
Place the Starter Pack trigger on real tension, not a hypothetical. M5 is a scripted ×2 stake match with a free booster — teaches stake UI, delivers the win/loss cascade, primes the $2.99 pack on the follow-up screen.

### M4 end state
- Standard Easy-bot match resolves; player returns to Home
- Popup (blocking, single CTA): **"Ready to raise the stakes? Stake a booster for ×2 rewards on your next match."**
- Red-dot pulse on Play button until M5 starts

### M5 pre-match
- Tutorial overlay (skippable after 1st view; NOT skippable in FTUE): animated explainer on ×2 stake — doubled coins + doubled trophies, booster at risk if you lose
- **Free Silver booster granted and auto-equipped as the stake**
- Stake multiplier locked to ×2 for this tutorial match (higher stakes not available regardless of unlock state)
- "Enter Match" CTA; no opt-out of the stake

### M5 match
- Plays as normal PvP-framed (vs cushion bot from §3)
- Persistent ×2 STAKE badge in match HUD — pulsing on first appearance
- Bot tuned to ~65% player WR specifically — majority experiences win cascade, minority sees loss cascade. Both outcomes are designed.

### M5 result

**Win (~65% of players):**
- Result screen with ×2 multiplier called out: "×2 STAKE — DOUBLED REWARDS"
- Coin + trophy pills count up with ×2 burst animation
- Booster card shows "KEPT" stamp, animates back into inventory

**Loss (~35% of players):**
- Result screen shows "LOST STAKE" animation; Silver booster card animates out of inventory (desaturate + fade)
- **Replacement grant popup follows immediately** (blocking):
  - Copy: "That was your tutorial — here's a free booster. Now go play for real."
  - New Silver booster animates into the empty slot
- No scolding, no "you failed" framing — tone is "lesson learned, here's your tool back"

### Post-M5 (both outcomes)
- Starter Pack ($2.99) popup triggers after result/replacement flow fully resolves and player is back on Home
- Dismiss → red-dot persists on Shop for 24h

### Edge cases
- **Rage-quit mid-match:** treat as loss. Grant replacement on next Home load
- **Already owns Starter Pack:** still run scripted M5 match; skip post-M5 Starter Pack popup
- **Crash / disconnect before result:** re-enter from server state; if no state, replay with `m5_redo` flag; on second failure, treat as win (fail-soft — never punish tutorial on client bug)

### Tracking events
- `m4_stake_teaser_shown`
- `m5_stake_tutorial_shown`
- `m5_stake_tutorial_booster_granted`
- `m5_stake_outcome` (win / loss)
- `m5_replacement_booster_granted` (loss path only)
- `m5_ragequit` (boolean)
- `starter_pack_shown_post_m5`
- `starter_pack_purchased_post_m5` (24h attribution window)

---

## §3 — Post-FTUE bot-fill + matchmaking runtime (moved from v7.4 §10, queue-related parts)

**v7.4 §10 split:** the Star Race gate and cushion-fade flag are implemented in v7.4. The queue/band/sampler/bot-fill runtime moves here because it needs a live matchmaking layer.

### Trophy-band matchmaking
| Arena | Band width |
|---|---|
| 1 Juice Stand, 2 Smoothie Bar | ±80 trophies |
| 3 Coffee House, 4 Tea Garden, 5 Cocktail Lounge | ±150 trophies |
| 6 Wine Cellar, 7 Champagne Room, 8 Grand Hotel | ±200 trophies |

Symmetric bands around searching player. No ELO layer at MVP.

### Queue wait → bot fallback
- **15s threshold.** At 15s queue returns bot with surface trophy count sampled from player's trophy band
- Pre-15s: real opponent preferred
- Band widens +50% at 10s as soft expansion before bot-fill
- Bot-fill fires silently — no "matching with bot" indicator

### Cushion mechanism (Arenas 1–4)
- Bot pool tagged with scripted skill level (1–5)
- In cushion arenas, sampler weighted toward lower-skill bots → observed aggregate WR converges on v7.4 §9 target (70/65/60/55% for arenas 1–4)
- Real-opponent matches included in aggregate — sampler self-corrects
- Personal WR rolling window: last 20 matches. If player drops >10pp below arena target for 10+ matches, sampler nudges bot skill one step lower until recovery.

### Cushion fade
- Crossing into Arena 5 (Cocktail, 1,000 trophies) exits cushion pool permanently
- Demotion back below 1,000 does NOT re-enable cushion
- Post-cushion bot pool is skill-uniform; aggregate ~52% WR
- `cushionFaded` flag is implemented in v7.4 save state; sampler reads it at match-request time

### Star Race integrity
- **Stars earned vs bots do NOT count toward Star Race leaderboard** (v7.3 §4 rule)
- Stars vs bots DO count toward Weekly Missions "Earn Stars" target (activity, not competition)
- Server-side filter on `match.opponent_type = bot` at leaderboard aggregation
- Trophy gains/losses vs bots apply normally

### Bot transparency
- **Bots are NOT revealed as bots in client UI.** Full player-like profiles: avatar, frame, country flag, VIP tier badge (from generator pool), coherent username
- Integrity protected by Star Race exclusion + trophy-band sampling
- Internal telemetry: `opponent_type` logged per match for auditing; not exposed

### Unity / server notes
- Matchmaking is a thin Photon / custom-backend service; client emits `match_request(arenaId, trophies)` and awaits `match_found(opponentPayload)`.
- Bot pool lives server-side; bot avatars/names/flags generated from a weighted pool keyed to the requesting player's arena + trophy band.
- `cushionFaded` flag sent with match request so server sampler can read without trusting client.

---

## §4 — `star_source` migration hook (moved from v7.4 §11)

Future-proofs v9 Teams conversion of Star Race to Team Box.

### Enum definition
```
enum star_source {
  SOLO_WEEKLY       // MVP — feeds solo Star Race leaderboard
  TEAM_BOX          // v9 — shared team container (reserved)
  EVENT_STAR_RACE   // v9+ — LTM/seasonal events (reserved)
}
```

MVP grants all stars with `SOLO_WEEKLY`. Writer path is a single constant; no branching ships.

### MVP schema
- Table `match_star_grants`: `(grant_id, player_id, match_id, stars_earned, star_source, arena_at_grant, week_bucket, created_at)`
- Table `star_race_weekly_totals`: materialized per `(player_id, arena, week_bucket)` filtered `WHERE star_source = SOLO_WEEKLY`
- No `team_id` column at MVP. Added in v9 as nullable; MVP rows stay NULL.

### Backward-compat rule (critical)
**Stars granted with `SOLO_WEEKLY` keep that value for life.** v9 does NOT rewrite historical rows.

- Stars earned during current Star Race week at v9 ship time stay `SOLO_WEEKLY` and complete that week normally
- First post-v9 Monday reset starts granting `TEAM_BOX` (if player in a team) or `SOLO_WEEKLY`
- No retroactive Team Box backfill — stars earned pre-team-join have no team to credit

### v9 migration plan — clean flush
- Chosen: clean flush. Pending SOLO_WEEKLY stars pay out via existing Star Race on post-v9 Monday reset, then writer switches
- Rejected: dual-credit (over-rewards migration cohort)
- Rejected: retroactive backfill (audit confusion)

### Team Box spec outline (v9 stub)
- Shared container; teammate `TEAM_BOX` stars sum into weekly bar
- Reset: weekly, Monday 00:00 UTC (matches MM team-box pattern)
- Tiered (Bronze/Silver/Gold thresholds); opens at reset; contents distributed equally to members contributing ≥1 star
- Star contribution visible on team roster (anti-freeloader transparency)
- Team Star Race (team-vs-team weekly board) uses `EVENT_STAR_RACE` — separate faucet, co-exists

### Schema impact matrix
| Change | MVP | v9 |
|---|---|---|
| `match_star_grants.star_source` enum | ships with SOLO_WEEKLY only | values activated via feature flag |
| `match_star_grants.team_id` nullable | — | added; MVP rows stay NULL |
| `team_box_weekly` aggregate | — | new |
| `star_race_weekly_totals` query filter | `WHERE source = SOLO_WEEKLY` | unchanged |
| Writer path | single constant | branches on `player.team_id IS NULL` |

---

## §5 — Open items forwarded from v7.4 §17

- Rewarded video integration (2 placements: post-match double coins, Color Spawn recharge)
- Coin bundle IAP localization + platform SKUs
- Home UI mockup after v7.3 §14 reshuffle (final art direction)
- Reconnection / anti-cheat baseline
- Matchmaking telemetry dashboard (band fill rate, bot-fill %, cushion WR accuracy)
- MM/8BP in-client screenshot verifications (v7.3 §18 items 1–4)
- Final SKU price localization pass per country
- Ad mediation setup (ironSource/MAX/AdMob)

---

## §6 — Sources

- v7.4-patch-ftue-tuning.md (content moved from §7, §8, §10 queue parts, §11, §17)

---

**End of v7.5 patch.**
