# PATCH v7.1 — COIN ECONOMY, MM-FAITHFUL

**Applies on top of:** `design-v7.0-patch-match-masters-refactor.md`
**Date:** 2026-04-21
**Purpose:** Align mix-it's economy with Match Masters' actual structure. Remove the invented Gold currency. Remove the invented per-match ante. Replace the single-booster Bet slot with MM's real wager mechanic — the **Booster Stakes Multiplier**.

---

## 0. Why this patch exists

v7.0 invented two things that Match Masters does not have:

1. A **second soft currency** called Gold (MM has one soft currency: Coins).
2. A **mandatory per-match coin/gold ante** on regular PvP matches (MM does not — entry fees exist only on tournament events, which are a separate feature).

MM's real "wager" is the **Booster Stakes Multiplier** (source: Candivore help — "Booster Stakes Multiplier"):
- You risk 1, 2, or 3 boosters (up to 5 at high trophies).
- On win: rewards (stars, trophies, coins, event points) multiply by that factor.
- On loss: you lose the staked boosters.
- Only high-rarity boosters qualify.

This patch rebuilds mix-it's match economy around that single mechanic and collapses the currency model to MM's actual shape.

**Supersedes (within v7 scope):**
- §2 Currency model
- §4.2 Bet slot rules (concept deleted — see §4.5 terminology note)
- §5 Match Bet (entire section — removed)
- §6.1, §6.2, §6.4 Match rewards
- §7.1, §7.2 Matchmaking filters
- §8.3 Practice Mode (removed)
- §9.1 Trophy Road rewards (Gold → Coins)
- §10.1, §10.2, §10.3 Daily Missions / Lucky Box / Star Chest rewards (Gold → Coins)
- §11.6, §11.7 Sticker Packs pricing + rewards (Gold → Coins)
- §11.8 Token yields unchanged; Diamond dupe value unchanged
- §12 Economy wiring (entirely rewritten)
- §13.1, §13.3, §13.4, §13.5, §13.7, §13.8 Shop sections (Gold → Coins)
- §14.1, §14.2 Match flow + result screen (no ante line)
- §15.1 Home layout (currency row becomes Coins + Stars only)
- §16 Save schema (`gold` field removed)
- §17, §18, §19, §20, §21 Scope / acceptance / feeling updates

Everything not listed stays as in v7.0.

---

## 1. Design stance — updates

Replace the v7.0 stance bullets as follows.

- **Boosters are bets, not inventory fluff.** Staking boosters on a match is the risk decision.
- **Rarity is the economy.** Every booster belongs to a tier; tier determines acquisition cost, coin payout, stake eligibility.
- **Guaranteed progress on every match.** A loss must still move *something* forward.
- **Free tools for mistakes; paid boosters for advantage.** No player ever loses to lack of undo/spawn.
- **One soft currency, one job.** Coins fund everything earnable (boosters, stickers, chests). No parallel softs.
- **No per-match entry fee.** Matches are always free to enter. The only thing you risk is the boosters you choose to stake.
- **The Venue grows by playing, not paying.** All buildings unlock and upgrade from play-earned Venue Tokens.
- **Collection is the retention engine.** Sticker albums + Venue — both drink from the same single coin faucet so pacing is honest.

---

## 2. Currency model (rewritten)

### 2.1 Two HUD balances

| Balance | Earned from | Spent on | Cap |
|---|---|---|---:|
| **Coins** | Match results, On Fire streak, duplicates, missions, chests, Lucky Box, Trophy Road, Bar Pass, daily gift | Booster Shop (A), Sticker Packs (F), Star Chest shortcut (B) | soft cap 99,999 |
| **Stars** | 1 loss / 2 win / 3 win-with-stakes-survived / 2 draw | Accumulate to Star Chest (25-meter) | no cap |

Plus one non-HUD progression item:

| Item | Earned from | Spent on | On HUD? |
|---|---|---|---|
| **Venue Tokens** | Match win, arena promo, Daily Chest, Seasonal Album completion, Bar Pass | Venue buildings + upgrades only (§11.14) | Venue tab only |

And one collection token:

| Item | Earned from | Spent on | On HUD? |
|---|---|---|---|
| **Sticker Tokens** | Diamond duplicate, Trophy Road 8/14/20, Bar Pass, Daily Chest 15%, Full album, Starter Pack | Pick any 1 missing sticker | Albums tab only |

### 2.2 Gold currency — deleted

- `gold` field removed from save (see §16 migration).
- Every v7.0 reference to "Gold" as a currency is replaced with "Coins" at the rates in §2.3.
- The word "Gold" is reserved exclusively for the **Gold booster tier** (Clear Bottle / Auto Serve / Double Serve) and the **Gold sticker rarity**. No ambiguity in UI copy.

### 2.3 Gold → Coin conversion (for migrating every table in v7.0)

v7.0 priced collection in gold at roughly 2.5× the booster-coin scale. This patch uses a **1.5× conversion** (gold × 1.5 → coins) because collapsing to one currency means the coin faucet now feeds both sinks. Round to the nearest 10.

| v7.0 Gold | v7.1 Coins |
|---:|---:|
| 30 | 50 |
| 50 | 80 |
| 80 | 120 |
| 100 | 150 |
| 150 | 230 |
| 200 | 300 |
| 250 | 380 |
| 300 | 450 |
| 500 | 750 |
| 600 | 900 |
| 700 | 1,050 |
| 800 | 1,200 |
| 900 | 1,350 |
| 1,000 | 1,500 |
| 2,000 | 3,000 |
| 3,000 | 4,500 |
| 5,000 | 7,500 |
| 8,000 | 12,000 |

All tables in §9, §10, §11.6, §11.7, §13 use this mapping.

### 2.4 Why one soft currency works

- **MM does it.** Candivore ships MM with coins as the only soft currency; stickers, boosters, spins, and chests all draw from the same pool.
- **Single faucet is easier to balance.** One coin-in, one coin-out pacing table instead of two.
- **No "can't afford to play" state.** No affordability gate on the main loop, so Practice Mode disappears (see §8).
- **Legible UI.** Home HUD shrinks from 3 counters (Coins / Gold / Stars) to 2 (Coins / Stars).

---

## 3. Boosters — unchanged

§3.1–§3.4 of v7.0 stand as-is. 9 boosters, 3 tiers, coin-priced.

---

## 4. Pre-match loadout (revised)

### 4.1 Structure: Stakes + Perks

```
+----------------------------------------+
|           CHOOSE YOUR LOADOUT          |
+----------------------------------------+
|  [ STAKE 1 ]  [ STAKE 2 ]  [ STAKE 3 ] |   ← 0–3 boosters, multiplier = count
|                                        |
|  [ PERK 1 ]   [ PERK 2 ]               |
+----------------------------------------+
|    Reward multiplier:  ×1    ×2    ×3  |
+----------------------------------------+
```

The single "Bet slot" from v7.0 is replaced by **three optional Stake slots**. This is MM's actual Booster Stakes Multiplier.

### 4.2 Stake slot rules (replaces v7.0 §4.2)

- Each stake slot accepts **one booster of eligible tier**.
- **Eligible tiers for staking: Silver + Gold.** Bronze cannot be staked (Bronze is the always-available utility floor — MM restricts staking to rarer tiers).
- **Multiplier = number of filled stake slots.** 0 → ×1 (no bonus), 1 → ×1, 2 → ×2, 3 → ×3.
  (Staking 1 booster is the same payout as staking 0, by design — the first stake is the price of entry to the multiplier curve. Stake 2+ for the real lift.)
- On **win**: all staked boosters return to inventory; rewards multiply (§6.1).
- On **loss**: all staked boosters are consumed; base rewards unmultiplied.
- On **draw**: staked boosters return; base rewards unmultiplied.
- Empty stake (0 boosters) is the default and always allowed — no pressure.
- Pre-match confirm only when stake count ≥ 2:
  > "Stake 2 boosters for ×2 rewards? You'll lose them on a loss."

### 4.3 Perk slots — unchanged

Perks are not stakeable. v7.0 §4.3 stands.

### 4.4 Future Diamond tier (noted, not built)

When Diamond boosters ship, stake cap rises to ×5 above 3,000 trophies, mirroring MM's Masters/Legends behavior. Not MVP.

### 4.5 Terminology — "bet tier" is deleted

The v7.0 term **"bet tier"** does not exist in Match Masters and is removed from mix-it entirely. It conflated two separate MM axes into one invented concept:

- **Booster rarity** (Bronze / Silver / Gold / future Diamond) — a property of the booster itself. Drives shop price and stake eligibility. Does **not** drive match payout.
- **Stake count** (0 / 1 / 2 / 3 / future up to 5) — how many boosters you risk this match. Drives the reward multiplier.

These are independent. Staking one Gold booster and staking one Silver booster give the **same ×1 multiplier** — the only difference is what you risk losing. The match's coin payout comes from the arena (§6.2), not from the booster's rarity.

Anywhere the code, UI copy, analytics event, or save field says `betTier`, `bet_tier`, `betId`, `betRarity`, or "Bet slot" — rename or delete per §16.1 and §19. Live vocabulary going forward: **stake slot**, **stake count**, **stake multiplier**, **booster rarity**.

---

## 5. Match Bet — SECTION REMOVED

v7.0 §5 in its entirety is removed. There is no ante, no pot, no arena gold treadmill, no two-stake concept.

Matches are free to enter. The only thing the player wagers is the boosters they choose to put in stake slots (§4.2).

---

## 6. Match rewards (revised)

### 6.1 Reward formula (replaces v7.0 §6.1)

```
Trophies = arena_base_delta × arenaScaling (§8.2) × stakeMultiplier
Stars    = 3 (win, stakes survived AND ≥1 stake)
         | 2 (win, no stakes)
         | 1 (loss, any)
         | 2 (draw)
Coins    = base_coin_payout(arena) × win_loss_mult × on_fire_mult × stakeMultiplier
```

`stakeMultiplier = max(1, filled_stake_slots)` (1 stake still × 1; see §4.2).

### 6.2 Base coin payout by arena (replaces v7.0 §6.2)

v7.0's "coin payout by bet tier" table is deleted. The concept of "bet tier" does not exist in MM (see §4.5). Coin payout now scales by **arena**, with the stake multiplier applied as a post-multiplier. Booster rarity never affects match payout.

| Arena | Win | Loss | Draw |
|---|---:|---:|---:|
| Juice Stand | 30 | 8 | 15 |
| Beach Bar | 60 | 15 | 30 |
| Cocktail Lounge | 120 | 25 | 60 |
| Speakeasy | 200 | 40 | 100 |
| Rooftop Terrace | 320 | 60 | 160 |
| Grand Hotel | 500 | 90 | 250 |

Applied *before* multipliers. So a Cocktail Lounge win with 3 stakes + On Fire → 120 × 2 (On Fire) × 3 (stake) = **720 coins**. That's the spike.

### 6.3 On Fire streak — unchanged

v7.0 §6.3 stands. 2 consecutive wins → next match ×2 coins + ×2 trophies. Multiplicative with stakeMultiplier.

### 6.4 Guaranteed progress floor (replaces v7.0 §6.4)

Every match, regardless of outcome, grants at least:
- 1 Star
- Base coin loss payout (see §6.2 — lowest is 8 coins at Juice Stand)
- Daily mission progress (if playing ranked arena)

No ante refund concept. No match costs coins to enter.

---

## 7. Matchmaking (revised)

### 7.1 Filter (replaces v7.0 §7.1)

1. Trophy band (±100)
2. **Stake count** — player and AI are matched on similar stake slot fill (0–1 vs. 0–1, 2 vs. 2, 3 vs. 3)

Matching on stake count preserves risk symmetry. (v7.0's "bet tier" filter is deleted along with the concept — see §4.5.)

### 7.2 AI stake generation (replaces v7.0 §7.2)

| Player stakes | AI stakes |
|---:|---|
| 0 | 0 (75%) / 1 (25%) |
| 1 | 1 (60%) / 0 (25%) / 2 (15%) |
| 2 | 2 (60%) / 1 (25%) / 3 (15%) |
| 3 | 3 (50%) / 2 (50%) |

AI booster rarity for filled stakes: Silver (70%) / Gold (30%) regardless of player's mix.

### 7.3 Named AI personas + Rematch — unchanged in principle

v7.0 §7.3 stands, with one wording change: opponent card shows **stake count** (×1 / ×2 / ×3). The v7.0 "Bet tier visible" line on the opponent card is deleted — there is no bet tier. Rematch preserves persona + stake selection.

---

## 8. Arena Selector, diminishing returns

### 8.1 Arena Selector — unchanged

v7.0 §8.1 stands.

### 8.2 Diminishing returns — unchanged

v7.0 §8.2 stands. Trophy and coin scaling on low-arena farming is the same. (No ante column — delete that column from the table; the other three stay.)

### 8.3 Practice Mode — SECTION REMOVED

Practice Mode existed only as a broke-gated fallback. With no ante, no player is ever broke-gated. The section, the save flag, the Home button, and the "offer Practice" flow in §14.1 are all removed.

Players who want to learn the water-sort core do so by playing actual (free) matches at Juice Stand.

---

## 9. Trophy Road — currency update

§9.1 milestone rewards are rewritten with Gold → Coins conversion (§2.3). All other Trophy Road rules (§9.2–§9.4) stand.

### 9.1 Milestones (replaces v7.0 §9.1)

| # | Trophies | Reward | Type |
|---:|---:|---|---|
| 1 | 50 | 100 Coins | small |
| 2 | 100 | 2 Bronze boosters + **Bronze Frame** (stickers locked until #4) | cosmetic |
| 3 | 150 | 80 Coins | small |
| 4 | 200 | **Beach Bar unlock + 2 Silver boosters + 250 Coins + Venue landmark unlock** | arena promo |
| 5 | 300 | 1 Silver booster + **Title: Regular** + 5 stickers (Bar Classics) | cosmetic |
| 6 | 400 | 270 Coins | small |
| 7 | 500 | **Cocktail Lounge unlock + 1 Gold booster + 400 Coins + Venue landmark unlock** | arena promo |
| 8 | 650 | 230 Coins + **Avatar 2** + 1 Sticker Token | cosmetic |
| 9 | 800 | 2 Silver boosters + 200 Coins | small |
| 10 | 1000 | **Speakeasy unlock + 2 Gold boosters + 600 Coins + Venue landmark unlock** | arena promo |
| 11 | 1200 | 380 Coins + **Silver Frame** + 5 stickers (City Nights) | cosmetic |
| 12 | 1400 | 1 Gold booster + **Title: Pro Bartender** | cosmetic |
| 13 | 1600 | 300 Coins | small |
| 14 | 1800 | 450 Coins + **Avatar 3** + 1 Sticker Token | cosmetic |
| 15 | 2000 | **Rooftop Terrace unlock + 2 Gold boosters + 1,000 Coins + Venue landmark unlock** | arena promo |
| 16 | 2400 | 750 Coins + **Gold Frame** | cosmetic |
| 17 | 2800 | 2 Gold boosters + **Title: Mixologist** + 5 stickers (Grand Hotel album) | cosmetic |
| 18 | 3200 | 1,050 Coins + **Avatar 4** | cosmetic |
| 19 | 3500 | **Grand Hotel unlock + 3 Gold boosters + 1,250 Coins + Venue landmark unlock** | arena promo |
| 20 | 4000 | 2,500 Coins + **Diamond Frame + Title: Legend + Avatar 5** + 2 Sticker Tokens + 10 mixed stickers | end-of-road flex |

---

## 10. Daily Missions, Lucky Box, Star Chest — currency update

### 10.1 Daily Missions (replaces v7.0 §10.1)

3 rotating tasks, refresh at local midnight.

| id | Task | Reward |
|---|---|---|
| win_3 | Win 3 matches | 200 Coins |
| serve_50 | Serve 50 customers | 150 Coins + 1 Silver booster |
| stake_2_wins | Win 2 matches with ≥2 stakes | 250 Coins + 1 Silver booster |
| combo_4 | Hit a 4-combo | 200 Coins + 1 Silver booster |
| play_2_arenas | Play in 2 different arenas | 230 Coins |
| lucky_box_2 | Claim Lucky Box twice | 150 Coins + 1 Bronze booster |
| earn_500_coins | Earn 500 Coins from matches | 200 Coins |
| open_chest | Open any chest | 150 Coins + 2 Bronze boosters |
| 3_star_match | Win with stakes surviving (≥1 stake) | 300 Coins + 1 Gold booster |
| play_5 | Play 5 matches (win or lose) | 200 Coins |

Daily mission `use_5_bets` from v7.0 is replaced by `stake_2_wins` (stakes replace the bet-slot concept).

#### Daily Chest (all 3 complete)
- 500 Coins + 3 random boosters + 2 stickers + 15% Sticker Token chance

#### Rules
- Progress on any match (no Practice exception — there is no Practice).
- Auto-claim on 3rd completion.
- Unclaimed forfeit at midnight.

### 10.2 Lucky Box (replaces v7.0 §10.2)

- Home button with 4h countdown.
- Reward: **4 random boosters** + 120 Coins + 1 sticker (Common-weighted).
- Persists `luckyBox.nextAvailableAt`.
- Tier weight per booster roll: Bronze 70% / Silver 25% / Gold 5%.

### 10.3 Star Chest (replaces v7.0 §10.3)

25-meter unchanged. Contents table:

| Arena | Coins | Boosters | Stickers | Decor chance |
|---|---:|---|---|---:|
| Juice Stand | 120 | 2 Bronze | 2 (C/S) | 25% |
| Beach Bar | 260 | 2 (B/S) | 3 | 20% |
| Cocktail Lounge | 500 | 3 (S-weighted) | 3 (1+ S guaranteed) | 18% |
| Speakeasy | 900 | 3 (S/G) | 4 (1+ G possible) | 15% |
| Rooftop Terrace | 1,600 | 4 (S/G) | 4 (1+ G) | 12% |
| Grand Hotel | 2,900 | 4 (G) | 5 (1+ G guaranteed, D possible) | 10% |

Decor roll fires only if the arena's Venue pool has unearned landmarks.

---

## 11. Stickers + Venue — currency update

Structural sections §11.1–§11.5, §11.8–§11.19 unchanged. Two tables rewrite.

### 11.6 Sticker Packs — Coins-priced (replaces v7.0 §11.6)

| Pack | Contents | Coins |
|---|---|---:|
| Cheap Pack | 3 stickers (White/Silver only) | 150 |
| Standard Pack | 5 stickers (standard rarity roll) | 380 |
| Big Pack | 10 stickers (1+ Gold guaranteed) | 900 |

Duplicate auto-conversion (unchanged from v7.0):

| Rarity | Dupe → |
|---|---|
| White | +10 Coins |
| Silver | +40 Coins |
| Gold | +150 Coins |
| Diamond | +1 Sticker Token |

Note: White dupes = 10 coins and a Cheap Pack = 150 coins. Duplicate churn doesn't self-fund pack buying — you still need to earn from matches. Intentional.

### 11.7 Page + album completion rewards (replaces v7.0 §11.7)

#### Page completion (5/5)
250 Coins + 1 random booster

#### Regular Album completion (20/20)
3,000 Coins + 3 Gold boosters + 1 Sticker Token + **Title unlock** (per album)

#### Seasonal Album completion (20/20)
- 6,000 Coins
- 5 Gold boosters + 2 Sticker Tokens
- 1 Exclusive Seasonal Frame
- 1 Exclusive Seasonal Title
- 1 Venue Token

---

## 12. Economy wiring (rewritten)

### 12.1 Sinks by balance

| Balance | Primary sink | Secondary sink |
|---|---|---|
| **Coins** | Booster Shop (A) | Sticker Packs (F) + Star Chest shortcut (B) |
| **Stars** | Star Chest at 25 | Future: team box |
| **Venue Tokens** | Venue buildings + upgrades | — |
| **Sticker Tokens** | Missing sticker grant | — |

One soft currency, multiple sinks, no overlap within a sink group — the collection sinks (sticker packs, chest shortcut) and the combat sink (booster shop) draw from the same coin pool, creating "spend on power vs. spend on collection" tension inside a single balance. This is MM's structure.

### 12.2 Faucets by balance

| Balance | Faucets |
|---|---|
| **Coins** | Match result (§6.2), On Fire ×2, stake multiplier up to ×3, duplicate stickers, mission rewards, chest rolls, Trophy Road, Lucky Box, Bar Pass, album completion |
| **Stars** | Per-match (§6.1) |
| **Venue Tokens** | 1/win, 5/arena promo, 1/Daily Chest, 1/Seasonal Album, 3/BP Premium t20 |
| **Sticker Tokens** | Diamond dupe, Trophy Road 8/14/20, BP Premium t15 & t30, Daily Chest 15%, Full album |

### 12.3 Pacing (engaged daily player, Beach Bar, 50% WR, avg 1-stake games)

| Lever | Per day |
|---|---:|
| Matches played | 8–12 |
| Avg coin income per match | ~45 (mixed win/loss/stake) |
| Coin income (total) | 450–600 |
| Mission + Daily Chest coins | ~800 (full clear) |
| Lucky Box (3–4 claims) | ~360 |
| Trophy Road trickles | ~100 avg |
| **Total coin-in** | ~1,700–1,900 / day engaged |
| Target coin-out | 1 Standard Sticker Pack (380) + 1 Silver booster (150) = 530 / day baseline |
| Net coin savings | ~1,200 / day toward a Big Pack (900) every other day OR Gold booster (400) buildup |

Coin target replaces v7.0's split "gold: save for pack, coins: save for booster." Now it's a single "which sink is worth it today" decision.

### 12.4 Pacing sanity check vs. v7.0

v7.0 gave engaged players ~400 coins + ~300 gold net per day = effectively ~1,200 "currency value" at gold's 1.5× weight. v7.1 gives ~1,700 coins/day. Modest intentional inflation — the single-currency model has no "ante tax" draining half of one bucket, so baseline income lands higher, which re-inflates booster refills (lost stakes) and pack saving at roughly the same pace as v7.0's dual budget. Verify in playtest.

---

## 13. Shop + monetization shells (rewritten)

All $ buttons show "Coming soon" toast. Shapes defined.

### 13.1 Shop structure (replaces v7.0 §13.1)

| Section | Contents | Currency |
|---|---|---|
| A | Boosters (per-tier, §3.1) | Coins |
| B | Star Chest shortcut | **Coins** |
| C | $ Bundles (rotating 3 SKUs) | $ |
| D | Bar Pass entry | $ |
| F | **Sticker Packs** | **Coins** |

### 13.2 Section A — Booster Shop — unchanged

v7.0 §13.2 stands.

### 13.3 Section B — Star Chest shortcut (replaces v7.0 §13.3)

| Arena | Price (Coins) |
|---|---:|
| Juice Stand | 300 |
| Beach Bar | 600 |
| Cocktail Lounge | 1,200 |
| Speakeasy | 2,400 |
| Rooftop Terrace | 4,500 |
| Grand Hotel | 7,500 |

### 13.4 Section C — $ Bundles (replaces v7.0 §13.4)

| Bundle | Contents | Placeholder price |
|---|---|---:|
| Bartender's Starter | 1,500 Coins + 5 boosters | $1.99 |
| Weekend Warrior | 6,000 Coins + 15 boosters + 1 Star Chest | $4.99 |
| Grand Stock | 24,000 Coins + 40 boosters + 3 Star Chests + 1 Exclusive Avatar | $19.99 |

### 13.5 Section F — Sticker Packs — see §11.6

### 13.6 Bar Pass — BPP unchanged, rewards converted

Tier rewards re-priced with Gold → Coin mapping. Abbreviated tier table:

| Tier | Free | Premium |
|---:|---|---|
| 1 | 50 Coins | 150 Coins + 2 boosters |
| 2 | 1 booster | 200 Coins + 2 boosters |
| 3 | 80 Coins | 1 Silver booster |
| 5 | 2 boosters | **Exclusive Seasonal Frame** + 1 Sticker Token |
| 10 | 1 Silver booster | 1 Star Chest + **Exclusive Avatar** |
| 15 | 300 Coins | 3 boosters + 800 Coins + 3 Big Packs + 1 Token |
| 20 | 1 Gold booster | **Exclusive Seasonal Title** + 750 Coins + 1 Venue seasonal landmark |
| 25 | 2 Silver boosters | 10 boosters + 2 Star Chests |
| 30 | 300 Coins | **3,000 Coins + Exclusive Seasonal Avatar + 2 Tokens + 1 Diamond sticker (player choice)** |

Rules unchanged from v7.0 §13.6.

### 13.7 Starter Pack (replaces v7.0 §13.7)

| Item | Qty |
|---|---|
| Coins | 2,000 |
| Boosters | 10 random (mixed tier) |
| Stickers | 5 (incl. 1 guaranteed Gold) |
| Sticker Token | 1 |
| Frame | "Founder's Frame" |
| Star Chest | 1 (Beach Bar tier) |

Placeholder: $2.99. 48h window.

### 13.8 Flash Offers (replaces v7.0 §13.8)

| Trigger | Offer | Price | Timer |
|---|---|---:|---:|
| 3 losses in a row | Comeback Bundle: 900 Coins + 3 boosters | $0.99 | 30 min |
| Arena promotion | Promotion Pack: arena-scaled coins + 5 boosters + cosmetic token | $2.99 | 24 h |
| Daily Chest claimed + coins < 200 | Refill Pack: 1,000 Coins + 2 boosters | $1.99 | 2 h |
| 3rd sticker pack in session without Gold pull | Sticker Splurge: 1 Big Pack + 1 Token | $1.99 | 2 h, 1/48h cap |

Note the low-coins trigger replaces v7.0's low-gold trigger. Threshold tuned so it fires only when a Cheap Pack (150) is barely affordable.

### 13.9 No-pay-to-win rails — unchanged

v7.0 §13.9 stands.

---

## 14. Match flow + result screen (revised)

### 14.1 Flow (replaces v7.0 §14.1)

```
HOME → tap PLAY
  → MATCHMAKING (persona + their stake count visible, §7.3)
  → PRE-MATCH LOADOUT (Stake slots ×3 + 2 Perks, §4)
  → COUNTDOWN → MATCH (unchanged)
  → RESULT
  → REWARD CLAIM SEQUENCE:
    1. Trophy + coins + stars (with stake multiplier applied)
    2. Trophy Road milestone claims
    3. Star Chest if meter filled
    4. Daily Mission progress + Daily Chest if 3/3
    5. Sticker Album page / album completion popups
    6. Venue landmark / building unlocks + Venue Token grant
    7. Bar Pass tier-up
    8. Flash Offer trigger eval
  → [Rematch] / [Home] / [Shop]
```

No affordability check before matchmaking. No ante deduction. No Practice branch.

### 14.2 Result screen examples (replaces v7.0 §14.2)

**Win (2 stakes, survived):**
```
VICTORY vs. Velvet Viv
+32 Trophies  (×2 stake)          Stars: 20/25 (+3)
+240 Coins    (Cocktail base ×2 stake)
Stakes Kept: Auto Serve, Color Splash
Venue Tokens: +1

📍 Trophy Road: Milestone 5 ready to claim!
✅ Daily: Win 2 matches with ≥2 stakes (1/2)
🎟️ NEW STICKER — Gold: "Midnight Martini" (City Nights 3/20)
🏘️ Venue: Cocktail Lounge — "Neon Fountain" ready to upgrade (L2)

[CLAIM ALL]   [REMATCH]   [HOME]
```

**Loss (2 stakes, lost):**
```
DEFEAT vs. Velvet Viv
-18 Trophies          Stars: 18/25 (+1)
+25 Coins             Stakes Lost: Auto Serve, Color Splash

✅ Daily: Play 5 matches (3/5)

[REMATCH]   [HOME]
```

**Loss (no stakes):**
```
DEFEAT vs. Velvet Viv
-18 Trophies          Stars: 18/25 (+1)
+15 Coins             No stakes risked

[REMATCH]   [HOME]
```

### 14.3 AI booster usage — unchanged

v7.0 §14.3 stands.

---

## 15. Home layout + navigation (revised)

### 15.1 Home — top to bottom (replaces v7.0 §15.1)

1. Profile Card strip (avatar + frame + title + trophies)
2. **Currency row (Coins / Stars)** — Gold slot removed
3. Star Meter + Lucky Box countdown button
4. Daily Missions (3 rows, compact)
5. Trophy Road horizontal strip
6. Arena Selector chips
7. Venue preview (current arena's venue interior)
8. Sticker Album progress card
9. **PLAY button — label just "PLAY"** (no ante copy)
10. Flash Offer banner (only when active)
11. Bar Pass banner

The v7.0 "Practice" button next to PLAY is removed.

### 15.2 Bottom nav — unchanged

v7.0 §15.2 stands.

### 15.3 Profile Card — unchanged

v7.0 §15.3 stands.

---

## 16. Save schema (updated)

### 16.1 Schema changes

```js
save = {
  // currencies — UPDATED
  coins, stars, starsMeter,
  // REMOVED: gold

  // loadout — UPDATED
  loadout: {
    stakes: [ boosterId | null, boosterId | null, boosterId | null ],  // up to 3, Silver/Gold rarity only
    perk1Id, perk2Id
  },
  // REMOVED: loadout.betId, loadout.betTier (concept deleted — see §4.5)

  // everything else unchanged from v7.0 §16
  trophies, arena, currentPlayingArena, maxUnlockedArena,
  boosters, perks,
  onFireStreak, onFireActive,
  luckyBox, starChestPending,
  trophyRoad, dailyMissions,
  stickers, stickerTokens, claimedPageRewards, claimedAlbumRewards, unlockedAlbums,
  venue,
  profile,
  barPass,
  starterPack, activeFlashOffer, lossStreak,
  achievements
}
```

### 16.2 Migration on load (replaces v7.0 §16.1)

- If `gold` field exists: `coins += round(gold * 1.5)`, then delete `gold`.
- If `loadout.betId` exists (legacy v7.0 save): `loadout.stakes = [loadout.betId, null, null]`, then delete `loadout.betId` and `loadout.betTier`. The fields are gone after migration.
- Strip `venueBuildings`, `memorabilia`, `stats.xp`, `stats.playerLevel` (unchanged).
- If `coins` unset after all merges: seed Starter inventory (§16.3).
- Initialize empty `stickers`, `venue`, `trophyRoad` if missing.
- Mission `use_5_bets` in active rotation → rewrite to `stake_2_wins` with progress reset to 0.

### 16.3 Starter inventory (replaces v7.0 §16.2)

| Item | Qty |
|---|---:|
| Extra Bottle (Bronze) | 3 |
| First Pour (Bronze) | 2 |
| Color Splash (Silver) | 1 |
| Swap (Silver) | 1 |
| Perks (all 3) | unlocked |
| Coins | 200 |
| Stars | 0 |
| Venue Tokens | 0 |
| Opening Night album | unlocked, 3 Common stickers seeded |
| Sticker Token | 1 |

---

## 17. Prototype scope (updated)

Replace the **Match economy** subsection of v7.0 §17.1 with:

**Match economy**
- [ ] Coins + Stars in save + HUD (no Gold slot)
- [ ] 9-booster tiered roster; tier tags in data
- [ ] 3 Stake slots (Silver/Gold eligible) + 2 Perk slots
- [ ] Stake-and-return logic (survive on win, consume on loss)
- [ ] Coin payout table by **arena** × stake multiplier × On Fire
- [ ] Visible opponent stake count + persona on matchmaking
- [ ] No ante deduction anywhere
- [ ] No Practice Mode button, flow, or state

Replace the first item under **Matchmaking + arena**:
- [ ] Arena Selector chip row + trophy scaling (no ante column)

All other v7.0 §17.1 items stand.

Add to v7.0 §17.2 (Not required / MVP cuts):
- Diamond stake tier (×5 multiplier above 3,000 trophies)
- Tournament event entry fees (MM-style stakes tournaments — future feature)

---

## 18. Acceptance spot-checks (replaces v7.0 §18)

- [ ] No `gold` field anywhere in save, UI, or result screen
- [ ] HUD currency row shows only Coins + Stars
- [ ] PLAY button deducts nothing on tap; matchmaking starts immediately
- [ ] Stake slots accept only Silver + Gold tier boosters; Bronze rejected with toast
- [ ] 2-stake win multiplies coin payout ×2 (verify: Cocktail Lounge base win 120 × 2 = 240)
- [ ] 3-stake win multiplies coin payout ×3 and trophies ×3
- [ ] On Fire + 2 stakes stacks: Cocktail Lounge win 120 × 2 (On Fire) × 2 (stake) = 480
- [ ] Stakes return to inventory on win, consumed on loss, return on draw
- [ ] Opponent card shows stake count (×1 / ×2 / ×3) + persona tagline pre-match
- [ ] Trophy Road milestone 4 grants 2 Silver boosters + 250 Coins + Beach Bar + Venue landmark
- [ ] Trophy Road milestone 20 grants 2,500 Coins + legendary cosmetics
- [ ] 25 stars queues Star Chest; contents use coin values from §10.3
- [ ] Lucky Box reward: 4 boosters + 120 Coins + 1 sticker
- [ ] Daily Mission `stake_2_wins` exists; `use_5_bets` does not
- [ ] Daily Chest grants 500 Coins + 3 boosters + 2 stickers + 15% Token
- [ ] Sticker Pack Cheap/Standard/Big priced 150/380/900 Coins
- [ ] Page completion (5/5): 250 Coins + 1 booster
- [ ] Regular album completion (20/20): 3,000 Coins + 3 Gold boosters + Token + title
- [ ] Seasonal album completion (20/20): 6,000 Coins + 5 Gold boosters + 2 Tokens + frame + title + Venue Token
- [ ] Star Chest shortcut in Shop B priced in Coins per §13.3
- [ ] Shop Section C bundle click → "Coming soon" toast
- [ ] Bar Pass Free tier 1 grants 50 Coins (not 30 Gold)
- [ ] Migration: save with `gold: 100` loads clean with `coins += 150`, no `gold` field
- [ ] Migration: save with legacy `loadout.betId: "swap"` loads with `loadout.stakes: ["swap", null, null]`
- [ ] No "Practice" button on Home in any state
- [ ] Flash offer "low-gold" trigger replaced by "coins < 200 after Daily Chest"
- [ ] Result screen shows no "Ante" line

---

## 19. What this patch explicitly removes (additions to v7.0 §19)

Search & delete from `index-v7.html`:

- All `gold` save field reads/writes
- All HUD slot for gold (icon, counter, tooltip)
- Ante deduction, pot settlement, refund logic
- Ante table reference in result screen
- Practice Mode: button, flag, flow branch, AI preset, reward-suppression logic
- "Offer Practice" gate before matchmaking
- **The entire "bet tier" concept (see §4.5).** Not an MM mechanic. Every occurrence deleted:
  - Bet-tier matchmaking filter → replace with stake-count filter
  - Single-booster Bet slot UI → replace with 3 Stake slots
  - Coin payout table indexed by "Bet tier" (None / Bronze / Silver / Gold) → replace with per-arena base (§6.2)
  - Opponent card line "their Bet tier visible" → replace with stake count pill (×1 / ×2 / ×3)
  - Save fields `loadout.betId`, `loadout.betTier` → removed after migration (§16.2)
  - Analytics events referencing `bet_tier`, `betTier`, `bet_rarity` → rename to `stake_count` and `stake_booster_rarity` (two separate fields)
  - UI copy strings containing "bet tier," "your bet," "Gold bet win," etc. → rewrite in stake language
- Daily mission `use_5_bets`; replace with `stake_2_wins`
- Flash offer "low-gold" trigger; replace with "low-coins"
- Pre-match confirm copy "Play without a bet? You'll earn fewer coins and risk no booster." (no longer meaningful — risk is only stake choice)

---

## 20. Final intended player feeling (replaces v7.0 §20)

- **Every match is free. My risk is what I stake.** Playing costs nothing; risking my best boosters is a choice.
- **One wallet, clear choices.** Coins pay for boosters, packs, chest shortcuts — I decide where to spend next.
- **I always walk away with something.** 1 star + base coins on loss; stake multiplier pays me for playing bigger when I win.
- **Collection is the long game.** Sticker albums and the Venue both grow from the same coin pool, so my saving is legible.
- **Stakes = the actual bet.** ×1, ×2, ×3 is the difference between a safe win and a spiked one.
- **Boosters are simple tools, not a treadmill.** 9 identities, 3 tiers, flat power; Silver/Gold double as wager fuel.

---

## 21. One-line meta loop (replaces v7.0 §21)

**Open app → Lucky Box + yesterday's dailies → pick arena → choose how many boosters to stake (0–3) → fight named opponent → win multiplied coins + stars + sticker drop → chest pops at 25 stars → pack or booster from coins → page fills → album completes → Venue Tokens earned → Venue building upgrades → Trophy Road ticks → Bar Pass climbs → tomorrow the same climb, heavier stakes.**

Three braided loops on one spine:
- **Tactical** — stake choice, perks, board routing
- **Economic** — coins in, coins out (boosters vs. collection)
- **Collection** — stickers + Venue, both fed by play, flexed forever

---

## 22. Confidence notes on the MM reference

Verified from Candivore's own help articles:

- MM has **one soft currency: Coins**, used for boosters, stickers, spins, chests. (source: Candivore — "Coins" article)
- MM's wager is the **Booster Stakes Multiplier**: stake 1/2/3 boosters, rewards multiply by count; ×5 at 30k+ trophies; Diamond/Legendary/Special boosters only. (source: Candivore — "Booster Stakes Multiplier" article)
- MM's **regular 1v1 matches have no coin entry fee**. Coin entry exists only in **tournament events** (a separate, optional feature not mirrored in this MVP).
- Stars: MM grants 2–3 on win (3 if margin ≥30%), 1 on loss. mix-it uses stake-survived as the "3-star" condition rather than margin — more legible for a water-sort variant where score margin is less meaningful. Noted design variance, intentional.

Anything this patch states about MM is either (a) backed by the above, or (b) a labeled mix-it design variance. No fabricated MM behavior.
