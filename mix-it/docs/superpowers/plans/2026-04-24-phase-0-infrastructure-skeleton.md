# Phase 0 — Infrastructure Skeleton Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the Unity project skeleton — folder structure, assembly definitions, DI (VContainer) + async (UniTask) packages, Main scene with canvas hierarchy, `UIRouter` service stub — so a fresh Play session boots to `"Boot OK"` with no exceptions and no compile errors.

**Architecture:** Single `Main` scene. One composition root (`GameLifetimeScope`) registers archetype services and the plugin via VContainer. Eight assembly definitions enforce boundaries: Archetype (Contracts / Data / Runtime / UI), Plugin (Runtime / UI), Game composition root, Tests. Plugin references `Archetype.Contracts` only.

**Tech Stack:** Unity 6.3.0f1, URP 17.3, C# 9+, VContainer 1.16.x, UniTask 2.5.x, Unity Test Framework 1.6.

**Spec:** [`../specs/2026-04-24-unity-port-archetype-plugin-design.md`](../specs/2026-04-24-unity-port-archetype-plugin-design.md) — §4.2 repo layout, §4.3 asmdefs, §4.9 scene architecture, §4.10 DI, §5 deps, §6 Phase 0 done-criterion.

**Unity project root:** `D:\Projects\mix-it\MixIt`

---

## File structure overview

Paths are relative to `D:\Projects\mix-it\MixIt\Assets\` unless noted. Every C# file also requires a `.meta` — Unity generates it on Editor focus; do not hand-write meta files.

```
Assets/
├── _Archetype/
│   ├── Contracts/
│   │   ├── MixIt.Archetype.Contracts.asmdef
│   │   ├── IPlugin.cs
│   │   ├── IMatchSession.cs
│   │   ├── MatchRequest.cs
│   │   ├── MatchResult.cs
│   │   ├── PluginManifest.cs
│   │   ├── IUIRouter.cs
│   │   └── PanelId.cs
│   ├── Data/
│   │   └── MixIt.Archetype.Data.asmdef
│   ├── Runtime/
│   │   ├── MixIt.Archetype.Runtime.asmdef
│   │   └── UI/
│   │       └── UIRouter.cs
│   └── UI/
│       └── MixIt.Archetype.UI.asmdef
├── _Plugins/
│   └── LiquidPuzzles/
│       ├── Runtime/
│       │   ├── MixIt.Plugin.LiquidPuzzles.Runtime.asmdef
│       │   └── LiquidPuzzlesPlugin.cs
│       └── UI/
│           └── MixIt.Plugin.LiquidPuzzles.UI.asmdef
├── _Game/
│   ├── Bootstrap/
│   │   ├── MixIt.Game.asmdef
│   │   ├── GameLifetimeScope.cs
│   │   └── Bootstrapper.cs
│   └── Scenes/
│       └── Main.unity
└── _Tests/
    └── EditMode/
        ├── MixIt.Archetype.Tests.asmdef
        └── UIRouterTests.cs
```

---

## Task 1: Update `Packages/manifest.json` with VContainer and UniTask

**Files:**
- Modify: `D:/Projects/mix-it/MixIt/Packages/manifest.json`

- [ ] **Step 1: Read current manifest**

Run: `cat "D:/Projects/mix-it/MixIt/Packages/manifest.json"`

Expected: JSON listing `com.unity.render-pipelines.universal`, `com.unity.inputsystem`, etc.

- [ ] **Step 2: Add VContainer and UniTask via git URLs**

Append two entries to the `"dependencies"` object (alphabetical order). VContainer and UniTask are distributed as Git packages:

```json
{
  "dependencies": {
    "com.cysharp.unitask": "https://github.com/Cysharp/UniTask.git?path=src/UniTask/Assets/Plugins/UniTask#2.5.10",
    "jp.hadashikick.vcontainer": "https://github.com/hadashiA/VContainer.git?path=VContainer/Assets/VContainer#1.16.9",
    ... (existing entries remain)
  }
}
```

Full updated manifest:

```json
{
  "dependencies": {
    "com.cysharp.unitask": "https://github.com/Cysharp/UniTask.git?path=src/UniTask/Assets/Plugins/UniTask#2.5.10",
    "com.unity.ai.navigation": "2.0.12",
    "com.unity.collab-proxy": "2.12.4",
    "com.unity.ide.rider": "3.0.39",
    "com.unity.ide.visualstudio": "2.0.26",
    "com.unity.inputsystem": "1.19.0",
    "com.unity.multiplayer.center": "1.0.1",
    "com.unity.render-pipelines.universal": "17.3.0",
    "com.unity.test-framework": "1.6.0",
    "com.unity.timeline": "1.8.12",
    "com.unity.ugui": "2.0.0",
    "com.unity.visualscripting": "1.9.11",
    "com.unity.modules.accessibility": "1.0.0",
    "com.unity.modules.adaptiveperformance": "1.0.0",
    "com.unity.modules.ai": "1.0.0",
    "com.unity.modules.androidjni": "1.0.0",
    "com.unity.modules.animation": "1.0.0",
    "com.unity.modules.assetbundle": "1.0.0",
    "com.unity.modules.audio": "1.0.0",
    "com.unity.modules.cloth": "1.0.0",
    "com.unity.modules.director": "1.0.0",
    "com.unity.modules.imageconversion": "1.0.0",
    "com.unity.modules.imgui": "1.0.0",
    "com.unity.modules.jsonserialize": "1.0.0",
    "com.unity.modules.particlesystem": "1.0.0",
    "com.unity.modules.physics": "1.0.0",
    "com.unity.modules.physics2d": "1.0.0",
    "com.unity.modules.screencapture": "1.0.0",
    "com.unity.modules.terrain": "1.0.0",
    "com.unity.modules.terrainphysics": "1.0.0",
    "com.unity.modules.tilemap": "1.0.0",
    "com.unity.modules.ui": "1.0.0",
    "com.unity.modules.uielements": "1.0.0",
    "com.unity.modules.umbra": "1.0.0",
    "com.unity.modules.unityanalytics": "1.0.0",
    "com.unity.modules.unitywebrequest": "1.0.0",
    "com.unity.modules.unitywebrequestassetbundle": "1.0.0",
    "com.unity.modules.unitywebrequestaudio": "1.0.0",
    "com.unity.modules.unitywebrequesttexture": "1.0.0",
    "com.unity.modules.unitywebrequestwww": "1.0.0",
    "com.unity.modules.vectorgraphics": "1.0.0",
    "com.unity.modules.vehicles": "1.0.0",
    "com.unity.modules.video": "1.0.0",
    "com.unity.modules.vr": "1.0.0",
    "com.unity.modules.wind": "1.0.0",
    "com.unity.modules.xr": "1.0.0"
  }
}
```

- [ ] **Step 3: [manual in Editor]** Open Unity, let it resolve packages

Open `D:\Projects\mix-it\MixIt` in Unity Hub with Unity 6.3. Package Manager will fetch UniTask and VContainer. Watch the console for compile errors.

Expected: Package Manager shows `UniTask` and `VContainer` under "In Project". No red errors in console.

- [ ] **Step 4: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Packages/manifest.json Packages/packages-lock.json
git commit -m "build: add VContainer and UniTask via UPM"
```

---

## Task 2: Create archetype Contracts asmdef and core interface files

**Files:**
- Create: `Assets/_Archetype/Contracts/MixIt.Archetype.Contracts.asmdef`
- Create: `Assets/_Archetype/Contracts/PanelId.cs`
- Create: `Assets/_Archetype/Contracts/IUIRouter.cs`
- Create: `Assets/_Archetype/Contracts/PluginManifest.cs`
- Create: `Assets/_Archetype/Contracts/MatchRequest.cs`
- Create: `Assets/_Archetype/Contracts/MatchResult.cs`
- Create: `Assets/_Archetype/Contracts/IMatchSession.cs`
- Create: `Assets/_Archetype/Contracts/IPlugin.cs`

- [ ] **Step 1: Create asmdef**

Path: `Assets/_Archetype/Contracts/MixIt.Archetype.Contracts.asmdef`

```json
{
    "name": "MixIt.Archetype.Contracts",
    "rootNamespace": "MixIt.Archetype.Contracts",
    "references": [
        "GUID:f51ebe6a0ceec4240a699833d6309b23"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

Note: the GUID reference is UniTask's assembly. If Unity reports an unresolved reference after this, open the asmdef inspector and re-add `UniTask` via the "Assembly Definition References" UI — the GUID may differ per UniTask version.

- [ ] **Step 2: Create `PanelId.cs`**

Path: `Assets/_Archetype/Contracts/PanelId.cs`

```csharp
namespace MixIt.Archetype.Contracts
{
    public enum PanelId
    {
        None,
        Loading,
        Home,
        Matchmaking,
        Loadout,
        Match,
        Result,
        Shop,
        TrophyRoad,
        BarPass,
        Venue,
        Albums,
        Teams,
        Ranking,
        Vip,
        Profile
    }
}
```

- [ ] **Step 3: Create `IUIRouter.cs`**

Path: `Assets/_Archetype/Contracts/IUIRouter.cs`

```csharp
using Cysharp.Threading.Tasks;

namespace MixIt.Archetype.Contracts
{
    public interface IUIRouter
    {
        PanelId Current { get; }
        UniTask GoTo(PanelId id, object args = null);
    }
}
```

- [ ] **Step 4: Create `PluginManifest.cs`**

Path: `Assets/_Archetype/Contracts/PluginManifest.cs`

```csharp
using UnityEngine;

namespace MixIt.Archetype.Contracts
{
    public record PluginManifest(string Id, string DisplayName, Sprite Icon);
}
```

- [ ] **Step 5: Create `MatchRequest.cs`**

Path: `Assets/_Archetype/Contracts/MatchRequest.cs`

```csharp
namespace MixIt.Archetype.Contracts
{
    public record MatchRequest(int Seed);
}
```

Kept minimal for Phase 0. OpponentSpec / DifficultyProfile / LoadoutSnapshot fields get added in Phase 1 and refined in Phase 2 when real gameplay lands.

- [ ] **Step 6: Create `MatchResult.cs`**

Path: `Assets/_Archetype/Contracts/MatchResult.cs`

```csharp
using System.Collections.Generic;

namespace MixIt.Archetype.Contracts
{
    public record MatchResult(bool Win, int Score, IReadOnlyDictionary<string, float> Telemetry);
}
```

- [ ] **Step 7: Create `IMatchSession.cs`**

Path: `Assets/_Archetype/Contracts/IMatchSession.cs`

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;
using UnityEngine;

namespace MixIt.Archetype.Contracts
{
    public interface IMatchSession
    {
        GameObject SceneRoot { get; }
        UniTask<MatchResult> Run(CancellationToken ct);
    }
}
```

- [ ] **Step 8: Create `IPlugin.cs`**

Path: `Assets/_Archetype/Contracts/IPlugin.cs`

```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IPlugin
    {
        PluginManifest Manifest { get; }
        IMatchSession StartMatch(MatchRequest request);
    }
}
```

Phase 0 scope drops `LoadoutProvider` and `Tutorial` — those re-enter in Phase 2 when liquid puzzles ships real content. Keeping the surface minimal now means fewer retrofits.

- [ ] **Step 9: [manual in Editor]** Trigger compile + resolve references

In Unity, focus the Editor window (alt-tab back). Unity compiles and generates `.meta` files. If console reports "UniTask reference not found", click the `MixIt.Archetype.Contracts.asmdef` in the Project view, in the Inspector under "Assembly Definition References" click `+`, select `UniTask`, Apply.

Expected: no compile errors.

- [ ] **Step 10: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Archetype/Contracts/
git commit -m "feat(archetype): add Contracts asmdef — IPlugin, IUIRouter, match DTOs"
```

---

## Task 3: Create empty Archetype.Data and Archetype.UI asmdefs

**Files:**
- Create: `Assets/_Archetype/Data/MixIt.Archetype.Data.asmdef`
- Create: `Assets/_Archetype/UI/MixIt.Archetype.UI.asmdef`

- [ ] **Step 1: Create `MixIt.Archetype.Data.asmdef`**

Path: `Assets/_Archetype/Data/MixIt.Archetype.Data.asmdef`

```json
{
    "name": "MixIt.Archetype.Data",
    "rootNamespace": "MixIt.Archetype.Data",
    "references": [
        "MixIt.Archetype.Contracts"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

- [ ] **Step 2: Create placeholder file to suppress "empty assembly" warning**

Path: `Assets/_Archetype/Data/_Placeholder.cs`

```csharp
namespace MixIt.Archetype.Data
{
    internal static class _Placeholder { }
}
```

Deleted as soon as Phase 3 adds the first real SO type.

- [ ] **Step 3: Create `MixIt.Archetype.UI.asmdef`**

Path: `Assets/_Archetype/UI/MixIt.Archetype.UI.asmdef`

```json
{
    "name": "MixIt.Archetype.UI",
    "rootNamespace": "MixIt.Archetype.UI",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Archetype.Runtime"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

- [ ] **Step 4: Placeholder for UI assembly**

Path: `Assets/_Archetype/UI/_Placeholder.cs`

```csharp
namespace MixIt.Archetype.UI
{
    internal static class _Placeholder { }
}
```

- [ ] **Step 5: [manual in Editor]** Verify compile clean

Focus Unity. Expected: no errors. `MixIt.Archetype.UI` will report unresolved `MixIt.Archetype.Runtime` — that's fine, Task 4 creates it. Proceed without fixing.

- [ ] **Step 6: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Archetype/Data/ Assets/_Archetype/UI/
git commit -m "feat(archetype): add Data and UI asmdef skeletons"
```

---

## Task 4: Create Archetype.Runtime asmdef + UIRouter implementation

**Files:**
- Create: `Assets/_Archetype/Runtime/MixIt.Archetype.Runtime.asmdef`
- Create: `Assets/_Archetype/Runtime/UI/UIRouter.cs`

- [ ] **Step 1: Create asmdef**

Path: `Assets/_Archetype/Runtime/MixIt.Archetype.Runtime.asmdef`

```json
{
    "name": "MixIt.Archetype.Runtime",
    "rootNamespace": "MixIt.Archetype.Runtime",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Archetype.Data",
        "GUID:f51ebe6a0ceec4240a699833d6309b23"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

If the UniTask GUID reference fails to resolve, re-add via Inspector (same procedure as Task 2).

- [ ] **Step 2: Create `UIRouter.cs`** (logic-only, no scene wiring yet)

Path: `Assets/_Archetype/Runtime/UI/UIRouter.cs`

```csharp
using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Archetype.Runtime.UI
{
    /// <summary>Routes panel navigation. Panels register themselves by PanelId.</summary>
    public class UIRouter : IUIRouter
    {
        readonly Dictionary<PanelId, GameObject> _panels = new();
        public PanelId Current { get; private set; } = PanelId.None;

        public void RegisterPanel(PanelId id, GameObject panel)
        {
            if (id == PanelId.None) throw new ArgumentException("PanelId.None is not registerable");
            if (panel == null) throw new ArgumentNullException(nameof(panel));
            _panels[id] = panel;
            panel.SetActive(false);
        }

        public UniTask GoTo(PanelId id, object args = null)
        {
            if (!_panels.TryGetValue(id, out var next))
                throw new InvalidOperationException($"Panel {id} not registered");

            if (Current != PanelId.None && _panels.TryGetValue(Current, out var prev))
                prev.SetActive(false);

            next.SetActive(true);
            Current = id;
            return UniTask.CompletedTask;
        }
    }
}
```

Commit granularity: UIRouter is behaviour-only; scene-level registration comes in Task 9. The EditMode test in Task 8 verifies this class in isolation.

- [ ] **Step 3: [manual in Editor]** Verify compile

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Archetype/Runtime/
git commit -m "feat(archetype): UIRouter — panel registration + GoTo"
```

---

## Task 5: Create Plugin.LiquidPuzzles asmdefs + stub plugin

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/MixIt.Plugin.LiquidPuzzles.Runtime.asmdef`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesPlugin.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/UI/MixIt.Plugin.LiquidPuzzles.UI.asmdef`

- [ ] **Step 1: Create Plugin.Runtime asmdef**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/MixIt.Plugin.LiquidPuzzles.Runtime.asmdef`

```json
{
    "name": "MixIt.Plugin.LiquidPuzzles.Runtime",
    "rootNamespace": "MixIt.Plugin.LiquidPuzzles",
    "references": [
        "MixIt.Archetype.Contracts",
        "GUID:f51ebe6a0ceec4240a699833d6309b23"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

Note: **deliberately no reference to `MixIt.Archetype.Runtime` or `MixIt.Archetype.UI`.** The compiler enforces the boundary — any attempt to `using MixIt.Archetype.Runtime.X` from inside this assembly fails to compile. This is the architectural guardrail.

- [ ] **Step 2: Create stub `LiquidPuzzlesMatchSession.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs`

```csharp
using System.Collections.Generic;
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Plugin.LiquidPuzzles
{
    public class LiquidPuzzlesMatchSession : IMatchSession
    {
        public GameObject SceneRoot { get; } = new GameObject("LiquidPuzzlesMatchRoot");

        public async UniTask<MatchResult> Run(CancellationToken ct)
        {
            await UniTask.Yield(ct);
            return new MatchResult(Win: true, Score: 0, Telemetry: new Dictionary<string, float>());
        }
    }
}
```

- [ ] **Step 3: Create stub `LiquidPuzzlesPlugin.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesPlugin.cs`

```csharp
using MixIt.Archetype.Contracts;

namespace MixIt.Plugin.LiquidPuzzles
{
    public class LiquidPuzzlesPlugin : IPlugin
    {
        public PluginManifest Manifest { get; } =
            new PluginManifest("liquid-puzzles", "Liquid Puzzles", null);

        public IMatchSession StartMatch(MatchRequest request)
            => new LiquidPuzzlesMatchSession();
    }
}
```

- [ ] **Step 4: Create Plugin.UI asmdef (empty shell)**

Path: `Assets/_Plugins/LiquidPuzzles/UI/MixIt.Plugin.LiquidPuzzles.UI.asmdef`

```json
{
    "name": "MixIt.Plugin.LiquidPuzzles.UI",
    "rootNamespace": "MixIt.Plugin.LiquidPuzzles.UI",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Plugin.LiquidPuzzles.Runtime"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

Path: `Assets/_Plugins/LiquidPuzzles/UI/_Placeholder.cs`

```csharp
namespace MixIt.Plugin.LiquidPuzzles.UI
{
    internal static class _Placeholder { }
}
```

- [ ] **Step 5: [manual in Editor]** Verify compile

Expected: no errors.

- [ ] **Step 6: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Plugins/
git commit -m "feat(plugin): liquid-puzzles stub — IPlugin + IMatchSession (contract-only deps)"
```

---

## Task 6: Create MixIt.Game asmdef + Bootstrapper

**Files:**
- Create: `Assets/_Game/Bootstrap/MixIt.Game.asmdef`
- Create: `Assets/_Game/Bootstrap/Bootstrapper.cs`

VContainer's `LifetimeScope` lands in Task 9 once the scene exists to attach it to. This task creates the plain-C# Bootstrapper and the game asmdef.

- [ ] **Step 1: Create asmdef**

Path: `Assets/_Game/Bootstrap/MixIt.Game.asmdef`

```json
{
    "name": "MixIt.Game",
    "rootNamespace": "MixIt.Game",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Archetype.Data",
        "MixIt.Archetype.Runtime",
        "MixIt.Archetype.UI",
        "MixIt.Plugin.LiquidPuzzles.Runtime",
        "MixIt.Plugin.LiquidPuzzles.UI",
        "VContainer",
        "VContainer.Unity",
        "GUID:f51ebe6a0ceec4240a699833d6309b23"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": false
}
```

If VContainer asmdef names differ in the installed version, open the asmdef Inspector and reconnect.

- [ ] **Step 2: Create `Bootstrapper.cs`**

Path: `Assets/_Game/Bootstrap/Bootstrapper.cs`

```csharp
using MixIt.Archetype.Contracts;
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace MixIt.Game
{
    /// <summary>Runs once after VContainer builds the scope. Proves DI works end-to-end.</summary>
    public class Bootstrapper : IStartable
    {
        readonly IUIRouter _router;
        readonly IPlugin _plugin;

        [Inject]
        public Bootstrapper(IUIRouter router, IPlugin plugin)
        {
            _router = router;
            _plugin = plugin;
        }

        public void Start()
        {
            Debug.Log($"Boot OK — plugin='{_plugin.Manifest.Id}', router current={_router.Current}");
        }
    }
}
```

- [ ] **Step 3: [manual in Editor]** Verify compile (scope class still missing — expected error)

Expected: `Bootstrapper.cs` compiles. `GameLifetimeScope` does not exist yet — that's Task 9.

- [ ] **Step 4: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Game/
git commit -m "feat(game): add MixIt.Game asmdef + Bootstrapper (DI smoke-test class)"
```

---

## Task 7: Create EditMode tests for UIRouter

**Files:**
- Create: `Assets/_Tests/EditMode/MixIt.Archetype.Tests.asmdef`
- Create: `Assets/_Tests/EditMode/UIRouterTests.cs`

- [ ] **Step 1: Create test asmdef**

Path: `Assets/_Tests/EditMode/MixIt.Archetype.Tests.asmdef`

```json
{
    "name": "MixIt.Archetype.Tests",
    "rootNamespace": "MixIt.Archetype.Tests",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Archetype.Runtime",
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner"
    ],
    "includePlatforms": [
        "Editor"
    ],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": true,
    "precompiledReferences": [
        "nunit.framework.dll"
    ],
    "autoReferenced": false,
    "defineConstraints": [
        "UNITY_INCLUDE_TESTS"
    ],
    "versionDefines": [],
    "noEngineReferences": false
}
```

- [ ] **Step 2: Write failing test `UIRouterTests.cs`**

Path: `Assets/_Tests/EditMode/UIRouterTests.cs`

```csharp
using System;
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime.UI;
using NUnit.Framework;
using UnityEngine;

namespace MixIt.Archetype.Tests
{
    public class UIRouterTests
    {
        UIRouter _router;
        GameObject _home;
        GameObject _shop;

        [SetUp]
        public void SetUp()
        {
            _router = new UIRouter();
            _home = new GameObject("Home"); _home.SetActive(true);
            _shop = new GameObject("Shop"); _shop.SetActive(true);
        }

        [TearDown]
        public void TearDown()
        {
            UnityEngine.Object.DestroyImmediate(_home);
            UnityEngine.Object.DestroyImmediate(_shop);
        }

        [Test]
        public void RegisterPanel_HidesPanelImmediately()
        {
            _router.RegisterPanel(PanelId.Home, _home);
            Assert.IsFalse(_home.activeSelf);
        }

        [Test]
        public void GoTo_ActivatesTargetAndDeactivatesPrevious()
        {
            _router.RegisterPanel(PanelId.Home, _home);
            _router.RegisterPanel(PanelId.Shop, _shop);

            _router.GoTo(PanelId.Home).GetAwaiter().GetResult();
            Assert.IsTrue(_home.activeSelf, "home should be active after first GoTo");

            _router.GoTo(PanelId.Shop).GetAwaiter().GetResult();
            Assert.IsFalse(_home.activeSelf, "home should be hidden after switch");
            Assert.IsTrue(_shop.activeSelf, "shop should be active after switch");
            Assert.AreEqual(PanelId.Shop, _router.Current);
        }

        [Test]
        public void GoTo_UnknownPanel_Throws()
        {
            Assert.Throws<InvalidOperationException>(
                () => _router.GoTo(PanelId.Home).GetAwaiter().GetResult());
        }

        [Test]
        public void RegisterPanel_None_Throws()
        {
            Assert.Throws<ArgumentException>(() => _router.RegisterPanel(PanelId.None, _home));
        }
    }
}
```

- [ ] **Step 3: Run tests in Editor — expect PASS**

Open Window → General → Test Runner → EditMode → Run All.

Expected: 4 tests green. If the UIRouter implementation in Task 4 was correct, they pass first try. If any fail, fix UIRouter — **do not change the test expectations**.

- [ ] **Step 4: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Tests/
git commit -m "test(archetype): UIRouter — register, GoTo, errors"
```

---

## Task 8: Create the `Main` scene with canvas hierarchy **[manual in Editor]**

**Files:**
- Create: `Assets/_Game/Scenes/Main.unity`

Scene YAML is fragile; create via Editor.

- [ ] **Step 1: Create empty scene**

Unity → File → New Scene → "Empty" template. Save As `Assets/_Game/Scenes/Main.unity`.

- [ ] **Step 2: Build canvas hierarchy**

Under the scene root, create:

```
MainCanvas                  (Canvas: Render Mode = Screen Space Overlay; + CanvasScaler UI Scale Mode = Scale With Screen Size, Reference 1080×1920, Match 0.5; + GraphicRaycaster)
├── TopMenuPanel            (empty RectTransform, anchor top-stretch, height 160)
├── ContentRoot             (empty RectTransform, anchor stretch-stretch, offsets 160 top / 220 bottom)
│   ├── LoadingPanel        (empty, full-stretch inside ContentRoot)
│   ├── HomePanel
│   ├── MatchmakingPanel
│   ├── LoadoutPanel
│   ├── MatchPanel
│   ├── ResultPanel
│   ├── ShopPanel
│   ├── TrophyRoadPanel
│   ├── BarPassPanel
│   ├── VenuePanel
│   ├── AlbumsPanel
│   ├── TeamsPanel
│   ├── RankingPanel
│   ├── VipPanel
│   └── ProfilePanel
├── BottomMenuPanel         (anchor bottom-stretch, height 220)
└── OverlayRoot             (anchor stretch-stretch, full)
```

Add an `EventSystem` GameObject (GameObject → UI → Event System).

Panels are empty RectTransforms for Phase 0 — each gets a placeholder `TextMeshPro` label showing the panel name so the visual switch in Task 9 is observable. `LoadingPanel` set active; all other ContentRoot children set inactive.

- [ ] **Step 3: Add temporary label to each panel**

On each panel child, add `GameObject → UI → Text - TextMeshPro` with the panel name (e.g. "HOME"). Accept the TMP Essentials import prompt on first use.

- [ ] **Step 4: Set `Main` as the default scene in Build Settings**

File → Build Settings → drag `Main.unity` in, tick it. Remove `SampleScene` if present.

- [ ] **Step 5: Save scene**

Ctrl+S.

- [ ] **Step 6: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Game/Scenes/ ProjectSettings/EditorBuildSettings.asset ProjectSettings/TagManager.asset
git commit -m "feat(game): Main scene — MainCanvas hierarchy with panel placeholders"
```

---

## Task 9: Wire `GameLifetimeScope` into the scene **[mixed]**

**Files:**
- Create: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`
- Create: `Assets/_Game/Bootstrap/SceneRefs.cs`
- Modify: `Assets/_Game/Scenes/Main.unity` (attach scope component)

- [ ] **Step 1: Create `SceneRefs.cs`** (MonoBehaviour holding panel references)

Path: `Assets/_Game/Bootstrap/SceneRefs.cs`

```csharp
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Game
{
    /// <summary>Inspector-wired registry of panel GameObjects. Scope reads this to register panels with UIRouter.</summary>
    public class SceneRefs : MonoBehaviour
    {
        [System.Serializable]
        public struct PanelBinding
        {
            public PanelId Id;
            public GameObject Panel;
        }

        [SerializeField] public PanelBinding[] Panels;
    }
}
```

- [ ] **Step 2: Create `GameLifetimeScope.cs`**

Path: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`

```csharp
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime.UI;
using MixIt.Plugin.LiquidPuzzles;
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace MixIt.Game
{
    public class GameLifetimeScope : LifetimeScope
    {
        [SerializeField] SceneRefs _sceneRefs;

        protected override void Configure(IContainerBuilder builder)
        {
            // Archetype services
            builder.Register<UIRouter>(Lifetime.Singleton).As<IUIRouter>();

            // Plugin — single DI line is the swap point
            builder.Register<LiquidPuzzlesPlugin>(Lifetime.Singleton).As<IPlugin>();

            // Bootstrapper runs once on scope start
            builder.RegisterEntryPoint<Bootstrapper>();

            // After scope builds, register scene panels with the router.
            builder.RegisterBuildCallback(container =>
            {
                var router = (UIRouter)container.Resolve<IUIRouter>();
                foreach (var binding in _sceneRefs.Panels)
                {
                    if (binding.Panel == null || binding.Id == PanelId.None) continue;
                    router.RegisterPanel(binding.Id, binding.Panel);
                }
                router.GoTo(PanelId.Loading).Forget();
            });
        }
    }
}
```

Note: `UIRouter` is registered as both `IUIRouter` (injection target) and recoverable as the concrete via resolving `IUIRouter` + cast — acceptable for this single call site. Alternative registration `builder.Register<UIRouter>(Lifetime.Singleton).AsSelf().As<IUIRouter>()` also works; use either.

- [ ] **Step 3: [manual in Editor]** Add `GameLifetimeScope` + `SceneRefs` to the scene

In `Main.unity`:

1. Create empty GameObject `[App]` at scene root.
2. Add component: `GameLifetimeScope`.
3. Add component: `SceneRefs`.
4. In `SceneRefs.Panels`, set `Size` = 16. Fill each row: pick PanelId from the dropdown, drag the matching scene panel into the `Panel` field.
5. On `GameLifetimeScope`, drag `[App]` (self) into the `_sceneRefs` field.
6. Save scene.

- [ ] **Step 4: [manual in Editor]** Enter Play mode — verify smoke test

Press Play. Expected in Console:
```
Boot OK — plugin='liquid-puzzles', router current=None
```
(The log fires during `Start()` before the scope's build callback calls `GoTo(Loading)`. Both orderings are acceptable — the requirement is **no exceptions** and some `Boot OK …` line present.)

In the Game view: only `LoadingPanel` (the "LOADING" label) should be visible. All other content panels inactive. `TopMenuPanel` + `BottomMenuPanel` visible (empty rects for now).

If Boot OK does not appear: check Console for missing DI bindings or null-ref on `SceneRefs`. Do not proceed until green.

- [ ] **Step 5: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Game/ Assets/_Game/Scenes/
git commit -m "feat(game): GameLifetimeScope — DI wired, Boot OK smoke test passes"
```

---

## Task 10: CI headless test runner script

**Files:**
- Create: `D:/Projects/mix-it/MixIt/run-tests.bat`
- Create: `D:/Projects/mix-it/MixIt/.gitignore` (if missing)

- [ ] **Step 1: Verify `.gitignore` exists and ignores Library/Temp/Logs/obj/Build**

Path: `D:/Projects/mix-it/MixIt/.gitignore` — if missing, create with:

```
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]ser[Ss]ettings/
*.csproj
*.unityproj
*.sln
*.suo
*.tmp
*.user
*.userprefs
*.pidb
*.booproj
*.svd
*.pdb
*.mdb
*.opendb
*.VC.db
*.DS_Store
.vs/
.idea/
```

- [ ] **Step 2: Create headless test script**

Path: `D:/Projects/mix-it/MixIt/run-tests.bat`

```bat
@echo off
setlocal
set UNITY="C:\Program Files\Unity\Hub\Editor\6000.3.0f1\Editor\Unity.exe"
set PROJECT=%~dp0
%UNITY% -batchmode -nographics -projectPath "%PROJECT%" -runTests -testPlatform EditMode -testResults "%PROJECT%\test-results.xml" -logFile "%PROJECT%\test.log"
type "%PROJECT%\test.log"
```

Adjust `UNITY` path if Unity is installed elsewhere. The user's exact Unity 6.3 install path should be substituted.

- [ ] **Step 3: Run it and verify PASS**

```bash
cd "D:/Projects/mix-it/MixIt"
./run-tests.bat
```

Expected (in `test.log`): `Test Results 4 passed, 0 failed`. The four tests are from Task 7.

If Unity is open in the Editor, close it first — batch-mode requires an exclusive project lock.

- [ ] **Step 4: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add .gitignore run-tests.bat
git commit -m "ci: headless EditMode test runner script"
```

---

## Task 11: Phase 0 done-criterion checklist

- [ ] **Step 1: Run all gates**

1. `./run-tests.bat` — 4 passed, 0 failed.
2. Open Unity → Play `Main` scene → Console shows `Boot OK …` line, no red errors, LoadingPanel visible.
3. Inspect `MixIt.Plugin.LiquidPuzzles.Runtime.asmdef` in Project view → References list does **not** contain `MixIt.Archetype.Runtime` or `MixIt.Archetype.UI` (architectural guardrail).
4. `git log --oneline` shows 10 phase-0 commits (one per task).

- [ ] **Step 2: Write Phase 0 completion note**

Path: `Assets/_Game/PHASE_0_DONE.md`

```markdown
# Phase 0 complete

- Assembly boundaries wired (Archetype Contracts/Data/Runtime/UI, Plugin Runtime/UI, Game).
- VContainer + UniTask installed.
- Main scene with MainCanvas + 16 panel placeholders + persistent TopMenuPanel/BottomMenuPanel.
- UIRouter service registers panels and switches between them.
- Bootstrapper runs on DI scope start — `Boot OK` confirms plugin injected and router resolved.
- EditMode tests green (4/4).
- Plugin depends only on Archetype.Contracts — compiler-enforced.

Ready for Phase 1: vertical slice (stub gameplay, one currency, Home → Match → Result → Home loop).
```

- [ ] **Step 3: Commit**

```bash
cd "D:/Projects/mix-it/MixIt"
git add Assets/_Game/PHASE_0_DONE.md
git commit -m "docs: Phase 0 complete"
```

---

## Appendix — troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Red "UniTask namespace not found" after Task 2 | UniTask GUID mismatch in asmdef | Open asmdef Inspector, remove stale GUID, re-add via `+ UniTask` |
| `VContainer` asmdef not found in Task 6 | VContainer package name in 1.16+ may be split | Check Project → Packages → VContainer for exact asmdef names; update refs |
| EditMode tests don't appear in Test Runner | Test asmdef missing platform `Editor` | Ensure `"includePlatforms": ["Editor"]` in test asmdef |
| Play mode: "SceneRefs is null" NRE | Inspector field not wired | In scene, drag `[App]` GameObject into `_sceneRefs` on `GameLifetimeScope` |
| `RegisterBuildCallback` missing | VContainer < 1.13 | Upgrade VContainer to 1.16.x — URL in Task 1 pins this |
| Plugin code accidentally compiles with `using MixIt.Archetype.Runtime` | asmdef reference leaked | Remove the leaked reference from `MixIt.Plugin.LiquidPuzzles.Runtime.asmdef`; fix the code |

---

## Self-review checklist (run after executing plan, before handing Phase 1)

- Every `IPlugin` member defined in `Contracts` matches the spec §4.4 surface (Phase 0 deliberately trims `LoadoutProvider`/`Tutorial` — that is by design for the stub; noted in Task 2 Step 8).
- `UIRouter` stores state of current panel — consistent across all method names (`Current`, `GoTo`, `RegisterPanel`). No rename drift.
- Plugin asmdef references section verified: Contracts + UniTask only.
- `Bootstrapper.Start()` log format is exact (`Boot OK — plugin='…', router current=…`) so Phase 1 grep/assertion can key on it if desired.
