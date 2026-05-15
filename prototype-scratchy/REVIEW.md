# Scritchy Scratchy — Archetype + Plugin Review (4-agent audit)

Date: 2026-05-15
Inputs reviewed: prototype-scratchy/index.html (1104 LoC, working) + prototype-scratchy-booster.md (316 LoC spec)
Agents dispatched: prototype-review · prototype-economy · prototype-systems · prototype-analyst

## TL;DR

- **🔴 SKILL-STOP IS DEAD.** `REVEAL_THRESHOLD = 0.25` (index.html:517) + auto-clear branch (index.html:838-844) kills the spec-mandated 85% peek-and-decide window. Spec §11 line 275 marked this rule do-not-violate; current build violates it. **All 4 agents flagged this as #1.** Without it, Apple Tree + Snake Eyes degrade to "EV calculator with extra steps" and Cash Out becomes vestigial.
- **🏷️ Archetype mis-labeled.** Declared "Prestige-Idle" but plugin is active drag-gesture with zero offline accrual. Actual fit: **Roguelite Prestige Arcade**. Mis-label steers downstream F2P decisions toward idle conventions the core can't support.
- **💰 Negative-cash floor breaks Snake Eyes identity.** `if (state.cash < 0) state.cash = 0;` (index.html:872) plus stuck-state recovery (index.html:545-548) violate spec §11 ("Negative-payout cards must be possible").
- **📚 Catalog gating is cosmetic.** Casino unlocks at 5 cards scratched (~90s of play) — well before player has $100 to actually afford Snake Eyes. Gate adds zero pacing.
- **⭐ Prestige rewards hoarding.** `JP = floor(sqrt(cash/100))` + flat $500 cost = optimal play is "ignore Final Chance until $2.5k+". Prestiging at $500 yields 2 JP; same as $400. Player is punished for the intended use.
- **📅 Day-to-day layer empty.** No daily login, no quests, no inbox, no events, no offline-earnings ("welcome back" promise an idle archetype implies). All spec §4 Phase-2 stubs unbuilt.
- **🚫 Theme/policy risk.** Scratch-lottery imagery + jackpot + cash payouts: Apple 17+ rating (Guideline 5.3, June 2025), Google policy April/Oct 2025 sweepstakes reclassification. Source ships premium Steam ($7), no F2P retention shell — and the prototype inherits zero monetization while still carrying the legal risk surface.
- **📦 Content thin.** Source has 17 cards across 4 catalogs; prototype has 5 in 2. Talent count 6 vs source's 8. Card variety exhausts in single session.

---

## Ranked holes (consolidated, cross-validated)

### 🔴 R1 — Skill-stop dead: REVEAL_THRESHOLD = 0.25 + auto-clear
**Where:** index.html:517 (`REVEAL_THRESHOLD = 0.25`), :758 (trigger), :838-844 (auto-clear remaining mask).
**Comment in code** literally says: *"// symbol triggers at 25% then auto-clears the rest (faster pace per player request)"* — silent regression under a "tuning" label.

**Why it matters:** Spec §11 line 275: *"Skill-stop is the core USP. Penalty symbols MUST only trigger at >85% reveal. If you trigger them earlier, the tension dies."* Without peek-then-decide:
- Worm in Apple Tree fires before player can recognize the silhouette
- Cash Out becomes a probability bet, not a skill move (spec target: 20-40% early cash-outs → reality: ~0-5%)
- Apple Tree and Snake Eyes become functionally identical to Quick Cash from a decision standpoint
- Auto-Scratcher's "can't skill-stop" downside evaporates because manual play can't either
- Per-card duration falls from spec's 10-40s → likely 3-8s

**Patch direction:** revert threshold to **0.80-0.85**; remove auto-clear after trigger; OR split: 0.25 for good symbols (fast pace), 0.85 for penalties (skill window preserved). The "faster pace" stated goal can instead be met by bumping default brush radius or Scratch Power baseline.

### 🔴 R2 — Negative cash floor + stuck-state recovery break Snake Eyes
**Where:** index.html:872 (`if (state.cash < 0) state.cash = 0`); :544-548 (auto-bump to $20 if broke).

**Why it matters:** Spec §11 line 278: *"Negative-payout cards must be possible. A bad run on Snake Eyes can lose money — keep that. Don't soft-cap it to 'always net positive'."* High-risk slot in card matrix becomes redundant with med-risk. Snake Eyes promise ("runs can lose money", index.html:452) becomes a lie.

**Patch:** remove the floor. Remove stuck-state recovery. Bankruptcy is a legitimate prestige trigger — when cash hits 0, fire a "Wiped Out" modal that offers (a) bail-out via rewarded-ad stub for $20, (b) commit-to-prestige early (refund Final Chance? give 1 JP for the failed run?). Turn failure into monetization touchpoint.

### 🔴 R3 — Archetype mis-label: not Prestige-Idle, but Roguelite Prestige Arcade
**Why:** Plugin demands active continuous drag (10-40s/card per spec); zero offline accrual; Auto-Scratcher only runs while tab open with a card queued; structure matches roguelite-meta-progression (Vampire Survivors / Balatro) not idle.

**Why it matters:** Mis-label cascades into wrong F2P hooks (offline bundles, time-skip IAP, manager-style automation) that the active core can't support. Wrong benchmarks (AdCap retention floors) applied to active-gesture content.

**Patch:** relabel archetype to **Roguelite Prestige Arcade** in spec + project config. Keep prestige math + talent tree (those parts ARE faithful idle-prestige). Drop the idle framing. Auto-Scratcher remains a plugin-assist feature, not an archetype pillar.

### 🔴 R4 — Catalog gating is cosmetic
**Where:** index.html:496-499 (`requiredCardsScratched: 5`).

**Math:** Quick Cash $5, EV ~$11.30, net ~+$6.30/scratch. 5 scratches in 60-90s from $20 starting cash. Casino unlocks before player can afford Snake Eyes ($100) or Scratch My Back ($60). Gate doesn't gate.

**Patch:** gate Casino by **economic readiness OR prestige count**, not card count:
- `state.cashHighWaterMark ≥ 200` OR
- `state.prestigeCount ≥ 1`

Add 2 more catalogs for prestige 2/3/4 to keep meta progression alive.

### 🔴 R5 — Prestige rewards hoarding, punishes intended use
**Where:** index.html:583 (`floor(sqrt(cash/100))`) + flat $500 Final Chance cost (index.html:485) + auto-fires on full reveal (index.html:795).

**Math:** JP thresholds → 1 JP @ $100, 2 JP @ $400, 3 JP @ $900, 5 JP @ $2.5k, 10 JP @ $10k.
- Buying Final Chance at $500 cash yields 2 JP (same as $400 if you hadn't bought)
- The $500 spend literally costs zero JP — but the player should be rewarded for committing
- Optimal play: hoard to $2,500+ then prestige once. Cards 6-30 of the run are wasted on stockpile, not engagement.

**Patch options (pick one):**
- Scale Final Chance cost: `cost = 500 * 1.5^prestigeCount`
- Change formula: `JP = floor(sqrt(cash/50)) + cardsScratchedThisRun * 0.05` — rewards play volume + cash
- Add JP bonus on Final Chance: `JP_total = JP_from_cash + 1` (the +1 is the commitment reward)

### 🔴 R6 — Theme/IP/store-policy risk
**Risks:**
- "Scratch lottery + cash + jackpot" hits Apple Guideline 5.3 + June 2025 17+ rating update
- "Cash" as currency name is borderline (real-money language) — keep visually distinct from real money or rename
- Google Play Oct 2025 sweepstakes reclassification + Jan 2026 age-gate enforcement (active as of today)
- Source name "Scritchy Scratchy" is trademarked by Lunch Money Games / Funday Games — cannot ship under that title

**Patch:**
- Rename project (placeholder: **Lucky Slip** / **Coin Cards** / **Scratch Stack**)
- Rename "Cash" → "Coins" or "Tokens" (gameplay currency, not real-money signal)
- Add 17+/age-gate readiness now
- Never add: real prizes, gift cards, redeemable currency, dual-currency-with-cashout

### 🟡 R7 — Negative-EV scenarios masked by skill-stop break (interaction of R1)
With skill-stop dead (R1), Apple Tree's worm fires 86.6% of the time if played to completion. Without the peek-window players can't avoid worms → effective EV drops from spec's intended +$133 (skill-stop preserved) to ~+$50-80 (one worm per card average) on a $25 spend. Still positive, but EV variance way higher than designed. Snake Eyes: 15-18% of cards net negative on the EV math — fine, but with R1 dead the player has no skill agency to mitigate.

**Patch:** R1 fixes this transitively. No standalone patch needed.

### 🟡 R8 — Area Size strictly dominated by Scratch Power
**Where:** index.html:504 (`areaSize: costBase 100, costScale 1.7`).
- Same purpose as Scratch Power (faster card completion)
- Cumulative cost to Lv5: Scratch Power $790, Area Size $2,036 — 2.6× more for similar throughput
- Strictly inferior

**Patch:** repurpose Area Size as **risk upgrade** — larger radius = harder to skill-stop on penalty cells (more EV per scratch but worse defensive play). Creates a meaningful tradeoff. OR rebalance to $50/×1.5 and make it multiplicative with Scratch Power.

### 🟡 R9 — Day-to-day layer empty
- No daily login, no quests, no offline-earnings ("come back" hook), no inbox, no events, no BP
- Spec §4 Phase-2 stubs (daily quest, rewarded ad, premium pack) all unbuilt
- For an "active-gesture × idle" hybrid the right between-session promise is **bankable, not auto-progressing**: tip-jar cap of 30 min auto-scratch output collected on return, one free pre-stocked card after 4h absence, "your run is still going, $X earned" welcome-back banner

**Patch stack:**
1. Daily login modal + 28-day calendar
2. 3 rotating daily quests (Scratch 10, Trigger 3 jackpots, Survive Snake Eyes positive)
3. Welcome-back modal computing `daysSinceLastSession` on load
4. Inbox + 4 push triggers (event live, queue-stocked, personal-best, catalog-unlocked)
5. Weekly themed catalog override (Pumpkin Pull, Lucky Hour, Speedrun, High Roller)
6. 4-week season pass

### 🟡 R10 — Talent tree thin + no run-2+ scaling
- 6 flat one-shot talents, total cost 11 JP — all max-able in ~3-4 prestiges
- No per-prestige challenge modifier, no card unlocks tied to prestige count, no scaling node tiers
- Macro-loop death cliff after prestige #4

**Patch:**
- Expand to **15-20 talents** including 8 from source (Picky Eater, Lucky permanent, etc.)
- Add `prestigeCount`-gated card unlocks: Scratch My Back at prestige 1, two more cards at prestige 2/3
- Convert one talent to repeatable tiered node (Allowance I/II/III/IV)

### 🟡 R11 — Zero monetization surface
- No premium currency (Lucky Coins)
- No IAP stubs (Phase-2 spec $1.99 Guaranteed Jackpot pack unbuilt)
- No rewarded-ad slots (spec'd 3 placements: peek 1 cell pre-scratch, double-or-nothing post-Cash-Out, +50% JP on prestige)
- No starter/comeback/prestige bundles
- Cosmetic card backs absent

**Patch:** add premium currency state field, 4 IAP gem packs + $1.99 Specials pack, 3 rewarded-ad slots, post-#1 starter pack offer ($2.99 → +$500 + Auto-Scratcher Lv1).

### 🟡 R12 — FTUE absent
- No `state.ftueStep`, no progressive tab unlock, no scripted first card
- Card descriptions act as inline tutorial — works for veterans, fails new players
- Skill-stop concept (the USP) gets ZERO onboarding — even if R1 is patched, players won't know to peek-and-stop

**Patch:** scripted first card (rigged Apple Tree with one obvious worm in known position) + coach-mark tooltip "Stop dragging when you see the worm. Cash Out to keep your apples." Progressive tab unlock: Home + Shop at t=0, Upgrades after card 1, Log after card 5, Prestige after first Final Chance.

### 🟢 R13 — Bug: Auto-Scratcher rate at level 0 returns 0 from formula but UI suggests level 0 means OFF (cosmetic; works correctly via the `if (l <= 0)` guard at :576)

### 🟢 R14 — Content breadth: 5 cards vs source's 17, 2 catalogs vs source's 4. Single-session exhaustion. Defer to Unity port if scope-pressed, but a "Coming Soon" tease in shop would soften.

### 🟢 R15 — Mundo (digital assistant ticket-buyer) absent. Source has TWO automation surfaces (scratch bot + Mundo); prototype has one. Plugin-level missing feature; defer.

---

## What's working (don't touch)

- Drag-canvas paint mechanic (index.html:691-735) — `destination-out` + alpha sampling. Solid.
- Per-card ruleset matrix (index.html:800-833) — match_n / per_symbol_accumulate / per_cell_binary / final_chance all correctly evaluated.
- Card RNG seeding at purchase (index.html:619-629) — deterministic, reload-safe.
- Auto-Scratcher correctly gated from high-risk + final_chance (index.html:685, 907) — preserves automation tension when skill-stop works.
- Bottom-nav 5-tab shell + center Home button — mobile-game appropriate.
- Save/load with 5s autosave + beforeunload hook — works.

## Source-fidelity score

| Layer | Faithfulness vs Steam source | Notes |
|---|---|---|
| Drag mechanic | High | Kotaku praised source: "comes pretty close to actual scratching"; prototype mechanic faithful |
| Skill-stop trigger | **Broken** (R1) | 0.25 + auto-clear → skill-stop dead |
| Per-card rulesets | Medium | 5 cards vs source's 17, but all 4 ruleset families represented |
| Talent tree | Low (depth) | 6 vs source's 8; missing Picky Eater + Luck-tier permanent |
| Auto-Scratcher | High | Correctly can't skill-stop, locked from risky cards |
| Mundo (digital assistant) | Absent | Plugin-level missing automation surface |
| Catalogs | Low (depth) | 2 vs source's 4 |
| Final Chance | Faithful structure, compressed numbers ($500 vs source $50M endgame) |

---

## Suggested next moves

1. **🔴 Patch R1 immediately, in isolation, then playtest.** Skill-stop dead = prototype is not testing what spec intended to test. One-line revert + remove auto-clear branch + 1h playtest.
2. **🔴 Patch R1-R6 (red tier) then playtest again.** Foundational integrity restored. Estimated 1-2 days.
3. **Or scope-down for Unity port**: accept R9-R11 as Phase 2; R1 + R2 + R3 + R4 + R5 + R6 are mandatory pre-port. R7-R12 deferrable.

---

## File references

- `index.html` key lines: 517 (REVEAL_THRESHOLD), 545-548 (stuck-state recovery), 583 (jackEstimate), 685 (auto-scratcher gating), 758 (trigger), 800-833 (ruleset eval), 838-844 (auto-clear after trigger), 872 (negative cash floor), 927-944 (prestige flow)
- `prototype-scratchy-booster.md` §3 (time-scales), §5 (data model), §9 (tuning targets), §11 (do-not-violate rules), §12 (out-of-scope flags)
- Source: [Scritchy Scratchy on Steam](https://store.steampowered.com/app/3948120/Scritchy_Scratchy/), [Notebookcheck 2026-03-25](https://www.notebookcheck.net/Steam-surprise-hit-This-quirky-scratch-off-idle-game-is-delighting-thousands.1258716.0.html), [Kotaku 2026-03-27](https://kotaku.com/new-hit-steam-game-lets-me-enjoy-scratch-off-lotto-tickets-without-feeling-terrible-and-i-love-it-2000682652), [scritchyscratchy.wiki](https://scritchyscratchy.wiki/scratchers/)
