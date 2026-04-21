# PATCH v7.0 — MATCH MASTERS FULL REFACTOR (consolidated)

**Applies to:** `design-v6.md` + patches 6.1 through 6.6.1  
**Supersedes / ignores:** patches 6.7, 6.8, 6.9, and the earlier v7.1 / v7.2 split drafts (all merged into this file)  
**Date:** 2026-04-20  
**Reference games:** Match Masters (Candivore) — boosters, bets, stickers, pass, chests. Trophy Hunter (Ten Square Games) — Hunter Lodge that fills with earned items and upgrades via play-earned tokens.  
**Purpose:** Bring mix-it's entire meta into structural alignment with Match Masters and Trophy Hunter, while preserving the water-sort-pour-serve core. One document covers match economy, retention layers, progression, collection, and monetization.

---

## 0. Reading guide

- **§1–§3**: match economy — boosters, loadout, bet + ante, match rewards
- **§4–§5**: matchmaking, AI personas, arena selector, practice
- **§6–§9**: retention — Trophy Road, Daily Missions, Lucky Box, Star Meter → Star Chest
- **§10–§11**: collection — Sticker Albums, The Venue (Trophy-Hunter-style hub)
- **§12**: gold / coin / star economy wiring (sinks + faucets)
- **§13**: monetization shells (placeholders — no real purchase logic)
- **§14**: match flow + result screen + reward claim sequence
- **§15**: Home layout, navigation, HUD
- **§16–§18**: save schema, prototype scope, acceptance checks

Nothing in this patch touches water-sort board mechanics, pour rules, Color Spawn, serve rules, combo rules, or customer patience. Those stay as in v6 / v6.6.1.

---

## 1. Design stance (non-negotiable)

- **Boosters are bets, not inventory fluff.** Equipping the bet booster is a risk choice.
- **Rarity is the economy.** Every booster belongs to a tier; tier determines acquisition cost, coin payout, matchmaking pool.
- **Guaranteed progress on every match.** A loss must still move *something* forward.
- **Free tools for mistakes; paid boosters for advantage.** No player ever loses to lack of undo/spawn.
- **Three currencies, three sinks, no overlap.** Coins fund combat (boosters). Gold funds collection (sticker packs, chest shortcuts, ante). Stars feed the meter + future social.
- **The Venue grows by playing, not paying.** All building unlocks and upgrades come from earned Venue Tokens, never from gold or $.
- **Collection is the retention engine.** Sticker albums (MM-faithful: Regular + Seasonal + rarity pulls + duplicates + tokens), not Memorabilia plaques.

---

## 2. Currency model

### 2.1 Three currencies

| Currency | Earned from | Spent on | Cap |
|---|---|---|---:|
| **Coins** | Match results (scales with bet tier), On Fire streak, daily gift, duplicates | Booster Shop (Section A) | soft cap 9,999 |
| **Stars** | 1 loss / 2 win / 3 win+bet-survived / 2 draw | Accumulate to Star Chest (25-meter); future team boxes | no cap |
| **Gold** | Match ante pot (on win/draw), chest rewards, Trophy Road, Lucky Box, missions, Bar Pass | Match ante, Sticker Packs (Shop F), Star Chest shortcut (Shop B) | soft cap 9,999 |

### 2.2 Venue Tokens (§11.14)
Separate play-earned progression item. Not a currency (doesn't accumulate into a balance shown on HUD). Spent only in the Venue.

### 2.3 Why three currencies
- **Coins** = short combat loop (boosters feed wins, wins earn coins).
- **Gold** = collection + entry-fee loop (ante to play, packs to collect).
- **Stars** = guaranteed progress floor (loss still gives 1, chest pops at 25).

No direct trade between currencies in MVP. Each has its own sink.

---

## 3. Boosters

### 3.1 Rarity tiers

| Tier | Count | Power | Shop price (Coins) | Win payout (Coins) | Loss penalty |
|---|---:|---|---:|---:|---|
| **Bronze** | 3 | utility / setup | 50 | +30 | lose bet (1 qty) |
| **Silver** | 3 | tactical / conversion | 150 | +60 | lose bet (1 qty) |
| **Gold** | 3 | match-winning / rescue | 400 | +120 | lose bet (1 qty) |
| *Diamond (future)* | *6* | *live-ops, event-only* | *event-only* | *+240* | *lose bet* |

### 3.2 Full roster

#### Bronze — utility / workspace
| Booster | Effect | Role |
|---|---|---|
| **Extra Bottle** | Add 1 empty bottle for rest of match | Workspace |
| **First Pour** | Start match with 2 free instant pours pre-loaded | Opening tempo |
| **Spawn+3** | Start match with +3 Color Spawn charges | Early board control |

#### Silver — tactical / conversion
| Booster | Effect | Role |
|---|---|---|
| **Color Splash** | Recolor top segment of 1 bottle (≤2 layers) to visible customer color | Route conversion |
| **Swap** | Select 2 bottles; full contents swap | Tactical re-layout |
| **Customer Lock** | Freeze 1 customer's patience bar for 8s | Deny opponent's serve window |

#### Gold — match-winning / rescue
| Booster | Effect | Role |
|---|---|---|
| **Clear Bottle** | Select 1 bottle; discard all contents | Emergency anti-deadlock |
| **Auto Serve (20s)** | For 20s, valid serveable glasses auto-serve after 0.3s delay | Serve-race scoring window |
| **Double Serve** | Next serve grants 2× points (stacks with combo + first-serve) | Score-bomb finisher |

### 3.3 Tier tuning rules
- **Bronze** useful every match, never decisive
- **Silver** visibly turns a match
- **Gold** match-defining; scarce; 20s duration not 30s (shorter spikes, not passive buffs)

### 3.4 Arena unlock gating

| Arena | Roster available |
|---|---|
| Juice Stand (0–199) | All 3 Bronze |
| Beach Bar (200–499) | + All 3 Silver |
| Cocktail Lounge (500–999) | + Clear Bottle, Auto Serve |
| Speakeasy (1000–1499) | + Double Serve (full Gold roster) |
| Rooftop+ | no new roster; higher payouts + Diamond (future) |

---

## 4. Pre-match loadout

### 4.1 Structure: 1 Bet + 2 Perks

```
+------------------------------------+
|         CHOOSE YOUR LOADOUT        |
+------------------------------------+
|  [ BET SLOT ]    ← 1 booster (stake)|
|                                    |
|  [ PERK 1 ] [ PERK 2 ]             |
+------------------------------------+
```

### 4.2 Bet slot rules
- Exactly 1 booster from any owned tier
- **Win = survive + higher coin payout**
- **Loss = consumed** (whether or not activated during match)
- Empty Bet allowed — plays at "None" coin payout tier (see §6.2), no stake
- Pre-match confirm if empty: "Play without a bet? You'll earn fewer coins and risk no booster."

### 4.3 Perk slots
- Up to 2 Perks from a separate Perk inventory
- **Perks do not stake.** 2–3 uses per match. Not lost on loss.
- MVP perks (3 total, granted at start, never lost):

| Perk | Effect | Uses |
|---|---|---:|
| **Second Look** | 1 extra Undo hint (tutorial flavor) | 2 |
| **Steady Hand** | Next pour immune to opponent's Customer Lock / Auto Serve | 2 |
| **Pour Read** | Briefly highlights the single best pour | 1 |

Perks remain mild by design — they are the always-available support layer so boosters stay scarce.

---

## 5. Match Bet: gold ante + booster stake

Every PvP match has **two independent stakes**: a mandatory gold ante (MM's real bet) + an optional booster stake (MM's "bring a premium booster" risk).

### 5.1 Ante per arena

| Arena | Ante (gold) | Pot | Net win | Net loss |
|---|---:|---:|---:|---:|
| Juice Stand | 10 | 20 | +10 | −10 |
| Beach Bar | 25 | 50 | +25 | −25 |
| Cocktail Lounge | 60 | 120 | +60 | −60 |
| Speakeasy | 140 | 280 | +140 | −140 |
| Rooftop Terrace | 280 | 560 | +280 | −280 |
| Grand Hotel | 550 | 1100 | +550 | −550 |

- No house rake at launch
- Draw refunds ante to both players

### 5.2 Flow

```
Tap PLAY
  → check gold ≥ arenaAnte
    → if no: offer Practice (§8.3)
    → if yes: deduct ante, enter matchmaking
  → Bet booster staked (if equipped)
  → on win:  gold += 2 × ante; bet booster returns
  → on loss: ante forfeit; bet booster consumed
  → on draw: gold += ante; bet booster returns
```

### 5.3 Pre-match summary

```
STAKES
Ante:  25 Gold       (pot: 50 Gold)
Bet:   Color Splash  (Silver)
```

---

## 6. Match rewards

### 6.1 Reward formula
```
Trophies = arena_base_delta × arenaScaling (§8.2)
Gold     = ante_pot_settlement (§5) + arena_flat_bonus
Stars    = 3 (win, bet survived) | 2 (win, no bet) | 1 (loss, any) | 2 (draw)
Coins    = bet_tier_payout × win_loss_mult × on_fire_mult
```

### 6.2 Coin payout table

| Bet | Win | Loss | Draw |
|---|---:|---:|---:|
| None (empty Bet) | 15 | 8 | 10 |
| Bronze | 30 | 15 | 20 |
| Silver | 60 | 25 | 40 |
| Gold | 120 | 40 | 70 |

### 6.3 On Fire streak
- After **2 consecutive wins**, next match is On Fire
- On Fire effect: **2× coins + 2× trophies** from that match only
- Consumed on any outcome (win or loss)
- Visual: flame ring on avatar during matchmaking

### 6.4 Guaranteed progress floor
Every match, regardless of outcome, grants at least:
- 1 Star
- 8 Coins
- Ante-settlement gold (always pays out via draw refund / loss-zero / win-pot)

No match is ever fully empty.

---

## 7. Matchmaking

### 7.1 Filter (two axes)
1. Trophy band (±100)
2. Bet tier — same tier as player, or closest

### 7.2 AI bet generation

| Player bet | AI bet |
|---|---|
| None | None (70%) / Bronze (30%) |
| Bronze | Bronze (80%) / Silver (20%) |
| Silver | Silver (70%) / Bronze (15%) / Gold (15%) |
| Gold | Gold (60%) / Silver (40%) |

Symmetric risk reinforces the stake tension.

### 7.3 Named AI personas + Rematch

~12 named bartenders per arena. Each persona has: name (e.g. "Sandy Pete", "Velvet Viv"), avatar emoji, 1-line tagline, fake trophies in arena range.

On matchmaking reveal: opponent card shows avatar + name + tagline + trophies + **their Bet tier visible**.
On result: "VICTORY vs. Sandy Pete" / "DEFEAT vs. Sandy Pete".
**Rematch** button preserves persona + ante + bet selection.

---

## 8. Arena Selector, diminishing returns, Practice

### 8.1 Arena Selector
- Chip row on Home, pick any arena at or below `maxUnlockedArena`
- Persists as `currentPlayingArena`
- No cooldown

### 8.2 Diminishing returns on low-arena farming

When `currentPlayingArena < maxUnlockedArena`:

| Arena delta | Trophy gain × | Trophy loss × | Coin payout × |
|---|---:|---:|---:|
| 0 | 1.0× | 1.0× | 1.0× |
| −1 | 0.5× | 0.25× | 0.75× |
| −2 | 0.25× | 0.1× | 0.5× |
| −3+ | 0× | 0× | 0.3× |

Ante/pot and Star Meter fill scale normally (arena-local economy stays honest). UI labels "No trophies at this arena" when delta ≥ 3.

### 8.3 Practice Mode (broke-gated only)
- Button on Home only when `gold < currentPlayingArena.ante`
- Juice Stand AI, no ante, no bet booster
- Zero rewards (no gold, coins, stars, trophies, missions, Road, Lucky Box timer)
- Loadout still applied for learning
- Hidden when gold is sufficient

No always-on Training mode. If the player has gold, they play real matches.

---

## 9. Trophy Road

20 milestones from 0 → 4000 trophies. Arena promotions **consolidate onto** this track — no separate promotion reward screen.

### 9.1 Milestones

| # | Trophies | Reward | Type |
|---:|---:|---|---|
| 1 | 50 | 30 Gold + 50 Coins | small |
| 2 | 100 | 2 Bronze boosters + **Bronze Frame** (stickers locked until #4) | cosmetic |
| 3 | 150 | 50 Gold | small |
| 4 | 200 | **Beach Bar unlock + 2 Silver boosters + 100 Coins + Venue landmark unlock** | arena promo |
| 5 | 300 | 1 Silver booster + **Title: Regular** + 5 stickers (Bar Classics) | cosmetic |
| 6 | 400 | 80 Gold + 150 Coins | small |
| 7 | 500 | **Cocktail Lounge unlock + 1 Gold booster + 200 Coins + Venue landmark unlock** | arena promo |
| 8 | 650 | 150 Gold + **Avatar 2** + 1 Sticker Token | cosmetic |
| 9 | 800 | 2 Silver boosters + 200 Coins | small |
| 10 | 1000 | **Speakeasy unlock + 2 Gold boosters + 300 Coins + Venue landmark unlock** | arena promo |
| 11 | 1200 | 250 Gold + **Silver Frame** + 5 stickers (City Nights) | cosmetic |
| 12 | 1400 | 1 Gold booster + **Title: Pro Bartender** | cosmetic |
| 13 | 1600 | 300 Coins | small |
| 14 | 1800 | 300 Gold + **Avatar 3** + 1 Sticker Token | cosmetic |
| 15 | 2000 | **Rooftop Terrace unlock + 2 Gold boosters + 500 Coins + Venue landmark unlock** | arena promo |
| 16 | 2400 | 500 Gold + **Gold Frame** | cosmetic |
| 17 | 2800 | 2 Gold boosters + **Title: Mixologist** + 5 stickers (Grand Hotel album) | cosmetic |
| 18 | 3200 | 700 Gold + **Avatar 4** | cosmetic |
| 19 | 3500 | **Grand Hotel unlock + 3 Gold boosters + 750 Coins + Venue landmark unlock** | arena promo |
| 20 | 4000 | 1000 Gold + 1000 Coins + **Diamond Frame + Title: Legend + Avatar 5** + 2 Sticker Tokens + 10 mixed stickers | end-of-road flex |

### 9.2 Rules
- Claim-on-reach, no expiration
- Trophy drop below threshold does NOT unclaim
- Claimable milestones stack as pending
- Arena unlock side-effect fires at threshold regardless of claim

### 9.3 UI
- Horizontal scrollable strip on Home, between Arena Selector and Venue preview
- Progress bar to next milestone
- Pulse "CLAIM" on reached tiles
- Tap locked tile = preview

### 9.4 Save
```js
trophyRoad = {
  highestTrophiesReached: number,   // monotonically non-decreasing
  claimedMilestones: number[]
}
```

No Player Level / XP system. Progression lives on Trophy Road + Bar Pass; that's enough.

---

## 10. Daily Missions, Lucky Box, Star Meter

### 10.1 Daily Missions

3 rotating tasks, refresh at local midnight.

#### Pool
| id | Task | Reward |
|---|---|---|
| win_3 | Win 3 matches | 40 Gold + 100 Coins |
| serve_50 | Serve 50 customers | 30 Gold + 1 Silver booster |
| use_5_bets | Equip a Bet in 5 matches | 30 Gold + 100 Coins |
| combo_4 | Hit a 4-combo | 40 Gold + 1 Silver booster |
| play_2_arenas | Play in 2 different arenas | 50 Gold + 150 Coins |
| lucky_box_2 | Claim Lucky Box twice | 30 Gold + 1 Bronze booster |
| earn_200_coins | Earn 200 Coins from matches | 50 Gold + 100 Coins |
| open_chest | Open any chest | 30 Gold + 2 Bronze boosters |
| 3_star_match | Win with bet surviving | 60 Gold + 1 Gold booster |
| play_5 | Play 5 matches (win or lose) | 40 Gold + 100 Coins |

Selection: 3 distinct per day, always include at least one play-count-friendly.

#### Daily Chest (all 3 complete)
- 150 Gold + 300 Coins + 3 random boosters + 2 stickers + 15% Sticker Token chance

#### Rules
- Progress only from real ante-paying matches (not Practice)
- Auto-claim on 3rd completion
- Unclaimed forfeit at midnight

### 10.2 Lucky Box
- Home button with 4h countdown
- Reward: **4 random boosters** + 50 Coins + 30 Gold + 1 sticker (Common-weighted)
- Persists `luckyBox.nextAvailableAt` across reloads
- Tier weight per booster roll: Bronze 70% / Silver 25% / Gold 5%

### 10.3 Star Meter → Star Chest

Stars accumulate into a 25-meter.

- On `starsMeter >= 25`: queue 1 Star Chest, `starsMeter -= 25`
- Max 1 chest queued; excess caps at 25 until claimed

#### Star Chest contents by arena

| Arena | Gold | Coins | Boosters | Stickers | Decor chance |
|---|---:|---:|---|---|---:|
| Juice Stand | 40 | 50 | 2 Bronze | 2 (C/S) | 25% |
| Beach Bar | 80 | 100 | 2 (B/S) | 3 | 20% |
| Cocktail Lounge | 150 | 200 | 3 (S-weighted) | 3 (1+ S guaranteed) | 18% |
| Speakeasy | 280 | 350 | 3 (S/G) | 4 (1+ G possible) | 15% |
| Rooftop Terrace | 500 | 600 | 4 (S/G) | 4 (1+ G) | 12% |
| Grand Hotel | 900 | 1000 | 4 (G) | 5 (1+ G guaranteed, D possible) | 10% |

Decor roll only fires if the arena's Venue pool has unearned landmarks.

---

## 11. Stickers (Match Masters model) + The Venue (Trophy Hunter model)

### 11.1 Sticker system — MM-faithful

Stickers are mix-it's collection spine. The structure follows Match Masters verbatim where practical, scaled for a single-player prototype.

#### Unlock
Sticker feature unlocks at **200 trophies** (coincides with Beach Bar unlock and Trophy Road milestone #4). Before that, the Albums tab shows a preview with "Unlock at 200 🏆".

#### Rarities (MM-faithful)
| Rarity | Drop weight |
|---|---:|
| **White** (Common) | 60% |
| **Silver** | 28% |
| **Gold** | 10% |
| **Diamond** | 2% |

(MM uses "White" for Common; we follow that naming.)

### 11.2 Album types

MM has 5 album types. We implement 2 for MVP + reserve 3 for future.

| Album type | MVP? | Purpose |
|---|---|---|
| **Regular Albums** | ✅ MVP | Permanent, always-on collections. Primary sticker sink. |
| **Seasonal Albums** | ✅ MVP (1 per season) | Time-limited, 30-day window aligned with Bar Pass season. Rotating content. |
| **Solo Albums** | ⏸ Future | Filled through solo-mode wins (no solo mode in MVP) |
| **Team Albums** | ⏸ Future | Requires team membership (no teams in MVP) |
| **Adventure Albums** | ⏸ Future | Event-mode albums (no event mode in MVP) |

### 11.3 Regular Albums (MVP content)

**3 Regular Albums** launch-ready, each with its own theme. Each album has **4 pages × 5 stickers = 20 stickers** per album.

| Album | Theme | Unlocks at |
|---|---|---|
| **Bar Classics** | timeless bar memorabilia | 200 trophies (first to unlock) |
| **City Nights** | cocktail / urban / speakeasy | 1000 trophies (Speakeasy) |
| **Grand Hotel** | luxury / Legendary flex | 2500 trophies (Grand Hotel) |

Per-album rarity mix: 10 White / 6 Silver / 3 Gold / 1 Diamond.

### 11.4 Seasonal Album (MVP content)

1 Seasonal Album active at any time. Aligned with the 30-day Bar Pass season. When a new season starts, the prior Seasonal Album is **archived** (view-only, cannot be completed) and a new one replaces it.

- 4 pages × 5 stickers = 20 stickers
- Theme rotates (first season: "Summer Rooftop")
- Completion reward is **larger** than Regular Albums (see §11.7)
- If the player doesn't complete it in 30 days, it archives incomplete — no forfeit penalty beyond lost chance at that season's rewards

### 11.5 Sticker acquisition (MM-faithful, multi-channel)

Every MM sticker source mapped to a mix-it source:

| MM source | mix-it implementation |
|---|---|
| Teammate trades / requests | ⏸ future (no teams MVP) — slot reserved |
| Coin-purchased packs | **Sticker Packs in Shop** (gold-priced in mix-it, since coins go to boosters — see §11.6) |
| Daily gift links | **Lucky Box 4h sticker drop** (§10.2) |
| Season chest rewards | **Star Chest sticker drops** (§10.3) |
| Event participation | ⏸ future — slot reserved for Adventure Albums |
| Daily task completion | **Daily Missions + Daily Chest sticker drops** (§10.1) |
| Sticker Tokens | **Sticker Tokens** (§11.8) |
| Ranking progression | **Trophy Road milestones** (§9.1) |
| Bar Pass tiers | **Bar Pass Free + Premium** (§13.6) |

### 11.6 Sticker Packs (Shop Section F, gold-priced)

| Pack | Contents | Gold |
|---|---|---:|
| Cheap Pack | 3 stickers (White/Silver only) | 100 |
| Standard Pack | 5 stickers (standard rarity roll) | 250 |
| Big Pack | 10 stickers (1+ Gold guaranteed) | 600 |

Duplicates convert automatically:

| Rarity | Dupe → |
|---|---|
| White | +10 Coins |
| Silver | +40 Coins |
| Gold | +150 Coins |
| Diamond | **+1 Sticker Token** (high-value redirect, not coins) |

### 11.7 Reward per page and per album

#### Page completion (5/5)
100 Gold + 100 Coins + 1 random booster

#### Regular Album completion (20/20)
1000 Gold + 1000 Coins + 3 Gold boosters + 1 Sticker Token + **Title unlock** (Bar Classics → "Classic Act", City Nights → "Night Owl", Grand Hotel → "Connoisseur")

#### Seasonal Album completion (20/20)
**Larger, event-grade reward:**
- 2000 Gold + 2000 Coins
- 5 Gold boosters + 2 Sticker Tokens
- 1 Exclusive Seasonal Frame (non-recurring — this season only)
- 1 Exclusive Seasonal Title
- 1 Venue Token (§11.11)

This tier difference is intentional: Seasonal is the "push" content; miss it and you miss the frame.

### 11.8 Sticker Tokens

Unlock any 1 missing sticker of player's choice. Sources:

| Source | Token yield |
|---|---:|
| Bar Pass Premium tier 15 | 1 |
| Bar Pass Premium tier 30 | 2 |
| Full Regular Album completion | 1 each (3 max) |
| Full Seasonal Album completion | 2 |
| Diamond duplicate | 1 |
| Trophy Road milestones 8, 14, 20 | 1 / 1 / 2 |
| Starter Pack ($) | 1 |
| Flash offer (Sticker Splurge) | 1 |
| Daily Chest (15% chance) | 1 |

### 11.9 UI

- **Albums tab** in bottom nav
- 3 Regular + 1 Seasonal album tiles, each showing 0/20 progress + rarity heatmap
- Tap album → grid of 20 slots across 4 pages
- Tap owned sticker → art + rarity badge + dupe value
- Tap locked → rarity hint + "Use Token" option
- Pack-opening flow: card-flip reveal per sticker; NEW / Duplicate ribbon; end summary ("3 NEW, 2 Duplicate +80 Coins")

### 11.10 First-launch seed
Bar Classics unlocked (teaser; 0/20 until player hits 200 trophies for full system), 3 White stickers pre-placed, 1 Sticker Token.

---

### 11.11 The Venue (Trophy-Hunter-style base hub)

Replaces the v6.5 Venue system entirely. Not "Lodge" — the mix-it theme is a bar ecosystem, so the hub is called **The Venue**: a themed neighborhood that grows as you climb. Modeled on Trophy Hunter's Hunter Lodge pattern, where the base contains **multiple unlockable and upgradable buildings**, each tied to progression and offering features (some functional, some cosmetic).

#### 11.12 Structure

One Venue hub, with **6 themed bars** (one per arena). Each themed bar has its own set of buildings that unlock over time. Terminology: we say **"the Venue"** for the whole hub and **"Juice Stand bar / Beach Bar / Cocktail Lounge / Speakeasy / Rooftop Terrace / Grand Hotel"** for each arena-themed section inside it.

| District | Unlocks at | Buildings |
|---|---|---:|
| Juice Stand | Start | 4 |
| Beach Bar | Trophy Road #4 | 4 |
| Cocktail Lounge | Trophy Road #7 | 5 |
| Speakeasy | Trophy Road #10 | 5 |
| Rooftop Terrace | Trophy Road #15 | 5 |
| Grand Hotel | Trophy Road #19 | 6 |
| **Total buildings** | | **29** |

#### 11.13 Building types

Each venue contains a mix of:

- **Functional buildings** — provide a small gameplay benefit (unlock at building completion):
  - **Sticker Shop** (1 per venue, adds arena-themed sticker packs to Shop F)
  - **Chest Office** (unlocks cheaper Star Chest shortcut — 10% gold discount per venue owned)
  - **Recruiter's Booth** (+1 extra daily mission slot — only 1 exists across whole Venue, at Cocktail Lounge)
- **Cosmetic landmarks** — pure flex, visually dominant:
  - **Winner's Bar** (decorative tavern counter; thematic centerpiece for a venue — no gameplay bonus)
  - Neon signs, fountains, statues, marquee signs, rooftop lights
  - Visible on the map; photographable

Each venue's building list is hand-assigned so every venue has **2 functional + 2–3 cosmetic**.

#### 11.14 Building progression (TH-style, played-not-paid)

Each building has **3 upgrade levels** (Base → Developed → Legendary). Upgrades cost **Venue Tokens** — a dedicated token earned from play, never bought for gold/coins.

| Level | Cost (Tokens) | Effect |
|---:|---:|---|
| Unlock (L1) | 2 | Building appears on map, minimal effect |
| L2 | 5 | Effect strengthened (functional), art improves (cosmetic) |
| L3 | 10 | Max effect, legendary art flourish |

Per building: 17 tokens total. Full Venue: 29 buildings × 17 = **493 Venue Tokens** to fully upgrade everything. Designed to take months at engaged pace.

#### 11.15 Venue Token sources

| Source | Yield |
|---|---:|
| Match win | +1 |
| Arena promotion (Trophy Road arena milestones) | +5 |
| Daily Chest (all 3 missions complete) | +1 |
| Seasonal Album completion | +1 |
| Bar Pass Premium tier 20 | +3 |
| Flash offer "Venue Pack" ($0.99) | +10 (occasional, capped 1/week) |

Approximate engaged-player yield: **8–12 tokens/day** → a building fully upgrades every 1–2 days on average, with the full Venue project spanning ~2–3 months.

#### 11.16 Venue UI

- **Venue tab** in bottom nav
- Full-screen venue interior; swipe between venues (top pills)
- Each building: tap to see name, current level, next-level preview + cost, upgrade button
- Locked buildings ghost-silhouetted with trophy requirement
- Top-right: Venue Token balance
- Home shows small preview of current arena's venue

#### 11.17 What's deleted
- All v6.5 Venue building upgrade mechanics (gold-priced per-level costs, 5×5 matrix, completion bundles)
- Utility Cart
- Venue completion gold bonus cash-ins (now live as Trophy Road rewards)

#### 11.18 Named Memorabilia deleted too
Achievement-driven named plaques from earlier drafts are folded into: (1) Venue cosmetic landmarks (each venue has 1 "plaque" landmark tied to an achievement), (2) sticker grants for achievement-triggered pulls (see §14.3).

---

### 11.19 How Stickers + Venue interact

- Stickers are **what you collect**; Venue is **where you live**. They don't cross-sink gold.
- Seasonal Album completion gives **1 Venue Token** — a small cross-system bridge.
- Every venue's "Sticker Shop" building adds arena-themed sticker packs to Shop F — another bridge.
- No other direct transfers. Each system is legible on its own.

---

## 12. Economy wiring

### 12.1 Sinks by currency

| Currency | Primary sink | Secondary sink |
|---|---|---|
| **Coins** | Booster Shop (Section A) | — |
| **Gold** | Match ante (treadmill) | Sticker Packs (Shop F) + Star Chest shortcut (Shop B) |
| **Stars** | Accumulate to Star Chest | Future: team box |
| **Venue Tokens** | Venue building unlocks + upgrades (§11.14) | — |

### 12.2 Faucets by currency

| Currency | Faucets |
|---|---|
| **Coins** | Match result (§6.2), On Fire doubler, duplicate stickers, mission rewards, chest rolls, Trophy Road, Bar Pass |
| **Gold** | Ante pot on win, arena flat bonus, chest rolls, Trophy Road, Lucky Box, missions, album completion, Bar Pass |
| **Stars** | Per-match (§6.1) |
| **Venue Tokens** | 1/win, 5/arena promo, 1/Daily Chest, 1/Seasonal Album, 3/BP Premium tier 20 |

### 12.3 Pacing (engaged daily player, Beach Bar, 50% WR)

| Lever | Per day |
|---|---:|
| Matches played | 8–12 |
| Ante flux (25g × 10) | ≈0 net |
| Coin income (avg) | 400–500 |
| Gold income (net, post-ante) | 200–400 |
| Star Chest fills | ~1/day |
| Lucky Box claims | 3–4 |
| Daily Missions + Daily Chest | completable |
| Trophy Road milestones | ~1 per 1–2 days early |
| Bar Pass BPP | 60–120/day → full pass 5–7 weeks |
| Venue Tokens | 8–12/day |

Gold target: 1 Standard Pack (250g) every 1–2 days OR 1 Star Chest shortcut every 2 days. Creates the "save or spin" tension.

Coin target: net positive, supporting ~1 Silver booster/day OR saving toward a Gold bet.

---

## 13. Shop + monetization shells

All $ buttons show "Coming soon" toast in prototype. Shapes defined so production can slot real IAP later.

### 13.1 Shop structure

| Section | Contents | Currency |
|---|---|---|
| A | Boosters (per-tier, §3.1) | Coins |
| B | Star Chest shortcut | **Gold** |
| C | $ Bundles (rotating 3 SKUs) | $ |
| D | Bar Pass entry | $ |
| F | **Sticker Packs** | **Gold** |

(Section E skipped — reserved historically, not used.)

### 13.2 Section A — Booster Shop (Coins)

| Booster | Price |
|---|---:|
| Extra Bottle / First Pour / Spawn+3 | 50 each |
| Color Splash / Swap / Customer Lock | 150 each |
| Clear Bottle / Auto Serve / Double Serve | 400 each |

Each purchase = 1 qty. Only unlocked tiers are shown.

### 13.3 Section B — Star Chest shortcut (Gold)

| Arena | Price |
|---|---:|
| Juice Stand | 200 |
| Beach Bar | 400 |
| Cocktail Lounge | 800 |
| Speakeasy | 1600 |
| Rooftop Terrace | 3000 |
| Grand Hotel | 5000 |

### 13.4 Section C — $ Bundles (3 SKUs)

| Bundle | Contents | Placeholder price |
|---|---|---:|
| Bartender's Starter | 500 Gold + 500 Coins + 5 boosters | $1.99 |
| Weekend Warrior | 2000 Gold + 2000 Coins + 15 boosters + 1 Star Chest | $4.99 |
| Grand Stock | 8000 Gold + 8000 Coins + 40 boosters + 3 Star Chests + 1 Exclusive Avatar | $19.99 |

### 13.5 Section F — Sticker Packs (Gold)

| Pack | Contents | Gold |
|---|---|---:|
| Cheap Pack | 3 stickers (C/S only) | 100 |
| Standard Pack | 5 stickers (standard roll) | 250 |
| Big Pack | 10 stickers (1+ Gold guaranteed) | 600 |

### 13.6 Bar Pass (30-day dual-track)

30 tiers. Free (always on) + Premium (unlock $9.99).

#### BPP sources (simple by design)
| Event | BPP |
|---|---:|
| Match played (any outcome) | +5 |
| Match won | +10 bonus |

Only these. Tier N requires `50 × N` BPP cumulative. Full pass ≈ 23,250 BPP ≈ 5–7 weeks engaged play.

#### Reward table (abbreviated)

| Tier | Free | Premium |
|---:|---|---|
| 1 | 30 Gold | 100 Gold + 2 boosters |
| 2 | 1 booster | 200 Coins + 2 boosters |
| 3 | 50 Gold | 1 Silver booster |
| 5 | 2 boosters | **Exclusive Seasonal Frame** + 1 Sticker Token |
| 10 | 1 Silver booster | 1 Star Chest + **Exclusive Avatar** |
| 15 | 100 Gold + 100 Coins | 3 boosters + 500 Coins + 3 Big Packs + 1 Token |
| 20 | 1 Gold booster | **Exclusive Seasonal Title** + 500 Gold + 1 Venue seasonal landmark |
| 25 | 2 Silver boosters | 10 boosters + 2 Star Chests |
| 30 | 200 Gold | **1000 Gold + 1000 Coins + Exclusive Seasonal Avatar + 2 Tokens + 1 Diamond sticker (player choice)** |

Rules: Premium purchase retroactively claims earned Premium tiers. Pass resets end of 30-day window; unclaimed forfeit.

### 13.7 Starter Pack (one-time, 48h after install)

| Item | Qty |
|---|---|
| Gold | 1000 |
| Coins | 500 |
| Boosters | 10 random (mixed tier) |
| Stickers | 5 (incl. 1 guaranteed Gold) |
| Sticker Token | 1 |
| Frame | "Founder's Frame" (exclusive) |
| Star Chest | 1 (Beach Bar tier) |

Placeholder: $2.99. Dismiss on purchase OR 48h, never reappears.

### 13.8 Flash Offers

| Trigger | Offer | Price | Timer |
|---|---|---:|---:|
| 3 losses in a row | Comeback Bundle: 300 Gold + 300 Coins + 3 boosters | $0.99 | 30 min |
| Arena promotion | Promotion Pack: arena-scaled gold + 5 boosters + cosmetic token | $2.99 | 24 h |
| Daily Chest claimed + gold < 100 | Refill Pack: 500 Gold + 200 Coins + 2 boosters | $1.99 | 2 h |
| 3rd sticker pack in session without Gold pull | Sticker Splurge: 1 Big Pack + 1 Token | $1.99 | 2 h, 1/48h cap |

Top banner on Home with countdown.

### 13.9 No-pay-to-win rails
- Boosters available for Coins in Shop A (all tiers). $ buys volume, not unique power.
- All stickers reachable via gameplay. $ accelerates.
- Cosmetics from Trophy Road (free) + Bar Pass premium + Starter Pack / bundle exclusives. No coin-gated cosmetic.
- Venue buildings and Venue Tokens never purchasable.

---

## 14. Match flow + result screen

### 14.1 Flow

```
HOME → tap PLAY
  → check gold ≥ arenaAnte (§5)
    → if no: offer Practice (§8.3)
    → if yes: deduct ante
  → MATCHMAKING (persona + their bet visible, §7.3)
  → PRE-MATCH LOADOUT (Bet slot + 2 Perks, §4)
  → COUNTDOWN → MATCH (unchanged)
  → RESULT
  → REWARD CLAIM SEQUENCE:
    1. Trophy + gold pot + coins + stars
    2. Trophy Road milestone claims
    3. Star Chest if meter filled (stickers + possible decor)
    4. Daily Mission progress + Daily Chest if 3/3
    5. Sticker Album page / album completion popups
    6. Venue landmark / building unlocks + Venue Token grant
    7. Bar Pass tier-up
    8. Flash Offer trigger eval
  → [Rematch] / [Home] / [Shop]
```

### 14.2 Result screen examples

**Win:**
```
VICTORY vs. Velvet Viv
+32 Trophies  (On Fire! ×2)      Ante won: +25 Gold (pot 50)
+120 Coins   (Gold bet win)       Stars: 19/25 (+3)
Bet Kept: Auto Serve              Venue Tokens: +1

📍 Trophy Road: Milestone 5 ready to claim!
✅ Daily: Win 3 matches (2/3)
🎟️ NEW STICKER — Gold: "Midnight Martini" (City Nights 3/20)
🏘️ Venue: Cocktail Lounge — "Neon Fountain" ready to upgrade (L2)

[CLAIM ALL]   [REMATCH]   [HOME]
```

**Loss:**
```
DEFEAT vs. Velvet Viv
-18 Trophies         Ante lost: -25 Gold
+25 Coins            Stars: 17/25 (+1)
Bet Lost: Color Splash

✅ Daily: Play 5 matches (3/5)

[REMATCH]   [HOME]
```

### 14.3 AI booster usage conditions

| Booster | AI condition |
|---|---|
| Extra Bottle | First 15s if empty-bottle count ≤ 1 |
| First Pour | Auto at match start |
| Spawn+3 | Auto at match start |
| Color Splash | Top-segment recolor creates near-pure customer match |
| Swap | Board blocked, swap creates visible serve route |
| Customer Lock | Apply to customer player is 1 pour from serving |
| Clear Bottle | 0 empty bottles AND no 4-move clean route |
| Auto Serve | Expects ≥ 2 serves in next 20s |
| Double Serve | Holds serveable glass matching ≥50% patience customer |

AI does not use Perks in MVP.

---

## 15. Home layout + navigation

### 15.1 Home (top → bottom)

1. Profile Card strip (avatar + frame + title + trophies)
2. Currency row (Coins / Stars / Gold)
3. Star Meter + Lucky Box countdown button
4. Daily Missions (3 rows, compact)
5. Trophy Road horizontal strip
6. Arena Selector chips
7. Venue preview (current venue interior, small)
8. Sticker Album progress card ("Bar Classics 7/20 — next pack hint")
9. PLAY button ("Wager 25 Gold") + Practice (only when broke)
10. Flash Offer banner (only when active)
11. Bar Pass banner (current tier + progress bar)

### 15.2 Bottom nav

Five tabs, fixed order left → right:

| Position | Tab | Contents |
|---:|---|---|
| 1 | Shop | Sections A / B / C / D / F |
| 2 | Trophy Road | Full-screen Trophy Road view (§9) — all 20 milestones, claim UI, progress bar, upcoming-reward preview |
| 3 | **Home** | Centered, primary tab (§15.1) — default landing |
| 4 | Venue | Full-screen Venue hub — bar-per-arena switcher, building upgrades |
| 5 | Albums | 3 Regular + 1 Seasonal album, Sticker Tokens, pack entry |

Design rule: Home sits in the center as the anchor. The two tabs left of Home (Shop, Trophy Road) are the **inbound** tabs — where the player collects rewards and spends for the next match. The two tabs right of Home (Venue, Albums) are the **outbound** tabs — where earned currencies and progress flow out into flex/collection.

(The Venue tab returns from v6.5, but with the TH-style Venue-Token upgrade mechanic instead of gold-priced building levels. Trophy Road becomes a full tab of its own — still retains a compact horizontal strip on Home for at-a-glance progress.)

### 15.3 Profile Card

Shown on matchmaking, result, Venue header:

```
[Avatar]  [Frame]
[Title]
Trophies: 1240
Best Sticker: ✨ Golden Skull Glass (Diamond)
```

No level, no XP. Cosmetics via Trophy Road (free) + Bar Pass Premium + $ exclusives. Defaults: Avatar 1, Default Frame, "Newcomer".

Tap own card → cosmetic picker.

---

## 16. Save schema

```js
save = {
  // core (preserved)
  trophies, arena,
  currentPlayingArena, maxUnlockedArena,

  // currencies
  gold, coins, stars, starsMeter,     // starsMeter = 0..25 accumulator

  // boosters (tiered identity)
  boosters: {
    bronze: { extraBottle, firstPour, spawnPlus3 },
    silver: { colorSplash, swap, customerLock },
    gold:   { clearBottle, autoServe, doubleServe }
  },

  // perks
  perks: { secondLook, steadyHand, pourRead },

  // loadout state
  loadout: { betId, betTier, perk1Id, perk2Id },

  // streak
  onFireStreak: number,  // count of consecutive wins
  onFireActive: boolean,

  // chests + faucets
  luckyBox: { nextAvailableAt },
  starChestPending: boolean,

  // trophy road
  trophyRoad: { highestTrophiesReached, claimedMilestones: number[] },

  // daily missions
  dailyMissions: {
    dateIso,
    missions: [ { id, progress, target, claimed, reward }, ... ],
    dailyChestClaimed
  },

  // collection
  stickers: { [stickerId]: number },
  stickerTokens: number,
  claimedPageRewards: string[],       // "albumId:pageIndex"
  claimedAlbumRewards: string[],      // albumId
  unlockedAlbums: string[],

  // venue (TH-style base hub)
  venue: {
    venueBuildingTokens: number,
    buildings: {
      [buildingId]: { level: 0 | 1 | 2 | 3 }   // 0 = locked, 1/2/3 = unlocked/developed/legendary
    },
    venuesUnlocked: string[]   // arena ids
  },

  // profile
  profile: {
    unlockedAvatars, unlockedFrames, unlockedTitles,
    activeAvatar, activeFrame, activeTitle
  },

  // bar pass
  barPass: {
    seasonStartAt, seasonEndAt,
    bpp, currentTier, premiumUnlocked,
    claimedFreeTiers: number[], claimedPremiumTiers: number[]
  },

  // monetization shells
  starterPack: { shownAt, purchased, dismissedAt },
  activeFlashOffer: { id, expiresAt } | null,
  lossStreak: number,

  // achievements (feed sticker-grant triggers)
  achievements: { /* counters */ },

  // REMOVED on migration:
  // venueBuildings, venueProgress, venueUpgrades, utilityCart, memorabilia,
  // stats.xp, stats.playerLevel, stats.claimedLevelRewards
}
```

### 16.1 Migration

On load:
- Strip `venueBuildings`, `memorabilia`, `stats.xp`, `stats.playerLevel`
- If `gold` unset: apply Starter inventory (§16.2), `currentPlayingArena = maxUnlockedArena || 'juice'`
- Initialize empty `stickers`, `venue`, `trophyRoad` defaulting to current trophies
- `luckyBox.nextAvailableAt = now()`
- Generate fresh dailies for today
- Initialize `barPass` with 30-day window from now
- Unlock "Opening Night" album, seed 3 Common stickers + 1 Sticker Token
- Profile defaults (Avatar 1, Default Frame, Newcomer)
- Show Starter Pack overlay (48h)

### 16.2 Starter inventory

| Item | Qty |
|---|---:|
| Extra Bottle (Bronze) | 3 |
| First Pour (Bronze) | 2 |
| Color Splash (Silver) | 1 |
| Swap (Silver) | 1 |
| Perks (all 3) | unlocked |
| Coins | 100 |
| Gold | 50 |
| Stars | 0 |
| Venue Tokens | 0 |
| Opening Night album | unlocked, 3 Common stickers seeded |
| Sticker Token | 1 |

---

## 17. Prototype scope

### 17.1 Required

**Match economy**
- [ ] Gold + Coins + Stars in save + HUD
- [ ] 9-booster tiered roster; tier tags in data
- [ ] Bet slot + 2 Perk slots loadout
- [ ] Bet stake-and-return logic (survive on win, consume on loss)
- [ ] Coin payout table by bet tier
- [ ] On Fire streak flag + doubler
- [ ] Visible opponent bet + persona on matchmaking
- [ ] Gold ante deduction on PLAY, pot settle on result

**Matchmaking + arena**
- [ ] Arena Selector chip row + trophy scaling
- [ ] Named AI personas per arena + Rematch button
- [ ] Practice button (broke-gated only)

**Retention**
- [ ] Trophy Road: strip UI, 20 milestones, claim, arena unlock on hit
- [ ] Daily Missions: 3/day from pool, midnight refresh, Daily Chest
- [ ] Lucky Box 4h timer + claim reward
- [ ] Star Meter accumulator + Star Chest queue + roll+reveal

**Collection**
- [ ] 4 Sticker Albums × 20 slots × rarity-typed data
- [ ] Sticker Pack purchase (Cheap / Standard / Big) gold-priced
- [ ] Pack-opening reveal animation
- [ ] Duplicate → Coins auto-convert (Diamond → Token)
- [ ] Sticker Token UI (use on any missing sticker)
- [ ] Page / album completion rewards
- [ ] Title unlocks on album completion

**Venue (TH-style hub)**
- [ ] Venue full-screen tab with bar-per-arena sections
- [ ] Decor drops in chests + flagship decor from Trophy Road
- [ ] Venue Token earning (1/win, 3/promo)
- [ ] Building L1/L2/L3 upgrade UI (Venue Token spend)
- [ ] Home Venue preview

**Monetization shells**
- [ ] Shop: Sections A / B / C / D / F
- [ ] Starter Pack (48h) overlay
- [ ] Flash Offer triggers (3-loss, arena promo, low-gold, sticker splurge)
- [ ] 30-day Bar Pass: BPP from match only, Free claimable, Premium grayed

**Infra**
- [ ] Result screen reward sequence (§14.1 steps 1–8)
- [ ] Save migration (strip venue / memorabilia / XP)
- [ ] Home layout per §15

### 17.2 Not required (MVP cuts)
- Player Level / XP
- Always-on Training Mode
- 60-item collectible sets (superseded by 80-sticker albums)
- Memorabilia plaques
- Venue building upgrades
- Achievement → booster rewards (folded into sticker grants)
- Team / club / guild
- Sticker trades
- Star Race leaderboard
- Real $ purchases
- Diamond-tier booster identities
- Seasonal rotating albums
- Animated decor / manual decor placement
- Card-upgrade-powers-booster system (keep flat tier power per §3.3)

---

## 18. Acceptance spot-checks

- [ ] PLAY deducts ante; win adds pot; loss no refund; draw refund
- [ ] Opponent Bet tier + persona tagline visible pre-match
- [ ] Bet booster returns on win, consumed on loss, regardless of activation
- [ ] On Fire triggers after 2 wins in a row; next match 2× coins + 2× trophies
- [ ] Trophy Road: milestone 2 at 100 trophies grants Bronze Frame + 3 stickers + 2 Bronze boosters
- [ ] Milestone 4 (Beach Bar) unlocks arena + Venue landmark unlock + Boardwalk album
- [ ] 25 stars queues Star Chest; reset to 0; excess caps at 25
- [ ] Lucky Box disabled while timer runs; timer persists across reload
- [ ] Daily Missions refresh at local midnight; Practice doesn't progress them
- [ ] Completing 3 missions auto-grants Daily Chest (incl. 2 stickers + 15% Token)
- [ ] Practice button hidden when gold ≥ ante
- [ ] Rematch preserves persona + ante + bet selection
- [ ] Profile Card never shows Level or XP
- [ ] Pack of 5 stickers plays reveal; dupes auto-convert to coins; Diamond dupe → Token
- [ ] Sticker Token UI: pick missing Diamond → confirm → token consumed
- [ ] Page completion (5/5): 100g + 100c + 1 booster
- [ ] Album completion (20/20): 1000g + 1000c + 3 Gold boosters + Token + title + showcase
- [ ] Star Chest shortcut in Shop B deducts Gold (not coins)
- [ ] Shop Section C bundle click → "Coming soon" toast
- [ ] Bar Pass BPP moves only on match played/won (not on chest / mission claim)
- [ ] Venue bar section shows base art + building slots; a building unlocks (L1) after 2 Venue Tokens spent
- [ ] Save with `venueBuildings` or `memorabilia` loads clean; fields stripped
- [ ] Bottom nav: Shop / Trophy Road / Home / Venue / Albums (Home centered as default)
- [ ] Trophy Road tab shows the full 20-milestone track; Home keeps the compact horizontal strip preview

---

## 19. What this patch explicitly removes

Search & delete from `index-v6.html`:

- Venue building upgrade UI, cost tables, upgrade handlers
- Venue completion milestone triggers + bundles
- Utility Cart (if still present)
- Flash Pour / Swap legacy references from pre-v6.6.1
- Booster tier labels shown as Bronze / Silver / Gold / Diamond / Legend if implemented from prior patch drafts in a way that sells or displays them as separate 5-tier UI (this patch uses 3 tiers + future Diamond)
- Player Level / XP fields + UI (if built from 6.7 drafts)
- Memorabilia / plaque unlock triggers
- Always-on Training Mode button
- Standalone "Arena Promotion Reward" screen (consolidated into Trophy Road)
- Any UI element that debits **gold** for a booster (boosters are coin-only)

---

## 20. Final intended player feeling

- **Every bet is a gamble, every match is a stake.** Ante + booster = two honest risks.
- **My currencies have clear jobs.** Coins feed boosters, gold feeds collection, stars fill the meter.
- **I always walk away with something.** 1 star on loss, ante treadmill is fair, Lucky Box is free.
- **Collection is the long game.** 60 Regular + 20 Seasonal stickers, 29 Venue buildings across 6 themed bars, 3 album titles + 1 seasonal title — months of pulls and flex.
- **My Venue grows because I win.** Not one gold paid for a building.
- **The Pass gives me a 30-day spine.** Match-only BPP keeps the bar legible.
- **Boosters are simple tools, not a treadmill.** 9 identities, 3 tiers, flat power.

---

## 21. One-line meta loop

**Open app → Lucky Box + yesterday's dailies → pick arena → wager gold ante + stake a bet booster → fight named opponent → win pot + coins + stars + sticker drop → chest pops at 25 stars → sticker pack from gold → page fills → album completes → Venue Tokens earned → Venue building upgrades → Trophy Road ticks → Bar Pass climbs → tomorrow a new box, new missions, same climb.**

Four braided loops on one spine:
- **Tactical** — bet booster, perks, board routing
- **Economic (combat)** — coins ↔ boosters
- **Economic (collection)** — gold ↔ sticker packs + chest shortcuts
- **Long-form** — trophies → Road, climb → arena + album unlocks, monthly pass, Venue buildings
