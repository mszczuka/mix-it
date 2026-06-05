# Harvest Kingdom — P1 Prototype Plan ("Core Feel Gate")

**Version:** 1.0 | **Date:** 2026-06-03 | **Parent doc:** `harvest-kingdom-concept.md`
**Target:** HTML prototype (to be built via `prototype:gs-prototype-wizard`)
**Duration estimate:** small — single field, single loop, instrumented A/B

---

## 0. Why P1 Exists (the one question)

P1 answers **one** question and refuses to build anything not needed to answer it:

> **Is a ~90-second active harvest run — reticle harvest + zone watering + crop-spoilage tension + a 1-of-3 upgrade draft — satisfying enough that the player wants another run? And does crop-spoilage tension beat a no-tension "screensaver" loop?**

Everything else in the concept (economy depth, prestige, monetization, LiveOps, automated back-fields, 25 fields, 100 nodes) is **explicitly out of scope** for P1. Building those before this gate passes is the #1 waste risk. If P1 fails, we pivot the core verb or the tension model — we do not proceed to the economy build.

This is the falsification gate from the concept doc §15, made executable.

---

## 1. The Central A/B Test

P1 is not a single prototype — it is **two variants of the same loop**, toggleable, so we can measure whether tension matters.

| Variant | Description | Tests |
|---|---|---|
| **A — No-fail screensaver** | Crops spawn, sit indefinitely at full value, auto-harvested when reticle is near. No spoilage, no elite despawn, no objective miss. Pure "drag finger, numbers go up." | The Keep Watering / Agrivore-default hypothesis: is cozy-passive enough? |
| **B — Spoilage tension** | Crops ripen → peak → overripe → rot (value decays to 0). Elites spawn with despawn windows. One per-run objective with a real miss condition. Combo-Heat meter. | The concept's core bet: does opportunity-cost pressure create "one more run"? |

**Both variants share:** the reticle harvest verb, zone watering booster, the 1-of-3 upgrade draft, the Feast summary, and identical art/feedback. The ONLY difference is the tension layer. This isolates the variable.

**Decision rule after P1:**
- B clearly beats A on "one more run" intent + run-2/run-3 engagement → **proceed**, spoilage is the tension model, build economy.
- A ≈ B (tension adds nothing) → the no-fail cozy direction is viable but we have a *different* game (lean harder idle/automation, reconsider the survivor-like UA promise).
- Both weak → the reticle harvest verb itself is the problem → pivot the core verb before anything else.

---

## 2. Scope — What P1 Builds

### In scope (minimum to answer the question)
- **1 field** (Carrot Patch), single continuous biome, readable on a phone-sized viewport.
- **3–4 crop types** with distinct silhouettes + ripeness color states (planted/sprout/ripe/overripe/rot must read at a glance).
- **1 input model: offset reticle** (finger below, tool auto-attacks in radius) + **zone watering** (tap-hold to accelerate growth in an area).
- **3 weapons/tools** with genuinely different feel (e.g. arc-scythe / piercing seed-cannon / AoE fertilizer-cloud) — enough to make the upgrade draft meaningful.
- **~12 run upgrades** weighted toward Behavior/Combo/Tradeoff, minimal pure-additive (test build divergence early).
- **1-of-3 upgrade draft** on level-up, ~6–10 level-ups per run.
- **Combo-Heat meter** (variant B): climbs on chained ripe harvests, decays on idle, speeds next level-up + temp Food mult.
- **~90s run** with the 4 phases (Setup/Growth/Overgrowth/Feast) — Overgrowth is where spoilage pressure peaks in variant B.
- **Feast summary screen**: total Food, best combo, crops harvested, Food/sec, "play again" CTA.
- **Variant toggle** (A/B) — config flag, ideally hot-swappable for playtest sessions.
- **Instrumentation** (see §4) — the prototype is worthless without it.

### Explicitly OUT of scope for P1
- Economy curves, currencies beyond a single run-Food counter, King feeding, field tiers, prestige.
- Automated back-fields / idle / offline income (the fusion mechanic — validated later).
- Gear collection, rarity, shards, skill tree, chests.
- Monetization, ads, IAP, store, pass.
- LiveOps, daily orders, events, push, login.
- Multiple fields, crop families, bosses, art polish beyond readability.
- Meta-progression of any kind — **each P1 run starts from zero.** (Meta is P2.)

> Discipline note: if a feature isn't needed to judge "is the run fun + does tension matter", it does not go in P1.

---

## 3. Success Criteria (the gate)

P1 **passes** only if it hits the feel bar AND the tension bar. Use a small qual playtest (5–10 testers, think-aloud) + the quant signals in §4.

### Feel bar (both variants must clear the floor)
1. **Input comprehension without explanation** — testers understand "move reticle, crops get harvested, water to grow faster" within ~15s, no tutorial text.
2. **Harvest feels satisfying** — testers describe the moment-to-moment as juicy/satisfying unprompted (crop-clear feedback, chains).
3. **Readability on phone** — crop density + ripeness states are legible at phone size; testers can tell ripe from overripe at a glance.
4. **"One more run" pull** — after a run ends, testers voluntarily tap "play again" at least once without prompting.

### Tension bar (the A/B decision)
5. **Variant B > Variant A** on the primary metric (run-2 start rate / sessions-per-tester) by a meaningful margin in playtest.
6. **Build divergence** — across testers, run-upgrade picks are not all converging on one option (no upgrade >40% pick-rate when offered).
7. **Spoilage reads as engaging, not annoying** — testers describe rot pressure as "I need to keep moving / prioritize" (good) rather than "frustrating / punishing" (bad). This is a qual judgment call — capture verbatim quotes.

### Fail signals (any of these = do not proceed as-is)
- Testers park the finger and watch (screensaver confirmed) in **both** variants.
- "Boring after 3 runs" — the explicit falsification condition.
- Spoilage causes rage/confusion rather than prioritization.
- Builds converge to one dominant pick by run 3.

---

## 4. Instrumentation (events to log)

The prototype must emit these from run 1. Even in an HTML prototype, log to console/localStorage/CSV — without data, P1 cannot answer its question.

**Session / loop:**
- `run_started` { variant: A|B, run_index }
- `run_completed` { variant, run_index, duration_s }
- `run_replayed` { variant, prev_run_index } ← **primary "one more run" signal**
- `session_ended` { variant, total_runs, total_time_s }

**Moment-to-moment (the feel/tension signals):**
- `crop_harvested` { ripeness_state: ripe|overripe, crop_type }
- `crop_rotted` { crop_type } ← variant B only; high rot count = player not keeping up / tension too high
- `elite_spawned` / `elite_harvested` / `elite_despawned` ← variant B; despawn count = missed opportunity
- `combo_chain` { length } ← engagement-with-clusters proxy
- `combo_heat_peak` { value } ← variant B
- `reticle_idle_time_s` { per_run } ← **screensaver detector**: high idle time = passive play
- `water_zone_used` { count } ← is the 2nd verb actually used?

**Upgrade draft (build divergence):**
- `upgrade_offered` { options: [id,id,id] }
- `upgrade_picked` { id, type: additive|behavior|combo|tradeoff }
  → compute pick-rate per upgrade (convergence alarm >40%)

**Objective (variant B):**
- `objective_assigned` { id }
- `objective_succeeded` / `objective_missed`

**Derived metrics to report:**
- Runs per tester (A vs B), run-2 start rate (A vs B) ← **the headline comparison**
- Median reticle-idle-time per run (A vs B) ← screensaver check
- Upgrade pick-rate distribution ← divergence check
- Rot rate & elite-despawn rate (B) ← tension calibration
- Water-verb usage rate ← is the 2nd verb earning its place?

---

## 5. Build Notes for the HTML Prototype

To hand to `prototype:gs-prototype-wizard`:

- **Viewport:** phone-portrait first (e.g. 9:16), touch-style input (mouse = touch for desktop testing). Reticle offset above the pointer.
- **Tunable config block** (expose these as constants for live tuning in playtest):
  - crop growth timings (sprout/ripe/overripe/rot durations), spawn density, spawn rate
  - tool params per weapon (power, interval, range, target count, chain count)
  - level-up XP curve (how fast the 1-of-3 draft arrives), combo-heat gain/decay
  - elite spawn chance + despawn window
  - run length, phase boundaries
  - **`VARIANT` flag (A|B)** and granular sub-toggles (spoilage on/off, elites on/off, objective on/off, combo-heat on/off) so we can bisect *which* tension element matters
- **Feedback first:** crop-clear pop, chain sparkle, satisfying harvest SFX/VFX even in the prototype — feel is the thing being tested, so flat placeholder feedback would invalidate the test.
- **No backend** — single-player, local. Instrumentation to localStorage + an "export CSV" button for playtest data collection.
- **Start-from-zero each run** — no meta. A run is a clean ~90s slice.

---

## 6. What Happens After P1 (gates into P2)

- **Pass** → P2 "Incremental Economy": add Food/Crowns/Seeds, King tiers, the per-tier power grant (§7.2 of concept — the math fix), 5 fields, ~20 nodes, the **automated back-field fusion** (1st→2nd field transition), offline mock. Validate: 2nd/3rd run feel stronger, big numbers exciting, automation return-hook works.
- **Conditional pass** (A≈B) → re-spec toward cozy-idle; revisit the survivor-like UA promise and the no-fail framing.
- **Fail** → pivot the core verb (reticle may not be the right harvest input on touch) before any further build.

---

## 7. P1 Checklist (for the wizard handoff)

- [ ] 1 field, 3–4 crops with legible ripeness states
- [ ] Offset reticle harvest + tap-hold zone watering
- [ ] 3 distinct weapons
- [ ] ~12 run upgrades (behavior/combo/tradeoff-weighted), 1-of-3 draft
- [ ] Combo-Heat meter (variant B)
- [ ] Crop spoilage + elite despawn + 1 objective (variant B); none of these (variant A)
- [ ] ~90s run, 4 phases, Feast summary + "play again"
- [ ] VARIANT A|B flag + granular sub-toggles
- [ ] Full instrumentation (§4) + CSV export
- [ ] Phone-portrait viewport, touch input
- [ ] Tunable config constants block
- [ ] NO meta, NO economy, NO monetization
