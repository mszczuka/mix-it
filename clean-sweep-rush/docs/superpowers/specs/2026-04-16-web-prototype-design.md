# Clean Sweep Rush — Web Prototype Spec

**Date:** 2026-04-16
**Purpose:** Concept validation — prove the core cleaning + targets + timer loop feels satisfying
**Format:** Single HTML file, vanilla JS + Canvas 2D, no dependencies
**Theme:** Backyard Chaos (World 1)

---

## 1. Prototype Goals

Answer three questions from the design doc (section 29):

1. Does auto-clean movement feel satisfying enough compared to hole-swallow movement?
2. Does temporary cleaning power growth create the same mid-level arc as hole growth?
3. Can target cards plus timer create enough tension without breaking the soothing fantasy?

## 2. Decisions

| Decision | Choice |
|---|---|
| Perspective | Slight tilt / 3/4 view — objects have visible front face and depth |
| Theme | Backyard Chaos — mud, garden mess, overgrown patches |
| Controls | Mouse/finger follow (Hole.io style) — bot lerps toward cursor/touch |
| Shell | Light — level intro with target cards → gameplay → win/fail screen |
| Tech | Single `index.html`, Canvas arena + DOM overlays, Web Audio API |

## 3. Screens & Flow

Three screens in a single HTML file:

### 3.1 Level Intro
- World name, level number
- Target cards (icon + description + required count)
- Timer preview
- START button
- Shown before each level

### 3.2 Gameplay
- Canvas arena (backyard, ~800x600 logical size, responsive)
- Top HUD bar (DOM overlay): target card progress (icon + current/required) on the left, timer on the right
- Bot in the arena, dirt patches, target objects, power-up pickups
- Power-up active indicator at bottom center
- Combo counter (visual only)
- Timer turns red and pulses when under 10 seconds

### 3.3 Result Screen
- **Win:** "Level Complete!" + star rating (1-3) + time bonus + coins earned + "Next Level" button
- **Fail:** "Time's Up!" + progress summary ("So close!") + "Retry" and "Menu" buttons
- Completing level 3 shows a simple "Prototype Complete" celebration

### 3.4 Flow
```
Level Intro → START → Gameplay → Win → next Level Intro (or Prototype Complete after level 3)
                                → Fail → Retry (same level intro) or Menu (level 1 intro)
```

## 4. Arena & Bot

### 4.1 Arena
- Fixed rectangular backyard with grass-green base
- Slight tilt perspective: elliptical dirt patches, objects drawn with front face + top face
- Divided into zones: open areas (immediately accessible) and gated zones (unlocked by clearing nearby dirt or completing actions)
- Backyard props: fence edges, stepping stones, decorative elements for context (non-interactive)

### 4.2 Cleaning Bot
- Small rounded rectangle with blue glow
- Follows mouse/finger position with smooth lerp (slight trailing lag for game feel)
- Auto-cleans within an elliptical radius — anything dirty inside the range loses HP per frame
- Spray particles emit from bot toward nearby dirt while actively cleaning
- Vacuum swirl particles when near sludge-type dirt

## 5. Dirt System

### 5.1 Dirt Types
Three types for the prototype:

| Type | Visual | HP | Cleaning | Notes |
|---|---|---|---|---|
| Mud | Brown ellipses | Medium | Standard spray | Base dirt type |
| Leaves | Scattered small clusters | Low | Fast spray | Light, satisfying quick cleans |
| Sludge | Dark viscous pools | High | Slow spray, fast with vacuum power-up | Thick, gating mechanic |

### 5.2 Dirt Behavior
- Each dirt node has: position (x, y), type, maxHP, currentHP, areaId (optional), targetTag (optional), unlockCondition (optional)
- As HP decreases, dirt visually shrinks and fades — revealing clean ground beneath
- Color transition: brown → yellow-green → bright green
- Fully cleared dirt triggers a clean reveal pulse (expanding white ring)
- Dirt nodes can be tagged to count toward specific targets

## 6. Target Objects

Specific interactive objects placed in the arena:

| Object | Visual | Behavior |
|---|---|---|
| Flower pot | Emoji-style pot, dimmed when dirty | Cleaned by proximity, brightens progressively, sparkle burst on completion |
| Garden bench | Rectangular with depth, muddy overlay | Same cleaning behavior, larger hitbox |
| Bird bath | Circular basin, filled with sludge | Requires full surrounding clean + direct clean = restore action |

Target objects start visually dirty (dimmed, desaturated, brown overlay). As the bot cleans nearby, they progressively brighten. Full clean triggers sparkle particles and increments the target card counter.

## 7. Gating & Locks

- **Dirt gate:** a zone is blocked until nearby mud is cleared (e.g., garden gate covered in mud — clean the mud to open the path)
- **Sequence gate:** some restore targets only activate after surrounding dirt is removed (bird bath in level 3)
- Visual: locked zones have a subtle barrier overlay (semi-transparent fence/gate). Barrier dissolves with a particle effect when unlocked.

## 8. Power-Up Pickups

In-level collectible orbs that spawn at a set time:

| Power-Up | Spawn Time | Duration | Effect |
|---|---|---|---|
| Turbo Spray | 15s elapsed (appears mid-level) | 8 seconds | Wider cleaning radius + 2x cleaning speed |
| Sludge Magnet | 10s elapsed (appears early-level) | 6 seconds | Sludge within extended range is pulled toward bot and cleaned rapidly |

- Visual: glowing orb floating with bobbing animation
- Collection: bot touches orb → flash + expanding ring + bot glow intensifies
- Active indicator shown at bottom of screen with countdown

## 9. Hazards

Level 3 only — one recontamination vent:

- A fixed position that slowly respawns mud in a small radius
- Visual: dark vent/grate with periodic puff animation
- Creates route pressure: do you clean that area first (knowing it'll get dirty again) or save it for last?
- Cannot be destroyed — must be managed through routing decisions

## 10. Combo System

- Cleaning multiple dirt nodes within 2 seconds of each other increments a combo counter (x2, x3, x4...)
- Combo resets after 2 seconds of no dirt cleared
- Purely visual/feel effect in prototype:
  - Higher combo = more particles per clean
  - Higher combo = brighter reveal flashes
  - Counter displayed near bot briefly on each increment
- No score multiplier — this just tests whether chaining cleans feels rewarding

## 11. Level Definitions

### Level 1 — "First Wash"
- **Timer:** 45 seconds
- **Targets:** Clean 4 flower pots
- **Dirt:** Mud only (~12 patches)
- **Gating:** None
- **Hazards:** None
- **Power-ups:** None
- **Purpose:** Learn controls, feel the satisfaction of cleaning and revealing

### Level 2 — "Garden Path"
- **Timer:** 40 seconds
- **Targets:** Remove 6 mud patches (tagged) + Clean 2 benches
- **Dirt:** Mud (~10) + Leaves (~8)
- **Gating:** 1 locked zone — garden gate covered in mud, clean to open access to back area with 1 bench
- **Hazards:** None
- **Power-ups:** Turbo Spray (spawns at 15s)
- **Purpose:** Route decisions, power growth arc, gating introduces light puzzle

### Level 3 — "Backyard Blitz"
- **Timer:** 35 seconds
- **Targets:** Clean area to 80% + Restore bird bath (sequence: clean surrounding sludge → clean bird bath)
- **Dirt:** Mud (~8) + Leaves (~6) + Sludge (~4)
- **Gating:** 2 locked zones (one dirt gate, one behind the bird bath restore) + sequence dependency for bird bath
- **Hazards:** 1 recontamination vent
- **Power-ups:** Turbo Spray (spawns at 15s) + Sludge Magnet (spawns at 10s)
- **Purpose:** Time pressure, tension vs. soothing balance, near-fail emotional state

## 12. Star Rating

Based on time remaining when all targets are completed:

| Stars | Condition |
|---|---|
| ★★★ | 10+ seconds remaining |
| ★★ | 5-9 seconds remaining |
| ★ | 0-4 seconds remaining |

Stars are displayed on the win screen. No gameplay impact in prototype.

## 13. Juice & Effects

### 13.1 Visual Effects
- **Dirt removal:** smooth shrink/fade with ease-out, ground beneath transitions brown → yellow-green → green
- **Spray particles:** 10-15 small blue/white dots per burst, short lifespan, random spread from bot toward dirt
- **Vacuum particles:** dark specks swirl inward toward bot when near sludge
- **Clean reveal pulse:** white ring expands outward from cleared dirt center
- **Target completion:** yellow/white star particle burst + HUD icon bounce + counter animate
- **Power-up collect:** bright flash + expanding ring + bot glow change during active duration
- **Screen shake:** subtle 2-3px on target completion and power-up collect
- **Timer warning:** red color + pulse animation when under 10 seconds
- **Combo counter:** floating "x2", "x3" text near bot, scales up on increment, fades

### 13.2 Audio (Web Audio API, all synthesized)
- **Spray loop:** soft white noise hiss while actively cleaning, pitch shifts with dirt resistance
- **Dirt clear pop:** short rising tone when a dirt patch fully clears
- **Target chime:** two-note ascending ding on target card completion
- **Power-up collect:** bright ascending frequency sweep
- **Timer tick:** subtle tick sound in last 10 seconds, accelerating pace
- **Win jingle:** short major chord arpeggio
- **Fail sound:** gentle descending tone (not harsh)
- **Combo sound:** pitch rises with combo level

## 14. Controls

### 14.1 Desktop
- Mouse position = bot target position
- Bot lerps toward mouse at a fixed speed (smooth follow, not instant teleport)
- No click required — movement is continuous while cursor is over the arena

### 14.2 Mobile
- Touch position = bot target position
- Same lerp behavior as desktop
- Touch start anywhere on arena to begin movement
- Lift finger = bot stops (holds last position)

### 14.3 Design Constraints
- First clean reveal within 2-3 seconds of first input (per design doc)
- Dirt must be placed near starting position to ensure immediate satisfaction
- No buttons needed during gameplay (all cleaning is automatic)

## 15. Technical Architecture

Single `index.html` file. Organized as labeled code sections:

### 15.1 Modules
- **Constants & Config** — canvas size, colors, timing values, tuning parameters
- **Game State** — current screen, level index, timer, targets, combo, active power-ups
- **Level Data** — array of 3 level definition objects
- **Level Loader** — reads level data, spawns dirt nodes/objects/locks/hazards/power-ups
- **Bot Controller** — input handling, lerp movement, cleaning radius logic
- **Dirt System** — dirt node management, HP reduction per frame, visual state updates, removal
- **Object System** — target object state, progressive cleaning, completion detection
- **Target Tracker** — checks dirt/object state against target cards, fires completion events
- **Lock System** — evaluates unlock conditions, removes barriers
- **Hazard System** — recontamination vent logic (mud respawn timer)
- **Power-Up System** — spawn timing, collection, active effects, expiry
- **Combo Tracker** — timestamps of recent cleans, counter, decay
- **Particle System** — pooled particle emitter for all visual effects
- **Audio Engine** — Web Audio oscillators and noise generators for all sounds
- **Renderer** — canvas draw loop: arena base, dirt, objects, bot, particles, effects
- **HUD Manager** — DOM elements for target cards, timer, combo, power-up indicator
- **Screen Manager** — show/hide intro, gameplay, result screens with transitions

### 15.2 Game Loop
```
requestAnimationFrame loop:
  1. calculate deltaTime
  2. if gameplay screen:
     a. update timer
     b. update bot position (lerp toward input)
     c. update dirt system (apply cleaning from bot radius)
     d. update objects (check cleaning progress)
     e. update locks (check unlock conditions)
     f. update hazards (respawn dirt if vent active)
     g. update power-ups (spawn timing, expiry)
     h. update combo (decay check)
     i. update particles
     j. check win/fail conditions
     k. update HUD
  3. render canvas (arena, dirt, objects, bot, particles)
  4. render DOM overlays (HUD, screens)
```

### 15.3 Rendering Approach
- Canvas for all gameplay visuals (arena, dirt, bot, objects, particles, effects)
- DOM overlays for UI (screens, HUD bar, buttons) — easier to style and animate
- Canvas resizes responsively to fit viewport while maintaining aspect ratio

### 15.4 Mobile Support
- Touch events mirror mouse events (touchmove position = mouse position)
- Canvas scales to fill viewport width on narrow screens
- No hover-dependent interactions
- Touch-friendly button sizes on intro/result screens

## 16. Estimated Scale

~2000-2500 lines in one HTML file, comparable to the Bar Clash prototype. Breakdown estimate:
- HTML/CSS structure and screens: ~200 lines
- Game state, config, level data: ~200 lines
- Bot + input handling: ~100 lines
- Dirt + object + target systems: ~300 lines
- Locks + hazards + power-ups: ~200 lines
- Particle system: ~200 lines
- Audio engine: ~200 lines
- Renderer (canvas draw): ~400 lines
- HUD + screen management: ~200 lines
- Game loop + win/fail logic: ~150 lines
- Utility functions: ~100 lines

## 17. Out of Scope

Explicitly not in this prototype:
- Boosters (pre-level or purchasable)
- Lives / continue economy
- Currency / economy
- Hub restoration meta
- Events / streaks / passes
- Social features
- Multiple worlds
- Save/load progress
- Settings/options
- Sound on/off toggle
