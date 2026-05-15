# Plugin Spec — Coin Tumble Roguelite

Date: 2026-05-15
Archetype: Roguelite Runner

## Identity
- Name: Coin Tumble Roguelite
- One-liner: A cute-greedy coin-pusher roguelite — tap to tumble coins, pick chips between floors, run for the stash.
- Donor reference: RACCOIN: Coin Pusher Roguelike (PC, Doraccoon/Playstack)

## Core verb
- Input: single tap to drop a coin from a horizontal aim slider at the top of the ledge
- Physics: 2.5D top-down ledge with a shelf and a far-edge drop zone. Existing coins push when new coins land.
- Score: coins falling off far edge add to floor score; combo multiplier on rapid-succession drops
- Charges: each drop spends 1 "Coin in Pouch"; pouch refills on floor clear

## Run structure
- 5 floors per run (HYPOTHESIS — lock after physics measurement; may move to 3 or 4)
- Each floor: score threshold + Coins-in-Pouch budget
- Between floors: chip shop (3 chips offered, 3 rarity tiers, banked Gold pays)
- Every 3rd floor: Bad Coin (boss floor) — hostile modifier (reversed drops, halved pouch, etc.)
- Run win: clear all 5 floors → bank rewards
- Run loss: pouch empty before threshold, or boss modifier wipes
- Revive: 1/run, 2/day, non-boss only; first free via RV, second costs gems

## Win condition
Clear N floors (N=5 placeholder) → bank Gold + Shards + run XP toward Battle Pass.

## Opponent model
Solo only. No PvP, no async ghost runs (cut per review). Asynchronous leaderboard (weekly fixed-seed challenge).

## Juice profile
Poppy on payoff peaks. Subdued baseline coin SFX. ×5+ combos and Rare chip triggers fire screen shake + particle burst + audio sting.

## Soft-launch content
- 3 characters (each with distinct starting coin set + 1 passive trait)
- 30 chips (modifiers in chip shop)
- 2 biomes (Trash Alley, Casino Floor)
- 3 stakes per character
- 30 codex entries

## Visual identity
- Theme: Raccoon Heist (primary) — raccoon mascot, urban dumpster → bank vault biome arc
- Fallback theme: Pirate Cove (art-ready) — parrot mascot, treasure cavern — for store-policy fallback
- Mood: cute-greedy / cozy-chaotic
