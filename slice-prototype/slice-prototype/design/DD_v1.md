# Slice Tycoon Design Doc v1

Date: 2026-06-26
Status: ACCEPTED
Archetype: ActiveTapperIdle (NEW — see archetype_spec.md)

## 1. Pillars
- Satisfying knife mastery — hypnotic, anti-stress satisfaction per slice.
- Numbers always grow — visible, abbreviated, escalating payout feedback.
- Active matters — tapping is a permanent, combo-bearing, wear-gated verb, never fully automated away.

## 2. Player fantasy
The player feels like a satisfying knife master — the hypnotic, anti-stress satisfaction of a
perfect slice while the numbers grow with every cut. Over time a humble cutting board grows into a
thriving slicing empire, but the hand on the knife always matters.

## 3. Core loop (plugin)
- Input model: single tap on the served ingredient (one-thumb, portrait).
- Per-second verb: tap-to-slice; perfect-window timing feeds a decaying combo multiplier.
- Win: progression milestones (blade/ingredient upgrades) + first prestige.
- Lose: soft-fail — knife-wear throttles income until sharpen/upgrade. Never game-over.
- Session length: 2-5 min active check-ins, 5-8/day; offline accumulation between.

## 4. Meta loops (archetype: ActiveTapperIdle)
### 4.1 Currencies
- Coins (soft): per slice + offline → upgrades/unlocks.
- Gems (hard, STUB in prototype): permanent 2x, time-warp, auto-unlock, ad-removal.
- Master Knives (prestige): permanent global profit multiplier.
### 4.2 Progression tracks
- Blade upgrade (MVP), ingredient tiers (1 live + stubs), automation (stub), prestige layers (first only).
### 4.3 Retention cadence
- Daily/weekly/seasonal: designed, CUT from prototype (phase-2).
### 4.4 Social / competitive layer
- None. Single-player. Async leaderboards parked.

## 5. Economy curves
- coins/slice = base * bladeMult * comboMult * prestigeMult.
- upgrade cost = base * growth^level (~1.07-1.15).
- offline ~50-100% active rate, capped (8h ≈ 1-2h active).
- monetisation hooks: gems → permanent 2x / time-warp / auto-unlock / ad-removal (stubbed).
- All constants live-tweakable in the prototype debug console.

## 6. FTUE shape
- 3 forced beats: first slices → first blade upgrade → first wear+sharpen. First prestige = headline milestone.

## 7. Analytics events
- slice_made, upgrade_bought, wear_depleted, blade_sharpened, offline_claimed, prestige_done.

## 8. Mood / texture
- Cozy, calm, anti-stress; warm palette; cozy kitchen growing to dream kitchen.
- Juice: clean slice SFX, slow-mo perfect slice, particle/juice splatter, combo flourish,
  welcome-back payout, milestone screen-fill.
- Failure: soft-fail only.

## 9. Open questions
- Prestige depth (2-4 layers); what changes per layer beyond bigger numbers.
- Master Knives = pure multiplier or passive producer.
- Knife-wear granularity: per-blade vs global meter.
- Active-vs-idle ratio target (2-5x) — economy tuning.
- Combo depth vs casual accessibility.
- Rewarded-ad frequency ceiling vs cozy tone.
- Decoration bonus model (flat % vs set collection).
- First-prestige timing ≤ 2-4h in production pacing.

## 10. Feature table
| Layer | System | Source | Status | Notes |
|---|---|---|---|---|
| Archetype | Currency: Coins | designed | new (MVP) | soft, per-slice + offline |
| Archetype | Currency: Gems | designed | stub | UI placeholder only |
| Archetype | Currency: Master Knives | designed | new (MVP) | prestige, global multiplier |
| Archetype | Offline earnings (capped) | designed | new (MVP) | welcome-back payout |
| Archetype | Prestige / ascension | designed | new (MVP) | first prestige only |
| Archetype | Automation managers | designed | stub | visible-but-locked |
| Archetype | Daily/weekly/seasonal | designed | cut | phase-2 |
| Plugin | Core verb: tap-to-slice | designed | new (MVP) | tap + perfect-window combo |
| Plugin | Combo multiplier | designed | new (MVP) | timing-based, decays |
| Plugin | Blade upgrade (1 track) | designed | new (MVP) | +coins/slice, +wear resist |
| Plugin | Knife-wear + sharpen | designed | new (MVP) | soft-fail throttle |
| Plugin | Ingredient tiers | designed | stub | 1 live + stubs |
| Plugin | Kitchen decorations | designed | cut | phase-2 |
| Plugin | Number formatting + milestone flash | designed | new (MVP) | 1.2K/3.4M |
| Plugin | Debug/tuning console | tooling | new (MVP) | +coins, +time, reset, live constants |
| Plugin | "2x offline (ad)" stub | designed | stub | UX placeholder |

## 11. Reference games + delta
- Slice to Meet You: copy tap-slice, knife-wear, blade tree, decorations, cozy juice; drop premium model.
- AdVenture Capitalist: copy automation, angel/prestige, offline, exponential curve; drop pure-AFK.
- Idle Slice and Dice: documented anti-pattern (forced ads, sub-gated ad-removal) — avoid.

## 12. Risks (from designer review)
- 🔴 Over-scoping 5 tracks → scoped to MVP slice.
- 🔴 Slice juice is the make-or-break craft problem → build feel-first in isolation.
- 🟡 Active-vs-idle balance unproven → live-tweakable constants.
- 🟡 First-prestige timing → debug fast-forward.
- 🟡 Knife-wear may feel like punishment → gentle meter, shallow throttle.
