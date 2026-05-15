# Prototype Spec — "Scritchy Scratchy" Plugin × Prestige-Idle Archetype

> HTML prototype design for Claude Code. Scope: validate the **drag-to-reveal + skill-stop + per-card-type ruleset + prestige** loop faithful to the original Steam game (Lunch Money Games / Funday Games, 2026-03-18). Target build time: 1–2 days for a single-page HTML/JS prototype with no backend.

> **Source verified:** Steam store page (2026-03-18), Kotaku review (2026-03-27), Notebookcheck (2026-03-25), GamingHQ review (2026-04-01), scritchyscratchy.org (2026). Fan wiki used as indicative-only for paytables.

> **Note on archetype:** the source game IS already a prestige-idle clicker. Plugin and archetype are tightly coupled in the original. The F2P-prototype scope adds: daily quest stub, rewarded-ad stub, premium-card-pack stub on top of the faithful loop.

---

## 1. Concept in one sentence

A prestige-idle game where the player **drags their cursor across scratch-off lottery tickets** to reveal random payouts, must **strategically stop scratching** to avoid penalty symbols, buys progressively riskier card types with bigger expected payouts, and prestiges via the "Final Chance" card to unlock permanent perks.

## 2. Plugin (core moment-to-moment)

**Drag → Reveal → Skill-Stop → Cash Out**

- The player has cash. They buy a scratch card of a specific type (each type has its own ruleset and price).
- The card spawns with **randomly seeded** symbols hidden under a scratch coating.
- The player **drags** their cursor across the card. The scratched area expands like a paint brush (Area Size upgrade increases brush radius).
- Symbols are revealed proportionally to the % of their area uncovered.
- **Skill-stop:** a symbol's effect only triggers when **fully revealed** (e.g. >85% uncovered).
  - Good symbols → pay out instantly on full reveal.
  - **Penalty symbols** → deduct cash on full reveal. Player can see them peeking and choose to **stop scratching** to avoid them.
- Card finishes when player clicks "Cash Out" (lock in revealed gains) or fully scratches everything.

**Gesture properties:**
- Drag: continuous, attention-demanding.
- Per-card duration: 10–40s.
- Bulkable: no — single-card focus is the point.
- Habituation: handled by **Auto Scratcher** unlock in mid-late run, which automates scratching for low-tier cards.

## 3. Core loop (time-scale)

| Scale | What happens |
|---|---|
| Second | Drag cursor → coating wears off → symbol partially visible → tension as player decides "keep going or stop" |
| Minute | Buy card → scratch (10–40s) → cash out → buy next card or upgrade |
| Session (3–8 min) | Open → resume run → 5–15 cards scratched → maybe upgrade → close |
| Run (15–60 min) | Multiple sessions; ends when player buys "Final Chance" card → prestige |
| Day | 1–3 sessions, 0–2 prestiges depending on player |
| Week | F2P additions: daily quests, theme-pack cards, BP (out of Phase 1) |

## 4. Prototype scope (what to build)

### MUST HAVE (Phase 1)
- **Card shop** with 4 starter card types (one of each ruleset family):
  - **Quick Cash** (match-2-of-3) — low risk, low payout
  - **Apple Tree** (per-symbol accumulate, penalty on worm) — medium risk
  - **Snake Eyes** (per-cell binary, dice) — high risk
  - **Final Chance** (special — triggers prestige)
- **Drag-to-reveal canvas mechanic** with area-based brush
- **Symbol reveal threshold** — symbol effect triggers only at >85% uncovered
- **Card RNG seeding** — each card instance has pre-determined symbols, just hidden
- **Cash Out button** — locks gains, ends card session
- **Cash currency** + **Jack Points** (prestige currency)
- **In-run upgrades shop:**
  - **Luck** — improves symbol roll odds at card seeding
  - **Scratch Power** — drag speed / brush opacity per pass
  - **Area Size** — brush radius
  - **Auto Scratcher** — unlocks at run threshold; automates scratching of one card slot
- **Final Chance card** → ends run → calculates Jack Points → opens prestige tree
- **Prestige tree (6 permanent perks):**
  - Muscle Memory (+25% scratch speed permanently)
  - Allowance (+$100 start cash next run)
  - Super Lucky (more frequent jackpot symbols)
  - Time Travel (start run with 1 Auto Scratcher)
  - Tough Skin (penalty symbols deal 50% damage)
  - Generous Tips (cards cost 10% less)
- **Save/load** — localStorage persist

### NICE TO HAVE (Phase 2)
- 2 more card types (e.g. Scratch My Back segmented, Lucky Cat)
- **Catalogs** — tiered card shops unlocked by progression
- **Daily quest stub** ("Scratch 10 cards", "Trigger 3 jackpots") with reward
- **Rewarded ad stub** — "Watch ad to peek 1 symbol on next card"
- **Premium pack stub** — $1.99 "Guaranteed Jackpot Card" button
- **Card collection log** — "first time scratched" entries (read-only ledger, NOT a TCG-style collectible — cards are one-shot)

### OUT OF SCOPE (don't build for prototype)
- Real BP / season system
- Multi-card-type theme weeks (events)
- Mobile responsive layout (desktop drag is fine)
- Sound polish beyond simple oscillator stubs
- Tutorial flow beyond first-card tooltip

## 5. Data model

```js
state = {
  cash: 0,
  jackPoints: 0,
  prestigeCount: 0,
  runStartedAt: 0,
  currentCard: null,           // active card being scratched, or null
  ownedCardSlots: 1,           // how many cards player can have queued at once
  cardCatalog: [
    {
      id: 'quick_cash',
      name: 'Quick Cash',
      cost: 5,
      ruleset: 'match_n',
      gridSize: 3,
      params: { matchTarget: 2, symbolPool: ['$', '$', '$$', 'X'] },
      unlocked: true
    },
    {
      id: 'apple_tree',
      name: 'Apple Tree',
      cost: 25,
      ruleset: 'per_symbol_accumulate',
      gridSize: 9,
      params: { goodSymbols: ['🍎', '🍏'], penaltySymbols: ['🐛'], payoutPerGood: 5, penaltyAmount: 30 },
      unlocked: true
    },
    {
      id: 'snake_eyes',
      name: 'Snake Eyes',
      cost: 100,
      ruleset: 'per_cell_binary',
      gridSize: 6,
      params: { winSymbols: ['⚀','⚁','⚂','⚃','⚄','⚅'], penaltyCondition: 'value=1', payoutPerWin: 25, penaltyPerLoss: 50 },
      unlocked: true
    },
    {
      id: 'final_chance',
      name: 'Final Chance',
      cost: 500,
      ruleset: 'final_chance',
      isPrestigeTrigger: true,
      unlocked: true
    }
  ],
  inRunUpgrades: {
    luck:         { level: 0, costBase: 50,  costScale: 1.5, effect: '+5% good symbol odds per level' },
    scratchPower: { level: 0, costBase: 50,  costScale: 1.5, effect: 'brush opacity per pass ×1.2 per level' },
    areaSize:     { level: 0, costBase: 100, costScale: 1.6, effect: 'brush radius +5px per level' },
    autoScratcher:{ level: 0, costBase: 1000,costScale: 2.0, effect: 'auto-scratches 1 queued card every 30s, lower tiers only' }
  },
  permanentTalents: [
    { id: 'muscle_memory', name: '+25% scratch speed', owned: false, cost: 1 },
    { id: 'allowance',     name: '+$100 starting cash', owned: false, cost: 1 },
    { id: 'super_lucky',   name: 'Jackpot symbols 2× more common', owned: false, cost: 2 },
    { id: 'time_travel',   name: 'Start with 1 Auto Scratcher', owned: false, cost: 3 },
    { id: 'tough_skin',    name: 'Penalty symbols deal 50%', owned: false, cost: 2 },
    { id: 'generous_tips', name: 'Cards cost 10% less', owned: false, cost: 2 }
  ],
  cardLog: { /* cardTypeId -> { scratched: N, totalPayout: $, biggestWin: $ } */ },
  lastSaved: 0
}
```

## 6. Card rulesets (faithful to source, simplified for prototype)

### Quick Cash (match-2-of-3)
- Grid: 3 panels.
- Each panel hides a symbol from pool `['$', '$', '$$', 'X']` (weighted).
- When 2 panels share a symbol after reveal → payout based on symbol value.
- No penalty symbols → safe entry card.

### Apple Tree (per-symbol accumulate, penalty on full reveal)
- Grid: 3×3 (9 cells).
- Cells hidden: mix of apples (good, pays per reveal) + worms (penalty if fully revealed).
- Strategy: scratch carefully, watch worm peek, stop before fully exposing.
- **Skill-stop is central here.**

### Snake Eyes (per-cell binary dice)
- Grid: 2×3 (6 cells), each is a die face 1–6.
- Reveal each die → if value > 1: payout. If value = 1: penalty.
- All cells must be evaluated independently. No accumulation rule.

### Final Chance (prestige trigger)
- Single panel.
- Cost = current run threshold ($500 base, scales with prestige count).
- Card always pays a fixed prestige reward in cash + 1 Jack Point, but **ends the run** on full reveal.
- Player commits to prestige by buying it.

## 7. Core formulas

- **Card seeding (at purchase):**
  ```js
  function seedCard(cardType, luck) {
    // Apply luck modifier to symbol pool weights
    // Roll each cell using weighted pool
    // Return array of symbols + their positions
  }
  ```
- **Symbol reveal %:** computed per-frame by sampling alpha channel of scratch mask canvas over symbol bounding box.
- **Trigger threshold:** if reveal % > 85% → symbol effect fires (good: instant payout; bad: instant penalty).
- **Cash out:** sums good-symbol payouts that fired, subtracts penalty-symbol charges that fired, ends card.
- **Jack Points on prestige:** `floor(sqrt(cashAtPrestige / 100))` (rough — tune to feel)
- **Brush radius:** `15 + (areaSize.level × 5)` pixels
- **Brush erase per drag tick:** opacity step proportional to `1 + scratchPower.level × 0.2`

## 8. UI layout (text wireframe)

### Run screen (between cards)
```
+--------------------------------------------------------+
|  💵 CASH: $1,250    ⭐ Jack Points (run end): est. 3   |
+--------------------------------------------------------+
|  CARDS SHOP                                            |
|  [Quick Cash — $5]      Risk: ●○○                      |
|  [Apple Tree — $25]     Risk: ●●○                      |
|  [Snake Eyes — $100]    Risk: ●●●                      |
|  [Final Chance — $500]  ⚠ Ends run                     |
+--------------------------------------------------------+
|  IN-RUN UPGRADES                                       |
|  Luck Lv0          [$50]                               |
|  Scratch Power Lv0 [$50]                               |
|  Area Size Lv0     [$100]                              |
|  Auto Scratcher    [$1000]   (Locked: need run lvl 5)  |
+--------------------------------------------------------+
| [📜 Card Log]  [⭐ Permanent Talents (Jack: 3)]        |
+--------------------------------------------------------+
```

### Card scratching view (active card)
```
+--------------------------------------------------------+
|  Apple Tree                              [✓ Cash Out]  |
+--------------------------------------------------------+
|                                                        |
|    ┌─────┬─────┬─────┐                                 |
|    │ ▓▓▓ │ ▓▓▓ │ 🍎  │                                 |
|    ├─────┼─────┼─────┤                                 |
|    │ ▓▓▓ │ 🐛(40%) │ ▓▓▓ │ ← peek of penalty           |
|    ├─────┼─────┼─────┤                                 |
|    │ ▓▓▓ │ ▓▓▓ │ ▓▓▓ │                                 |
|    └─────┴─────┴─────┘                                 |
|                                                        |
|  Earned so far: $5  |  Drag to scratch                 |
+--------------------------------------------------------+
```

The 40% peek visualizes the skill-stop tension: keep scratching that cell and you'll trigger the penalty.

### Permanent Talents modal (post-prestige)
```
   [Muscle Memory +25%]   1 pt   [Owned]
   [Allowance +$100]      1 pt   [Available]
   [Super Lucky]          2 pt   [Locked: need 2 pt]
   [Time Travel]          3 pt
   [Tough Skin]           2 pt
   [Generous Tips]        2 pt

   Jack Points: 3
```

## 9. Tuning targets (first-pass)

| Metric | Target |
|---|---|
| Time-to-first-card | <10s (cash starts at $5 or $0 + free starter) |
| Time-to-first-cash-out | 15–25s on Quick Cash |
| Time to scratch Apple Tree (carefully) | 25–40s |
| % of cards player chooses to Cash Out early | 20–40% (skill-stop is real) |
| Time-to-Auto-Scratcher | 8–15 min |
| Time-to-first-Final-Chance | 20–40 min (run 1) |
| Cards scratched per run (run 1) | 30–60 |
| Jack Points across first 3 prestiges | 1–3, 3–6, 6–10 |
| % penalty symbol fully revealed by mistake | 15–30% (feels real) |

## 10. Validation goals (what the prototype must prove)

1. **Does drag-to-reveal feel satisfying after 20 cards?** Or does active fatigue kick in before Auto Scratcher unlocks?
2. **Does skill-stop create real tension?** Does the player **stop scratching** when they see a worm peek, or do they bulldoze through?
3. **Do per-card rulesets feel different?** Apple Tree should feel different from Snake Eyes despite both being "scratch a grid".
4. **Is the Final Chance prestige choice rewarding?** Player should hesitate, calculate, then commit.
5. **Does the permanent tree make run 2 feel meaningfully different from run 1?** (Especially Allowance + Super Lucky combo.)

## 11. Critical design rules (do not violate)

- **Skill-stop is the core USP.** Penalty symbols MUST only trigger at >85% reveal. If you trigger them earlier, the tension dies.
- **Cards are stochastic, not deterministic.** Each card instance is RNG-seeded at purchase. The player doesn't see the seed.
- **Cards are single-use, not collectibles.** When a card is cashed out, it's gone. Card Log tracks aggregate stats, not instances.
- **Negative-payout cards must be possible.** A bad run on Snake Eyes can lose money — keep that. Don't soft-cap it to "always net positive".
- **The drag gesture is the plugin.** Don't replace it with click-to-reveal or tap-to-reveal — it kills the source-game identity. Auto Scratcher is the only acceptable bypass, and only for lower-tier cards.
- **Don't add card collection / album view.** This is NOT a TCG game. Card Log is a stats ledger, not a sticker album.

## 12. Out-of-scope decisions to flag for next iteration

- **Catalog tiers** — prototype has 4 cards in one shop. Real game has multiple catalogs unlocked by progression. Define catalog gating in next iteration.
- **Theme cards / events** — F2P would add limited-time card types (e.g. "Halloween Pumpkin Pull"). Out of prototype scope.
- **Daily limits / energy** — verified absent in source. F2P version may want to add soft limits for monetization, but **test the source loop without them first**.
- **Auto Scratcher economy** — at what point does it dominate over manual? Tune so that high-tier cards still demand manual play.
- **Penalty severity tuning** — first prototype uses fixed values. Real game would scale penalties to current run cash.

---

## File structure suggested

```
/prototype-scratchy/
  index.html
  styles.css
  game.js            # state, save/load, run management
  shop.js            # card shop, upgrades shop, prestige tree
  card.js            # card spawning, seeding, ruleset eval
  scratch.js         # canvas drag mechanic, reveal % calculation
  rulesets/
    quickCash.js
    appleTree.js
    snakeEyes.js
    finalChance.js
```

## Implementation hints

- **Scratch canvas:** HTML5 Canvas with cover layer; on pointer-drag, paint with `globalCompositeOperation = 'destination-out'` to erase mask.
- **Reveal % per symbol:** for each symbol's bounding box, sample alpha values across a sparse grid (e.g. 10×10 = 100 samples) to estimate exposed area. Re-sample every 100ms or every 5 drag events.
- **Symbol reveal trigger:** when sample shows >85% transparent, fire `symbol.onReveal()` once (debounce).
- **Visual peek:** keep symbols visible (semi-transparent under cover) so player sees "shape" of penalty before committing. Tune cover opacity so player sees enough to identify type but not enough to "cheat" the system.
- **Auto Scratcher:** spawn a virtual pointer that drags in a slow predictable pattern on a queued card. Crucially: **it cannot skill-stop** — it always fully scratches, so it's bad for high-risk cards.
- **Card RNG seed:** generate a seed on card purchase, store as `card.seed`. Use it to deterministically generate symbol layout via seeded PRNG (so reload preserves the card state).
