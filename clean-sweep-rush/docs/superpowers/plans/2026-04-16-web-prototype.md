# Clean Sweep Rush Web Prototype — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a playable single-file web prototype that validates the core cleaning + targets + timer loop across 3 levels.

**Architecture:** Single `index.html` file with inline CSS and JS. Canvas 2D for gameplay rendering (arena, dirt, bot, objects, particles). DOM overlays for UI screens (intro, HUD, result). Web Audio API for synthesized sound effects. No dependencies or build step.

**Tech Stack:** Vanilla HTML5/CSS3/JS, Canvas 2D, Web Audio API

**Spec:** `docs/superpowers/specs/2026-04-16-web-prototype-design.md`

**Testing approach:** This is a single-file game prototype — no automated tests. Each task produces a playable increment. Verification is: open `index.html` in browser, perform described actions, confirm expected behavior. Every task ends with a manual verification step and a commit.

---

## File Structure

Single file:
- **Create:** `index.html` — the entire prototype (~2500 lines)

The file is organized into labeled sections via comments:
```
<!-- HTML structure -->
<style>/* CSS */</style>
<script>
// ===== CONSTANTS & CONFIG =====
// ===== GAME STATE =====
// ===== LEVEL DATA =====
// ===== UTILITIES =====
// ===== AUDIO ENGINE =====
// ===== PARTICLE SYSTEM =====
// ===== DIRT SYSTEM =====
// ===== OBJECT SYSTEM =====
// ===== LOCK SYSTEM =====
// ===== HAZARD SYSTEM =====
// ===== POWER-UP SYSTEM =====
// ===== COMBO TRACKER =====
// ===== BOT CONTROLLER =====
// ===== TARGET TRACKER =====
// ===== RENDERER =====
// ===== HUD MANAGER =====
// ===== SCREEN MANAGER =====
// ===== GAME LOOP =====
// ===== INIT =====
</script>
```

---

### Task 1: HTML Shell, Canvas, Screen Manager, Bot Movement

Build the skeleton: 3 screens (intro, gameplay, result), a canvas, and a bot that follows the mouse. This is the foundation everything else builds on.

**Files:**
- Create: `index.html`

- [ ] **Step 1: Create the HTML structure with all 3 screens and canvas**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>Clean Sweep Rush — Prototype</title>
</head>
<body>
  <!-- GAMEPLAY CANVAS (behind overlays) -->
  <canvas id="game-canvas"></canvas>

  <!-- HUD OVERLAY (visible during gameplay) -->
  <div id="hud" class="hidden">
    <div id="hud-bar">
      <div id="hud-targets"></div>
      <div id="hud-timer">0:45</div>
    </div>
    <div id="hud-powerup" class="hidden"></div>
  </div>

  <!-- SCREEN: LEVEL INTRO -->
  <div id="screen-intro" class="screen">
    <div class="screen-content">
      <div id="intro-world" class="intro-world"></div>
      <div id="intro-level" class="intro-level"></div>
      <div id="intro-targets" class="intro-targets"></div>
      <div id="intro-timer" class="intro-timer-preview"></div>
      <button id="btn-start" class="btn-primary">▶ START</button>
    </div>
  </div>

  <!-- SCREEN: RESULT (win/fail) -->
  <div id="screen-result" class="screen hidden">
    <div class="screen-content">
      <div id="result-icon"></div>
      <div id="result-title"></div>
      <div id="result-stars"></div>
      <div id="result-summary"></div>
      <div id="result-buttons"></div>
    </div>
  </div>
</body>
</html>
```

CSS requirements:
- `body`: full viewport, no scroll, dark green-tinted background (`#1a2a1a`), flexbox centered, system font
- `#game-canvas`: centered in viewport, maintains 4:3 aspect ratio (800x600 logical), scales to fit
- `.screen`: absolute overlay covering full viewport, flexbox centered, semi-transparent dark background
- `.screen.hidden`: `display: none`
- `.screen-content`: centered column, max-width 360px
- `.btn-primary`: green (`#4a8`), white text, rounded, large touch target (min 48px height), hover/active states
- `#hud`: fixed top bar, transparent black background, flexbox space-between
- `#hud-bar`: flex row, targets on left, timer on right
- `.hud-target-card`: small pill with icon + count, background `rgba(255,255,255,0.1)`
- `#hud-timer`: orange-amber, bold, pill-shaped
- `#hud-timer.warning`: red, CSS pulse animation
- Intro screen: world name (small green text, uppercase), level number (large white), target cards (icon + text, bordered cards), timer preview (dimmed)
- Result screen: large icon, title, stars row, summary text, action buttons

- [ ] **Step 2: Implement Constants, Game State, and Utilities**

```javascript
// ===== CONSTANTS & CONFIG =====
const CANVAS_W = 800;
const CANVAS_H = 600;
const BOT_SPEED = 280;        // pixels per second (lerp target speed)
const BOT_RADIUS_X = 18;      // bot ellipse radii (slight tilt)
const BOT_RADIUS_Y = 12;
const CLEAN_RADIUS_X = 50;    // cleaning radius ellipse
const CLEAN_RADIUS_Y = 35;
const CLEAN_POWER = 30;       // HP removed per second (base)
const TURBO_RADIUS_MULT = 1.5;
const TURBO_POWER_MULT = 2.0;
const SLUDGE_MAGNET_RADIUS = 120;
const COMBO_WINDOW = 2.0;     // seconds before combo resets
const POWERUP_BOB_SPEED = 2;  // oscillations per second
const POWERUP_BOB_AMP = 4;    // pixels
const HAZARD_RESPAWN_INTERVAL = 4; // seconds between mud respawns
const HAZARD_RESPAWN_RADIUS = 60;
const SCREEN_SHAKE_DECAY = 0.9;

// Colors
const COL_GRASS = '#4a7a3a';
const COL_GRASS_CLEAN = '#5a9a4a';
const COL_MUD = '#6a5232';
const COL_LEAVES = '#5a6a2a';
const COL_SLUDGE = '#2a2a1a';
const COL_BOT = '#44aaff';
const COL_BOT_GLOW = 'rgba(68,170,255,0.3)';
const COL_SPRAY = 'rgba(180,220,255,0.8)';
const COL_FENCE = '#8a7a5a';

// ===== GAME STATE =====
const state = {
  screen: 'intro',      // 'intro' | 'gameplay' | 'result'
  levelIndex: 0,
  timer: 0,              // seconds remaining
  timerElapsed: 0,        // seconds elapsed since level start
  paused: false,
  // Bot
  botX: CANVAS_W / 2,
  botY: CANVAS_H / 2,
  targetX: CANVAS_W / 2,
  targetY: CANVAS_H / 2,
  inputActive: false,
  // Level runtime
  dirtNodes: [],
  objects: [],
  locks: [],
  hazards: [],
  powerUps: [],
  activePowerUps: [],     // { type, remaining }
  // Targets
  targets: [],            // { ...def, current: 0 }
  // Combo
  comboCount: 0,
  comboTimer: 0,
  // Particles
  particles: [],
  // Shake
  shakeX: 0,
  shakeY: 0,
  // Result
  won: false,
  timeLeft: 0,
  stars: 0,
  // Audio context (lazy init)
  audioCtx: null,
  isCleaning: false,
  sprayNode: null,
};

// ===== UTILITIES =====
function lerp(a, b, t) { return a + (b - a) * t; }
function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }
function dist(x1, y1, x2, y2) { return Math.sqrt((x2-x1)**2 + (y2-y1)**2); }
function ellipseDist(px, py, cx, cy, rx, ry) {
  // Normalized distance: <1 means inside ellipse
  return Math.sqrt(((px-cx)/rx)**2 + ((py-cy)/ry)**2);
}
function randRange(min, max) { return min + Math.random() * (max - min); }
function randInt(min, max) { return Math.floor(randRange(min, max + 1)); }
function easeOut(t) { return 1 - (1 - t) ** 3; }
```

- [ ] **Step 3: Implement Screen Manager**

```javascript
// ===== SCREEN MANAGER =====
const screens = {
  intro: document.getElementById('screen-intro'),
  result: document.getElementById('screen-result'),
};
const hud = document.getElementById('hud');

function showScreen(name) {
  state.screen = name;
  // Hide all screens
  Object.values(screens).forEach(s => s.classList.add('hidden'));
  hud.classList.add('hidden');

  if (name === 'intro') {
    screens.intro.classList.remove('hidden');
    populateIntroScreen();
  } else if (name === 'gameplay') {
    hud.classList.remove('hidden');
  } else if (name === 'result') {
    screens.result.classList.remove('hidden');
    populateResultScreen();
  }
}

function populateIntroScreen() {
  const level = LEVELS[state.levelIndex];
  document.getElementById('intro-world').textContent = 'World 1 — Backyard Chaos';
  document.getElementById('intro-level').textContent = `Level ${state.levelIndex + 1}: ${level.name}`;
  // Build target cards
  const targetsEl = document.getElementById('intro-targets');
  targetsEl.innerHTML = '';
  level.targets.forEach(t => {
    const card = document.createElement('div');
    card.className = 'target-card';
    card.innerHTML = `<span class="target-icon">${t.icon}</span><span class="target-text">${t.label}</span>`;
    targetsEl.appendChild(card);
  });
  document.getElementById('intro-timer').textContent = `⏱ ${level.timerSeconds} seconds`;
}

function populateResultScreen() {
  const resultIcon = document.getElementById('result-icon');
  const resultTitle = document.getElementById('result-title');
  const resultStars = document.getElementById('result-stars');
  const resultSummary = document.getElementById('result-summary');
  const resultButtons = document.getElementById('result-buttons');

  if (state.won) {
    resultIcon.textContent = '✨';
    resultTitle.textContent = 'Level Complete!';
    resultTitle.className = 'result-title win';
    const starStr = '★'.repeat(state.stars) + '☆'.repeat(3 - state.stars);
    resultStars.textContent = starStr;
    resultStars.className = 'result-stars';
    const timeBonus = Math.floor(state.timeLeft) * 10;
    resultSummary.textContent = `+${timeBonus} time bonus`;

    resultButtons.innerHTML = '';
    if (state.levelIndex < LEVELS.length - 1) {
      const btn = document.createElement('button');
      btn.className = 'btn-primary';
      btn.textContent = 'Next Level →';
      btn.onclick = () => { state.levelIndex++; showScreen('intro'); };
      resultButtons.appendChild(btn);
    } else {
      const btn = document.createElement('button');
      btn.className = 'btn-primary';
      btn.textContent = '🎉 Prototype Complete!';
      btn.onclick = () => { state.levelIndex = 0; showScreen('intro'); };
      resultButtons.appendChild(btn);
    }
  } else {
    resultIcon.textContent = '😤';
    resultTitle.textContent = "Time's Up!";
    resultTitle.className = 'result-title fail';
    resultStars.textContent = '';
    // Show how close
    const summaryParts = state.targets.map(t => `${t.icon} ${t.current}/${t.amount}`);
    resultSummary.textContent = summaryParts.join(' · ') + ' — So close!';

    resultButtons.innerHTML = '';
    const retryBtn = document.createElement('button');
    retryBtn.className = 'btn-primary';
    retryBtn.textContent = 'Retry ↻';
    retryBtn.onclick = () => showScreen('intro');
    resultButtons.appendChild(retryBtn);

    const menuBtn = document.createElement('button');
    menuBtn.className = 'btn-secondary';
    menuBtn.textContent = '← Menu';
    menuBtn.onclick = () => { state.levelIndex = 0; showScreen('intro'); };
    resultButtons.appendChild(menuBtn);
  }
}
```

- [ ] **Step 4: Implement Bot Controller with mouse/touch input**

```javascript
// ===== BOT CONTROLLER =====
const canvas = document.getElementById('game-canvas');

function canvasCoords(clientX, clientY) {
  const rect = canvas.getBoundingClientRect();
  return {
    x: (clientX - rect.left) / rect.width * CANVAS_W,
    y: (clientY - rect.top) / rect.height * CANVAS_H,
  };
}

canvas.addEventListener('mousemove', e => {
  if (state.screen !== 'gameplay') return;
  const pos = canvasCoords(e.clientX, e.clientY);
  state.targetX = clamp(pos.x, 20, CANVAS_W - 20);
  state.targetY = clamp(pos.y, 20, CANVAS_H - 20);
  state.inputActive = true;
});

canvas.addEventListener('mouseleave', () => { state.inputActive = false; });
canvas.addEventListener('mouseenter', () => { state.inputActive = true; });

canvas.addEventListener('touchstart', e => {
  e.preventDefault();
  if (state.screen !== 'gameplay') return;
  const touch = e.touches[0];
  const pos = canvasCoords(touch.clientX, touch.clientY);
  state.targetX = clamp(pos.x, 20, CANVAS_W - 20);
  state.targetY = clamp(pos.y, 20, CANVAS_H - 20);
  state.inputActive = true;
}, { passive: false });

canvas.addEventListener('touchmove', e => {
  e.preventDefault();
  if (state.screen !== 'gameplay') return;
  const touch = e.touches[0];
  const pos = canvasCoords(touch.clientX, touch.clientY);
  state.targetX = clamp(pos.x, 20, CANVAS_W - 20);
  state.targetY = clamp(pos.y, 20, CANVAS_H - 20);
}, { passive: false });

canvas.addEventListener('touchend', () => { state.inputActive = false; });

function updateBot(dt) {
  if (!state.inputActive) return;
  const dx = state.targetX - state.botX;
  const dy = state.targetY - state.botY;
  const d = Math.sqrt(dx * dx + dy * dy);
  if (d < 1) return;
  const move = Math.min(BOT_SPEED * dt, d);
  state.botX += (dx / d) * move;
  state.botY += (dy / d) * move;
}
```

- [ ] **Step 5: Implement basic Renderer — arena background and bot**

Draw the backyard arena (green rectangle with fence border, slight tilt feel via subtle gradient) and the bot (rounded rect with glow, cleaning radius indicator).

```javascript
// ===== RENDERER =====
const ctx = canvas.getContext('2d');

function resizeCanvas() {
  const aspect = CANVAS_W / CANVAS_H;
  let w = window.innerWidth;
  let h = window.innerHeight;
  if (w / h > aspect) { w = h * aspect; }
  else { h = w / aspect; }
  canvas.style.width = w + 'px';
  canvas.style.height = h + 'px';
  canvas.width = CANVAS_W;
  canvas.height = CANVAS_H;
}
window.addEventListener('resize', resizeCanvas);
resizeCanvas();

function render() {
  ctx.save();
  // Apply screen shake
  ctx.translate(state.shakeX, state.shakeY);

  // Arena background — grass with subtle vertical gradient for tilt feel
  const grassGrad = ctx.createLinearGradient(0, 0, 0, CANVAS_H);
  grassGrad.addColorStop(0, '#3a6a2a');  // slightly darker at top (further away)
  grassGrad.addColorStop(1, COL_GRASS);
  ctx.fillStyle = grassGrad;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  // Fence border
  ctx.strokeStyle = COL_FENCE;
  ctx.lineWidth = 6;
  ctx.strokeRect(3, 3, CANVAS_W - 6, CANVAS_H - 6);
  // Fence posts
  for (let i = 0; i < CANVAS_W; i += 60) {
    ctx.fillStyle = COL_FENCE;
    ctx.fillRect(i, 0, 4, 8);
    ctx.fillRect(i, CANVAS_H - 8, 4, 8);
  }

  // ... (dirt, objects, locks drawn by later tasks) ...

  // Bot
  renderBot();

  // ... (particles drawn by later tasks) ...

  ctx.restore();
}

function renderBot() {
  const bx = state.botX;
  const by = state.botY;
  const hasTurbo = state.activePowerUps.some(p => p.type === 'turbo');
  const radiusMult = hasTurbo ? TURBO_RADIUS_MULT : 1;

  // Cleaning radius indicator
  ctx.beginPath();
  ctx.ellipse(bx, by, CLEAN_RADIUS_X * radiusMult, CLEAN_RADIUS_Y * radiusMult, 0, 0, Math.PI * 2);
  ctx.fillStyle = hasTurbo ? 'rgba(68,170,255,0.12)' : 'rgba(68,170,255,0.06)';
  ctx.fill();
  ctx.strokeStyle = 'rgba(68,170,255,0.2)';
  ctx.lineWidth = 1;
  ctx.setLineDash([4, 4]);
  ctx.stroke();
  ctx.setLineDash([]);

  // Bot shadow
  ctx.beginPath();
  ctx.ellipse(bx, by + 8, BOT_RADIUS_X, BOT_RADIUS_Y * 0.5, 0, 0, Math.PI * 2);
  ctx.fillStyle = 'rgba(0,0,0,0.2)';
  ctx.fill();

  // Bot body (rounded rect with depth)
  const bw = BOT_RADIUS_X * 2;
  const bh = BOT_RADIUS_Y * 2;
  // Front face (slightly darker)
  ctx.fillStyle = '#3388dd';
  roundRect(ctx, bx - bw/2, by - bh/2 + 3, bw, bh - 3, 5);
  ctx.fill();
  // Top face
  ctx.fillStyle = hasTurbo ? '#66ccff' : COL_BOT;
  roundRect(ctx, bx - bw/2, by - bh/2, bw, bh - 6, 5);
  ctx.fill();
  // Highlight stripe
  ctx.fillStyle = 'rgba(255,255,255,0.3)';
  roundRect(ctx, bx - bw/4, by - bh/2 + 2, bw/2, 3, 2);
  ctx.fill();

  // Bot glow
  ctx.beginPath();
  ctx.ellipse(bx, by, BOT_RADIUS_X + 6, BOT_RADIUS_Y + 4, 0, 0, Math.PI * 2);
  ctx.fillStyle = hasTurbo ? 'rgba(68,200,255,0.25)' : COL_BOT_GLOW;
  ctx.fill();
}

function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
}
```

- [ ] **Step 6: Implement basic Game Loop and START button wiring**

```javascript
// ===== GAME LOOP =====
let lastTime = 0;

function gameLoop(timestamp) {
  const dt = Math.min((timestamp - lastTime) / 1000, 0.05); // cap at 50ms
  lastTime = timestamp;

  if (state.screen === 'gameplay') {
    updateBot(dt);
    // (other updates added by later tasks)
    updateShake(dt);
  }

  render();
  requestAnimationFrame(gameLoop);
}

function updateShake(dt) {
  state.shakeX *= SCREEN_SHAKE_DECAY;
  state.shakeY *= SCREEN_SHAKE_DECAY;
  if (Math.abs(state.shakeX) < 0.1) state.shakeX = 0;
  if (Math.abs(state.shakeY) < 0.1) state.shakeY = 0;
}

function triggerShake(intensity) {
  state.shakeX = randRange(-intensity, intensity);
  state.shakeY = randRange(-intensity, intensity);
}

// ===== INIT =====
function startLevel() {
  const level = LEVELS[state.levelIndex];
  state.timer = level.timerSeconds;
  state.timerElapsed = 0;
  state.botX = level.startX || CANVAS_W / 2;
  state.botY = level.startY || CANVAS_H * 0.7;
  state.targetX = state.botX;
  state.targetY = state.botY;
  state.inputActive = false;
  state.dirtNodes = [];
  state.objects = [];
  state.locks = [];
  state.hazards = [];
  state.powerUps = [];
  state.activePowerUps = [];
  state.targets = level.targets.map(t => ({ ...t, current: 0 }));
  state.comboCount = 0;
  state.comboTimer = 0;
  state.particles = [];
  state.shakeX = 0;
  state.shakeY = 0;
  state.won = false;
  state.isCleaning = false;
  // Load level data (dirt, objects, etc) — added in later tasks
  loadLevel(level);
  showScreen('gameplay');
}

document.getElementById('btn-start').addEventListener('click', startLevel);

// Placeholder level loader — filled in Task 3
function loadLevel(level) {
  // Will spawn dirt, objects, locks, hazards, power-ups
}

// Need at least a stub LEVELS array for screen manager to work
const LEVELS = [
  { name: 'First Wash', timerSeconds: 45, targets: [{ type: 'clean_object', icon: '🪴', label: 'Clean 4 pots', objectType: 'pot', amount: 4 }] },
  { name: 'Garden Path', timerSeconds: 40, targets: [{ type: 'clean_dirt', icon: '💧', label: 'Remove 6 mud', dirtTag: 'target_mud', amount: 6 }, { type: 'clean_object', icon: '🪑', label: 'Clean 2 benches', objectType: 'bench', amount: 2 }] },
  { name: 'Backyard Blitz', timerSeconds: 35, targets: [{ type: 'clean_area', icon: '🧹', label: 'Clean to 80%', areaId: 'main', threshold: 0.8 }, { type: 'restore_object', icon: '🛁', label: 'Restore bird bath', objectId: 'birdbath' }] },
];

// Start
showScreen('intro');
requestAnimationFrame(gameLoop);
```

- [ ] **Step 7: Verify in browser**

Open `index.html` in a browser.
- Expected: dark green background, intro screen shows "Level 1: First Wash", target card "Clean 4 pots", timer "45 seconds", green START button.
- Click START: intro hides, canvas shows green backyard with fence border, blue bot in lower-center.
- Move mouse over canvas: bot smoothly follows cursor with slight lag.
- Touch works on mobile (test with dev tools device mode).

- [ ] **Step 8: Commit**

```bash
git add index.html
git commit -m "feat: HTML shell, screens, canvas, bot movement"
```

---

### Task 2: Dirt System and Cleaning

Add dirt nodes to the arena. The bot auto-cleans dirt within its radius. Dirt fades and reveals clean ground. This is the core mechanic.

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Implement Dirt System**

```javascript
// ===== DIRT SYSTEM =====
function spawnDirt(defs) {
  for (const def of defs) {
    state.dirtNodes.push({
      id: def.id || `dirt_${state.dirtNodes.length}`,
      x: def.x,
      y: def.y,
      type: def.type,            // 'mud' | 'leaves' | 'sludge'
      radiusX: def.radiusX || (def.type === 'sludge' ? 28 : def.type === 'leaves' ? 18 : 24),
      radiusY: def.radiusY || (def.type === 'sludge' ? 18 : def.type === 'leaves' ? 12 : 16),
      maxHP: def.hp || (def.type === 'sludge' ? 100 : def.type === 'leaves' ? 30 : 60),
      hp: def.hp || (def.type === 'sludge' ? 100 : def.type === 'leaves' ? 30 : 60),
      areaId: def.areaId || null,
      targetTag: def.targetTag || null,
      locked: def.locked || false,
      alive: true,
    });
  }
}

function updateDirt(dt) {
  const hasTurbo = state.activePowerUps.some(p => p.type === 'turbo');
  const hasMagnet = state.activePowerUps.some(p => p.type === 'magnet');
  const radiusMult = hasTurbo ? TURBO_RADIUS_MULT : 1;
  const powerMult = hasTurbo ? TURBO_POWER_MULT : 1;
  let anyCleaning = false;

  for (const dirt of state.dirtNodes) {
    if (!dirt.alive || dirt.locked) continue;

    // Check if bot is in range
    const ed = ellipseDist(dirt.x, dirt.y, state.botX, state.botY,
      CLEAN_RADIUS_X * radiusMult, CLEAN_RADIUS_Y * radiusMult);

    let cleaning = ed < 1.0;

    // Sludge magnet: extended pull range
    if (!cleaning && dirt.type === 'sludge' && hasMagnet) {
      const magnetDist = dist(dirt.x, dirt.y, state.botX, state.botY);
      if (magnetDist < SLUDGE_MAGNET_RADIUS) {
        cleaning = true;
      }
    }

    if (cleaning) {
      anyCleaning = true;
      let power = CLEAN_POWER * powerMult * dt;
      // Sludge cleans slower without magnet
      if (dirt.type === 'sludge' && !hasMagnet) power *= 0.4;
      // Leaves clean faster
      if (dirt.type === 'leaves') power *= 1.5;

      dirt.hp -= power;

      // Spawn spray particles toward this dirt
      if (Math.random() < 0.3) {
        spawnSprayParticle(state.botX, state.botY, dirt.x, dirt.y, dirt.type);
      }

      if (dirt.hp <= 0) {
        dirt.hp = 0;
        dirt.alive = false;
        onDirtCleared(dirt);
      }
    }
  }
  state.isCleaning = anyCleaning;
}

function onDirtCleared(dirt) {
  // Clean reveal pulse
  spawnRevealPulse(dirt.x, dirt.y);
  // Check target tags
  if (dirt.targetTag) {
    for (const target of state.targets) {
      if (target.type === 'clean_dirt' && target.dirtTag === dirt.targetTag) {
        target.current = Math.min(target.current + 1, target.amount);
      }
    }
  }
  // Check area threshold targets
  checkAreaTargets();
  // Combo
  onCleanForCombo();
}

function checkAreaTargets() {
  for (const target of state.targets) {
    if (target.type !== 'clean_area') continue;
    const total = state.dirtNodes.filter(d => !target.areaId || d.areaId === target.areaId).length;
    const cleared = state.dirtNodes.filter(d => (!target.areaId || d.areaId === target.areaId) && !d.alive).length;
    if (total > 0) {
      target.current = cleared / total;
    }
  }
}
```

- [ ] **Step 2: Add dirt rendering to the Renderer**

Insert into the `render()` function, after arena background and before bot rendering:

```javascript
function renderDirt() {
  for (const dirt of state.dirtNodes) {
    if (!dirt.alive && dirt.type !== 'sludge') continue; // keep dead sludge for area display
    if (!dirt.alive) continue;

    const ratio = dirt.hp / dirt.maxHP;
    const currentRX = dirt.radiusX * (0.3 + 0.7 * ratio); // shrinks as cleaned
    const currentRY = dirt.radiusY * (0.3 + 0.7 * ratio);

    ctx.save();
    ctx.globalAlpha = 0.3 + 0.7 * ratio; // fades as cleaned

    if (dirt.locked) {
      ctx.globalAlpha *= 0.5; // dimmed if locked
    }

    // Dirt color by type
    let color;
    if (dirt.type === 'mud') color = COL_MUD;
    else if (dirt.type === 'leaves') color = COL_LEAVES;
    else if (dirt.type === 'sludge') color = COL_SLUDGE;

    // Main dirt ellipse
    ctx.beginPath();
    ctx.ellipse(dirt.x, dirt.y, currentRX, currentRY, 0, 0, Math.PI * 2);
    ctx.fillStyle = color;
    ctx.fill();

    // Depth rim (bottom edge darker for tilt feel)
    ctx.beginPath();
    ctx.ellipse(dirt.x, dirt.y + 2, currentRX, currentRY * 0.6, 0, 0, Math.PI);
    ctx.fillStyle = 'rgba(0,0,0,0.15)';
    ctx.fill();

    // Clean ground reveal behind (draw a bright patch where dirt was)
    if (ratio < 0.8) {
      const revealRX = dirt.radiusX * (1 - ratio) * 0.8;
      const revealRY = dirt.radiusY * (1 - ratio) * 0.8;
      ctx.beginPath();
      ctx.ellipse(dirt.x, dirt.y, revealRX, revealRY, 0, 0, Math.PI * 2);
      ctx.fillStyle = COL_GRASS_CLEAN;
      ctx.globalAlpha = (1 - ratio) * 0.4;
      ctx.fill();
    }

    ctx.restore();
  }
}
```

- [ ] **Step 3: Implement Level 1 dirt layout in loadLevel**

```javascript
function loadLevel(level) {
  const lvl = state.levelIndex;

  if (lvl === 0) {
    // Level 1: mud only, 12 patches, some near starting position for instant satisfaction
    spawnDirt([
      // Near start (bot starts at CANVAS_W/2, CANVAS_H*0.7)
      { x: 380, y: 420, type: 'mud' },
      { x: 440, y: 400, type: 'mud' },
      { x: 350, y: 380, type: 'mud' },
      // Mid area
      { x: 200, y: 300, type: 'mud' },
      { x: 300, y: 250, type: 'mud' },
      { x: 500, y: 280, type: 'mud' },
      { x: 600, y: 320, type: 'mud' },
      // Far area
      { x: 150, y: 150, type: 'mud' },
      { x: 350, y: 120, type: 'mud' },
      { x: 550, y: 160, type: 'mud' },
      { x: 680, y: 200, type: 'mud' },
      { x: 250, y: 480, type: 'mud' },
    ]);
    // Objects added in Task 3
  }
  // Levels 2 and 3 added in Task 6
}
```

- [ ] **Step 4: Wire updateDirt into the game loop**

In the `gameLoop`, inside the `if (state.screen === 'gameplay')` block, add after `updateBot(dt)`:

```javascript
updateDirt(dt);
```

In `render()`, call `renderDirt()` after the arena background and before `renderBot()`.

- [ ] **Step 5: Add stub particle functions** (full implementation in Task 5)

```javascript
// ===== PARTICLE SYSTEM (stubs, full impl in Task 5) =====
function spawnSprayParticle(fromX, fromY, toX, toY, dirtType) { /* Task 5 */ }
function spawnRevealPulse(x, y) { /* Task 5 */ }
function onCleanForCombo() { /* Task 5 */ }
function updateParticles(dt) { /* Task 5 */ }
function renderParticles() { /* Task 5 */ }
```

- [ ] **Step 6: Verify in browser**

Open `index.html`, click START.
- Expected: ~12 brown elliptical dirt patches scattered across backyard. Several near the bot's start position.
- Move mouse: bot follows cursor. When bot radius overlaps a dirt patch, the patch shrinks and fades.
- Dirt near start cleans within 2-3 seconds of first movement (immediate satisfaction).
- Fully cleaned dirt disappears.

- [ ] **Step 7: Commit**

```bash
git add index.html
git commit -m "feat: dirt system with auto-cleaning and visual feedback"
```

---

### Task 3: Target Objects, Target Tracker, HUD

Add cleanable target objects (flower pots for level 1), track completion against target cards, display progress in the HUD.

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Implement Object System**

```javascript
// ===== OBJECT SYSTEM =====
function spawnObjects(defs) {
  for (const def of defs) {
    state.objects.push({
      id: def.id || `obj_${state.objects.length}`,
      x: def.x,
      y: def.y,
      type: def.type,           // 'pot' | 'bench' | 'birdbath'
      maxHP: def.hp || 80,
      hp: def.hp || 80,
      radiusX: def.radiusX || 20,
      radiusY: def.radiusY || 14,
      cleaned: false,
      locked: def.locked || false,
      restoreRequired: def.restoreRequired || false, // needs sequence
      restoreReady: false,
      restored: false,
    });
  }
}

function updateObjects(dt) {
  const hasTurbo = state.activePowerUps.some(p => p.type === 'turbo');
  const radiusMult = hasTurbo ? TURBO_RADIUS_MULT : 1;
  const powerMult = hasTurbo ? TURBO_POWER_MULT : 1;

  for (const obj of state.objects) {
    if (obj.cleaned || obj.locked) continue;
    if (obj.restoreRequired && !obj.restoreReady) continue;

    const ed = ellipseDist(obj.x, obj.y, state.botX, state.botY,
      CLEAN_RADIUS_X * radiusMult, CLEAN_RADIUS_Y * radiusMult);

    if (ed < 1.0) {
      obj.hp -= CLEAN_POWER * powerMult * dt;
      if (obj.hp <= 0) {
        obj.hp = 0;
        obj.cleaned = true;
        if (obj.restoreRequired) obj.restored = true;
        onObjectCleaned(obj);
      }
    }
  }
}

function onObjectCleaned(obj) {
  // Sparkle burst
  spawnSparkleBurst(obj.x, obj.y);
  triggerShake(2);

  // Update targets
  for (const target of state.targets) {
    if (target.type === 'clean_object' && target.objectType === obj.type) {
      target.current = Math.min(target.current + 1, target.amount);
      onTargetProgress(target);
    }
    if (target.type === 'restore_object' && target.objectId === obj.id) {
      target.current = 1;
      onTargetProgress(target);
    }
  }

  checkWinCondition();
}

function onTargetProgress(target) {
  // HUD bounce animation
  const el = document.querySelector(`[data-target-id="${target.icon}"]`);
  if (el) {
    el.classList.remove('bounce');
    void el.offsetWidth; // trigger reflow
    el.classList.add('bounce');
  }
  // Play target chime if completed
  if ((target.type === 'clean_object' || target.type === 'clean_dirt') && target.current >= target.amount) {
    playTargetChime();
  }
  if (target.type === 'restore_object' && target.current >= 1) {
    playTargetChime();
  }
  if (target.type === 'clean_area' && target.current >= target.threshold) {
    playTargetChime();
  }
}
```

- [ ] **Step 2: Implement object rendering**

```javascript
function renderObjects() {
  for (const obj of state.objects) {
    const ratio = obj.hp / obj.maxHP;
    const cleanRatio = 1 - ratio; // 0=dirty, 1=clean

    ctx.save();

    if (obj.locked || (obj.restoreRequired && !obj.restoreReady)) {
      ctx.globalAlpha = 0.4;
    }

    if (obj.type === 'pot') {
      // Pot body (trapezoid with depth)
      const w = 24, h = 28;
      // Shadow
      ctx.beginPath();
      ctx.ellipse(obj.x, obj.y + h/2 + 4, w * 0.6, 4, 0, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.15)';
      ctx.fill();
      // Pot front
      ctx.fillStyle = lerpColor('#5a4030', '#c47040', cleanRatio);
      ctx.beginPath();
      ctx.moveTo(obj.x - w/2, obj.y - h/4);
      ctx.lineTo(obj.x + w/2, obj.y - h/4);
      ctx.lineTo(obj.x + w/3, obj.y + h/2);
      ctx.lineTo(obj.x - w/3, obj.y + h/2);
      ctx.closePath();
      ctx.fill();
      // Rim
      ctx.fillStyle = lerpColor('#6a5040', '#d48050', cleanRatio);
      ctx.fillRect(obj.x - w/2 - 2, obj.y - h/4 - 4, w + 4, 6);
      // Plant (appears as cleaned)
      if (cleanRatio > 0.3) {
        ctx.globalAlpha = cleanRatio;
        ctx.fillStyle = '#3a8a2a';
        ctx.beginPath();
        ctx.ellipse(obj.x, obj.y - h/2 - 6, 12 * cleanRatio, 10 * cleanRatio, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.globalAlpha = 1;
      }
      // Sparkle if fully clean
      if (obj.cleaned) {
        ctx.fillStyle = `rgba(255,255,200,${0.3 + 0.2 * Math.sin(Date.now() / 200)})`;
        ctx.beginPath();
        ctx.arc(obj.x + 8, obj.y - h/4, 3, 0, Math.PI * 2);
        ctx.fill();
      }
    } else if (obj.type === 'bench') {
      const w = 50, h = 20;
      // Shadow
      ctx.beginPath();
      ctx.ellipse(obj.x, obj.y + h/2 + 5, w * 0.5, 4, 0, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(0,0,0,0.15)';
      ctx.fill();
      // Legs
      ctx.fillStyle = lerpColor('#4a3a2a', '#8a6a4a', cleanRatio);
      ctx.fillRect(obj.x - w/2 + 4, obj.y, 4, h);
      ctx.fillRect(obj.x + w/2 - 8, obj.y, 4, h);
      // Seat top
      ctx.fillStyle = lerpColor('#5a4a3a', '#aa8a5a', cleanRatio);
      roundRect(ctx, obj.x - w/2, obj.y - 4, w, 8, 3);
      ctx.fill();
      // Front face
      ctx.fillStyle = lerpColor('#4a3a2a', '#9a7a4a', cleanRatio);
      ctx.fillRect(obj.x - w/2, obj.y, w, 4);
    } else if (obj.type === 'birdbath') {
      const r = 22;
      // Pedestal
      ctx.fillStyle = lerpColor('#5a5a5a', '#aaaaaa', cleanRatio);
      ctx.fillRect(obj.x - 6, obj.y, 12, 20);
      // Basin
      ctx.beginPath();
      ctx.ellipse(obj.x, obj.y, r, r * 0.6, 0, 0, Math.PI * 2);
      ctx.fillStyle = lerpColor('#4a4a4a', '#ccccdd', cleanRatio);
      ctx.fill();
      // Water (appears when restored)
      if (obj.restored) {
        ctx.beginPath();
        ctx.ellipse(obj.x, obj.y - 2, r * 0.7, r * 0.35, 0, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(100,180,255,${0.5 + 0.1 * Math.sin(Date.now() / 300)})`;
        ctx.fill();
      }
    }

    // Dirty overlay for unclean objects
    if (!obj.cleaned && ratio > 0.1) {
      ctx.beginPath();
      ctx.ellipse(obj.x, obj.y, obj.radiusX, obj.radiusY, 0, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(80,60,30,${ratio * 0.4})`;
      ctx.fill();
    }

    ctx.restore();
  }
}

function lerpColor(c1, c2, t) {
  // Simple hex lerp
  const r1 = parseInt(c1.slice(1,3), 16), g1 = parseInt(c1.slice(3,5), 16), b1 = parseInt(c1.slice(5,7), 16);
  const r2 = parseInt(c2.slice(1,3), 16), g2 = parseInt(c2.slice(3,5), 16), b2 = parseInt(c2.slice(5,7), 16);
  const r = Math.round(lerp(r1, r2, t)), g = Math.round(lerp(g1, g2, t)), b = Math.round(lerp(b1, b2, t));
  return `#${r.toString(16).padStart(2,'0')}${g.toString(16).padStart(2,'0')}${b.toString(16).padStart(2,'0')}`;
}
```

- [ ] **Step 3: Implement HUD Manager**

```javascript
// ===== HUD MANAGER =====
function updateHUD() {
  // Timer
  const timerEl = document.getElementById('hud-timer');
  const secs = Math.ceil(state.timer);
  const mins = Math.floor(secs / 60);
  const s = secs % 60;
  timerEl.textContent = `${mins}:${s.toString().padStart(2, '0')}`;
  timerEl.classList.toggle('warning', state.timer < 10);

  // Targets
  const targetsEl = document.getElementById('hud-targets');
  targetsEl.innerHTML = '';
  for (const t of state.targets) {
    const card = document.createElement('div');
    card.className = 'hud-target-card';
    card.dataset.targetId = t.icon;
    let progressText;
    if (t.type === 'clean_area') {
      progressText = `${Math.floor((t.current || 0) * 100)}%/${Math.floor(t.threshold * 100)}%`;
    } else if (t.type === 'restore_object') {
      progressText = t.current >= 1 ? '✓' : '○';
    } else {
      progressText = `${t.current}/${t.amount}`;
    }
    const done = (t.type === 'clean_area' && t.current >= t.threshold) ||
                 (t.type === 'restore_object' && t.current >= 1) ||
                 ((t.type === 'clean_object' || t.type === 'clean_dirt') && t.current >= t.amount);
    card.innerHTML = `<span class="target-icon">${t.icon}</span><span class="target-progress ${done ? 'done' : ''}">${progressText}</span>`;
    targetsEl.appendChild(card);
  }
}
```

- [ ] **Step 4: Implement Timer and Win/Fail logic**

```javascript
function updateTimer(dt) {
  state.timer -= dt;
  state.timerElapsed += dt;
  if (state.timer <= 0) {
    state.timer = 0;
    onLevelFail();
  }
}

function checkWinCondition() {
  const allDone = state.targets.every(t => {
    if (t.type === 'clean_object' || t.type === 'clean_dirt') return t.current >= t.amount;
    if (t.type === 'clean_area') return t.current >= t.threshold;
    if (t.type === 'restore_object') return t.current >= 1;
    return false;
  });
  if (allDone) onLevelWin();
}

function onLevelWin() {
  state.won = true;
  state.timeLeft = state.timer;
  if (state.timeLeft >= 10) state.stars = 3;
  else if (state.timeLeft >= 5) state.stars = 2;
  else state.stars = 1;
  playWinJingle();
  showScreen('result');
}

function onLevelFail() {
  state.won = false;
  playFailSound();
  showScreen('result');
}
```

- [ ] **Step 5: Add objects to Level 1 layout, wire updates into game loop**

Add to `loadLevel` inside the level 0 block:
```javascript
spawnObjects([
  { x: 150, y: 200, type: 'pot' },
  { x: 650, y: 180, type: 'pot' },
  { x: 300, y: 400, type: 'pot' },
  { x: 580, y: 450, type: 'pot' },
]);
```

Wire into game loop (inside gameplay update):
```javascript
updateTimer(dt);
updateBot(dt);
updateDirt(dt);
updateObjects(dt);
updateHUD();
```

Wire into render:
```javascript
renderDirt();
renderObjects();
renderBot();
```

- [ ] **Step 6: Add stub audio functions** (full implementation in Task 5)

```javascript
function playTargetChime() { /* Task 5 */ }
function playWinJingle() { /* Task 5 */ }
function playFailSound() { /* Task 5 */ }
function spawnSparkleBurst(x, y) { /* Task 5 */ }
```

- [ ] **Step 7: Add CSS for HUD**

```css
.hud-target-card {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 6px;
  padding: 4px 10px;
  margin-right: 6px;
  font-size: 13px;
}
.hud-target-card.bounce {
  animation: bounce 0.3s ease;
}
@keyframes bounce {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}
.target-progress.done {
  color: #8b7;
  font-weight: 700;
}
#hud-timer {
  background: rgba(255,180,0,0.2);
  border: 1px solid rgba(255,180,0,0.4);
  border-radius: 12px;
  padding: 4px 14px;
  color: #fb4;
  font-weight: 700;
  font-size: 15px;
}
#hud-timer.warning {
  color: #f44;
  border-color: rgba(255,60,60,0.5);
  animation: pulse 0.5s ease infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}
```

- [ ] **Step 8: Verify in browser**

Open `index.html`, click START.
- Expected: dirt patches AND 4 flower pots visible. Pots start dimmed/brownish.
- Move bot near a pot: pot gradually brightens, plant appears, sparkle appears when fully cleaned.
- HUD shows "🪴 0/4" → "🪴 1/4" etc. as pots are cleaned.
- Timer counts down from 0:45.
- Clean all 4 pots: win screen appears with stars and "Next Level" button.
- Let timer run out: fail screen appears with "So close!" and progress summary.

- [ ] **Step 9: Commit**

```bash
git add index.html
git commit -m "feat: target objects, HUD, timer, win/fail logic"
```

---

### Task 4: Locks, Power-Ups, Hazards

Add the gating, power-up, and hazard systems. This enables levels 2 and 3 to work with their full mechanics.

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Implement Lock System**

```javascript
// ===== LOCK SYSTEM =====
function spawnLocks(defs) {
  for (const def of defs) {
    state.locks.push({
      id: def.id || `lock_${state.locks.length}`,
      // Visual barrier
      x: def.x, y: def.y,
      width: def.width || 80,
      height: def.height || 10,
      // Condition: which dirt IDs must be cleared
      requiredDirtCleared: def.requiredDirtCleared || [],
      // Which dirt/object IDs are locked behind this
      unlocksDirt: def.unlocksDirt || [],
      unlocksObjects: def.unlocksObjects || [],
      open: false,
      dissolveProgress: 0, // 0=closed, 1=fully dissolved
    });
  }
}

function updateLocks(dt) {
  for (const lock of state.locks) {
    if (lock.open) {
      lock.dissolveProgress = Math.min(1, lock.dissolveProgress + dt * 2);
      continue;
    }
    // Check if all required dirt is cleared
    const allCleared = lock.requiredDirtCleared.every(id => {
      const d = state.dirtNodes.find(n => n.id === id);
      return d && !d.alive;
    });
    if (allCleared) {
      lock.open = true;
      // Unlock dirt and objects behind this lock
      for (const dirtId of lock.unlocksDirt) {
        const d = state.dirtNodes.find(n => n.id === dirtId);
        if (d) d.locked = false;
      }
      for (const objId of lock.unlocksObjects) {
        const o = state.objects.find(n => n.id === objId);
        if (o) o.locked = false;
      }
      triggerShake(3);
      spawnRevealPulse(lock.x, lock.y);
    }
  }
}

function renderLocks() {
  for (const lock of state.locks) {
    if (lock.dissolveProgress >= 1) continue;
    ctx.save();
    ctx.globalAlpha = 1 - lock.dissolveProgress;
    // Gate visual: wooden fence segment
    ctx.fillStyle = '#7a6a4a';
    ctx.fillRect(lock.x - lock.width/2, lock.y - lock.height/2, lock.width, lock.height);
    // Fence pickets
    const picketCount = Math.floor(lock.width / 12);
    for (let i = 0; i < picketCount; i++) {
      const px = lock.x - lock.width/2 + i * 12 + 2;
      ctx.fillStyle = '#8a7a5a';
      ctx.fillRect(px, lock.y - lock.height/2 - 6, 8, lock.height + 12);
      ctx.fillStyle = '#6a5a3a';
      ctx.fillRect(px, lock.y - lock.height/2 - 6, 8, 2);
    }
    // Lock icon
    if (!lock.open) {
      ctx.fillStyle = 'rgba(255,255,255,0.6)';
      ctx.font = '16px system-ui';
      ctx.textAlign = 'center';
      ctx.fillText('🔒', lock.x, lock.y + 5);
    }
    ctx.restore();
  }
}
```

- [ ] **Step 2: Implement Power-Up System**

```javascript
// ===== POWER-UP SYSTEM =====
function spawnPowerUpDefs(defs) {
  for (const def of defs) {
    state.powerUps.push({
      id: def.id || `pu_${state.powerUps.length}`,
      x: def.x, y: def.y,
      type: def.type,         // 'turbo' | 'magnet'
      spawnAfter: def.spawnAfter, // seconds elapsed before appearing
      duration: def.duration,
      visible: false,
      collected: false,
      bobOffset: Math.random() * Math.PI * 2,
    });
  }
}

function updatePowerUps(dt) {
  // Spawn check
  for (const pu of state.powerUps) {
    if (!pu.visible && !pu.collected && state.timerElapsed >= pu.spawnAfter) {
      pu.visible = true;
      spawnRevealPulse(pu.x, pu.y);
    }
  }
  // Collection check
  for (const pu of state.powerUps) {
    if (!pu.visible || pu.collected) continue;
    const d = dist(state.botX, state.botY, pu.x, pu.y);
    if (d < 30) {
      pu.collected = true;
      pu.visible = false;
      state.activePowerUps.push({ type: pu.type, remaining: pu.duration });
      triggerShake(3);
      spawnPowerUpCollectEffect(pu.x, pu.y, pu.type);
      playPowerUpCollect();
      updatePowerUpHUD();
    }
  }
  // Tick active power-ups
  for (let i = state.activePowerUps.length - 1; i >= 0; i--) {
    state.activePowerUps[i].remaining -= dt;
    if (state.activePowerUps[i].remaining <= 0) {
      state.activePowerUps.splice(i, 1);
    }
  }
  updatePowerUpHUD();
}

function updatePowerUpHUD() {
  const el = document.getElementById('hud-powerup');
  if (state.activePowerUps.length === 0) {
    el.classList.add('hidden');
    return;
  }
  el.classList.remove('hidden');
  const active = state.activePowerUps[0];
  const icon = active.type === 'turbo' ? '⚡' : '🧲';
  const name = active.type === 'turbo' ? 'Turbo Spray' : 'Sludge Magnet';
  el.textContent = `${icon} ${name} — ${Math.ceil(active.remaining)}s`;
}

function renderPowerUps() {
  for (const pu of state.powerUps) {
    if (!pu.visible || pu.collected) continue;
    const bob = Math.sin(Date.now() / 1000 * POWERUP_BOB_SPEED + pu.bobOffset) * POWERUP_BOB_AMP;

    ctx.save();
    // Glow
    ctx.beginPath();
    ctx.arc(pu.x, pu.y + bob, 20, 0, Math.PI * 2);
    const glowColor = pu.type === 'turbo' ? 'rgba(68,170,255,0.2)' : 'rgba(255,170,68,0.2)';
    ctx.fillStyle = glowColor;
    ctx.fill();
    // Orb
    ctx.beginPath();
    ctx.arc(pu.x, pu.y + bob, 10, 0, Math.PI * 2);
    ctx.fillStyle = pu.type === 'turbo' ? '#44aaff' : '#ffaa44';
    ctx.fill();
    ctx.strokeStyle = '#fff';
    ctx.lineWidth = 2;
    ctx.stroke();
    // Icon
    ctx.font = '14px system-ui';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(pu.type === 'turbo' ? '⚡' : '🧲', pu.x, pu.y + bob);
    ctx.restore();
  }
}
```

- [ ] **Step 3: Implement Hazard System**

```javascript
// ===== HAZARD SYSTEM =====
function spawnHazards(defs) {
  for (const def of defs) {
    state.hazards.push({
      id: def.id || `haz_${state.hazards.length}`,
      x: def.x, y: def.y,
      type: def.type,          // 'recontamination_vent'
      respawnInterval: def.respawnInterval || HAZARD_RESPAWN_INTERVAL,
      respawnRadius: def.respawnRadius || HAZARD_RESPAWN_RADIUS,
      respawnTimer: def.respawnInterval || HAZARD_RESPAWN_INTERVAL,
      puffTimer: 0,
    });
  }
}

function updateHazards(dt) {
  for (const haz of state.hazards) {
    if (haz.type === 'recontamination_vent') {
      haz.respawnTimer -= dt;
      haz.puffTimer -= dt;
      if (haz.respawnTimer <= 0) {
        haz.respawnTimer = haz.respawnInterval;
        haz.puffTimer = 0.5; // puff visual duration
        // Respawn a mud patch near the vent
        const angle = Math.random() * Math.PI * 2;
        const r = Math.random() * haz.respawnRadius;
        const nx = haz.x + Math.cos(angle) * r;
        const ny = haz.y + Math.sin(angle) * r;
        // Only if inside arena
        if (nx > 30 && nx < CANVAS_W - 30 && ny > 30 && ny < CANVAS_H - 30) {
          spawnDirt([{
            x: nx, y: ny, type: 'mud',
            radiusX: 16, radiusY: 10, hp: 40,
            areaId: 'main',
          }]);
        }
      }
    }
  }
}

function renderHazards() {
  for (const haz of state.hazards) {
    ctx.save();
    // Dark vent grate
    ctx.fillStyle = '#2a2a2a';
    ctx.beginPath();
    ctx.ellipse(haz.x, haz.y, 18, 12, 0, 0, Math.PI * 2);
    ctx.fill();
    // Grate lines
    ctx.strokeStyle = '#4a4a4a';
    ctx.lineWidth = 2;
    for (let i = -2; i <= 2; i++) {
      ctx.beginPath();
      ctx.moveTo(haz.x + i * 6, haz.y - 10);
      ctx.lineTo(haz.x + i * 6, haz.y + 10);
      ctx.stroke();
    }
    // Puff animation
    if (haz.puffTimer > 0) {
      const puffAlpha = haz.puffTimer / 0.5;
      ctx.beginPath();
      ctx.arc(haz.x, haz.y - 8, 15 * (1 - haz.puffTimer / 0.5), 0, Math.PI * 2);
      ctx.fillStyle = `rgba(80,60,30,${puffAlpha * 0.4})`;
      ctx.fill();
    }
    // Warning icon
    ctx.font = '12px system-ui';
    ctx.textAlign = 'center';
    ctx.fillText('⚠️', haz.x, haz.y - 18);
    ctx.restore();
  }
}
```

- [ ] **Step 4: Implement restore-readiness check for bird bath sequence**

Add to `onDirtCleared`:
```javascript
// Check if any restore objects become ready
for (const obj of state.objects) {
  if (!obj.restoreRequired || obj.restoreReady) continue;
  // Check: all sludge within 80px of this object must be cleared
  const nearSludge = state.dirtNodes.filter(d =>
    d.type === 'sludge' && dist(d.x, d.y, obj.x, obj.y) < 80
  );
  if (nearSludge.every(d => !d.alive)) {
    obj.restoreReady = true;
    spawnRevealPulse(obj.x, obj.y);
  }
}
```

- [ ] **Step 5: Wire locks, power-ups, hazards into game loop and renderer**

Game loop additions (inside gameplay update, after existing updates):
```javascript
updateLocks(dt);
updatePowerUps(dt);
updateHazards(dt);
```

Render order (from back to front):
```javascript
renderDirt();
renderLocks();
renderObjects();
renderHazards();
renderPowerUps();
renderBot();
renderParticles();
```

- [ ] **Step 6: Add stub for new audio/particle functions**

```javascript
function spawnPowerUpCollectEffect(x, y, type) { /* Task 5 */ }
function playPowerUpCollect() { /* Task 5 */ }
```

- [ ] **Step 7: Verify in browser**

For now, only Level 1 is populated, but the systems exist. Verify:
- Power-up, lock, and hazard arrays are empty for Level 1 — no errors, no rendering.
- Level 1 still plays correctly: clean pots, win/fail works.

- [ ] **Step 8: Commit**

```bash
git add index.html
git commit -m "feat: lock, power-up, and hazard systems"
```

---

### Task 5: Particle System and Audio Engine

Add all juice: spray particles, clean reveal pulses, sparkle bursts, combo counter, and synthesized audio. This is what makes cleaning *feel* satisfying.

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Implement full Particle System**

Replace the stub particle functions:

```javascript
// ===== PARTICLE SYSTEM =====
function spawnParticle(props) {
  state.particles.push({
    x: props.x, y: props.y,
    vx: props.vx || 0, vy: props.vy || 0,
    life: props.life || 1,
    maxLife: props.life || 1,
    size: props.size || 3,
    color: props.color || COL_SPRAY,
    type: props.type || 'dot',  // 'dot' | 'ring' | 'text'
    text: props.text || '',
    shrink: props.shrink !== false,
    gravity: props.gravity || 0,
    friction: props.friction || 1,
  });
}

function spawnSprayParticle(fromX, fromY, toX, toY, dirtType) {
  const angle = Math.atan2(toY - fromY, toX - fromX) + randRange(-0.5, 0.5);
  const speed = randRange(60, 120);
  const color = dirtType === 'sludge'
    ? `rgba(${randInt(30,60)},${randInt(30,50)},${randInt(20,30)},0.8)`
    : COL_SPRAY;
  spawnParticle({
    x: fromX + Math.cos(angle) * 15,
    y: fromY + Math.sin(angle) * 10,
    vx: Math.cos(angle) * speed,
    vy: Math.sin(angle) * speed,
    life: randRange(0.2, 0.4),
    size: randRange(2, 4),
    color,
  });
}

function spawnRevealPulse(x, y) {
  spawnParticle({
    x, y, vx: 0, vy: 0,
    life: 0.5,
    size: 5,
    color: 'rgba(255,255,255,0.6)',
    type: 'ring',
    shrink: false,
  });
  // Play dirt clear pop
  playDirtClearPop();
}

function spawnSparkleBurst(x, y) {
  for (let i = 0; i < 12; i++) {
    const angle = (i / 12) * Math.PI * 2 + randRange(-0.2, 0.2);
    const speed = randRange(40, 100);
    spawnParticle({
      x, y,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed - 20,
      life: randRange(0.4, 0.8),
      size: randRange(2, 5),
      color: `rgba(255,${randInt(200,255)},${randInt(50,150)},0.9)`,
      gravity: 80,
    });
  }
}

function spawnPowerUpCollectEffect(x, y, type) {
  const color = type === 'turbo' ? 'rgba(68,170,255,0.8)' : 'rgba(255,170,68,0.8)';
  // Ring burst
  spawnParticle({ x, y, life: 0.6, size: 10, color, type: 'ring', shrink: false });
  // Particles
  for (let i = 0; i < 16; i++) {
    const angle = (i / 16) * Math.PI * 2;
    spawnParticle({
      x, y,
      vx: Math.cos(angle) * 80,
      vy: Math.sin(angle) * 60,
      life: 0.5,
      size: 3,
      color,
    });
  }
}

function onCleanForCombo() {
  if (state.comboTimer > 0) {
    state.comboCount++;
  } else {
    state.comboCount = 1;
  }
  state.comboTimer = COMBO_WINDOW;
  if (state.comboCount >= 2) {
    // Floating combo text
    spawnParticle({
      x: state.botX + randRange(-10, 10),
      y: state.botY - 30,
      vx: 0, vy: -30,
      life: 0.8,
      size: 14 + state.comboCount,
      color: `rgba(255,${Math.max(100, 255 - state.comboCount * 20)},50,0.9)`,
      type: 'text',
      text: `x${state.comboCount}`,
    });
    playComboSound();
  }
}

function updateCombo(dt) {
  if (state.comboTimer > 0) {
    state.comboTimer -= dt;
    if (state.comboTimer <= 0) {
      state.comboCount = 0;
    }
  }
}

function updateParticles(dt) {
  for (let i = state.particles.length - 1; i >= 0; i--) {
    const p = state.particles[i];
    p.life -= dt;
    if (p.life <= 0) {
      state.particles.splice(i, 1);
      continue;
    }
    p.vx *= p.friction;
    p.vy *= p.friction;
    p.vy += p.gravity * dt;
    p.x += p.vx * dt;
    p.y += p.vy * dt;
  }
}

function renderParticles() {
  for (const p of state.particles) {
    const lifeRatio = p.life / p.maxLife;
    ctx.save();
    ctx.globalAlpha = lifeRatio;

    if (p.type === 'ring') {
      const ringSize = p.size + (1 - lifeRatio) * 40;
      ctx.beginPath();
      ctx.arc(p.x, p.y, ringSize, 0, Math.PI * 2);
      ctx.strokeStyle = p.color;
      ctx.lineWidth = 2 * lifeRatio;
      ctx.stroke();
    } else if (p.type === 'text') {
      ctx.font = `bold ${p.size}px system-ui`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillStyle = p.color;
      ctx.fillText(p.text, p.x, p.y);
    } else {
      const s = p.shrink ? p.size * lifeRatio : p.size;
      ctx.beginPath();
      ctx.arc(p.x, p.y, s, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.fill();
    }

    ctx.restore();
  }
}
```

- [ ] **Step 2: Implement Audio Engine**

```javascript
// ===== AUDIO ENGINE =====
function getAudioCtx() {
  if (!state.audioCtx) {
    state.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  if (state.audioCtx.state === 'suspended') {
    state.audioCtx.resume();
  }
  return state.audioCtx;
}

function playTone(freq, duration, type = 'sine', volume = 0.15) {
  const ctx = getAudioCtx();
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(freq, ctx.currentTime);
  gain.gain.setValueAtTime(volume, ctx.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(ctx.currentTime);
  osc.stop(ctx.currentTime + duration);
}

function playDirtClearPop() {
  const baseFreq = 600 + state.comboCount * 40;
  playTone(baseFreq, 0.12, 'sine', 0.1);
  playTone(baseFreq * 1.5, 0.08, 'sine', 0.05);
}

function playTargetChime() {
  playTone(880, 0.15, 'sine', 0.15);
  setTimeout(() => playTone(1100, 0.2, 'sine', 0.12), 100);
}

function playPowerUpCollect() {
  const ctx = getAudioCtx();
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = 'sine';
  osc.frequency.setValueAtTime(400, ctx.currentTime);
  osc.frequency.exponentialRampToValueAtTime(1200, ctx.currentTime + 0.3);
  gain.gain.setValueAtTime(0.15, ctx.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.4);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(ctx.currentTime);
  osc.stop(ctx.currentTime + 0.4);
}

function playComboSound() {
  const freq = 500 + state.comboCount * 60;
  playTone(freq, 0.1, 'triangle', 0.08);
}

function playWinJingle() {
  [523, 659, 784, 1047].forEach((freq, i) => {
    setTimeout(() => playTone(freq, 0.3, 'sine', 0.12), i * 120);
  });
}

function playFailSound() {
  playTone(400, 0.3, 'sine', 0.12);
  setTimeout(() => playTone(300, 0.4, 'sine', 0.1), 150);
}

function playTimerTick() {
  playTone(800, 0.05, 'square', 0.06);
}

// Spray loop sound
let sprayGainNode = null;
let sprayNoiseNode = null;

function updateSpraySound() {
  const ctx = getAudioCtx();
  if (state.isCleaning && state.screen === 'gameplay') {
    if (!sprayNoiseNode) {
      // Create white noise
      const bufferSize = ctx.sampleRate * 2;
      const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
      }
      sprayNoiseNode = ctx.createBufferSource();
      sprayNoiseNode.buffer = buffer;
      sprayNoiseNode.loop = true;
      // Bandpass filter for softer hiss
      const filter = ctx.createBiquadFilter();
      filter.type = 'bandpass';
      filter.frequency.value = 3000;
      filter.Q.value = 0.5;
      sprayGainNode = ctx.createGain();
      sprayGainNode.gain.value = 0;
      sprayNoiseNode.connect(filter);
      filter.connect(sprayGainNode);
      sprayGainNode.connect(ctx.destination);
      sprayNoiseNode.start();
    }
    // Fade in
    sprayGainNode.gain.setTargetAtTime(0.04, ctx.currentTime, 0.1);
  } else if (sprayGainNode) {
    // Fade out
    sprayGainNode.gain.setTargetAtTime(0, ctx.currentTime, 0.1);
  }
}

// Timer tick tracking
let lastTickSecond = -1;

function updateTimerTick() {
  if (state.screen !== 'gameplay') return;
  const secs = Math.ceil(state.timer);
  if (secs <= 10 && secs > 0 && secs !== lastTickSecond) {
    lastTickSecond = secs;
    playTimerTick();
  }
}
```

- [ ] **Step 3: Wire particles, combo, and audio into game loop**

Add to gameplay update section:
```javascript
updateCombo(dt);
updateParticles(dt);
updateSpraySound();
updateTimerTick();
```

Add `renderParticles()` as the last render call (after bot).

- [ ] **Step 4: Verify in browser**

Click START, play Level 1:
- Expected: blue/white spray particles emit from bot toward dirt while cleaning.
- Dirt clear: white ring pulse expands, short pop sound.
- Cleaning multiple dirt in quick succession: floating "x2", "x3" combo text near bot, sounds rise in pitch.
- Pot cleaned: yellow/white sparkle burst, satisfying chime.
- Soft hiss sound while actively cleaning, fades when not cleaning.
- Timer under 10s: tick sounds accelerate, timer turns red and pulses.
- Win: ascending jingle. Fail: descending tone.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: particle system, audio engine, combo tracker"
```

---

### Task 6: Level 2 and Level 3 Data

Populate levels 2 and 3 with their complete dirt layouts, objects, locks, power-ups, and hazards as specified in the design.

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Expand loadLevel for Level 2 — "Garden Path"**

Add to `loadLevel`, `else if (lvl === 1)`:

```javascript
else if (lvl === 1) {
  // Level 2: mud + leaves, locked zone, 1 bench behind gate
  // Main area dirt
  spawnDirt([
    // Near start
    { id: 'l2_mud1', x: 360, y: 420, type: 'mud', targetTag: 'target_mud' },
    { id: 'l2_mud2', x: 440, y: 380, type: 'mud', targetTag: 'target_mud' },
    { id: 'l2_mud3', x: 280, y: 350, type: 'mud', targetTag: 'target_mud' },
    // Gate-blocking mud
    { id: 'l2_gate_mud1', x: 580, y: 250, type: 'mud' },
    { id: 'l2_gate_mud2', x: 620, y: 260, type: 'mud' },
    // More target mud
    { id: 'l2_mud4', x: 200, y: 200, type: 'mud', targetTag: 'target_mud' },
    { id: 'l2_mud5', x: 350, y: 150, type: 'mud', targetTag: 'target_mud' },
    { id: 'l2_mud6', x: 150, y: 400, type: 'mud', targetTag: 'target_mud' },
    // Behind gate (2 more mud)
    { id: 'l2_locked_mud1', x: 650, y: 150, type: 'mud', locked: true },
    { id: 'l2_locked_mud2', x: 700, y: 180, type: 'mud', locked: true },
  ]);
  // Leaves
  spawnDirt([
    { x: 180, y: 280, type: 'leaves' },
    { x: 250, y: 180, type: 'leaves' },
    { x: 420, y: 200, type: 'leaves' },
    { x: 500, y: 350, type: 'leaves' },
    { x: 320, y: 480, type: 'leaves' },
    { x: 600, y: 400, type: 'leaves' },
    { x: 130, y: 320, type: 'leaves' },
    { x: 480, y: 150, type: 'leaves' },
  ]);

  // Objects: 1 bench in main area, 1 behind gate
  spawnObjects([
    { id: 'l2_bench1', x: 200, y: 450, type: 'bench' },
    { id: 'l2_bench2', x: 680, y: 120, type: 'bench', locked: true },
  ]);

  // Lock: gate at right side, opened by clearing gate_mud1 and gate_mud2
  spawnLocks([{
    id: 'l2_gate',
    x: 610, y: 200, width: 60, height: 8,
    requiredDirtCleared: ['l2_gate_mud1', 'l2_gate_mud2'],
    unlocksDirt: ['l2_locked_mud1', 'l2_locked_mud2'],
    unlocksObjects: ['l2_bench2'],
  }]);

  // Power-up: Turbo Spray at 15s elapsed
  spawnPowerUpDefs([{
    x: 400, y: 280, type: 'turbo',
    spawnAfter: 15, duration: 8,
  }]);
}
```

- [ ] **Step 2: Expand loadLevel for Level 3 — "Backyard Blitz"**

Add `else if (lvl === 2)`:

```javascript
else if (lvl === 2) {
  // Level 3: all dirt types, 2 locks, bird bath restore, recontamination vent
  // Main area mud
  spawnDirt([
    { id: 'l3_mud1', x: 360, y: 400, type: 'mud', areaId: 'main' },
    { id: 'l3_mud2', x: 200, y: 350, type: 'mud', areaId: 'main' },
    { id: 'l3_mud3', x: 500, y: 380, type: 'mud', areaId: 'main' },
    { id: 'l3_mud4', x: 300, y: 250, type: 'mud', areaId: 'main' },
    // Gate-blocking mud
    { id: 'l3_gate1_mud', x: 150, y: 200, type: 'mud', areaId: 'main' },
    { id: 'l3_gate2_mud1', x: 600, y: 300, type: 'mud', areaId: 'main' },
    { id: 'l3_gate2_mud2', x: 640, y: 280, type: 'mud', areaId: 'main' },
    // Behind gate 1
    { id: 'l3_locked1_mud', x: 100, y: 120, type: 'mud', areaId: 'main', locked: true },
  ]);
  // Leaves
  spawnDirt([
    { x: 250, y: 420, type: 'leaves', areaId: 'main' },
    { x: 450, y: 200, type: 'leaves', areaId: 'main' },
    { x: 350, y: 480, type: 'leaves', areaId: 'main' },
    { x: 550, y: 150, type: 'leaves', areaId: 'main' },
    { x: 150, y: 450, type: 'leaves', areaId: 'main' },
    { x: 680, y: 400, type: 'leaves', areaId: 'main' },
  ]);
  // Sludge (near bird bath)
  spawnDirt([
    { id: 'l3_sludge1', x: 660, y: 150, type: 'sludge', areaId: 'main', locked: true },
    { id: 'l3_sludge2', x: 700, y: 170, type: 'sludge', areaId: 'main', locked: true },
    { id: 'l3_sludge3', x: 680, y: 120, type: 'sludge', areaId: 'main', locked: true },
    { id: 'l3_sludge4', x: 720, y: 140, type: 'sludge', areaId: 'main', locked: true },
  ]);

  // Bird bath — restore sequence: clean surrounding sludge, then clean bird bath
  spawnObjects([{
    id: 'birdbath', x: 690, y: 145, type: 'birdbath',
    hp: 60, locked: true, restoreRequired: true,
  }]);

  // Lock 1: left gate, opened by clearing gate1_mud
  spawnLocks([{
    id: 'l3_gate1',
    x: 130, y: 160, width: 50, height: 8,
    requiredDirtCleared: ['l3_gate1_mud'],
    unlocksDirt: ['l3_locked1_mud'],
    unlocksObjects: [],
  }]);
  // Lock 2: right gate to bird bath area, opened by gate2 muds
  spawnLocks([{
    id: 'l3_gate2',
    x: 640, y: 240, width: 60, height: 8,
    requiredDirtCleared: ['l3_gate2_mud1', 'l3_gate2_mud2'],
    unlocksDirt: ['l3_sludge1', 'l3_sludge2', 'l3_sludge3', 'l3_sludge4'],
    unlocksObjects: ['birdbath'],
  }]);

  // Hazard: recontamination vent in center-left
  spawnHazards([{
    x: 250, y: 300, type: 'recontamination_vent',
    respawnInterval: 4, respawnRadius: 50,
  }]);

  // Power-ups
  spawnPowerUpDefs([
    { x: 400, y: 300, type: 'turbo', spawnAfter: 15, duration: 8 },
    { x: 500, y: 250, type: 'magnet', spawnAfter: 10, duration: 6 },
  ]);
}
```

- [ ] **Step 3: Update LEVELS array with complete target definitions**

Ensure the LEVELS array matches exactly:

```javascript
const LEVELS = [
  {
    name: 'First Wash',
    timerSeconds: 45,
    startX: 400, startY: 420,
    targets: [
      { type: 'clean_object', icon: '🪴', label: 'Clean 4 pots', objectType: 'pot', amount: 4 }
    ],
  },
  {
    name: 'Garden Path',
    timerSeconds: 40,
    startX: 400, startY: 420,
    targets: [
      { type: 'clean_dirt', icon: '💧', label: 'Remove 6 mud', dirtTag: 'target_mud', amount: 6 },
      { type: 'clean_object', icon: '🪑', label: 'Clean 2 benches', objectType: 'bench', amount: 2 },
    ],
  },
  {
    name: 'Backyard Blitz',
    timerSeconds: 35,
    startX: 350, startY: 420,
    targets: [
      { type: 'clean_area', icon: '🧹', label: 'Clean to 80%', areaId: 'main', threshold: 0.8 },
      { type: 'restore_object', icon: '🛁', label: 'Restore bird bath', objectId: 'birdbath' },
    ],
  },
];
```

- [ ] **Step 4: Verify in browser**

Play through all 3 levels:

**Level 1:** Clean 4 pots, win. Click "Next Level."
**Level 2:** Clean 6 tagged mud patches + 2 benches. Verify:
- Gate with lock icon visible on right side
- Clean the 2 mud patches near gate → gate dissolves, locked area opens
- Bench behind gate becomes cleanable
- Turbo Spray orb appears ~15s in, collecting it widens cleaning radius for 8s
**Level 3:** Clean area to 80% + restore bird bath. Verify:
- Recontamination vent in center-left periodically respawns mud with puff animation
- Right gate blocks sludge + bird bath area
- Clean gate mud → sludge area opens
- Sludge Magnet orb appears ~10s in, makes sludge cleaning fast
- Clean all sludge near bird bath → bird bath becomes cleanable (restore ready)
- Clean bird bath → water appears, target completes
- Reach 80% clean + restored bird bath → win

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: level 2 and level 3 complete with all mechanics"
```

---

### Task 7: Polish Pass — Backyard Props, Responsive Sizing, Mobile, Final Styling

Add decorative backyard elements, ensure responsive canvas sizing works on mobile, polish all CSS, and add the "Prototype Complete" celebration after level 3.

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add decorative backyard props to the renderer**

Add a `renderProps()` function called after arena background, before dirt:

```javascript
function renderProps() {
  // Stepping stones (decorative)
  const stones = [
    { x: 100, y: 500 }, { x: 160, y: 480 }, { x: 220, y: 500 },
    { x: 700, y: 500 }, { x: 730, y: 470 },
  ];
  for (const s of stones) {
    ctx.beginPath();
    ctx.ellipse(s.x, s.y, 14, 8, 0, 0, Math.PI * 2);
    ctx.fillStyle = '#6a7a6a';
    ctx.fill();
    ctx.strokeStyle = '#5a6a5a';
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  // Corner bushes (non-interactive)
  const bushes = [
    { x: 30, y: 30 }, { x: CANVAS_W - 30, y: 30 },
    { x: 30, y: CANVAS_H - 30 }, { x: CANVAS_W - 30, y: CANVAS_H - 30 },
  ];
  for (const b of bushes) {
    ctx.beginPath();
    ctx.ellipse(b.x, b.y, 25, 18, 0, 0, Math.PI * 2);
    ctx.fillStyle = '#2a5a1a';
    ctx.fill();
    ctx.beginPath();
    ctx.ellipse(b.x + 8, b.y - 5, 18, 12, 0, 0, Math.PI * 2);
    ctx.fillStyle = '#3a6a2a';
    ctx.fill();
  }

  // Garden hose (decorative curved line)
  ctx.beginPath();
  ctx.moveTo(50, CANVAS_H - 50);
  ctx.bezierCurveTo(80, CANVAS_H - 100, 120, CANVAS_H - 80, 100, CANVAS_H - 60);
  ctx.strokeStyle = '#2a8a4a';
  ctx.lineWidth = 4;
  ctx.stroke();
}
```

- [ ] **Step 2: Ensure responsive sizing handles all viewports**

Update `resizeCanvas()` to handle portrait and landscape properly:

```javascript
function resizeCanvas() {
  const aspect = CANVAS_W / CANVAS_H;
  const maxW = window.innerWidth;
  const maxH = window.innerHeight;
  let w, h;
  if (maxW / maxH > aspect) {
    h = maxH;
    w = h * aspect;
  } else {
    w = maxW;
    h = w / aspect;
  }
  canvas.style.width = Math.floor(w) + 'px';
  canvas.style.height = Math.floor(h) + 'px';
  canvas.width = CANVAS_W;
  canvas.height = CANVAS_H;
  // Center canvas vertically
  canvas.style.position = 'absolute';
  canvas.style.left = Math.floor((maxW - w) / 2) + 'px';
  canvas.style.top = Math.floor((maxH - h) / 2) + 'px';
}
```

- [ ] **Step 3: Polish all CSS — complete stylesheet**

Finalize all styles: intro screen target cards, result screen stars (gold color), button hover/active, screen transitions. Ensure `.btn-secondary` style exists for the "Menu" button. Add `user-select: none` and `touch-action: manipulation` on body. Ensure all text is readable at mobile sizes.

Key CSS additions:
```css
/* Target cards on intro screen */
.intro-targets { display: flex; gap: 12px; margin: 16px 0; flex-wrap: wrap; justify-content: center; }
.target-card {
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 10px;
  padding: 12px 16px;
  text-align: center;
  min-width: 100px;
}
.target-icon { font-size: 24px; display: block; margin-bottom: 4px; }
.target-text { font-size: 13px; color: rgba(255,255,255,0.7); }

/* Result stars */
.result-stars { font-size: 32px; color: #fc4; letter-spacing: 4px; margin: 8px 0; }
.result-title.win { color: #8b7; font-size: 24px; font-weight: 800; }
.result-title.fail { color: #e66; font-size: 24px; font-weight: 800; }

/* Buttons */
.btn-secondary {
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.2);
  color: #fff;
  padding: 10px 24px;
  border-radius: 20px;
  font-size: 16px;
  cursor: pointer;
}

/* Power-up HUD */
#hud-powerup {
  position: fixed;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(255,200,0,0.15);
  border: 1px solid rgba(255,200,0,0.3);
  border-radius: 8px;
  padding: 6px 16px;
  font-size: 13px;
  color: #fc4;
}
```

- [ ] **Step 4: Add Prototype Complete celebration after level 3 win**

In `populateResultScreen()`, when `state.won && state.levelIndex >= LEVELS.length - 1`:

```javascript
resultIcon.textContent = '🎉';
resultTitle.textContent = 'Prototype Complete!';
resultTitle.className = 'result-title win';
resultStars.textContent = '';
resultSummary.innerHTML = 'All 3 levels cleared!<br><span style="color:rgba(255,255,255,0.5);font-size:13px;">Core loop validation ready for review.</span>';
const btn = document.createElement('button');
btn.className = 'btn-primary';
btn.textContent = 'Play Again';
btn.onclick = () => { state.levelIndex = 0; showScreen('intro'); };
resultButtons.innerHTML = '';
resultButtons.appendChild(btn);
```

- [ ] **Step 5: Add audio context initialization on first user interaction**

Ensure audio works on all browsers by initializing AudioContext on first click/touch:

```javascript
document.addEventListener('click', () => getAudioCtx(), { once: true });
document.addEventListener('touchstart', () => getAudioCtx(), { once: true });
```

- [ ] **Step 6: Final verification in browser**

Full playthrough:
- Open `index.html`: intro screen renders correctly with target cards and styling.
- Level 1: clean 4 pots. Spray particles, pop sounds, sparkle bursts, combo counter all working. Win → stars shown, "Next Level" button.
- Level 2: locked gate visible, target mud tracked, Turbo Spray spawns and works, gate opens on mud clear, bench behind gate cleanable. Win → "Next Level."
- Level 3: recontamination vent respawns mud, locked bird bath area, sludge magnet works, bird bath restores with water. Win → "Prototype Complete!" celebration.
- Fail a level: "Time's Up!" shows progress, retry works.
- Resize browser window: canvas scales correctly.
- Chrome DevTools device mode (mobile): touch input works, canvas fits screen.

- [ ] **Step 7: Commit**

```bash
git add index.html
git commit -m "feat: polish pass — props, responsive, mobile, final styling"
```

---

## Verification Checklist

After all 7 tasks, confirm:

- [ ] Level 1 playable: clean 4 pots, win within 45s
- [ ] Level 2 playable: clear 6 mud + 2 benches, locked gate works, Turbo Spray works
- [ ] Level 3 playable: 80% clean + restore bird bath, sludge + locks + hazard + magnet all work
- [ ] Spray particles emit during cleaning
- [ ] Clean reveal pulse on each dirt cleared
- [ ] Sparkle burst on each target object cleaned
- [ ] Combo counter floats near bot on chains
- [ ] Audio: spray hiss, dirt pop, target chime, power-up sweep, timer tick, win jingle, fail tone
- [ ] Timer warning (red pulse) under 10 seconds
- [ ] Screen shake on target completion and power-up collect
- [ ] Win screen shows stars based on remaining time
- [ ] Fail screen shows progress and "So close!"
- [ ] Prototype Complete after level 3
- [ ] Responsive canvas sizing works on mobile
- [ ] Touch input works
