# Research Brief — RACCOIN F2P Mobile Port

Date: 2026-05-15

## 1.1 RACCOIN: Coin Pusher Roguelike (PRIMARY DONOR)

| Element | Finding | Confidence |
|---|---|---|
| Platform / model | PC (Steam) F2P. App ID 3784030, dev Doraccoon, pub Playstack. ~100k installs in 24h, 86% positive of 2,092 reviews. | High |
| Core verb | Spend "drop charges" to drop coins on physics ledge; coins falling off the far edge score. | High |
| Run structure | Series of floors; each floor has score threshold; phase ends when met or charges depleted. | High |
| Boss layer | Every few floors a "Bad Coin" floor imposes modifiers (reversed drops, halved charges, hostile coins) — Balatro Boss Blind analog. | High |
| Combo system | Combo multiplier starts ×1, +0.5 per coin in chain (rapid-succession window). MultiCoin adds +0.5 if dropped in chain — placement matters. | High |
| Shop | Between floors, 4 chips offered, 3 rarity tiers (common/uncommon/rare). Effects permanent for run. | High |
| Content scale | 6 characters with distinct coin sets, 150+ coin types, 150+ power-ups, 8 difficulty stakes. | High |
| Tactility | Physics pile chaos + combo windows + visible compounding stack. | High |

## 1.2 Coin Master (F2P comparable)
- $6B+ lifetime revenue (Sensor Tower, Aug 2024); ~$1.2B annual run-rate.
- ~65% IAP / 35% ads (Udonis).
- Slot machine core verb → coins/attack/shield/raid bag outcomes.
- Sticker album viral hook (friend trades) + village progression + pet system.
- **Drop for our port**: PvP raids, friend-trade-stickers as core viral. **Keep**: collection, daily energy gating, push retention.

## 1.3 Monopoly GO (F2P megahit, closest template)
- $5B+ in two years (Deconstructor of Fun, 2025-07).
- Dice rolls = energy; board movement → cash/build/sticker.
- **Themed sticker albums on 8-10wk cadence** (Making Music, Monopoly Games, Marvel GO, Jingle Joy).
- Co-op partner events (social without PvP).
- **This is the proven F2P scaffolding** around a luck-driven verb. Our template.

## 1.4 Balatro (run-economy reference)
- Antes (escalating tiers): Small/Big/Boss Blind. Boss Blind = modifier penalty.
- Shop between blinds sells Jokers (run-permanent synergies), Vouchers, Tarots, Planets.
- 32 vouchers in 16 pairs; one per ante for $10.
- **Mobile lesson**: pick-3 shop with rarity coding scales to portrait.

## 1.5 Mobile coin-pusher competitor scan

| Title | Model | Notes |
|---|---|---|
| Coin Pusher – Vegas Dozer (vivuga) | Free + IAP + ads | Chips refill every 20s, special coins, mystery boxes, daily quests |
| Coin Pusher (CoinGame) | Free + IAP | Realistic physics, jackpot mode, daily login |
| Push The Coin | Free + heavy ads | Casual physics pusher |
| Coin Pusher Carnival | Free + IAP | Carnival reskin, prize mini-games |
| Cash Master / Pusher Mania / Dozer Mania | Free + ads "earn real cash" | Reviewers flag deceptive cashout patterns |

**Pattern**: genre dominated by shallow physics-only pushers with ad-heavy or pseudo-cash-out monetization. **None layer a roguelite run/upgrade meta. This is the unoccupied lane.**

## 1.6 Genre benchmarks
- D1 retention mobile top-quartile: 26.5%–27.7% overall; 31–33% iOS top-quartile.
- D1 bottom quartile: 10–11.5%.
- D7 top-quartile: 7–8%.
- D7 ROAS casual: 5.7% avg (Liftoff × GameRefinery 2024).
- Coin Master/Monopoly GO session length: ~3–8 min, multiple bursts/day, energy-regen driven.

## Risks flagged
- RACCOIN sales data is single-source (Hey Poor Player) — medium confidence.
- Coin Master 65/35 split is single-source.
- "Earn real cash" lane in mobile coin-pushers has store-policy and brand risk.
