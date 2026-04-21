# mix-it v7.1 — Release Notes

**Patch:** `design-v7.1-patch-coin-economy-mm-faithful.md`
**Base:** v7.0 Match Masters Refactor
**Date:** 2026-04-21
**Theme:** Match Masters-faithful economy. One soft currency, one wager mechanic, zero invented systems.

---

## TL;DR

- **Gold currency deleted.** Coins is now the only soft currency.
- **Per-match ante deleted.** Matches are free to enter.
- **Bet slot deleted.** Replaced with 3 Stake slots (MM's Booster Stakes Multiplier).
- **Practice Mode deleted.** Not needed — no affordability gate exists anymore.
- **"Bet tier" concept deleted.** It conflated booster rarity with wager size. Those are now two separate things, matching MM.
- **All currency values migrated.** Legacy gold is converted to coins at 1.5×.

---

## What changed for the player

### Currency
- HUD now shows **Coins + Stars** only. Gold counter gone.
- Coins fund everything earnable: boosters, sticker packs, Star Chest shortcuts.

### Playing a match
- **No entry fee.** Tap PLAY → straight into matchmaking.
- **Choose your stake** on the loadout screen: 0, 1, 2, or 3 boosters (Silver/Gold rarity only — Bronze can't be staked).
- **Reward multiplier = stake count.** 2 stakes → ×2 coins, trophies, stars. 3 stakes → ×3.
- **Win:** stakes return to you, rewards multiplied.
- **Loss:** stakes are consumed, base rewards unmultiplied.
- **Draw:** stakes return, base rewards.

### Coin payouts
- Scale by **arena** (Juice Stand 30 base → Grand Hotel 500 base on win).
- Multiply by stake count × On Fire.
- Example: Cocktail Lounge win with 3 stakes + On Fire = 120 × 2 × 3 = **720 coins** from one match.

### Practice Mode
- **Removed.** Every player can always play a real match at Juice Stand (no ante to pay).

---

## What changed under the hood

### Save schema
- `gold` field → **removed.**
- `loadout.betId` / `loadout.betTier` → **removed.**
- New: `loadout.stakes: [boosterId | null, boosterId | null, boosterId | null]`.
- Migration on load:
  - `coins += round(gold * 1.5)`, then delete `gold`.
  - `stakes[0] = betId` (if present), then delete both legacy fields.
  - Daily mission `use_5_bets` in rotation → rewritten to `stake_2_wins`, progress reset.

### Matchmaking
- Trophy band (±100) — unchanged.
- Second filter: **stake count** (player vs. AI matched on 0–1 / 2 / 3).
- Opponent card shows **stake count pill** (×1 / ×2 / ×3). No more "bet tier" label.

### Match flow
- No affordability check before matchmaking.
- No ante deduction.
- No "offer Practice" branch.

---

## Tables that changed

| v7.0 | v7.1 |
|---|---|
| Gold ante per arena (§5.1) | **Deleted** |
| Coin payout by Bet tier (§6.2) | Coin payout by **Arena** |
| Matchmaking filter: bet tier | Matchmaking filter: stake count |
| AI bet generation (§7.2) | AI stake generation (0–3) |
| Trophy Road rewards (Gold + Coins) | Trophy Road rewards (Coins only, ~1.5× conversion) |
| Daily Mission rewards (Gold + Coins) | Daily Mission rewards (Coins only) |
| Lucky Box: 50 Coins + 30 Gold | Lucky Box: 120 Coins |
| Star Chest (Gold + Coins columns) | Star Chest (Coins column only) |
| Sticker Packs priced in Gold | Sticker Packs priced in Coins (150 / 380 / 900) |
| Page completion: 100g + 100c | Page completion: 250 Coins |
| Album completion: 1000g + 1000c | Album completion: 3,000 Coins |
| Seasonal album: 2000g + 2000c | Seasonal album: 6,000 Coins |
| Bar Pass rewards (Gold + Coins) | Bar Pass rewards (Coins only) |
| Star Chest shortcut prices (Gold) | Star Chest shortcut prices (Coins, higher scale) |
| Flash offer: low-gold trigger | Flash offer: low-coins trigger (<200) |
| Starter Pack: 1000g + 500c + … | Starter Pack: 2,000 Coins + … |

---

## UI changes

- **Home HUD:** currency row shrinks from 3 slots (Coins / Gold / Stars) to 2 (Coins / Stars).
- **Home:** Practice button removed entirely (was broke-gated).
- **PLAY button:** label is just "PLAY." No "Wager X Gold" copy.
- **Loadout screen:** single Bet slot → three Stake slots + live multiplier readout (×1 / ×2 / ×3).
- **Pre-match confirm:** only appears when staking ≥2 boosters ("Stake 2 boosters for ×2 rewards? You'll lose them on a loss.").
- **Matchmaking reveal:** opponent card shows stake count pill, not bet-tier badge.
- **Result screen:** no "Ante" line. Coins line shows base × multipliers breakdown. Lost stakes list each consumed booster; kept stakes likewise on win.
- **Shop:** Sections B (Star Chest shortcut) and F (Sticker Packs) price in Coins, not Gold.

---

## What's removed from the codebase

Scrub `index-v7.html` for:

- All `gold` save reads/writes, HUD slot, tooltips, icons
- Ante deduction, pot settlement, refund logic
- Practice Mode: button, flag, branch, preset, reward suppression
- "Offer Practice" gate before matchmaking
- Bet slot UI + single-bet loadout state
- Coin payout table keyed on bet tier
- Bet-tier matchmaking filter
- Opponent card "their bet tier visible" line
- Daily mission `use_5_bets`
- Flash offer "low-gold" trigger
- Pre-match confirm copy about playing without a bet
- Analytics events referencing `bet_tier`, `betTier`, `bet_rarity` — rename to `stake_count` + `stake_booster_rarity`

---

## What stays the same from v7.0

- 9-booster roster, 3 tiers (Bronze / Silver / Gold), flat power per tier.
- 2 Perk slots + 3 MVP perks (Second Look, Steady Hand, Pour Read).
- On Fire streak (2 wins → next match ×2).
- Arena selector + diminishing returns on low-arena farming.
- Trophy Road structure (20 milestones, 0–4000 trophies) — rewards just converted.
- Daily Missions structure (3/day, Daily Chest) — rewards converted.
- Lucky Box 4h timer.
- Star Meter → Star Chest at 25 stars.
- Sticker system: 3 Regular + 1 Seasonal album, 4 rarities, duplicate conversion, Sticker Tokens.
- The Venue (6 themed bars, 29 buildings, 3-level upgrades) + Venue Tokens (play-earned only).
- 30-day Bar Pass, BPP from match played/won only.
- All water-sort / pour / serve / customer mechanics untouched.
- Named AI personas + Rematch button.

---

## Risks / things to watch in playtest

- **Coin inflation.** Single-currency net daily income estimated ~1,700 coins vs. v7.0's combined ~1,200 "currency value." Pacing may need tuning if players hit soft cap early or if sticker-pack saving feels trivially fast.
- **Stake adoption.** If most players default to 0 stakes, the multiplier system underperforms. Daily mission `stake_2_wins` + the ×2/×3 payout spike are the nudges. Watch stake-slot fill rate in analytics.
- **Bronze stake eligibility.** Currently blocked. If playtesters feel locked out of the multiplier loop (because they only own Bronze early), consider letting Bronze count with a reduced multiplier (e.g., Bronze stake = ×1.25 each instead of ×1).
- **3-star condition = stake-survived.** Deliberate variance from MM's "30% margin" rule. If it makes 3-star feel trivial (any 1-stake win = 3 stars), tighten to "≥2 stakes survived."

---

## Future (noted, not in 7.1)

- **Diamond booster tier** with ×5 stake cap above 3,000 trophies.
- **Tournament events** with coin entry fees (MM's actual tournament system, separate from regular matches).
- **Team / club features** — sticker trades, team box from stars.

---

## Acceptance bar for shipping 7.1

- No `gold` field anywhere in save, UI, or result screen.
- HUD shows 2 currency slots, not 3.
- PLAY deducts nothing.
- Stake slots reject Bronze with a toast.
- 2-stake win pays double the arena base.
- Migration: legacy save with `gold: 100` + `betId: "swap"` loads clean → `coins += 150`, `stakes[0] = "swap"`, legacy fields gone.
- Practice button never appears in any state.
- Daily mission `stake_2_wins` exists, `use_5_bets` does not.
- Result screen has no "Ante" line.

Full 28-item list in patch §18.
