# Designer Review — RACCOIN F2P stack

Date: 2026-05-15

## Framing

Archetype: **Roguelite Runner** (Archero/Balatro shape).
Plugin: **Coin-pusher core verb** (RACCOIN donor).
Meta borrowings: **Coin Master / Monopoly Go** (energy + collection + season).

Structural read:
- Roguelite Runner archetype usually carries 1 soft + 1 hard currency, 1 progression track. This stack carries Coin Master-tier meta density (6 currencies, 8 tracks, sticker album, battle pass, seasons).
- Plugin verb (coin-pusher) attracts **Thrill Seeker + Treasure Hunter**; archetype meta (stake mastery, chip optimization) attracts **Skill Master + Thinker**. Audiences only overlap on Treasure Hunter.

## ⚠️ Risks

- 🔴 **R1 [pillar/audience]** — Plugin audience (Thrill Seeker, luck-dopamine) and archetype audience (Skill Master, run-optimization) only partially overlap. The vision says "lucky scavenger" but R3 meta is built for chip-synergy optimizers.
  - 🛡️ Pick a side at soft launch. (a) Lean Thrill: collapse stakes to 3, simplify chips to 30-40, push album + biomes harder. (b) Lean Skill: keep stakes/chips, make plugin reward read-the-board (aim-swipe non-optional).
- 🔴 **R2 [meta/scope]** — Coin Master / Monopoly Go-tier density on a prototype timeline. 6 currencies, 8 tracks, 48 mastery nodes (6×8), 60-100 chips, 486 stickers (6×9×9), 50-tier pass, 4 biomes, 60-80 codex. Archero/Balatro/Survivor.io ship ~1/3 of this at launch.
  - 🛡️ Cut soft-launch to: 3 chars, 3 stakes each, 30 chips, 2 biomes, 1 album (3×6×6), 25-tier pass, 4 currencies.
- 🔴 **R3 [monetization/store policy]** — Coin-pusher + casino-coded theme + RV revive is a known three-flag combination (Apple 4.7/5.3, NL/BE loot-box-adjacent regs).
  - 🛡️ Pre-clear via TestFlight build Q1. Have **Pirate Cove fully art-ready, not just A/B-planned**. Neutralize "jackpot" language in store metadata.
- 🟡 **R4 [currency bloat]** — 6 currencies, 2 likely redundant. Drop Charges + Run Tickets = two energy gates. Tokens + Gold = two soft currencies with unclear Tokens function.
  - 🛡️ Drop Tokens (fold into Gold-earned-during-run, banks on floor clear). Rename Drop Charges to a physical noun so HUD never says "energy" twice.
- 🟡 **R5 [loop-meta misalignment]** — 5 floors × 120s = 24s/floor. Coin-pusher physics needs 8-15s settle per drop sequence. Either floors are 3-4 drops (very arcadey) or runs stretch to 180-240s (breaks target).
  - 🛡️ Prototype physics first; lock floor count after settle-time measurement. Be ready to move to 4×30s or 3×40s.
- 🟡 **R6 [energy calibration]** — 5 tickets × 120s = 10 min/bucket; 25min regen = 2h 5min to full. That's Coin Master session shape (2-3 sessions/day), not Archero shape (one 15-20 min sitting).
  - 🛡️ A/B the cap (5 vs 8) and regen (25 vs 18 min) in soft launch. RV ticket gifts more abundant D1-D7; gate tightens post-D14.
- 🟡 **R7 [texture/pillar]** — Cheeky-forgiving + RV revive may undercut run-end cadence that roguelites need to retain.
  - 🛡️ Cap revives: 1/run, 2/day, non-boss only. First free via RV, second costs gems.
- 🟢 **R8 [scope]** — Album 10wk vs Season 8wk = deliberate de-sync but 40-week LCM, two-cadence live-ops overhead.
  - 🛡️ Align both to 8wk (simpler) or accept the cost knowingly.
- 🟢 **R9 [donor fidelity]** — Async friend ghost-runs aren't in donor or archetype references; unclear retention return on luck-heavy verb.
  - 🛡️ Cut from soft launch. Revisit if leaderboard data shows demand.

## 💡 Recommendations (impact-ordered)

1. **Pick the primary motivation lane before soft launch.** Thrill Seeker / Treasure Hunter OR Skill Master / Thinker. Highest-impact call in the stack.
2. **Cut soft-launch scope ~60%.** 3 chars / 3 stakes / 30 chips / 2 biomes / 1 album / 25-tier pass / 4 currencies.
3. **Pre-clear store policy in Q1.** Pirate Cove theme art-ready, not A/B-planned.
4. **Drop Tokens; rename Drop Charges.** 6 → 5 currencies; HUD avoids dual "energy" reading.
5. **Lock per-floor run shape after physics prototyping.** 5 × 24s may not survive settle-time.
6. **Constrain RV revive: 1/run, 2/day, non-boss only.** Preserves run-end cadence.
7. **Cut async ghost runs from soft launch.** Backend cost, unclear return.

## 🧾 Verdict

🔄 **REVISE Round 5** — explicitly resolve R1 (audience lane) and R2 (scope realism) before further work. Currently a Coin Master meta strapped to a Balatro archetype strapped to a Coin Dozer plugin, three not pulling in the same direction on motivation or production cost.
