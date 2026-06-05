# Harvest Kingdom — Context & Handoff

**Purpose:** continuation context for an F2P mobile prototype being designed/built iteratively. Read this to pick up where we left off (in a new session, with another assistant, or to brief a teammate).
**Date of handoff:** 2026-06-03
**Working dir:** `D:\ClaudeProject\`

---

## 1. The Goal (in one line)

Put **Agrivore's fun gameplay** (active harvest + crop synergies + skill tree) into a **working prototype that uses a market‑verified mobile F2P structure** (the Survivor.io / Archero "discrete runs + permanent meta" pattern = **Model C**).

It is NOT a clone of any one game. It's: *Agrivore-style run* wrapped in a *proven mobile F2P shell*, themed as harvesting (re: the cutting verb), inspired also by *Keep Watering* (the watering analogue).

---

## 2. Reference games — VERIFIED facts (with citations)

We repeatedly web-verified these (the user owns ground truth where noted; do NOT invent mechanics).

### Agrivore: Incremental Farming  (the primary gameplay reference)
- Steam app **4045540**, dev **verty**, publisher Rogue Duck Interactive / Gamersky Games, **released 2026-04-27**, **paid PC** (~$7), ~72% positive / ~370 reviews. v1.1.0 "King's Mood Update". **PC, NOT a shipped mobile F2P** → validates *appeal*, not mobile monetization.
- **Run length: ~12 seconds** (per user, who has played it).
- **Core verb:** mouse/pointer **hover → weapon auto-fires** ("your weapon does the rest"). Real-time, "waves of crops".
- **Crops are player-SELECTED build choices** (loadout), NOT random; harvested as auto-spawning waves. You start a run with **1 crop / 1 weapon / 1 skill**; higher "farms" raise slot capacity.
- **Skill tree is PER-RUN (resets each run!).** You earn **Crowns** (in-run soft currency) by harvesting and spend them on the run's skill tree. Completing the tree banks **red diamonds** (the META currency, persistent), scaling with farm tier. (Two currencies: Crowns = in-run, red diamonds = meta.)
- **Crops have HP** (red HP bars) and are damaged by DPS (damage numbers like "5"). **Ripe/"gold" crops STAY until harvested** (don't wilt). Crops "spawn" rather than grow through long stages.
- **Synergies** (the "wow"): cutting specific crops triggers effects — **garlic → bats orbiting you (contact damage, NOT lasers)**; **mushroom → start round with gold crops**; **potato generator → zapping**; **laser is a separate weapon**. Combos of crop × weapon × skill ("hyper combos").
- **Skill-tree nodes are small incremental, some repeatable (e.g. 0/3):** e.g. "on harvest start spawn 1 damage spot dealing 8 DPS" (Sunburn Spots), "+1 Sunburn Spot", "+0.85 Sunburn DPS (0/3)", "+0.23% Garlic spawn chance (2/3)". **Crop spawn-chance is itself an upgradable node.**
- **Grass:** the field is a packed grid of **grass that is ALSO reactive** — you can cut it and it respawns; lots of it; wheat/crops spawn among it.
- "Feed the King" = framing/goal. King's Mood = mid-run system that shifts tastes if you over-focus one strategy (forces build variety).

### Keep Watering  (the watering analogue)
- Frozen Logic Studios, Steam app **4569670** / itch.io, **unreleased prototype** (~mid-2026), cozy incremental. **Run length: ~20 seconds** (per user).
- Loop "Water → Harvest → Upgrade → Repeat"; permanent upgrades; automation arc (automate the action away); single soft currency; prestige planned. (Zero commercial signal — design reference only.)

### Mobile F2P structure proof (for Model C)
- **Survivor.io** (Habby, 2022, ~$500M lifetime IAP est.) and **Archero** (~$263M est.) — the two highest-grossing mobile games with our exact active, one-thumb, screen-clearing verb — are **Model C**: discrete roguelite runs + **permanent meta-progression** + monetization (chapter bundles, season pass, growth fund, heavy rewarded ads). (Sources: Naavik hybridcasual deep-dive; Sensor Tower via trade press — estimates, not independently confirmed.)
- Benchmarks to design against: D1 35–45% / D7 ~20% / D30 ~10%; ARPDAU $0.15–0.50 blended; ~40–50% IAP / 50–60% ads; session 2–4 min × 5–10/day (idle).

---

## 3. Design decisions locked so far

- **Model C** (runs + permanent meta) is the agreed backbone. Active harvest run = the session; permanent progression = retention/monetization engine. (A dedicated systems analysis recommended this; see reasoning in chat history.)
- **Run length: 10 seconds** (Keep Watering ~20s, Agrivore ~12s; we went shorter for a tighter loop). Short, repeatable.
- **Core input:** **tap = one 360° scythe swing** (a deliberate divergence from Agrivore's hover-auto-fire — the user prefers the active click). Move cursor/finger to aim. The scythe is a spinning blade that deals damage on the swing.
- **Crops do NOT grow** through stages — they **spawn ready-to-harvest** with HP. Board is fresh each run.
- **Grass** = dense reactive filler (lots, cuttable, 0 coins, 1 hit, respawns). **Wheat & specials** = sparser, valuable, with a gold glow.
- **Coins per crop kind:** wheat **1**, potato **3**, garlic **5**, mushroom **8**, grass **0** (× location mult × upgrades).
- **HP / DPS harvest:** ripe crops have HP (wheat 3 = "3 hits"), damaged by scythe (1/hit, 0.18s per-crop cooldown) + agents; HP bar + damage numbers.
- **Currency = coins.** Harvesting gives coins. Coins are spent on the **permanent skill tree** AND accumulate into **King Tier = the "level"** (lifetime coins). ONE persistent coin pool for both (no Agrivore-style per-run tree/second currency — decided Model A; see §6.1).
- **ALL progression is PERMANENT and lives in the skill tree** ("deep, far, expensive" per user). **NO in-run power-ups / on-field bonus orbs** (the user explicitly rejected those — an earlier on-field-pickup attempt was removed). Per-run only resets the board.
- **Spawn chance per crop is upgradable in the skill tree** (leveling a crop's node raises its spawn weight + its effect; spawn-chance and effect are combined per crop, vs Agrivore's separate nodes — simplification).
- **Synergies** (verified, re-themed): 🧄 garlic → orbiting blades (contact damage); 🥔 potato → ground zapper; 🍄 mushroom → ripens/clears an area; 🔥 Sunburn = a sun **zone** that burns crops in its radius (AoE, start-active from the tree).
- **Skill tree** = a **connected-node tree** in **4 vertical branches** (⚔️ Scythe / 🌾 Crops / 🤖 Agents / 🪙 Economy), scrollable, ~21 nodes.
- **Harvest Summary** screen after each run (CROP | CUT | COIN table + EARNED + King + Balance), styled after Agrivore's, with **SKILL TREE** + **HARVEST!** buttons.
- **Mobile structure:** Home screen with bottom nav (🌾 Farm / ⬆️ Upgrades / 🗺️ Map), currencies in a top bar, big **PLAY** button bottom-center on Farm. **Locations** (fields) gated by King Tier with a Food multiplier. King Tier shown as the level.

---

## 4. Current prototype state

**File:** `D:\ClaudeProject\prototypes\v2\index.html` — single self-contained HTML/JS (canvas + DOM), no build step, mobile-portrait. Open in a browser; tap to play.

**The loop:** PLAY → **10s run** on a fresh board → harvest crops for coins → **Harvest Summary** banks coins (→ spendable balance for the skill tree + King Tier level) → **HARVEST!** (again) / **SKILL TREE**. Upgrades are PERMANENT. **✕ quit mid-run forfeits that run's coins** (banked only at run end); permanent stuff (balance, tree, tier) untouched.

**What works now (v2):**
- Home (Farm) top-bar currencies (👑 King Tier · 🪙 Coins), bottom nav (Farm/Upgrades/Map), central PLAY, ✕ quit-run button.
- 10s run: spinning scythe (tap=swing, Double-Swing/Whirlwind can add swings), dense reactive **grass** + sparse glowing **wheat/specials**.
- HP/DPS harvest (HP bars + damage numbers, crit); per-kind coins; grass = 0-coin quiet puff. Golden crops (×5).
- **Skill tree (~21 nodes, 4 connected branches, scrollable):**
  - ⚔️ Scythe: Heavy Steel(+dmg), Bigger Blade(+reach), Quick Spin(+swing speed), Double Swing(chance ×2), Whirlwind(auto-swing), Critical Harvest(crit %), Deep Cut(crit ×mult).
  - 🌾 Crops: Wheat Seeds, Crop Density(+field), Tender Crops(−HP), Fertile Soil(+special spawn), Golden Crop(×5), Garlic, Potato, Mushroom.
  - 🤖 Agents: Sunburn Spot(+zones), Sunburn Power(+DPS), Solar Flare(+radius), Sharp Blades(+orbiter dmg).
  - 🪙 Economy: Sharper Cuts(+coins/crop), King's Tithe(+coins all).
- Synergies: garlic orbiters (contact), potato zappers, mushroom area-ripen, sunburn sun-zones (AoE).
- King Tier (level) from lifetime coins; **Locations** (Carrot Patch → … → Cosmic Farm) gated by tier, Food ×mult + background tint.
- **Harvest Summary**; **Reset account** (under the tree on Upgrades tab); instrumentation + CSV export (press `D`).

**Current tuning (in `CONFIG` / data near top of `<script>`):**
- RUN_LEN 10; CROP_R 13; BLADE_R 50; `curMaxField = 110 + 15×lv(density)`; spawn 0.07s × 2 crops; spacing CROP_R*1.7.
- Crop weights: grass 70, wheat `12 + 8×lv(seeds)`, specials `lv(node)×6 ×(1+0.25×lv(fertile))`.
- HP: grass 1, wheat 3, potato 6, garlic 10, mushroom 16 (× golden 2 × `(1−0.12×lv(ripen))`). Scythe dmg `1 + lv(steel)`, crit chance `8%×lv(crit)` → `×(3+lv(critpow))`. SCYTHE per-crop hit cooldown 0.18s.
- Coins: grass 0, wheat 1, potato 3, garlic 5, mushroom 8, × `(1 + 0.20×lv(power) + 0.15×lv(tithe))` × location mult × (golden ×5).
- Upgrade cost `base*7*1.65^level` (bases 2–5 → "deep & expensive"). KING_BASE 60, ×1.5/tier.
- Sunburn: zone radius `58 + 12×lv(sunrad)`, DPS `8 + 0.85×lv(sundps)`, relocates every 3s. Garlic orbiters cap 3.

**Controls:** tap/click = swing scythe (aim by moving). ✕ (top-right, in-run) = quit→Home (forfeit run coins). `D` = data panel + CSV. Reset account under the skill tree.

---

## 5. Other files in `D:\ClaudeProject\`

- `harvest-kingdom-concept.md` — the earlier full F2P concept doc (pre-pivot; some of it is superseded by the verified Agrivore model above, but the economy curves / monetization / retention sections are still useful reference).
- `harvest-kingdom-p1-prototype-plan.md` — original P1 "core-feel gate" test plan (the very first prototype was `prototypes/v1/` — a different, survivor-like reticle test; **v2 is the current line**).
- `agrivore-design-doc.md` — original v0.1 working doc (source material).
- `prototypes/v1/` — abandoned first prototype (offset-reticle survivor-like core-feel test). Ignore for current work.
- `prototypes/v2/index.html` — **the live prototype.**
- `mix-it/` — unrelated folder that pre-existed; do not touch.

---

## 6. Open questions / known divergences / TODO

1. **Run-progression model — DECIDED: Model A (permanent-only).** All progression is PERMANENT and lives in the skill tree (deep + expensive). **NO in-run power-ups / on-field pickups** — the user tried them and rejected them ("everything in skills"); an on-field-pickup version was built then fully removed. NO resetting in-run tree, no second currency, no pausing drafts. Per-run = fresh board only; the run's coins bank at run end and are **forfeited if you quit mid-run (✕)**. King Tier = level from lifetime coins. This is the verified mobile shape (Survivor.io/Archero permanent-meta spine). *Possible future loss-model tweak: quit could refund a fraction instead of 0 — user may revisit.*
2. **Input:** tap=swing (divergence; Agrivore is hover-auto-fire). User chose this deliberately. Whirlwind skill adds auto-swing.
3. **Balance is rough** — HP/DPS, coin rate, upgrade costs, spawn density hand-tuned through play; NOT yet run through the economy specialist for this model. Last passes: grass dense (field 110), wheat base weight 12, smaller plants (CROP_R 13), run 10s, pricier upgrades (×7, ^1.65). Ongoing feedback loop.
4. **Skill backlog (from the brainstorm agent — ~60 ideas, ~21 implemented).** The remaining ones are mini-features to add one at a time, NOT one-line nodes:
   - New crops w/ fx: 🍅 Tomato (splatter), 🎃 Pumpkin (mini-boss + coin burst), 🌽 Corn (clusters), ❄️ Frostberry (freeze grass regrow), 🌶️ Chili (feeds Sunburn).
   - New agents: 🐕 Herding Dog, 🚜 Mini Tractor (lane mow), 🦅 Crop Hawk, 🐝 Pollinator, Agent Cap+1.
   - Signature hooks: ★ **Combo / Multiplier Chain** (uninterrupted harvests build x2→x5, decays if you stop — top pick to deepen the 10s run), ★ **Boss Crop** (giant HP-bar crop = jackpot), alt weapons (boomerang / war sickle / plasma mower), Field Events (Golden Hour, Overgrowth), Daily Decree.
   - Retention/meta: Offline Harvest, First-Run-of-Day bonus, Prestige ("New Harvest" + Royal Seals). (Full list is recoverable from chat history / re-run the brainstorm.)
5. **Not yet built (Model A meta/monetization shell):** offline/idle accrual + welcome-back, monetization (ads/IAP/permanent-x2/pass), LiveOps, King's Mood variety system. The "permanent meta + monetization" half still to come.
6. **Process note:** the user strongly prefers **verified facts over invention** — when referencing Agrivore/Keep Watering, web-verify or ask the user; never make up mechanics/numbers/run-lengths. Several corrections happened because of unverified guesses (e.g. Agrivore is PC-paid not mobile F2P; KW has 20s runs; Agrivore ~12s — all user/web-confirmed).

---

## 7. How to continue

- Open `prototypes/v2/index.html` in a browser to playtest; iterate by editing the `CONFIG`/data blocks and the relevant functions.
- The build is one file; key systems: `CONFIG`, `CROP_KINDS` + `kindWeight`/`pickKind`, `spawnCrop`, `damage`/`harvestCrop`/`triggerFx`, `update` (scythe swing + agents/orbiters/zappers/sunspots), `drawCrop`, `UP` (skill list, each has `cat`) + `renderTree` (`TREE_CATS`, `COLX` — 4-branch layout), `lv`/`upCost`/`buyUpgrade`, `LOCATIONS`, `endRun` (Harvest Summary + coin banking), `king` state (`fed`=lifetime→tier, `crowns`=spendable, `up`=skill levels) + `tierInfo`.
- Skill effects are wired inline in the relevant systems (e.g. `steel`/`crit`/`critpow` in the scythe-hit line, `whirl` auto-swing + `spin` in the swing block, `golden`/`ripen`/`fertile` in `spawnCrop`/`kindWeight`, `tithe`/`power` in `curFoodMult`, `density` in `curMaxField`, `sunrad`/`sundps`/`orbdmg` in the agents block).
- Immediate next likely steps: keep tuning feel (grass/wheat ratio, coin rate, costs); then start the Model‑C meta shell (offline earnings + welcome-back, then monetization vectors) per the systems analysis.
