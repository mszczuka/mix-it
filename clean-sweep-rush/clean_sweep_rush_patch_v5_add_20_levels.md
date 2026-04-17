# Clean Sweep Rush — Content Expansion Patch
**Patch ID:** `design-patch-v5-add-20-levels-backyard-chaos`  
**Applies to:** `index.html`, `design-doc.md`, `clean_sweep_rush_patch_v4_level_difficulty_fix.md`  
**Audience:** Game Design, Level Design, Economy, Claude Code  
**Status:** Proposed content patch  

---

## 1. Patch Goal

This patch expands the prototype from **3 levels** to **23 total levels** by adding **20 new levels**.

The goal is **not** to simply add more content volume.  
The goal is to add a proper **first-world progression ladder** that matches the current product shape:

- level-based
- explicit goals
- one complication at a time
- fast early payoff
- readable near-win tension
- light permanent progression
- portrait-first casual pacing

This patch assumes:
- Levels 1–3 are already fixed by the onboarding/difficulty patch
- the game keeps the current regenerating tank model
- gold remains visible during gameplay
- boosters remain optional support, not required build-drafting

---

## 2. Why This Patch Is Needed

The current prototype code only contains **3 level definitions** in the `LEVELS` array. That is enough for core-loop validation, but not enough to validate:
- campaign pacing
- upgrade unlock flow
- water-pressure curve
- goal variety
- difficulty cadence
- first-world economy loop

The design doc recommends that each world should contain **20–40 levels**, with a clear visual theme, signature dirt/hazard family, and one new mechanic or complication. The current first world is `Backyard Chaos`, so the most natural next step is to expand that world into a full first pack rather than immediately jumping across multiple themes.

The design also says difficulty should:
- introduce one complication at a time
- include easier relief levels
- avoid early chaos inflation
- use a 10-level rhythm with easy / standard / hard / bonus cadence.

That is exactly what this patch adds.

---

## 3. Final Scope

### Current state
- Levels 1–3 exist

### New state after patch
- Levels 1–23 exist
- all 23 levels remain in **World 1: Backyard Chaos**
- the first world now has enough content to validate:
  - onboarding
  - target variety
  - lock / restore sequence readability
  - static area-target logic
  - first hazard introduction
  - first economy relief levels
  - upgrade usefulness over time

---

## 4. World 1 Progression Model

## 4.1. World Theme
**Backyard Chaos**

Theme fantasy:
- a messy, muddy suburban backyard gradually becomes restored, organized, bright, and alive

Primary dirt families:
- mud
- leaves
- sludge

Primary early object families:
- pots
- benches
- birdbath
- hose reel
- garden cart
- lamp posts
- picnic table
- fountain
- shed door / gate
- planter boxes

Primary restore actions:
- birdbath
- fountain
- garden lights
- sprinkler
- compost machine
- patio lamp string

Primary first-world hazard family:
- light recontamination vent / muddy sprinkler leak
- only introduced later and lightly

---

## 5. Difficulty Philosophy for the 20 New Levels

The first world should feel like this:

### Levels 1–5
- learning
- confidence
- zero-to-low pressure
- no hidden complexity

### Levels 6–10
- mixed targets
- basic routing
- first lock and first restore
- first relief level

### Levels 11–15
- stable area-target introduction
- more map spread
- stronger tank rhythm pressure
- first soft hazard

### Levels 16–20
- combinations of already-taught systems
- denser goals
- more meaningful route planning
- second relief level

### Levels 21–23
- first-world mini-finale
- multi-step restore fantasy
- clear but fair challenge spike

This keeps the world aligned with the intended casual progression model rather than turning into a difficulty cliff.

---

## 6. Content Structure Rules for Added Levels

All added levels should follow these rules:

### 6.1. Level length target
- early added levels: **45–65s**
- mid added levels: **55–75s**
- late first-world levels: **65–85s**

### 6.2. Objective count
- 1 target card for very simple levels
- 2 target cards for standard levels
- 3 target cards only after the systems are already understood

### 6.3. Area targets
If used:
- denominator must be static at level start
- hazard-spawned dirt must **not** increase target total

### 6.4. Hazard usage
- no hazards before Level 12
- only one hazard family at a time early
- hazards should create route pressure, not confusion

### 6.5. Booster presentation
- no mandatory booster framing
- optional helper tray only
- the level must be beatable without booster spend

---

## 7. New Levels — Full Plan

Below is the proposed 20-level extension.

---

## 7.1. Levels 4–8 — Early Expansion

### Level 4 — `Potting Corner`
**Timer:** 55s  
**Targets:**
- Clean Pots x4  
**Systems:**
- simple spread
- first slightly wider route
**Notes:**
- unlocks `Tank Capacity` lane by campaign progression
- still no locks or hazards

### Level 5 — `Bench Wipe`
**Timer:** 55s  
**Targets:**
- Clean Bench x1
- Clean Mud Patches x4  
**Systems:**
- first mixed target level after safe onboarding
**Notes:**
- bench visible from first screen
- mud creates route extension

### Level 6 — `Gate Mud`
**Timer:** 60s  
**Targets:**
- Clean Mud Patches x6  
**Systems:**
- first simple lock/gate
**Notes:**
- player clears a small blocker cluster to access final 2 mud targets
- no restore yet

### Level 7 — `Birdbath Prep`
**Timer:** 60s  
**Targets:**
- Restore Birdbath x1  
**Systems:**
- first pure restore refresher
- no secondary goals
**Notes:**
- 1 lock only
- clear readability of “clean -> restore -> win”

### Level 8 — `Leaf Sweep`
**Timer:** 55s  
**Targets:**
- Clean Leaves x8
- Clean Pots x2  
**Systems:**
- target variety
- no hidden content
**Notes:**
- unlocks `Spray Width` by progression
- leaves teach quicker visual reward pattern

---

## 7.2. Levels 9–13 — Mixed Goals and First Relief

### Level 9 — `Garden Path`
**Timer:** 65s  
**Targets:**
- Clean Mud Patches x5
- Clean Bench x2  
**Systems:**
- broader route
- two clear lanes in map
**Notes:**
- no lock
- readability over challenge

### Level 10 — `Quick Cleanup` *(relief level)*
**Timer:** 50s  
**Targets:**
- Clean Pots x5  
**Systems:**
- dense easy cluster
- high gold-per-minute feel
**Notes:**
- relief level
- good for confidence and first upgrades

### Level 11 — `Compost Route`
**Timer:** 65s  
**Targets:**
- Clean Sludge x4
- Clean Mud Patches x3  
**Systems:**
- first larger sludge presence
- stop-and-go water rhythm becomes meaningful
**Notes:**
- no hazards
- no restore

### Level 12 — `Patio Area`
**Timer:** 70s  
**Targets:**
- Clean Patio Area 70%
- Clean Bench x1  
**Systems:**
- first **static** area target
**Notes:**
- no hazard respawn in target area
- bench gives extra clarity and anchor goal

### Level 13 — `Lamp Restore`
**Timer:** 70s  
**Targets:**
- Restore Garden Lamp x1
- Clean Leaves x6  
**Systems:**
- restore + secondary clean target
**Notes:**
- one gate only
- first slightly longer route

---

## 7.3. Levels 14–18 — Mid World

### Level 14 — `Mud Spiral`
**Timer:** 70s  
**Targets:**
- Clean Mud Patches x8  
**Systems:**
- denser routing
- stronger tank rhythm pressure
**Notes:**
- no restore
- intended as pure movement/clean efficiency test

### Level 15 — `Sprinkler Leak`
**Timer:** 75s  
**Targets:**
- Restore Sprinkler x1
- Clean Mud Patches x5  
**Systems:**
- first soft hazard family
- leak zone creates light route pressure
**Notes:**
- unlocks `Regen Speed` lane by campaign progression
- hazard stays local and readable

### Level 16 — `Garden Cart`
**Timer:** 75s  
**Targets:**
- Clean Garden Cart x1
- Clean Sludge x4
- Clean Pots x2  
**Systems:**
- first 3-target level
**Notes:**
- no hazard
- challenge comes from route ordering only

### Level 17 — `Side Yard Clean`
**Timer:** 75s  
**Targets:**
- Clean Side Yard 75%  
**Systems:**
- second area-target level
- slightly wider map spread
**Notes:**
- static denominator required
- no recontamination inside counted area

### Level 18 — `Fence Unlock`
**Timer:** 80s  
**Targets:**
- Clean Mud Patches x4
- Restore Birdbath x1  
**Systems:**
- two-step progression
- first meaningful gate placement
**Notes:**
- gate opens second half of map
- still fair and linear

---

## 7.4. Levels 19–23 — Late World / Mini-Finale

### Level 19 — `Back Corner`
**Timer:** 75s  
**Targets:**
- Clean Sludge x5
- Clean Leaves x8  
**Systems:**
- denser dual-dirt routing
**Notes:**
- stronger use of spray rhythm and vacuum identity

### Level 20 — `Coin Rinse` *(relief / bonus-feel level)*
**Timer:** 55s  
**Targets:**
- Clean Pots x6
- Clean Benches x2  
**Systems:**
- low complexity
- high reward feel
**Notes:**
- second relief level
- should feel very beatable

### Level 21 — `Fountain Access`
**Timer:** 80s  
**Targets:**
- Clean Mud Patches x5
- Restore Fountain x1  
**Systems:**
- lock + restore
- stronger route optimization
**Notes:**
- first-world penultimate setup

### Level 22 — `Light the Yard`
**Timer:** 85s  
**Targets:**
- Restore Garden Lights x2
- Clean Leaves x10  
**Systems:**
- dual restore targets
- wider map
**Notes:**
- still no overlapping hazard spam

### Level 23 — `Backyard Reborn` *(world mini-finale)*
**Timer:** 90s  
**Targets:**
- Clean Main Yard 80%
- Restore Fountain x1
- Restore Garden Lights x1  
**Systems:**
- combined finale of already-taught systems
**Notes:**
- no hidden denominator changes
- one soft hazard zone allowed outside counted area
- should feel like a capstone, not a wall

---

## 8. New Level Matrix

| Level | Name | Timer | Targets | New / Main System |
|---|---|---:|---|---|
| 4 | Potting Corner | 55s | Pots x4 | wider route |
| 5 | Bench Wipe | 55s | Bench x1, Mud x4 | mixed goals |
| 6 | Gate Mud | 60s | Mud x6 | first gate |
| 7 | Birdbath Prep | 60s | Restore Birdbath x1 | restore refresher |
| 8 | Leaf Sweep | 55s | Leaves x8, Pots x2 | target variety |
| 9 | Garden Path | 65s | Mud x5, Bench x2 | broader routing |
| 10 | Quick Cleanup | 50s | Pots x5 | relief |
| 11 | Compost Route | 65s | Sludge x4, Mud x3 | sludge pressure |
| 12 | Patio Area | 70s | Area 70%, Bench x1 | first static area target |
| 13 | Lamp Restore | 70s | Restore Lamp x1, Leaves x6 | restore + secondary goal |
| 14 | Mud Spiral | 70s | Mud x8 | route efficiency |
| 15 | Sprinkler Leak | 75s | Restore Sprinkler x1, Mud x5 | first soft hazard |
| 16 | Garden Cart | 75s | Cart x1, Sludge x4, Pots x2 | first 3-target level |
| 17 | Side Yard Clean | 75s | Area 75% | second area target |
| 18 | Fence Unlock | 80s | Mud x4, Restore Birdbath x1 | lock + restore |
| 19 | Back Corner | 75s | Sludge x5, Leaves x8 | denser dual-dirt route |
| 20 | Coin Rinse | 55s | Pots x6, Benches x2 | relief |
| 21 | Fountain Access | 80s | Mud x5, Restore Fountain x1 | penultimate restore route |
| 22 | Light the Yard | 85s | Restore Lights x2, Leaves x10 | dual restore |
| 23 | Backyard Reborn | 90s | Area 80%, Restore Fountain x1, Restore Lights x1 | world mini-finale |

---

## 9. Gold Reward Plan for the New Levels

The prototype should use a simple and readable first-world reward curve.

### Recommended base rewards
| Levels | Base Reward |
|---|---:|
| 1–5 | 60 Gold |
| 6–10 | 70 Gold |
| 11–15 | 85 Gold |
| 16–20 | 100 Gold |
| 21–23 | 120 Gold |

### Relief level bonus
Levels 10 and 20:
- +15 extra base reward

### Goal-specific bonus emphasis
Restore targets should feel more valuable than raw dirt cleanup:
- restore completion should produce stronger on-map gold feedback
- finale levels should feel noticeably better in payout

This supports the permanent upgrade loop without making early progression grindy.

---

## 10. Upgrade Unlock Synergy

The 20 new levels should align with the existing upgrade gates:

- `Tank Capacity` unlocks at Level 4
- `Spray Width` unlocks at Level 8
- `Regen Speed` unlocks at Level 15
- `Move Speed` unlocks at Level 25 (outside this patch’s scope for now)

This means the world now naturally supports:
- first tank-focused choices in early world
- width becoming meaningful in leaf and spread-heavy maps
- regen speed becoming meaningful exactly when hazard/tank rhythm starts to matter

That is much healthier than having upgrades unlock with too little content to justify them.

---

## 11. Implementation Notes for `index.html`

## 11.1. Extend `LEVELS` array
The current file defines only Levels 1–3. Add levels 4–23 using the structure already present in the existing `LEVELS` array.

Recommended minimum fields per level:
```ts
{
  worldName: "Backyard Chaos",
  levelName: "Potting Corner",
  levelNumber: 4,
  timer: 55,
  startX: 225,
  startY: 600,
  targets: [...]
}
```

## 11.2. Add layout-driven spawning
Do not hardcode all spawn logic inside one giant `if (levelNumber === X)` chain if it can be avoided.

Recommended approach:
- add `layoutId` to each level
- define a `LEVEL_LAYOUTS` dictionary
- each layout contains:
  - dirt nodes
  - objects
  - gates/locks
  - hazards
  - restore anchors
  - power-up placements if any

Example:
```ts
{
  levelNumber: 12,
  worldName: "Backyard Chaos",
  levelName: "Patio Area",
  timer: 70,
  layoutId: "w1_l12_patio_area",
  targets: [...]
}
```

This will make expansion to 40+ levels much safer.

## 11.3. Add area-target safety field
For later static area targets, use:
```ts
countsForAreaTarget: true | false
```

And snapshot tracked dirt at level start:
```ts
target.trackedDirtIds = [...]
```

Do not let spawned dirt expand the denominator mid-run.

---

## 12. Suggested Layout Families

To avoid building 20 fully unique maps from scratch, use reusable layout families:

### Family A — `Cluster Start`
- dense opening cluster
- short route
- onboarding / relief use

### Family B — `Split Path`
- two visible lanes
- mixed targets
- route choice

### Family C — `Single Gate`
- one blocked subzone
- one clear unlock moment

### Family D — `Restore Anchor`
- one obvious restore object at far end
- blockers around it

### Family E — `Area Sweep`
- wider zone
- static tracked dirt
- less object complexity

### Family F — `Mini Finale`
- known systems combined
- larger route
- stronger reward

These six layout families are enough to build World 1 efficiently.

---

## 13. Booster Availability for Expanded Levels

To match the intended non-Archero-like shell:

### Levels 1–3
- booster tray hidden or collapsed

### Levels 4–10
- optional light booster tray allowed
- show only:
  - `+10 Seconds`
  - `Bigger Tank`

### Levels 11–15
- allow:
  - `Wide Nozzle`
  - `Turbo Regen`

### Levels 16–23
- full optional tray allowed
- but still secondary in visual hierarchy

This keeps progression readable and avoids turning pre-level into a build draft.

---

## 14. Acceptance Criteria

This patch is successful when:

### Content
- prototype contains 23 levels total
- World 1 feels like a complete first pack
- progression from Level 1 to 23 is readable

### Difficulty
- no impossible spike before Level 10
- Level 12+ can start using area and soft hazard systems
- Level 23 feels hard but fair

### Economy
- player can afford at least one meaningful early upgrade without excessive grind
- reward pacing remains visible in-level and on result screen

### UX
- home screen progression through a longer world feels motivating
- upgrades have enough level content to matter
- booster use remains optional, not structurally required

---

## 15. Final Decision

### Keep
- one-world focus for prototype
- goal-based structure
- level-by-level complication rollout
- relief levels
- restore as major fantasy payoff
- light progression shell

### Add
- 20 more levels
- complete first-world cadence
- two relief levels
- first static area-target ladder
- first soft hazard ladder
- first world mini-finale

### Reject
- jumping to multiple worlds too early
- adding 20 random hard levels without progression logic
- stacking hazards, area goals, and restore too early
- content expansion without economy/difficulty rhythm

---

## 16. Final Product Shape After This Patch

After this patch, the prototype becomes:

> **a real first-world vertical slice instead of a 3-level mechanic demo**

That is the correct next step for validating:
- campaign flow
- upgrade cadence
- world pacing
- content scalability
- first-world retention potential

---
