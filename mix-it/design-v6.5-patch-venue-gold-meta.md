# PATCH: Arena Venue Meta (Gold Upgrades + Milestone Booster Rewards)

**Applies to:** `design-v6.md` and supersedes the direct post-match booster reward direction from `design-v6.1-patch-loadout.md`  
**Date:** 2026-04-16  
**Purpose:** Add a lightweight arena-themed "village" layer that fits BAR CLASH better as a **Venue** or **Bar District** system: the player earns gold from matches, upgrades venue buildings between matches, and gets boosters mainly from venue milestones instead of every match.

---

## Design intent

This patch keeps BAR CLASH focused on its real core:
- shared-customer PvP serve-race
- water-sort routing skill
- pre-match 2-slot booster loadout
- trophy ladder and arena climb

But it adds a clearer long-term reason to play:

**I win matches to earn trophies and gold. I spend gold upgrading my current venue. Venue milestones give me boosters and visible account progress.**

This gives BAR CLASH a more visible home-screen meta while keeping the PvP loop primary.

---

## Product stance

Use this as the explicit design stance:

> Matches earn the gold. The Venue tab spends the gold. Boosters come mostly from venue milestones, not from every match.

And:

> Home shows progress visually, but venue interaction lives in its own bottom-nav tab.

---

## Summary of changes

1. Add **Venue Progression** as the main gold sink
2. Home shows the current venue **visually only**
3. Add a dedicated **Venue** tab in the bottom menu for upgrades and reward claims
4. Gold is earned from match completions and results
5. Direct post-match booster drops are removed from the normal result flow
6. Boosters are now earned primarily from:
   - building completion milestones
   - full venue completion
   - arena promotion rewards
   - starter inventory
7. Keep **2 fixed booster loadout slots**
8. Keep a very small **Utility Cart** inside the Venue tab as an emergency booster top-up, not the main source of boosters
9. Tune gold rewards and venue costs so the economy is sustainable and visible

---

## Why this direction fits BAR CLASH

BAR CLASH already has:
- arena progression
- a Home screen
- a clear PvP match loop
- pre-match booster selection

What it lacks is a stronger visual meta wrapper and a cleaner reason to care about gold.

Venue progression solves three problems at once:
- gives Home a meaningful visual progression layer
- gives gold a clear sink
- lets booster supply be controlled through milestone rewards instead of noisy per-match drops

This keeps the game closer to Match Masters in spirit (PvP-first, consumable tactical tools, meta wrapper), while still fitting BAR CLASH's arena/bar fantasy better than a literal Coin Master village.

---

## Section changes

### § 4 — What changes from v6

Replace the current loadout reward lines with:

```md
- Power-ups are now consistently referred to as **Boosters**
- Boosters are selected before the match from a persistent inventory (2 fixed slots)
- Gold is earned from match completions and match results
- Direct post-match booster drops are removed from normal match rewards
- New **Venue Progression** system added as the primary gold sink
- Home shows the current venue visually only
- New **Venue** tab added in the bottom menu for upgrades and reward claims
- Boosters are granted mainly through venue milestones and arena promotions
```

---

## Terminology update

Use these terms consistently:

- **Booster** = consumable tactical tool selected before the match
- **Gold** = soft currency earned from matches and spent mostly on venue upgrades
- **Venue** = the arena-themed upgradeable home meta layer
- **Venue Milestone Reward** = booster reward granted for building or venue completion
- **Utility Cart** = small emergency booster purchase panel inside the Venue tab

Do not use:
- village
- building spins
- level completions

BAR CLASH remains match-based, not level-based.

---

## § 5 — Match Layout

No change to active in-match layout.

Gold and venue progression are **meta-layer systems** and should not clutter the match HUD.

The active match still shows:
- score bar
- opponent board
- customer zone
- 2-slot booster loadout
- player board

---

## § 8 — Boosters (Economy Refactor)

### 8.0 Booster economy philosophy

Boosters remain:
- tactical
- pre-selected
- 1-use per match if activated
- consumable

But the economy changes:
- boosters are **not** granted after every normal match
- boosters are granted mainly through venue milestones
- unused equipped boosters return to inventory after the match
- used boosters leave inventory and must be replenished

This makes boosters feel more deliberate and lets the game control supply more tightly.

---

### 8.1 Loadout

Keep the pre-match rules, with terminology cleaned up:

```md
- Before each match, the player selects up to **2 boosters** from inventory
- The player always has exactly **2 loadout slots**
- Each selected booster has **1 use** during the match
- A booster is consumed only if activated
- If a selected booster is not used, it returns to inventory after the match
- Empty slots are allowed
```

#### Design note
The loadout layer stays tactical and Match Masters-like, but booster acquisition is no longer tied to every result screen.

---

### 8.1.1 Starter inventory (UPDATED)

Replace the old starter inventory with:

| Booster | Starting quantity |
|---|---:|
| Extra Bottle | 2 |
| Flash Pour | 2 |
| Swap | 0 |
| Clear Bottle | 0 |

Additional first-launch grant:
- **50 Gold**

#### Why
The player should:
- understand boosters immediately
- have enough supply for the first few matches
- see the first venue rewards matter quickly
- not start with such a huge stock that venue rewards feel irrelevant

---

### 8.2 Booster roster

Keep the same roster, but update Flash Pour for clarity:

#### Extra Bottle
- Adds one empty bottle permanently for the rest of the match
- 1 use
- Role: workspace / setup

#### Flash Pour
- Your next **3 pours** are instant
- 1 use
- Role: tempo spike / serve conversion

#### Swap
- Select any 2 bottles; their full contents swap
- 1 use
- Role: tactical rescue / route conversion

#### Clear Bottle
- Select 1 bottle; discard all contents and make it empty
- 1 use
- Role: emergency anti-deadlock

---

### 8.3 Booster unlocks by arena

Replace the old availability section with:

| Arena | Unlocked boosters |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Flash Pour |
| Beach Bar (200-499) | + Swap |
| Cocktail Lounge (500-999) | + Clear Bottle |
| Speakeasy+ | no new booster unlocks |

#### Rule
Once a booster is unlocked, it stays available permanently for:
- pre-match loadout selection
- venue milestone reward tables
- Utility Cart emergency purchases

---

### 8.4 Booster reward sources (NEW)

Add a new subsection:

#### 8.4 Booster reward sources

Normal match results do **not** grant random boosters.

Main booster sources are:
1. Starter inventory
2. Building completion rewards (5/5)
3. Full venue completion rewards
4. Arena promotion rewards
5. Utility Cart emergency purchases

#### Design goal
Boosters should feel earned and paced, not sprayed after every match.

---

### 8.5 Utility Cart (NEW)

Add a new subsection:

#### 8.5 Utility Cart

Inside the Venue tab, the player has access to a small **Utility Cart**.

It is a safety valve, not the main progression loop.

#### Purpose
The Utility Cart exists so players are never fully blocked if they run low on boosters between milestone rewards.

#### Purchase prices
| Booster | Utility Cart price |
|---|---:|
| Extra Bottle | 60 |
| Flash Pour | 70 |
| Swap | 95 |
| Clear Bottle | 120 |

#### Rules
- Only unlocked boosters can be purchased
- No bundles in MVP
- No random chest behavior
- No discount rotation required in MVP
- The cart sits below the building reward UI in the Venue tab

#### Design note
These prices are intentionally much worse value than milestone rewards. The Venue system should remain the primary booster source.

---

## § 11 — Arenas + Venues

### 11.0 Arena progression purpose

Arenas now do four things:
1. Scale board depth and AI difficulty
2. Unlock boosters
3. Change the venue theme shown on Home and Venue screens
4. Open a new set of venue upgrades and milestone rewards

The player should feel:

**New arena = new tactical layer + new visual place + new gold sink + new milestone rewards**

---

### 11.1 Venue theme mapping (NEW)

Add a new subsection:

| Arena | Venue theme |
|---|---|
| Juice Stand | juice kiosk / stand |
| Beach Bar | beach bar |
| Cocktail Lounge | lounge interior |
| Speakeasy | hidden bar |
| Rooftop Terrace | rooftop venue |
| Grand Hotel | luxury hotel bar |

#### Rule
Home always shows the player's **current active venue theme** visually, matching the highest unlocked arena.

---

### 11.2 Venue structure (NEW)

Add a new subsection:

Each venue contains **5 upgradeable buildings / venue modules**.

Recommended generic structure:
1. Main Counter
2. Seating Area
3. Signage / Entrance
4. Decor / Lighting
5. Service Station / Shelf

Each building has **5 upgrade levels**.

Total venue progress:
- **25 upgrade steps**
- **5 building completion rewards**
- **1 full venue completion reward**

#### UI rule
The building art and labels change per arena theme, but the underlying structure stays the same for production simplicity.

---

### 11.3 Venue upgrade costs by arena (NEW)

Add a new subsection:

Each building in a venue uses the same level costs for that arena.

| Arena | L1 | L2 | L3 | L4 | L5 | Total per building | Total per venue |
|---|---:|---:|---:|---:|---:|---:|---:|
| Juice Stand | 20 | 25 | 30 | 30 | 35 | 140 | 700 |
| Beach Bar | 25 | 30 | 35 | 40 | 50 | 180 | 900 |
| Cocktail Lounge | 30 | 35 | 45 | 60 | 70 | 240 | 1200 |
| Speakeasy | 35 | 45 | 55 | 75 | 90 | 300 | 1500 |
| Rooftop Terrace | 40 | 55 | 70 | 95 | 120 | 380 | 1900 |
| Grand Hotel | 50 | 65 | 85 | 120 | 140 | 460 | 2300 |

#### Design goal
Venue completion should take a meaningful number of matches, but not feel like a months-long project.

---

### 11.4 Venue milestone rewards (NEW)

Add a new subsection:

#### Building completion rewards (5/5)
Completing a building grants a **2-booster reward bundle** based on the currently unlocked roster.

Example reward rules:
- Juice Stand: `1 Extra Bottle + 1 Flash Pour`
- Beach Bar: `1 common booster + 1 Swap`
- Cocktail Lounge+: `1 common booster + 1 higher-tier roll from unlocked roster`

#### Full venue completion rewards
Completing all 5 buildings grants a larger reward:

| Arena | Full venue reward |
|---|---|
| Juice Stand | 3 boosters |
| Beach Bar | 3 boosters + 25 Gold |
| Cocktail Lounge | 4 boosters + 40 Gold |
| Speakeasy | 4 boosters + 60 Gold |
| Rooftop Terrace | 5 boosters + 75 Gold |
| Grand Hotel | 5 boosters + 100 Gold |

#### Arena promotion reward
Reaching a new arena also grants a one-time promotion reward:

| Arena reached | Promotion reward |
|---|---|
| Beach Bar | Swap x1 + 30 Gold |
| Cocktail Lounge | Clear Bottle x1 + 40 Gold |
| Speakeasy | 60 Gold |
| Rooftop Terrace | 80 Gold |
| Grand Hotel | 100 Gold |

#### Design goal
The player should celebrate three separate beats:
- finishing a building
- finishing a venue
- unlocking the next arena

---

### 11.5 Prototype arenas (UPDATED)

Replace the old prototype arena table with:

| Arena | Trophies | Colors | Bottles | Booster unlock | Win Gold | Lose Gold | Draw Gold | Venue total cost |
|---|---:|---:|---|---|---:|---:|---:|---:|
| Juice Stand | 0-199 | 3 | 3 full + 2 empty (5) | Extra Bottle, Flash Pour | 35 | 20 | 25 | 700 |
| Beach Bar | 200-499 | 5 | 4 full + 3 empty (7) | + Swap | 40 | 22 | 30 | 900 |
| Cocktail Lounge | 500-999 | 7 | 5 full + 3 empty (8) | + Clear Bottle | 50 | 25 | 35 | 1200 |
| Speakeasy | 1000-1499 | 7 | 6 full + 4 empty (10) | no new booster | 60 | 30 | 40 | 1500 |
| Rooftop Terrace | 1500-2499 | 7 | 7 full + 5 empty (12) | no new booster | 70 | 35 | 45 | 1900 |
| Grand Hotel | 2500+ | 7 | 8 full + 5 empty (13) | no new booster | 80 | 40 | 50 | 2300 |

---

## § 12 — Match Flow

Replace the high-level flow with:

```md
HOME -> MATCHMAKING -> PRE-MATCH LOADOUT -> COUNTDOWN -> MATCH -> RESULT -> REWARD CLAIM -> HOME / VENUE
```

### 12.5 Reward Claim (UPDATED)

After the result screen, the player sees:
- win / lose / draw
- trophy delta
- gold earned
- arena promotion reward (if any)
- venue progress increment callout

Example:

```md
REWARDS
+30 Trophies
+40 Gold
VENUE PROGRESS
Beach Bar - Main Counter can now be upgraded
```

#### Rule
Do **not** show booster rewards on a normal result screen unless the match also caused:
- a building completion
n- a full venue completion
- an arena promotion

This keeps the result screen cleaner.

---

## § 13 — Home / Venue / Result

### 13.0 Bottom navigation (NEW)

Add a new subsection:

Bottom menu has **2 primary tabs** in MVP:
- **Home**
- **Venue**

Optional later tabs can be added, but are not required now.

---

### 13.1 Home (UPDATED)

Home becomes the fast-entry PvP screen.

It should show:
- Arena badge
- Trophy count with progress bar to next arena
- Gold balance
- Stats
- PLAY button
- Current venue visual preview
- Small CTA: `Go to Venue`

#### Important rule
The venue shown on Home is **visual only**.

On Home, the player cannot:
- tap buildings to upgrade
- claim building rewards
- open upgrade cards

Home is for:
- immediate readability
- status
- match entry

---

### 13.2 Venue tab (NEW)

Add a new subsection:

The Venue tab is the dedicated progression screen.

It contains:
1. Large current venue artwork
2. Venue progress header: `17 / 25 upgrades complete`
3. Five building cards / buttons
4. Upgrade cost button on the currently selected building
5. Building reward preview: `Reward at 5/5`
6. Full venue reward bar
7. Utility Cart panel at the bottom

#### Building card content
Each building card shows:
- building name
- current level (`3/5`)
- next upgrade cost in gold
- final completion reward preview

#### Upgrade interaction
Selecting a building opens the building panel:
- current level
- next level visual preview
- next cost
- final reward at `5/5`
- primary button: `UPGRADE - 40 GOLD`

#### Reward claim behavior
- Building completion rewards are claimed immediately on upgrade to `5/5`
- Full venue completion reward is claimed immediately when the 25th upgrade is purchased

---

### 13.3 Result (UPDATED)

Replace the reward messaging with a cleaner structure:
- score comparison
- trophy delta
- gold earned
- arena progress
- optional milestone reward reveal only if triggered

Example result variants:

#### Normal match
```md
+35 Trophies
+50 Gold
```

#### Match that finishes a building
```md
+35 Trophies
+50 Gold
BUILDING COMPLETE!
Reward: Flash Pour x1 + Swap x1
```

#### Match that finishes a venue
```md
+35 Trophies
+50 Gold
VENUE COMPLETE!
Reward: Clear Bottle x2 + Flash Pour x2 + 40 Gold
```

---

## § 14 — Prototype Scope

Update **Required** list with:

```md
- Gold soft currency
- Venue tab in bottom navigation
- Home venue visual preview
- 5-building venue upgrade screen
- Building completion rewards
- Full venue completion rewards
- Arena promotion rewards
- Utility Cart emergency booster purchases
- Arena-based gold rewards after each match
```

Update **Not required** with:

```md
- Shop as a standalone main tab
- Chest timers
- Sticker album
- Battle pass
- Booster mastery
- Weekly stars
- Direct booster rewards after every match
```

---

## Economy math

This section is the balancing backbone for the new system.

### 1. Gold income by match result

Assume a long-term average player profile:
- 50% win rate
- 10% draw rate
- 40% loss rate

Expected gold per match:

| Arena | Expected gold / match |
|---|---:|
| Juice Stand | 29.5 |
| Beach Bar | 31.8 |
| Cocktail Lounge | 38.5 |
| Speakeasy | 46.0 |
| Rooftop Terrace | 52.5 |
| Grand Hotel | 60.0 |

Example formula for Beach Bar:

```md
0.5 x 40 + 0.1 x 30 + 0.4 x 22
= 20 + 3 + 8.8
= 31.8 expected gold per match
```

---

### 2. Expected matches to finish a venue

| Arena | Venue cost | Expected gold / match | Expected matches to finish venue |
|---|---:|---:|---:|
| Juice Stand | 700 | 29.5 | 23.7 |
| Beach Bar | 900 | 31.8 | 28.3 |
| Cocktail Lounge | 1200 | 38.5 | 31.2 |
| Speakeasy | 1500 | 46.0 | 32.6 |
| Rooftop Terrace | 1900 | 52.5 | 36.2 |
| Grand Hotel | 2300 | 60.0 | 38.3 |

#### Interpretation
- Early venues complete fairly quickly
- Mid venues become a medium-term goal
- Late venues stay meaningful without becoming endless

---

### 3. Booster reward supply per venue

Booster supply from venue milestones:

| Arena | Building rewards | Full venue reward | Total boosters per venue |
|---|---:|---:|---:|
| Juice Stand | 5 buildings x 2 = 10 | 3 | 13 |
| Beach Bar | 5 buildings x 2 = 10 | 3 | 13 |
| Cocktail Lounge | 5 buildings x 2 = 10 | 4 | 14 |
| Speakeasy | 5 buildings x 2 = 10 | 4 | 14 |
| Rooftop Terrace | 5 buildings x 2 = 10 | 5 | 15 |
| Grand Hotel | 5 buildings x 2 = 10 | 5 | 15 |

Booster supply per expected match:

| Arena | Boosters per venue | Expected matches | Booster supply / match |
|---|---:|---:|---:|
| Juice Stand | 13 | 23.7 | 0.55 |
| Beach Bar | 13 | 28.3 | 0.46 |
| Cocktail Lounge | 14 | 31.2 | 0.45 |
| Speakeasy | 14 | 32.6 | 0.43 |
| Rooftop Terrace | 15 | 36.2 | 0.41 |
| Grand Hotel | 15 | 38.3 | 0.39 |

---

### 4. Booster consumption assumption

Expected actual booster uses per match:

| Arena band | Expected boosters used per match |
|---|---:|
| Juice Stand | 0.30 |
| Beach Bar | 0.35 |
| Cocktail Lounge | 0.40 |
| Speakeasy | 0.45 |
| Rooftop Terrace | 0.50 |
| Grand Hotel | 0.50 |

#### Why
Players equip up to 2 boosters, but many matches use:
- zero boosters in a dominant game
- one booster in a normal game
- two boosters only in high-pressure or comeback moments

Because unused equipped boosters return to inventory, real consumption is much lower than equip count.

---

### 5. Sustainability check

Compare booster supply to expected use:

| Arena | Booster supply / match | Expected use / match | Net |
|---|---:|---:|---:|
| Juice Stand | 0.55 | 0.30 | +0.25 |
| Beach Bar | 0.46 | 0.35 | +0.11 |
| Cocktail Lounge | 0.45 | 0.40 | +0.05 |
| Speakeasy | 0.43 | 0.45 | -0.02 |
| Rooftop Terrace | 0.41 | 0.50 | -0.09 |
| Grand Hotel | 0.39 | 0.50 | -0.11 |

#### Interpretation
- Early and mid game are self-sustaining through venue rewards alone
- Late game is intentionally slightly tighter
- The Utility Cart covers occasional shortages
- Promotion rewards and venue-completion gold bonuses help smooth the curve

This is intentional: boosters should feel available, but not infinite.

---

### 6. Gold pressure and Utility Cart safety valve

Because venue upgrades are the primary gold sink, the Utility Cart must stay expensive.

Example late-game tradeoff:
- buy 1 Clear Bottle for 120 gold now
- or keep that gold toward a venue upgrade

This creates a healthy choice:
- short-term tactical safety
- versus long-term progression

That tension is desirable.

---

## What this patch removes

Remove all references to:
- direct random booster rewards after every match
- booster shop as a primary main-tab economy feature
- stars
- booster mastery

---

## What stays unchanged

This patch does **not** change:
- board generation
- serve rules
- scoring
- combo logic
- Color Spawn as the board feed system
- the shared-customer race structure
- AI board logic
- trophy ladder rules
- 2-slot pre-match loadout structure

---

## Open questions for playtesting

Add:

```md
8. Does the Venue tab make gold feel more meaningful than a plain shop?
9. Does showing the venue only visually on Home keep the main screen clean enough?
10. Do building completion rewards arrive often enough to keep boosters feeling alive?
11. Is the Utility Cart expensive enough to remain a safety valve rather than the main booster source?
12. Does venue completion feel exciting, or too far away in later arenas?
13. Do players understand the difference between trophies (climb) and gold (venue progress)?
```

---

## Final intended player loop

After this patch, the player should feel:

- **I win matches to earn trophies and gold**
- **I spend gold to grow my current venue**
- **Growing the venue gives me boosters and visible progress**
- **I save my boosters for moments that matter**
- **Climbing arenas gives me a new place to build and new tools to unlock**

---

## One-line meta loop

**Play match -> earn trophies + gold -> upgrade venue in the Venue tab -> claim milestone booster rewards -> choose 2 boosters for the next match -> repeat**
