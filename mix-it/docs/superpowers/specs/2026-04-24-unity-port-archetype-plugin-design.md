# Mix-It Unity Port — Archetype + Plugin Design

**Date:** 2026-04-24
**Status:** Draft for review
**Scope:** Port the HTML prototype (`index-v7.html`, design v6 → v7.5) to a Unity 6.3 project at `D:\Projects\mix-it\MixIt`, structured so the game is split into a reusable **archetype** backbone and a swappable **plugin** (core gameplay). Current archetype: casual PvP arena. Current plugin: liquid puzzles.

---

## 1. Goals

- 1:1 feature parity with mix-it v7.4, plus v7.5 implementation during the port.
- Architecture that allows:
  - Swapping the plugin (liquid puzzles → different core gameplay) by changing a single DI registration, with no edits to archetype code.
  - Swapping the archetype later (casual PvP arena → e.g. level-based puzzle meta) by replacing the archetype package.
  - Promoting `_Archetype` to a versioned in-house UPM package once stable, so future studio titles can consume it as `archetype@version + plugin + config`.
- Designer-tunable content: all balance numbers, screens' content lists (shop bundles, BP tiers, trophy road, venue, albums, league tables, FTUE script, flash offer rules) live as ScriptableObject assets, not hardcoded in scripts.
- Async/simulated PvP (bots + fake matchmaking), with abstraction points that permit a later real-netcode swap without rewriting gameplay.
- Executable across multiple Claude Code sessions — each phase is a self-contained work package with clear done-criteria.

## 2. Non-goals

- Real-time multiplayer netcode in v1.
- Backend / BaaS integration in v1 (local JSON save only; `ISaveBackend` abstraction leaves room).
- Art pipeline, final visuals, VFX polish — the user handles art separately. Port uses placeholders.
- Localization infrastructure beyond English constants in v1 (loc keys + table layout must still be respected so it can be bolted on later).

## 3. Source-of-truth inputs

- `mix-it/index-v7.html` — v7.4 implementation, ~5700 lines, 15 screens, all balance numbers embedded in JS.
- `mix-it/design-v6.md` through `mix-it/design-v7.5-patch-pre-launch-polish.md` — chronological design deltas. v7.5 is unimplemented in the HTML and must land in the Unity port.
- `mix-it/reference-casual-pvp-arena-genre.md`, `reference-mix-it-vs-genre-conventions.md` — genre references.
- Archetype + Plugin framework document (provided in chat) — definitions of archetype vs plugin, moment/minute/hour/day layer model.

## 4. Architectural model

### 4.1 Two layers

| Layer | Owns | Rule |
|---|---|---|
| **Archetype** | Hour-to-hour + day-to-day: meta progression, shop, social, economy, currencies, retention drivers. All screens except match+tutorial. | Reusable across future studio titles. No knowledge of plugin internals. |
| **Plugin** | Moment-to-moment + minute-to-minute: core gameplay, match screen, tutorial, loadout item definitions. | Depends only on `Archetype.Contracts`. Replaceable. |

### 4.2 Repository layout

```
MixIt/Assets/
├── _Archetype/
│   ├── Contracts/              (interfaces + DTOs, zero deps)
│   ├── Data/                   (SO definitions)
│   ├── Runtime/                (services)
│   ├── UI/                     (prefabs + MonoBehaviours for archetype screens)
│   └── Archetype.asmdef-tree
├── _Plugins/
│   └── LiquidPuzzles/
│       ├── Runtime/
│       ├── UI/
│       ├── Data/
│       └── Plugin.LiquidPuzzles.asmdef-tree
├── _Game/                      (composition root — mix-it specific)
│   ├── Bootstrap/              (scene, VContainer LifetimeScope)
│   ├── Config/                 (all .asset SO instances for mix-it)
│   └── Scenes/
└── _Tests/
    ├── Archetype.Tests/
    ├── Plugin.LiquidPuzzles.Tests/
    └── Integration.Tests/
```

### 4.3 Assembly definitions (compiler-enforced boundaries)

| asmdef | Depends on |
|---|---|
| `MixIt.Archetype.Contracts` | (none) |
| `MixIt.Archetype.Data` | Contracts |
| `MixIt.Archetype.Runtime` | Contracts, Data |
| `MixIt.Archetype.UI` | Runtime |
| `MixIt.Plugin.LiquidPuzzles.Runtime` | **Archetype.Contracts only** |
| `MixIt.Plugin.LiquidPuzzles.UI` | Plugin.LiquidPuzzles.Runtime, Archetype.Contracts |
| `MixIt.Game` | everything (composition root) |
| Test asmdefs | their target + test framework |

Plugin must **never** reference `Archetype.Runtime` or `Archetype.UI`. This is the boundary the compiler guards.

### 4.4 `IPlugin` contract (critical interface)

```csharp
namespace MixIt.Archetype.Contracts;

public interface IPlugin {
    PluginManifest Manifest { get; }
    IMatchSession StartMatch(MatchRequest request);
    ILoadoutSlotProvider LoadoutProvider { get; }
    ITutorialScript Tutorial { get; }
}

public record PluginManifest(
    string Id, string DisplayName, Sprite Icon,
    IReadOnlyList<LoadoutSlotDefinition> SupportedSlots);

public record MatchRequest(
    int Seed, OpponentSpec Opponent, DifficultyProfile Difficulty,
    LoadoutSnapshot Loadout);

public interface IMatchSession {
    UniTask<MatchResult> Run(CancellationToken ct);
    GameObject SceneRoot { get; }   // archetype attaches this under its match host
}

public record MatchResult(
    bool Win, int Score,
    IReadOnlyDictionary<string, float> Telemetry);
```

**Direction of information**: plugin reports raw facts (win/loss, score, telemetry). The archetype interprets those into currency gains, rating deltas, BP points, album drops — all via `RewardTranslator` configured in `_Game/Config/`. The plugin never touches `Wallet`, `Rating`, or `BattlePass` directly.

### 4.5 Core services (all live in `Archetype.Runtime`)

| Service | Responsibility |
|---|---|
| `WalletService` | Currencies (gold, gems, energy, etc.) — add, spend, validate, persist |
| `MatchmakingService` | Request → opponent pick via `IOpponentProvider` (bot today) |
| `RatingService` | Elo-style rating, trophies, league bands |
| `BattlePassService` | BP progress, tier unlocks, free vs premium track |
| `TrophyRoadService` | Trophy milestones + reward chests |
| `VenueService` | Venue upgrade tree + idle gold meta |
| `AlbumService` | Collection unlocks + completion rewards |
| `ShopService` | Bundle catalog, purchase, flash offers |
| `FtueService` | Scripted first 60min — session state, next-step hinting |
| `SaveService` | Aggregates all persisted subsystems via `ISaveBackend` |
| `AnalyticsService` | Event sink; `IAnalytics` → no-op / Unity Analytics / future |

### 4.6 Abstraction points (swap seams)

| Interface | v1 impl | Future swap |
|---|---|---|
| `IPlugin` | `LiquidPuzzlesPlugin` | any future plugin |
| `IOpponentProvider` | `BotOpponentProvider` (rating-band bots with fake profiles) | real-matchmaking provider |
| `ISaveBackend` | `LocalJsonSaveBackend` | PlayFab / Nakama / custom |
| `IAnalytics` | `NoOpAnalytics` | Unity Analytics / GameAnalytics |
| `ITimeProvider` | `SystemTimeProvider` | server-authoritative time (anti-cheat for daily resets) |

### 4.7 Data / config model

All balance tables from `index-v7.html` move to ScriptableObject `.asset` files in `_Game/Config/`. Categories:

- **Currencies** — `CurrencyDefinition` SO per currency (id, icon, cap, display format).
- **Shop** — `ShopBundle` SOs + `ShopCatalog` SO listing active bundles; `FlashOfferRules` SO.
- **Battle Pass** — `BattlePassSeason` SO with 30 `BPTier` entries.
- **Trophy Road** — `TrophyRoad` SO with ordered `TrophyTier` entries (threshold + reward).
- **Venue** — `VenueTree` SO with upgrade nodes.
- **Albums** — `Album` SOs + `AlbumSet` SO grouping them; drop-rate tables.
- **Ranking** — `LeagueBand` SOs (min/max rating, reward, visual).
- **Matchmaking** — `RatingTable` SO (K-factor, bot behavior curves).
- **FTUE** — `FtueScript` SO with timestamped events (0s, +3s, 1min, 5min, 30-60min, 60min — see framework doc §9).
- **Plugin-owned** (live inside `Plugin.LiquidPuzzles.Data`) — item catalog, difficulty curves, puzzle definitions.

Designers/the user can tune every number in the Inspector without touching code. Overrides per archetype are natural (the `_Game` layer holds the asset instances).

### 4.8 Save model

Versioned JSON, one blob per subsystem:

```
save.json
├── version: int
├── wallet: { currencyId → amount }
├── rating: { current, peak, leagueId }
├── battlePass: { seasonId, xp, claimedTiers[] }
├── trophyRoad: { claimedMilestones[] }
├── venue: { nodeId → level }
├── albums: { cardId → count }
├── shop: { purchasedBundleIds[], flashOfferState }
├── profile: { name, avatarId, createdAt, lastSeenAt }
└── plugin: { raw JSON blob owned by IPlugin }
```

Plugin gets an opaque `string` slot to persist its own state — archetype never parses it.

### 4.9 Screen ownership

| Screen | Owner | Note |
|---|---|---|
| Splash | Archetype | |
| Home | Archetype | Hosts plugin preview widget via `IPlugin.Manifest` |
| Matchmaking | Archetype | |
| Loadout | **Shared** | Archetype renders slot frame; plugin supplies `ILoadoutSlotProvider` with items |
| Match | Plugin | |
| Tutorial | Plugin | Via `ITutorialScript` |
| Result | Archetype | Consumes `MatchResult` |
| Shop | Archetype | |
| Trophy Road | Archetype | |
| Bar Pass (BP) | Archetype | |
| Venue | Archetype | |
| Albums | Archetype | |
| Teams | Archetype | |
| Ranking | Archetype | |
| VIP | Archetype | |
| Profile | Archetype | |

### 4.10 DI / composition root

VContainer `LifetimeScope` in `_Game/Bootstrap/GameLifetimeScope.cs`. Registers:

- All archetype services (singletons).
- `IPlugin → LiquidPuzzlesPlugin` (single line — the swap point).
- `IOpponentProvider → BotOpponentProvider`.
- `ISaveBackend → LocalJsonSaveBackend`.
- `IAnalytics → NoOpAnalytics`.
- `ITimeProvider → SystemTimeProvider`.
- All `.asset` configs from `_Game/Config/`, loaded via a `ConfigRegistry` SO.

Swapping the plugin = change one line. Swapping the backend = change one line. No prefab/scene edits needed.

## 5. Third-party dependencies

| Package | Purpose | Justification |
|---|---|---|
| **VContainer** | DI | Unity-idiomatic, lightweight, compile-time-safe. Zenject alternative. |
| **UniTask** | Async | Zero-alloc awaits, frame-aware, scene cancellation. Industry standard for Unity async. |
| **DOTween** (Free) | Tweens | UI polish (optional for MVP; recommended for screen transitions and match animations). |
| Unity Test Framework | Tests | Already in manifest. |
| Input System | Input | Already in manifest. |
| URP 17.3 | Render | Already in manifest. |

No other third-party in v1. Addressables deferred — not needed at current asset scale and would add complexity cost.

## 6. Phased execution

Each phase ends with a demoable done-criterion. Phases 3–4 are parallelizable across sessions once phases 0–2 land.

### Phase 0 — Infrastructure skeleton
**Goal:** Empty shells, compiles, boots without crashing.

- Create all asmdefs with dependency rules wired.
- Add VContainer + UniTask via UPM.
- `GameLifetimeScope` registers stub services (empty implementations).
- `BootScene` loads, shows a blank canvas, logs "Boot OK".
- CI: Unity command-line build of `BootScene` succeeds.

**Done criterion:** `UnityEditor` opens, enter Play, console shows "Boot OK", no exceptions.

### Phase 1 — Vertical slice (proves the contract)
**Goal:** Minimum end-to-end loop through the plugin boundary.

- Implement `IPlugin` stub `LiquidPuzzlesPlugin` that renders a single-button match ("tap to win/lose 50/50"), returns `MatchResult`.
- Archetype: `Home → Matchmaking → Match → Result → rewardGold → Home`.
- One currency (gold). One bot opponent. Local save writes/reads.
- No BP, no albums, no shop, no tutorial content.

**Done criterion:** Start app, play match, see result screen with reward, gold counter persists across restart.

### Phase 2 — Liquid Puzzles plugin to v7.5 fidelity
**Goal:** Full core gameplay matches the HTML.

- Port match-screen mechanics from `index-v7.html` §match section.
- Loadout slot definitions + items, all via SO.
- Tutorial script via `ITutorialScript`.
- Difficulty profiles, opponent simulation curve.
- All plugin balance numbers in `_Plugins/LiquidPuzzles/Data/` SO assets.

**Done criterion:** Match feels like the HTML prototype. All v7.0 / v7.1 / v7.2 / v7.3 / v7.3.1 / v7.4 plugin-side design doc line-items verified.

### Phase 3 — Archetype meta systems (parallelizable)
**Goal:** All backend services functional, headless-testable.

Parallel work-units (one per session):
- Wallet + Rating + MatchmakingService.
- BattlePassService + TrophyRoadService.
- VenueService + AlbumService.
- ShopService + FlashOfferRules.
- FtueService + AnalyticsService.

Each lands with unit tests against SO fixtures.

**Done criterion:** Each service has unit-test coverage for its state transitions + SO-driven behavior.

### Phase 4 — Archetype screens UI (parallelizable, one session per screen)
**Goal:** 1:1 visual + UX parity with v7.4 HTML per screen.

Per-screen sub-tasks (one session each): Splash, Home, Matchmaking, Loadout-frame, Result, Shop, Trophy Road, Bar Pass, Venue, Albums, Teams, Ranking, VIP, Profile.

Each screen sub-task:
- Prefab in `_Archetype/UI/`.
- MonoBehaviour bound via VContainer.
- Data sourced from services (Phase 3) + configs (`_Game/Config/`).
- Navigation wired to the app state machine.

**Done criterion:** Every screen reachable, every list populated from config, every button routes correctly. Visual parity with HTML (placeholder art OK).

### Phase 5 — v7.5 polish + FTUE + flash offers
**Goal:** v7.5 patch fully implemented, first 60 minutes scripted.

- Apply `design-v7.5-patch-pre-launch-polish.md` deltas.
- `FtueScript` SO encoding the 0s → 60min timeline.
- Flash offer triggers, paywall sweet-spot at 30–60 min mark.

**Done criterion:** Fresh install → scripted first 60 minutes runs end to end without FTUE dead-ends.

### Phase 6 — Promote `_Archetype` to UPM package
**Goal:** Archetype reusable across future studio titles.

- Extract `_Archetype/` to its own folder with `package.json`.
- Move to separate repo (or keep as local package).
- `MixIt` consumes it as a UPM dependency.
- Document the `IPlugin` contract for third-party plugin authors inside the studio.

**Done criterion:** A throwaway second Unity project can depend on the archetype package and spin up a stub plugin in < 1 hour.

## 7. Testing strategy

- **Unit tests** for every archetype service (state transitions, save/load round-trips, config-driven edge cases).
- **Contract tests** for `IPlugin` — a dummy `NullPlugin` implementation lets the archetype test suite run without any real plugin.
- **Integration tests** covering the vertical slice (Home → Match → Result → persisted state).
- **Manual QA checklist** per screen in Phase 4 (mirrors v7.4 acceptance criteria in design docs).

## 8. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Plugin boundary leaks (plugin starts reaching for Wallet directly) | Compiler-enforced via asmdef refs; code review checkpoints at Phases 1, 2, 6. |
| Config explosion unmanageable in Inspector | `ConfigRegistry` master SO that indexes all others; folder convention per subsystem. |
| SO assets hard to version-control / merge | Force text serialization; one SO per file; CI check that guards against embedded nested SOs. |
| Unity 6.3 + URP 17.3 third-party asset lag | Third-party list held to 3 packages (VContainer, UniTask, DOTween) — all known-compatible. |
| Phase 4 (14 screens) sprawl | Each screen is one session with a fixed done-criterion; screen list is the parallelization unit. |
| v7.5 content drifts during port | Freeze v7.5 patch doc before Phase 5 starts; any new design goes to v7.6 post-launch. |
| Loadout is "shared" — ambiguous ownership | Archetype owns the *frame* and *equip rules*; plugin owns the *items*. `ILoadoutSlotProvider` is the seam. Revisit if disputes arise in Phase 2. |

## 9. Open items (resolve before Phase 0 starts)

- Confirm package versions for VContainer + UniTask (pin to latest stable at Phase 0 start).
- Confirm Git LFS policy for any placeholder art the user drops in.
- Confirm project namespace root: `MixIt.*` assumed in this doc.

## 10. References

- `mix-it/index-v7.html` — v7.4 source
- `mix-it/design-v7.5-patch-pre-launch-polish.md` — target delta
- Archetype + Plugin framework doc (chat attachment, 2026-04-24)
- Framework layer model: moment / minute / hour / day
