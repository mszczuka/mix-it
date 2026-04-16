# PATCH: Arena Progression Through Booster Arsenal (No Collection)

**Applies to:** `design-v6.md` and the pre-match loadout direction from `design-v6.1-patch-loadout.md`  
**Date:** 2026-04-16  
**Purpose:** Make arena climbing feel like real player progression without adding a collection layer, a village meta, or extra booster slots.

---

## Design intent

BAR CLASH should answer the question:

**Why should I keep winning and climbing?**

The answer should not be:
- only because numbers go up
- only because boards get harder
- only because trophies increase

The answer should be:

**I climb because higher arenas expand my tactical toolbox, improve my reward quality, and unlock more expressive loadout decisions.**

This patch keeps the game **Match Masters-like in structure**:
- fixed pre-match loadout
- limited-use tactical tools
- trophy / arena progression
- growing arsenal over time

But it **does not** add:
- sticker albums
- collection books
- village / renovation meta
- chest timers
- more booster slots

The goal is to make progression visible and motivating while keeping BAR CLASH skill-first and PvP-first.

---

## Summary of changes

1. Booster slot count stays fixed at **2** across the whole game
2. Arena progression now grants **explicit booster arsenal growth**
3. Each arena promotion gives a **guaranteed promotion reward**
4. Match rewards improve in **quality**, not just quantity, as arenas rise
5. New **Booster Mastery** system gives long-term progression without collection
6. Result and arena unlock screens now communicate progression more clearly
7. Arena climb is reframed as unlocking **new tactical play**, not just harder matches

---

## Why this patch exists

The current direction already has:
- trophies
- arenas
- pre-match loadout
- match rewards in power-ups

That creates a basic progression loop, but the current climb motivation is still too weak.

Right now, moving to a higher arena mostly means:
- harder boards
- more colors / bottles
- stronger opponents
- some new power-ups

That is useful, but not yet emotionally strong enough.

This patch makes the player feel:

- **I reached a new arena, so I got something permanent**
- **I now have more ways to play**
- **Winning at this level is more rewarding than winning below**
- **My favorite boosters are also progressing with me**

---

## Core progression principle

Arena progression should widen the player's **arsenal**, not widen the player's **hotbar**.

That means:

- keep **2 booster slots**
- unlock **more booster options**
- improve **reward quality**
- add **mastery tracks** for depth

Do **not** solve progression by adding a 3rd or 4th slot.

More slots would:
- increase UI complexity
- reduce clarity of each decision
- create power creep
- make the puzzle layer easier to override
- weaken the importance of timing

Fixed 2-slot loadout keeps each choice meaningful.

---

## Section changes

### § 4 — What changes from v6

Add to the "Changed" list:

```md
- Arena progression now grants explicit booster arsenal growth
- Booster slot count stays fixed at 2 across all arenas
- Arena promotions grant guaranteed booster rewards
- Match rewards improve in quality as arenas rise
- New Booster Mastery system added for long-term progression
```

---

### § 8 — Power-Ups / Boosters

Add the following progression rule near the start of the section:

#### 8.0 Booster progression philosophy

Boosters are not a collection set to complete.

They are a **tactical arsenal**:
- unlocked through progression
- stocked through match rewards
- selected before each match
- spent through smart timing
- mastered over time

The player should feel that their options are expanding as they climb, while the number of choices they bring into a match remains fixed and readable.

---

### § 8.1 Loadout

Update with this rule:

```md
- The player always has exactly **2 booster loadout slots**
- Additional slots are never unlocked through progression
- Progression comes from a broader booster roster, not a larger loadout
```

Add this design note below:

```md
Design note:
Keeping loadout size fixed preserves clarity, tactical tension, and the importance of each booster pick.
```

---

### § 8.3 Booster unlocks by arena

Replace the old availability section with:

#### 8.3 Booster unlocks by arena

Boosters unlock through arena progression.  
Once unlocked, a booster remains available permanently in all future arenas.

| Arena | Newly unlocked | Total selectable roster |
|---|---|---|
| Juice Stand | Extra Bottle, Flash Pour | 2 |
| Beach Bar | Swap | 3 |
| Cocktail Lounge | Clear Bottle | 4 |
| Speakeasy | No new booster, reward quality upgrade | 4 |
| Rooftop Terrace | No new booster, mastery milestone unlock | 4 |
| Grand Hotel | No new booster, elite reward tuning | 4 |

#### Design note
Early arenas add new tactical tools quickly.  
Later arenas stop increasing raw complexity and instead improve the value of progression through better reward structure and mastery.

---

### § 8.4 Promotion rewards (NEW)

Add a new subsection:

#### 8.4 Promotion rewards

When the player reaches a new arena for the first time, they receive a **guaranteed promotion reward**.

| Arena reached | Promotion reward |
|---|---|
| Juice Stand | Starter inventory already granted on first launch |
| Beach Bar | `Swap x3` |
| Cocktail Lounge | `Clear Bottle x3` |
| Speakeasy | `Flash Pour x2` + `Extra Bottle x2` |
| Rooftop Terrace | `1 Bonus Reward Pick` + `Flash Pour x2` |
| Grand Hotel | `1 Elite Reward Pick` + `Clear Bottle x2` |

#### Promotion reward rules
- Granted only once per account per arena
- Shown in a dedicated arena unlock popup
- If the arena unlocks a new booster, that booster is the visual focus of the popup
- Promotion rewards are added immediately to inventory

#### Design goal
Promotion should feel like a real upgrade event, not just a rank label change.

---

### § 8.5 Match reward quality by arena (NEW)

Add a new subsection:

#### 8.5 Match reward quality by arena

Match rewards improve with arena level.

This progression should be felt through **reward quality**, not only raw quantity.

| Arena | Win reward | Lose reward | Draw reward |
|---|---|---|---|
| Juice Stand | 2 random boosters | 1 random booster | 1 random booster |
| Beach Bar | 2 random boosters | 1 random booster | 1 random booster |
| Cocktail Lounge | 2 random boosters + 20% bonus roll | 1 random booster | 1 random booster |
| Speakeasy | 2 random boosters + choose 1 of 2 bonus rewards | 1 random booster + 20% bonus roll | 1 random booster |
| Rooftop Terrace | 2 random boosters + guaranteed non-common roll | 1 random booster + choose 1 of 2 bonus rewards | 1 random booster |
| Grand Hotel | 2 random boosters + elite bonus reward | 1 random booster + guaranteed bonus roll | 1 random booster + 20% bonus roll |

#### Reward quality rules
- "Bonus roll" means an extra chance to gain 1 additional booster
- "Choose 1 of 2" means the player is shown two booster rewards and picks one
- "Guaranteed non-common roll" means the reward cannot roll the most common outcome bucket
- "Elite bonus reward" can favor later-unlock boosters or higher-value reward bundles

#### Design goal
Higher arenas should feel more generous and more meaningful even when the player already knows all core boosters.

---

### § 8.6 Booster rarity weights by arena (NEW)

Add a new subsection:

#### 8.6 Booster reward weights by arena

Booster reward tables shift by arena to reinforce progression.

Example baseline:

| Booster | Early arena weight | Late arena weight |
|---|---|---|
| Extra Bottle | 30% | 24% |
| Flash Pour | 30% | 28% |
| Swap | 25% | 26% |
| Clear Bottle | 15% | 22% |

#### Rule
As players climb, reward tables should gradually become less weighted toward basic openers and more weighted toward tactically expressive boosters.

#### Design goal
The player should feel that higher arenas have a stronger reward identity.

---

### § 8.7 Booster Mastery (NEW)

Add a new subsection:

#### 8.7 Booster Mastery

Booster Mastery provides long-term progression without adding a collection system.

Each booster has a mastery track tied to use and success.

Example mastery objectives:

| Booster | Example mastery goals |
|---|---|
| Extra Bottle | Play 20 matches with Extra Bottle equipped |
| Flash Pour | Perform 30 serves within 5 seconds of activation |
| Swap | Use Swap to create 20 serveable glasses |
| Clear Bottle | Recover from 0 empty bottles 15 times |

#### Mastery rewards
Mastery rewards should be light and status-focused:
- profile badge
- match banner flair
- subtle board cosmetic
- small one-time booster bundle
- mastery star for that booster

#### Rules
- Mastery does not increase booster strength
- Mastery does not unlock extra loadout slots
- Mastery is permanent account progression
- Mastery is visible in a simple booster detail screen

#### Design goal
Mastery gives players a reason to keep using and improving with specific boosters without creating collection pressure or balance inflation.

---

### § 11 — Arenas

Update arena philosophy with this paragraph:

#### 11.0 Arena progression purpose

Arenas do not exist only to increase difficulty.

Each new arena should offer at least one of the following:
- broader tactical options
- better reward quality
- a stronger sense of status
- new mastery goals
- more expressive match planning

The player should feel that climbing upward expands the game, rather than simply punishing them with harder boards.

---

### § 11.2 Prototype arenas

Update the table by adding two new columns:

| Arena | Trophies | Colors | Bottles | Booster unlock | Progression reward |
|---|---|---|---|---|---|
| Juice Stand | 0-199 | 3 | 3 full + 2 empty (5) | Extra Bottle, Flash Pour | Starter inventory |
| Beach Bar | 200-499 | 5 | 4 full + 3 empty (7) | + Swap | `Swap x3` |
| Cocktail Lounge | 500-999 | 7 | 5 full + 3 empty (8) | + Clear Bottle | `Clear Bottle x3` |
| Speakeasy | 1000-1499 | 7 | 6 full + 4 empty (10) | No new booster | reward quality upgrade |
| Rooftop Terrace | 1500-2499 | 7 | 7 full + 5 empty (12) | No new booster | mastery milestone unlock |
| Grand Hotel | 2500+ | 7 | 8 full + 5 empty (13) | No new booster | elite reward tuning |

---

### § 12 — Match Flow

Update the flow to make progression visible:

#### 12.1 Flow

```md
HOME -> MATCHMAKING -> PRE-MATCH LOADOUT -> COUNTDOWN -> MATCH -> RESULT -> REWARD CLAIM -> HOME
```

#### 12.5 Reward Claim (NEW)

After the result screen, the player sees a compact reward claim step.

Contents:
- trophies gained / lost
- boosters gained
- bonus roll result (if any)
- promotion reward (if arena promoted)
- mastery progress pips for equipped boosters

#### Design goal
Progress should be visible every match, not hidden inside inventory numbers.

---

### § 13 — Home / Result

Add the following to **Home**:

#### Home additions
- "Current Arena Benefits" panel:
  - unlocked booster roster
  - current reward bonus
  - next arena unlock preview

Example:
```md
NEXT ARENA: Beach Bar
Unlocks: Swap
Promotion Reward: Swap x3
```

Add the following to **Result**:

#### Result screen additions
- reward section already shows gained boosters
- add mastery progress for the 2 equipped boosters
- if arena promotion occurs, show dedicated unlock banner before returning home

Example:
```md
FLASH POUR MASTERY +1
3 / 30 fast serves
```

---

### § 14 — Prototype Scope

Update **Required** list:

```md
- Arena promotion rewards
- Reward quality scaling by arena
- Booster mastery tracking
- Home screen next-arena preview
- Reward claim step after results
```

Add to **Not required**:

```md
- Collection album
- Booster collection book
- Additional booster slots
- Village / renovation meta
```

---

### § 15 — Open Questions for Playtesting

Add:

```md
8. Do players feel a strong reason to climb arenas beyond difficulty alone?
9. Are promotion rewards large enough to feel exciting?
10. Does fixed 2-slot loadout still feel expressive after all boosters are unlocked?
11. Does booster mastery create healthy long-term goals, or does it feel too grindy?
12. Is reward quality scaling more motivating than simply giving more boosters?
```

---

## Recommended product stance

Use this as the explicit design stance:

> BAR CLASH progression is built around tactical arsenal growth, not collection completion.

And also:

> Higher arenas should increase strategic expression before they increase system complexity.

---

## What this patch intentionally does NOT add

This patch does **not** add:
- sticker albums
- collectible sets
- village building
- bar renovation meta
- chest timers
- battle pass
- a 3rd booster slot
- booster upgrading through duplicates
- booster power levels

Those systems may be explored later, but they are not necessary to make arena climbing feel meaningful right now.

---

## Final intended player motivation

After this patch, the player should feel:

- **I win to climb**
- **I climb to unlock better tactical options**
- **I unlock better options to build smarter loadouts**
- **I keep playing because each match also grows my mastery and reward quality**

That is enough to create a strong medium-term meta loop without adding a separate collection game.

---

## One-line meta loop

**Play match -> win trophies and boosters -> improve arsenal -> choose 2-booster loadout -> climb into richer rewards and deeper tactics -> repeat**
