# Archetype Spec — Roguelite Runner

Date: 2026-05-15
Status: NEW (no existing catalog entry in this project)
Reusable across plugins: yes — defines the genre, not a single game

## 1. Genre identity
- one-sentence definition: "Roguelite Runner = games where the player runs short solo skill-luck sessions, picks modifiers between/within runs, and compounds meta progression across runs"
- shape: SOLO; async social allowed (leaderboards), no PvP
- typical session texture: short (90-300s) bursts; multiple sessions/day; energy-gated
- exclusions: NOT real-time PvP, NOT MMO, NOT idle/AFK (player must be active in-run), NOT premium-only one-shot run experiences

## 2. Meta systems (canonical list)

Required core:
- **Currency / economy** (`ICurrencyService`) — soft + hard meta currencies
- **Progression — Account Level** (`IPlayerLevelService`) — XP from runs, unlock pacing
- **Match flow — Run** (`IRunService`) — request run → execute run → emit result
- **Save / profile** (`ISaveService`) — persistent profile blob

Recommended:
- **Energy gate** (`IEnergyService`) — Run Tickets / Keys / etc; regen + cap + IAP refill
- **Character / loadout** (`ICharacterService`) — starting loadout variety
- **Modifier library** (`IModifierService`) — chips / jokers / cards / scrolls; pool unlocked by Level
- **Collection / album** (`ICollectionService`) — codex + themed collection albums
- **Battle pass** (`IPassService`) — 8wk seasonal premium track
- **Daily quests** (`IQuestService`) — daily + weekly objectives
- **Events** (`IEventService`) — bi-weekly themed event biome / blind / variant
- **Leaderboard** (`ILeaderboardService`) — async social, fixed-seed challenges
- **FTUE** (`IFtueService`) — staged tutorial gating

Optional:
- Mail / inbox
- Shop / boosters (outside of in-run shop)
- Cosmetic skin system
- Push notifications

## 3. Currencies (canonical shape)

| Slot | Purpose |
|---|---|
| Run-internal energy | Limits actions within a run |
| Run-internal soft | Buy modifiers in-run shop |
| Meta soft | Permanent upgrades, cosmetics |
| Meta hard | Premium currency — IAP, time-skip, premium pass |
| Meta energy | Gates run starts (regen + cap) |
| Collection token | Drops from runs, fills album slots |

Plugins can collapse run-internal energy + run-internal soft into one currency. They MUST keep meta soft, meta hard, meta energy distinct.

## 4. Progression tracks (canonical shape)

| Track | Reset |
|---|---|
| Account Level | Never |
| Character / Class unlocks | Never |
| Modifier library (gradual unlock) | Never |
| Stakes / Difficulty per character | Per character |
| Biome / World | Never |
| Battle Pass | Per season (8wk) |
| Collection Album | Per album cycle (8-10wk) |
| Codex | Never |

## 5. Retention cadence
- Daily: 3 quests + login reward + 1 free RV ticket
- Weekly: fixed-seed challenge run leaderboard
- Bi-weekly: themed event (modifier variant or themed biome)
- Seasonal: 8-week pass + themed album + new char/biome at midpoint
- Permanent: codex, stake mastery, account grind

## 6. FTUE template
- Stage 0: forced-win first run (1 char, 1 biome, 1 stake)
- Stage 1: first chip shop choice (forced rare reveal)
- Stage 2: first floor clear → meta reward beat (Gold + first sticker shard)
- Stage 3: first boss floor exposure (forced win, scripted modifier)
- Stage 4: ticket gate reveal (out of tickets → RV refill demo)
- Stage 5: starter pack offer + free account-level claim

## 7. Service contracts (preview)
- `IRunService` — `StartRun(charId, biomeId, stake) → RunHandle`, `EndRun(RunHandle, outcome) → RunResult`, events: `RunStarted`, `FloorCleared`, `RunEnded`
- `ICurrencyService` — `Get(key)`, `Add(key, amount)`, `TrySpend(key, amount)`, events: `CurrencyChanged`
- `IPlayerLevelService` — `GetLevel()`, `AddXp(amount)`, events: `LeveledUp`
- `IEnergyService` — `GetTickets()`, `TryConsume()`, `RefillByGem()`, `RefillByRV()`, events: `TicketsChanged`
- `IModifierService` — `GetUnlockedPool()`, `RollShopOffers(count, rarityTable) → Offer[]`
- `ICollectionService` — `AddShard(amount)`, `FillSlot(albumId, slotId)`, events: `SlotFilled`, `AlbumCompleted`
- `IPassService` — `AddPassXp(amount)`, `ClaimTier(tier, track)`, events: `TierUnlocked`
- `IQuestService` — `GetActive()`, `RecordEvent(eventKey, amount)`, events: `QuestCompleted`
- `IEventService` — `GetActiveEvent()`, `ParticipateRun(runResult)`
- `ILeaderboardService` — `SubmitScore(boardId, score)`, `GetTopN(boardId, n)`

## 8. SaveProfile schema (preview)

```
account: { level, xp }
currencies: { gold, gems, tickets, shards, <run-internal volatile not persisted> }
characters: { <charId>: { unlocked, stake } }
modifiers: { unlockedIds[] }
biomes: { unlockedIds[] }
codex: { discoveredIds[] }
album: { currentAlbumId, slots: { <slotId>: stickerCount } }
pass: { seasonId, xp, claimedTiers: { free[], premium[] }, premiumUnlocked }
quests: { dailyDateKey, dailyProgress[], weeklyProgress[] }
ftue: { stage }
flags: { passPending, shopPending, albumPending, ... }
stats: { runsPlayed, runsWon, highestStakeCleared }
```

## 9. Analytics events (canonical names)
- `run_started` { charId, biomeId, stake, seed }
- `run_ended` { charId, biomeId, stake, outcome, floorsCleared, durationMs, runRewards }
- `floor_started` / `floor_cleared` / `boss_floor_started` / `boss_floor_cleared`
- `chip_offered` / `chip_purchased` / `chip_rerolled`
- `revive_used` { source: rv|gem }
- `ticket_consumed` / `ticket_refilled` { source }
- `quest_completed` / `pass_tier_claimed` / `album_slot_filled` / `album_completed`
- `iap_purchased` { sku, price, currency }
- `level_up`
- `ftue_stage_completed` { stage }

## 10. Economy curve template
- Per-run Gold payout scales with stake and floors cleared
- Battle Pass XP per run normalized to ~50 runs per season for free-track completion
- Sticker Shard drop rate calibrated to ~1 album completion per season at 1.5 runs/day average
- Ticket regen: 1 / 20-30 min, cap 5-8 (A/B candidate window)
- Hard currency drips: ~30 gems / week from free progression; IAP packs scale $0.99 → $99.99

## 11. Reused / similar archetypes
Comparable real-world archetypes:
- Archero / Survivor.io — roguelite runner with active combat
- Balatro Mobile — roguelite runner with card verb
- Soul Knight Prequel — roguelite runner with dungeon verb
- Coin Tumble Roguelite (this project) — roguelite runner with coin-pusher verb

Gap: no F2P mobile coin-pusher has layered a roguelite runner archetype on top — that's the unoccupied lane this prototype targets.

## 12. Catalog registration
- proposed catalog id: `roguelite-runner`
- proposed location: `archetypes/roguelite-runner.yaml`
- next step skill: after prototype proven, invoke `archetype-extract` to generate contract stubs + DI registration + EditMode test scaffolds
