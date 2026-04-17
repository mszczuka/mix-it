# Water Stream Mechanic — Design Spec

**Date:** 2026-04-16
**Purpose:** Replace bot-follows-cursor input with a stationary nozzle + water particle stream aimed at a splash point
**Scope:** Mechanic swap in existing prototype (`index.html`)

---

## 1. Summary

Replace the moving cleaning bot with a stationary nozzle at the bottom-center of the arena. The player aims anywhere on screen and a rapid particle stream of water droplets flies from the nozzle to the aim point. Cleaning happens at the splash impact point within the existing cleaning radius. All other systems (dirt, objects, locks, hazards, power-ups, targets, HUD, timer, audio, levels) remain unchanged.

## 2. Decisions

| Decision | Choice |
|---|---|
| Input model | Free-aim from bottom — point anywhere, stream goes there |
| Bot role | Stationary nozzle at bottom-center of arena |
| Cleaning zone | Single splash point with cleaning radius where stream lands |
| Stream visual | Rapid water droplet particles from nozzle to target |
| Power-up collection | Splash point collects power-up orbs (not bot position) |

## 3. Bot Changes

### 3.1 Position
- Bot is anchored at bottom-center: `x = CANVAS_W / 2`, `y = CANVAS_H - 30`
- Bot no longer moves. `state.botX`/`state.botY` become fixed nozzle position.
- New state fields: `state.aimX`, `state.aimY` — where the stream lands (the splash point)

### 3.2 Visual
- Same blue rounded-rect body with glow, but drawn at fixed bottom-center
- Bot rotates to face the aim direction: calculate angle from nozzle to aim point, rotate the body drawing
- Small "nozzle tip" drawn at the top of the bot pointing toward aim
- Recoil/wobble animation when actively cleaning (subtle oscillation)
- Glow intensifies when turbo power-up is active

### 3.3 No Movement
- `updateBot(dt)` no longer moves the bot
- Instead it lerps `state.aimX`/`state.aimY` toward the input position (mouse/touch) at a fast rate for smooth aiming
- Lerp factor: use `t = 1 - Math.pow(0.001, dt)` for near-instant snapping (aim follows input with ~5ms effective lag). This is much faster than the old bot speed — aiming must feel responsive, not sluggish.

## 4. Input Changes

### 4.1 Mouse (Desktop)
- Mouse position on canvas = aim target
- `state.aimX`/`state.aimY` lerp toward mouse position
- No click required — continuous aiming while cursor is over canvas
- `state.inputActive` stays true while cursor is over canvas

### 4.2 Touch (Mobile)
- Touch position = aim target
- Same lerp behavior
- Lift finger = stream stops (inputActive = false), aim holds last position

### 4.3 Initial State
- On level start, aim point defaults to center of arena (CANVAS_W/2, CANVAS_H/2)
- Bot is always at bottom-center

## 5. Cleaning Logic Changes

### 5.1 Swap cleaning center
Everywhere that currently uses `state.botX`/`state.botY` as the cleaning center:
- `updateDirt(dt)` — change `ellipseDist` check to use `state.aimX`/`state.aimY`
- `updateObjects(dt)` — same swap
- Power-up collection in `updatePowerUps(dt)` — check distance from `state.aimX`/`state.aimY` to power-up orbs

### 5.2 Cleaning only when aiming
- Cleaning should only happen when `state.inputActive` is true (player is actively aiming)
- When input is not active, no cleaning occurs and no stream particles are emitted
- This adds a deliberate feel — you choose where to clean

### 5.3 Cleaning radius unchanged
- `CLEAN_RADIUS_X`/`CLEAN_RADIUS_Y` stay the same
- Turbo power-up still multiplies the radius
- The splash circle visually indicates the cleaning area at the aim point

## 6. Stream Particles

### 6.1 Emission
- When `state.inputActive` and screen is gameplay:
- Every frame, spawn 3-5 water droplet particles at the nozzle position (bot location)
- Each particle has velocity aimed at `state.aimX`/`state.aimY` with slight random spread (angle jitter +/- 0.08 radians, speed jitter +/- 10%)
- Calculate base speed so particles reach the aim point in ~0.25-0.35 seconds (speed = distance / travel_time)

### 6.2 Particle properties
- Type: 'dot'
- Size: 2-4px
- Color: COL_SPRAY (blue-white) with slight random alpha variation
- Life: calculated from distance (enough to reach target)
- Gravity: slight downward pull (20-40) so the stream has a subtle arc shape
- Friction: 0.99 (minimal drag)
- Shrink: false (dots stay same size during flight)

### 6.3 Stream density
- At 60fps, 3-5 particles per frame = 180-300 particles per second
- With ~0.3s lifetime, ~50-90 particles alive at any time
- This creates a visible continuous stream without being too heavy

## 7. Splash Effect

### 7.1 Splash circle indicator
- Draw at `state.aimX`/`state.aimY` (replacing the old cleaning radius around the bot)
- Pulsing ellipse: slight size oscillation (sin wave)
- Semi-transparent blue fill + dashed stroke
- Only visible when `state.inputActive`

### 7.2 Splash particles
- When stream particles reach the splash zone (or on every frame while cleaning):
- Spawn 1-2 small splash particles radiating outward from the aim point
- Short life (0.15-0.25s), small size, white-blue color
- Low speed (20-50), random direction, slight gravity

### 7.3 Dirt interaction splash
- When dirt is being cleaned, the existing spray particles (from `spawnSprayParticle`) still work
- They now emit from the splash point toward nearby dirt (not from the bot)
- Adjust `spawnSprayParticle` source position from bot to aim point

## 8. Nozzle Rendering

### 8.1 Bot body
- Drawn at fixed position (CANVAS_W/2, CANVAS_H - 30)
- Rotated to face aim point: angle = atan2(aimY - botY, aimX - botX)
- Only rotate within a reasonable range (don't flip upside down) — clamp angle
- Shadow still drawn below

### 8.2 Nozzle tip
- Small protruding rectangle/cone at the top of the bot body, pointing toward aim
- Glows brighter when actively streaming (inputActive)
- Changes color when turbo is active (brighter blue/cyan)

### 8.3 Recoil
- When streaming, bot has subtle rapid oscillation (1-2px random offset per frame)
- Creates a "pressure washer kickback" feel

## 9. What Does NOT Change

- Dirt system (spawnDirt, dirt types, HP, rendering, clean reveal)
- Object system (spawnObjects, object types, rendering, cleaning behavior)
- Lock system (gates, unlock conditions)
- Hazard system (recontamination vent)
- Power-up system (spawn timing, effects, duration) — only collection trigger point changes
- Combo system
- Target tracker
- HUD (timer, target cards, power-up indicator)
- Audio engine (all sounds stay)
- Level data (all 3 levels, dirt/object/lock/hazard/powerup placement)
- Win/fail logic
- Star rating
- Screen manager (intro, gameplay, result screens)

## 10. Level Layout Consideration

- Bot starting position is now always bottom-center, so `level.startX`/`level.startY` are ignored for the bot
- Dirt/objects near the bottom of the arena will be very easy to clean (close to nozzle). This is fine for Level 1 "immediate satisfaction" but level layouts may need slight adjustment if playtesting reveals balance issues
- For now, keep all existing level layouts unchanged — test first, adjust later

## 11. Implementation Scope

Estimated changes:
- `updateBot(dt)` — rewrite to lerp aim point instead of moving bot
- `drawBot()` — rewrite to draw stationary rotated nozzle at bottom
- `updateDirt(dt)` — swap botX/Y → aimX/Y (small change)
- `updateObjects(dt)` — swap botX/Y → aimX/Y (small change)
- `updatePowerUps(dt)` — swap collection distance check to aimX/Y
- `spawnSprayParticle()` — change source from bot to aim point
- `render()` — add splash circle rendering, stream particle emission
- `startLevel()` — set initial aimX/Y
- `state` object — add aimX, aimY fields
- Stream particle spawning — new logic in game loop or render
- Splash effect rendering — new function

No new HTML elements or CSS needed. All changes are in JS.
