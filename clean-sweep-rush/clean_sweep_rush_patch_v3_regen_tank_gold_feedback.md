# Clean Sweep Rush — Patch v3
**Patch ID:** `design-patch-v3-regen-tank-bottom-bar-gold-feedback`  
**Applies to:** `clean_sweep_rush_design_doc_en.md` and `clean_sweep_rush_patch_v2_consolidated.md`  
**Audience:** Product, Game Design, UI/UX, Economy, Claude Code  
**Status:** Working patch  

---

## 1. Patch Goal

This patch corrects and extends the current resource/UI design in five areas:

1. **Water Tank now regenerates automatically**
2. **Water is consumed only while the player is actively holding tap / press**
3. **Tank has a visible reserve threshold (20%)**
4. **If the player drains into reserve, spray is locked until the full tank regenerates**
5. **Gold earnings become visible in moment-to-moment gameplay through floating pickups and fly-to-HUD feedback**

This patch preserves the core structure of the product:
- level-based
- explicit goals
- timer-driven
- near-win tension
- booster support
- light meta

It does **not** change the product into a simulator.

---

## 2. Design Rationale

The original All in Hole adaptation works because it keeps:
- readable fantasy
- goal-based levels
- timer pressure
- simple fail states
- booster-based relief
- light meta and session shell

This patch strengthens that direction by making water:
- more legible
- more tactile
- more skill-expressive
- less like hidden passive friction
- more compatible with one-thumb portrait play

The updated tank should feel like a **moment-to-moment pressure valve**, not a background tax.

The updated gold feedback supports:
- stronger reward readability
- more satisfying action loop
- better perceived value of cleaning
- clearer connection between play and progression

---

## 3. Water Tank v2 — Final Resource Model

## 3.1. Core Rule

The water tank now behaves as a **regenerating active-use resource**.

### Rules
- Water is consumed **only while the player is holding tap / press to spray**
- Water does **not** drain while moving, aiming, or vacuuming
- Water automatically regenerates while the player is **not spraying**
- Regeneration is continuous unless the tank is in penalty lock
- Tank includes a clearly marked **reserve zone**
- Reserve zone is set to **20% of total tank capacity** by default

This means the player actively controls water usage through input discipline.

## 3.2. Input Rule

Spray is now a **hold action**:
- press and hold to spray
- release to stop consuming water
- move while spraying if control scheme allows
- recommended MVP behavior: move + hold spray works smoothly with one-thumb drag/press interaction

### Design intent
This creates a more deliberate loop:
`move -> hold to clean -> release -> reposition -> hold again`

It also creates skill expression without making the game feel deep or sim-like.

---

## 4. Water Regeneration Rules

## 4.1. Normal Regeneration

When the player is **not spraying**, the tank regenerates automatically.

### Baseline behavior
- regeneration starts immediately after spray stops
- regeneration is smooth and readable
- no manual refill action is required in the baseline system
- refill stations may still exist later as optional speed-up or event modifiers, but baseline tank no longer depends on them

## 4.2. Regeneration State

Tank has 3 practical states:

### A. Healthy Zone
From 100% down to reserve threshold.
- spray available
- normal play
- no warning

### B. Reserve Zone
Bottom 20% of the tank.
- strong warning visuals
- player may still spend into it
- entering reserve is risky
- if reserve is fully triggered, penalty lock begins

### C. Locked Recharge State
If player drains the tank into the reserve failure state:
- spray is disabled
- player must wait until the tank recharges to **100%**
- spray cannot resume at 30%, 50%, or 80%
- full recharge is mandatory as the penalty

This is the cost of reckless overuse.

---

## 5. Reserve System

## 5.1. Reserve Definition

Reserve is a protected danger band at the bottom of the tank.

### Default tuning
- reserve threshold = **20% of total capacity**

### Visual treatment
- main tank fill uses normal color
- reserve zone is marked in a contrasting color
- threshold marker is always visible
- low-water warning begins before lock

## 5.2. Reserve Failure Rule

When the player crosses the reserve threshold and fully depletes usable water:
- spray is disabled
- tank enters `Locked Recharge`
- player must wait until tank returns to 100%
- only then may spraying resume

### Why this is better than hard fail
This creates:
- tension
- route timing
- punishment for panic-spraying
- readable self-correcting downtime

Without causing an immediate fail screen.

The timer remains the main fail condition.  
The tank creates time pressure and mistake punishment.

---

## 6. Water Tuning Targets

## 6.1. Core Feel Target

Players should feel:
- safe when they burst-spray intelligently
- punished when they hold spray too greedily
- rewarded for rhythm and pacing
- in control of their own resource usage

## 6.2. Early Game
- large enough tank that reserve lock is rare
- regeneration feels forgiving
- player learns “press to spray, release to recover”

## 6.3. Mid Game
- reserve becomes meaningful
- more targets and denser dirt create pressure
- bad spray discipline creates lost time

## 6.4. Late Game
- reserve lock becomes part of endgame tension
- higher target density + more routing makes resource timing meaningful
- boosters/upgrades help recover efficiency

---

## 7. Recommended Baseline Numbers

These are balancing placeholders, not final production values.

### Baseline Tank
- `tank_capacity = 100 units`

### Default Reserve
- `reserve_threshold = 20 units` (20%)

### Spray Drain
- `drain_while_holding = 14 units/sec`

### Passive Regen
- `regen_while_not_spraying = 10 units/sec`

### Locked Recharge Regen
- `regen_when_locked = 12 units/sec`

### Low Water Warning
- warning pulse begins at `30%`

### Reserve Entry Warning
- critical warning at `20%`

These numbers create:
- meaningful burst usage
- frequent but manageable low-water decisions
- visible punishment if player commits too long

---

## 8. Design Consequences for Difficulty

This tank model changes difficulty in a clean way:

### Before
Water was mostly route friction.

### After
Water becomes:
- **input rhythm pressure**
- **micro-decision pressure**
- **endgame punishment amplifier**
- **time-loss risk**

This is better aligned with a level-based casual game because it adds tension without requiring more map objects or refill path complexity.

### Difficulty can now scale through:
- more targets
- denser dirt clusters
- longer cleanup windows per target
- more hazards that discourage continuous spraying
- higher pressure to stop-and-go efficiently

---

## 9. Water Tank UI Update

## 9.1. Final Placement

The water tank should now be:
- **visible at the bottom of the gameplay screen**
- **horizontal**
- centered or slightly above bottom-safe zone
- always readable during active gameplay

This replaces the previous top-corner presentation direction.

## 9.2. Why Bottom Placement Is Better

Bottom placement works because:
- it is close to the player’s thumb interaction zone
- it reinforces the “hold to spray” loop
- it reads like a stamina/active-use resource
- it separates water from top-HUD economy/timer information

## 9.3. Bottom Tank Composition

Recommended structure:

```text
[ Spray Icon ] [==========------|====]
                main fill      reserve
```

### Elements
- spray icon on left
- wide horizontal fill bar
- reserve segment visually separated
- animated fill loss while holding
- animated regen while idle
- flashing state during low water
- lock icon overlay during forced full recharge

## 9.4. Visual States

### Normal
- stable fill
- no warning

### Low Water
- subtle pulse
- yellow/orange state

### Reserve
- stronger pulse
- red reserve segment
- warning SFX optional

### Locked Recharge
- bar grayed with fill rebuilding
- lock icon
- tooltip/text like `Recharge to Full`

---

## 10. Boosters Update for Regenerating Tank

Boosters should be updated to reflect the new water system.

## 10.1. Keep
- `+10 Seconds`
- `Wide Nozzle`
- `Pressure Boost`
- `Target Scanner`
- `Freeze Time`
- `Power Burst`
- `Hazard Shield`
- `Foam Bomb`
- `Instant Restore`

## 10.2. Update Water-Related Boosters

### Replace `Fast Refill`
Old concept depended on refill points.

### New version: `Turbo Regen`
For one level:
- increases passive water regeneration speed
- reduces lock-recharge downtime

### Replace `Bigger Tank`
Keep this as valid.

**New behavior:**  
larger tank also increases reserve size proportionally, but gives more usable water before lock risk.

### Add `Reserve Shield`
Optional later-game booster:
- first reserve break in level does not trigger lock
- instead restores to reserve threshold once

This is a strong late-game monetization/safety tool.

---

## 11. Permanent Upgrades Update

The permanent upgrade system remains valid, but one lane must be reframed.

## 11.1. Keep These Lanes
- Spray Power
- Tank Capacity
- Spray Width
- Move Speed

## 11.2. Replace `Refill Speed` with `Regen Speed`

Because the core tank now regenerates automatically, the safer permanent lane is:

### `Regen Speed`
Effect:
- increases passive water regeneration speed
- shortens forced full-recharge downtime after reserve lock

This is much more compatible with the current design than refill-station speed.

## 11.3. Updated Safe Upgrade Lanes
1. Spray Power
2. Tank Capacity
3. Regen Speed
4. Spray Width
5. Move Speed

---

## 12. Gold Economy Update

## 12.1. Currency Naming Change

For gameplay readability, the soft currency should now be called:

> **Gold**

This is clearer, shorter, and easier to read in fast in-level feedback than `Wash Coins`.

`Wash Coins` can remain an internal placeholder if needed, but player-facing UI should use `Gold`.

## 12.2. Gold Sources During Gameplay

Gold should now be earned visibly during active level play from:
- cleaning dirt clusters
- completing mini-goals / sub-goals on the map
- clearing target objects
- restoring key objects
- optional breakables / bonus pickups

This creates a stronger “I am earning while I clean” feeling.

---

## 13. Gold Feedback — Moment-to-Moment

## 13.1. New Feedback Rule

During gameplay, when the player earns gold:
- a small gold number appears near the cleaned object / reward source
- the number floats upward briefly
- then a gold chip/icon or number streak flies toward the top-bar gold counter
- the top-bar gold total increments visibly

This must be readable, lightweight, and frequent.

## 13.2. Example Micro-Reward Values

Recommended small in-level values:
- dirt patch cleaned: `+1`
- medium cluster: `+2`
- target object cleaned: `+3`
- restore interaction: `+5`
- mini-goal complete: `+8`
- optional bonus item: `+10`

These values are intentionally small and frequent.

## 13.3. Why This Matters

This supports:
- reward readability
- action-value clarity
- satisfying progress feedback
- stronger retention through visible gain
- stronger conversion into upgrades

The player should never feel that gold only exists on the end screen.

---

## 14. Gold Feedback UX Rules

## 14.1. Floating Number Rules
- appear near reward source
- short lifetime
- no clutter stacking
- combine nearby pickups when needed

## 14.2. Fly-to-HUD Rules
- each reward does not need a fully separate particle
- small rewards can batch every 0.3–0.5 sec
- top-bar gold counter should pulse on receipt

## 14.3. Anti-Clutter Rules
To avoid visual spam:
- batch repeated +1 rewards
- suppress extra VFX during very dense spray moments
- prioritize target/object rewards over tiny dirt ticks
- use stronger feedback for goal completion than for basic dirt

---

## 15. Top HUD Gold Presentation

## 15.1. Final Rule

Gold remains in the **top bar**, because it belongs to session/meta economy.

### Top Bar Should Show
- timer
- goal cards
- total gold
- lives
- optional premium placeholder

### Bottom of Screen Should Show
- horizontal water tank
- temporary contextual booster buttons if active

This creates a clean split:
- **Top = progression / economy / goals**
- **Bottom = active-use resource / moment-to-moment control**

---

## 16. Goal Rewards on Map

## 16.1. On-Map Goal Reward Feedback

When the player completes an explicit map goal:
- show stronger gold feedback than normal dirt cleaning
- use a goal-complete burst
- display total goal payout
- fly reward to top bar

Example:
```text
Goal Complete!
Clean 3 Trucks
+12 Gold
```

Then:
- coins/number fly to top HUD
- goal card checks off
- player gets immediate value confirmation

## 16.2. Why Goal Rewards Matter
This better links:
- explicit goals
- level strategy
- economy gain

That reinforces the goal-based loop from the original shell.

---

## 17. Updated Portrait HUD Layout

## 17.1. Top HUD
- timer at top center
- goal cards under timer
- gold at top right
- lives at top left or top right cluster
- pause/settings top left

## 17.2. Bottom HUD
- centered horizontal water tank
- reserve marker visible at all times
- lock state visible clearly
- optional contextual booster buttons placed above or beside tank
- do not overlap thumb comfort zone too heavily

## 17.3. Spatial Rule
The bottom tank should feel like:
- the player’s active stamina/resource strip
- not a hidden stat
- not a tiny utility meter

---

## 18. Updated Fail / Near-Fail Logic

## 18.1. Main Fail
- timer expires

## 18.2. Secondary Resource Punishment
- overusing water triggers reserve lock
- reserve lock costs time
- lost time can push player into near-fail

This is preferable to immediate fail because it creates more monetizable and readable recovery moments.

## 18.3. Continue Offer Logic
If player fails shortly after one or more reserve locks:
- prioritize offers like `+15 sec`
- `Turbo Regen`
- `Reserve Shield`
- `Power Burst`

This connects the failure reason to a meaningful rescue tool.

---

## 19. Economy / Upgrade Impact

## 19.1. Gold Should Support
- permanent upgrades
- some boosters
- event progression sinks
- light retry support if desired

## 19.2. Most Valuable Upgrade Lanes After Patch

### Early Game
1. Spray Power
2. Tank Capacity
3. Spray Width

### Mid Game
1. Regen Speed
2. Tank Capacity
3. Spray Width

### Late Game
1. Regen Speed
2. Move Speed
3. Spray Power

The reserve mechanic makes `Regen Speed` strategically important and easy to understand.

---

## 20. Claude Code Implementation Notes

## 20.1. Revised Water State

```ts
type WaterTankState = {
  capacity: number;
  current: number;
  reserveThreshold: number; // e.g. 20% of capacity
  drainPerSecondWhileSpraying: number;
  regenPerSecondWhileIdle: number;
  regenPerSecondWhileLocked: number;
  isSpraying: boolean;
  isLockedRecharge: boolean;
};
```

## 20.2. Spray Rule

```ts
waterDrainsOnlyWhen = "hold_input_active";
```

## 20.3. Lock Rule

```ts
if (currentWater <= 0) {
  isLockedRecharge = true;
  sprayEnabled = false;
}

if (isLockedRecharge && currentWater >= capacity) {
  isLockedRecharge = false;
  sprayEnabled = true;
}
```

## 20.4. Idle Regen Rule

```ts
if (!isSpraying && !isLockedRecharge) {
  currentWater += regenPerSecondWhileIdle * dt;
}
```

## 20.5. Locked Regen Rule

```ts
if (isLockedRecharge) {
  currentWater += regenPerSecondWhileLocked * dt;
}
```

## 20.6. Gold Reward Feedback

```ts
type GoldRewardEvent = {
  sourceType: "dirt" | "target_object" | "restore" | "goal_complete" | "bonus_pickup";
  amount: number;
  worldPosition: Vec3;
};

onGoldReward(event):
  spawnFloatingNumber(event.amount, event.worldPosition);
  queueFlyToHud(event.amount, topHudGoldCounter);
  wallet.gold += event.amount;
```

---

## 21. Final Decision

### Keep
- level-based shell
- target cards
- timer as main fail source
- boosters
- light meta
- portrait layout
- top-bar economy

### Change
- water now regenerates automatically
- water drains only on hold-to-spray
- reserve threshold added
- reserve depletion locks spray until full recharge
- tank moves to bottom-center horizontal HUD
- gold is earned visibly during gameplay
- floating gold numbers fly to top-bar gold counter
- `Refill Speed` lane becomes `Regen Speed`
- player-facing soft currency becomes `Gold`

### Reject
- passive constant drain
- hidden water usage
- refill-station dependency as baseline
- top-corner tank UI
- economy feedback only on end screen

---

## 22. Final Product Shape After Patch

The game is now:

> **a portrait-first, level-based restoration puzzle where the player actively controls spray usage, manages a regenerating water tank with a reserve lock penalty, and sees gold earned directly from cleaning actions and goals**

This is a stronger moment-to-moment design because:
- the player has more agency over resource spend
- punishment is readable
- reward feedback is more satisfying
- UI roles are cleaner
- progression is more tightly connected to gameplay

---
