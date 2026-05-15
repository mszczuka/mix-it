# Scritchy Scratchy — CORE Patch

Date: 2026-05-15
Target: `prototype-scratchy/index.html`
Scope: **make the prototype validate what it set out to validate** — the skill-stop drag-reveal mechanic with a working economy. Nothing more.

> **What this patch is NOT.** Not a rename, not a theme change, not an F2P retention shell, not daily quests / inbox / battle pass / premium currency / IAP / ads / leaderboards / FTUE state machine / season pass / Mundo / events / analytics. Those belong to the Unity port (or never — most are out of prototype scope).
>
> **What this patch IS.** Five focused fixes to the core loop. The plugin's USP is currently dead in code; this restores it. Plus the smallest economy adjustments needed to make prestige + catalog progression test cleanly.

---

## The 5 patches

| # | Severity | What | Effort |
|---|---|---|---|
| C1 | 🔴 | Restore skill-stop (REVEAL_THRESHOLD split + remove auto-clear + drag smoothing) | 1-2h |
| C2 | 🔴 | Remove negative-cash floor + stuck-state recovery → wipe-out modal with 2 choices | 30min |
| C3 | 🔴 | Catalog gating by `cashHighWaterMark`, not card count | 30min |
| C4 | 🔴 | Prestige math anti-hoard (split formula + commit bonus + cost scaling) | 30min |
| C5 | 🟡 | Area Size repurposed as risk upgrade (Scratch Power vs Area Size tradeoff) | 30min |

Total: ~3-4h. One sitting. Ship as v1.1, playtest, done.

---

## C1 — Restore skill-stop

**The problem.** index.html:517 sets `REVEAL_THRESHOLD = 0.25` with the code comment *"symbol triggers at 25% then auto-clears the rest (faster pace per player request)"*. Combined with the auto-clear branch in `triggerSymbol` at index.html:838-844, this kills the plugin's USP — the player cannot see a worm peek and stop. Spec §11 line 275: *"Skill-stop is the core USP. Penalty symbols MUST only trigger at >85% reveal."*

This is the single most important fix. Without it the prototype validates nothing.

### C1.a — Split threshold

Replace index.html:517:
```js
const REVEAL_THRESHOLD_GOOD    = 0.30;   // good/jackpot can snap early — pace stays fast
const REVEAL_THRESHOLD_PENALTY = 0.85;   // penalty MUST reach 85% — preserves skill-stop
```

Replace the trigger check at index.html:758:
```js
if (!cell.triggered) {
  const threshold = (cell.symbol.type === 'penalty')
    ? REVEAL_THRESHOLD_PENALTY
    : REVEAL_THRESHOLD_GOOD;
  if (newPct >= threshold) triggerSymbol(cell);
}
```

### C1.b — Remove auto-clear after trigger

Delete the auto-clear block at index.html:838-844. The mask stays under user control after a cell triggers. Trigger feedback comes from the floatText + cellMeta (already present), not from forcing the whole canvas to clear.

New `triggerSymbol`:
```js
function triggerSymbol(cell) {
  cell.triggered = true;
  if (cell.symbol.type === 'penalty') {
    cell.penalized = true;
    floatFromCell(cell, fmt(cell.symbol.value * penaltyMult()), 'bad');
  } else {
    floatFromCell(cell, '+' + fmt(cell.symbol.value), 'good');
  }
  refreshCellMeta(cell);
}
```

### C1.c — Symbol silhouette during partial reveal

Players need to read the symbol type *before* the trigger fires, or skill-stop is impossible. Make the `cellContent` fade in proportionally to `revealPct`:

In `refreshCellMeta`, before the `if (cell.triggered)` branch:
```js
const cellEl = document.querySelector('.cardCell[data-idx="' + cell.idx + '"]');
const contentEl = cellEl?.querySelector('.cellContent');
if (contentEl && !cell.triggered) {
  contentEl.style.opacity = Math.min(1, 0.2 + cell.revealPct * 1.4);
}
// Telegraph penalty: pulse red border when penalty cell is past 60% reveal
if (cellEl && !cell.triggered && cell.symbol.type === 'penalty' && cell.revealPct > 0.6) {
  cellEl.style.boxShadow = '0 0 12px rgba(255,102,102,0.7)';
} else if (cellEl && !cell.triggered) {
  cellEl.style.boxShadow = '';
}
```

The 0.2 floor ensures even at 0% reveal there's a faint hint — players need *something* to peek at. Tune later if too generous.

### C1.d — Drag smoothing (lerp between pointer events)

Currently `onpointermove` paints one circle per move event. A fast swipe across a cell at 1000px/s on a 100px-wide cell hits the threshold in a single frame. Skill-stop dies.

Replace the pointer handlers in `initCellCanvas`:
```js
let scratching = false;
let lastPt = null;

canvas.onpointerdown = e => {
  e.preventDefault();
  if (currentCard.cashedOut) return;
  scratching = true;
  const p = pt(e);
  paintAt(p.x, p.y);
  lastPt = p;
};
canvas.onpointermove = e => {
  if (!scratching || currentCard.cashedOut) return;
  const p = pt(e);
  if (lastPt) {
    // Interpolate along the segment so a fast swipe still paints continuously,
    // and updateCellReveal fires at each step — gives skill-stop a chance to react.
    const dx = p.x - lastPt.x, dy = p.y - lastPt.y;
    const dist = Math.hypot(dx, dy);
    const r = brushRadius();
    const steps = Math.max(1, Math.ceil(dist / (r * 0.6)));
    for (let i = 1; i <= steps; i++) {
      const t = i / steps;
      paintAt(lastPt.x + dx * t, lastPt.y + dy * t);
    }
  } else {
    paintAt(p.x, p.y);
  }
  lastPt = p;
};
canvas.onpointerup = canvas.onpointerleave = () => {
  scratching = false;
  lastPt = null;
};
```

**Acceptance for C1:**
- Drag at moderate speed across a worm cell → you SEE the worm silhouette at ~40-60% reveal and can stop dragging before it triggers
- Good symbols snap at 30% (fast pace preserved)
- Penalty symbols require ≥85% (skill window preserved)
- Cards take 10-40s to fully play (spec target — was ~3-8s before)
- Cash Out becomes a real decision again

---

## C2 — Remove negative-cash floor + stuck-state recovery

**The problem.** index.html:872 (`if (state.cash < 0) state.cash = 0;`) and index.html:544-548 (stuck-state auto-bump) hide the high-risk identity of Snake Eyes. Spec §11 line 278: *"Negative-payout cards must be possible. A bad run on Snake Eyes can lose money — keep that."*

### C2.a — Delete the floor

index.html:872 — delete the line.

### C2.b — Delete stuck-state recovery

index.html:544-548 — delete the block:
```js
// DELETE THIS:
const cheapest = Math.min(...CARD_TYPES.map(c => Math.ceil(c.cost * ...)));
if (s.cash < cheapest) { s.cash = Math.max(s.cash, 20); }
```

### C2.c — Replace with wipe-out modal

After `cashOut` finishes, if player can't afford the cheapest non-final card, offer two choices:

```js
function cheapestNonFinalCost() {
  return Math.min(...CARD_TYPES
    .filter(c => c.id !== 'final_chance')
    .map(c => cardCost(c)));
}

function maybeWipeOut() {
  if (state.cash >= cheapestNonFinalCost()) return;
  showModal('💀 Wiped Out',
    `You can't afford another card. Your run is over.<br><br>` +
    `<div style="display:flex;gap:10px;justify-content:center;margin-top:14px;">` +
      `<button class="btn prestige" id="btnEmergencyPrestige">⭐ Take 1 JP and Reset</button>` +
      `<button class="btn danger" id="btnRestartBroke">🗑 Restart at $20</button>` +
    `</div>`);
  document.getElementById('btnEmergencyPrestige').onclick = () => {
    state.jackPoints += 1;
    state.cash = 0;
    state.runNumber++;
    startNewRun(state, false);
    document.getElementById('modal').classList.remove('show');
    renderShop(); updateHud(); saveState();
  };
  document.getElementById('btnRestartBroke').onclick = () => {
    state.cash = 20;
    startNewRun(state, false);
    document.getElementById('modal').classList.remove('show');
    renderShop(); updateHud(); saveState();
  };
}
```

Call `maybeWipeOut()` at the end of `cashOut` (after the result modal closes). And in `loadState` after migration — in case save came in broke.

**Acceptance:**
- Snake Eyes can produce net -$300 cards; balance can go negative
- When balance falls below cheapest card, modal offers 2 choices (no silent revert)
- Bankruptcy is a legitimate prestige trigger — the player chose it

---

## C3 — Catalog gating by economic readiness

**The problem.** index.html:498 uses `requiredCardsScratched: 5` — Quick Cash at $5 with +$6 EV means 5 cards in ~90 seconds, well before the player has $100 to buy Snake Eyes. The gate adds zero pacing.

### C3.a — Track high water mark

Add to `freshState()`:
```js
cashHighWaterMark: 20,
```

After every `state.cash += ...` or in `updateHud`, sync:
```js
if (state.cash > state.cashHighWaterMark) state.cashHighWaterMark = state.cash;
```

Easiest: stick it inside `updateHud()` so every HUD refresh keeps HWM current.

### C3.b — Switch catalog gate

Replace CATALOGS at index.html:496-499:
```js
const CATALOGS = [
  { id: 'starter', name: 'Starter Catalog', requiredHWM: 0,    cards: ['quick_cash', 'apple_tree', 'final_chance'] },
  { id: 'casino',  name: 'Casino Catalog',  requiredHWM: 150,  cards: ['snake_eyes', 'scratch_my_back'] }
];
```

Update gating check in `renderShop` at index.html:986:
```js
const unlocked = state.cashHighWaterMark >= cat.requiredHWM;
// ...
header.textContent = unlocked
  ? `📚 ${cat.name}`
  : `🔒 ${cat.name} (unlock at ${fmt(cat.requiredHWM)} cash high-water-mark — you've hit ${fmt(state.cashHighWaterMark)})`;
```

Reset HWM on prestige in `triggerPrestige`:
```js
state.cashHighWaterMark = 20;
```

**Acceptance:**
- Casino locked until player has reached $150 (forces ~1 successful Apple Tree run)
- HWM resets each prestige — re-earning Casino unlock is part of the run loop
- Snake Eyes never appears affordable but un-unlockable

---

## C4 — Prestige math anti-hoard

**The problem.** `JP = floor(sqrt(cash/100))` (index.html:583) + flat $500 Final Chance cost = optimal play is "hoard to $2,500 then prestige once." Buying Final Chance at $500 yields 2 JP, same as if you hadn't bought it (cash was $400). The commitment costs nothing — but the player should be rewarded for it.

### C4.a — New JP formula

Replace `jackEstimate` at index.html:583:
```js
function jackEstimate(cashAtPrestige, cardsThisRun) {
  const fromCash    = Math.max(0, Math.floor(Math.sqrt(cashAtPrestige / 50)));
  const fromCards   = Math.floor((cardsThisRun || 0) * 0.05);  // 1 JP per 20 cards played
  const commitBonus = 1;                                        // baseline for taking the leap
  return fromCash + fromCards + commitBonus;
}
```

New thresholds for fromCash:
- 1 JP @ $50, 2 JP @ $200, 3 JP @ $450, 5 JP @ $1.25k, 10 JP @ $5k.

With commit + cards: prestige at $500 + 10 cards = `3 + 0 + 1 = 4 JP` (was 2). Prestige at $2,500 + 50 cards = `7 + 2 + 1 = 10 JP`. Hoarding still pays more — but the early-prestige path is now viable instead of strictly dominated.

### C4.b — Scale Final Chance cost with prestige count

Override `cardCost` for final_chance:
```js
function cardCost(c) {
  if (c.id === 'final_chance') {
    return Math.ceil(c.cost * Math.pow(1.5, state.runNumber - 1) * discount());
  }
  return Math.ceil(c.cost * discount());
}
```

Final Chance: $500 → $750 → $1125 → $1687 → $2531 across runs 1-5. Forces the player to actually grind cash on later runs; the prestige bar climbs.

### C4.c — Pass cardsThisRun to jackEstimate

The prestige info display at index.html:1037-1039 needs the cards count. Update `triggerPrestige` at index.html:927:
```js
function triggerPrestige(finalPayout) {
  const cashAtPrestige = state.cash + finalPayout;
  const cardsThisRun = state.cardsScratched;
  const earned = jackEstimate(cashAtPrestige, cardsThisRun);
  state.jackPoints += earned;
  state.runNumber++;
  state.cash = 0;
  state.cashHighWaterMark = 20;
  showModal('⭐ Prestige!',
    `Run ${state.runNumber - 1} complete.<br>` +
    `Final payout: <b>${fmt(finalPayout)}</b><br>` +
    `Jack Points earned: <b style="color:#aaf080">${earned}</b><br>` +
    `<small>(Cash: +${Math.floor(Math.sqrt(cashAtPrestige/50))} · Cards: +${Math.floor(cardsThisRun*0.05)} · Commit: +1)</small>`);
  startNewRun(state, false);
  scheduleAutoScratch();
  currentCard = null;
  renderCardArea();
  renderShop();
  saveState();
  updateHud();
}
```

And update the live estimate at index.html:1037:
```js
const fc = CARD_TYPES.find(c => c.id === 'final_chance');
const projectedCash = state.cash + fc.symbols[0].value;
const est = jackEstimate(projectedCash, state.cardsScratched);
document.getElementById('prestigeInfo').textContent =
  `Buying Final Chance now → ~${est} JP (cards played: ${state.cardsScratched}). Banked: ${state.jackPoints} ⭐ · FC cost: ${fmt(cardCost(fc))}`;
```

**Acceptance:**
- Early prestige (run 1, $500, 10 cards) gives 4 JP — feels like a reward, not a tax
- Patient prestige (run 1, $2500, 50 cards) gives 10 JP — hoarding still pays, just isn't dominant
- Final Chance cost scales 1.5×/run — player has to keep playing
- Prestige info shows the breakdown so players understand the formula

---

## C5 — Area Size as risk upgrade

**The problem.** index.html:504 — Area Size ($100, ×1.7) and Scratch Power ($50, ×1.6) do the same thing (speed up card completion), but Area Size costs 2.6× more cumulative. Strictly dominated.

### C5.a — Make Area Size a deliberate tradeoff

Bigger brush = covers more area per drag = harder to skill-stop precisely on penalty cells. Larger brush at high levels makes the penalty threshold *effectively* lower because you can overshoot. Players have to choose: throughput vs precision.

Replace UPGRADES entry for areaSize at index.html:504:
```js
{ id: 'areaSize', name: 'Area Size', costBase: 80, costScale: 1.5,
  desc: l => `brush radius +${l*5}px — faster scratch, but harder to stop precisely on penalties` }
```

Brush radius formula at index.html:570:
```js
function brushRadius() { return 15 + state.upgradeLevels.areaSize * 5; }
```
Already correct, just rebalanced cost.

### C5.b — Add the precision penalty

At Area Size level ≥3, raise the penalty threshold slightly to model the "overshoot" — bigger brush, harder to stop on the dime, so the game gives you a bit more margin but it's still net harder because each frame paints more area:

```js
function penaltyThreshold() {
  // Bigger brush overshoots — game compensates by raising threshold a bit, but lerp + bigger paint per move means the player still overshoots in practice.
  return REVEAL_THRESHOLD_PENALTY + Math.min(0.10, state.upgradeLevels.areaSize * 0.025);
}
```

And in the trigger check (C1.a):
```js
const threshold = (cell.symbol.type === 'penalty')
  ? penaltyThreshold()
  : REVEAL_THRESHOLD_GOOD;
```

At areaSize=4, penalty threshold = 0.95 — but the brush is now 35px (vs starting 15px), so a single move paints ~5× the area, and the lerp fills more steps per frame. In practice the player triggers penalties MORE often, not less. The threshold rise is a small mercy that doesn't fully compensate.

**Acceptance:**
- Area Size and Scratch Power are no longer interchangeable
- High-Area-Size builds clear safe cards (Quick Cash) very fast but struggle on Apple Tree / Snake Eyes
- Low-Area-Size + high-Scratch-Power builds are precision-skill builds
- Player has a meaningful build decision past run 1

---

## What's NOT in this patch (and why)

| Thing | Why deferred |
|---|---|
| Rename / theme / IP-policy fixes | Prototype is internal validation, not store submission. Handle at Unity port. |
| Archetype relabel | Doc-only; doesn't change validation outcome. |
| Premium currency / IAP / ad stubs | F2P shell — not the plugin under test. |
| Daily quests / login / events / battle pass | Retention shell — Unity port concern. |
| Inbox / push triggers / welcome-back | Retention shell. |
| FTUE state machine / coach marks | Helps onboard but doesn't change whether the plugin works; design the rigged tutorial card during Unity port. |
| Talent tree expansion (6 → 18 nodes) | Content. 6 talents is enough to validate the meta-loop shape. |
| New card types (Platinum, Cosmic, etc.) | Content. 5 cards cover all 4 ruleset families. |
| Mundo digital assistant | Content. Auto-Scratcher already validates the automation surface. |
| Leaderboards / Rival ghost | Social shell. |
| Analytics events | Unity port wires real BI. Local console.log is enough for prototype. |
| Save migration to new key | No rename, so no migration needed. |

If, after playing the patched prototype, any of these become blockers for what you're trying to learn — add them. Don't pre-emptively.

---

## Validation checklist (when C1-C5 are done)

- [ ] Drag a worm cell at moderate speed → silhouette visible at ~40-60%, can stop before trigger
- [ ] Good symbols trigger at 30%, penalties at 85%+
- [ ] No auto-clear after trigger; mask stays where the player left it
- [ ] Cards take 10-40s to fully scratch (was ~3-8s)
- [ ] Cash Out feels like a real decision, not vestigial
- [ ] Snake Eyes can produce a net -$300 card
- [ ] Balance can go negative; wipe-out modal offers Take 1 JP / Restart $20
- [ ] Stuck-state auto-bump is gone
- [ ] Casino catalog locked until cash HWM ≥ $150
- [ ] HWM resets on prestige
- [ ] First prestige at $500 + 10 cards yields ~4 JP (was 2)
- [ ] First prestige at $2500 + 50 cards yields ~10 JP
- [ ] Final Chance cost climbs 1.5×/run
- [ ] Prestige info shows the JP breakdown
- [ ] Area Size at level 3+ noticeably reduces precision; Scratch Power doesn't
- [ ] Cards remain playable end-to-end (no crashes, no NaN, no infinite triggers)

## File-level outline of changes

```
prototype-scratchy/index.html
├── <script>
│   ├── REVEAL_THRESHOLD = 0.25 → REVEAL_THRESHOLD_GOOD + _PENALTY    [C1a]
│   ├── freshState: + cashHighWaterMark                                [C3a]
│   ├── loadState: remove stuck-state recovery                         [C2b]
│   ├── cardCost: scale final_chance by runNumber                      [C4b]
│   ├── jackEstimate: split formula (cash + cards + commit)            [C4a]
│   ├── UPGRADES[areaSize]: rebalance cost + risk wording              [C5a]
│   ├── penaltyThreshold(): new helper                                 [C5b]
│   ├── initCellCanvas: drag lerp                                      [C1d]
│   ├── updateCellReveal: use split threshold + penaltyThreshold()     [C1a, C5b]
│   ├── refreshCellMeta: silhouette opacity + penalty pulse            [C1c]
│   ├── triggerSymbol: REMOVE auto-clear                               [C1b]
│   ├── cashOut: remove negative floor, call maybeWipeOut              [C2a, C2c]
│   ├── cheapestNonFinalCost + maybeWipeOut: new helpers               [C2c]
│   ├── triggerPrestige: pass cardsThisRun, reset HWM, show breakdown  [C4c]
│   ├── updateHud: bump cashHighWaterMark                              [C3a]
│   └── renderShop: catalog gate by HWM + show FC cost / live estimate [C3b, C4c]
```

That's it. Five patches, one file, ~3-4 hours, restores the prototype to validating the thing it was built to validate.
