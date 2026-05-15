# Gamblers Table — Patch Plan v1

Date: 2026-05-15
Target: `prototype-gamblers/index.html` (single file)
Source review: `prototype-gamblers/REVIEW.md`
Output cadence: patches land as a single new working `index.html`. No new files except documentation. Save key migrates (see §99).

> Goal: take the prototype from "good plugin, missing meta" to "shippable F2P slice" without abandoning what works. Every patch below is scoped tight enough to land in one editing pass.

---

## 0. Patch order & dependency graph

Patches must land roughly in this order — later ones depend on earlier scaffolding (new state fields, currency keys, panel framework).

```
P1 (rename/de-gamble theme)  ──┐
P2 (archetype label flip)     ─┤
P3 (commit plugin identity:   ─┤
     KEEP PHYSICS, drop       ─┤
     FLIP ALL, drop MERGE,    ─┤
     add hard coin cap)       ─┤── foundation
P4 (perm-prestige multiplier) ─┤
P5 (premium currency Gems)    ─┘
P6 (skull sink rebuild)       ──┐
P7 (talent tree depth + tabs) ─ ┤
P8 (helper math fix)          ─ ┤── balance + economy
P9 (tier ramp / coin-cap UI)  ─ ┤
P10 (super_lucky kill;        ─ ┘
     OXIDATION_MS bug fix)
P11 (FTUE state machine)      ──┐
P12 (daily login + 3 quests)  ─ ┤
P13 (inbox + push triggers)   ─ ┤── retention/meta
P14 (weekly Lucky Table evt)  ─ ┤
P15 (season pass v0 stub)     ─ ┘
P16 (IAP/ad stubs + offers)   ──┐
P17 (leaderboard + Rival ghost)─ ┤── monetization + social
P18 (analytics events)        ─ ┘
P19 (validation checklist)
```

Anything below P10 can ship to playtest. P11+ is engagement scaffolding.

---

## P1 — Rename + de-gamble the theme

**Why:** Apple Guideline 5.3 + Google Apr/Oct 2025 policy + IP risk from greenpixels/Bossforge trademark. "Gamblers" in title forces 17+ on iOS and torpedoes installs.

**Decisions to commit:**
- New project codename: **"Coin Table"** (placeholder) — or pick from: `Lucky Toss`, `Flick Fortune`, `Coin Den`, `Two-Faced`, `Flipside`. Default to **Coin Table** in this patch; bikeshed later.
- Skull symbol → **clover (☘)** for the not-cash side. Reframes "skull = death = loss" into "clover = bonus token = different reward."
- "High Roll Table" → **"Lucky Table"**.
- "Sacrifice" → **"Reset"** (or **"Refurbish"**) — drops the occult framing.
- "Skull Tokens" → **"Tokens"** (or **"Lucky Tokens"**).
- "Helpers / Minions" stays (neutral).

**Code changes (string-replace level):**

| Old | New | Where |
|---|---|---|
| `Gamblers Table` | `Coin Table` | `<title>`, all visible copy |
| `Skull Tokens` / `Skulls` / `💀` | `Tokens` / `Tokens` / `☘` | HUD label, gacha button, all `floatText`, all `showModal` strings |
| `state.skullTokens` | `state.tokens` | data model (migrate, see §99) |
| `Sacrifice` / `SACRIFICE` | `Reset` / `RESET RUN` | button text, modal copy, comments |
| `state.sacrificeCount` | `state.resetCount` | data model (migrate) |
| `sacrificeThreshold/sacrificeReward` | `resetThreshold/resetReward` | function names |
| `High Roll Table` | `Lucky Table` | TABLES config + UI |
| Skull-on-skull-side visuals | Clover-on-bonus-side | `.floatText.skull` class can stay but content changes |

**New color palette pulls (CSS root vars in `<style>`):**
```css
:root {
  --c-bg: #0e1a14;
  --c-surface: #15281d;
  --c-felt: #2d6a3e;        /* table felt — kept */
  --c-felt-edge: #6b4423;
  --c-primary: #d4af37;      /* gold — kept */
  --c-accent: #ffe680;
  --c-text: #f4e4bc;
  --c-text-dim: #c0a060;
  --c-token: #aaf080;        /* was skull silver — now clover green */
  --c-success: #aaf080;
  --c-danger: #ff6666;
}
```
Replace all hard-coded `#e8e8f0` / `#aaf080` / etc. with the var refs.

**Acceptance:** screenshot of home screen contains zero instances of the words `gambler`, `skull`, `sacrifice`, `casino`, `gambling`, `bet`, `bookmaker`, `wager`, `high roll`. Search the source: `grep -iE 'gambl|skull|sacri|casino|wager|bet\b|bookm'` returns only commented-out historical strings.

---

## P2 — Flip archetype label

**Why:** code shape is **Prestige Incremental** (log-scale prestige formula, tiered generator ladder, flat-multiplier talent tree, no managers, no spatial business expansion). Calling it "Idle Tycoon" pulls wrong benchmarks (Idle Miner / Cash Inc.). Correct peers: AdVenture Capitalist, Cookie Clicker, Egg Inc.

**Code changes:** docs-only.
- Update `<title>` and top-of-file comment: `// Archetype: Prestige Incremental — Plugin: Coin Table (click-to-flip donor: Gamblers Table, Steam 2026)`
- Update `prototype-gamblers-idle.md` header line 1 + line 9 once HTML lands.

**Downstream effect:** §P12, §P15, §P17 benchmark choices change accordingly.

---

## P3 — Commit plugin identity: KEEP PHYSICS

The review presented two options. **We commit to Option A: keep the click-to-flip physics identity.** Physics is the plugin's whole reason to exist; ladder identity is generic.

### P3.a — Remove FLIP ALL button

Lines to delete:
- index.html:312-338 (CSS for `#flipAllBtn`)
- index.html:436 (button DOM)
- index.html:870-884 (click handler + `refreshFlipAllBadge`)
- index.html:766 — remove `refreshFlipAllBadge()` call inside `renderCoins`
- Remove media-query overrides for `#flipAllBtn` at index.html:335-338

### P3.b — Remove MERGE_COST auto-merge

Lines to change:
- index.html:497 — delete `const MERGE_COST = 5;`
- index.html:972-1002 — delete both auto-merge blocks (one on unlock, one on buy). The buy handler becomes:

```js
} else if (canBuy) {
  if (state.coins.length >= coinCap()) {
    showModal('Table Full', `Max ${coinCap()} coins on the table. Tier up or Reset.`);
    return;
  }
  state.cash -= cost;
  state.coins.push(makeCoin(t.id, state));
  renderShop(); renderCoins(); updateHud();
}
```

### P3.c — Add hard coin cap

New global + helper:
```js
const BASE_COIN_CAP = 30;
function coinCap() {
  return BASE_COIN_CAP
    + (state.talentsOwned.crowded_table  ? 10 : 0)
    + (state.talentsOwned.big_table      ? 20 : 0)
    + Math.floor(state.resetCount * 0.5);  // soft grow with prestige
}
```

New talents to add to `TALENTS` (see P7):
- `crowded_table`: "+10 coin cap", cost 2
- `big_table`: "+20 coin cap", cost 3

### P3.d — Tier-up consumes count visibly

When unlocking next tier, instead of silent auto-merge: the unlock flow now shows a modal "Consume 5 ${prev.name} coins to unlock ${t.name}?" with [Confirm] / [Cancel]. Confirm removes 5 lower-tier coins, adds 1 new higher-tier coin. Player sees the trade.

```js
function unlockTier(t, tierIdx) {
  const prev = TIERS[tierIdx - 1];
  const have = state.coins.filter(c => c.tier === prev.id).length;
  if (have < 5) { showModal('Need 5', `You need 5 ${prev.name} coins to unlock ${t.name}. You have ${have}.`); return; }
  if (state.cash < Math.ceil(t.buyCost * coinDiscount())) { return; }
  showConfirm(`Unlock ${t.name}?`,
    `Consume 5 ${prev.name} + $${(t.buyCost*coinDiscount()).toLocaleString()} → 1 ${t.name} (payout ${t.basePayout}/flip).`,
    () => {
      state.cash -= Math.ceil(t.buyCost * coinDiscount());
      // remove 5 of prev tier
      let removed = 0;
      state.coins = state.coins.filter(c => { if (c.tier === prev.id && removed < 5) { removed++; return false; } return true; });
      state.ownedTiers[t.id] = true;
      state.coins.push(makeCoin(t.id, state));
      renderShop(); renderCoins(); updateHud(); saveState();
    });
}
```

Add `showConfirm(title, body, onYes)` helper (similar to `showModal` but with Confirm/Cancel buttons).

**Acceptance:**
- Player must hand-click each coin or buy helpers; no "flip all in one click" affordance.
- Coin count stops at `coinCap()`; UI shows "12 / 30" badge somewhere visible (HUD).
- Tier-up modal explicit, never silent.

---

## P4 — Permanent prestige multiplier

**Why:** without it, sacrifice #4 stalls hard (review §R3). Threshold grows ×10/prestige; with current flat talents the post-reset earn rate doesn't grow → reset loop dies.

**Add:**

```js
function permMult() {
  // Each reset gives +25% permanent income; talents add multiplicative perm mult
  const fromResets = 1 + state.resetCount * 0.25;
  const fromTalents = (state.talentsOwned.gilded_legacy  ? 1.5 : 1)
                    * (state.talentsOwned.iron_will      ? 2.0 : 1);
  return fromResets * fromTalents;
}
```

Modify `profitMult`:
```js
function profitMult() {
  const eff = activeTableEffects();
  return (1 + state.upgradeLevels.profit * 0.1)
       * (1 + (eff.profitBonus || 0))
       * permMult();
}
```

HUD addition: show "Legacy ×N.NN" chip next to Reset count.

Add talents (in P7):
- `gilded_legacy`: "+50% permanent income", cost 4
- `iron_will`: "×2 permanent income (one-time, late)", cost 8

**Acceptance:** after 3 resets, earn rate is ≥1.75× run 1 baseline. Threshold ×10 is now climbable; reset #4 should take ~run-1-duration × 1.5 instead of × 10.

---

## P5 — Premium currency: Gems

**Why:** no commercial layer to even prototype. Mobile F2P stack requires soft+hard split. Gems is the hard currency.

**State:**
```js
state.gems = 0;  // default in freshState()
```

**HUD:** add 4th chip on top-bar right: `💎 0`.

**Earn sources (free):**
- Daily login bonus (see P12): 1-3 gems/day
- First-time milestone rewards (first reset, first platinum, first 5 hats): 10 gems each
- Weekly Lucky Table event clear: 5 gems

**Spend sinks:**
- Time-skip 1h offline income: 10 gems
- Refill helpers (reset cooldown on a future ad-skip): 5 gems
- Premium hat gacha (guaranteed rare): 50 gems
- Re-spec talents: 25 gems
- Coin discount permanent +5% stacking up to 3 times: 50/100/200 gems

**IAP stubs (P16):** Gem packs $0.99/$2.99/$9.99/$24.99. Stubs only — no real Stripe/Apple flow. Buttons that grant gems with a fake "Thanks for your purchase!" modal so playtest can measure clicks.

**Acceptance:** Gems visible from second 1, earned from daily login on day 2 onwards, spent on at least 2 sinks present in shop.

---

## P6 — Skull/Token sink rebuild

**Why:** at 5/sec faucet vs 50-token lifetime sink, currency dies in 60s mid-game (review §R5). Steam source has 149 hats; prototype has 5.

### P6.a — Expand hat pool to 24 across 3 rarity tiers

```js
const HATS = {
  common:    ['🎩','🧢','🎓','🪖','👒','🎀','⛑','🎪'],      // 8 hats, weight 70
  rare:      ['👑','🪄','🌟','🦄','🌈','🍀','🎯','🔮'],      // 8 hats, weight 25
  legendary: ['💎','🔥','⚡','💀','😈','👻','🌌','🪐']       // 8 hats, weight 5
};
const HAT_RARITY_WEIGHTS = { common: 70, rare: 25, legendary: 5 };
```

### P6.b — Escalating cost + duplicate-shards

- First hat roll: 10 tokens.
- Each subsequent roll: `10 + Math.floor(state.hatsRolled * 2.5)` tokens.
- Duplicate hats: shred into 1 "Token Shard" each. 5 shards = guaranteed rare; 25 shards = guaranteed legendary.

```js
state.hatsRolled = 0;
state.tokenShards = 0;
state.hatsOwned = {};  // already exists; keys are hat strings now, values are count
```

### P6.c — Token-priced upgrades (sink #2)

New section in shop "Token Bazaar":
- Talent re-spec: 50 tokens (reset all talents, refund SP)
- Helper morale +25% for 30 min: 25 tokens
- Oxidation early-trigger (one-shot, picks newest copper): 15 tokens
- Coin cap +1 permanent (max +10): 30/60/120/... tokens

### P6.d — Premium-currency gacha (P5 integration)

Premium hat box (50 gems): guaranteed rare or better. Drops `gems_only_hats` cosmetic line (8 more hats, premium-exclusive).

**Acceptance:** at 1-hr mid-game session, tokens have at least 2 active sinks the player engages with; full hat completion is a 30-50 hr arc, not a 60-second arc.

---

## P7 — Talent tree depth + branching

**Why:** 6 flat nodes < mobile genre baseline of 20-40. Steam source promises "strategy-flipping" talents; prototype delivers "+10% cash" stubs.

**Restructure:** 4 branches × 5 nodes each = **20 nodes**, with intra-branch prerequisites.

### Branch A — Greed (cash & income)
1. `allowance` — +$100 starting cash — 1 SP — no prereq (kept)
2. `golden_touch` — +25% profit/flip permanent — 2 SP — req: `allowance`
3. `compound` — +1% profit/flip per coin on table — 3 SP — req: `golden_touch`
4. `gilded_legacy` — +50% permanent income (P4 integration) — 4 SP — req: `compound`
5. `iron_will` — ×2 permanent income — 8 SP — req: `gilded_legacy` + 5 resets

### Branch B — Speed (flip & helper)
1. `muscle_memory` — Helpers +25% rate (kept) — 1 SP — no prereq
2. `quick_hands` — Flip animation ×0.7 — 2 SP — req: `muscle_memory`
3. `swarm` — +2 helpers max per tier — 3 SP — req: `muscle_memory`
4. `fast_helpers` — Helpers +50% rate — 4 SP — req: `swarm`
5. `eternal_motion` — Helpers don't need owned coin (auto-flip on tier even if empty) — 6 SP — req: `fast_helpers`

### Branch C — Rust (oxidation)
1. `patience` — Oxidation triggers at 60s instead of 90s — 2 SP — no prereq
2. `tough_skin` — Oxidation pays ×2 more (kept, was ×20 → now ×20 keeps consistent) — 2 SP — no prereq
3. `silver_rust` — Silver coins also oxidize (45s timer, ×5 payout) — 3 SP — req: `patience` + `tough_skin`
4. `chain_oxidation` — Flipping an oxidized coin makes adjacent ones oxidize — 4 SP — req: `silver_rust`
5. `rust_master` — Oxidation payout × number_of_oxidized_visible — 6 SP — req: `chain_oxidation`

### Branch D — Table (coins & layout)
1. `crowded_table` — +10 coin cap (P3 integration) — 2 SP — no prereq
2. `big_table` — +20 coin cap (P3 integration) — 3 SP — req: `crowded_table`
3. `generous` — Coins cost 10% less (kept) — 2 SP — no prereq
4. `time_travel` — Start each run with 1 silver coin — 3 SP — req: `generous` + 2 resets
5. `table_master` — Start each run with 1 of every owned tier — 6 SP — req: `time_travel` + 4 resets

**Replace `TALENTS` const accordingly.** UI: replace flat list modal with branch-tabbed tree view. Show prereq lines between nodes.

**Acceptance:** 20 nodes total, branching prereqs visible, total SP cost ~70 — player has meaningful decisions across 5-7 resets.

---

## P8 — Helper math fix

**Why:** Platinum minion = $10M cost, $150/s earn, 18.5h payback, 4h offline cap → **mathematically unbuyable** (review §R7).

**Concrete tuning patch (HELPERS const, lines 498-503):**

| Tier | Old cost | Old f/s | New cost | New f/s | Payback @ tier×0.5 |
|---|---|---|---|---|---|
| Copper | 100 | 1.0 | 100 | 1.0 | 200s — OK |
| Silver | 5,000 | 0.5 | 4,000 | 0.6 | 2,222s — OK |
| Gold | 500,000 | 0.25 | 200,000 | 0.4 | 12,500s ≈ 3.5h — fits offline cap |
| Platinum | 10,000,000 | 0.20 | 3,000,000 | 0.5 | 8,000s ≈ 2.2h — fits offline cap |
| Diamond (new) | — | — | 80,000,000 | 0.3 | 17,778s ≈ 5h — needs P9 talent or accept long payback |

Replace `HELPERS` const:
```js
const HELPERS = [
  { tier: 'copper',   name: 'Copper Minion',   costBase: 100,        costScale: 1.15, flipsPerSec: 1.0 },
  { tier: 'silver',   name: 'Silver Minion',   costBase: 4000,       costScale: 1.15, flipsPerSec: 0.6 },
  { tier: 'gold',     name: 'Gold Minion',     costBase: 200000,     costScale: 1.15, flipsPerSec: 0.4 },
  { tier: 'platinum', name: 'Platinum Minion', costBase: 3000000,    costScale: 1.15, flipsPerSec: 0.5 },
  { tier: 'diamond',  name: 'Diamond Minion',  costBase: 80000000,   costScale: 1.15, flipsPerSec: 0.3 }
];
```

**Offline cap rework:** base 4h, +2h per branch B node owned (max 10h with full Speed branch). Stops Platinum from being a trap purchase even without ad-boost.

```js
function offlineCapMs() {
  const branchBBonus = ['muscle_memory','quick_hands','swarm','fast_helpers','eternal_motion']
    .filter(id => state.talentsOwned[id]).length * 2 * 3600 * 1000;
  return 4 * 3600 * 1000 + branchBBonus;
}
```

Replace `Math.min((now - state.lastTick) / 1000, 14400)` at index.html:1207 with `Math.min((now - state.lastTick), offlineCapMs()) / 1000`.

---

## P9 — Tier ramp / coin-cap UI

**Why:** with merge removed (P3), silver/gold look like dead buys vs copper spam. Cap makes the math work — but only if cap is **visible**.

### P9.a — Coin-cap HUD chip

Add to HUD (`<div id="hud">`):
```html
<div class="hud-stat"><span class="hud-label">Coins</span><span class="hud-value small" id="capDisplay">0 / 30</span></div>
```

Update in `updateHud()`:
```js
document.getElementById('capDisplay').textContent = state.coins.length + ' / ' + coinCap();
```

When `state.coins.length === coinCap()`, color it `var(--c-danger)`.

### P9.b — Buy buttons go disabled at cap

Shop coin items: if `state.coins.length >= coinCap()` and tier is buying (not unlocking), show `🛑 Table Full — Tier up!` instead of cost line. Disable click.

### P9.c — Tooltip on tier-up benefit

Each coin tier shop row shows: `1 ${t.name} = ${ratio} ${prev.name} flips of equivalent payout` where `ratio = t.basePayout / prev.basePayout`. Makes the value-density story explicit.

---

## P10 — Bug fixes + rule consistency

### P10.a — `OXIDATION_MS` undefined (index.html:1195)

Replace:
```js
const isOxi = c.tier === 'copper' && Date.now() - c.lastClickedAt >= OXIDATION_MS;
```
with:
```js
const isOxi = canOxidize(c) && Date.now() - c.lastClickedAt >= oxidationMs(c);
```

Add helpers:
```js
function canOxidize(c) {
  if (c.tier === 'copper') return true;
  if (c.tier === 'silver' && state.talentsOwned.silver_rust) return true;
  return false;
}
function oxidationMs(c) {
  let base = activeTableEffects().oxidationMs || BASE_OXIDATION_MS;
  if (state.talentsOwned.patience) base = Math.min(base, 60000);
  if (c && c.tier === 'silver') base = 45000;
  return base;
}
```

Update all callers (line 595, 763, 828) to pass the coin and use the new shape.

### P10.b — Kill `super_lucky` talent

Spec §10 rule 2 is sacred: "50/50 is uncompromising." Talent shifted it to 55/45. Either rule dies or talent dies. **Talent dies.** Remove `super_lucky` from `TALENTS`. Update `dollarOdds()` (line 584-588):
```js
function dollarOdds() {
  const eff = activeTableEffects();
  if (eff.dollarOddsOverride !== undefined) return eff.dollarOddsOverride;
  return 0.5;  // always — design rule, never bend
}
```

### P10.c — `selected` CSS class on tableShop is referenced but never defined

index.html:1066 uses `selected` class. Add CSS:
```css
.shopItem.selected { border-color: var(--c-success); background: linear-gradient(180deg, #2a4828, #0f2a0a); }
```

### P10.d — Save-key bump for migration

See §99 — version state schema, run migration on load.

---

## P11 — FTUE state machine

**Why:** all 5 tabs visible from t=0, no tutorial, no first-paywall hook. D1 retention is set in the first 5 minutes.

**New state:**
```js
state.ftue = {
  step: 0,            // 0 = boot, 1 = first-flip done, 2 = bought 2nd coin, 3 = first helper, 4 = oxidation seen, 5 = first reset, 6 = done
  tabsUnlocked: ['home'],
  starterPackShown: false,
  starterPackBought: false
};
```

**Step gates:**

| Step | Trigger | Effect | Coach mark |
|---|---|---|---|
| 0→1 | First `flipCoin` call | `tabsUnlocked.push('coins')`; toast "Click any coin to flip it" before, "Tokens are not a loss — save them for hats" after first ☘ side | Pulsing arrow on starting coin |
| 1→2 | First buy in coin shop | `tabsUnlocked.push('helpers')` | "Buy more coins — fill the table" |
| 2→3 | First helper hire | nothing new unlocked yet | "Helpers auto-flip coins — go AFK!" |
| 3→4 | First oxidation-payout flip | `tabsUnlocked.push('tables')` | "Leave copper coins alone for 90s — they oxidize for ×10!" |
| 4→5 | First reset | `tabsUnlocked.push('skills')`; trigger starter pack at +5s | "Reset wipes the table for permanent talents" |
| 5→6 | Starter pack modal closed | full unlock, FTUE done | — |

**Tab gating implementation:**
```js
function renderBottomNav() {
  document.querySelectorAll('.navBtn').forEach(btn => {
    btn.style.display = state.ftue.tabsUnlocked.includes(btn.dataset.tab) ? '' : 'none';
  });
}
```

**Coach marks:** absolute-position div over target with pulse animation:
```css
.coach { position: absolute; pointer-events: none; z-index: 50; padding: 8px 12px; background: var(--c-accent); color: var(--c-bg); border-radius: var(--r-2); font-weight: bold; animation: coachPulse 1s infinite; }
@keyframes coachPulse { 50% { transform: scale(1.08); } }
```

**Starter pack offer (post-first-reset):**
```js
function showStarterPack() {
  if (state.ftue.starterPackShown) return;
  state.ftue.starterPackShown = true;
  showOffer({
    title: '🎁 Starter Pack',
    body: '50 💎 Gems + $10,000 + 1 Gold coin for $2.99 (-70%).',
    cta: 'Buy ($2.99)',
    onBuy: () => { state.gems += 50; state.cash += 10000; /* grant gold coin */ state.ftue.starterPackBought = true; showModal('Thanks!','(stub purchase — no real charge)'); saveState(); },
    onClose: () => { saveState(); }
  });
}
```

**Acceptance:** new save → 5 visible nav tabs go down to 1; player completes ladder over ~10-15 min of intentional play; starter pack modal fires once at first reset.

---

## P12 — Daily login + 3 daily quests

**Why:** highest-ROI retention system in incrementals. Empty here.

**State:**
```js
state.daily = {
  lastClaimDate: null,            // YYYY-MM-DD
  streak: 0,
  quests: [],                     // [{id, text, target, progress, reward, claimed}]
  questsGeneratedDate: null
};
```

### P12.a — Login calendar (28-day cycle)

```js
const DAILY_REWARDS = [
  { day: 1,  gems: 1,  cash: 500 },
  { day: 2,  gems: 1,  tokens: 5 },
  { day: 3,  gems: 2,  cash: 2000 },
  { day: 4,  gems: 1,  tokens: 10 },
  { day: 5,  gems: 3,  cash: 5000 },
  { day: 6,  gems: 2,  tokens: 15 },
  { day: 7,  gems: 10, cash: 25000, banner: '🎉 Week 1 Bonus!' },
  // ... 28 days total, week 4 bonus = 25 gems + 1 random rare hat
];
```

Show modal on first session-open of a new local-date. Streak resets if a day is missed.

### P12.b — Daily quest stack

```js
const QUEST_TEMPLATES = [
  { id: 'flip_n',        text: n => `Flip ${n} coins`,                  baseN: 50,  scaleByResets: 10,  reward: { gems: 1, tokens: 5 } },
  { id: 'oxi_n',         text: n => `Trigger ${n} oxidations`,          baseN: 2,   scaleByResets: 0.5, reward: { gems: 2 } },
  { id: 'hire_n',        text: n => `Hire ${n} helper(s)`,              baseN: 1,   scaleByResets: 0,   reward: { tokens: 10 } },
  { id: 'earn_n',        text: n => `Earn $${n.toLocaleString()}`,      baseN: 5000,scaleByResets: 5,   reward: { gems: 1, cash: 1000 } },
  { id: 'reset_once',    text: () => 'Reset 1 time',                    baseN: 1,   scaleByResets: 0,   reward: { gems: 5 } },
  { id: 'switch_table',  text: () => 'Try a different table',           baseN: 1,   scaleByResets: 0,   reward: { tokens: 20 } },
  { id: 'spend_token_n', text: n => `Spend ${n} tokens`,                baseN: 30,  scaleByResets: 5,   reward: { gems: 1 } }
];

function generateDailyQuests() {
  const today = new Date().toISOString().slice(0,10);
  if (state.daily.questsGeneratedDate === today) return;
  state.daily.questsGeneratedDate = today;
  const picks = shuffle([...QUEST_TEMPLATES]).slice(0, 3);
  state.daily.quests = picks.map(q => ({
    id: q.id,
    text: q.text(q.baseN + Math.floor(q.scaleByResets * state.resetCount) * 1.0),
    target: q.baseN + Math.floor(q.scaleByResets * state.resetCount),
    progress: 0,
    reward: q.reward,
    claimed: false
  }));
}
```

Hook into game events (flipCoin → flip_n, earn_n; oxidation payout → oxi_n; helper hire → hire_n; reset → reset_once; table switch → switch_table; token spend → spend_token_n).

**UI:** new panel "Daily" — accessible from Home tab via a small "Quests (X/3)" chip. Modal shows 3 quests + login calendar.

**Acceptance:** day 2 onwards, opening the game shows daily-quest panel; quests complete during normal play; claim grants gems/tokens/cash with float text.

---

## P13 — Inbox + 4 local push triggers

**Why:** every retention system below (events, compensation, friend gifts, leaderboard payouts) needs a delivery channel. Without an inbox you can't run live-ops.

### P13.a — Inbox state + UI

```js
state.inbox = [];  // [{id, ts, title, body, claim: { gems, cash, tokens, hat }, claimed, expiresAt}]
```

HUD bell icon (top-right): badge count of unclaimed messages.

Modal panel: list messages newest-first, [CLAIM] button per item, [Claim All] button, delete after claim.

```js
function inboxPush(msg) {
  msg.id = 'msg_' + Date.now() + '_' + Math.random().toString(36).slice(2,7);
  msg.ts = Date.now();
  msg.claimed = false;
  msg.expiresAt = Date.now() + 30 * 24 * 3600 * 1000;
  state.inbox.unshift(msg);
  if (state.inbox.length > 50) state.inbox.length = 50;  // cap
  saveState();
  updateBellBadge();
}

function inboxClaim(id) {
  const m = state.inbox.find(x => x.id === id);
  if (!m || m.claimed) return;
  m.claimed = true;
  if (m.claim?.gems)   state.gems   += m.claim.gems;
  if (m.claim?.cash)   state.cash   += m.claim.cash;
  if (m.claim?.tokens) state.tokens += m.claim.tokens;
  if (m.claim?.hat)    grantHat(m.claim.hat);
  saveState(); updateHud(); updateBellBadge();
}
```

### P13.b — Local notification triggers (no server)

Use Notification API + Page Visibility API. Request permission on first inbox open.

```js
function scheduleLocalNotify(when, title, body, tag) {
  const delay = when - Date.now();
  if (delay <= 0) return;
  setTimeout(() => {
    if (!document.hidden) return;  // user is here, don't bug them
    if (Notification.permission === 'granted') {
      new Notification(title, { body, tag, icon: '/icon.png' });
    }
  }, delay);
}
```

Triggers:
1. **Offline cap nearly full** — `scheduleLocalNotify(Date.now() + offlineCapMs() * 0.875, 'Your table is calling', 'Helpers are about to max out their offline earnings.', 'offline-cap')`
2. **Daily quests reset** — `scheduleLocalNotify(midnight, 'New daily quests', '3 fresh tasks waiting.', 'daily-reset')`
3. **Oxidation ready** — when player leaves with copper unflipped, schedule 90s notify if they don't return
4. **Event ending in 6h** — at event-end - 6h, fire

Re-schedule on every `saveState()` (idempotent via `tag`).

### P13.c — Seed inbox with welcome message

On first boot (`resetCount === 0 && cash === 0`):
```js
inboxPush({
  title: '👋 Welcome to Coin Table',
  body: 'Here is a small gift to get you started. Flip the copper coin to begin!',
  claim: { gems: 5, cash: 500 }
});
```

---

## P14 — Weekly Lucky Table event

**Why:** weekly cadence empty. Single event surface that rotates is the cheapest possible weekly anchor.

**Add to TABLES:**
```js
const WEEKLY_EVENT_TABLES = [
  { id: 'evt_double_copper', name: 'Copper Boom',  desc: 'All copper coins ×3 payout. ☘ tokens halved.', effects: { copperBoost: 3, tokenDivisor: 2 } },
  { id: 'evt_token_rush',    name: 'Token Rush',    desc: '☘ side gives 3 tokens. Cash side -25%.',      effects: { tokenMult: 3, profitBonus: -0.25 } },
  { id: 'evt_no_skull',      name: 'Lucky Streak',  desc: 'Always cash side. No tokens drop.',           effects: { dollarOddsOverride: 1.0 } },
  { id: 'evt_chaos',         name: 'Chaos Table',   desc: 'Coin tier shuffled per flip. Payouts ×2.',    effects: { shuffleTier: true, profitBonus: 1.0 } }
];

state.activeEvent = null;  // {tableId, startsAt, endsAt, claimed: false}
```

**Rotation logic:** ISO week number `% events.length`. Event runs Mon 00:00 → Sun 23:59 local time. On event end, post inbox message with claim if player participated (any flips on event table during window): `{gems: 5, tokens: 50}`.

**Effects engine:** extend `activeTableEffects()` to include event modifiers when `activeEvent.tableId === state.activeTable`.

**UI:** new section on Tables tab "This Week's Event" with countdown timer, switch button.

---

## P15 — Season pass v0 (stub)

**Why:** mobile incremental D14+ retention floor; 28-day commitment hook. Full impl is post-Unity; HTML version is a stub that proves layout and pacing.

**Minimum surface:**
```js
state.season = {
  number: 1,
  startedAt: 1735689600000,   // 2025-01-01 epoch start (replace at runtime)
  xp: 0,
  tier: 0,
  premiumUnlocked: false,
  claimed: { free: [], premium: [] }
};
```

**XP sources:** flip (1 XP), oxidation payout (10 XP), reset (50 XP), table switch (5 XP), daily quest claim (20 XP).

**XP per tier:** 100 + tier × 50, max tier 30.

**Tier rewards (alternating free/premium per row):**
```js
const SEASON_REWARDS = [
  { tier: 1,  free: {gems: 1}, premium: {gems: 3} },
  { tier: 2,  free: {tokens: 10}, premium: {tokens: 30} },
  // ... 30 tiers
  { tier: 15, free: {hat: 'rare'}, premium: {hat: 'legendary'} },
  { tier: 30, free: {hat: 'rare'}, premium: {hat: 'legendary', cash: 100000} }
];
```

**Premium unlock:** $9.99 IAP stub button (P16).

**UI:** new bottom-nav tab "Pass" (replaces or sits beside an existing slot — pick one in build). Linear track UI, current tier highlighted.

---

## P16 — IAP + ad stubs

**Why:** can't tune monetization without the surfaces in place. Stubs let playtest measure clicks without real billing.

### P16.a — Gem packs

```js
const IAP_PACKS = [
  { id: 'gems_99',   price: 0.99,  gems: 80,   label: 'Starter Pile' },
  { id: 'gems_299',  price: 2.99,  gems: 250,  label: 'Handy Stack',  popular: true },
  { id: 'gems_999',  price: 9.99,  gems: 900,  label: 'Big Pouch' },
  { id: 'gems_2499', price: 24.99, gems: 2500, label: 'Treasure Chest' },
  { id: 'starter_pack', price: 2.99, oneShot: true, contents: { gems: 50, cash: 10000, hat: 'rare' }, label: 'Starter Pack (-70%)' }
];
```

Add "Shop" panel. Click any pack → confirmation modal → grant rewards → `analytics('iap_stub_purchased', {id, price})`.

### P16.b — Rewarded ad stubs

Top-right corner button "🎬 Free Gems" — 3-times-per-day cap.
```js
const AD_REWARDS = [
  { id: 'ad_2x_offline', label: '2× Offline (next collect)',   reward: () => state.adBoosts.offline2xExpiresAt = Date.now() + 4*3600*1000 },
  { id: 'ad_free_token', label: '+25 Tokens',                  reward: () => state.tokens += 25 },
  { id: 'ad_gem',        label: '+1 Gem',                      reward: () => state.gems += 1 }
];
```

"Watch" modal shows 3s fake "Loading ad..." then grants. Records cooldown.

### P16.c — Inline contextual offers

After cap hit (P3): "Buy gem pack to grow table?" cross-sell. Don't be aggressive — show max 1/session.

---

## P17 — Leaderboard + Rival ghost

**Why:** zero competitive layer. Async leaderboards are cheap and idle-genre-appropriate.

### P17.a — Synthetic ghost rival

Pick on first boot: random bot persona (name + avatar emoji), their week's "score" is a noisy linear function of player's score with small lead/lag.

```js
state.rival = {
  name: pickFrom(['Tatya','Borys','Mira','Hank','Aiko','Zola']),
  avatar: pickFrom(['🥷','🤠','🧙','🦊','🐨','🐲']),
  scoreOffset: rand(-0.15, 0.15)
};
function rivalScore() {
  return Math.max(0, Math.floor(state.cash * (1 + state.rival.scoreOffset)));
}
```

Home tab adds a "This Week's Rival" card: avatar + name + their score vs yours, "vs" delta.

### P17.b — Leaderboard panel (synthetic)

Generate 49 fake players on first boot with varied score distributions; player slots in at correct rank. Resets weekly. Top 10 get inbox prize on reset.

```js
state.leaderboard = {
  bots: generateBots(49),  // [{name, avatar, score}]
  weekStart: monday(),
  topPrizesClaimed: {}
};
```

Top 3: 50/30/15 gems + 1 legendary hat. Top 10: 10 gems. Top 50: 25 tokens.

UI: new section in Daily panel or Tables panel; sortable, paginated.

---

## P18 — Analytics events

**Why:** can't tune funnel without instrumentation. Local-only stub (console + localStorage queue) — Unity port wires real BI later.

```js
function analytics(event, payload = {}) {
  const e = { event, payload, ts: Date.now(), session: SESSION_ID, day: Math.floor((Date.now() - state.firstSeenAt) / (24*3600*1000)) };
  console.log('[analytics]', event, payload);
  const log = JSON.parse(localStorage.getItem('coinTable_analytics') || '[]');
  log.push(e);
  if (log.length > 1000) log.splice(0, log.length - 1000);
  localStorage.setItem('coinTable_analytics', JSON.stringify(log));
}
```

Canonical event names to instrument (call from existing hooks):
- `session_start`, `session_end`
- `first_flip`, `first_buy`, `first_helper`, `first_oxidation`, `first_reset`, `first_iap_stub`
- `flip_done` (payload: tier, side, oxidized, payout)
- `coin_bought` (tier, cost, totalOwned)
- `helper_hired` (tier, cost, count)
- `tier_unlocked` (tier)
- `reset_done` (sacrificeCount, cash, spGained)
- `talent_purchased` (id, cost)
- `table_switched` (tableId)
- `gacha_rolled` (cost, hatRarity, isDupe)
- `daily_claimed` (day, streak)
- `quest_claimed` (id)
- `event_joined`, `event_completed`
- `ftue_step_completed` (step)
- `iap_stub_purchased` (id, price)
- `ad_stub_watched` (id)
- `inbox_claimed` (msgId)
- `notification_clicked` (tag) — best-effort
- `paywall_shown`, `paywall_dismissed`

**Funnel view stub:** debug-tab button "Dump analytics" → JSON dump to console.

---

## P19 — Validation checklist (acceptance)

After all patches land, the prototype must satisfy:

### Plugin identity
- [ ] No `FLIP ALL` affordance
- [ ] No silent merge — tier-up requires explicit modal Confirm
- [ ] Coin cap visible in HUD, blocks buy at limit
- [ ] Click-to-flip per coin is mandatory for cash income (helpers automate but require buying first)

### Math (run-a-fresh-save scenarios)
- [ ] Reset #1 reachable in ~15-25 min (kept from spec)
- [ ] Reset #3 reachable in ~run-1-duration × 1.5 (was × 10)
- [ ] Platinum minion payback ≤ offline cap with full Speed branch (≤8h)
- [ ] Silver-buy ROI ≥ equivalent-cost Copper-spam ROI when at ≥50% coin cap
- [ ] Tokens spent > tokens earned in mid-game session (sink active)
- [ ] 5 hats / 24 hats requires ≥30 rolls, not 5

### Theme / policy
- [ ] No `gambler|skull|sacrifice|casino|wager|bet|bookmaker` in user-visible strings
- [ ] Clover ☘ replaces 💀 in all float-text and HUD
- [ ] App-store rating self-assessment: candidate 12+ not 17+

### Retention surfaces
- [ ] Daily login modal fires on first session of new local-date
- [ ] 3 daily quests visible + claimable
- [ ] Inbox bell with welcome message on fresh save
- [ ] Weekly event banner on Tables tab
- [ ] Season pass tier number advances during play
- [ ] FTUE walks new player through 5 milestones; tabs unlock progressively

### Bugs
- [ ] `OXIDATION_MS` reference removed; `oxidationMs(coin)` used everywhere
- [ ] `super_lucky` talent gone, `dollarOdds()` returns 0.5 base
- [ ] `.shopItem.selected` CSS exists for active table highlight
- [ ] Save migration from old format runs cleanly (see §99)

### Monetization stubs
- [ ] 4 gem packs + starter pack visible in shop
- [ ] 3 rewarded-ad rewards with 24h cooldown
- [ ] Starter pack offer fires once after first reset
- [ ] All purchases route through `analytics('iap_stub_purchased')`

### Analytics
- [ ] 20+ events firing during a full first-reset playthrough
- [ ] `localStorage.coinTable_analytics` populated

---

## §99 — Save migration

Old save key: `gamblersFlip`. New key: `coinTable.save.v2`.

```js
const SAVE_KEY = 'coinTable.save.v2';
const LEGACY_KEY = 'gamblersFlip';

function loadState() {
  try {
    let raw = localStorage.getItem(SAVE_KEY);
    if (!raw) {
      const legacy = localStorage.getItem(LEGACY_KEY);
      if (legacy) {
        const migrated = migrateV1toV2(JSON.parse(legacy));
        localStorage.setItem(SAVE_KEY, JSON.stringify(migrated));
        localStorage.removeItem(LEGACY_KEY);  // optional — or keep as backup
        return migrated;
      }
      return startNewRun(freshState(), true);
    }
    return Object.assign(freshState(), JSON.parse(raw));
  } catch (e) { return freshState(); }
}

function migrateV1toV2(old) {
  const s = freshState();
  s.cash = old.cash ?? 0;
  s.tokens = old.skullTokens ?? 0;                // rename
  s.skillPoints = old.skillPoints ?? 0;
  s.resetCount = old.sacrificeCount ?? 0;         // rename
  s.coins = old.coins ?? [];
  s.nextCoinId = old.nextCoinId ?? 1;
  s.ownedTiers = old.ownedTiers ?? s.ownedTiers;
  s.upgradeLevels = old.upgradeLevels ?? s.upgradeLevels;
  s.helperCounts = old.helperCounts ?? s.helperCounts;
  s.minionHats = old.minionHats ?? {};
  // talents — drop super_lucky, keep the rest; add new branches at 0
  s.talentsOwned = {};
  for (const k of Object.keys(old.talentsOwned ?? {})) {
    if (k === 'super_lucky') continue;
    s.talentsOwned[k] = true;
  }
  s.hatsOwned = old.hatsOwned ?? {};
  s.tablesUnlocked = old.tablesUnlocked ?? { classic: true };
  s.activeTable = old.activeTable ?? 'classic';
  s.lastTick = old.lastTick ?? Date.now();
  s.gems = 0;                                     // new currency, start at 0
  s.firstSeenAt = old.firstSeenAt ?? Date.now();
  return s;
}
```

`freshState()` itself must be rewritten to include all new fields (ftue, daily, inbox, season, rival, leaderboard, adBoosts, hatsRolled, tokenShards, gems, firstSeenAt).

---

## §100 — Out-of-scope for this patch (deferred to Unity port)

- Real IAP integration (Stripe / Apple / Google billing)
- Real push notifications via FCM/APNs
- Server-side leaderboards
- Cloud save / cross-device
- Real-time guilds / chat
- Localization beyond English
- Accessibility (color-blind mode, screen reader)
- Performance: 100+ DOM coins (P3 cap solves this)
- Anti-cheat: localStorage is trivially editable; accept for prototype

---

## File-level outline of changed sections

```
prototype-gamblers/index.html
├── <head>
│   ├── <title> → "Coin Table"                                      [P1]
│   └── <style>
│       ├── :root CSS vars                                          [P1]
│       ├── #flipAllBtn ........................................... DELETED [P3a]
│       ├── .shopItem.selected                                      [P10c]
│       ├── .coach + @keyframes coachPulse                          [P11]
│       └── .inbox-bell + .badge ................................... NEW [P13a]
├── <body>
│   ├── <div id="hud">
│   │   ├── cash, tokens, gems, SP, resets, helpers, coin-cap       [P1, P5, P9a]
│   │   └── inbox bell                                              [P13a]
│   ├── <div id="game">
│   │   ├── #tableArea                                              (unchanged structure)
│   │   ├── #shop (panel-switched by tab)                           (extended)
│   │   ├── #dailyPanel ............................................ NEW [P12]
│   │   ├── #inboxPanel ............................................ NEW [P13]
│   │   ├── #seasonPanel ........................................... NEW [P15]
│   │   └── #shopPanel (IAP) ....................................... NEW [P16]
│   ├── <nav id="bottomNav">                                        (gated by P11)
│   └── <script>
│       ├── CONFIG: TIERS, HELPERS, UPGRADES, TALENTS×20, TABLES,    [P3,P6,P7,P8,P14]
│       │           HATS{common,rare,legendary}, QUEST_TEMPLATES,
│       │           DAILY_REWARDS, SEASON_REWARDS, IAP_PACKS,
│       │           AD_REWARDS, WEEKLY_EVENT_TABLES
│       ├── STATE: freshState, loadState, saveState, migrateV1toV2  [§99]
│       ├── HELPERS: permMult, profitMult, oxidationMs, coinCap,    [P3,P4,P10]
│       │           offlineCapMs, canOxidize, rivalScore
│       ├── COINS: makeCoin, renderCoins, onCoinPointerDown,
│       │           resolveCollisions, flipCoin                      (mostly unchanged)
│       ├── HELPERS-LANE: renderHelpers, animateHelperThrow         (unchanged)
│       ├── FLIP-ALL ............................................. DELETED [P3a]
│       ├── AUTO-TICK: autoTick                                     (unchanged structure)
│       ├── SHOP-RENDER: renderShop, unlockTier, showConfirm        [P3d]
│       ├── GACHA: rollHat (rarity-weighted)                        [P6a,b,c]
│       ├── RESET (was Sacrifice)                                   [P1, P4]
│       ├── TALENTS: renderTalentTree (branched UI)                 [P7]
│       ├── FTUE: ftueAdvance, coachShow, gateTabs                  [P11]
│       ├── DAILY: generateDailyQuests, claimDaily, hookQuestEvent  [P12]
│       ├── INBOX: inboxPush, inboxClaim, scheduleLocalNotify       [P13]
│       ├── EVENTS: currentWeeklyEvent, joinEvent                   [P14]
│       ├── SEASON: addSeasonXP, claimSeasonReward                  [P15]
│       ├── IAP: showIapShop, buyPack, watchAd                      [P16]
│       ├── SOCIAL: rivalScore, leaderboardRender                   [P17]
│       ├── ANALYTICS: analytics                                    [P18]
│       ├── MODAL+HUD                                                (extended)
│       └── BOOT: init order — load → migrate → bootFTUE → render
```

---

## Estimated effort

| Bucket | Patches | Effort |
|---|---|---|
| Foundation | P1, P2, P3, P10 | 4-6h (find/replace, careful) |
| Economy & balance | P4, P5, P6, P7, P8, P9 | 6-8h (new state, math, balance) |
| Retention surfaces | P11, P12, P13, P14, P15 | 8-12h (most new code) |
| Monetization + social | P16, P17, P18 | 4-6h (mostly stubs) |
| **Total** | **19 patches** | **~22-32h single-dev** |

Realistic break: land P1-P10 as v1.1 (playtest the rebrand + core fixes), then P11-P18 as v1.2.
