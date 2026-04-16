# Clean Sweep Rush — Consolidated Design Patch
**Patch ID:** `design-patch-v2-water-boosters-upgrades-portrait-ui`  
**Applies to:** `clean_sweep_rush_design_doc_en.md`  
**Audience:** Product, Game Design, Economy, UI/UX, Level Design, Claude Code  
**Status:** Proposed working patch  

---

## 1. Patch Goal

This patch consolidates the decisions discussed after the base design doc:

- keep the **All in Hole-style shell**
- keep the game **level-based**, not roguelike
- keep **explicit targets**, **timer pressure**, **near-win monetization**, and **light meta**
- add a **finite renewable water tank**
- add a defined **booster set**
- add **permanent upgrades**
- adapt the product to a **portrait-first mobile UI**
- add a minimal bottom navigation with:
  - `Home`
  - `Upgrades`
- add a **soft currency** earned in levels and spent on upgrades
- add **upgrade pricing**
- add **campaign-level unlock gates**

---

## 2. Strategic Positioning After Patch

The product remains:

**readable cleaning fantasy**  
+ **goal-based timed level puzzle**  
+ **water refill route pressure**  
+ **boosters + revive + lives shell**  
+ **light permanent utility progression**

This is **not** a simulator.  
This is **not** a factory/meta-heavy product.  
This is **not** a roguelike-run game.

The product is best described as:

> A portrait-first casual F2P restoration game where the player clears dirt, manages time and refill pressure, upgrades a cleaning tool, and progresses through short, readable levels.

---

## 3. Screen / Device Target

## 3.1. Aspect Ratio Decision

Implementation target:

- **portrait-first mobile**
- **9:16 gameplay framing**
- safe-area aware for taller devices such as 19.5:9 and 20:9

Internal teams sometimes casually say “vertical 16:9,” but for implementation the correct baseline should be:

> **9:16 portrait**

## 3.2. Design Implications of Portrait

Portrait framing means:

- one-thumb control
- central play space
- strong top HUD readability
- bottom-safe CTA and navigation zones
- cleaner composition for ads and store captures
- easier reuse of gameplay footage in vertical marketing assets

## 3.3. Portrait Composition Rules

- center the cleaner avatar and nearest actionable dirt in the middle 60% of the screen
- keep top HUD lightweight and always readable
- keep bottom navigation outside active gameplay moments
- never place critical dirt feedback under the thumb zone
- maintain strong contrast between dirty / clean states for fast readability in vertical video

---

## 4. Bottom Navigation

## 4.1. Final Bottom Menu

Persistent bottom nav outside active levels:

- `Home`
- `Upgrades`

No third tab in MVP.

Reason:
- keeps the shell clean
- reduces UI noise
- supports the current depth of meta
- avoids overbuilding economy screens too early

## 4.2. Behavior

### Home
Primary progression hub.

### Upgrades
Permanent utility progression for the cleaning tool.

During gameplay:
- bottom nav is hidden
- only gameplay HUD is visible

---

## 5. Home Screen Design

## 5.1. Home Layout

Recommended vertical layout:

### Top Bar
- player level / campaign progress
- soft currency
- premium currency placeholder (optional in MVP)
- lives / heart count
- inbox / events icon

### Upper-Mid
- current world card
- current level CTA
- “Play” / “Continue” primary button
- small preview of target types or difficulty

### Mid
- restoration hub preview
- current chapter/world visual state
- next restoration milestone

### Lower-Mid
- streak chest / event progress
- daily reward / pass teaser
- optional limited-time event banner

### Bottom
- nav bar:
  - Home
  - Upgrades

## 5.2. Home Design Goals

Home must answer 4 questions instantly:
1. What do I do next?
2. What do I earn next?
3. What can I upgrade?
4. Why should I play one more level?

---

## 6. Upgrades Screen Design

## 6.1. Upgrades Screen Purpose

This screen is the permanent utility progression screen for the player’s cleaning tool.

It exists to create:
- readable long-term progress
- stronger session-to-session motivation
- spend sink for soft currency
- visible power fantasy without overcomplicated meta

## 6.2. Upgrades Screen Layout

### Top Area
- title: `Upgrades`
- soft currency balance
- player campaign level
- back button if needed

### Hero Panel
- large 3D preview or stylized render of the cleaning tool / sprayer
- current stat summary:
  - Spray Power
  - Tank Capacity
  - Refill Speed
  - Spray Width
  - Move Speed

### Upgrade Lane List
Scrollable card list or compact stack of 5 lanes:
1. Spray Power
2. Tank Capacity
3. Refill Speed
4. Spray Width
5. Move Speed

Each lane card should show:
- icon
- current rank
- next rank benefit
- upgrade cost
- unlock requirement
- lock state if gated
- “Upgrade” button when available

### Bottom Safe Zone
- no extra nav clutter beyond the 2-tab nav
- keep purchase decisions easy to thumb-tap

## 6.3. Visual Language

The sprayer should visibly improve at certain breakpoints:
- wider nozzle head
- bigger visible tank
- brighter pressure gauge
- cleaner body color accents
- stronger VFX in preview

This makes upgrade progression feel tangible, not purely numeric.

---

## 7. Core Water Tank System

## 7.1. Final Rule

The player has a **finite but renewable water tank** in every relevant level.

Rules:
- water drains only while actively spraying
- drain is constant
- distance does not affect drain
- vacuum / suction action does not consume water in MVP
- water refills at refill points placed in the level

## 7.2. Water Role in Product

Water is a **secondary pressure system**.

Main pressure source remains:
- explicit targets
- timer
- routing
- endgame tension

Water adds:
- route planning
- refill timing
- more meaningful map flow
- better near-win conversion hooks

## 7.3. Refill Point Rules

Refill points:
- are readable from a distance
- are placed off the perfect route in mid/late levels
- auto-refill the tank while the player stands in the zone
- should refill quickly enough to preserve flow

Recommended refill animation length:
- 1.0s–1.8s baseline
- can be shortened by upgrade or booster

---

## 8. Difficulty Scaling with Water

## 8.1. Difficulty Levers

As levels progress, increase pressure through:
- more targets
- more dirt volume
- more area spread
- more restore dependencies
- more hazard routing
- slightly more important refill choices

Do not mainly scale by:
- making the tank tiny too early
- making refill stations too rare
- hiding refill logic
- turning water into a hard punishment system

## 8.2. Onboarding Water

### Levels 1–10
- water pressure is minimal
- player learns clean fantasy first

### Levels 11–25
- refill becomes noticeable
- player starts making simple route decisions

### Levels 26–50
- refill becomes a real optimization layer
- target count and dirt density create pressure

### Levels 51+
- refill timing becomes part of difficulty identity
- wide maps and denser endgames justify booster usage

---

## 9. Booster System

## 9.1. Booster Philosophy

Boosters stay in the design because they are part of the shell, not optional extras.

They exist to:
- reduce frustration
- support near-win moments
- help weaker players
- create spend moments
- allow tighter level tuning

## 9.2. Pre-Level Boosters

### 1. `+10 Seconds`
Adds time before level start.

**Price:** 80 Wash Coins

### 2. `Bigger Tank`
Increases starting water capacity for one run.

**Price:** 70 Wash Coins

### 3. `Fast Refill`
Refill points restore water faster during this level.

**Price:** 70 Wash Coins

### 4. `Wide Nozzle`
Increases spray width for the level.

**Price:** 90 Wash Coins

### 5. `Pressure Boost`
Improves spray efficiency, especially against heavier dirt.

**Price:** 90 Wash Coins

### 6. `Target Scanner`
Highlights critical targets or route-priority objects.

**Price:** 60 Wash Coins

## 9.3. In-Level / Continue Boosters

These should appear from:
- fail screen offers
- rewarded ad offers
- event rewards
- premium value packs

### 1. `Freeze Time`
Stops the timer briefly.

### 2. `Instant Refill`
Fully restores water tank.

### 3. `Power Burst`
Temporary boost to cleaning speed and width.

### 4. `Foam Bomb`
Weakens or instantly clears a dirt cluster.

### 5. `Hazard Shield`
Temporary immunity to certain hazards.

### 6. `Auto-Vac`
Auto-cleans sludge/debris in radius for a short time.

### 7. `Instant Restore`
Immediately completes one valid restore interaction.

## 9.4. Booster Unlock Cadence

Not all boosters should appear immediately.

### Suggested rollout
- Levels 1–10: `+10 Seconds`, `Bigger Tank`
- Levels 11–20: add `Wide Nozzle`, `Target Scanner`
- Levels 21–35: add `Fast Refill`, `Pressure Boost`
- Levels 36+: unlock contextual fail/continue boosters

This keeps onboarding cleaner and matches the rule of introducing complications one at a time.

---

## 10. Permanent Upgrade Meta

## 10.1. Final Recommendation

Permanent upgrades are **in scope**.

This is not too much meta if:
- the number of lanes stays small
- one soft currency pays for everything
- costs are linear/escalating but readable
- upgrades improve the level loop directly
- there is no branching tree

## 10.2. Safe Upgrade Lanes

Keep exactly these 5 permanent lanes:

1. `Spray Power`
2. `Tank Capacity`
3. `Refill Speed`
4. `Spray Width`
5. `Move Speed`

No detergent tree.  
No rarity.  
No deep equipment system.  
No secondary crafting layer in MVP.

---

## 11. Soft Currency

## 11.1. Currency Name

Recommended soft currency:
**Wash Coins**

Simple, readable, on-theme, and clear in UI.

## 11.2. How It Is Earned

Wash Coins are earned from:
- level completion
- no-continue bonus
- time-left bonus
- bonus levels
- streak chest
- events
- daily rewards

## 11.3. Level Reward Structure

Recommended baseline progression:

| Level Range | Base Win Reward |
|---|---:|
| 1–10 | 60 Wash Coins |
| 11–25 | 85 Wash Coins |
| 26–50 | 110 Wash Coins |
| 51–80 | 140 Wash Coins |
| 81+ | 175 Wash Coins |

### Bonus Rewards
- `No Continue Bonus`: +15
- `20s+ Left Bonus`: +10
- `Perfect Clean / optional star`: +10
- `Bonus Level`: ~2x base win reward

## 11.4. Economy Goal

A normal player should feel:
- they can afford early upgrades regularly
- they need to choose priorities later
- boosters are spendable but not infinitely free
- upgrades are meaningful but not painfully slow

---

## 12. Upgrade Unlock Gates

## 12.1. Gate Philosophy

Upgrade lanes should unlock by campaign level completion, not by account XP complexity.

This keeps progression clear and directly tied to play.

## 12.2. Lane Unlock Table

| Upgrade Lane | Unlock Requirement |
|---|---|
| Spray Power | available from start |
| Tank Capacity | complete Level 4 |
| Spray Width | complete Level 8 |
| Refill Speed | complete Level 15 |
| Move Speed | complete Level 25 |

This creates a natural order:
- first improve cleaning feel
- then improve water control
- then improve comfort and mastery

---

## 13. Upgrade Costs and Effects

## 13.1. Rank Structure

Each lane has **8 permanent ranks** in MVP.

Costs escalate cleanly.  
Effects are modest but noticeable.

## 13.2. Spray Power

**Effect:** cleans heavier dirt faster  
**Per Rank Effect:** +5% Spray Power

| Rank | Cost | Unlock |
|---|---:|---|
| 1 | 100 | start |
| 2 | 160 | start |
| 3 | 240 | Level 6 |
| 4 | 340 | Level 12 |
| 5 | 470 | Level 20 |
| 6 | 630 | Level 30 |
| 7 | 820 | Level 42 |
| 8 | 1050 | Level 58 |

## 13.3. Tank Capacity

**Effect:** more water before refill  
**Per Rank Effect:** +7% Tank Capacity

| Rank | Cost | Unlock |
|---|---:|---|
| 1 | 120 | Level 4 |
| 2 | 180 | Level 6 |
| 3 | 260 | Level 10 |
| 4 | 360 | Level 16 |
| 5 | 490 | Level 24 |
| 6 | 650 | Level 34 |
| 7 | 840 | Level 46 |
| 8 | 1080 | Level 62 |

## 13.4. Refill Speed

**Effect:** refill stations refill faster  
**Per Rank Effect:** +6% Refill Speed

| Rank | Cost | Unlock |
|---|---:|---|
| 1 | 160 | Level 15 |
| 2 | 240 | Level 18 |
| 3 | 340 | Level 22 |
| 4 | 470 | Level 28 |
| 5 | 630 | Level 36 |
| 6 | 820 | Level 48 |
| 7 | 1040 | Level 60 |
| 8 | 1300 | Level 76 |

## 13.5. Spray Width

**Effect:** wider effective cleaning cone/radius  
**Per Rank Effect:** +4% Spray Width

| Rank | Cost | Unlock |
|---|---:|---|
| 1 | 140 | Level 8 |
| 2 | 210 | Level 11 |
| 3 | 300 | Level 16 |
| 4 | 420 | Level 22 |
| 5 | 570 | Level 30 |
| 6 | 750 | Level 40 |
| 7 | 960 | Level 54 |
| 8 | 1200 | Level 70 |

## 13.6. Move Speed

**Effect:** faster route execution and refill access  
**Per Rank Effect:** +3% Move Speed

| Rank | Cost | Unlock |
|---|---:|---|
| 1 | 180 | Level 25 |
| 2 | 260 | Level 28 |
| 3 | 360 | Level 34 |
| 4 | 500 | Level 42 |
| 5 | 670 | Level 52 |
| 6 | 870 | Level 64 |
| 7 | 1100 | Level 78 |
| 8 | 1380 | Level 92 |

---

## 14. Upgrade Priority Recommendation

For player guidance, the game should softly suggest this order:

### Early Game
1. Spray Power
2. Tank Capacity
3. Spray Width

### Mid Game
1. Tank Capacity
2. Refill Speed
3. Spray Width

### Late Game
1. Refill Speed
2. Move Speed
3. Spray Power

This helps players avoid bad early spending and makes the system feel curated.

---

## 15. UI Behavior for Locked Upgrades

Locked lane card should show:
- greyed icon
- “Unlock at Level X”
- preview of the future benefit
- no purchase CTA

Locked rank inside an unlocked lane should show:
- current next required campaign level
- faint price preview
- progress hint: `Complete 3 more levels to unlock`

This keeps future progression visible and motivating.

---

## 16. Upgrade Screen Example Card

```text
Spray Power
Rank 3 -> 4
Current: +15%
Next: +20%
Cost: 340 Wash Coins
Unlock: Available
[Upgrade]
```

Locked example:

```text
Move Speed
Unlocks at Level 25
Effect: Reach targets and refill stations faster
[Locked]
```

---

## 17. Economy Balance Notes

## 17.1. Why this amount of meta is safe

This setup is still “light meta” because:
- only 5 lanes exist
- every lane directly improves core loop readability
- one currency pays for upgrades
- no branching build complexity exists
- power growth supports the level game instead of replacing it

## 17.2. When it becomes too much meta

Do **not** add all of these in MVP:
- detergent crafting
- secondary tool rarity
- multiple gear slots
- passive production economy
- upgrade trees with branches
- separate water chemistry system
- hub buildings that also boost stats
- additional equipment currencies

That would push the product away from a casual level game.

---

## 18. Gameplay HUD in Portrait

## 18.1. Top HUD
- timer centered or slightly top-left
- target cards below timer
- water tank bar near top-right
- optional booster indicator top-right or right rail
- pause top-left

## 18.2. Bottom Gameplay Space
- thumb movement zone
- no persistent bottom nav during gameplay
- boosters appear as temporary contextual action buttons when relevant

## 18.3. Water Visibility Rule
Water tank must always be readable in one glance:
- visible fill bar
- numeric optional
- strong low-water warning state
- refill point highlighting when critically low

---

## 19. Continue / Fail Screen Adjustments

## 19.1. Fail States to Support
- time ran out
- water route failed into time loss
- hazard collision

## 19.2. Contextual Continue Offers
- low time -> `+15 sec`
- low water -> `Instant Refill`
- dense last target -> `Power Burst`
- hazard issue -> `Hazard Shield`

## 19.3. Continue Offer Price Direction
Recommended initial soft/hard logic:
- first soft continue in session: soft currency or ad
- later continues: premium or ad-limited
- keep emotional price lower than restart friction

---

## 20. Claude Code Implementation Notes

## 20.1. New Systems to Add

- `PortraitUIScreenConfig`
- `BottomNavController`
- `HomeScreenController`
- `UpgradesScreenController`
- `PlayerProgressionState`
- `SoftCurrencyWallet`
- `PermanentUpgradeSystem`
- `WaterTankSystem`
- `RefillPointSystem`

## 20.2. Suggested Data Structures

```ts
type PlayerProgressionState = {
  campaignLevel: number;
  washCoins: number;
  lives: number;
  upgradeRanks: Record<UpgradeLane, number>;
};

type UpgradeLane =
  | "spray_power"
  | "tank_capacity"
  | "refill_speed"
  | "spray_width"
  | "move_speed";

type UpgradeDefinition = {
  lane: UpgradeLane;
  rank: number;
  unlockLevel: number;
  costWashCoins: number;
  effectValue: number;
};

type WaterTankState = {
  capacity: number;
  current: number;
  drainPerSecond: number;
  refillUnitsPerSecond: number;
};
```

## 20.3. Reward Formula Example

```ts
baseReward = rewardTable[levelRange];
bonusReward =
  (usedContinue ? 0 : 15) +
  (timeLeft >= 20 ? 10 : 0) +
  (perfectClean ? 10 : 0);

totalReward = baseReward + bonusReward;
```

## 20.4. Upgrade Availability Logic

```ts
canUnlockLane = campaignLevel >= laneUnlockLevel;
canBuyRank =
  canUnlockLane &&
  campaignLevel >= rankUnlockLevel &&
  washCoins >= costWashCoins;
```

---

## 21. Final Decision

### Keep
- level-based structure
- target cards
- timer as main pressure
- water as secondary route pressure
- boosters before and during levels
- near-win continue moments
- light permanent upgrades
- soft currency spent on upgrades
- portrait-first screen design
- very small bottom nav

### Reject
- roguelike replacement
- deep meta tree
- multiple currencies for upgrades
- distance-based water drain
- permanent bottom nav during gameplay
- adding more than 2 meta tabs in MVP

---

## 22. Final Product Shape After Patch

The game is now:

> **a portrait-first, level-based restoration puzzle with timer pressure, refill routing, boosters, and a light permanent upgrade screen for the player’s sprayer**

This is still aligned with the original shell while making the product more legible, more marketable in vertical formats, and more sustainable as a casual F2P progression product.

---
