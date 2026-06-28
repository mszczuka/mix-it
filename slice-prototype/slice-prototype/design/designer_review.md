# Designer review (Mode B)

Date: 2026-06-26
Verdict: ACCEPT (design coherent + pillar-aligned) — scope prototype to MINIMAL SLICE, not full meta.

## Risks

- 🔴 [loop] Over-scoping: 5 progression tracks at once proves none well, burns budget on UI plumbing.
  - 🛡️ Minimal pillar slice = tap-to-slice + combo + coins + ONE blade upgrade + knife-wear + offline + first prestige. Decorations / ingredient breadth / automation = phase-2.
- 🔴 [pillar] Pillar lives/dies on slice juice; HTML/Canvas ASMR is the hardest, least-certain build. If flat, no meta rescues it.
  - 🛡️ Build slice-feel vertical slice FIRST in isolation (one ingredient, one knife, full juice). Get to "I want to keep tapping" before wiring meta. If unprovable → REVISE concept.
- 🟡 [loop] Active-tap vs offline-idle gap unproven at prototype scale; may feel pointless or mandatory.
  - 🛡️ Expose offline-rate + active-multiplier as live-tweakable constants; feel the gap.
- 🟡 [meta] First-prestige timing = genre #1 churn trap, untested. Needs to be demonstrable in minutes.
  - 🛡️ Debug fast-forward / add-coins control so prestige reachable in one sitting, separate from prod pacing.
- 🟡 [meta] Knife-wear can read as punishment (Idle Slice & Dice anti-pattern) vs cozy.
  - 🛡️ Gentle visible meter + satisfying sharpen beat; shallow throttle. Nudge, never frustrate.
- 🟢 [meta] Monetization correctly off prototype critical path.
  - 🛡️ Stub one "watch ad → 2x offline" placeholder; no real ad/IAP flow.
- 🟢 [texture] Number formatting / growth feedback cheap + high pillar payoff.
  - 🛡️ Abbreviated notation (1.2K/3.4M) + milestone screen-flash from day one.
- 🟢 [loop] One-thumb portrait low-risk in HTML but easy to violate with hover/drag.
  - 🛡️ Single-tap targets, portrait viewport, test at phone aspect ratio.

## Recommendations (HTML prototype slice)
- Build order: (1) slice-feel isolation (one ingredient/knife, full juice, coins-per-slice) (2) combo on perfect-timing taps (3) knife-wear meter + sharpen (4) offline + welcome-back payout (5) first prestige (Master Knives global mult). Stop there.
- Cut from prototype: decorations, full ingredient tree, automation managers, daily/weekly/seasonal, real ads/IAP, season pass.
- Live-tweakable constants: coins-per-slice, combo mult, offline rate, offline cap, active-vs-idle ratio, wear rate, prestige threshold.
- Debug controls: +coins, +time (fast-forward offline), reset/prestige.
- Monetization: single "2x offline (ad)" stub.
- Success bar: a stranger taps 60s unprompted and reaches first prestige feeling numbers grow. If juice fails this → REVISE Round 1.

## Verdict
ACCEPT — no round needs design revision; risk is purely build-scope. Prove slice juice + active-tapper-idle spine + first prestige first.
