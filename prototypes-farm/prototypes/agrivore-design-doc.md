# Agrivore Mobile F2P — Working Design Doc

**Version:** 0.1 EN | **Date:** 2026-06-03 | **Status:** working document for iteration

## 1. Executive Summary

The public description of *Agrivore: Incremental Farming* points to an **incremental farming idle** game: the player equips magical farming gear, harvests waves of crops, unlocks new equipment, spends **Crowns** in a skill tree, and builds increasingly powerful hyper-combos to feed a hungry King.

For Mobile F2P, the strongest opportunity is a hybrid: **Idle-first economy + active harvest gameplay**. Working genre label: **Active Incremental Farming Idle**.

The game can *feel* like Survivor-lite harvest action (short sessions, auto-weapons, AoE, chains, screen full of crops, satisfaction of clearing a field). But systemically it should behave like an idle/incremental economy: numbers scale from thousands to millions, billions, trillions; content scaled through field tiers, crop tiers, King hunger tiers, gear progression, and prestige.

Key conclusion: allow huge numbers and strong visual snowballing, but control progression pace through tiering, time-to-upgrade, diminishing returns on stacked systems, and prestige.

## 2. Sources and Assumptions

- Steam page: https://store.steampowered.com/app/4045540/Agrivore_Incremental_Farming/
- Gameplay video: https://www.youtube.com/watch?v=u0E8ofsyi_g

Hard observations from Steam description: incremental farming idle; fantasy "Feed the King"; core action "swing, slash, or shoot through waves of crops"; PC input "hover over crops and your weapon does the rest"; meta = unlock farming gear; meta currency = Crowns; progression = skill tree, stronger every run, build perfect farming build. Tags: Incremental, Idler, Roguelite, Strategy, Roguelike, Loot, Arcade, Relaxing, Economy, Simulation, Collectathon, Farming, Procedural Generation, Casual.

Mobile assumptions: don't copy PC mouse-hover 1:1; need clarity, short sessions, clear reward moments; keep incremental fantasy (absurd numbers, power creep, faster clearing); F2P needs long-term meta, content cadence, safe rewarded-ad placements.

## 3. Core Design Problem

Three tensions: (1) Action vs idle; (2) Snowball vs endless economy; (3) Harvest fantasy vs F2P retention. Layered architecture: moment-to-moment active harvesting; session = short runs with local snowball; meta = gear/skill tree/King feeding/field unlocks; long-term = exponential economy/prestige/LiveOps/events.

## 4. Archetype Options

**A — Survivor-lite Harvest Action**: closer to Survivor.io/Vampire Survivors. Pros: strong UA hook, ad-friendly, broken-build moments, rewarded-ad placements. Cons: harder endless balance, may drift from idle DNA, more content production, risk of weaker Survivor-like. Risk: too much survival combat kills relaxing feel.

**B — Idle Tycoon / Pure Incremental**: numbers grow absurdly, farms produce offline, active harvest is a booster. Pros: easiest infinite progression, huge numbers natural, good LiveOps economy, accessible. Cons: loses uniqueness, too passive, generic UA creatives. Risk: "just another farm idle tycoon."

**C — Archero-adjacent Roguelite**: run-based rooms/fields, bosses, perk choices, energy entry, fail state. Pros: proven F2P, gear/rarity role, chapters/bosses, daily/weekly goals. Cons: less aligned (crops are resources not enemies), higher combat-balancing cost, loses incremental fantasy. Risk: skill-action game vs incremental promise.

**D — RECOMMENDED: Active Incremental Farming Idle**: idle/incremental economy, but moment-to-moment is active harvesting. Short juicy runs, local snowball; long-term on growing numbers, field tiers, King tiers, gear, skill tree, prestige. Pros: best DNA fit, mobile-friendly session, huge idle numbers without simulating billions of objects, F2P-natural. Cons: needs clear separation between visual snowball and economic payout, strong economy design, excellent small-screen UX. Risk: too passive core OR too chaotic economy.

## 5. Recommended Game Concept

Working title: **Agrivore Mobile: Feed the King** (alts: Harvest King, Endless Harvest, Crop Devourer, King's Harvest Idle).

Pitch: active incremental farming idle where player clears waves of crops in short harvest runs, builds absurd gear-combos, feeds the King with ever-growing food.

Core pillars: (1) One-finger harvest satisfaction; (2) Broken-but-controlled builds; (3) Endless numbers, readable sessions; (4) Feed the King as emotional sink; (5) Idle-first retention, active-first creatives.

## 6. Target Audience

Primary: idle/incremental/clicker players; big-numbers fans; casual short-session; Survivor.io-likes who enjoy auto-combat without hard survival. Secondary: farming/cozy fans; build-crafters; collectors. Promise: "I always come back stronger / can always harvest more / numbers grow absurdly but I understand it / my build does something spectacular."

## 7. Core Gameplay

### 7.1 Input models
1. **Offset reticle** (finger below reticle, weapons auto-activate in radius) — MVP recommendation.
2. **Drag harvester** (control physical harvester/scythe/character).
3. **Tap/hold zones** (hold areas, gear harvests inside) — weakest action feel.

### 7.2 Harvest interaction
Crop appears → move reticle over it → weapon auto-attacks in range → crop loses HP/harvest progress → harvested crop drops Food/XP/Seeds, sometimes Crowns/gear shards → combo effects transfer to nearby crops.

### 7.3 Run structure (90–180s)
- Phase 1 Setup (0–30s): low density, collect currency, first upgrade choice.
- Phase 2 Growth (30–90s): more crops, first chains/AoE, elite/bonus crops, snowball begins.
- Phase 3 Overgrowth (90–150s): high density, crop HP up, build peaks, final burst.
- Phase 4 Feast Summary: run ends, Food to King, see totals/best combo/Food per sec/Crown gain/progress to next King tier, rewarded-ad offer (double Food/bonus chest/extra Crowns).

### 7.4 Fail state
No hard death in default mode — run ends on timer/field harvested to limit; optional objective may fail but player always gains. Optional fail modes: Boss Crop Challenge, Infested Field, Timed King Order, Endless Overgrowth leaderboard.

## 8. Core Loops
- Second: control reticle → target crops → auto-harvest → collect drops → trigger chain → seek dense clusters.
- Minute: start run → collect XP/Food → choose run upgrade → increase efficiency → harvest elite/boss → feed King.
- Session: claim idle/offline → run → claim chest/ad bonus → upgrade gear/skill tree → feed King → unlock next field/King demand → run again/exit.
- Long-term: clear field tiers → unlock crop families → upgrade gear rarity → complete King hunger tiers → prestige/Ascend → unlock new permanent mechanic → repeat at higher scale.

## 9. Progression Systems

### 9.1 Currencies
- **Food**: main production, feeds King, scales K/M/B/T/aa/ab/ac.
- **Crowns**: meta currency from runs/King milestones/objectives, spent in skill tree, more controlled.
- **Seeds**: crop/field upgrade currency, unlock crop families & soil modifiers.
- **Gear Shards**: upgrade equipment, drop from elite crops/chests/events.
- **Gems** (premium): IAP + slow earn; extra chest, cosmetic, premium pass, convenience, limited rerolls.

### 9.2 King Feeding (central sink)
Each tier requires Food, sometimes specific crops. Example: T1=100 Food; T2=1K; T3=50K+200 Carrots; T4=2M+500 Corn; T5=100M+Boss Pumpkin. Rewards: new field, crop family, gear slot, global multiplier, run-upgrade type, prestige access.

### 9.3 Field Tiers
Each field: crop family, base crop HP, base Food value, spawn density, elite chance, special modifier, King demand. Progression: 1 Carrot Patch (tutorial), 2 Cornfield (chains), 3 Pumpkin Grounds (tough/AoE), 4 Crystal Vineyard (shields/status), 5 Royal Overgrowth (mixed waves), 6 Cosmic Farm (prestige/absurd).

### 9.4 Gear
Slots: Main Tool (scythe/sickle/mower/wand/seed cannon), Offhand (fertilizer bag/raven charm/watering orb), Trinket (crown ring/soil amulet/harvest bell), Boots/Gloves (movement/reticle speed/pickup radius), Relic (run-defining passive). Rarity: Common→Mythic. Properties: base harvest power, attack interval, range, target count, chain count, crop family bonus, combo tag, special proc. Examples: Royal Scythe (arc, bounce every 5th), Seed Cannon (piercing lines), Fertilizer Cloud (AoE DoT, higher value), Raven Harvester (auto-pick low-HP, passive/offline build).

### 9.5 Skill Tree (spends Crowns)
Categories: Harvest Power, Crop Value, Combo Engine, King Economy, Idle Production, Prestige Growth. Principle: early = obvious power/low load; mid = specialization; late = multiplicative identity but capped.

## 10. Run Upgrades
Types: Additive (+10% power, +15% carrot Food, +1 radius); Behavior (scythe bounces, seed pierces +1, fertilizer follows reticle); Combo (corn 10% explode, chain +Food 3s, every 20 crops King Bite); Tradeoff (+100% value/+50% HP, +50% speed/−20% range, +3 chain/less power each). Choice: 1-of-3 on level-up, reroll via soft currency/ticket/ad, rare upgrades need build conditions. Rule: feel broken but contained inside run; long-term controlled via gear/tree/prestige.

## 11. Snowballing and Endless Scaling
Main rule: visual snowball aggressive, economic snowball scaled through tiers. Currency scale K/M/B/T/aa/ab/ac, use idle abbreviations. Balance through time-to-harvest not absolute DPS: seconds to harvest a crop at current tier, runs per upgrade, upgrades per field unlock, feeds per King tier, days to prestige. Example: Field 1 crop 10HP/2DPS = 5s; Field 10 crop 10B HP/2B DPS = 5s.

What can multiply: at most 2–3 axes truly multiplicative simultaneously — (1) Field/King/World tier, (2) Gear rarity/level, (3) Temporary run combo. Everything else additive/softcapped/separate buckets. Dangerous stack: attack speed × area × chain × crit × crop value × respawn × event × offline × ad.

Softcaps (thematic): Soil Exhaustion (value grows slower over time), King Fullness (overflow to bonus chest), Crop Toughness (need synergies), Season Shift (crop properties change), Overgrowth Limit (max density, further boosts increase quality not count).

Prestige ("Ascension Feast"): reset part of field progress/King tiers/some gear levels; keep account level, gear collection, cosmetics, purchases, permanent prestige currency, selected branches. Rewards: global Food multiplier, crop mutations, new gear slot, auto-harvest earlier fields, new skill tree layer.

## 12. Economy — Working Model

### 12.1 Resource flow
Harvest Run → Food → King Feeding → King Tiers → Field Unlocks; → Crowns → Skill Tree → Permanent Power; → Seeds → Crop/Field Upgrades → Higher Output; → Gear Shards → Equipment Levels → Build Power; → Chests → Gear/Shards/Gems/Cosmetics.

### 12.2 Food curve
`FoodValue(fieldTier) = baseFood * 10^(fieldTier/3)`; `CropHP(fieldTier) = baseHP * 10^(fieldTier/3)`. Keeps time-to-harvest roughly stable if player power scales similarly.

### 12.3 Upgrade costs
`UpgradeCost(level) = baseCost * growthRate^level`. Growth rates: early 1.25–1.45, mid 1.5–1.8, late 2.0+.

### 12.4 Run payout
`RunFood = sum(cropFoodValue * cropMultiplier) * runMultiplier * eventMultiplier`. Controls: cropFoodValue by tier; runMultiplier temporary; eventMultiplier capped; ad multiplier usually x2 on specific buckets; prestige multiplier = main long-term axis.

### 12.5 Offline income
Base offline 10–30% of active efficiency; cap 2–8h at launch, expandable; offline mainly Food/Seeds, rarely Crowns; active best for Crowns/gear shards.

### 12.6 Ads economy
Safe placements: x2 Food after run, bonus chest, free reroll, instant offline claim boost, extra daily King Order, revive/extend in challenge modes, speed-up for timed upgrades. Avoid: ad every minute required, ads blocking core upgrades, unlimited chains, P2W PvP pressure.

## 13. Monetization
Pillars: rewarded ads (main), No Ads IAP, Starter Pack, Harvest/Season Pass, gear chests/shard bundles (careful), cosmetics, event packs. Starter Pack: legendary beginner tool, Gems, no-ad tickets, cosmetic, 2h offline boost (low price). Harvest Pass free track (Food boosts/chests/Gems/shards) + premium (cosmetics/more chests/pass currency/non-mandatory gear variant). Gacha policy: gear earnable via gameplay, chests accelerate, dupes→shards, pity for high rarities, no core progression locked behind paid gacha only.

## 14. LiveOps
Daily: King Orders (harvest 500 carrots, feed 3x, finish with Seed Cannon, 20 chain explosions, 1 Boss Crop) → Crowns/Gems/Pass XP/keys/event currency; Daily Field Bonus (+50% Seeds/elite chance/special crop/King favorite). Weekly: Harvest Tournament (soft brackets, best Food/combo score/feed amount, mostly cosmetic rewards), Mutated Field (mutators). Seasonal: Harvest Season Pass 3–5 weeks (Pumpkin Feast/Winter Greenhouse/Royal Cornival/Cosmic Harvest) with new crop family, temp field, cosmetics, milestones, gear skin, King outfit.

## 15. Content Plan
MVP: 5 field tiers, 5 crop families, 8–12 gear, 40–60 skill nodes, 20 run upgrades, 1 King track, 1 prestige layer, basic ads, basic daily orders. Soft launch: 10–15 fields, 8 crops, 25–35 gear, 100+ nodes, 50+ upgrades, 2 prestige layers, events, pass, store, analytics/AB. Global: 25+ fields, 12+ crops, 50+ gear, deep prestige, seasonal LiveOps, more cosmetics, tournament variants.

## 16. UX and Controls
HUD: run timer, Food this run, Crown progress, upgrade progress, King objective, equipped tool, optional 1 active ability. Avoid too many currencies/tiny labels/full tree in loop/small targets. End-run: total Food, best combo, crops harvested, Food/sec, records, King feeding animation, next upgrade recommendation, ad option. Skill tree: zoomable/tabbed, recommended highlight, affordable pinned, presets later, effect comparison. Big numbers: compact notation, animate magnitude, show deltas, avoid 15 currencies.

## 17–18. Art & Audio
Tone: colorful, slightly absurd, medieval/fantasy farming, gluttonous comic King, playful crop violence. Visual hierarchy: reticle > crop clusters > combo VFX > drops > timer. VFX: each gear tier visually distinct, distinct combo VFX, avoid full-screen noise mid-game, light screen shake, strong crop-clear feedback. Audio: crop pops, chain sparkle, scythe swipes, King chewing/burping/demanding, escalating Overgrowth music, feast jingle.

## 19. Tutorial/FTUE
60s comprehension: move reticle over crops; weapon auto-harvests; crops give Food; Food feeds King; Crowns upgrade tree; next run stronger. Flow: King hungry → drag over carrots → auto-harvest → mini-combo → run ends fast → King eats/demands more → buy first node → 2nd run faster → first gear unlock → store/ads delayed.

## 20. Retention
D1: tutorial, 2nd field, first new gear, multiple King feeds, first big number jump, understand next-session value. D2–3: daily orders, first event/challenge, gear upgrade path, first meaningful build choice, first soft wall. D7: prestige preview/first prestige, several gear, favorite build, event/pass engagement, King milestones. D30: deeper prestige, chase gear/cosmetics, seasons/events, optimize builds.

## 21. Analytics & KPIs
Core questions: harvesting fun after 10 min? King feeding understood as objective? big numbers motivating or confusing? action-heavy vs idle-heavy preference? ads feel optional/valuable? prestige timing? skill tree exciting/overwhelming? Metrics: D1/D3/D7 retention, session length, runs/session, time-to-first-King-feed, time-to-first-gear, time-to-first-wall, ad impressions/DAU, ad opt-in, No Ads conversion, Starter Pack conversion, Pass conversion, ARPDAU, build diversity, upgrade pick rates.

## 22. Prototype Plan
P1 Core feel: 1 field, 3 crops, 1 reticle, 3 weapons, 10 upgrades, 2-min runs, simple end screen. Success: input understood without explanation, harvesting satisfying, "one more run", density readable on phone.
P2 Incremental economy: Food/Crowns/Seeds, King tiers, 5 fields, 20 nodes, basic gear, offline mock. Success: understand what to upgrade, 2nd/3rd run stronger, big numbers exciting.
P3 Monetization fit: x2 ad, reroll ad, bonus chest ad, no-ads placeholder, starter pack placeholder. Success: ads valuable, don't interrupt flow, one strong opt-in placement.
P4 Long-term loop: 1 prestige, 10+ fields, 20+ gear, daily orders, simple event. Success: prestige rewarding, reset value understood, economy survives multipliers.

## 23. Risks & Mitigations
R1 Too passive → run choices, elite crops, temp objectives, 1 active skill, target priority. R2 Too much action → keep no-death default, emphasize King/numbers/gear/tree. R3 Economy explodes → bucketed multipliers, softcaps, field tiers, controlled Crowns, prestige gates. R4 UI unreadable → larger silhouettes, compact notation, limited HUD, VFX priority, auto-pickups. R5 Predatory monetization → ads as accelerators, no hard gates, strong no-ads value. R6 Idle makes active irrelevant → offline good for Food/Seeds, active best for Crowns/shards/events. R7 Skill tree overwhelming → recommended upgrades, branches, simple early nodes, presets.

## 24. Open Questions
Reticle vs character vs tap/hold? Run ends via timer/depletion/fullness? How many in-run choices to avoid passivity? Crops have behaviors or only HP/value? Active ability button or pure one-finger? How fast huge numbers appear (5 min/30 min/Day 1)? How early preview prestige? Gear random/crafted/linear? King only sink or active buffs? Events challenge vs idle-milestone?

## 25. Recommendation
Option D (Active Incremental Farming Idle) with Option A as feel layer. Pure Idle Tycoon not recommended first (loses active differentiator); pure Archero/Survivor not recommended first (loses incremental DNA + expensive combat). Key question: is a 90s active harvest with reticle, auto-weapons, run upgrades, King feeding satisfying enough to want another run for bigger numbers? If yes → build idle economy + prestige. If no → shift to Survivor-lite or idle tycoon.

## Appendix A — Options Summary
A Survivor-lite (best gameplay/UA hook, hard endless balance, prototype the feel). B Idle Tycoon (best infinite scaling, generic feel, backup). C Archero roguelite (proven F2P, too far from Agrivore, low priority). D Active Incremental Farming Idle (best DNA+mobile fit, requires strong economy, RECOMMENDATION).

## Appendix E — MVP Hypothesis
A mobile F2P Agrivore should be idle/incremental-first, not action-first. Active harvest is the satisfying interaction that makes numbers feel earned; long-term retention from King feeding, gear, skill tree, field tiers, prestige. Falsified if: harvest boring after 3 runs; players ignore King; big numbers meaningless; ads only work on hard gates; action-heavy prototype performs significantly better. Next gate: after first playable, decide axis shift — more action/more idle/stay hybrid.
