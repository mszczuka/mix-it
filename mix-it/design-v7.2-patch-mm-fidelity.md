# PATCH v7.2 — MATCH MASTERS FIDELITY CORRECTIONS

**Applies on top of:** `design-v7.1-patch-coin-economy-mm-faithful.md` (which itself applies on top of `design-v7.0-patch-match-masters-refactor.md`)
**Date:** 2026-04-21
**Purpose:** Correct MM-fidelity drift in v7.1 and v7.0. Staking becomes Gold-only (matching MM's Diamond/Legendary/Special rule), the multiplier ladder extends to ×4, pacing tightens and redirects income from passive drips to active-risk payoffs, the multiplier UI stops treating "stake 1" as a pretend wager, **the Arena Selector is removed in favor of MM's auto-tiered arena model**, and **the 3-star rule becomes score-margin-based (MM-faithful) instead of stake-count-gated**. Housekeeping items from the v7.1 review are folded in.

---

## 0. Why this patch exists

v7.1 collapsed the currency model correctly but made six MM-fidelity mistakes and carried several doc-hygiene issues from v7.0:

1. **Stake eligibility was wrong.** MM restricts staking to its top 3 rarities (Diamond, Legendary, Special Edition). v7.1 allowed Silver + Gold to stake — the middle tier can never stake in MM. Corrected: Gold-only.
2. **The multiplier ladder skipped ×4.** Candivore's own article is titled "Booster Stakes Multiplier — ×2 / ×3 / ×4 / ×5." v7.1 jumped from ×3 to a future ×5 and dropped ×4. Corrected: ×1/×2/×3/×4 in MVP, ×5 future.
3. **"Stake 1 = ×1" framed the first stake as a dead slot.** MM's UI shows the multiplier option when you can risk *additional* boosters beyond your equipped one. Corrected: stake 1 is just "the booster you brought," multiplier UI appears at ≥2 stakes.
4. **The pacing model under-budgeted the spike tail and over-fed passive faucets.** Active-risk play (stake × On Fire) wasn't in the daily ceiling; Lucky Box and Trophy Road drips were generous. Corrected: tighter ~2,500 coin ceiling, passive faucets trimmed, spike payouts kept intact.
5. **The Arena Selector is un-MM and overdesigned.** MM auto-promotes the player to the current-trophies arena; there is no player-selectable farming-down flow and no diminishing-returns scaling table. v7.0 added a chip row + 4-column (and later 3-column) scaling table that served no MM-faithful purpose. Corrected: Arena Selector, `currentPlayingArena`, and the diminishing-returns table are all removed. The player always plays their current trophy-band arena, period.
6. **The 3-star rule was stake-count-gated.** v7.1 awarded stars based on how many stakes survived — a mix-it invention. MM uses **score margin** (decisive-win vs close-win vs loss). Corrected: stars = match performance, decoupled from the stake mechanic.

Plus housekeeping: ×4/×5 thresholds documented as scaled, `stake_2_wins` mission gated, naming standardized on "White," analytics renames completed, §22 primary-source claim flagged for re-verification.

**Supersedes (within v7 scope):**
- §3.1, §3.4 booster tiers (stake-eligibility column added)
- §4.1, §4.2, §4.4 Stake slots (Silver stakes removed, ×4 added, 1-stake semantics rewritten)
- §6.1 Reward formula (stakeMultiplier definition revised; **star rule rewritten to score margin**)
- §7.2 AI stake generation (weights updated for Gold-only pool)
- **§8 Arena Selector + diminishing returns — ENTIRE SECTION DELETED.** Home UI simplification in §15.
- §10.1 Daily Missions (`stake_2_wins` gated; `3_star_match` rewritten to be margin-based)
- §10.2, §10.3 Lucky Box and Star Chest (passive coin drops trimmed)
- §9.1 Trophy Road (milestone trickles trimmed; #7 reward now includes the first Gold booster as the staking unlock moment)
- §10.1 Daily Chest (500 → 400 coins)
- §11.1 Rarity naming ("White" everywhere; "(C/S)" → "(W/S)")
- §14.2 Result screen examples (star readout based on margin, not stakes)
- §16.1, §16.2 Save schema and migration (stake slot rarity restriction, **`currentPlayingArena` removed**, analytics renames)
- §19 analytics event renames (`bet_survived` added, **`arena_selected` deleted**)
- §22 MM-reference note (primary-source status flagged)

Everything not listed stays as in v7.1.

---

## 1. Design stance — one bullet update

Replace the v7.1 "**One soft currency, one job**" bullet with:

- **One soft currency, one job — and income rewards risk, not patience.** Coins fund boosters, stickers, and chest shortcuts. Passive faucets (Lucky Box, Trophy Road trickles, daily chest) stay modest. The fast path to coins is to stake Gold and win — that's the loop we want the player to engage with, not idle drip collection.

Add one new bullet:

- **The arena you're in is the arena your trophies earned.** No player-selectable tier-shopping, no farming down for easier wins, no UI chrome explaining which arena you're "currently playing." You climb, you're there.

All other v7.1 §1 bullets stand.

---

## 2. Currency model — unchanged

v7.1 §2 stands.

---

## 3. Boosters — stake-eligibility column added

### 3.1 Rarity tiers (replaces v7.1 §3.1)

| Tier | Count | Power | Shop price (Coins) | Win payout | Loss penalty | **Stake-eligible?** |
|---|---:|---|---:|---:|---|---|
| **Bronze** | 3 | utility / setup | 50 | (arena base, §6.2) | n/a | ❌ no |
| **Silver** | 3 | tactical / conversion | 150 | (arena base × mult) | consumed if staked | ❌ no |
| **Gold** | 3 | match-winning / rescue | 400 | (arena base × mult) | consumed if staked | ✅ yes |
| *Diamond (future)* | *6* | *live-ops, event-only* | *event* | *(arena base × mult)* | *consumed if staked* | *✅ yes* |

**Stake-eligible = can be placed in a Stake slot (§4.2).** MM restricts staking to the top 3 rarities (Diamond / Legendary / Special Edition). mix-it's 3-tier roster maps this as Gold-only for MVP, with future Diamond joining. Silver remains a tactical layer the player uses freely without risking.

### 3.2 Full roster — unchanged

v7.1 §3.2 stands.

### 3.3 Tier tuning rules — unchanged

v7.1 §3.3 stands.

### 3.4 Arena unlock gating — unchanged

v7.1 §3.4 stands. Note that this means **staking unlocks at Cocktail Lounge (Trophy Road #7, 500 trophies)** — the same moment the first Gold booster becomes available. This is intentional and mirrors MM's "staking is an endgame feature because the eligible rarities are endgame drops" structure. Players below Cocktail Lounge play ×1 matches only and earn coins at arena base rates.

---

## 4. Pre-match loadout — stake slots rewritten

### 4.1 Structure: Equipped booster + Stake slots + Perks (replaces v7.1 §4.1)

```
+-------------------------------------------------------+
|               CHOOSE YOUR LOADOUT                     |
+-------------------------------------------------------+
|  Equipped Booster:   [ Swap (Silver) ]                |
|                                                       |
|  [ STAKE 1 ]  [ STAKE 2 ]  [ STAKE 3 ]  [ STAKE 4 ]   |   ← 0–4 Gold boosters
|  (Gold only — Silver/Bronze cannot be staked)         |
|                                                       |
|  [ PERK 1 ]   [ PERK 2 ]                              |
+-------------------------------------------------------+
|    Reward multiplier:  ×1    ×2    ×3    ×4           |
+-------------------------------------------------------+
```

The player brings **one equipped booster** (any rarity, always used in-match) plus **0–4 optional Gold stakes** for the multiplier. ×5 is future (§4.4).

### 4.2 Stake slot rules (replaces v7.1 §4.2)

- Each stake slot accepts **one Gold booster**. Silver and Bronze are rejected with a toast: *"Only Gold boosters can be staked."*
- **The multiplier UI only appears once the player owns ≥1 Gold booster.** Pre-Cocktail Lounge, the Stake row is hidden entirely — matches play at ×1.
- **Multiplier = number of filled stake slots, when ≥2.** Specifically:
  - 0 stakes → ×1 (no bonus)
  - 1 stake → ×1 (the stake does not multiply; it's just a Gold booster the player can optionally risk for cosmetic consistency with ×2+, but see §4.2.1 note)
  - 2 stakes → ×2
  - 3 stakes → ×3
  - 4 stakes → ×4 (unlocks at Speakeasy, Trophy Road #10, 1000 trophies)
  - 5 stakes → ×5 (future, above 3,000 trophies)
- On **win**: all staked boosters return to inventory; rewards multiply.
- On **loss**: all staked boosters consumed; base rewards unmultiplied.
- On **draw**: stakes return; base rewards unmultiplied.
- Empty stake (0 boosters) always allowed — no pressure.
- Pre-match confirm only when stake count ≥ 2:
  > *"Stake N Gold boosters for ×N rewards? You'll lose them on a loss."*

### 4.2.1 Note on 1-stake semantics

In MM the multiplier option shows up when the player can risk *more than* their equipped booster. mix-it mirrors this by hiding the multiplier readout unless 2+ stakes are filled. If a player fills exactly 1 stake slot, the UI should treat it as "you're bringing a Gold booster in your equipped slot" — no multiplier copy, no ×1 badge, no "you'll lose it on a loss" warning. Reward payout is identical to 0-stake.

Functionally this means **the loadout UI can be collapsed for Gold-owners to: equipped + stake 2 / 3 / 4 slots**, skipping an explicit "stake 1" tile. Either representation is acceptable as long as the player is never shown a ×1 pill next to a filled stake.

### 4.3 Perk slots — unchanged

v7.1 §4.3 stands.

### 4.4 Future Diamond tier + ×5 cap (replaces v7.1 §4.4)

When Diamond boosters ship, the stake cap rises to ×5 above **3,000 trophies** (mix-it's scaled analog of MM's 30,000-trophy threshold — the last ~20% of the ladder, matching MM's endgame proportion). Not MVP.

The ×4 cap is active at Speakeasy+ (1,000 trophies) in MVP, mirroring MM's mid-ladder ×4 availability.

### 4.5 Terminology — unchanged

v7.1 §4.5 stands. "Bet tier" remains deleted.

---

## 5. Match Bet — remains REMOVED

v7.1 §5 stands (entire section removed in v7.1).

---

## 6. Match rewards — formula cleaned, star rule rewritten

### 6.1 Reward formula (replaces v7.1 §6.1)

```
Trophies = arena_base_delta × stakeMultiplier
Coins    = base_coin_payout(arena) × win_loss_mult × on_fire_mult × stakeMultiplier
Stars    = f(match_result, score_margin_ratio)   — see §6.1.1
```

`stakeMultiplier = filled_stake_slots if filled_stake_slots ≥ 2 else 1`

**Arena scaling is gone.** The player is always in their current trophy-band arena (§8), so `arena_base_delta` and `base_coin_payout(arena)` are simply the table values for that arena — no delta-modifier, no diminishing returns to apply.

### 6.1.1 Star rule — score-margin based (MM-faithful)

MM awards **1 / 2 / 3 stars based on score margin at match end** (loss / close win / decisive win). v7.2 adopts this directly. Stars are decoupled from the stake mechanic.

Let `margin_ratio = (winner_score − loser_score) / max(winner_score, 1)`. At match end:

| Outcome | Margin ratio | Stars |
|---|---|---:|
| Win — decisive | ≥ 0.35 | **3** |
| Win — close | < 0.35 | **2** |
| Draw | (scores equal) | **2** |
| Loss | (any) | **1** |

Rationale for the 0.35 threshold: with Cocktail Lounge typical serve-scores in the 150–300 range, a 35 % margin is a 50–100-point lead — readable to the player as "I pulled ahead" rather than "we were neck-and-neck." Threshold is a single-source design choice (no MM-published number); playtest and tune. Acceptable range is 0.25–0.50; anything tighter makes 3-star trivial, anything wider makes it rare.

**Stake count no longer enters the star calculation.** Staking affects trophies, coins, and inventory risk — not stars. This preserves "stars = play quality" as a skill signal separate from "stakes = wager size." A 4-stake win by a narrow margin is still 2 stars; a 0-stake blowout is still 3 stars.

### 6.2 Base coin payout — unchanged

v7.1 §6.2 stands.

### 6.3 On Fire streak — unchanged

v7.1 §6.3 stands.

### 6.4 Guaranteed progress floor — unchanged

v7.1 §6.4 stands.

---

## 7. Matchmaking — AI stake generation revised

### 7.1 Filter — unchanged

v7.1 §7.1 stands. Stake-count band matching preserved.

### 7.2 AI stake generation (replaces v7.1 §7.2)

AI staking now only operates on Gold rarity (since staking is Gold-only). Players below Cocktail Lounge are matched against AI that never stakes. Above Cocktail Lounge:

| Player stakes | AI stakes |
|---:|---|
| 0 | 0 (80%) / 2 (20%) |
| 1 (rare — see §4.2.1) | 0 (70%) / 2 (30%) |
| 2 | 2 (65%) / 3 (25%) / 0 (10%) |
| 3 | 3 (55%) / 2 (35%) / 4 (10%) |
| 4 | 4 (50%) / 3 (50%) |

AI booster rarity for filled stakes: **Gold (100%)** — matches the player's available pool.

### 7.3 Named AI personas + Rematch — unchanged in principle

v7.1 §7.3 stands. Opponent card shows stake count (×2 / ×3 / ×4) — no pill at 0 or 1 stakes, matching §4.2.1 UI rule.

---

## 8. Arena model — Arena Selector REMOVED (MM-faithful auto-tier)

### 8.1 Current arena = current trophy band (replaces v7.0/v7.1 §8 entirely)

The player always plays in the arena that matches their **current trophy count**. No chip row, no selector, no persisted `currentPlayingArena`. When trophies cross an arena threshold upward, the player auto-promotes. When trophies drop below a threshold, the player auto-demotes. This matches MM's model.

Arena thresholds (unchanged from v7.0 Trophy Road gates):

| Arena | Trophy floor |
|---|---:|
| Juice Stand | 0 |
| Beach Bar | 200 |
| Cocktail Lounge | 500 |
| Speakeasy | 1,000 |
| Rooftop Terrace | 2,000 |
| Grand Hotel | 3,500 |

The current arena is displayed on Home as a single card (venue art + name + trophy progress to next floor). It is **not** interactive for tier selection.

### 8.2 Diminishing returns — DELETED

The 3-column diminishing-returns table (v7.1 §8.2) and the 4-column version (v7.0 §8.2) are both removed. With no Arena Selector, the player cannot play below their current tier; there is nothing to scale. Trophy and coin payouts are the straight table values for the current arena.

### 8.3 Practice Mode — remains REMOVED

v7.1 §8.3 stands (section removed in v7.1).

### 8.4 What this removes from scope

- Home UI: Arena Selector chip row (deleted)
- Save field: `currentPlayingArena` (deleted; derived at runtime from trophies)
- Analytics event: `arena_selected` (deleted)
- Prototype task: "Arena Selector chip row + trophy scaling" (deleted from §17)
- Acceptance check: diminishing-returns table rendering (deleted from §18)
- §6.1 reward formula: `arenaScaling` term (deleted — no longer applies)

This is a net UI reduction. The "which arena am I in?" question is answered by the player's trophy count, same as MM.

---

## 9. Trophy Road — passive trickles trimmed

§9.1 milestone rewards are tuned down on the "small" and "cosmetic-plus-coins" tiles; arena-promo tiles keep their coin grants because they fund the player's arrival in a new arena where base coin scale jumps.

### 9.1 Milestones (replaces v7.1 §9.1)

| # | Trophies | Reward | Type |
|---:|---:|---|---|
| 1 | 50 | 80 Coins | small |
| 2 | 100 | 2 Bronze boosters + **Bronze Frame** (stickers locked until #4) | cosmetic |
| 3 | 150 | 60 Coins | small |
| 4 | 200 | **Beach Bar unlock + 2 Silver boosters + 250 Coins + Venue landmark unlock** | arena promo |
| 5 | 300 | 1 Silver booster + **Title: Regular** + 5 stickers (Bar Classics) | cosmetic |
| 6 | 400 | 180 Coins | small |
| 7 | 500 | **Cocktail Lounge unlock + 1 Gold booster + 400 Coins + Venue landmark unlock** *— staking now unlocked* | arena promo |
| 8 | 650 | 150 Coins + **Avatar 2** + 1 Sticker Token | cosmetic |
| 9 | 800 | 2 Silver boosters + 150 Coins | small |
| 10 | 1000 | **Speakeasy unlock + 2 Gold boosters + 600 Coins + Venue landmark unlock** *— ×4 stakes unlocked* | arena promo |
| 11 | 1200 | 250 Coins + **Silver Frame** + 5 stickers (City Nights) | cosmetic |
| 12 | 1400 | 1 Gold booster + **Title: Pro Bartender** | cosmetic |
| 13 | 1600 | 200 Coins | small |
| 14 | 1800 | 300 Coins + **Avatar 3** + 1 Sticker Token | cosmetic |
| 15 | 2000 | **Rooftop Terrace unlock + 2 Gold boosters + 1,000 Coins + Venue landmark unlock** | arena promo |
| 16 | 2400 | 500 Coins + **Gold Frame** | cosmetic |
| 17 | 2800 | 2 Gold boosters + **Title: Mixologist** + 5 stickers (Grand Hotel album) | cosmetic |
| 18 | 3200 | 700 Coins + **Avatar 4** | cosmetic |
| 19 | 3500 | **Grand Hotel unlock + 3 Gold boosters + 1,250 Coins + Venue landmark unlock** | arena promo |
| 20 | 4000 | 2,000 Coins + **Diamond Frame + Title: Legend + Avatar 5** + 2 Sticker Tokens + 10 mixed stickers | end-of-road flex |

Net coin delta vs v7.1: **−1,500 Coins across all 20 milestones** (~5 % of total Trophy Road coin payout removed from passive trickles).

**Milestone #7** is flagged in UI as the "Staking Unlocked" moment — the first Gold booster grant + the arena change together enable the multiplier loop.
**Milestone #10** is flagged as the "×4 Stakes" moment — two Gold boosters land with the Speakeasy arena, enabling a ×4 play that same session.

---

## 10. Daily Missions, Lucky Box, Star Chest — passive coins trimmed, stake mission gated

### 10.1 Daily Missions (replaces v7.1 §10.1)

3 rotating tasks, refresh at local midnight. `stake_2_wins` is now gated — it only enters the rotation once `maxUnlockedArena ≥ cocktail_lounge`.

| id | Task | Reward | Gate |
|---|---|---|---|
| win_3 | Win 3 matches | 180 Coins | — |
| serve_50 | Serve 50 customers | 120 Coins + 1 Silver booster | — |
| stake_2_wins | Win 2 matches with ≥2 stakes | 250 Coins + 1 Silver booster | **Cocktail Lounge+** |
| combo_4 | Hit a 4-combo | 180 Coins + 1 Silver booster | — |
| lucky_box_2 | Claim Lucky Box twice | 130 Coins + 1 Bronze booster | — |
| earn_500_coins | Earn 500 Coins from matches | 180 Coins | — |
| open_chest | Open any chest | 130 Coins + 2 Bronze boosters | — |
| 3_star_match | Win 2 matches with 3 stars (decisive win, margin ≥ 0.35) | 300 Coins + 1 Gold booster | Cocktail Lounge+ |
| play_5 | Play 5 matches (win or lose) | 180 Coins | — |

**`play_2_arenas` deleted** — with no Arena Selector, the player cannot choose their arena, so "play in 2 different arenas" is no longer a player-controlled action.

**`3_star_match` rewritten** to match the new score-margin star rule (§6.1.1) — requires winning with ≥ 0.35 margin ratio, a skill-based outcome independent of stake count. Reward stays at 1 Gold booster because that still feeds the stake loop. Gate remains Cocktail Lounge+ because the Gold reward is meaningless below the staking threshold.

Below Cocktail Lounge, selection pool excludes the two gated missions, so pre-staking players always get 3 from the 7-mission open pool.

#### Daily Chest (all 3 complete)

400 Coins + 3 random boosters + 2 stickers + 15 % Sticker Token chance.

(Trimmed from v7.1's 500 Coins.)

### 10.2 Lucky Box (replaces v7.1 §10.2)

- Home button with 4 h countdown.
- Reward: **4 random boosters** + **80 Coins** + 1 sticker (Common-weighted).

(Trimmed from 120 Coins.)

### 10.3 Star Chest (replaces v7.1 §10.3)

25-meter unchanged. Contents trimmed on the "middle arena" rows where the pacing model pooled:

| Arena | Coins | Boosters | Stickers | Decor chance |
|---|---:|---|---|---:|
| Juice Stand | 100 | 2 Bronze | 2 (W/S) | 25% |
| Beach Bar | 220 | 2 (B/S) | 3 | 20% |
| Cocktail Lounge | 420 | 3 (S-weighted) | 3 (1+ S guaranteed) | 18% |
| Speakeasy | 750 | 3 (S/G) | 4 (1+ G possible) | 15% |
| Rooftop Terrace | 1,400 | 4 (S/G) | 4 (1+ G) | 12% |
| Grand Hotel | 2,600 | 4 (G) | 5 (1+ G guaranteed, D possible) | 10% |

Decor roll unchanged. Naming "W/S" replaces v7.1's "C/S" per §11.1.

Note: without Arena Selector, "which arena row applies" is simply the player's current trophy-band arena.

---

## 11. Stickers + Venue

### 11.1 Sticker system — naming standardized (replaces v7.1 §11.1)

Rarity names: **White** / **Silver** / **Gold** / **Diamond**. Drop weights unchanged (60 / 28 / 10 / 2). Every occurrence of "Common" or "(C/…)" in v7.0/v7.1 documents is replaced with "White" or "(W/…)" to match MM's terminology.

Affected tables this patch updates in place: §10.3 (Star Chest), §11.6 (Sticker Packs).

### 11.2 – 11.5 — unchanged

v7.1 stands.

### 11.6 Sticker Packs — Coins-priced (replaces v7.1 §11.6)

| Pack | Contents | Coins |
|---|---|---:|
| Cheap Pack | 3 stickers (White/Silver only) | 150 |
| Standard Pack | 5 stickers (standard rarity roll) | 380 |
| Big Pack | 10 stickers (1+ Gold guaranteed) | 900 |

Dupe conversion unchanged:

| Rarity | Dupe → |
|---|---|
| White | +10 Coins |
| Silver | +40 Coins |
| Gold | +150 Coins |
| Diamond | +1 Sticker Token |

**Late-game pack EV note (flagged, not fixed):** Once all 3 Regular Albums are 20/20 complete, pack EV drops dramatically — a Cheap Pack (3 stickers, ~60 % White at 10 c each) yields ~18 coins against a 150-coin cost. MM ships with the same structure and doesn't compensate; we ship likewise. Accepted as a known late-game tail issue. Reopen if playtest shows Shop F becomes a dead UI for returning players.

### 11.7 Page + album completion rewards — unchanged

v7.1 §11.7 stands.

### 11.8 – 11.19 — unchanged

v7.1 stands.

---

## 12. Economy wiring — pacing retuned

### 12.1 Sinks — unchanged

v7.1 §12.1 stands.

### 12.2 Faucets — unchanged in kind

v7.1 §12.2 stands (list of sources). Specific yields for Trophy Road, Lucky Box, Daily Chest, Star Chest updated in §9.1, §10.1, §10.2, §10.3 above.

### 12.3 Pacing (replaces v7.1 §12.3)

**Target: ~2,500 coins/day engaged ceiling,** including spike tail from On Fire × stake plays. Income is redistributed from passive faucets (down) to active-risk payoffs (held intact).

Engaged daily player, Cocktail Lounge, 50 % WR, avg 2-stake games where Gold inventory allows:

| Lever | Per day | vs v7.1 |
|---|---:|---|
| Matches played | 10 | — |
| Base coin income (mixed win/loss, Cocktail Lounge base 120/25) | ~725 | — |
| Stake × multiplier contribution (avg 2-stake wins ~3/day) | ~720 | (newly modeled) |
| On Fire streaks × 1–2/day | ~400 | (newly modeled) |
| Mission + Daily Chest coins (full clear) | ~650 | −150 |
| Lucky Box (3 claims × 80) | 240 | −120 |
| Trophy Road trickles (averaged) | ~80 | −20 |
| Star Chest pop (~every 2 days, Cocktail 420) | ~210 | −50 |
| **Total coin-in** | **~2,500 / day engaged** | vs v7.1's untuned ~1,700 baseline + ~+1,500 unmodeled spike tail |
| Target coin-out | 1 Standard Sticker Pack (380) + 1 Gold booster refill (400) = 780 / day baseline | — |
| Net coin savings | ~1,700 / day toward a Big Pack (900) OR two Gold boosters (800) every day | — |

**Pre-Cocktail Lounge player (no staking yet):**
- Stake contribution = 0, On Fire stacks still apply.
- Total coin-in ≈ 1,400–1,600 / day.
- Target coin-out = 1 Silver booster (150) + 1 Cheap Pack (150) / day ≈ 300.
- Net savings ~1,200 / day — enough to save for a Standard Pack every 2 days or bank toward the first Gold booster purchase (400) ahead of Cocktail unlock.

Both cohorts remain net positive, but the *shape* of the day is different — pre-staking players drip; post-staking players spike.

### 12.4 Pacing sanity check vs v7.1 (replaces v7.1 §12.4)

v7.1 gave engaged players ~1,700 passive coins/day and unmodeled spike tail. v7.2 targets ~2,500/day with the spike tail explicitly modeled. Passive faucets are trimmed ~15 % in aggregate so that active-risk plays are *how* you climb the income ladder — not a bonus on top of already-sufficient passive drip.

If playtest shows pre-staking players stall below Cocktail Lounge, the first intervention is to add coins (not Gold boosters) to Trophy Road #5 / #6 and Beach Bar Star Chest — preserving the "staking is the fast path" principle while softening the pre-500-trophy climb.

---

## 13. Shop + monetization shells

### 13.1 – 13.9 — unchanged

v7.1 stands. Sticker Splurge flash offer (§13.8) still refers to "3rd sticker pack in session without Gold *sticker* pull" — note this is the Gold rarity sticker, not the booster tier. Copy disambiguation recommended:

> "Sticker Splurge: 1 Big Pack + 1 Token — you've opened 3 packs without a Gold-rarity sticker."

---

## 14. Match flow + result screen

### 14.1 Flow — unchanged

v7.1 §14.1 stands.

### 14.2 Result screen examples (replaces v7.1 §14.2)

Stars are score-margin based (§6.1.1). "Stakes Kept / Lost" still appears as an inventory readout but does not affect stars.

**Win, decisive (margin 0.52, 2 Gold stakes, survived) — 3 stars:**
```
VICTORY vs. Velvet Viv                  ★★★
Score 285 — 135
+32 Trophies  (×2 stake)          Stars: 20/25 (+3)
+240 Coins    (Cocktail base ×2 stake)
Stakes Kept: Auto Serve, Clear Bottle
Venue Tokens: +1

📍 Trophy Road: Milestone 5 ready to claim!
✅ Daily: Win 3 matches with 3 stars (1/2)
🎟️ NEW STICKER — Gold: "Midnight Martini" (City Nights 3/20)

[CLAIM ALL]   [REMATCH]   [HOME]
```

**Win, close (margin 0.18, 3 Gold stakes, survived) — 2 stars:**
```
VICTORY vs. Velvet Viv                  ★★
Score 220 — 180
+48 Trophies  (×3 stake)          Stars: 17/25 (+2)
+360 Coins    (Cocktail base ×3 stake)
Stakes Kept: Auto Serve, Clear Bottle, Double Serve

[CLAIM ALL]   [REMATCH]   [HOME]
```

**Loss (3 Gold stakes, lost) — 1 star:**
```
DEFEAT vs. Velvet Viv                   ★
Score 140 — 210
-18 Trophies          Stars: 15/25 (+1)
+25 Coins             Stakes Lost: Auto Serve, Clear Bottle, Double Serve

✅ Daily: Play 5 matches (3/5)

[REMATCH]   [HOME]
```

**Loss (no stakes) — 1 star:**
```
DEFEAT vs. Velvet Viv                   ★
Score 140 — 210
-18 Trophies          Stars: 15/25 (+1)
+25 Coins             No stakes risked

[REMATCH]   [HOME]
```

**Win (0 or 1 stakes — no multiplier shown):**
```
VICTORY vs. Velvet Viv                  ★★★
Score 260 — 115
+16 Trophies                      Stars: 18/25 (+3)
+120 Coins    (Cocktail base)
Venue Tokens: +1

[CLAIM ALL]   [REMATCH]   [HOME]
```

Note: the last example shows 3 stars because the margin is 0.56 (decisive) — stake count does not affect stars. Also per §4.2.1, a 1-stake play is visually identical to a 0-stake play: no stake line, no multiplier pill.

### 14.3 AI booster usage — unchanged

v7.1 §14.3 stands.

---

## 15. Home layout — Arena Selector row removed

Replace the "Arena Selector chips" line in v7.0 §15 / v7.1 §15 with:

- **Current Arena card** (static, non-interactive): venue art + arena name + trophy progress bar ("Cocktail Lounge — 620 / 1,000 to Speakeasy").

No chip row, no tap-to-switch, no "currently playing" modifier on any other UI element. All other v7.1 §15 items stand.

---

## 16. Save schema

### 16.1 Schema changes (replaces v7.1 §16.1)

```js
save = {
  // loadout — UPDATED rarity restriction
  loadout: {
    equippedBoosterId: string | null,                     // any rarity, used in-match
    stakes: [ goldBoosterId | null, goldBoosterId | null, goldBoosterId | null, goldBoosterId | null ],
    //        4 slots (was 3 in v7.1); only Gold-rarity ids accepted
    perk1Id, perk2Id
  },

  // DELETED in v7.2:
  //   currentPlayingArena     → removed; current arena derived from trophies at runtime

  // analytics events renamed / deleted:
  //   bet_tier        → REMOVED (deleted in v7.1)
  //   bet_survived    → stakes_survived_count (integer)
  //   stake_count     → (kept, integer 0–4)
  //   stake_booster_rarity → (kept, string; now always "gold" in MVP)
  //   arena_selected  → REMOVED (no selector)
  //   match_result    → (kept; now carries score_margin_ratio and star_count fields)

  // everything else unchanged from v7.1 §16
  // ...
}
```

### 16.2 Migration on load (replaces v7.1 §16.2)

- If `gold` field exists: `coins += round(gold * 1.5)`, then delete `gold` (v7.1 carryover).
- If `loadout.betId` exists: `loadout.stakes = [loadout.betId, null, null, null]`, delete legacy fields (v7.1 carryover).
- **New in v7.2:** walk `loadout.stakes` — for any entry whose booster is Silver rarity, eject it back to the player's inventory and null the slot. Show a one-time toast on next Home: *"Staking is now Gold-only. Silver boosters returned to inventory."*
- **New in v7.2:** expand `loadout.stakes` from length 3 to length 4, padding with `null`.
- **New in v7.2:** if `equippedBoosterId` is missing, default to the highest-rarity booster the player owns with count ≥1, else null.
- **New in v7.2:** delete `currentPlayingArena` from save. Runtime derives the current arena from trophy count (§8.1).
- Analytics migration: any queued/pending `bet_survived` event renamed to `stakes_survived_count`. Any pending `arena_selected` event dropped. Any historical `stake_count = 1` events remain (they'll just cluster at ×1 payout in dashboards).
- Mission `use_5_bets` → `stake_2_wins` (v7.1 carryover). **New in v7.2:**
  - if `maxUnlockedArena < cocktail_lounge`, remove `stake_2_wins` and `3_star_match` from the active rotation, re-roll from the open pool.
  - if `play_2_arenas` is in the active rotation, remove it (mission deleted) and re-roll from the open pool.

### 16.3 Starter inventory — unchanged

v7.1 §16.3 stands. Starter has 0 Gold boosters — matches the "staking unlocks at Cocktail Lounge" rule.

---

## 17. Prototype scope

Replace the **Match economy** subsection of v7.1 §17.1 with:

**Match economy**
- [ ] Coins + Stars in save + HUD (no Gold slot)
- [ ] 9-booster tiered roster; tier + stake-eligibility tag in data
- [ ] Equipped booster slot + **4 Gold-only Stake slots** + 2 Perk slots
- [ ] Stake-UI hidden when player owns 0 Gold boosters
- [ ] Stake-and-return logic (survive on win, consume on loss)
- [ ] Coin payout table by arena × stake multiplier × On Fire
- [ ] Visible opponent stake count pill on matchmaking (only when ≥2)
- [ ] Reject Silver/Bronze in stake slots with a toast

Replace the **Matchmaking + arena** subsection first item with:

- [ ] **Current Arena = current trophy band; no selector.** Auto-promote on threshold cross; auto-demote on trophy loss across threshold.
- [ ] Current Arena card on Home (static, non-interactive).

**Delete from v7.1 §17.1 entirely:**
- "Arena Selector chip row + trophy scaling"
- Any task referring to diminishing returns
- Any task referring to `arena_selected` analytics

**Add to v7.1 §17.1 (Match scoring):**
- [ ] Match score tracked per side (serve totals, per §core)
- [ ] `margin_ratio` computed at match end: `(winner − loser) / max(winner, 1)`
- [ ] Star award: 3 if win & ratio ≥ 0.35; 2 if win & ratio < 0.35; 2 if draw; 1 if loss
- [ ] Result screen shows final score for both players + star count

All other v7.1 §17.1 items stand.

Add to v7.1 §17.2 (Not required / MVP cuts):
- Diamond stake tier (×5 multiplier above 3,000 trophies)
- Tournament event entry fees (MM-style stakes tournaments — future feature)
- Arena Selector (cut outright; not a future feature unless design reverses)

---

## 18. Acceptance spot-checks (replaces v7.1 §18)

- [ ] No `gold` field anywhere in save, UI, or result screen (carryover)
- [ ] HUD currency row shows only Coins + Stars (carryover)
- [ ] PLAY button deducts nothing on tap; matchmaking starts immediately (carryover)
- [ ] **Stake slots accept only Gold tier boosters; Silver and Bronze rejected with toast**
- [ ] **4 stake slots visible in loadout UI when player owns ≥1 Gold booster; hidden entirely when player owns 0 Gold**
- [ ] **1-stake win: no ×1 pill shown, no "stakes kept" line on result, payout identical to 0-stake**
- [ ] 2-stake win multiplies coin payout ×2 (Cocktail Lounge base 120 × 2 = 240)
- [ ] **3-stake win multiplies ×3; 4-stake win multiplies ×4 (unlocked at Speakeasy)**
- [ ] On Fire + 3 stakes stacks: Cocktail Lounge win 120 × 2 (On Fire) × 3 = 720
- [ ] Stakes return to inventory on win, consumed on loss, return on draw
- [ ] Opponent card shows stake count pill only when ≥2; no pill at 0 or 1
- [ ] **Stars awarded by score margin: 3 if win & ratio ≥ 0.35; 2 if win & ratio < 0.35; 2 if draw; 1 if loss**
- [ ] **Stars are independent of stake count** (4-stake close win = 2 stars; 0-stake blowout = 3 stars)
- [ ] Result screen shows both players' final scores
- [ ] **No Arena Selector UI anywhere; Home shows single non-interactive Current Arena card**
- [ ] **No `currentPlayingArena` in save; current arena derived from trophy count**
- [ ] **Auto-promote to next arena on trophy threshold cross; auto-demote on drop across threshold**
- [ ] **No diminishing-returns table in UI or docs** (both 3-col and 4-col versions deleted)
- [ ] Trophy Road milestone #7 grants 1 Gold booster + 400 Coins + Cocktail Lounge + Venue landmark, and triggers a "Staking Unlocked" prompt
- [ ] Trophy Road milestone #10 grants 2 Gold boosters + triggers "×4 Stakes Unlocked" prompt
- [ ] Trophy Road milestone 20 grants 2,000 Coins + legendary cosmetics (v7.1 was 2,500 — trimmed)
- [ ] 25 stars queues Star Chest; contents use coin values from §10.3 (v7.2 rates) and match the player's current arena row
- [ ] Lucky Box reward: 4 boosters + 80 Coins + 1 sticker (was 120 in v7.1)
- [ ] Daily Mission `stake_2_wins` exists only when `maxUnlockedArena ≥ cocktail_lounge`
- [ ] Daily Mission `3_star_match` requires winning with margin ratio ≥ 0.35 (score-based); gated to Cocktail Lounge+
- [ ] Daily Mission `play_2_arenas` does **not** exist (deleted with Arena Selector)
- [ ] Daily Chest grants 400 Coins + 3 boosters + 2 stickers + 15 % Token (was 500)
- [ ] Sticker Pack Cheap/Standard/Big priced 150/380/900 Coins (carryover)
- [ ] All rarity labels in UI read "White" not "Common"
- [ ] Migration: save with `loadout.stakes` containing a Silver booster loads clean with slot nulled and Silver returned to inventory; toast shown
- [ ] Migration: save with 3-entry `loadout.stakes` loads with 4-entry array (4th entry `null`)
- [ ] Migration: save with `currentPlayingArena` field loads clean — field deleted, current arena derived from trophies
- [ ] Migration: legacy `bet_survived` events renamed to `stakes_survived_count` in analytics queue
- [ ] Migration: pending `arena_selected` analytics events dropped
- [ ] §22 MM-reference claim about "no coin entry fee on 1v1" carries an inline "unverified pending primary-source re-check" caveat

---

## 19. What this patch explicitly removes (additions to v7.1 §19)

Search & delete from `index-v7.html`:

- All UI paths that place a Silver booster in a stake slot
- Any ×1 pill render on filled stake slots (now suppressed — see §4.2.1)
- Stake readout UI showing ×1 at stake count 1 (replace with no readout)
- Analytics event `bet_survived` — rename to `stakes_survived_count`
- Rarity string "Common" anywhere in UI copy / data — replace with "White"
- **Arena Selector chip row and all associated handlers**
- **Diminishing-returns table rendering (both 3-col and 4-col variants)**
- **`currentPlayingArena` save field reads/writes**
- **`arena_selected` analytics event**
- **Daily mission `play_2_arenas` (task + rewards definition)**
- **Star-award logic based on stake-survival count** — replace with score-margin-ratio logic
- **Result-screen star readout keyed to stake survival** — rekey to star_count from §6.1.1

---

## 20. Final intended player feeling — bullets updated

Replace v7.1 §20 with:

- **Every match is free. My risk is what I stake.** Playing costs nothing; risking my Gold boosters is a choice.
- **One wallet, clear choices.** Coins pay for boosters, packs, chest shortcuts — I decide where to spend.
- **Staking is the fast path to coins.** Passive drips keep me alive; stake multipliers make me rich.
- **I always walk away with something.** 1 star + base coins on loss; stake multiplier pays me more for playing bigger.
- **Stars measure how I played, not how much I wagered.** A decisive win is 3 stars whether I risked nothing or risked four.
- **The arena is where my trophies put me.** No shopping for easier tiers; no farming-down UI. I climb, I'm there.
- **Collection is the long game.** Sticker albums and the Venue both grow from the same coin pool.
- **Stakes = the actual bet.** ×2, ×3, ×4 (future ×5) is the difference between a safe win and a spiked one.
- **Boosters are simple tools, not a treadmill.** 9 identities, 3 tiers, flat power; Gold doubles as wager fuel. Silver and Bronze never stake.

---

## 21. One-line meta loop (replaces v7.1 §21)

**Open app → Lucky Box + yesterday's dailies → current-arena card shows where I am → bring an equipped booster + optionally stake 2–4 Gold boosters → fight named opponent → win by a margin I can feel → multiplied coins + stars by margin + sticker drop → chest pops at 25 stars → pack or booster from coins → page fills → album completes → Venue Tokens earned → Venue building upgrades → Trophy Road ticks (staking unlocks at #7, ×4 at #10) → tomorrow I'm one arena closer, heavier stakes.**

Three braided loops on one spine:
- **Tactical** — equipped booster choice, stake count, perks, board routing, score margin
- **Economic** — coins in (staked wins), coins out (Gold refills, packs, shortcuts)
- **Collection** — stickers + Venue, both fed by play, flexed forever

---

## 22. Confidence notes on the MM reference (replaces v7.1 §22)

Verified from Candivore's own help articles and cross-referenced trade-press coverage:

- MM's stakes multiplier ladder is **×2 / ×3 / ×4 / ×5** (Candivore article title is literally "Booster Stakes Multiplier — x2 / x3 / x4 / x5"). mix-it MVP builds ×2 / ×3 / ×4 and notes ×5 as future. Source: [Booster Stakes Multiplier — Candivore](https://candivore.zendesk.com/hc/en-us/articles/6352690476314-Booster-Stakes-Multiplier-x2-x3-x4-x5), accessed 2026-04-21.
- **Staking is restricted to Diamond / Legendary / Special Edition boosters** in MM. mix-it's Gold-only rule is the direct analog. Source: [Candivore article above] + [What is Booster Stakes Multiplier in Match Masters? — Gamers Dunia, 2025](https://gamersdunia.com/booster-stakes-multiplier/) + [Beginner's Guide to Match Masters Booster Stakes Multiplier — Allloot, 2024](https://allloot.com/match-masters-booster-multiplier/).
- MM's ×5 unlocks at **30,000 trophies**; mix-it scales this to 3,000 (the last ~20 % of the ladder, matching MM's endgame proportion).
- MM grants **2–3 stars on win depending on score margin**, 1 on loss. mix-it v7.2 adopts this directly with a 0.35 margin-ratio threshold for 3 stars (the exact MM threshold is not publicly documented; 0.35 is a playtest starting value). Source: [Naavik — Match Masters deconstruction](https://naavik.co/deep-dives/match-masters-deconstruction/).
- MM uses an **auto-tiered arena model** — the player plays in the arena matching their trophy count, with no selector or farming-down UI. mix-it v7.2 adopts this directly (Arena Selector deleted).
- MM has **one soft currency: Coins**. mix-it mirrors this (v7.1).
- **⚠ UNVERIFIED pending primary-source re-check:** v7.1 §22 claimed "MM's regular 1v1 matches have no coin entry fee; coin entry exists only in tournament events." Candivore's own Coins / Play Mode articles returned 403 to our fetch attempts. Naavik's deep-dive text reads "you need coins to enter Solo Events, Duo Events, and to challenge players in the Arena" — ambiguous about matchmade 1v1. **This claim should be re-verified with an in-client screenshot or a fresh Candivore quote before being treated as load-bearing.** For now, mix-it proceeds on the v7.1 interpretation (no coin ante) because the Stakes Multiplier is the documented wager system. Reopen if playtest of MM confirms a hidden coin-per-match fee.

No fabricated MM behavior.

---

## 23. Summary of numeric + structural changes in v7.2 (for quick scan)

| Lever | v7.1 | v7.2 | Δ |
|---|---:|---:|---:|
| Stake slots | 3 | 4 | +1 |
| Max MVP multiplier | ×3 | ×4 | +1 tier |
| Stake-eligible rarities | Silver + Gold | Gold | −1 tier |
| **Star rule** | stake-survival-count | **score-margin-ratio (MM-faithful)** | rewritten |
| **3-star condition** | ≥1 stake survived | **win & margin ratio ≥ 0.35** | rewritten |
| **Arena Selector** | chip row + 3-col scaling | **removed; auto-tier by trophies** | deleted |
| **Diminishing returns table** | 3-column | **deleted** | removed |
| **`currentPlayingArena` save field** | present | **deleted** | removed |
| **`arena_selected` analytics event** | present | **deleted** | removed |
| **`play_2_arenas` daily mission** | present | **deleted** | removed |
| Trophy Road total coin payout | ~16,250 | ~14,750 | −1,500 |
| Lucky Box coins | 120 | 80 | −40 |
| Daily Chest coins | 500 | 400 | −100 |
| Star Chest coins (all arenas) | 120/260/500/900/1,600/2,900 | 100/220/420/750/1,400/2,600 | ~−10 % |
| Modeled daily coin ceiling | ~1,700 (unmodeled spike tail) | ~2,500 (spike tail modeled) | +800 / honest |
| Naming: Common/White | mixed | "White" only | consistent |
| `bet_survived` analytics event | present | renamed `stakes_survived_count` | renamed |

End of patch v7.2.
