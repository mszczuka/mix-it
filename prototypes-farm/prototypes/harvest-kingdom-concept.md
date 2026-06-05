# Harvest Kingdom — F2P Mobile Design Concept

**Version:** 1.0 | **Date:** 2026-06-03 | **Status:** unified concept for prototyping
**Genre:** Active Incremental Farming Idle (idle-first economy + survivor-lite active harvest)
**Platforms:** iOS / Android | **Engine target:** Unity (HTML prototype first)

---

## 0. Provenance & How To Read This Doc

This concept is a synthesis of two reference games plus a four-lane specialist analysis (market, economy, systems/monetization, content/levels). It supersedes the earlier "Agrivore Mobile: Feed the King" working doc (v0.1) — that doc's open questions are **resolved** here, and its identified risks are **fixed** with concrete numbers.

**Reference games (verified, 2026-06-03):**
- *Agrivore: Incremental Farming* — Steam app 4045540, dev **verty**, released 2026-04-27, **paid PC**, ~371 reviews / 71% positive. Provides the **active half** (survivor-lite hover-harvest verb that stays engaging) and a roguelite run frame. NOTE: validates *appeal at niche scale*, NOT F2P mobile monetization. Even on PC it patched a flat base loop ("King's Mood Update" — variable King tastes to force build variety).
- *Keep Watering* — Frozen Logic Studios, Steam app 4569670 / itch.io, **unreleased browser prototype**, free, ~2 ratings. Provides the **idle half** (named loop "Water→Harvest→Upgrade→Repeat", automation-as-reward, irrigation-tier escalation, cozy "one more upgrade"). NOTE: **zero commercial signal** — design reference only.

**Genre commercial proof** comes from the shipped hybrid-casual leaders (Habby: Survivor.io, Archero 2, Capybara Go — the active-core + idle-meta + rewarded-ads template). For *garden-idle mobile monetization* proof specifically, do a separate teardown of Terrarium: Garden Idle and Window Garden (verified mobile F2P, not yet analyzed).

---

## 1. The Core Insight (the fusion)

The two reference games answer the central design question — *"what does the player actually DO moment-to-moment?"* — **oppositely**, and each pays a price for it:

| | Active verb | Tension | Price paid |
|---|---|---|---|
| Agrivore | survivor-lite aiming — **stays engaging** | none (no death by default) | screensaver-risk; flat loop |
| Keep Watering | watering — **automated away by design** | none (cozy) | active verb self-deletes; thin session pull |

**Our fusion — the one idea neither game has:**

> **Automation does not delete active play — it moves active play to the frontier.**
> Old, cleared fields **automate themselves** (idle / offline income — Keep Watering's DNA). You actively play **only the newest field — the frontier** (survivor-lite harvest — Agrivore's DNA). Automation is the **reward that pushes you forward**, not the off-switch for fun.

This resolves both failure modes at once:
- The active verb **never self-deletes** — there is always a fresh frontier field to play.
- The idle layer has a **real return-hook** — the automated back-fields accrue offline Food while you're away.
- It gives a clean, screenshot-able power fantasy: *your kingdom of farms grows behind you, humming on autopilot, while you push the edge.*

Tension is supplied not by death but by **crop spoilage** (opportunity-cost pressure — see §4).

---

## 2. Pitch & Pillars

**One-line:** An active incremental farming idle where you sweep a magical harvester across living fields — watering and reaping crops before they rot — building absurd gear-combos to feed an ever-hungrier King, while your conquered fields automate behind you into an endless food empire.

**Core pillars:**
1. **One-finger harvest with depth** — simple reticle input, but *where* you point is a constantly-renewing decision.
2. **Crops rot** — moment-to-moment tension from opportunity-cost, not from a death screen.
3. **Active frontier, automated back-fields** — the fusion. Active play stays fresh; idle income stays meaningful.
4. **Feed the King** — central economy sink + comic emotional anchor with variable demands.
5. **Idle-first retention, active-first creatives** — systemically an idle game; in UA, a satisfying "clear-the-field" hook.

**Player promise:** "I always come back stronger / I can always harvest more / the numbers grow absurdly but I understand it / my build does something spectacular / my empire runs itself while I sleep."

---

## 3. Target Audience

- **Primary:** idle/incremental optimizers (big numbers, prestige theorycraft); Survivor.io-likes who want auto-combat *without* hard survival; casual short-session players.
- **Secondary:** cozy/farming fans; build-crafters; collectors.
- **Dual-genre risk (critical):** the audience self-selects for *either* action *or* idle. UA creatives (action-first) skew installs toward the action cohort, who are then handed an idle economy. **Mitigation:** lead FTUE with the action feel; deliver the first offline-claim within session 1 to convert action-installers into idle-retainers. Instrument the action-vs-idle preference split as the #1 soft-launch learning.

---

## 4. Moment-to-Moment — the Active Verb WITH Tension

Two active verbs, layered for depth (this is what keeps it off the screensaver):

### Verb 1 — Harvest (the spine)
Offset reticle: the player's finger sits *below* the reticle (finger doesn't cover target). The equipped tool **auto-attacks crops within radius**. Skill = **target priority**: which cluster/elite to point at *now*.

### Verb 2 — Water (the booster)
Tap-and-hold a zone to **accelerate crop growth** there, creating a burst window of ripe crops to sweep. Adds a timing/positioning decision on top of harvest.

### The tension engine — crops grow and ROT
Every crop runs a real-time growth timer:

```
planted → sprout → RIPE (peak value) → overripe (value decays) → ROT (value = 0, slot wasted)
```

- Harvesting a RIPE crop = full Food. Overripe = partial. Rotted = nothing + occupies a spawn slot.
- **Not pointing optimally costs you Food.** Same loss-aversion psychology as death in survivor-likes — but no fail screen, and it fits the farming fiction perfectly (crops literally spoil).
- **Elites** spawn with a telegraphed window and **despawn** if not harvested — a second opportunity-cost layer.
- **Chains** only fire when you sweep dense ripe clusters — rewards active sweeping over parking the finger.

### Live performance read
A visible **Combo-Heat meter** climbs as you chain ripe harvests and **decays** when you idle. High heat = the next run-upgrade choice arrives sooner (faster level-up cadence) + a temporary Food multiplier. This makes good play *visibly* rewarding second-to-second, replacing the legible-score function that survival pressure normally provides.

### Run structure (90–150s)
| Phase | Time | Feel |
|---|---|---|
| Setup | 0–30s | low density, collect, first upgrade choice, build starts |
| Growth | 30–90s | density up, first chains/AoE, elites appear, snowball begins |
| Overgrowth | 90–130s | high density, ripening accelerates, **rot pressure peaks**, build peaks |
| Feast | end | Food → King; summary (total Food, best combo, Food/sec, Crown gain, next King tier); rewarded-ad offer (x2 Food / bonus chest) |

### Fail state
**No hard death in default mode** — the run ends on timer. Tension comes from spoilage + elite windows + at least **one per-run objective with a real miss condition** (you lose the *bonus*, never the run). Optional hard-fail modes exist as side content (Boss Crop, Infested Field, Endless Overgrowth leaderboard).

> **This is the single make-or-break design bet.** P1 must A/B "pure no-fail" vs "no-death + spoilage/objective pressure" and measure 'one more run' intent. Do not assume the no-death default works — earn it with data.

---

## 5. The Fusion Mechanic — Active Frontier + Automated Back-Fields

This is the structural heart of the concept and the thing neither reference game has.

- You progress through **field tiers** (Carrot Patch → Cornfield → Pumpkin Grounds → Crystal Vineyard → Royal Overgrowth → Cosmic Farm → …).
- The **frontier field** = the highest field you've unlocked. This is the *only* field you actively play. All active harvest runs happen here.
- When you unlock a new field (via a King tier reward), the **previous field becomes automated**: it gains an irrigation tier (watering can → sprinkler → drone → rainfall → tractor — stolen from Keep Watering) and produces **idle / offline Food** at a rate set by its tier and irrigation level.
- **Idle income = sum of all automated back-fields.** Offline accrual is the return-hook. Time-warp IAP and rewarded-ad "instant offline claim" monetize this directly.

**Why this works:**
- Active play is *always* on fresh content (no screensaver, no self-deleting verb).
- Idle income scales naturally with progression (more conquered fields = more passive Food).
- Automation upgrades (irrigation tiers) are a deep, monetizable, screenshot-able progression vertical.
- It maps the "relaxing cozy automation" fantasy onto the idle layer while keeping the "active juicy harvest" fantasy on the frontier — serving *both* audience cohorts in one loop.

---

## 6. Progression Spine — King Tier is the Master Clock

Resolves the earlier doc's "five parallel axes, no arbitration" problem. **King tier is the explicit pacing spine.** Every other axis is expressed as "by King tier N, the player should have ~X".

| Axis | Gated by | Relationship to spine |
|---|---|---|
| **King tier** | Food (+ specific crops) | **THE SPINE** — master sink & pacing clock |
| Field tier (frontier) | King tier reward | ~1 new field per King tier; previous field auto-fies |
| Crop families | King / Seeds | per field |
| Gear rarity | Gear Shards (elites/chests) | continuous drip, target "by King tier N have rarity R" |
| Skill tree (Crowns) | Crowns (runs/milestones) | continuous, target "by King tier N have ~K nodes" |
| Prestige | unlocked at King tier ~6 | endless scaling layer (see §7.4) |

**King-tier cost curve** (steeper than field income, so feeding always lags production → King stays a meaningful sink):

```
KingCost(tier) = 100 · 10^((tier-1)/2)
```

| King tier | Food cost | Special demand | Reward |
|---|---|---|---|
| 1 | 100 | — | tutorial gear |
| 2 | 1K | — | 2nd field (Cornfield); 1st field auto-fies |
| 3 | 31.6K | +200 Carrots | new crop family; **soft wall #1** |
| 4 | 1M | +500 Corn | new gear slot; 3rd field |
| 5 | 31.6M | +1 Boss Pumpkin | global multiplier |
| 6 | 1B | — | **unlocks Prestige (Ascension Feast)** |

**Soft wall #1** lands at King tier ~3 / field 3, ~2–3h cumulative play, cleared by a gear upgrade + tree node + ~10–15 runs OR an ad-boost shortcut. This is an *economic* wall (grind/pay until your number is big enough), not a skill wall — own that honestly; it's where idle games sell boosts.

---

## 7. Economy — Working Model (drop-in numbers for P2 spreadsheet)

All values are starting designs to be tuned in playtest. Derived from the doc's own formula intentions + idle-genre conventions, with the math holes fixed.

### 7.1 Currencies
- **Food** — main production; feeds King; scales K/M/B/T/aa+. (Note: field tiers alone only reach ~10⁸ — the astronomical numbers come from **prestige**, see §7.4.)
- **Crowns** — meta currency (runs, King milestones, objectives); spent in skill tree; controlled supply.
- **Seeds** — crop/field upgrades, crop families, soil modifiers.
- **Gear Shards** — upgrade equipment; drop from elites/chests/events.
- **Gems** (premium) — IAP + slow earn; chests, cosmetics, pass, convenience, rerolls.

### 7.2 Core curves & constants
```
baseFood   = 10      // Food per crop at tier 0
baseHP     = 10      // crop HP at tier 0  (HP:Food ratio = 1.00, constant forever)
baseCost   = 50      // first upgrade ~5 crops
N          = 150-250 // crops per run

FoodValue(t) = baseFood · 10^(t/3)     // ×2.154 per field tier, ×10 every 3 tiers
CropHP(t)    = baseHP   · 10^(t/3)
```

**THE CRITICAL FIX — the power curve (absent in v0.1, the reason "5s harvest" was fiction):**
```
// Unlocking field tier t grants a baseline harvest-power step:
BaseHarvestPower(t) = basePower · 10^(t/3)   // ×2.154 per field unlock
```
This makes **seconds-to-harvest a true invariant** (≈5.0s at every tier with baseline gear) instead of a hand-waved assertion. Gear / combo / prestige then layer *on top* to create the broken-build bursts (faster clears, bigger numbers) WITHOUT breaking the baseline. Alternative implementation: gate field-tier *unlock* behind a power threshold. Pick one — do not ship without it.

### 7.3 Upgrade cost bands
```
UpgradeCost(level) = baseCost · growthRate^level
```
| Band | Levels | growthRate | Cadence |
|---|---|---|---|
| Early | 1–15 | **1.30** | affordable every 1–3 runs (dopamine-rich) |
| Mid | 16–35 | **1.60** | every few runs (specialization) |
| Late | 36+ | **2.05** | drives the prestige decision |

### 7.4 Prestige — "Ascension Feast" (the endless-scaling engine)
Field tiers cap the headline numbers at ~10⁸; **prestige is what delivers the K/M/B/T/aa promise.** Resource it as a first-class system, not a stub.

```
AscensionCrowns(reset)  = floor( 10 · (LifetimeFoodThisCycle / 1e6)^0.5 )
GlobalFoodMultiplier    = 1 + 0.02 · AscensionCrownsSpentOnMult   // additive in points → never explodes
```
| Lifetime Food this cycle | Ascension Crowns |
|---|---|
| 1M | 10 |
| 100M | 100 |
| 1B | 316 |
| 1T | 10,000 |
| 1 quadrillion | 316,228 |

- **First prestige target: ~1M lifetime Food ≈ 2–3h cumulative play (D1–D2).** NOT D7 — a 7-day delay to the genre's signature hook is a churn trap. Surface a *preview* in session 1; deliver the real (small) first prestige within the first few play-hours.
- **Reset:** part of field progress + King tiers + some gear levels. **Keep:** account level, gear collection, cosmetics, purchases, Ascension Crowns, selected branches.
- **Steady cadence:** 1–3 prestiges/week.
- **Each prestige layer must change the FEEL, not just rescale** (e.g. Layer 2 = auto-harvest of frontier converting active→idle faster; crop mutations; new gear slot; new tree layer).

### 7.5 Multiplier discipline — 3 registers + 1 capped Boost
v0.1 claimed "2–3 multiplicative axes" but actually had ≥5, enabling a ~×4,320 burst stack ("economy explodes"). **Enforce in code, not prose:**

| Register | Contents | Cap |
|---|---|---|
| `TierScalar` | field / King / world tier | none (it's the spine) |
| `BuildPower` | gear + run combo + within-run upgrades, **summed then multiplied once** | soft-cap ×25 / run |
| `MetaMultiplier` | **merged** prestige global + mutations (single value) | none (the endless axis) |
| `Boost` | event + daily + ad, **additive into one bucket** | hard cap **+200% (×3)** |

Merge the two prestige globals (skill-tree "Prestige Growth" + §7.4 global) into one `MetaMultiplier` to avoid squaring. Event/Daily/Ad must be additive, never their own multiplicative chain.

### 7.6 Run payout & offline
```
RunFood = (Σ cropFoodValue · ripenessFactor) · BuildPower · MetaMultiplier · Boost
IdleFood/sec = Σ over automated back-fields ( fieldOutput(tier) · irrigationMult )
```
**Offline:** floor **20% of active efficiency**, cap **4h at launch** (→ 8–12h via Starter Pack / prestige / ad-boost). Offline gives Food + Seeds + a **small capped Crown trickle** (5% of active rate, daily cap) so idle players still inch up the tree without making active irrelevant (active stays ~5–20× best for Crowns/Shards). Sanity: 8h@20% = 1.6 active-hours (inside genre norm).

---

## 8. Gear, Skill Tree, Run Upgrades

### 8.1 Gear (build variety source)
Slots: Main Tool (scythe/sickle/mower/wand/seed cannon), Offhand (fertilizer bag/raven charm/watering orb), Trinket (crown ring/soil amulet/harvest bell), Boots/Gloves (reticle speed, pickup radius), Relic (run-defining passive). Rarity Common→Mythic. Props: harvest power, attack interval, range, target count, chain count, crop-family bonus, combo tag, special proc. Earnable via gameplay + chest accelerator + pity; **no P2W**.

### 8.2 Skill tree (spends Crowns)
Categories: Harvest Power, Crop Value, Combo Engine, King Economy, **Idle Production** (offline Food, auto-harvest back-fields), Prestige Growth. Early = obvious power/low load; mid = specialization; late = multiplicative identity (folded into `MetaMultiplier`, capped). Recommended-node highlight + affordable-pinned to fight overwhelm.

### 8.3 Run upgrades (1-of-3 on level-up)
Types: Additive / Behavior / Combo / Tradeoff. **Build divergence rules:**
- Combo upgrades are build-defining and **compete for slots** (corn-explode vs chain vs DoT can't all coexist).
- Tradeoff upgrades create genuine forks (+100% value/+50% HP gates itself behind burst).
- **Gear sets the build seed** — make "rare upgrades need build conditions" central, not rare.
- **Pool size:** 12 for P1 validation; **30–40 minimum for any retention test (P2+)**; 50+ at scale. Replayability lives in the upgrade pool, not the field count. Expand the pool *before* field count.
- **Convergence alarm:** if any upgrade has >40% pick-rate when offered, it's a balance bug.

---

## 9. Monetization (no-P2W, but fully built for the genre)

v0.1 built the monetization of a *clean idle game* with the *UA hook of a survivor-like* — the low-revenue half of each. Fixed:

- **Ads = the floor** (40–55% of revenue): x2 Food after run, instant offline-claim / x2 offline, bonus chest, free reroll (post-D2 only), extra daily King Order. Target 1–3 opt-ins/session, ~4–8/day. Fully completable ad-free, just slower.
- **IAP = the ceiling** — add the genre-defining vectors v0.1 was missing:
  - **Permanent ×2 Food** (the #1 idle IAP; the "buy forever" version of the x2 ad).
  - **Time-Warp** (skip offline hours — uniquely natural here because the automated back-fields *are* a time-bank).
  - **Subscription / VIP** (daily Gems + offline boost + QoL — recurring revenue, serves the whale tier).
  - **Starter Pack** (legendary beginner tool, Gems, no-ad tickets, cosmetic, offline-cap boost — low price).
  - **Harvest / Season Pass** (free + premium track, 3–5 wk).
- **Cosmetics = a CORE revenue pillar, not garnish** — deep, visible King-outfit / tool-skin / field-theme catalog (visual content can be the majority of IAP in this space).
- **Chests:** gear earnable via play, chests accelerate, dupes→shards, **pity** on high rarity, no core progression locked behind paid gacha only.

**Cut unless deliberately built:** "speed-up for timed upgrades" ad — the economy has no hard timers; adding them just to sell speed-ups imports strategy-game friction that contradicts the relaxing pillar.

---

## 10. LiveOps & Retention

**P0 (cheap, genre-standard, was missing in v0.1):**
- **Push / local notifications** (back-fields full, offline cap reached, King hungry) — the #1 idle return-trigger.
- **Daily login calendar + streak** — loss-aversion habit loop.
- **First prestige by D1–D2** (preview in session 1) — not D7.

**LiveOps cadence:**
- Daily: King Orders + Daily Field Bonus.
- Weekly: Mutated Field (mutators) + Tournament (soft brackets, aspirational cosmetics + non-power flex like titles/frames; keep power out).
- Monthly: a **challenge event** (event currency → milestone track → event shop, 1–2 wk) — fills the D7–D14 content sag.
- Seasonal Pass (3–5 wk, themed: Pumpkin Feast / Winter Greenhouse / Royal Cornival / Cosmic Harvest).
- Later: lightweight async social (Guild Boss Crop / shared harvest milestone), comeback reward, achievements.

**Retention targets (idle benchmarks):** D1 35–45%, D7 15–22%, D30 6–12%. ARPDAU $0.04 good / $0.10+ great; IAP conversion 1.5% good / 3%+ great.

**Churn cliffs to instrument:** FTUE comprehension drop; soft wall #1 (D2–3); prestige *comprehension* (generous welcome-back-to-power moment); mid-game grind plateau (fill with events).

---

## 11. UX, Art, Audio (essentials)

- **HUD (in run):** run timer, Food this run, Combo-Heat meter, upgrade progress, King objective, equipped tool, ≤1 active-ability button. Compact number notation (K/M/B/T/aa); animate magnitude; show deltas. Avoid >15 currencies on screen.
- **Frontier vs Empire view:** active run = frontier field; a separate "Kingdom" map view shows automated back-fields humming (the idle dopamine + offline-claim surface).
- **Art:** colorful, slightly absurd, medieval-fantasy farming; gluttonous comic King; playful (not gross) crop "violence". Visual hierarchy: reticle > ripe clusters > combo VFX > drops > timer. Ripeness must read at a glance (color/silhouette state). Avoid full-screen VFX noise mid-game.
- **Audio:** crop pops, chain sparkle, scythe swipes, King chewing/burping/demanding, escalating Overgrowth music, feast jingle. Avoid harsh repetition (idle sessions run long).

---

## 12. Content Plan

- **MVP (core-feel gate — cut hard):** 2 fields, 3–4 crops, 6 gear, ~20 skill nodes, **30–40 run upgrades**, 1 King track, 1 prestige layer, basic ads, daily orders, the automation/back-field mechanic for the 1st→2nd field transition. *Do not build 60 nodes / 5 fields before the core validates.*
- **Soft launch:** 10–15 fields, 8 crops, 25–35 gear, 100+ nodes, 50+ upgrades, 2 prestige layers, events, pass, store, push + login, analytics + A/B.
- **Global:** 25+ fields (≈6 mechanical templates × reskins/param-scales), 12+ crops, 50+ gear, deep prestige, seasonal LiveOps, **procedural/parameterized field generation** as the long-tail treadmill (a source-game tag worth honoring), social layer.

---

## 13. Resolved Open Questions (vs v0.1)

| Question | Decision |
|---|---|
| Reticle / character / tap-hold? | **Offset reticle (harvest) + tap-hold zone (water)** — two verbs for depth |
| Run ends via timer / depletion / fullness? | **Timer + spoilage/overgrowth limit** |
| No-death? | **No-death default, BUT with spoilage opportunity-cost** — not pure no-fail (validate in P1) |
| How fast do huge numbers appear? | Field tiers to ~10⁸; the rest from **prestige, first one D1–D2** |
| Gear random / crafted / linear? | Earnable + chest accelerator + pity, no-P2W |
| King = sink or active buffs? | **Sink + variable demands** (changing tastes force build variety — Agrivore's own fix) |
| Active ability? | **Yes, ≥1** (one button is too thin for tension; 1–2 with cooldowns) |
| Events challenge vs idle-milestone? | **Both** — daily/weekly + monthly challenge event with currency |

---

## 14. Top Risks (carried from analysis)

1. **Red ocean** — Habby owns the active-core hybrid with elite UA. Moat must be execution + the "Feed the King" charm/IP + the frontier/automation fusion + creative pipeline, NOT the mechanic (skinnable).
2. **No-death tension unproven** — the #1 design bet; validate spoilage-pressure in P1 before building economy.
3. **Dual-genre install mismatch** — action UA → idle core; convert via fast first offline-claim; instrument the preference split.
4. **Economy explosion** — solved on paper by §7.5 buckets; verify in P2 sim.
5. **Anchor games prove appeal, not mobile F2P monetization** — get real monetization proof from Terrarium / Window Garden teardown.

---

## 15. Falsification Hypothesis (the bet)

**Hypothesis:** A 90-second active harvest with reticle + watering + crop-spoilage tension + run upgrades + King feeding is satisfying enough to make the player want another run for bigger numbers — and the "automated back-fields" fusion keeps active play fresh while giving idle a real return-hook.

**Falsified if:** harvest input boring after 3 runs; players ignore King progression; big numbers feel meaningless; spoilage pressure annoys rather than engages; the no-fail variant performs as well as the spoilage variant (tension adds nothing); ads only work on hard gates.

**Next gate:** after P1, decide axis — more action / more idle / stay hybrid (per the action-vs-idle preference signal).
