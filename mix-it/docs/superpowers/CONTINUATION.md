# Continuation Guide

Last updated: 2026-04-25 (post-Phase-5-layout — v7 HTML layout ported)
Resume the Unity port of Mix It prototype from any device.

## Repos

Two repos involved:
- **Docs + prototype:** `mix-it` (this one)
  - `docs/superpowers/specs/` — phase design docs
  - `docs/superpowers/plans/` — task-by-task implementation plans
  - `index-v7.html` + `design-v7.x-*.md` — HTML source of truth
- **Unity project:** `MixIt` (separate repo, typically `D:\Projects\mix-it\MixIt`)
  - `Assets/_Game/PHASE_*_DONE.md` — completion markers per phase

Both repos need to be cloned side by side.

## Environment

- Unity **6000.3.14f1** (Unity 6.3) — version pinned; manifest resolves git deps on first open
- Packages via `Packages/manifest.json`:
  - VContainer 1.16.9 (git)
  - UniTask 2.5.10 (git)
  - TextMeshPro, Input System (built-in)
  - unity-mcp + Newtonsoft.Json (for MCP agent usage)
- Internet required on first open (package git deps)
- `run-tests.bat` in MixIt root runs headless EditMode tests

## Current status (end of session 2026-04-24)

### Shipped
- **Phase 0** — infra skeleton (assemblies, DI, UIRouter, 16 panel placeholders)
- **Phase 1** — vertical slice (Home → MM → Match → Result loop, tap-button stub)
- **Phase 2** — Liquid Puzzles match (full bottle/serve/combo/AI gameplay, 90s timer, persona carousel)
- **Phase 3.1** — Rating + Matchmaking (8 arenas, trophy deltas, persona roster, SaveProfile JSON)
- **Phase 3.2** — Analytics event bus (in-memory buffer + Debug.Log, 2 emit points in FlowController)
- **Phase 3.3** — Coins + Boosters + Shop + FlashOffer (Gold→Coins rename, 9-item catalog, 4 flash triggers)
- **Phase 3.4** — TrophyRoad + BarPass + DailyMissions (25 milestones, 30 tiers, 3-daily rotation)
- **Phase 3.5** — Venue + Album + PackOpener (3 districts, 4 albums × 10 stickers, rarity-weighted rolls, sticker tokens)
- **Phase 3.6** — FTUE (v7.5 M1-M5 match progression, headless state machine, rewards per stage, M5 ×2 stake tutorial)
- **Phase 4** — UI surface (prefab infra + 7 sub-projects: HUD, TR, BP, Missions, Shop, Venue, Album, FTUE popups, Avatar frame, persistent HUD/BottomNav overlay)
- **Phase 5 layout port** — v7 HTML layout ported across all panels (HudBar/BottomNav/Home/TR/BP/Shop/Venue/Album/DM/MM/Result/StarterPack/StakeTeaser overlays). Solid colors + Image proxies; gradients/sprites/fonts deferred to polish.

### Test count
- **162 EditMode tests green** (verified 2026-04-24 end of Phase 3.6)
- 0 compile errors / warnings
- Play Mode smoke: Boot OK (last verified at 3.4)

### Deferred
- **Phase 4** — UI surface (panels for BP, TR, Shop, Missions, trophy/reward display)
- **Phase 5** — polish (audio, VFX, animation)
- **Phase 6** — launch (IAP, analytics backend, build pipelines)

## Architectural overview

```
MixIt.Archetype.Contracts    — pure interfaces + records (engine-optional)
MixIt.Archetype.Runtime      — services: UIRouter, WalletService/CoinService,
                               RatingService, MatchmakingService, AnalyticsService,
                               BoosterInventory/Shop, FlashOffer, TrophyRoad,
                               BarPass, DailyMission, Venue, Album, PackOpener,
                               Ftue, SaveProfile/JsonSaveStore,
                               DefaultMatchIntroPresenter, FlowController
MixIt.Archetype.UI           — panel MonoBehaviours (Home, MM, Match, Result, Loading)
MixIt.Plugin.LiquidPuzzles.Runtime  — Model/, Simulation/, Config/, Avatar/ (pure C# + UniTask + UGUI + TMP)
MixIt.Plugin.LiquidPuzzles.UI       — GlassView, QueueView, HudView, BoardView, MatchSession, Plugin factory
MixIt.Game                   — GameLifetimeScope (VContainer wiring)
```

### Boundary rule
Plugin asmdefs reference ONLY `MixIt.Archetype.Contracts` + `UniTask` + `Unity.ugui` + `Unity.TextMeshPro`.
Never reference `MixIt.Archetype.Runtime` or `MixIt.Archetype.UI`.

### Save profile schema
Single JSON blob in PlayerPrefs key `mixit.save.v1`. Schema: `SaveProfile.cs` at `Assets/_Archetype/Runtime/Persistence/`. Extended per phase; JsonUtility-compatible (no Dictionaries — use `List<Pair>`).

## Resuming work

### 1. Re-open project
- Clone both repos
- Open MixIt in Unity 6000.3.14f1
- Let packages resolve (~30s first time)
- Run `run-tests.bat` — expect 162 green

### 2. Context bootstrap for agent
Point agent at these files in order:
1. `docs/superpowers/CONTINUATION.md` (this file)
2. `docs/superpowers/specs/2026-04-24-unity-port-archetype-plugin-design.md` (root architecture)
3. `docs/superpowers/specs/2026-04-24-phase-3-decomposition.md` (Phase 3 sub-project map)
4. Latest `PHASE_*_DONE.md` in MixIt (`Assets/_Game/`)
5. `git log --oneline -30` in MixIt (recent commit flow)

### 3. Pick next phase

**Phase 4 complete.** Next: Phase 5 (polish: real art, VFX, animation, audio) + Phase 6 (launch: IAP, backend, build pipelines).

Phase 5 candidates:
- Replace placeholder colors with real sprite/frame art
- Lucky Box starter chest UI (currently 250c stub in FtueService)
- Solo puzzle scene for M1/M2 FTUE tutorials
- M5 stake tutorial overlay + result cascade animations
- Stake button UI on Matchmaking (×2/×3/×4)
- Juice/particle VFX for serves, combo, claims
- Audio: SFX + music

Phase 6 candidates: IAP Starter Pack, rewarded video placements, analytics backend, iOS/Android build pipelines, server-authoritative M5 rage-quit.

**Option B: Jump to Phase 4 (UI surface)**
Higher user-visible impact. Risk: meta systems not fully shipped.
Deferred items (3.5, 3.6) would need Phase 4 UI anyway; bundling reduces churn but widens scope.

Recommendation: finish Phase 3.5 + 3.6 first (each ~1 session). Then Phase 4 can cover all meta UIs in one sweep.

## Plan/spec conventions

- **Specs** describe design + acceptance (`YYYY-MM-DD-<topic>-design.md`)
- **Plans** are task-by-task execution (`YYYY-MM-DD-<topic>.md`) with checkbox steps
- Phase 3.1 has formal plan; Phase 3.2/3.3/3.4 specs alone proved sufficient (executed via inline agent prompts)
- If resuming with subagent-driven-development skill, the spec is enough input; the agent generates task breakdown on the fly

## Execution pattern that works

Subagent-driven development via `dev:gs-unity-dev` agent:
1. Extract mechanics from HTML via Explore agent (delegated read)
2. Write spec from extraction
3. Write plan from spec (optional for small subprojects)
4. Dispatch per-task subagent with exact spec content inline
5. Review output, commit atomically
6. Retrospective review agent at end of phase

## Key gotchas discovered

- `new GameObject("X")` has plain `Transform`; can't `AddComponent<RectTransform>`. Use `new GameObject("X", typeof(RectTransform))`.
- VContainer + multiple constructors → mark correct ctor with `[Inject]`.
- `record` types need `IsExternalInit.cs` polyfill (present in Contracts asmdef).
- JsonUtility can't serialize Dictionary — use `List<Pair>`.
- Meta files: commit folder `.meta` or `git add -A Assets/` to catch all.
- Plugin boundary: enforce via asmdef inspection, tests help catch accidents early.
- Input System: EventSystem must use `InputSystemUIInputModule`, not `StandaloneInputModule`.
- StandaloneInputModule + InputSystem = runtime exception, not compile error.

## Commit message conventions

Scoped: `feat(archetype):`, `feat(plugin):`, `feat(game):`, `refactor:`, `fix:`, `docs:`, `chore:`, `test:`.
Atomic per task.
