# PowerWash Hole / Clean Sweep Rush
**Casual F2P Mobile Design Document**  
**Version:** 0.2  
**Language:** English  
**Audience:** Product, Game Design, Economy, Level Design, UA, Claude Code  
**Status:** Concept / Pre-production  

---

## 1. Executive Summary

This document proposes a **casual F2P mobile game** built by adapting the **All in Hole** structural model and replacing the black-hole fantasy with a **cleaning / restoration fantasy**.

The core strategic bet is:

> Do **not** make a mobile port of a PC powerwash simulator.  
> Make a **goal-based cleaning puzzle game** with the shell of a proven casual F2P level product.

The recommended product is:

- **easy to understand in 1–3 seconds**
- built around **before/after transformation**
- structured as **short levels with explicit goals**
- monetized through **boosters, lives, revives, streaks, and events**
- supported by a **light restoration meta** between levels

This should be treated as:

**cleaning fantasy**  
+ **goal-based collect / route puzzle**  
+ **monetizable casual session shell**

---

## 2. Strategic Thesis

## 2.1. Why this concept is attractive

A cleaning / restore game fits current market behavior because it combines:

- strong visual payoff
- low cognitive friction
- strong short-form / ad readability
- obvious level goals
- natural room for "almost won" monetization
- broad casual audience appeal

The strongest public signal from the supplied trend report is that **before/after cleanup / restore** is one of the best bridges between **product, content, and performance marketing**. The same report rates **satisfying micro-payoff / ASMR** and **teaser-to-reward** as highly effective for shorts and ad creatives, while **automation chains + base expansion** are useful but weaker as a first-hook ad promise.  
See: `raport_trendy_gamingowe_Q1_2026.pdf` and especially the mechanics ranking and strategic conclusions.  
References for product direction: `all_in_hole_schema.md`, sections on preserving the level/meta shell and replacing only fantasy/input.  
Public store benchmarks: All in Hole on Google Play and Clean It on the App Store.

## 2.2. Core conclusion

Yes: the **All in Hole** model can be adapted to a cleaning theme.

But only if we keep the following distinction:

- **Keep** the level shell, time pressure, targets, pacing, fail/retry economy, boosters, lives, revive moments, events, and light social shell.
- **Replace** the fantasy, objects, gating logic, avatar, and audiovisual feel.
- **Avoid** building a heavy simulator with precise hose aiming and long sandbox sessions.

The best version is not "mobile PowerWash Simulator".

The best version is:

> **All in Hole as a cleaning / restoration puzzle with transformation fantasy.**

---

## 3. Product Definition

## 3.1. Working title

Possible internal codenames:

- **PowerWash Hole**
- **Clean Sweep Rush**
- **Restore Rush**
- **Wash & Restore**
- **Clean Core**

Recommended working direction:
**Clean Sweep Rush** for a broader casual market tone  
or  
**PowerWash Hole** if we deliberately want a more literal pitch during internal development.

## 3.2. One-sentence pitch

A level-based casual F2P mobile game where the player controls a cleaning bot, washes and restores dirty locations under time pressure, completes explicit level goals, uses boosters, and rebuilds a brighter world between levels.

## 3.3. Elevator pitch

`[NEW TITLE]` is a casual mobile game where the player controls a compact cleaning machine and completes short level objectives by washing grime, vacuuming sludge, restoring broken objects, and managing route and priority under a timer. The game uses a proven casual shell: boosters, lives, revives, streaks, events, and light restoration meta progression.

---

## 4. Market Interpretation

## 4.1. What the supplied internal/public materials imply

The uploaded **All in Hole schema** makes a very strong structural argument:

- the original success pattern is **not "a game about a hole"**
- it is a **goal-based level puzzle**
- wrapped in a **casual F2P session/meta shell**
- where the fantasy layer is replaceable

That means the "hole" is only the wrapper.  
The actual reusable product formula is:

- readable input fantasy
- target-based levels
- timer
- pacing with late tension
- boosters
- revive economy
- lives
- streaks
- events
- light meta

The trend report supports cleaning even more strongly than automation-heavy gameplay:
- **before/after cleanup / restore** is rated as highly visual, high YouTube potential, and very high ad potential
- **satisfying transformation** works even without narration
- **teaser-to-reward** is a strong bridge between problem and visual payoff
- **automation chains + base expansion** are interesting, but weaker as the lead promise and better as meta/support

## 4.2. Public benchmark: All in Hole

Public store messaging for **All in Hole** shows that its current shell already includes:
- satisfying puzzle levels
- growth during the level
- boosts
- teams / hearts / coins
- tournaments / challenges
- Treasure Pass
- frequent level updates

This confirms the adaptation should preserve:
- level structure
- live ops wrapper
- utility economy
- event cadence
- light social structure

## 4.3. Public benchmark: Clean It

Public store messaging and IAP structure for **Clean It** confirm that cleaning fantasy can support:
- cleanup + light management fantasy
- permanent utility IAPs
- no-ads sales
- bot utility
- speed / mobility utility
- broad casual readability

This is useful not as a direct gameplay template, but as evidence that:
- cleanup is a sellable mobile fantasy
- players accept utility-driven monetization around cleaning
- cleaning games do not need realism to work

---

## 5. Product Pillars

## 5.1. Pillar 1 – Readable Cleaning Fantasy
The player must instantly understand:
- what is dirty
- what can be cleaned now
- what is locked
- what the payoff will be

## 5.2. Pillar 2 – Goal-Based Levels, Not Sandbox
Each level has clear objectives.
The player is not just "washing everything".  
They are solving a timed routing / priority challenge.

## 5.3. Pillar 3 – Frequent Micro-Payoff
Every 5–15 seconds, the player should get:
- a clean reveal
- a target completion pulse
- an unlocked path
- a restored object
- a visible contrast moment

## 5.4. Pillar 4 – Tense Endgame
Late-level pressure is essential.
The best monetization and retry moments come from:
- 1–2 missing targets
- little time left
- visible almost-win state

## 5.5. Pillar 5 – Shell-Driven Retention
The long-term product value comes from:
- lives
- boosters
- revives
- streaks
- chests
- passes
- events
- light social systems

## 5.6. Pillar 6 – Transformation Meta
The game should not end emotionally at level completion.
Each win should also improve a hub/world through:
- restoration
- decoration
- reactivation
- world brightening

---

## 6. Core Fantasy

## 6.1. Recommended fantasy framing

The player controls a **compact cleaning rover / wash bot / sludge vacuum drone**.

Why this is better than a realistic pressure-washer:
- easier one-thumb input
- closer to All in Hole movement language
- easier spatial readability
- easier to gate with power tiers
- more flexible for power-ups
- more scalable for casual content and UA

## 6.2. Emotional fantasy

The fantasy is not "being a contractor with a hose".

It is:

- removing mess
- bringing order back
- restoring broken environments
- making ugly areas beautiful
- mastering a tool that becomes more capable

The emotional verbs are:
- clean
- reveal
- unblock
- restore
- save
- brighten
- fix

---

## 7. High-Level Gameplay Loop

## 7.1. Session loop
`open app -> claim rewards -> play next level -> win/fail -> reward/continue -> event/meta progress -> play next level`

## 7.2. Level loop
`read targets -> move through arena -> clean easy targets -> unlock or power up -> prioritize remaining goals -> finish before timer`

## 7.3. Moment-to-moment loop
`move -> auto-clean / auto-vacuum -> dirt meter drops -> target progress increases -> route opens -> next decision appears`

---

## 8. Mapping the All in Hole Structure to Cleaning

## 8.1. What stays
From the uploaded All in Hole schema, the following should remain almost intact:

- level-based structure
- explicit target cards
- timer
- fail state
- 3-phase pacing
- pre-level boosters
- in-level boosters
- revive / continue moments
- lives
- streak rewards
- bonus/relief levels
- event wrapper
- social-light features
- light long-term meta

## 8.2. What changes
Replace:

- **black hole** -> **cleaning rover / wash bot**
- **swallowing** -> **washing / vacuuming / dissolving grime**
- **size growth** -> **power growth / nozzle width / detergent state / tank capacity**
- **edible objects** -> **cleanable dirt classes / clutter / restore targets**
- **size gating** -> **dirt hardness gating / lock gating / contamination gating**

## 8.3. Design implication
This is not a reskin.  
It is a **mechanical remap of the same shell**.

The shell survives if the new verbs still support:
- fast start
- target clarity
- route optimization
- late tension
- utility booster use
- clean fail/retry economy

---

## 9. Camera, Controls, and Input

## 9.1. Camera
Recommended:
- fixed 3/4 top-down or isometric camera
- one arena per level
- no free camera rotation
- stable framing for quick readability

## 9.2. Controls
- drag to move
- cleaner auto-washes within a cone / radius
- sludge auto-vacuums within range
- boosters on tap buttons
- optional hold mechanic only for advanced dirty surfaces

## 9.3. Design target
The player should feel productive immediately.
The first clean reveal should happen within **2–3 seconds** of first touch.

---

## 10. Level Structure

## 10.1. Definition
A level is a small arena with:
- a timer
- 1–3 target cards
- several dirt/object families
- blocked and open subzones
- at least one routing choice
- one visible finish challenge

## 10.2. Level phases

### Phase A – Fast Entry
The player immediately cleans:
- low-resistance dirt
- an obvious target object
- a visually satisfying patch

Goal:
- instant satisfaction
- no friction in first seconds

### Phase B – Routing and Priority
The level introduces:
- locked zones
- heavier grime
- restore actions
- hazard positioning
- target tradeoffs

Goal:
- turn simple cleaning into light puzzle play

### Phase C – End Tension
The player has:
- limited time left
- 1–2 incomplete targets
- a clear route or risky choice

Goal:
- create "almost won" emotional state
- support continue / booster conversion

---

## 11. Objective System

## 11.1. Why explicit targets matter
Targets make cleaning more than soothing interaction.
They convert a passive fantasy into a monetizable casual loop.

Without targets, the game becomes too sandbox-like and weaker for:
- fail states
- retry loops
- revive offers
- level economy
- event task structure

## 11.2. Target card model
Each level displays 1–3 target cards at the top of the screen.

Examples:
- Clean 4 food stands
- Remove 8 oil puddles
- Restore 2 generators
- Wash 3 delivery trucks
- Clean Sector A to 80%

## 11.3. Goal types

### A. Clean Target
Clean a specific number of target objects.
Examples:
- clean 5 cars
- wash 6 benches

### B. Dirt-Class Target
Remove a specific class of dirt.
Examples:
- remove 10 sludge pools
- clean 5 graffiti walls

### C. Restore Target
Clean first, then reactivate / repair.
Examples:
- wash solar panel then reconnect it
- clean generator then turn it on

### D. Sequence Target
Goals must be completed in order.
Examples:
- unblock pipe -> wash floor -> restore fountain

### E. Rescue Target
Clear dirt or debris to free a trapped object or NPC.
Examples:
- clean path to maintenance drone
- remove sludge around trapped cat

### F. Area Threshold Target
Reach a percentage of cleanliness in a sector.
Examples:
- 75% clean in Sector A
- 90% clean in Sector B

## 11.4. Difficulty mix recommendation
Early game:
- 1–2 simple clean goals
- no sequencing
- minimal hazards

Mid game:
- 2–3 mixed target cards
- 1 unlock or restore dependency
- more meaningful route choices

Late game:
- tighter timer
- mixed dirt families
- more nested dependencies
- stronger end-level tension

---

## 12. Cleaning Mechanics

## 12.1. Core verbs
Recommended base verbs:
- **spray** – washes light/medium dirt
- **vacuum** – removes sludge / loose debris
- **restore** – activates object after cleaning

Optional later verb:
- **foam** – a special treatment for heavy dirt

MVP recommendation:
- keep only `spray + vacuum + restore`
- treat `foam` as a booster or advanced unlock

## 12.2. Dirt classes
Example dirt families:
- `dust` – very light
- `mud` – standard
- `sludge` – thicker, better with vacuum
- `oil` – resistant and hazardous
- `rust` – clean + restore combo
- `graffiti` – highly satisfying target layer
- `toxic residue` – requires shield or deactivation

## 12.3. Gating logic
Equivalent of "small objects first, bigger later":
- light dirt can be cleaned immediately
- heavy grime needs stronger nozzle / detergent
- some zones need valves or generators activated
- some restore targets only work after nearby dirt is removed

## 12.4. In-level power growth
Instead of the hole growing in size, the cleaning tool grows in capability.

Possible temporary upgrades:
- nozzle width increase
- pressure increase
- tank capacity increase
- detergent overdrive
- sludge magnet
- overclock state after combo

This preserves the feeling of mid-level progression.

---

## 13. Hazards and Failure

## 13.1. Primary fail state
- timer runs out

## 13.2. Secondary fail states
Use lightly and selectively:
- too many hazard hits
- pollution surge triggers if leak is ignored
- fragile object breaks
- restore chain resets

## 13.3. Hazard families
- electric puddles
- toxic gas clouds
- explosive barrels
- slippery oil zones
- recontamination vents
- moving hostile cleaning drones / obstacles

## 13.4. Design rule
Hazards should create:
- readable tension
- route pressure
- late-level decision-making

But they should not destroy the central fantasy of satisfying restoration.

---

## 14. Difficulty Model

## 14.1. Difficulty levers
- number of goals
- number of dirt types
- map size and spread
- number of gated areas
- number of hazards
- tighter time budget
- longer pathing between targets
- fake / distractor objects
- heavier dependency chains

## 14.2. Difficulty philosophy
- introduce one new complication at a time
- provide relief levels regularly
- make challenge levels feel intentional, not random
- avoid late-game chaos inflation

## 14.3. Difficulty shape
Per 10-level block:
- 3 easy / onboarding or relief levels
- 4 standard
- 2 hard
- 1 bonus / economy relief level

---

## 15. Boosters

## 15.1. Pre-level boosters
- `+10 Seconds`
- `Turbo Nozzle` – stronger cleaning power
- `Wide Spray` – larger cleaning radius
- `Smart Foam` – instant heavy dirt reduction
- `Target Compass` – highlights critical route

## 15.2. In-level boosters
- `Freeze Time`
- `Power Burst`
- `Foam Bomb`
- `Hazard Shield`
- `Auto Vacuum`
- `Instant Restore`

## 15.3. Booster function
Boosters are not optional "extra features".
They are key to:
- smoothing frustration
- monetizing near-fails
- supporting tighter level tuning
- increasing session control

---

## 16. Revive and Lives Design

## 16.1. Lives
Recommended starting point:
- 5 lives
- lose 1 on fail
- timed refill
- later social gifting via teams

## 16.2. Continue offers
Fail screen examples:
- continue with +15 sec
- continue with +10 sec + one Foam Bomb
- continue with ad watch
- continue with premium currency

## 16.3. Emotional principle
Continue offers must appear when:
- success is visible
- missing progress is low
- restart feels painful
- the player believes help will solve the problem

---

## 17. Reward and Economy Structure

## 17.1. Currency layers

### Soft currency
Uses:
- boosters
- some retries / supports
- small meta purchases
- chest opening support

### Hard currency
Uses:
- continues
- lives refill
- booster bundles
- event shortcuts
- premium pass
- cosmetics or time-saving packs

### Meta currency
Uses:
- hub restoration
- world repair
- long-term progress tracks

## 17.2. Reward sources
- level wins
- streaks
- daily rewards
- event milestones
- bonus levels
- challenge tracks
- treasure chests
- pass tiers

## 17.3. Monetization philosophy
Monetization should center on:
- utility
- assistance
- pacing
- quality-of-life
- event urgency

Not on:
- harsh permanent blocking
- heavy simulation grind
- core fantasy denial before first payoff

---

## 18. Meta Progression

## 18.1. Main meta
A hub / town / eco-zone gradually transforms from dirty to restored.

This meta should provide:
- visual before/after satisfaction
- reason to keep leveling
- narrative continuity
- more content hooks for screenshots and ads

## 18.2. Meta layers
- restore buildings
- unlock greenery / lighting / decorations
- repair utilities
- restore landmarks
- unlock character/tool skins
- fill collection album of cleaned objects

## 18.3. Why this matters
The hub turns level progression into a broader emotional journey:
`I did not just beat level 42. I made the world cleaner and better.`

---

## 19. Session Shell

## 19.1. Standard session flow
1. Open app
2. Claim daily / event reward
3. See next level CTA
4. Optional booster prompt
5. Play level
6. Win or fail
7. Claim chest / streak / event progress
8. Reveal hub restoration
9. Continue or exit

## 19.2. Session goals
Early onboarding:
- 3–5 minute sessions

Normal play:
- 6–10 minute sessions

Exit reason:
- out of lives
- event checkpoint complete
- chest timer
- next milestone almost reached

---

## 20. Live Ops

## 20.1. Minimal required live ops
- Season pass / Treasure Pass equivalent
- Solo collection event
- Short tournament
- Team contribution event
- Weekend challenge
- Limited thematic world packs

## 20.2. Event examples
- Spring Cleanup Week
- Toxic Harbor Emergency
- Festival Washdown
- Graffiti Crisis
- Sludge Storm Weekend
- Industrial Night Shift

## 20.3. Event task examples
- clean X objects
- finish Y levels without failing
- restore Z generators
- collect event slime
- use no boosters in 3 levels
- finish 5 levels with 20+ sec left

---

## 21. Social Light

## 21.1. Recommended features
- teams / crews
- send hearts / lives
- request hearts
- team leaderboard
- cooperative event chest

## 21.2. Defer for MVP
- live co-op cleaning
- synchronous PvP
- full chat

---

## 22. Content Architecture

## 22.1. World structure
Each world should include:
- 20–40 levels
- 1 clear visual theme
- 1 signature dirt/hazard family
- 1 signature restore action
- 1 new mechanic or complication

## 22.2. Example worlds
1. Backyard Chaos
2. Food Court Meltdown
3. Garage Restore
4. Neon Alley Cleanup
5. Harbor Sludge Zone
6. Theme Park Recovery
7. Laboratory Containment
8. Eco Island Renewal

## 22.3. Example object families
For `Garage Restore`:
- targets: cars, tire racks, tool benches
- dirt: mud, oil, rust
- hazards: sparks, fuel leaks
- restore action: activate garage lift / neon sign

For `Neon Alley Cleanup`:
- targets: signs, windows, delivery scooters
- dirt: graffiti, sludge, trash
- hazards: exposed wires, toxic vents
- restore action: restore street lights

---

## 23. Bonus and Relief Content

## 23.1. Why relief levels matter
The All in Hole schema correctly points out that bonus levels are useful emotional reset valves.

Cleaning version should include:
- very easy "wash everything" levels
- jackpot levels with dense dirt clusters
- coin vacuum levels
- chain-reveal satisfaction levels

## 23.2. Function
Bonus levels:
- reset frustration
- create currency spikes
- make normal levels feel fairer
- support reward loops after fail streaks

---

## 24. UA / Creative Strategy Implications

## 24.1. Best ad hooks for this game
Based on the trend report, the most promising hooks are:
- restore / fix / build
- satisfying before/after
- timer urgency
- noob fail (as funnel hook only)
- teaser-to-reward
- ASMR micro-payoff
- save/rescue framing

## 24.2. Best-performing creative directions for this concept
### A. Dirty -> Clean
Open on ugly mess, end on spotless reveal.

### B. Wrong Clean Order
A character makes a bad choice; player could do it better.

### C. Timed Rescue
"Can you clean this before the leak spreads?"

### D. Hidden Beauty Reveal
Ad cuts before full restoration.

### E. Multi-stage Transform
Trash -> wash -> restore lights -> beautiful final zone

## 24.3. Important caution
Do not make fake ads that promise a different product.
The marketing layer can dramatize the route/timer/restore moments,
but the real game must still deliver:
- cleaning
- transformation
- target completion
- visible payoff

---

## 25. Art Direction

## 25.1. Style
- stylized 3D
- readable silhouettes
- high contrast dirt states
- playful but not childish
- cozy-tech / bright restoration palette

## 25.2. Dirt readability rule
At every moment, the player must visually understand:
- dirty vs clean
- light dirt vs heavy dirt
- interactable vs decorative
- locked vs available

## 25.3. Payoff hierarchy
Strongest visual rewards should come from:
- large clean reveals
- restored lights / color return
- greenery or sparkle return
- completion pulses
- area transformation shots

---

## 26. Audio Direction

## 26.1. Audio goals
- soft but satisfying spray / suction sound
- dirt dissolve audio pulses
- target completion chime
- restore action reward sting
- light ASMR influence without becoming too passive

## 26.2. Why audio matters
The game must feel soothing, but not sleepy.
Audio should support:
- rhythm
- progress
- relief
- momentum

---

## 27. UX / UI Requirements

## 27.1. HUD
Required:
- timer
- target cards
- booster buttons
- progress pulses
- combo / streak indicator
- warning states
- pause/settings

## 27.2. Win screen
Must show:
- goals completed
- time left bonus
- streak progress
- chest/event progress
- hub restoration progress
- CTA to next level

## 27.3. Fail screen
Must show:
- what was missing
- how close the player was
- continue offer
- retry CTA
- optional recommended booster

---

## 28. Recommended MVP Scope

## 28.1. MVP should prove
1. Cleaning fantasy is satisfying in this shell  
2. Target-card level structure works with cleaning verbs  
3. Continue economy converts on near-fails  
4. Hub restoration increases retention  
5. One-thumb controls feel good  

## 28.2. MVP feature set
- 1 control scheme
- 3 worlds
- 60 levels
- 3 dirt classes
- 3 hazard classes
- 5 pre-level boosters
- 4 in-level boosters
- lives
- continue
- basic streak chest
- basic event token track
- simple hub restoration
- 1 bonus level format

## 28.3. Defer after MVP
- advanced social
- complex tool upgrade trees
- narrative layer
- character roster
- co-op
- heavy automation meta

---

## 29. Recommended Prototype Focus

## 29.1. Prototype question 1
Does auto-clean movement feel satisfying enough compared to hole-swallow movement?

## 29.2. Prototype question 2
Does temporary cleaning power growth create the same mid-level arc as hole growth?

## 29.3. Prototype question 3
Can target cards plus timer create enough tension without breaking the soothing fantasy?

## 29.4. Prototype question 4
Do players respond better to:
- direct wash spray
- sludge vacuum
- hybrid wash + vacuum

---

## 30. Claude Code-Oriented Implementation Notes

## 30.1. Core system modules
Claude Code should think in the following modules:

- `LevelDefinition`
- `TargetDefinition`
- `DirtSystem`
- `CleanerController`
- `BoosterSystem`
- `TimerSystem`
- `HazardSystem`
- `RewardResolver`
- `ContinueFlow`
- `LivesSystem`
- `MetaRestorationSystem`
- `EventProgressSystem`

## 30.2. Suggested data model (pseudo-structure)

```ts
type LevelDefinition = {
  id: string;
  worldId: string;
  timerSeconds: number;
  targets: TargetDefinition[];
  dirtSpawners: DirtNode[];
  hazards: HazardNode[];
  locks: LockNode[];
  boostersAllowed: string[];
  rewardProfileId: string;
};

type TargetDefinition =
  | { type: "clean_object"; objectType: string; amount: number }
  | { type: "clean_dirt"; dirtType: string; amount: number }
  | { type: "restore_object"; objectId: string }
  | { type: "clean_area"; areaId: string; threshold: number }
  | { type: "sequence"; steps: TargetDefinition[] };

type CleanerState = {
  moveSpeed: number;
  cleanPower: number;
  sprayWidth: number;
  vacuumPower: number;
  tankCapacity: number;
  overdriveActive: boolean;
};

type DirtNode = {
  id: string;
  dirtType: string;
  hp: number;
  areaId?: string;
  targetTag?: string;
  unlockCondition?: string;
};

type HazardNode = {
  id: string;
  hazardType: string;
  areaId?: string;
  damageRule: string;
};
```

## 30.3. Win/fail logic
```ts
win = allTargetsCompletedBeforeTimer;
fail = timerExpired || hazardFailureTriggered;
continueEligible = fail && nearWinThresholdReached;
```

## 30.4. Near-win threshold examples
```ts
continueEligible if:
- remainingTargets <= 2
OR
- areaCompletionMissing <= 15%
OR
- remainingEstimatedSeconds <= 12
```

---

## 31. Risks

## 31.1. Risk: too simulator-like
If cleaning becomes too precise, slow, or physically literal, the product will lose casual F2P efficiency.

**Mitigation:** auto-cleaning, readable targets, arcade pacing.

## 31.2. Risk: too shallow / too toy-like
If levels are only "wash everything", there will be weak difficulty and weak monetization.

**Mitigation:** explicit goals, dependencies, hazards, routing.

## 31.3. Risk: automation bloat
If we turn the product into a management/automation game, we lose the strength of cleaning as the main fantasy.

**Mitigation:** keep automation only as light meta, not core loop.

## 31.4. Risk: fake-ad mismatch
If UA sells impossible or unrelated gameplay, retention will suffer.

**Mitigation:** dramatize real restore/timer/fail situations that exist in product.

---

## 32. Recommendation

Proceed with concept validation.

The strongest recommended direction is:

> **Take the All in Hole level + shell model, replace the hole fantasy with a one-thumb cleaning rover, build around before/after transformation, and keep automation as meta only.**

This direction is strategically stronger than:
- a full simulator port
- a heavy management-cleaning hybrid
- an automation-first cleaner
- a sandbox wash game with weak fail states

The product should be positioned as:

**a fast, readable, satisfying, level-based restoration game for casual F2P mobile.**

---

## 33. Final Product Formula

**Readable cleaning fantasy**  
+ **goal-based level puzzle**  
+ **timer + route + near-win tension**  
+ **boosters + lives + continue economy**  
+ **event wrapper + streak + light restoration meta**

That is the recommended design foundation.

---
