# Archetype Spec — ActiveTapperIdle

Date: 2026-06-26
Status: NEW (no existing catalog entry)
Reusable across plugins: yes — defines a genre, not a single game.

## 1. Genre identity
- One-sentence: "ActiveTapperIdle = games where the player actively taps a satisfying
  core verb for a multiplier-bearing payout, while automation gradually absorbs the
  grind and prestige resets compound long-term power."
- Shape: solo / PvE. No realtime PvP. Async social optional (later).
- Session texture: short (2-5 min), frequent (5-8/day), async between sessions via offline earnings.
- Exclusions: NOT pure-AFK idle (active tap must stay meaningful); NOT a twitch action game
  (no fail-and-restart runs); NOT realtime multiplayer.

## 2. Meta systems (canonical list)
Required core:
- Currency / economy — soft (earned), hard (premium), prestige (reset reward).
- Progression — at least one upgrade track that raises payout/rate.
- Match flow — here the "match" is the continuous active-tap session (request=open, run=tap, result=offline-payout/prestige).
- Save/profile — local persisted blob.

Core to THIS archetype:
- Active-tap core verb with combo/timing multiplier (`ITapVerbService`).
- Automation managers — convert active grind to passive over time (`IAutomationService`).
- Offline earnings with cap + welcome-back (`IOfflineService`).
- Prestige / ascension — reset for permanent global multiplier (`IPrestigeService`).
- Wear / soft-fail throttle — keeps active play strategic (`IWearService`).

Optional (per plugin):
- Daily / weekly / seasonal cadence, collection/album, pass, shop, FTUE state machine, analytics bus.

## 3. Currencies
| Name | Soft/Hard | Source(s) | Sink(s) | Cap |
|---|---|---|---|---|
| Coins | soft | per slice + offline | upgrades, unlocks | none |
| Gems | hard | IAP + milestone trickle | permanent 2x, time-warp, auto-unlock, ad-removal | none |
| Master Knives | prestige | prestige reset | permanent global multiplier | none |

## 4. Progression tracks
| Track | Tier count | Reset cadence | Reward shape | Gating |
|---|---|---|---|---|
| Blade upgrade | open-ended | survives prestige (or partial) | +coins/slice, +wear resist | coins |
| Ingredient tiers | staged | survives | higher base value | coins + milestone |
| Automation | staged | survives | passive slice rate | coins + milestone |
| Prestige layers | 2-4 | the reset itself | global multiplier + new mechanic per layer | threshold |

## 5. Retention cadence
- Daily: login reward, offline-cap "board full" notification, daily deal, 1-2 slice quests.
- Weekly: ingredient/blade challenge w/ milestone track; gentle streak.
- Seasonal: themed live-ops events, optional pass.
- Permanent: prestige power, blade collection.

## 6. FTUE template
- ~3 forced stages: (1) first slices (teach tap) → (2) first upgrade (teach coins sink) →
  (3) first wear+sharpen (teach soft-fail). First prestige surfaced as the first big milestone.

## 7. Service contracts (preview)
- ITapVerbService — register tap, evaluate timing window, emit slice+combo events.
- IWearService — track blade durability, apply throttle, sharpen.
- IOfflineService — accumulate offline at capped rate, produce welcome-back payout.
- IAutomationService — passive slice ticks from owned managers.
- IPrestigeService — compute prestige reward, reset eligible state, apply global mult.
- ICurrencyService — coins/gems/prestige balances + transactions.

## 8. SaveProfile schema (preview)
- currencies.coins: number (0)
- currencies.gems: number (0)
- currencies.masterKnives: number (0)
- progression.bladeLevel: number (0)
- progression.ingredientTier: number (0)
- stats.totalSlices: number (0)
- wear.durability: number (max)
- time.lastSeen: epoch ms (for offline calc)
- flags.ftueStage: number (0)

## 9. Analytics events (canonical)
- slice_made {combo, value}
- upgrade_bought {track, level, cost}
- wear_depleted / blade_sharpened
- offline_claimed {durationMs, amount}
- prestige_done {masterKnivesGained, runDurationMs}

## 10. Economy curve template
- Payout: coins/slice = base * bladeMult * comboMult * prestigeMult.
- Cost ramp: upgrade cost = base * growth^level (exponential, ~1.07-1.15).
- Offline: rate ~50-100% active, capped (8h ≈ 1-2h active).
- Monetisation hooks: gems → permanent 2x, time-warp, auto-unlock, ad-removal.

## 11. Reused / similar archetypes
- Closest existing genre: idle/incremental (Cookie Clicker, AdVenture Capitalist, Tap Titans).
- Why NEW: those skew pure-AFK; ActiveTapperIdle elevates the active tap to a permanent,
  combo-bearing, wear-gated verb that never fully automates away — the active layer is a
  first-class, retained system, not an early-game stand-in.

## 12. Catalog registration
- Proposed slug: active-tapper-idle
- Next step (post-prototype): archetype-extract to generate contract stubs + DI + tests.
