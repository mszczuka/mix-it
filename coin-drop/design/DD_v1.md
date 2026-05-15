# Coin Tumble Roguelite — Design Doc v1

Date: 2026-05-15
Status: ACCEPTED

## 1. Pillars
1. **Lucky Scavenger** — player roots for the raccoon; every drop a tumble of chance and consequence
2. **Compound Greed** — runs end, but the chips, shards, level, and album persist; every session is heavier than the last
3. **Cute over Casino** — the genre's gravity pulls casino-ward; the brand pulls back toward mascot-cozy

## 2. Player fantasy
Player feels like a lucky scavenger pushing coins off a chaotic ledge — every run a tumble of physics, jackpots, and roguelike upgrades that compound across sessions. Sessions are quick (90-180s); the meta is the slow-burn payoff that makes "one more run" pull harder than the last.

## 3. Core loop (plugin)
- **Input model**: tap-to-drop from horizontal aim slider; one-thumb portrait
- **Per-second verb**: drop a coin, watch physics tumble, read combo + threshold delta
- **Win condition**: clear N=5 floors (hypothesis, lock after physics measurement) → bank rewards
- **Lose condition**: pouch empty before floor threshold OR Bad Coin (boss) modifier wipes
- **Session length target**: 120s per run (90-180s tolerated)
- **Between floors**: 3-chip shop, banked Gold pays; reroll via ad or gems
- **Boss floors**: every 3rd floor, hostile modifier (reversed drops, halved pouch, etc.)
- **Revive**: 1/run, 2/day, non-boss only; first free RV, second gems

## 4. Meta loops (archetype: Roguelite Runner)

### 4.1 Currencies (5)
| Currency | Type | Source | Sink |
|---|---|---|---|
| Coins in Pouch | Run energy | Run start + floor clear | 1 per drop |
| Gold | Meta soft | In-run earned, banks on floor clear; quests; album | Passive upgrades; cosmetics |
| Gems | Meta hard | IAP; quest drips; level milestones | Ticket refill; pass premium; reroll |
| Run Tickets | Meta energy | 1/25min, max 5; login; gem buy | 1 ticket = 1 run |
| Sticker Shards | Collection | Run drops (rarity-weighted); events | Album slot fills |

### 4.2 Progression tracks (soft-launch numbers)
- Account Level 1-50
- 3 Characters
- 30 Chips
- 2 Biomes (Trash Alley, Casino Floor)
- 3 Stakes per character
- 30 Codex entries
- 1 Sticker Album (3 sets × 6 stickers = 18)
- 25-tier Battle Pass / 8wk

### 4.3 Retention cadence
- 🌅 Daily: 3 quests, login Gold, 1 free RV ticket
- 🗓️ Weekly: fixed-seed challenge run + leaderboard
- 🎉 Bi-weekly: themed event biome + exclusive chip + event currency
- 🍂 Seasonal (8wk): pass + album + new char OR biome at midpoint
- ♾️ Permanent: codex, stake mastery, account grind

### 4.4 Social / competitive layer
SOLO + async leaderboards (weekly fixed-seed challenges). No PvP. No async ghost runs (cut per review).

## 5. Economy curves
- Run reward: Gold + Shards scale with stake × floors cleared
- Battle Pass: free track completable in ~50 runs over 8 weeks (~1 run/day)
- Sticker Album: 1 completion / season at 1.5 runs/day
- Ticket regen: 1 / 25 min, cap 5 (A/B candidate: 18min × 8)
- Gem drips (free): ~30 gems / week from progression
- IAP ladder: $0.99 → $99.99 standard

## 6. FTUE shape
- Stage 0: forced-win first run (1 char, 1 biome, lowest stake)
- Stage 1: first chip shop choice (forced rare reveal)
- Stage 2: first floor clear → meta reward beat (Gold + first shard)
- Stage 3: first boss floor (scripted forced-win, scripted modifier)
- Stage 4: ticket gate reveal (out → RV refill demo)
- Stage 5: starter pack offer + free account-level claim

## 7. Analytics events
`run_started`, `run_ended`, `floor_started`, `floor_cleared`, `boss_floor_started`, `boss_floor_cleared`, `chip_offered`, `chip_purchased`, `chip_rerolled`, `revive_used`, `ticket_consumed`, `ticket_refilled`, `quest_completed`, `pass_tier_claimed`, `album_slot_filled`, `album_completed`, `iap_purchased`, `level_up`, `ftue_stage_completed`.

## 8. Mood / texture
- Mood: cute-greedy / cozy-chaotic
- Theme: Raccoon Heist (primary, donor-parity); Pirate Cove (fallback, art-ready)
- Juice: poppy on payoffs (×5+ combo, Rare chip); subdued baseline
- Failure: cheeky-forgiving with constrained revive (1/run, 2/day, non-boss only)

## 9. Open questions
1. Tickets vs no-tickets energy gate — playtest decision
2. Run length calibration — physics measurement gates floor count
3. Shop pick count — 3 vs 4 chips; reroll cost (tokens vs gems vs RV)
4. Sticker album viral hook — solo + leaderboard, or add clan/team contribution?
5. Character unlock pacing — 2-3 in first session for variety, or strict gating?
6. Bad Coin boss design budget — minimum modifier count for variety?
7. Biome differentiation — cosmetic-only vs mechanical layer?
8. Theme robustness — Raccoon Heist regional readability; Pirate Cove readiness gate
9. Real-money cash-out gimmick — explicit out-of-scope stance in store metadata
10. Difficulty stakes — launch with 3, expand via patches (confirmed)

## 10. Feature table
See `feature_table.md`.

## 11. Reference games + delta
- **RACCOIN** (donor): copy physics, chip shop, boss floors, combo. Drop PC density + premium pacing.
- **Coin Master**: copy energy, collection, daily retention. Drop PvP raids, friend-trade-stickers as core viral.
- **Monopoly GO**: copy sticker album cadence + themed seasons. Drop dice-board verb.
- **Balatro**: copy modifier-pick UX + rarity coding. Drop card metaphor.

## 12. Risks (from designer review)
- 🔴 R1: plugin/archetype audience tension — RESOLVED by Thrill Seeker lane choice
- 🔴 R2: scope realism — RESOLVED by 60% scope cut (3/3/30/2/1/25/5)
- 🔴 R3: store-policy risk — MITIGATED via TestFlight Q1 pre-clear + Pirate Cove art-ready
- 🟡 R4: currency bloat — RESOLVED by dropping Tokens, renaming Charges → "Coins in Pouch"
- 🟡 R5: loop-meta misalignment — DEFERRED to physics-prototype measurement
- 🟡 R6: energy calibration — A/B in soft launch
- 🟡 R7: revive cadence — RESOLVED by 1/run, 2/day, non-boss only
- 🟢 R8: cadence sync — RESOLVED by aligning album + pass to 8wk
- 🟢 R9: async ghost runs — CUT from soft launch
