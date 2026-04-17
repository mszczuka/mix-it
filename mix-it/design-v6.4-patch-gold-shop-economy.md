# PATCH: Gold Economy + Booster Shop Refactor

**Applies to:** `design-v6.md` and replaces the result-economy direction from `design-v6.1-patch-loadout.md`  
**Date:** 2026-04-16  
**Purpose:** Refactor BAR CLASH boosters to feel closer to Match Masters: fixed 2-slot pre-match loadout, boosters as consumable tactical tools, and **gold** as the primary soft currency used to restock boosters through a simple shop.

---

## Design intent

This patch answers two questions:

1. **Why do I keep winning?**  
   To climb arenas **and** earn gold.

2. **What is gold for?**  
   To keep my PvP loadout stocked by buying boosters I have unlocked.

This keeps BAR CLASH aligned with the current core:
- shared-customer PvP race
- pre-match booster loadout
- trophy ladder
- arena unlocks

But it removes the extra progression clutter:
- **remove stars**
- **remove booster mastery**
- **remove direct random booster drops from normal match results**

The target structure is:

**Play match -> earn trophies + gold -> buy / restock boosters -> choose 2-slot loadout -> play again**

---

## Summary of changes

1. Add **Gold** as the primary soft currency
2. Remove **Stars** entirely
3. Remove **Booster Mastery** entirely
4. Refactor boosters into a **stock + spend** economy
5. Keep **2 fixed booster loadout slots**
6. Replace normal result rewards from direct booster drops to **gold rewards**
7. Add a simple **Booster Shop** where unlocked boosters can be purchased for gold
8. Keep arena progression meaningful through:
   - new booster unlocks
   - promotion rewards
   - higher gold rewards in later arenas
9. Keep direct booster grants only for:
   - first launch starter inventory
   - arena promotions
   - optional future events / limited rewards

---

## Product stance

Use this as the explicit meta stance:

> BAR CLASH progression is built on trophies for climb and gold for tactical readiness.

And:

> Boosters are not a collectible layer. They are consumable tools that the player unlocks, stocks, and spends deliberately.

---

## Section changes

### § 4 — What changes from v6

Replace the existing added lines about match-result booster rewards with:

```md
- Power-ups are now refactored into **Boosters**
- Boosters are selected before the match from a persistent inventory
- Each selected booster has 1 use per match and is consumed only if activated
- Gold added as the primary soft currency
- Match results now grant gold instead of direct random booster drops
- New Booster Shop added for buying unlocked boosters with gold
- Stars removed
- Booster Mastery removed
```

---

## Section terminology update

Use the term **Booster** consistently instead of mixing:
- power-up
- power up
- power-ups

For this version:
- **Booster** = consumable tactical tool chosen before the match
- **Gold** = soft currency used to purchase boosters
- **Trophies** = ranked ladder progression
- **Arenas** = unlock structure for board scale and booster roster

---

## § 5 — Match Layout

Update the top-level economy UI references to include gold.

### Header addition

Add gold to the home / meta UI header:

```md
HOME TOP BAR:
[Trophies]   [Gold]   [Arena]
```

### In-match layout
No gold is shown in the active match HUD.  
Gold is part of the meta economy, not in-match decision-making.

---

## § 8 — Boosters (Refactor)

Replace the whole power-up economy framing with:

### 8.0 Booster philosophy

Boosters are:
- tactical
- consumable
- pre-selected
- limited-use
- purchased with gold after being unlocked

They should help the player convert skill into tempo, rescue, or workspace.

They should **not**:
- become permanent stat upgrades
- create power creep
- replace the core puzzle

---

### 8.1 Loadout

Keep the pre-match system, but update the rules:

```md
- Before each match, the player selects up to **2 boosters** from inventory
- The player always has exactly **2 loadout slots**
- A selected booster has **1 use** during the match
- A booster is consumed only if the player activates it
- If a selected booster is not used, it returns to inventory after the match
- If the player owns fewer than 2 boosters, empty slots are allowed
```

#### Design note
This preserves the Match Masters-like pre-match decision layer while keeping the match itself readable.

---

### 8.1.1 Starter inventory (UPDATED)

Replace the previous starter inventory with:

| Booster | Starting quantity |
|---|---:|
| Extra Bottle | 3 |
| Flash Pour | 3 |
| Swap | 0 |
| Clear Bottle | 0 |

Additional first-launch grant:
- **75 Gold**

#### Why
The player should be able to:
- play several matches immediately
- understand that boosters are consumable
- interact with the shop early
- not begin with such a huge stock that gold feels irrelevant

**Total starter value:**
- 3 Extra Bottle x 20 = 60 gold value
- 3 Flash Pour x 25 = 75 gold value
- 75 direct gold
- **Total = 210 gold equivalent**

That is enough to support the tutorial / first session without making the store irrelevant.

---

### 8.2 Booster roster

Keep the same four booster effects, but define them as purchasable inventory items.

#### Extra Bottle
- Adds one empty bottle permanently for the rest of the match
- 1 use
- Consumed only if activated
- Role: workspace / setup

#### Flash Pour
- Your next **3 pours** are instant
- 1 use
- Consumed only if activated
- Role: tempo spike / serve conversion

#### Swap
- Select any 2 bottles; their full contents swap
- 1 use
- Consumed only if activated
- Role: tactical rescue / route conversion

#### Clear Bottle
- Select 1 bottle; discard all contents and make it empty
- 1 use
- Consumed only if activated
- Role: emergency anti-deadlock

#### Design note
Flash Pour is changed from an 8-second timer to **next 3 pours are instant** because that is clearer in a puzzle-routing game and easier to value economically.

---

### 8.3 Booster unlocks by arena

Replace the previous availability section with:

| Arena | Booster unlock state |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Flash Pour unlocked |
| Beach Bar (200-499) | Swap unlocked |
| Cocktail Lounge (500-999) | Clear Bottle unlocked |
| Speakeasy+ | No new booster unlocks; economy and board depth scale instead |

#### Rule
Once unlocked, a booster stays permanently purchasable in the Booster Shop.

---

### 8.4 Booster purchase prices (NEW)

Add a new subsection:

| Booster | Gold price | Design role |
|---|---:|---|
| Extra Bottle | 20 | cheapest setup tool |
| Flash Pour | 25 | efficient tempo tool |
| Swap | 35 | stronger tactical conversion |
| Clear Bottle | 45 | strongest rescue tool |

#### Price logic
- Basic early-game tools are cheap enough to use regularly
- Advanced tools are more expensive, so they feel stronger and are used more deliberately
- Clear Bottle is the premium emergency option and should not be spammed every match

---

### 8.5 Booster Shop (NEW)

Add a new subsection:

#### 8.5 Booster Shop

The shop is a simple utility store, not a monetization-heavy system.

It exists to let the player convert gold into tactical readiness.

#### Shop tabs
1. **Daily Free Claim**
2. **Single Booster Purchase**
3. **Bundle Offers**

#### 8.5.1 Daily Free Claim
Once per calendar day, the player can claim:
- **15 Gold**

#### 8.5.2 Single Booster Purchase
The player may buy any **unlocked** booster directly for gold at its standard price.

#### 8.5.3 Bundle Offers
The shop offers a small set of permanent bundles:

| Bundle | Contents | Price | Raw value | Discount |
|---|---|---:|---:|---:|
| Basics Pack | 3 Extra Bottle + 3 Flash Pour | 125 | 135 | 7% |
| Tactical Pack | 2 Swap + 1 Flash Pour | 90 | 95 | 5% |
| Rescue Pack | 2 Clear Bottle + 1 Extra Bottle | 105 | 110 | 5% |

#### 8.5.4 Daily Rotating Deal
One unlocked booster is discounted each day:

- Discount range: **10-20%**
- Example:
  - Flash Pour: 25 -> 20
  - Swap: 35 -> 30

#### Shop design rules
- No chest timers
- No crafting
- No duplicate upgrade system
- No rarity stars on boosters
- No extra booster slots sold
- Shop exists to support the loadout economy, not overshadow it

---

## § 9 — AI Opponent

No economy changes required in-match.

Keep AI using 2 pre-selected boosters from the unlocked arena roster.

AI does not buy boosters in a visible way.  
AI inventory is simulated and not part of the player's economy model.

---

## § 11 — Arenas

Update the arena purpose with explicit economic meaning.

### 11.0 Arena progression purpose

Arenas should now provide three things:
1. Harder / richer boards
2. New booster unlocks
3. Better gold income and promotion rewards

The player should feel that climbing arenas gives:
- broader tactics
- more valuable matches
- stronger future purchasing power

---

### 11.2 Prototype arenas (UPDATED)

Replace the old table with:

| Arena | Trophies | Colors | Bottles | Booster unlock | Win Gold | Lose Gold | Draw Gold | Promotion reward |
|---|---:|---:|---|---|---:|---:|---:|---|
| Juice Stand | 0-199 | 3 | 3 full + 2 empty (5) | Extra Bottle, Flash Pour | 35 | 20 | 25 | starter inventory only |
| Beach Bar | 200-499 | 5 | 4 full + 3 empty (7) | + Swap | 40 | 22 | 30 | Swap x2 + 40 Gold |
| Cocktail Lounge | 500-999 | 7 | 5 full + 3 empty (8) | + Clear Bottle | 50 | 25 | 35 | Clear Bottle x2 + 60 Gold |
| Speakeasy | 1000-1499 | 7 | 6 full + 4 empty (10) | no new booster | 60 | 30 | 40 | 100 Gold |
| Rooftop Terrace | 1500-2499 | 7 | 7 full + 5 empty (12) | no new booster | 70 | 35 | 45 | 125 Gold |
| Grand Hotel | 2500+ | 7 | 8 full + 5 empty (13) | no new booster | 80 | 40 | 50 | 150 Gold |

#### Design note
Early arenas unlock the full tactical roster.  
Later arenas stop adding more buttons and instead increase:
- board depth
- match value
- purchasing power
- status

---

## § 12 — Match Flow

Replace the previous economy part of the flow with:

```md
HOME -> MATCHMAKING -> PRE-MATCH LOADOUT -> COUNTDOWN -> MATCH -> RESULT -> REWARD CLAIM -> HOME / SHOP
```

### 12.5 Reward Claim (NEW)

After the result screen, the player sees:

- result (win / lose / draw)
- score comparison
- trophy change
- gold earned
- arena promotion reward (if promoted)

Example:

```md
REWARDS
+35 Trophies
+50 Gold
PROMOTION BONUS
Clear Bottle x2
+60 Gold
```

### 12.6 Post-match shop nudge (NEW)

After reward claim, the player may:
- tap **Play Again**
- tap **Go to Shop**
- tap **Home**

The shop button should be subtle but visible when the player has enough gold to buy at least one unlocked booster.

---

## § 13 — Home / Result

### Home additions

Add a small economy panel:

```md
Gold: 185
Boosters:
Extra Bottle x2
Flash Pour x1
Swap x0
Clear Bottle x0
```

Add a **Shop** button on Home.

Add a next arena teaser:

```md
NEXT ARENA: Beach Bar
Unlocks: Swap
Promotion Reward: Swap x2 + 40 Gold
```

### Result screen additions

Replace stars / mastery / direct booster drop messaging with:

- trophy delta
- gold gained
- promotion reward (if any)

Do **not** show:
- stars
- mastery progress
- random booster drops from the result itself

---

## § 14 — Prototype Scope

Update **Required** list with:

```md
- Gold soft currency
- Booster Shop
- Booster prices
- Arena-based gold rewards
- Promotion rewards with gold and booster grants
- Reward claim step after match
- Home screen gold display
```

Update **Not required** with:

```md
- Stars
- Booster mastery
- Sticker album
- Battle pass
- Chest timers
- Collection layer
```

---

## Economy math

This section defines why the system is sustainable.

### 1. Match reward formula

The player always gets:
- **Trophies** for ladder progress
- **Gold** for economic progress

Gold rewards scale by arena because later arenas unlock stronger boosters and larger boards.

---

### 2. Spend model assumptions

Expected average booster consumption per match:

| Arena band | Typical boosters unlocked | Expected boosters actually consumed per match | Estimated average gold cost per consumed booster | Estimated spend per match |
|---|---|---:|---:|---:|
| Juice | Extra Bottle, Flash Pour | 1.0 | 22.5 | 22.5 |
| Beach | + Swap | 1.1 | 27.0 | 29.7 |
| Cocktail | + Clear Bottle | 1.2 | 31.0 | 37.2 |
| Speakeasy+ | all 4 | 1.3 | 33.0 | 42.9 |

#### Why actual consumption is below 2
The player can equip 2 boosters but:
- may use only 1
- may use 0 in a dominant match
- unused boosters return to inventory

This is important: **the economy is based on use, not equip.**

---

### 3. Average income by arena

Assume a normal player over time:
- 50% win rate
- 10% draw rate
- 40% loss rate

Expected gold per match:

| Arena | Expected gold / match |
|---|---:|
| Juice Stand | 29.5 |
| Beach Bar | 31.8 |
| Cocktail Lounge | 38.5 |
| Speakeasy | 45.0 |
| Rooftop Terrace | 52.0 |
| Grand Hotel | 59.0 |

Formula example for Cocktail Lounge:

```md
0.5 * 50 + 0.1 * 35 + 0.4 * 25
= 25 + 3.5 + 10
= 38.5 expected gold per match
```

---

### 4. Sustainability check

Compare expected income to expected spend:

| Arena band | Expected gold / match | Expected spend / match | Net |
|---|---:|---:|---:|
| Juice | 29.5 | 22.5 | +7.0 |
| Beach | 31.8 | 29.7 | +2.1 |
| Cocktail | 38.5 | 37.2 | +1.3 |
| Speakeasy+ | 45.0+ | 42.9 | +2.1+ |

#### Interpretation
- The economy is **slightly positive** for a stable player
- Players can sustain regular use without running dry
- Stronger players accumulate gold faster
- Weaker players still gain enough to keep playing because losses also pay gold

This is the key balancing target:
**Gold should feel valuable, but normal players should not feel punished for using boosters.**

---

### 5. Daily session example

Example: Cocktail Lounge player, 10-match day

Assume:
- 5 wins
- 1 draw
- 4 losses

Gold from matches:
- 5 x 50 = 250
- 1 x 35 = 35
- 4 x 25 = 100
- **Subtotal = 385**

Daily additions:
- first win bonus = **30 Gold**
- daily free claim = **15 Gold**

Total daily gold:
- **430 Gold**

Expected booster spend:
- 10 matches x 37.2 = **372 Gold**

Net daily balance:
- **+58 Gold**

This means:
- the player can maintain normal booster usage
- the player can slowly save for more expensive tools
- the player still values discounts and bundles

---

### 6. First win of day bonus (NEW)

To help smooth weaker sessions, add:

| Arena | First win bonus |
|---|---:|
| Juice Stand | 20 |
| Beach Bar | 25 |
| Cocktail Lounge | 30 |
| Speakeasy | 35 |
| Rooftop Terrace | 40 |
| Grand Hotel | 50 |

#### Why
This gives the player a strong reason to come back daily without needing stars or a weekly track.

---

### 7. Promotion reward value

Promotion rewards must be large enough to feel exciting but not so large that the shop becomes irrelevant.

Promotion value by tier:

| Arena reached | Value |
|---|---:|
| Beach Bar | 2 Swap + 40 Gold = 110 value |
| Cocktail Lounge | 2 Clear Bottle + 60 Gold = 150 value |
| Speakeasy | 100 Gold |
| Rooftop Terrace | 125 Gold |
| Grand Hotel | 150 Gold |

This makes promotions feel meaningful and helps players adopt newly unlocked boosters immediately.

---

## What this patch removes

Remove all references to:
- stars
- weekly star tracks
- booster mastery
- booster mastery bars on result screens
- direct random booster rewards from normal match results

---

## What stays unchanged

This patch does **not** change:
- board generation
- serving rules
- scoring
- combo logic
- Color Spawn as the board feed system
- AI puzzle logic
- trophy ladder structure
- 2-slot pre-match loadout structure

---

## Open questions for playtesting

Add:

```md
8. Do players understand gold immediately as the “restock my loadout” currency?
9. Does the shop feel useful without becoming mandatory after every match?
10. Are booster prices low enough to encourage use, but high enough to preserve choice?
11. Is loss gold generous enough to keep weaker players engaged?
12. Does replacing random booster drops with gold make the economy feel cleaner and more strategic?
13. Is Flash Pour clearer and more satisfying as “next 3 pours are instant” than as an 8-second timer?
```

---

## Final intended player loop

After this patch, the player should feel:

- **I win to gain trophies and gold**
- **I climb to unlock new boosters and richer matches**
- **I spend gold to prepare my next loadout**
- **I keep playing because my tactical options stay stocked**

---

## One-line economy loop

**Play match -> earn trophies + gold -> buy unlocked boosters in shop -> choose 2 boosters for next match -> compete again**
