# Clean Sweep Rush — Level Tuning Patch
**Patch ID:** `design-patch-v4-levels-onboarding-difficulty-fix`  
**Applies to:** `index.html`, `design-doc.md`, `clean_sweep_rush_patch_v2_consolidated.md`, `clean_sweep_rush_patch_v3_regen_tank_gold_feedback.md`  
**Audience:** Game Design, Level Design, Economy, UI/UX, Claude Code  
**Status:** Proposed fix patch  

---

## 1. Patch Goal

This patch fixes the current prototype level set so that it matches the **current product design** instead of an over-tuned challenge prototype.

The problem is not only “numbers are too hard.”  
The bigger problem is that the current 3-level stack introduces **too many systems too early**.

The design foundation says the product should be:
- **level-based**
- built around **explicit goals**
- have a **fast entry**
- add **one complication at a time**
- preserve a readable **almost won** fail state
- keep **early tank pressure forgiving**
- avoid early complexity that blocks the first satisfying payoff. fileciteturn30file8 fileciteturn31file1 fileciteturn31file2

Current implementation front-loads too much:
- Level 1 already contains many dirt nodes despite only one simple target,
- Level 2 already mixes multi-targets, lock/unlock, hidden content, and a power-up,
- Level 3 stacks **area target + restore target + two locks + sludge unlock + recontamination hazard + power-ups** under a short timer. fileciteturn31file0

That does not match the intended onboarding curve from the design docs. fileciteturn30file8 fileciteturn31file1

---

## 2. Root Cause Summary

## 2.1. Too many mechanics in the first 3 levels
The design calls for early levels to be:
- immediate,
- low-friction,
- easy to read,
- with new complications introduced one by one. fileciteturn30file8 fileciteturn31file1

But current prototype levels are:

### Current Level 1
- timer 45s
- target: 4 pots
- plus 12 mud nodes on the map. fileciteturn31file0

### Current Level 2
- timer 40s
- mud target + bench target
- gate mud
- locked mud
- locked bench
- leaves clutter
- turbo power-up. fileciteturn31file0

### Current Level 3
- timer 35s
- clean area threshold
- restore birdbath
- two locks
- sludge behind lock
- recontamination vent
- two power-ups. fileciteturn31file0

That is too steep for the intended casual onboarding.

## 2.2. Level 3 has moving-goal difficulty
The current `clean_area` target calculates progress from **all dirt nodes in the area**, while the vent hazard can spawn additional mud in the same area. That makes the denominator unstable and can turn the objective into a moving target during the run. This is not aligned with the intended “simple, readable, almost won” fail pattern. fileciteturn31file0 fileciteturn31file1

## 2.3. Early tank pressure should be forgiving, but level density is not
Patch v3 explicitly says early game should:
- make reserve lock rare,
- feel forgiving,
- teach “press to spray, release to recover.” fileciteturn31file2

The current early level stack creates difficulty mostly by system stacking, not by readable mastery progression.

---

## 3. Level Design Principles to Reapply

The prototype should return to these rules:

### 3.1. One new complication at a time
Do not combine in one level:
- multi-targets
- area threshold
- restore chain
- lock/unlock
- hazards
- power-up reliance

until each has been taught separately. fileciteturn31file1

### 3.2. Phase A must be very fast
Every level must open with:
- one obvious clean action
- one obvious reward
- one obvious progress update
within the first 2–3 seconds. fileciteturn30file8

### 3.3. Early levels should not require boosters
Boosters are support valves, not mandatory onboarding tools. The shell keeps them, but early levels should be clearable without spending. fileciteturn31file1

### 3.4. Timer is still the main fail source
The tank should create **time pressure**, not become the primary reason the player fails in Level 1–3. fileciteturn31file2

---

## 4. New Onboarding Structure for Prototype

This patch redefines the first 3 levels as follows:

### Level 1 = Learn cleaning + single target type
Teach:
- hold to spray
- release to regen
- clean an object target
- immediate gold feedback

Do not teach:
- gates
- hazards
- area thresholds
- restore
- power-up reliance

### Level 2 = Add second target family, no lock
Teach:
- mixed target reading
- simple prioritization
- broader cleaning coverage

Do not teach:
- hidden content
- lock/unlock
- hazard management
- restore chain

### Level 3 = Teach one structural complication only
Teach **either**:
- gate/unlock  
**or**
- restore  
but not both together.

Area threshold and respawn hazards should move later.

---

## 5. Level-by-Level Fixes

## 5.1. Level 1 — `First Wash`

### Current issue
Current Level 1 is visually busier than needed and asks for 4 pots while also placing 12 mud patches in the arena. fileciteturn31file0

### New design
**Goal:** extremely safe tutorial win.

### Changes
- increase timer from **45s -> 60s**
- reduce pot target from **4 -> 3**
- reduce background mud from **12 -> 6**
- place 2 mud patches and 1 pot in the immediate opening cone
- keep remaining dirt as optional bonus cleanup, not objective complexity
- no booster UI shown before level
- no failure expectation from reserve lock

### Rationale
Level 1 should prove:
- cleaning feels good
- gold feedback is visible
- one target card is readable
- the player wins on first attempt unless they fully disengage

---

## 5.2. Level 2 — `Garden Path`

### Current issue
Current Level 2 already mixes:
- dirt target
- bench target
- gate mud
- locked bench
- hidden mud
- leaves clutter
- turbo power-up. fileciteturn31file0

That is too many systems for second level.

### New design
**Goal:** teach multi-target reading without hidden dependencies.

### Changes
- increase timer from **40s -> 55s**
- keep two target families, but simplify them to:
  - `clean_dirt target_mud x4`
  - `clean_object bench x1`
- remove gate lock
- remove locked bench
- remove locked mud behind gate
- remove turbo power-up
- keep leaves only as non-target scenic clutter or remove 50% of them
- cluster first two mud targets near start, bench visible in first screen, remaining mud farther away

### Rationale
Level 2 should teach:
- “I can read two goals”
- “I can choose what to do first”
without adding hidden unlock logic yet.

---

## 5.3. Level 3 — `Backyard Blitz`

### Current issue
Current Level 3 stacks:
- area threshold
- restore target
- two gates
- sludge cluster
- hazard vent
- two power-ups
- short 35s timer. fileciteturn31file0

This is the main cause of “levels are impossible.”

### New design
**Goal:** teach one structural escalation, not five.

### Recommended version for prototype
Use Level 3 to teach **restore**, because restore is core to the product fantasy. fileciteturn30file8

### Changes
- increase timer from **35s -> 60s**
- remove `clean_area` target entirely
- keep only:
  - `restore_object birdbath x1`
- reduce level structure to:
  - 2 blocker mud nodes
  - 2 sludge nodes near birdbath
  - 1 simple lock
- remove second lock
- remove hazard vent
- remove magnet power-up
- optional: keep 1 turbo power-up as a celebratory assist, but not required

### Rationale
Level 3 then teaches:
1. clear blockers
2. unlock access
3. clean around restore object
4. restore it
5. win

That is readable and on-theme.

---

## 6. Postpone These Mechanics

These mechanics should move later in the world:

### Move to Level 4 or 5
- `clean_area` threshold target

### Move to Level 5 or 6
- first hazard
- first recontamination behavior

### Move to Level 6+
- multi-stage lock chains
- area threshold + restore in the same level
- power-up stacking
- respawned dirt under time pressure

This matches the “single complication, then combination later” rule. fileciteturn31file1

---

## 7. Specific Fix for Area Targets

If `clean_area` remains in the prototype at all, it must be fixed.

### Problem
Current area progress uses all dirt currently in the area. If hazards spawn additional dirt into the area, total required cleanliness changes mid-run. fileciteturn31file0

### Required fix
For any `clean_area` level, compute:
- `areaTargetInitialTotal` at level start
- progress against **initial tracked dirt only**

### Alternative safe rule
Respawned dirt from hazards must have:
- `countsForAreaTarget = false`

### Recommendation
For prototype:
- simplest fix is to **remove area target from Level 3 entirely**
- later, reintroduce it with a static denominator

---

## 8. Booster Presentation Fix for Early Levels

To match the intended shell:

### Levels 1–3
- do **not** present a mandatory booster choice screen
- if intro screen remains, show:
  - level title
  - goals
  - timer
  - `Start`
- boosters can remain hidden or collapsed under optional help

### Levels 4+
- optional pre-level booster tray can appear
- only after players understand core loop

This avoids the wrong Archero-like reading and preserves clean onboarding. fileciteturn30file8 fileciteturn31file1

---

## 9. Gold and Upgrade Economy Impact

The level fix should also stabilize economy perception.

### Early level economy rules
- Level 1 should always award enough visible Gold to feel meaningful
- Level 2 should reinforce that goals, not random spray spam, are the best source of value
- Level 3 should award a stronger restore payout than basic dirt

### Recommendation
Do not use early difficulty to starve upgrade progression.  
Players should reach their **first real upgrade purchase** after 2–3 successful early levels, not after long failure cycles. This aligns with the light-meta progression model. fileciteturn30file4 fileciteturn31file1

---

## 10. New Difficulty Ladder for Prototype

## 10.1. Level 1
- single target family
- no lock
- no hazard
- no power-up
- guaranteed fast payoff

## 10.2. Level 2
- second target family
- still no lock
- still no hazard
- no mandatory power-up
- simple prioritization

## 10.3. Level 3
- single structural complication
- recommended: restore + one lock
- no area threshold
- no hazard respawn
- no multi-system stack

## 10.4. Level 4+
- introduce area threshold
- later add hazard
- only later combine them

---

## 11. Proposed Replacement Values

## 11.1. Replacement Level Table

| Level | Current Main Issue | New Timer | New Targets | Systems Allowed |
|---|---|---:|---|---|
| 1 | too much non-target clutter | 60s | Pots x3 | clean only |
| 2 | too many systems at once | 55s | Mud x4 + Bench x1 | multi-target only |
| 3 | stacked impossible combination | 60s | Restore Birdbath x1 | one lock + restore |

## 11.2. Systems Matrix

| System | L1 | L2 | L3 |
|---|---|---|---|
| clean object | yes | yes | optional |
| clean dirt target | no | yes | optional blockers only |
| lock/unlock | no | no | yes |
| restore | no | no | yes |
| clean area target | no | no | no |
| hazard | no | no | no |
| power-up required | no | no | no |

---

## 12. Implementation Notes for `index.html`

## 12.1. Update `LEVELS`
Change:
- Level 1 target amount
- Level 2 timer and target composition
- Level 3 timer and target composition

## 12.2. Update `loadLevel(level)`
### Level 1
- remove 50% of current mud nodes
- keep 3 target pots, not 4

### Level 2
- delete gate setup
- delete locked bench
- delete locked mud nodes
- delete turbo power-up
- reduce non-target leaves clutter

### Level 3
- delete `clean_area` usage
- keep only `restore_object`
- remove hazard vent
- remove second lock
- reduce sludge count from 4 to 2
- remove magnet power-up

## 12.3. If area target is reused later
Add field:
```ts
countsForAreaTarget?: boolean
```

And snapshot:
```ts
target.initialTrackedDirt = trackedDirtIdsAtLevelStart
```

---

## 13. QA Acceptance Criteria

The patch is successful when:

### Level 1
- first-time player wins on first or second try without booster
- first visible clean payoff happens in under 3 seconds
- reserve lock almost never causes failure

### Level 2
- player understands two-goal structure
- level is readable without tutorial text wall
- no hidden dependency blocks completion

### Level 3
- player clearly understands what unlocks the restore object
- level can be completed without perfect play
- failure, if any, feels like “almost won,” not “what was I supposed to do?”

### Economy
- player can afford early progress without grind wall
- Gold feedback feels tied to actions and goal completion

---

## 14. Final Decision

### Keep
- level-based structure
- target cards
- timer as primary fail
- water tank as secondary pressure
- gold feedback
- permanent upgrades
- boosters as optional support

### Change
- rebuild first 3 levels as onboarding ladder
- remove stacked mechanics from Level 2 and 3
- postpone area target and hazard respawn
- make restore the first real escalation
- make area target static when reintroduced later

### Reject
- Level 2 hidden-content gate complexity
- Level 3 area target + restore + vent + dual locks combo
- early reliance on booster support
- moving-goal denominator for area-clean objectives

---

## 15. Final Product Shape After This Patch

After this patch, the prototype again matches the intended product shape:

> **a readable, level-based restoration puzzle with a soft onboarding curve, fast early payoff, one complication at a time, and fair near-win tension**

That is the correct direction for the current design.

---
