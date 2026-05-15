# Prototype Spec — "Gamblers Table" Plugin × Idle Tycoon Archetype

> HTML prototype design for Claude Code. Scope: validate the **click-to-flip + buy more coins + helpers + sacrifice** loop faithful to the original Steam game (greenpixels & Bossforge, 2026-01). Target build time: 1–2 days for a single-page HTML/JS prototype with no backend.

> **Source verified:** Steam store page (2026), Kotaku (2026-01), AdventureGamers (2026), greenpixels itch devlog (2026-01-11), NeonLightsMedia community guide (2026).

---

## 1. Concept in one sentence

A click-to-flip idle game where the player **flips physical coins on a table** for a 50/50 cash-or-skull payout, buys more and bigger coins to fill the table, hires minions to auto-flip, and sacrifices runs to unlock permanent talents.

## 2. Plugin (core moment-to-moment)

**Click → Flip → 50/50 → Repeat**

- The table contains physical coin objects (start with 1 copper coin).
- Clicking a coin **flips it** with a coin-flip animation (~0.3s).
- Result is a 50/50 RNG:
  - **Dollar side** → instant cash payout (value = coin tier × upgrades)
  - **Skull side** → 1 Skull Token (cosmetic gacha currency)
- The player buys **more coins** (same or higher tier) to place on the table — more coins = more flips per click cycle.
- Helpers (minions) can be hired to auto-flip coins.
- Coins are physical objects on the table — they can be **pushed around** by mouse and may collide.

**Gesture properties:**
- Click: 0.1–0.2s.
- Bulkable: yes — rapid-clicking is the early game.
- Habituation: high, **by design** — player transitions to auto-flippers and helpers within 5–10 minutes.

## 3. Core loop (time-scale)

| Scale | What happens |
|---|---|
| Second | Click coin → flip animation → result side reveals → cash or skull particle to counter |
| Minute | Spam-click coins → buy more coins / upgrade flip-rate → table fills up → buy first helper |
| Session (3–5 min) | Open → collect any offline gains → flip cycle → upgrade pass → close |
| Day | 4–8 sessions, sacrifice (prestige) every 1–3 days for skill point |
| Week | New unlocked tables with global effects (out of prototype Phase 1) |

## 4. Prototype scope (what to build)

### MUST HAVE (Phase 1)
- **Table surface** — 2D top-down view with physical coin objects
- **Click-to-flip** — click a coin → flip animation → 50/50 result
- **Coin physics (simple)** — coins are draggable; they can collide and be pushed into corners (2D physics, very simple — overlap-push, no real momentum needed)
- **3 coin tiers:** Copper / Silver / Gold (Platinum + Diamond gated for later)
- **Currency HUD** — Cash and Skull Tokens counters
- **Upgrade shop:**
  - Buy more coins of current tier
  - Unlock next tier
  - Upgrade flip-speed (animation duration ↓)
  - Upgrade profit/flip (cash multiplier)
  - Buy auto-flipper (auto-clicks 1 coin per N seconds)
- **Helper hire** — buy "Minion" units, each auto-flips coins of a tier at fixed rate
- **Sacrifice (prestige)** — button appears at threshold; wipes table, awards 1 Skill Point
- **Skill tree (small)** — 5–6 permanent talents (e.g. "+10% cash/flip", "Auto-flippers 2× faster", "Start with 1 silver coin", "Oxidation 2× payout")
- **Oxidation mechanic** — copper coins left unclicked for 90 seconds enter "Oxidized" state with golden glow; next click pays 10× — alternative loop "ignore and return"
- **Skull gacha stub** — spend 10 Skull Tokens → roll random cosmetic hat for a helper (3–5 hats in prototype)
- **Save/load** — localStorage persist
- **Offline earnings** — calculated on tab focus from auto-flippers and helpers (cap 4h)

### NICE TO HAVE (Phase 2)
- 2nd unlockable table with global effect ("All silver coins +25% but copper disabled")
- Rewarded ad stub — "Watch ad for 2× boost (4h)"
- Daily login bonus
- 3 quest stubs ("Flip 50 coins", "Hire 1 minion", "Trigger 1 Oxidation")

### OUT OF SCOPE (don't build for prototype)
- BP / season system
- Multi-day events
- Real monetization beyond stubs
- Tutorial flow beyond first-flip tooltip
- Multiple unlockable tables with rich effects (1 alt table is the cap)
- Mobile responsive layout

## 5. Data model

```js
state = {
  cash: 0,
  skullTokens: 0,
  skillPoints: 0,
  sacrificeCount: 0,
  coins: [
    // { id, tier: 'copper'|'silver'|'gold', x, y, isOxidized: bool, lastClickedAt: timestamp }
  ],
  coinTiers: {
    copper:   { unlocked: true,  basePayout: 1,    buyCost: 10,   buyCostScale: 1.10 },
    silver:   { unlocked: false, basePayout: 10,   buyCost: 500,  buyCostScale: 1.10 },
    gold:     { unlocked: false, basePayout: 100,  buyCost: 25000,buyCostScale: 1.10 }
  },
  upgrades: {
    flipSpeed:   { level: 0, costBase: 50,   costScale: 1.5, effect: 'animDuration *= 0.9' },
    profitMult:  { level: 0, costBase: 100,  costScale: 1.5, effect: '+10% cash/flip per level' },
    autoFlipper: { level: 0, costBase: 200,  costScale: 1.6, effect: 'autoFlip 1 coin per (10/level)s' }
  },
  helpers: [
    { tier: 'copper', count: 0, costBase: 100,   costScale: 1.15, flipsPerSec: 1 },
    { tier: 'silver', count: 0, costBase: 5000,  costScale: 1.15, flipsPerSec: 0.5 },
    { tier: 'gold',   count: 0, costBase: 500000,costScale: 1.15, flipsPerSec: 0.25 }
  ],
  talents: [
    // { id, name, owned: bool, cost: 1, description }
    { id: 'cash_plus_10', name: '+10% Cash/flip', owned: false, cost: 1 },
    { id: 'auto_2x',      name: 'Auto-flippers 2× faster', owned: false, cost: 2 },
    { id: 'silver_start', name: 'Start with 1 Silver', owned: false, cost: 2 },
    { id: 'oxidation_2x', name: 'Oxidation pays 2× more', owned: false, cost: 3 },
    { id: 'skull_boost',  name: '+20% Skull drop', owned: false, cost: 2 },
    { id: 'fast_helpers', name: 'Helpers +25% rate', owned: false, cost: 3 }
  ],
  hats: { /* cosmetic, applied to random helper */ },
  sacrificeThreshold: 100000,    // cash to enable sacrifice
  lastSaved: 0
}
```

## 6. Core formulas

- **Single flip payout (when landing on dollar side):**
  `tier.basePayout × (1 + upgrades.profitMult.level × 0.1) × talentMultipliers × oxidizedMult`
- **50/50 outcome:** standard `Math.random() < 0.5` — dollar vs skull
- **Buy coin cost (n-th of tier):** `tier.buyCost × (tier.buyCostScale ^ ownedOfTier)`
- **Helper auto-flip rate:** `helper.flipsPerSec × (1 + (autoFlipperLevel × 0.1))`
- **Oxidation trigger:** copper coin with `lastClickedAt > 90000ms ago` → set `isOxidized = true`
- **Oxidized payout:** base × 10 (× talent bonus if owned)
- **Sacrifice reward:** `skillPointsGained = 1 + floor(log10(currentCash / sacrificeThreshold))`
- **Skull token drop:** 50% of flips (the skull side) — base rate 1 per skull-side flip

## 7. UI layout (text wireframe)

```
+-----------------------------------------------------------+
|  💵 CASH: $12,345    💀 Skulls: 23    ⭐ Skill Pts: 1     |
+-----------------------------------------------------------+
|                                                           |
|   ╔═══════════════════════════════════════════════════╗   |
|   ║                  TABLE                            ║   |
|   ║    🪙 🪙       🪙(✨oxidized)                     ║   |
|   ║                                                   ║   |
|   ║        🪙   🪙       🪙                           ║   |
|   ║                                                   ║   |
|   ║   🪙        🪙              🪙                    ║   |
|   ║                                                   ║   |
|   ╚═══════════════════════════════════════════════════╝   |
|   Click coins to flip. Drag to move. Leave copper for 90s.|
+-----------------------------------------------------------+
| SHOP                                                      |
| [Buy Copper Coin — $11]   Owned: 7                        |
| [Buy Silver Coin — $550]   (locked: requires $500 cash)   |
| [Upgrade Flip Speed — $50]   Lv 0                         |
| [Upgrade Profit/Flip — $100]  Lv 0                        |
| [Hire Copper Minion — $100]   Owned: 0                    |
+-----------------------------------------------------------+
| [🎰 Roll Hat (10 Skulls)]   [✨ SACRIFICE (Skill Pt: +1)]  |
| [⭐ Skill Tree]                                            |
+-----------------------------------------------------------+
```

### Skill Tree modal
```
   [+10% Cash/flip]  (1 pt)  [Owned]
       |
   [Auto-flippers 2× faster]  (2 pt)  [Available]
       |
   [Helpers +25% rate]  (3 pt)  [Locked]

   [Oxidation 2× more]  (3 pt)
   [Start with Silver]  (2 pt)
   [+20% Skull drop]    (2 pt)
```

## 8. Tuning targets (first-pass)

| Metric | Target |
|---|---|
| Time-to-first-flip | <5s (1 coin already on table) |
| Time-to-buy-2nd-coin | ~30s |
| Time-to-unlock-silver | 5–8 min |
| Time-to-first-helper | 3–5 min |
| Time-to-first-sacrifice | 15–25 min (run 1) |
| Coins on table at sacrifice point | 15–30 |
| First Oxidation hit (player-discovered) | 2–4 min (90s timer × discovery) |
| Skill points across first 3 sacrifices | 1, 2, 4 (super-linear scaling) |

## 9. Validation goals (what the prototype must prove)

1. **Does the click-to-flip 50/50 feel satisfying or punishing?** Watch for "I only got skulls" frustration patterns.
2. **Does the Oxidation alt-loop create interesting tension?** Player should learn to **not click** some copper coins.
3. **Does buying more coins (instead of bigger coins) feel meaningful?** Filling the table should feel like progression.
4. **Is the sacrifice/skill tree loop rewarding?** First sacrifice should produce visible permanent benefit.
5. **Do coins-as-objects with physics add to the feel, or feel pointless?** Test with vs without push/drag.

## 10. Critical design rules (do not violate)

- **The table has NO target zones, NO paytable, NO multiplier areas.** Value comes from coin tier × upgrades × oxidation, not position.
- **The 50/50 is real and uncompromising.** Don't soften it to 70/30 even if it feels bad — the skull side IS a reward (Skull Tokens for gacha).
- **Skulls are not "loss".** Both sides are wins, just different currencies. Frame UI accordingly (skull animation should feel good, not feel like a failure).
- **Sacrifice is meta-progression, not currency exchange.** Don't let player "trade cash for skill points" — they must commit to the wipe.
- **Oxidation is a 90s passive mechanic.** Don't shorten to 30s (kills the "leave and return" loop) or extend to 5 min (kills discoverability).

## 11. Out-of-scope decisions to flag for next iteration

- **Real gambling theme** — current scope is "casino aesthetic + coin flip". No roulette / slots / jackpot. Don't drift into real-money gambling territory.
- **Skull gacha depth** — prototype has 3–5 hats. Real game would need 50+ cosmetics + rarities + duplicate handling.
- **Unlockable tables economy** — only 1 alt table in prototype. Real game = 5–8 tables with synergistic effects.
- **Helper management UI** — minions are just numbers in prototype. Real game = visible minions on/around table with personalities.

---

## File structure suggested

```
/prototype-gamblers/
  index.html
  styles.css
  game.js           # core loop, state, save/load
  table.js          # coin objects, physics, click handling
  flip.js           # flip animation + 50/50 outcome
  shop.js           # shop, helpers, upgrades, skill tree
  oxidation.js      # 90s timer logic per coin
```

## Implementation hints

- **Coins as DOM elements** with absolute positioning + transform — easier than canvas for click handling and accessibility.
- **Simple physics:** each frame, if two coins overlap, push them apart by half the overlap vector. No momentum needed.
- **Oxidation visual:** add CSS class `.oxidized` with a golden glow animation; switch on after `Date.now() - lastClickedAt > 90000`.
- **Flip animation:** CSS transform `rotateY` with `transform-style: preserve-3d` and two face divs.
- **Mass-click feel:** if player holds mouse button or rapid-clicks, queue flips with small stagger — feels like a "wave" of flips.
