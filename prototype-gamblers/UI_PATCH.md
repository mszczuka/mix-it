# Gamblers — UI Patch

Date: 2026-05-15
Target: `prototype-gamblers/index.html`
Scope: **reorganize the navigation and surface the prestige loop**. No new gameplay, no new content — just UI restructuring so the player can find what already exists.

> **Why this patch.** Current build has 6 bottom-nav tabs (Coins, Helpers, Home, Tables, Skills, Pass) — too many, too thin per tab. Monetization (Pass + IAP + Ads) is scattered across 2 tabs. The Skill Points loop is invisible — the RESET button is buried in the Skills tab so new players never find it. Missions/dailies live in the same Coins tab as the shop, making both feel cluttered.

---

## The 5 patches

| # | What | Effort |
|---|---|---|
| U1 | Bottom nav: 6 tabs → 3 (Shop · Home · Skills); add SHOP tab consolidating Pass + IAP + Ads | 30min |
| U2 | Home overlay buttons: Coins / Helpers / Tables / Daily (open as modals over table) | 45min |
| U3 | Missions/Daily popup via small square button on Home | 20min |
| U4 | Prominent Wipe Save in Skills tab + confirm flow (already exists, move to top) | 10min |
| U5 | Skill Points clarity: ready-to-reset HUD badge + inline explainer + reset CTA on Home | 30min |

Total: ~2-2.5h.

---

## U1 — Bottom nav redesign

### Current

```
[🪙 Coins] [👥 Helpers] [🏠 Home] [🎲 Tables] [⭐ Skills] [🎟 Pass]
```

6 tabs. `body` CSS toggles `tab-coins`/`tab-helpers`/etc. to show one `.tabSection` at a time inside `#shop`.

### New

```
[🛒 Shop] [🏠 Home] [⭐ Skills]
```

3 tabs. `🛒 Shop` = monetization-only (Pass + Gem packs + Rewarded Ads + Starter Pack). `🏠 Home` = play area with overlay buttons (U2). `⭐ Skills` = talent tree + Reset Run + Wipe Save (U4).

### Code changes

**HTML — replace the `<nav id="bottomNav">` block at index.html:562-569:**

```html
<nav id="bottomNav">
  <button class="navBtn" data-tab="shop"><span class="icon">🛒</span>Shop</button>
  <button class="navBtn home active" data-tab="home"><span class="icon">🏠</span>Home</button>
  <button class="navBtn" data-tab="skills"><span class="icon">⭐</span>Skills</button>
</nav>
```

**HTML — restructure the `.tabSection` blocks inside `#shop` at index.html:509-559:**

Delete: `.tabSection.t-coins`, `.tabSection.t-helpers`, `.tabSection.t-tables`, `.tabSection.t-pass` (their contents move — coins/helpers/tables go to U2 modals, pass goes inside Shop).

Keep + restructure:

```html
<div id="shop">
  <!-- SHOP tab: monetization hub -->
  <div class="tabSection t-shop">
    <div class="section-title">🎟 Season Pass</div>
    <div id="seasonPass"></div>

    <div class="section-title">💎 Gem Packs</div>
    <div id="iapShop"></div>

    <div class="section-title">📺 Rewarded Ads</div>
    <div id="adShop"></div>

    <div class="section-title">🎁 Special Offer</div>
    <div id="starterPackSlot"></div>  <!-- shows starter_pack one-shot here when available -->
  </div>

  <!-- SKILLS tab: prestige + meta -->
  <div class="tabSection t-skills">
    <div class="section-title">⭐ Reset Run for Skill Points</div>
    <button class="btn reset" id="btnReset">✨ RESET RUN</button>
    <div class="infoLine" id="resetInfo"></div>

    <div class="section-title">🌳 Skill Tree</div>
    <div class="branchTabs" id="branchTabs"></div>
    <div id="talentTree"></div>

    <div class="section-title">⚠ Danger Zone</div>
    <button class="btn danger" id="btnWipe">🗑 Wipe Save (clear all progress)</button>
    <button class="btn" id="btnDumpAnalytics" style="background:#444;color:#ddd;margin-top:6px;">📊 Dump Analytics</button>
  </div>
</div>
```

**CSS — update the tab toggles at index.html:82-96.** Replace the `body.tab-*` block:

```css
body.tab-home #tableArea { display: block; }
body:not(.tab-home) #shop { display: block; }
body.tab-shop   .tabSection.t-shop   { display: block; }
body.tab-skills .tabSection.t-skills { display: block; }
.tabSection { display: none; }
```

**JS — update `switchTab` at index.html:2020:**

Replace:
```js
document.body.classList.remove('tab-home','tab-coins','tab-helpers','tab-tables','tab-skills','tab-pass');
```
with:
```js
document.body.classList.remove('tab-home','tab-shop','tab-skills');
```

**Initial state** at index.html:489: keep `<body class="tab-home">`.

Anything else that referenced removed tabs (coins/helpers/tables/pass) — those flows now open as modals via U2. Grep for `tab-coins`, `tab-helpers`, `tab-tables`, `tab-pass`, `switchTab('coins'`, etc. and either delete or replace with `openModal*` calls from U2.

---

## U2 — Home overlay buttons (Coins · Helpers · Tables · Daily)

### Concept

A vertical column of square buttons on the Home table area — top-right or top-left edge. Each opens a modal overlay (existing `#modal` infra) showing the previously-tabbed content. Table stays visible behind.

```
┌─────────────────────────────┐
│ ⌚                       🪙 │  ← Coins
│  ╔═══════════════════╗   👥 │  ← Helpers
│  ║                    ║   🎲 │  ← Tables
│  ║      TABLE         ║   📜 │  ← Daily
│  ║                    ║      │
│  ╚═══════════════════╝      │
│        [Score / Cap]        │
└─────────────────────────────┘
```

### HTML — add inside `#tableArea` at index.html:502-507

```html
<div id="tableArea">
  <div id="homeActions">
    <button class="homeBtn" data-action="coins"   title="Buy Coins / Upgrades"><span class="ico">🪙</span><span class="lbl">Coins</span></button>
    <button class="homeBtn" data-action="helpers" title="Helpers / Hats / Bazaar"><span class="ico">👥</span><span class="lbl">Helpers</span></button>
    <button class="homeBtn" data-action="tables"  title="Tables / Event"><span class="ico">🎲</span><span class="lbl">Tables</span></button>
    <button class="homeBtn daily-btn" data-action="daily" title="Daily Quests + Login">
      <span class="ico">📜</span><span class="lbl">Daily</span>
      <span class="dot" id="dailyDot" style="display:none;"></span>
    </button>
  </div>
  <div id="table">
    <div id="tableHint">Click coins to flip. Drag to move. Leave copper 90s to oxidize.</div>
    <div id="helperLane"></div>
  </div>
</div>
```

### CSS — add to `<style>` (near `#table` rules, ~line 145)

```css
#homeActions {
  position: absolute;
  top: 10px; right: 10px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  z-index: 30;
}
.homeBtn {
  width: 56px; height: 56px;
  background: linear-gradient(180deg, rgba(42,15,15,0.92), rgba(20,8,8,0.92));
  border: 2px solid #6b4423;
  border-radius: 10px;
  color: #ffe680;
  cursor: pointer;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 2px;
  font-size: 9px;
  font-weight: bold;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  box-shadow: 0 2px 8px rgba(0,0,0,0.5);
  transition: transform 0.1s, box-shadow 0.1s, border-color 0.1s;
  position: relative;
}
.homeBtn:hover { border-color: #ffe680; transform: scale(1.05); }
.homeBtn:active { transform: scale(0.96); }
.homeBtn .ico { font-size: 22px; line-height: 1; }
.homeBtn .lbl { font-size: 9px; opacity: 0.85; }
.homeBtn .dot { position: absolute; top: 4px; right: 4px; width: 10px; height: 10px; border-radius: 50%; background: #ff4444; box-shadow: 0 0 6px #ff6666; }
@media (max-width: 520px) {
  .homeBtn { width: 48px; height: 48px; }
  .homeBtn .ico { font-size: 18px; }
  .homeBtn .lbl { font-size: 8px; }
}
```

### JS — open content as modals

Add somewhere near the existing modal helpers (~line ~1700):

```js
function openHomeModal(action) {
  let title = '', html = '';
  if (action === 'coins') {
    title = '🪙 Coins & Upgrades';
    html = `
      <h2>${title}</h2>
      <div class="section-title">Buy Coins</div>
      <div id="modalCoinShop"></div>
      <div class="section-title">In-run Upgrades</div>
      <div id="modalUpgradeShop"></div>
      <button class="btn" onclick="closeModal()">Close</button>
    `;
  } else if (action === 'helpers') {
    title = '👥 Helpers';
    html = `
      <h2>${title}</h2>
      <div class="section-title">Hire Helpers</div>
      <div id="modalHelperShop"></div>
      <div class="section-title">Hat Gacha</div>
      <button class="btn gacha" id="modalBtnGacha">🎰 Roll Hat</button>
      <button class="btn iap" id="modalBtnGachaPrem" style="margin-top:6px;">💎 Premium Box (50 Gems)</button>
      <div class="infoLine" id="modalHatInfo"></div>
      <div class="section-title">Token Bazaar</div>
      <div id="modalBazaarShop"></div>
      <button class="btn" onclick="closeModal()">Close</button>
    `;
  } else if (action === 'tables') {
    title = '🎲 Tables';
    html = `
      <h2>${title}</h2>
      <div class="section-title">This Week's Event</div>
      <div id="modalEventInfo"></div>
      <div class="section-title">Tables (Global Effects)</div>
      <div id="modalTableShop"></div>
      <div class="section-title">Leaderboard</div>
      <div id="modalLeaderboard"></div>
      <button class="btn" onclick="closeModal()">Close</button>
    `;
  } else if (action === 'daily') {
    title = '📜 Daily Quests & Login';
    html = `
      <h2>${title}</h2>
      <div class="section-title">Today's Quests</div>
      <div id="modalDailyQuests"></div>
      <div class="section-title">Login Calendar</div>
      <div id="modalDailyCalendar"></div>
      <button class="btn" onclick="closeModal()">Close</button>
    `;
  }
  document.getElementById('modalContent').innerHTML = html;
  document.getElementById('modal').classList.add('show');
  // Re-render the targeted sections into their new modal DOM nodes:
  if (action === 'coins')   renderCoinShop('modalCoinShop'),   renderUpgradeShop('modalUpgradeShop');
  if (action === 'helpers') renderHelperShop('modalHelperShop'), renderBazaar('modalBazaarShop'), renderHatInfo('modalHatInfo'),
                            document.getElementById('modalBtnGacha').onclick = () => { rollHat(); openHomeModal('helpers'); },
                            document.getElementById('modalBtnGachaPrem').onclick = () => { rollPremiumHat(); openHomeModal('helpers'); };
  if (action === 'tables')  renderEventInfo('modalEventInfo'), renderTableShop('modalTableShop'), renderLeaderboard('modalLeaderboard');
  if (action === 'daily')   renderDailyQuests('modalDailyQuests'), renderDailyCalendar('modalDailyCalendar');
}

function closeModal() { document.getElementById('modal').classList.remove('show'); }

// Wire the home buttons
document.querySelectorAll('.homeBtn').forEach(b => {
  b.addEventListener('click', () => openHomeModal(b.dataset.action));
});
```

**Refactor the existing render functions** so each takes a container-id arg instead of hardcoding `'coinShop'` / `'helperShop'` etc. Example for `renderCoinShop`:

```js
function renderCoinShop(targetId = 'coinShop') {
  const cs = document.getElementById(targetId);
  if (!cs) return;
  // ... existing logic populating cs
}
```

Do the same for: `renderUpgradeShop`, `renderHelperShop`, `renderTableShop`, `renderBazaar`, `renderEventInfo`, `renderLeaderboard`, `renderDailyQuests`, `renderDailyCalendar`, `renderHatInfo`. Existing tab-side render calls (`renderShop()` master function) still pass the original IDs — modal calls pass the modal IDs. Zero behavior change in the tab pathway.

### Daily dot badge

```js
function updateDailyDot() {
  const hasUnclaimed = (state.daily?.quests || []).some(q => q.progress >= q.target && !q.claimed)
    || (state.daily?.loginAvailableToday === true);
  document.getElementById('dailyDot').style.display = hasUnclaimed ? '' : 'none';
}
```

Call from `saveState()` or HUD update cycle.

---

## U3 — Missions popup (already covered by U2)

The Daily home button **is** the missions popup. The U2 daily-modal contains: today's 3 quests with claim buttons + the 28-day login calendar.

Just make sure `renderDailyQuests('modalDailyQuests')` shows progress bars and a [CLAIM] button per completed quest:

```js
function renderDailyQuests(targetId = 'dailyQuests') {
  const el = document.getElementById(targetId);
  if (!el) return;
  if (!state.daily?.quests?.length) { el.innerHTML = '<div class="infoLine">No quests today.</div>'; return; }
  el.innerHTML = state.daily.quests.map(q => {
    const done = q.progress >= q.target;
    const pct = Math.min(100, Math.floor(q.progress / q.target * 100));
    return `<div class="shopItem ${done && !q.claimed ? '' : 'disabled'}" data-qid="${q.id}">
      <div class="name">${q.text}</div>
      <div class="desc">Progress: ${q.progress} / ${q.target} (${pct}%)</div>
      <div class="cost">${q.claimed ? '✓ Claimed' : (done ? '🎁 Click to claim' : '...')}</div>
    </div>`;
  }).join('');
  el.querySelectorAll('[data-qid]').forEach(node => {
    node.onclick = () => {
      const q = state.daily.quests.find(x => x.id === node.dataset.qid);
      if (!q || q.claimed || q.progress < q.target) return;
      q.claimed = true;
      if (q.reward.gems)   state.gems   += q.reward.gems;
      if (q.reward.cash)   state.cash   += q.reward.cash;
      if (q.reward.tokens) state.tokens += q.reward.tokens;
      saveState(); updateHud(); renderDailyQuests(targetId); updateDailyDot();
    };
  });
}
```

---

## U4 — Wipe Save (clear all)

The `#btnWipe` button already exists at index.html:551 inside Skills tab debug section. After U1 it lives in the "Danger Zone" section near the top of the Skills tab (more discoverable).

Confirm the wipe handler does what user expects — find the existing handler (grep `btnWipe`) and ensure it shows a confirm:

```js
document.getElementById('btnWipe').onclick = () => {
  if (!confirm('⚠ Wipe ALL progress and start from scratch? This cannot be undone.')) return;
  // Clear all known save keys (current + legacy):
  localStorage.removeItem('coinTable.save.v2');
  localStorage.removeItem('gamblersFlip');
  localStorage.removeItem('coinTable_analytics');
  location.reload();
};
```

That's it for U4. Already present, just made visible by U1's restructure.

---

## U5 — Skill Points clarity (the part you asked about)

**The problem.** Skill Points come from clicking **RESET RUN** in the Skills tab once `cash >= 100K × 10^resetCount`. The button is buried, the threshold is hidden, the reward formula isn't shown anywhere on Home.

**The fix:** make all 4 visible from Home.

### U5.a — Ready-to-reset HUD badge

Add to the HUD's `Resets/Legacy` cell (or as a sibling) at index.html:496:

```html
<div class="hud-stat">
  <span class="hud-label">Resets / Legacy</span>
  <span class="hud-value small" id="resetDisplay">0 / ×1.00</span>
  <span class="reset-ready-badge" id="resetReadyBadge" style="display:none;">🟢 RESET READY</span>
</div>
```

CSS:
```css
.reset-ready-badge {
  display: inline-block;
  margin-top: 2px;
  font-size: 9px;
  color: #1a0a0a;
  background: linear-gradient(180deg, #aaf080, #66bb44);
  padding: 1px 6px;
  border-radius: 8px;
  font-weight: bold;
  animation: readyPulse 1.5s infinite;
}
@keyframes readyPulse { 50% { transform: scale(1.06); filter: brightness(1.1); } }
```

In `updateHud`:
```js
const reward = resetReward();
document.getElementById('resetReadyBadge').style.display = (reward > 0) ? '' : 'none';
document.getElementById('resetReadyBadge').textContent =
  reward > 0 ? `🟢 RESET → ${reward} ⭐` : '';
```

### U5.b — Inline explainer on Home (one-time hint)

Add to the table hint area (index.html:504):

```html
<div id="tableHint">Click coins to flip. Drag to move. Leave copper 90s to oxidize.</div>
<div id="skillHint" style="display:none;">
  💡 Earn ⭐ <b>Skill Points</b> by clicking <b>RESET RUN</b> in the Skills tab when you hit
  <span id="hintThreshold">$100,000</span> cash. Spend SP on the Skill Tree for permanent bonuses.
</div>
```

CSS:
```css
#skillHint {
  position: absolute;
  bottom: 12px; left: 12px; right: 80px;
  background: rgba(212,175,55,0.12);
  border: 1px solid #d4af37;
  border-radius: 8px;
  padding: 8px 10px;
  font-size: 11px;
  color: #ffe680;
  z-index: 12;
  line-height: 1.4;
}
```

JS — show the hint once player has >50% of first threshold AND no resets yet AND not dismissed:

```js
function updateSkillHint() {
  const el = document.getElementById('skillHint');
  if (!el) return;
  const threshold = resetThreshold();
  const ratio = state.cash / threshold;
  const eligible = state.resetCount === 0 && ratio >= 0.5 && !state.skillHintDismissed;
  el.style.display = eligible ? '' : 'none';
  document.getElementById('hintThreshold').textContent = '$' + threshold.toLocaleString();
}
```

Call from `updateHud`. Dismiss when the player resets the first time (set `state.skillHintDismissed = true` inside the reset handler).

### U5.c — Reset CTA inline on Home (appears only when ready)

Right next to the HUD or as a banner above the table — only visible when `resetReward() > 0`:

```html
<button class="btn reset-cta" id="resetCtaBtn" style="display:none;">
  ✨ RESET RUN — Claim <span id="resetCtaReward">1</span> ⭐ Skill Points
</button>
```

CSS:
```css
.btn.reset-cta {
  position: fixed;
  left: 50%; transform: translateX(-50%);
  top: 70px;
  width: auto; max-width: 320px;
  padding: 10px 18px;
  background: linear-gradient(180deg, #aaf080, #339933);
  color: #0a1a08;
  border: 2px solid #66bb44;
  font-size: 13px;
  box-shadow: 0 4px 14px rgba(102,204,102,0.4);
  z-index: 50;
  animation: readyPulse 1.5s infinite;
}
```

JS in `updateHud`:
```js
const reward = resetReward();
const cta = document.getElementById('resetCtaBtn');
if (cta) {
  cta.style.display = reward > 0 ? '' : 'none';
  document.getElementById('resetCtaReward').textContent = reward;
}
```

Wire the click to the same handler the Skills-tab reset button uses:
```js
document.getElementById('resetCtaBtn').onclick = () => document.getElementById('btnReset').click();
```

### U5.d — Reset confirm modal shows the math

Existing reset modal probably just says "Reset?". Replace with a clearer one:

```js
// In the btnReset handler:
document.getElementById('btnReset').onclick = () => {
  const reward = resetReward();
  if (reward <= 0) {
    showModal('Not Yet', `You need ${fmt(resetThreshold())} cash to reset. You have ${fmt(state.cash)}.<br>` +
      `Get richer first — buy more coins, tier up, hire helpers.`);
    return;
  }
  const next = 1e5 * Math.pow(10, state.resetCount + 1);
  showConfirm('✨ Reset Run?',
    `Current cash: ${fmt(state.cash)}<br>` +
    `Threshold: ${fmt(resetThreshold())}<br>` +
    `<b style="color:#aaf080">+${reward} ⭐ Skill Points</b><br>` +
    `<br>The table wipes. You start a new run with $0.<br>` +
    `Next reset will require ${fmt(next)}.<br>` +
    `<br>Spend Skill Points in the tree below for permanent upgrades.`,
    () => {
      state.skillPoints += reward;
      state.resetCount++;
      state.skillHintDismissed = true;
      startNewRun(state, false);
      renderCoins(); renderHelpers(); renderShop(); updateHud(); saveState();
      showModal('✨ Reset!', `+${reward} ⭐ Skill Points earned. Spend them in the Skill Tree.`);
    });
};
```

(Assumes `showConfirm` helper exists from earlier patches; if not, use `if (confirm(...)) { ... }` as a fallback.)

---

## What's NOT in this patch

- No new monetization content — Shop tab just consolidates what already exists
- No new gameplay
- No FTUE coach marks beyond U5.b's single-string hint
- No notification refactor
- No analytics changes
- No archetype/theme changes
- No save migration (no state fields renamed)

If after U1-U5 the SP loop is still unclear, the next iteration is a real FTUE state machine — but try this first.

---

## Validation checklist

- [ ] Bottom nav has exactly 3 buttons: Shop · Home · Skills
- [ ] Shop tab contains: Season Pass, Gem Packs, Rewarded Ads, Starter Pack offer
- [ ] Skills tab contains: Reset Run CTA, Skill Tree (branched), Wipe Save (danger zone)
- [ ] Home shows 4 square buttons (Coins / Helpers / Tables / Daily) on the right edge of the table area
- [ ] Tapping any home button opens a modal with that subsystem's content; table stays visible behind
- [ ] Daily button shows a red dot when an unclaimed quest or login reward is available
- [ ] HUD shows a pulsing "🟢 RESET → N ⭐" badge once `cash >= threshold`
- [ ] Once badge is visible, a fixed-position green CTA banner appears at top of Home: "✨ RESET RUN — Claim N ⭐"
- [ ] Before first reset, when `cash > 50% threshold`, the table hint area shows a one-time inline explainer
- [ ] Reset confirm modal shows: current cash, threshold, reward, next threshold, where to spend SP
- [ ] Wipe Save button shows confirm dialog; on confirm clears localStorage + reloads
- [ ] All previously-tabbed subsystems (coin shop, helpers, hat gacha, bazaar, tables, event, leaderboard, daily quests, login calendar) still work — just accessed via modals now

## File-level outline

```
prototype-gamblers/index.html
├── <style>
│   ├── #homeActions + .homeBtn (+ .dot for daily badge)               [U2]
│   ├── #skillHint                                                      [U5b]
│   ├── .reset-ready-badge + @keyframes readyPulse                      [U5a]
│   ├── .btn.reset-cta                                                  [U5c]
│   └── body.tab-* simplified to home/shop/skills                       [U1]
├── <body class="tab-home">
│   ├── HUD: + .reset-ready-badge inside Resets/Legacy stat             [U5a]
│   ├── #tableArea
│   │   ├── #homeActions: 4 square buttons                              [U2]
│   │   ├── #table                                                       (kept)
│   │   ├── #tableHint                                                   (kept)
│   │   ├── #skillHint                                                  [U5b]
│   │   └── #resetCtaBtn                                                [U5c]
│   ├── #shop:
│   │   ├── .tabSection.t-shop (Pass + IAP + Ads + StarterPack)         [U1]
│   │   └── .tabSection.t-skills (Reset + Tree + Wipe + Analytics)      [U1, U4]
│   └── <nav id="bottomNav">: 3 buttons                                 [U1]
├── <script>
│   ├── renderCoinShop / renderUpgradeShop / renderHelperShop /         [U2]
│   │   renderTableShop / renderBazaar / renderEventInfo /
│   │   renderLeaderboard / renderDailyQuests / renderDailyCalendar /
│   │   renderHatInfo: accept (targetId) arg
│   ├── openHomeModal(action) + closeModal()                            [U2]
│   ├── updateDailyDot()                                                [U2]
│   ├── updateSkillHint()                                               [U5b]
│   ├── updateHud(): + reset-ready badge + CTA + skill hint             [U5a, U5c, U5b]
│   ├── btnReset.onclick: explainer modal w/ math                       [U5d]
│   ├── btnWipe.onclick: confirm + clear all keys + reload              [U4]
│   ├── switchTab: 3-tab roster                                         [U1]
│   └── home-button wire-up                                             [U2]
```

That's the whole thing. ~2-2.5h end-to-end. Ship as v1.2 after the C1-C5 core patch.
