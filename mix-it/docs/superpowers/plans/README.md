# Mix-It Unity Port — Plans Index

**Spec:** [`../specs/2026-04-24-unity-port-archetype-plugin-design.md`](../specs/2026-04-24-unity-port-archetype-plugin-design.md)
**Target Unity project:** `D:\Projects\mix-it\MixIt` (Unity 6.3, URP 17.3)

---

## Cadence

Each phase gets its own plan file, **written just-in-time when the prior phase completes**. Writing detailed TDD steps for Phase 4 screens before Phase 0 compiles would lock decisions against a repo state that does not yet exist and would go stale before execution. Instead: finish phase N, re-run `/superpowers:writing-plans` against the spec + current repo state to produce the plan for phase N+1.

## Phases

| # | Name | Plan file | Status |
|---|---|---|---|
| 0 | Infrastructure skeleton | [2026-04-24-phase-0-infrastructure-skeleton.md](2026-04-24-phase-0-infrastructure-skeleton.md) | Ready to execute |
| 1 | Vertical slice (stub plugin, one-currency loop) | _write after Phase 0_ | Pending |
| 2 | Liquid Puzzles plugin to v7.5 fidelity | _write after Phase 1_ | Pending |
| 3 | Archetype meta services (parallelizable, 5 sub-plans) | _write after Phase 2_ | Pending |
| 4 | Archetype panels UI (parallelizable, 16 sub-plans) | _write after Phase 3_ | Pending |
| 5 | v7.5 polish + FTUE + flash offers | _write after Phase 4_ | Pending |
| 6 | Promote `_Archetype` to UPM package | _write after Phase 5_ | Pending |

## How to execute a plan in a fresh session

Fresh Claude Code sessions pick up a plan with this prompt:

> Read `d:/ProjectsClaude/mix-it/mix-it/docs/superpowers/specs/2026-04-24-unity-port-archetype-plugin-design.md` for design context, then execute `d:/ProjectsClaude/mix-it/mix-it/docs/superpowers/plans/<plan-file>.md` using the `superpowers:executing-plans` skill. Unity project lives at `D:\Projects\mix-it\MixIt`.

## Phase 3 sub-plan units (when the time comes)

- 3a. Wallet + Rating + Matchmaking
- 3b. BattlePass + TrophyRoad
- 3c. Venue + Albums
- 3d. Shop + FlashOffers
- 3e. FTUE + Analytics

## Phase 4 sub-plan units (when the time comes)

TopMenuPanel and BottomMenuPanel land first, then remaining panels can parallelize:
TopMenuPanel, BottomMenuPanel, LoadingPanel, HomePanel, MatchmakingPanel, LoadoutPanel, ResultPanel, ShopPanel, TrophyRoadPanel, BarPassPanel, VenuePanel, AlbumsPanel, TeamsPanel, RankingPanel, VipPanel, ProfilePanel.

## Unity-specific testing notes (applies to every plan)

- **Pure C# logic → EditMode tests** (`Tests/EditMode/`, Unity Test Framework). Fast, runnable headless via `Unity -batchmode -runTests -testPlatform EditMode`.
- **Scene/panel/prefab behavior → PlayMode tests** (`Tests/PlayMode/`). Slower but still headless.
- **Manual verification steps** exist where Unity Editor operations can't reliably be scripted (initial scene creation, prefab hierarchies, Inspector wiring). Each plan marks these `**[manual in Editor]**` vs `**[file edit]**`.
- **Commit after each task**, even if the task mixes file edits and manual Editor steps.
