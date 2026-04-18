# PATCH: Booster Roster Refactor for v6.5 (Auto Serve as 30s Match Booster)

**Applies to:** `design-v6.md` and the current venue-based meta direction in `design-v6.5-patch-venue-gold-meta.md`  
**Date:** 2026-04-18  
**Purpose:** Refactor the booster roster around the latest BAR CLASH direction: venue-based gold meta, 2-slot pre-match loadout, scarce boosters, and puzzle-first PvP. This patch keeps the venue economy intact, removes weak-feeling boosters, and adds stronger board- and serve-native tools.

---

## Design intent

The latest v6.5 direction is already the right macro structure:

- shared-customer PvP serve-race
- water-sort routing skill
- Color Spawn as ongoing board feed
- 2-slot pre-match booster loadout
- gold earned from matches
- Venue tab as the main meta screen
- boosters granted mainly through venue milestones, venue completion, arena promotions, and Utility Cart fallback purchases

That structure should stay.

What needs to change is the **booster roster itself**.

The current v6.5 roster has two weak points:

1. **Flash Pour** is not solving the real problem of the game.  
   BAR CLASH is about routing, customer matching, and workspace pressure, not about pour animation speed.

2. **Swap** is too indirect.  
   It moves structure around, but often does not create a clear emotional payoff or a visible “I converted this into a serve” moment.

At the same time, two boosters still fit the core very well:

- **Extra Bottle** — because workspace is central to the puzzle
- **Clear Bottle** — because rescue / anti-deadlock remains meaningful in later arenas

This patch keeps those two and replaces the weaker half of the roster with tools that better support the actual game fantasy:
- fixing colors
- converting near-serves
- winning serve windows

---

## Product stance

Use this as the explicit design stance:

> BAR CLASH match boosters should solve real board problems or create real serve-race spikes.

And:

> Timed effects are allowed inside the 2-slot loadout only if they are short, tactical, and match-local.

And:

> Venue remains the strategic layer; boosters remain the tactical layer.

---

## Summary of changes

1. **Keep** Extra Bottle
2. **Keep** Clear Bottle
3. **Remove** Flash Pour
4. **Remove** Swap
5. Add **Color Splash** as a new puzzle-native match booster
6. Add **Auto Serve (30s)** as a new tactical match booster
7. Keep the venue economy structure from v6.5 unchanged
8. Keep the Venue tab focused on:
   - gold spending
   - building upgrades
   - milestone rewards
   - Utility Cart fallback purchases
9. Do **not** add separate timed Venue Service Boosts in this patch

---

## Why this fits the latest v6.5 design

The latest design makes four things very clear:

- the emotional center of the match is serving shared customers
- workspace matters because the board starts with 2 empty bottles
- boosters should be paced and scarce
- gold and meta progression already have a home in the Venue tab

That means the best match boosters are the ones that:
- create workspace
- fix colors
- rescue bad boards
- convert a narrow serve window into points

This is why the new roster should focus on:
- **Extra Bottle** for workspace
- **Color Splash** for color conversion
- **Auto Serve** for short tactical serve pressure
- **Clear Bottle** for emergency rescue

This keeps the roster small, understandable, and directly tied to the current game.

---

# Section changes

## § 4 — What changes from v6

Replace the booster-related lines with:

```md
- Booster roster refactored around puzzle-first and serve-race-first effects
- Extra Bottle remains in the roster
- Clear Bottle remains in the roster
- Flash Pour removed from the roster
- Swap removed from the roster
- New booster added: Color Splash
- New booster added: Auto Serve (30s)
- Venue system, gold rewards, and venue milestone economy remain unchanged
```

---

## Terminology update

Use these terms consistently:

- **Booster** = 1-use tactical tool selected in the 2-slot pre-match loadout
- **Auto Serve** = a short-duration tactical booster that affects only the current match after activation
- **Venue** = the strategic meta layer where gold is spent and milestone rewards are claimed
- **Utility Cart** = emergency booster purchase panel inside the Venue tab

Do **not** introduce a second booster family in this patch.
Keep the current v6.5 structure simple:
- Venue = strategic progression
- Match Booster loadout = tactical decisions

---

## § 8 — Boosters

Replace the current booster roster and related economy wording with the following structure.

### 8.0 Booster philosophy

Boosters remain:
- tactical
- pre-selected
- 1-use per match if activated
- consumable
- scarce enough to matter

They should do one of four jobs:
1. workspace expansion
2. color conversion
3. serve-window conversion
4. emergency rescue

They should **not**:
- become permanent stat upgrades
- create passive account power
- solve the whole board automatically
- exist only to speed up finger taps

---

### 8.1 Loadout

Keep the v6.5 loadout rules, unchanged in structure:

```md
- Before each match, the player selects up to **2 boosters** from inventory
- The player always has exactly **2 loadout slots**
- Each selected booster has **1 use** during the match
- A booster is consumed only if activated
- If a selected booster is not used, it returns to inventory after the match
- Empty slots are allowed
```

#### Design note
Loadout size stays fixed. The roster should get better, not wider in-match.

---

### 8.1.1 Starter inventory (UPDATED)

Replace the old starter inventory with:

| Booster | Starting quantity |
|---|---:|
| Extra Bottle | 2 |
| Color Splash | 2 |
| Auto Serve | 0 |
| Clear Bottle | 0 |

Additional first-launch grant:
- **50 Gold**

#### Why
This teaches the player the two most useful early lessons:
- workspace matters
- color correction matters

Auto Serve and Clear Bottle are saved as later unlocks so they feel meaningful.

---

### 8.2 Booster roster (REPLACED)

Replace the current roster with:

#### Extra Bottle
- Adds one empty bottle permanently for the rest of the match
- 1 use
- Role: workspace / setup

#### Color Splash
- Select 1 bottle
- Recolor the **top contiguous segment** of that bottle to one **currently visible customer color**
- Maximum affected segment size: **2 layers**
- 1 use
- Role: color fixing / route conversion

#### Auto Serve
- For **30 seconds** after activation, any valid serveable glass is automatically served after a short delay
- Auto-serve delay: **0.3 seconds**
- 1 use
- Role: short tactical scoring window / serve-race conversion

#### Clear Bottle
- Select 1 bottle
- All contents are discarded and the bottle becomes empty
- 1 use
- Role: emergency anti-deadlock / hard rescue

---

### 8.2.1 Why Flash Pour is removed

Add this note:

```md
Flash Pour is removed because faster pouring does not meaningfully solve the real tactical problems of BAR CLASH.
The important decisions are about routing, workspace, and customer-color conversion, not animation speed.
```

---

### 8.2.2 Why Swap is removed

Add this note:

```md
Swap is removed because it is too indirect and too often fails to create a clear, satisfying payoff.
It changes layout, but does not consistently create workspace, color correction, or immediate serve conversion.
```

---

### 8.2.3 Auto Serve design rule

Add this note:

```md
Auto Serve is intentionally a short-duration match booster, not a Venue effect.
Its purpose is to create a temporary high-pressure scoring window inside a match, not to act as a long-duration account buff.
```

---

### 8.3 Booster unlocks by arena (UPDATED)

Replace the unlock table with:

| Arena | Unlocked boosters |
|---|---|
| Juice Stand (0-199) | Extra Bottle, Color Splash |
| Beach Bar (200-499) | + Auto Serve |
| Cocktail Lounge (500-999) | + Clear Bottle |
| Speakeasy+ | no new booster unlocks |

#### Rule
Once unlocked, a booster stays available permanently for:
- pre-match loadout selection
- venue milestone reward tables
- Utility Cart purchases

---

### 8.4 Booster reward sources (UPDATED)

Keep the same v6.5 source logic, with updated wording:

Normal match results do **not** grant random boosters.

Main booster sources are:
1. Starter inventory
2. Building completion rewards (5/5)
3. Full venue completion rewards
4. Arena promotion rewards
5. Utility Cart purchases

#### Design goal
Boosters should feel paced and meaningful, not sprayed after every match.

---

### 8.5 Utility Cart (UPDATED)

Keep Utility Cart as the emergency purchase panel, but update the prices to match the new roster.

| Booster | Utility Cart price |
|---|---:|
| Extra Bottle | 60 |
| Color Splash | 75 |
| Auto Serve | 90 |
| Clear Bottle | 120 |

#### Price logic
- Extra Bottle is the cheapest because it is useful but fair
- Color Splash is more premium because it directly fixes color state
- Auto Serve is priced below Clear Bottle, but high enough that it remains a deliberate purchase
- Clear Bottle stays the most expensive panic tool

#### Design rule
The Utility Cart remains a fallback system.  
Venue milestones should remain the primary source of booster inventory.

---

## § 9 — AI Opponent

Replace the booster usage table with:

| Booster | AI usage condition |
|---|---|
| Extra Bottle | Use within first 15 seconds if workspace is tight |
| Color Splash | Use when recoloring the top segment creates a likely customer-matching route |
| Auto Serve | Use when AI expects multiple serves in the next 30 seconds |
| Clear Bottle | Use when board has 0 empty bottles and no clean route |

- AI usage delay: 2-4 seconds after condition is met
- AI does not buy boosters mid-match
- Remove all old Flash Pour / Swap logic from AI behavior

---

## § 11 — Arenas + Venues

### 11.0 Arena progression purpose (booster wording update)

Update the booster wording to:

```md
Arenas now do four things:
1. Scale board depth and AI difficulty
2. Unlock new boosters
3. Change the venue theme shown on Home and Venue screens
4. Open a new set of venue upgrades and milestone rewards
```

---

### 11.4 Venue milestone rewards (UPDATED)

Update reward examples to reflect the new roster.

#### Building completion rewards (5/5)

Example reward rules:
- Juice Stand: `1 Extra Bottle + 1 Color Splash`
- Beach Bar: `1 common booster + 1 Auto Serve`
- Cocktail Lounge+: `1 common booster + 1 higher-tier roll from unlocked roster`

#### Full venue completion rewards

Replace the generic examples with more explicit bundles:

| Arena | Full venue reward |
|---|---|
| Juice Stand | `Extra Bottle x2 + Color Splash x1` |
| Beach Bar | `Color Splash x1 + Auto Serve x2 + 25 Gold` |
| Cocktail Lounge | `Auto Serve x2 + Clear Bottle x2 + 40 Gold` |
| Speakeasy | `Auto Serve x2 + Clear Bottle x2 + 60 Gold` |
| Rooftop Terrace | `Color Splash x2 + Auto Serve x2 + Clear Bottle x1 + 75 Gold` |
| Grand Hotel | `Auto Serve x2 + Clear Bottle x2 + Extra Bottle x1 + 100 Gold` |

#### Arena promotion reward

Replace promotion rewards with:

| Arena reached | Promotion reward |
|---|---|
| Beach Bar | `Auto Serve x1 + 30 Gold` |
| Cocktail Lounge | `Clear Bottle x1 + 40 Gold` |
| Speakeasy | `60 Gold` |
| Rooftop Terrace | `80 Gold` |
| Grand Hotel | `100 Gold` |

#### Design note
Later arenas should reward stronger rescue and scoring-window tools, not just more copies of openers.

---

## § 12 — Match Flow

Keep the v6.5 high-level flow unchanged:

```md
HOME -> MATCHMAKING -> PRE-MATCH LOADOUT -> COUNTDOWN -> MATCH -> RESULT -> REWARD CLAIM -> HOME / VENUE
```

Update the Reward Claim rule with one wording change:

```md
- Booster rewards are shown only when triggered by a building completion, a full venue completion, or an arena promotion
```

No extra timed-service-boost messaging is needed.

---

## § 13 — Home / Venue / Result

### 13.1 Home (booster summary update)

Replace the example inventory summary with:

```md
Gold: 185
Boosters:
Extra Bottle x2
Color Splash x1
Auto Serve x0
Clear Bottle x0
```

Update next arena teaser example:

```md
NEXT ARENA: Beach Bar
Unlocks: Auto Serve
Promotion Reward: Auto Serve x1 + 30 Gold
```

---

### 13.2 Venue tab

Keep the Venue tab structure from v6.5.

Do **not** add a separate timed-service-boost panel in this patch.

The Venue tab should still contain:
1. Large current venue artwork
2. Venue progress header
3. Five building cards / buttons
4. Upgrade interaction panel
5. Building reward preview
6. Full venue reward bar
7. Utility Cart panel at the bottom

#### Venue rule
Venue stays focused on:
- spending gold
- growing the venue
- claiming milestone rewards
- emergency booster replenishment

---

### 13.3 Result (UPDATED)

Update reward examples to reflect the new roster.

#### Match that finishes a building
```md
+35 Trophies
+50 Gold
BUILDING COMPLETE!
Reward: Extra Bottle x1 + Auto Serve x1
```

#### Match that finishes a venue
```md
+35 Trophies
+50 Gold
VENUE COMPLETE!
Reward: Auto Serve x2 + Clear Bottle x2 + 40 Gold
```

#### Match that triggers an arena promotion
```md
+35 Trophies
+50 Gold
NEW ARENA UNLOCKED!
Reward: Auto Serve x1 + 30 Gold
```

---

## § 14 — Prototype Scope

Update **Required** list with:

```md
- New booster roster:
  - Extra Bottle
  - Color Splash
  - Auto Serve
  - Clear Bottle
- Removal of Flash Pour and Swap
- Updated AI logic for the new roster
- Updated Utility Cart pricing
- Updated booster milestone reward tables
```

Update **Not required** with:

```md
- Flash Pour
- Swap
- Venue Service Boost layer
- Booster mastery
- Weekly stars
- Standalone shop tab
```

---

## Economy notes

This patch keeps the v6.5 macro economy intact:
- gold still comes from match results
- venue upgrades remain the main sink
- boosters still come mainly from venue milestones
- Utility Cart stays deliberately expensive

What changes is the **value per booster use**.

### Design economics impact

#### Higher value per use
The new roster should produce more visible and satisfying payoff than Flash Pour / Swap.

That means:
- supply can stay relatively low
- each booster reward feels more exciting
- players are more willing to save boosters for high-pressure matches

#### Cleaner booster roles
Each booster now has a much clearer purpose:
- Extra Bottle = workspace
- Color Splash = color fix
- Auto Serve = scoring window
- Clear Bottle = rescue

That should improve both understanding and balance tuning.

---

## What this patch removes

Remove all references to:
- Flash Pour
- Swap
- instant-pour speed boosts
- timed Venue Service Boosts
- separate service-boost panels in Venue

---

## What stays unchanged

This patch does **not** change:
- board generation
- Color Spawn base behavior
- serve rules
- combo rules
- 2-slot pre-match loadout structure
- venue progression structure
- gold rewards by arena
- trophy ladder structure

---

## Open questions for playtesting

Add:

```md
14. Does Color Splash feel more useful and satisfying than Flash Pour or Swap?
15. Does Auto Serve create meaningful serve-race spikes without feeling too automatic?
16. Is 30 seconds the right Auto Serve duration, or should it be 20 or 25?
17. Is Auto Serve clearer as a match booster than as a venue/meta effect?
18. Are Utility Cart prices high enough that venue milestones remain the primary source of boosters?
19. Does the new 4-booster roster feel easier to understand and more exciting to save?
```

---

## Final intended player feeling

After this patch, the player should feel:

- **My boosters solve real problems in this puzzle**
- **When I use one, I can clearly see why it mattered**
- **Auto Serve helps me win a short scoring window, not passively farm forever**
- **The venue remains my long-term progression layer, while boosters stay tactical**

---

## One-line meta loop

**Play match -> earn trophies + gold -> upgrade venue -> claim milestone boosters -> choose 2 strong tactical boosters -> convert better serves and win more races -> repeat**
