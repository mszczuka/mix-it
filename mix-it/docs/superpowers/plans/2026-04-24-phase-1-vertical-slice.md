# Phase 1 — Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** End-to-end loop — Home → Matchmaking → Match (tap button, 50/50 win/lose) → Result (gold reward) → Home — with gold persisting across restarts.

**Architecture:** Three new service interfaces in `Archetype.Contracts` (`IWalletService`, `IFlowController`, `IMatchPanelView`); implementations in `Archetype.Runtime`; five panel `MonoBehaviour` views in `Archetype.UI`; plugin session upgraded to a real tap-button UI. VContainer wires everything via `GameLifetimeScope`. Gold persisted via `PlayerPrefs`.

**Tech Stack:** Unity 6.3, VContainer 1.16.9, UniTask 2.5.10, TextMeshPro, UnityEngine.UI (buttons/images), C# 9.

**Spec:** `../specs/2026-04-24-unity-port-archetype-plugin-design.md` — §4.4 plugin contract, §4.5 WalletService, §4.9 panel ownership, §4.10 DI, §6 Phase 1 done-criterion.

**Unity project root:** `D:\Projects\mix-it\MixIt`

---

## File structure overview

```
Assets/
├── _Archetype/
│   ├── Contracts/
│   │   ├── IWalletService.cs          (NEW)
│   │   ├── IFlowController.cs         (NEW)
│   │   └── IMatchPanelView.cs         (NEW)
│   ├── Runtime/
│   │   ├── WalletService.cs           (NEW)
│   │   └── FlowController.cs          (NEW)
│   └── UI/
│       ├── MixIt.Archetype.UI.asmdef  (MODIFY — add Unity.ugui + UniTask + Unity.TextMeshPro refs)
│       └── Panels/
│           ├── LoadingPanelView.cs    (NEW)
│           ├── HomePanelView.cs       (NEW)
│           ├── MatchmakingPanelView.cs(NEW)
│           ├── MatchPanelView.cs      (NEW)
│           └── ResultPanelView.cs     (NEW)
├── _Plugins/LiquidPuzzles/Runtime/
│   └── LiquidPuzzlesMatchSession.cs   (MODIFY — real tap-button UI)
├── _Game/Bootstrap/
│   └── GameLifetimeScope.cs           (MODIFY — register wallet, flow, panels)
└── _Tests/EditMode/
    └── WalletServiceTests.cs          (NEW)
```

---

## Task 1: Add contract interfaces — IWalletService, IFlowController, IMatchPanelView

**Files:**
- Create: `Assets/_Archetype/Contracts/IWalletService.cs`
- Create: `Assets/_Archetype/Contracts/IFlowController.cs`
- Create: `Assets/_Archetype/Contracts/IMatchPanelView.cs`

- [ ] **Step 1: Create `IWalletService.cs`**

Path: `Assets/_Archetype/Contracts/IWalletService.cs`

```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IWalletService
    {
        int Gold { get; }
        void AddGold(int amount);
        bool SpendGold(int amount);
        void Save();
        void Load();
    }
}
```

- [ ] **Step 2: Create `IFlowController.cs`**

Path: `Assets/_Archetype/Contracts/IFlowController.cs`

```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IFlowController
    {
        MatchResult LastResult { get; }
        int LastReward { get; }
        void GoHome();
        void RequestMatch();
        void StartMatch();
        void CompleteMatch(MatchResult result);
    }
}
```

- [ ] **Step 3: Create `IMatchPanelView.cs`**

Path: `Assets/_Archetype/Contracts/IMatchPanelView.cs`

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;

namespace MixIt.Archetype.Contracts
{
    public interface IMatchPanelView
    {
        UniTask<MatchResult> ShowMatch(IMatchSession session, CancellationToken ct);
    }
}
```

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Contracts/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(contracts): IWalletService, IFlowController, IMatchPanelView"
```

---

## Task 2: WalletService implementation + EditMode tests

**Files:**
- Create: `Assets/_Archetype/Runtime/WalletService.cs`
- Create: `Assets/_Tests/EditMode/WalletServiceTests.cs`

- [ ] **Step 1: Write failing tests first**

Path: `Assets/_Tests/EditMode/WalletServiceTests.cs`

```csharp
using MixIt.Archetype.Runtime;
using NUnit.Framework;

namespace MixIt.Archetype.Tests
{
    public class WalletServiceTests
    {
        WalletService _wallet;

        [SetUp]
        public void SetUp()
        {
            UnityEngine.PlayerPrefs.DeleteKey("wallet.gold");
            _wallet = new WalletService();
        }

        [TearDown]
        public void TearDown()
        {
            UnityEngine.PlayerPrefs.DeleteKey("wallet.gold");
        }

        [Test]
        public void Gold_StartsAtZero_WhenNoSavedData()
        {
            Assert.AreEqual(0, _wallet.Gold);
        }

        [Test]
        public void AddGold_IncreasesBalance()
        {
            _wallet.AddGold(100);
            Assert.AreEqual(100, _wallet.Gold);
        }

        [Test]
        public void SpendGold_DecreasesBalance_ReturnsTrue()
        {
            _wallet.AddGold(200);
            bool ok = _wallet.SpendGold(50);
            Assert.IsTrue(ok);
            Assert.AreEqual(150, _wallet.Gold);
        }

        [Test]
        public void SpendGold_InsufficientFunds_ReturnsFalse_BalanceUnchanged()
        {
            _wallet.AddGold(30);
            bool ok = _wallet.SpendGold(100);
            Assert.IsFalse(ok);
            Assert.AreEqual(30, _wallet.Gold);
        }

        [Test]
        public void SaveAndLoad_PersistsGold()
        {
            _wallet.AddGold(500);
            _wallet.Save();

            var wallet2 = new WalletService();
            wallet2.Load();
            Assert.AreEqual(500, wallet2.Gold);
        }
    }
}
```

- [ ] **Step 2: Run tests — expect FAIL (WalletService doesn't exist yet)**

Open Unity → Window → General → Test Runner → EditMode → Run All.
Expected: 5 compile errors / test failures.

- [ ] **Step 3: Create `WalletService.cs`**

Path: `Assets/_Archetype/Runtime/WalletService.cs`

```csharp
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Archetype.Runtime
{
    public class WalletService : IWalletService
    {
        const string GoldKey = "wallet.gold";

        public int Gold { get; private set; }

        public WalletService()
        {
            Load();
        }

        public void AddGold(int amount)
        {
            if (amount <= 0) return;
            Gold += amount;
        }

        public bool SpendGold(int amount)
        {
            if (amount > Gold) return false;
            Gold -= amount;
            return true;
        }

        public void Save() => PlayerPrefs.SetInt(GoldKey, Gold);

        public void Load() => Gold = PlayerPrefs.GetInt(GoldKey, 0);
    }
}
```

- [ ] **Step 4: Run tests — expect all 5 PASS**

Unity Test Runner → EditMode → Run All. Expected: 9 tests total (4 UIRouter + 5 Wallet), all green.

- [ ] **Step 5: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/WalletService.cs Assets/_Tests/EditMode/WalletServiceTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): WalletService — gold balance + PlayerPrefs persistence"
```

---

## Task 3: FlowController

**Files:**
- Create: `Assets/_Archetype/Runtime/FlowController.cs`

`FlowController` orchestrates screen transitions and match lifecycle. It implements `IStartable` so VContainer calls `Start()` after DI scope builds — this transitions from Loading to Home.

- [ ] **Step 1: Create `FlowController.cs`**

Path: `Assets/_Archetype/Runtime/FlowController.cs`

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using VContainer;
using VContainer.Unity;

namespace MixIt.Archetype.Runtime
{
    public class FlowController : IFlowController, IStartable
    {
        const int GoldOnWin = 100;
        const int GoldOnLoss = 25;

        readonly IUIRouter _router;
        readonly IPlugin _plugin;
        readonly IWalletService _wallet;
        readonly IMatchPanelView _matchPanel;
        CancellationTokenSource _matchCts;

        public MatchResult LastResult { get; private set; }
        public int LastReward { get; private set; }

        [Inject]
        public FlowController(IUIRouter router, IPlugin plugin, IWalletService wallet, IMatchPanelView matchPanel)
        {
            _router = router;
            _plugin = plugin;
            _wallet = wallet;
            _matchPanel = matchPanel;
        }

        public void Start() => GoHome();

        public void GoHome()
        {
            _router.GoTo(PanelId.Home).Forget();
        }

        public void RequestMatch()
        {
            _router.GoTo(PanelId.Matchmaking).Forget();
        }

        public void StartMatch()
        {
            _matchCts?.Cancel();
            _matchCts = new CancellationTokenSource();
            RunMatchAsync(_matchCts.Token).Forget();
        }

        async UniTaskVoid RunMatchAsync(CancellationToken ct)
        {
            var session = _plugin.StartMatch(new MatchRequest(UnityEngine.Random.Range(0, int.MaxValue)));
            await _router.GoTo(PanelId.Match);
            var result = await _matchPanel.ShowMatch(session, ct);
            CompleteMatch(result);
        }

        public void CompleteMatch(MatchResult result)
        {
            LastResult = result;
            LastReward = result.Win ? GoldOnWin : GoldOnLoss;
            _wallet.AddGold(LastReward);
            _wallet.Save();
            _router.GoTo(PanelId.Result).Forget();
        }
    }
}
```

- [ ] **Step 2: Verify compile (no Unity MCP needed — file edit only)**

Refresh Unity assets. Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/FlowController.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): FlowController — Loading→Home, match lifecycle, reward"
```

---

## Task 4: Update Archetype.UI asmdef and create panel views

**Files:**
- Modify: `Assets/_Archetype/UI/MixIt.Archetype.UI.asmdef`
- Modify: `Assets/_Archetype/UI/_Placeholder.cs` (delete — real files replace it)
- Create: `Assets/_Archetype/UI/Panels/LoadingPanelView.cs`
- Create: `Assets/_Archetype/UI/Panels/HomePanelView.cs`
- Create: `Assets/_Archetype/UI/Panels/MatchmakingPanelView.cs`
- Create: `Assets/_Archetype/UI/Panels/MatchPanelView.cs`
- Create: `Assets/_Archetype/UI/Panels/ResultPanelView.cs`

- [ ] **Step 1: Update `MixIt.Archetype.UI.asmdef`**

Path: `Assets/_Archetype/UI/MixIt.Archetype.UI.asmdef`

```json
{
    "name": "MixIt.Archetype.UI",
    "rootNamespace": "MixIt.Archetype.UI",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Archetype.Runtime",
        "UniTask",
        "VContainer",
        "Unity.ugui",
        "Unity.TextMeshPro"
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

- [ ] **Step 2: Create `LoadingPanelView.cs`**

Path: `Assets/_Archetype/UI/Panels/LoadingPanelView.cs`

```csharp
using UnityEngine;

namespace MixIt.Archetype.UI.Panels
{
    public class LoadingPanelView : MonoBehaviour
    {
        // Passive — FlowController.Start() handles transition to Home.
        // This panel is just a visual placeholder during DI boot.
    }
}
```

- [ ] **Step 3: Create `HomePanelView.cs`**

Path: `Assets/_Archetype/UI/Panels/HomePanelView.cs`

```csharp
using MixIt.Archetype.Contracts;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using VContainer;

namespace MixIt.Archetype.UI.Panels
{
    public class HomePanelView : MonoBehaviour
    {
        [SerializeField] TMP_Text _goldLabel;
        [SerializeField] Button _playButton;

        IFlowController _flow;
        IWalletService _wallet;

        [Inject]
        public void Construct(IFlowController flow, IWalletService wallet)
        {
            _flow = flow;
            _wallet = wallet;
        }

        void Start()
        {
            _playButton.onClick.AddListener(() => _flow.RequestMatch());
        }

        void OnEnable()
        {
            if (_wallet != null && _goldLabel != null)
                _goldLabel.text = $"Gold: {_wallet.Gold}";
        }
    }
}
```

- [ ] **Step 4: Create `MatchmakingPanelView.cs`**

Path: `Assets/_Archetype/UI/Panels/MatchmakingPanelView.cs`

```csharp
using System;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using UnityEngine;
using VContainer;

namespace MixIt.Archetype.UI.Panels
{
    public class MatchmakingPanelView : MonoBehaviour
    {
        IFlowController _flow;

        [Inject]
        public void Construct(IFlowController flow) => _flow = flow;

        void OnEnable()
        {
            WaitThenStart().Forget();
        }

        async UniTaskVoid WaitThenStart()
        {
            await UniTask.Delay(TimeSpan.FromSeconds(1.5f), cancellationToken: destroyCancellationToken);
            if (isActiveAndEnabled) _flow.StartMatch();
        }
    }
}
```

- [ ] **Step 5: Create `MatchPanelView.cs`**

Path: `Assets/_Archetype/UI/Panels/MatchPanelView.cs`

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Archetype.UI.Panels
{
    public class MatchPanelView : MonoBehaviour, IMatchPanelView
    {
        [SerializeField] RectTransform _contentParent;

        public async UniTask<MatchResult> ShowMatch(IMatchSession session, CancellationToken ct)
        {
            var root = session.SceneRoot;
            root.transform.SetParent(_contentParent, false);

            if (root.TryGetComponent<RectTransform>(out var rt))
            {
                rt.anchorMin = Vector2.zero;
                rt.anchorMax = Vector2.one;
                rt.offsetMin = rt.offsetMax = Vector2.zero;
            }

            var result = await session.Run(ct);

            Destroy(root);
            return result;
        }
    }
}
```

- [ ] **Step 6: Create `ResultPanelView.cs`**

Path: `Assets/_Archetype/UI/Panels/ResultPanelView.cs`

```csharp
using MixIt.Archetype.Contracts;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using VContainer;

namespace MixIt.Archetype.UI.Panels
{
    public class ResultPanelView : MonoBehaviour
    {
        [SerializeField] TMP_Text _outcomeLabel;
        [SerializeField] TMP_Text _rewardLabel;
        [SerializeField] Button _continueButton;

        IFlowController _flow;

        [Inject]
        public void Construct(IFlowController flow) => _flow = flow;

        void Start()
        {
            _continueButton.onClick.AddListener(() => _flow.GoHome());
        }

        void OnEnable()
        {
            if (_flow == null) return;
            var result = _flow.LastResult;
            if (result == null) return;
            if (_outcomeLabel != null) _outcomeLabel.text = result.Win ? "VICTORY!" : "DEFEAT";
            if (_rewardLabel != null) _rewardLabel.text = $"+{_flow.LastReward} Gold";
        }
    }
}
```

- [ ] **Step 7: Verify compile — refresh Unity assets**

Expected: 0 errors.

- [ ] **Step 8: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/UI/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype-ui): panel views — Home, Matchmaking, Match, Result, Loading"
```

---

## Task 5: Update LiquidPuzzlesMatchSession — real tap-button UI

**Files:**
- Modify: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs`

Replace the stub with a session that creates a button inside its `SceneRoot`. Player taps it → 50/50 win/lose.

- [ ] **Step 1: Update `LiquidPuzzlesMatchSession.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs`

```csharp
using System.Collections.Generic;
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace MixIt.Plugin.LiquidPuzzles
{
    public class LiquidPuzzlesMatchSession : IMatchSession
    {
        readonly UniTaskCompletionSource<MatchResult> _tcs = new();

        public GameObject SceneRoot { get; } = new GameObject("LiquidPuzzlesRoot");

        public async UniTask<MatchResult> Run(CancellationToken ct)
        {
            BuildUI();
            using var reg = ct.Register(() => _tcs.TrySetCanceled());
            return await _tcs.Task;
        }

        void BuildUI()
        {
            var rt = SceneRoot.AddComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = rt.offsetMax = Vector2.zero;

            var btnGo = new GameObject("TapButton");
            btnGo.transform.SetParent(SceneRoot.transform, false);
            var btnRt = btnGo.AddComponent<RectTransform>();
            btnRt.anchorMin = btnRt.anchorMax = new Vector2(0.5f, 0.5f);
            btnRt.sizeDelta = new Vector2(300, 100);
            var img = btnGo.AddComponent<Image>();
            img.color = new Color(0.2f, 0.6f, 1f);
            var btn = btnGo.AddComponent<Button>();
            btn.onClick.AddListener(OnTap);

            var labelGo = new GameObject("Label");
            labelGo.transform.SetParent(btnGo.transform, false);
            var txt = labelGo.AddComponent<TextMeshProUGUI>();
            txt.text = "TAP TO PLAY";
            txt.alignment = TextAlignmentOptions.Center;
            txt.color = Color.white;
            txt.fontSize = 24;
            var labelRt = txt.GetComponent<RectTransform>();
            labelRt.anchorMin = Vector2.zero;
            labelRt.anchorMax = Vector2.one;
            labelRt.offsetMin = labelRt.offsetMax = Vector2.zero;
        }

        void OnTap()
        {
            bool win = Random.value > 0.5f;
            _tcs.TrySetResult(new MatchResult(win, win ? 100 : 0, new Dictionary<string, float>()));
        }
    }
}
```

Note: `MixIt.Plugin.LiquidPuzzles.Runtime.asmdef` needs `Unity.ugui` reference for `UnityEngine.UI.Button`. Add it in the next step.

- [ ] **Step 2: Update `MixIt.Plugin.LiquidPuzzles.Runtime.asmdef`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/MixIt.Plugin.LiquidPuzzles.Runtime.asmdef`

```json
{
    "name": "MixIt.Plugin.LiquidPuzzles.Runtime",
    "rootNamespace": "MixIt.Plugin.LiquidPuzzles",
    "references": [
        "MixIt.Archetype.Contracts",
        "UniTask",
        "Unity.ugui",
        "Unity.TextMeshPro"
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

- [ ] **Step 3: Verify compile**

Expected: 0 errors.

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin): liquid-puzzles real match session — tap button, 50/50 result"
```

---

## Task 6: Update GameLifetimeScope — register new services and panels

**Files:**
- Modify: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`

- [ ] **Step 1: Update `GameLifetimeScope.cs`**

Path: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`

```csharp
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime;
using MixIt.Archetype.Runtime.UI;
using MixIt.Archetype.UI.Panels;
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
            // Core archetype services
            builder.Register<UIRouter>(Lifetime.Singleton).As<IUIRouter>();
            builder.Register<WalletService>(Lifetime.Singleton).As<IWalletService>();
            builder.Register<FlowController>(Lifetime.Singleton).As<IFlowController>().AsSelf();
            builder.RegisterEntryPoint<FlowController>(Lifetime.Singleton);

            // Plugin
            builder.Register<LiquidPuzzlesPlugin>(Lifetime.Singleton).As<IPlugin>();

            // Panel views (MonoBehaviours in scene — VContainer injects into them)
            builder.RegisterComponentInHierarchy<HomePanelView>();
            builder.RegisterComponentInHierarchy<MatchmakingPanelView>();
            builder.RegisterComponentInHierarchy<MatchPanelView>().As<IMatchPanelView>();
            builder.RegisterComponentInHierarchy<ResultPanelView>();
            builder.RegisterComponentInHierarchy<LoadingPanelView>();

            // Bootstrapper (smoke-test log)
            builder.RegisterEntryPoint<Bootstrapper>();

            // Wire panels into UIRouter after scope builds
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

Note: `FlowController` is registered both as `IFlowController` (for injection) and as an entry point (so VContainer calls `Start()`). The `.AsSelf()` call allows the internal cast in `RegisterBuildCallback` if needed, but `FlowController` is now resolved via `IFlowController`. Adjust if VContainer reports duplicate registration — alternative: use `builder.Register<FlowController>(Lifetime.Singleton).As<IFlowController, IStartable>()`.

Also note `MixIt.Game.asmdef` needs `MixIt.Archetype.UI` added to references since it now uses panel view types.

- [ ] **Step 2: Update `MixIt.Game.asmdef`**

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
        "UniTask"
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

- [ ] **Step 3: Verify compile — refresh Unity**

Expected: 0 errors.

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Game/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(game): wire WalletService, FlowController, panel views into DI scope"
```

---

## Task 7: Scene wiring via Unity MCP

This task uses Unity MCP tools (`editor_execute_code`) to:
1. Add panel MonoBehaviour components to existing scene GameObjects
2. Create minimal UI (Text label + Button) on each panel
3. Wire serialized references on MatchPanelView (`_contentParent`)
4. Save scene

All work done via `editor_execute_code` with usings `["UnityEditor.SceneManagement", "UnityEngine.UI", "MixIt.Archetype.UI.Panels"]`.

- [ ] **Step 1: Add panel MonoBehaviour components + create UI**

Run via Unity MCP `editor_execute_code`:

```csharp
var scene = EditorSceneManager.OpenScene("Assets/_Game/Scenes/Main.unity", OpenSceneMode.Single);

// Helper
UnityEngine.GameObject Find(string path) => UnityEngine.GameObject.Find(path);

// --- HomePanel ---
var homeGo = Find("MainCanvas/ContentRoot/HomePanel");
var homeView = homeGo.AddComponent<MixIt.Archetype.UI.Panels.HomePanelView>();

// Gold label
var goldLabelGo = new UnityEngine.GameObject("GoldLabel");
goldLabelGo.transform.SetParent(homeGo.transform, false);
var goldRt = goldLabelGo.AddComponent<UnityEngine.RectTransform>();
goldRt.anchorMin = new UnityEngine.Vector2(0, 0.7f);
goldRt.anchorMax = new UnityEngine.Vector2(1, 0.9f);
goldRt.offsetMin = goldRt.offsetMax = UnityEngine.Vector2.zero;
var goldTxt = goldLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
goldTxt.text = "Gold: 0";
goldTxt.alignment = TMPro.TextAlignmentOptions.Center;
goldTxt.fontSize = 36;
goldTxt.color = UnityEngine.Color.white;

// Play button
var playBtnGo = new UnityEngine.GameObject("PlayButton");
playBtnGo.transform.SetParent(homeGo.transform, false);
var playBtnRt = playBtnGo.AddComponent<UnityEngine.RectTransform>();
playBtnRt.anchorMin = new UnityEngine.Vector2(0.25f, 0.35f);
playBtnRt.anchorMax = new UnityEngine.Vector2(0.75f, 0.55f);
playBtnRt.offsetMin = playBtnRt.offsetMax = UnityEngine.Vector2.zero;
var playImg = playBtnGo.AddComponent<UnityEngine.UI.Image>();
playImg.color = new UnityEngine.Color(0.2f, 0.7f, 0.3f);
var playBtn = playBtnGo.AddComponent<UnityEngine.UI.Button>();
var playLabelGo = new UnityEngine.GameObject("Label");
playLabelGo.transform.SetParent(playBtnGo.transform, false);
var playTxt = playLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
playTxt.text = "PLAY";
playTxt.alignment = TMPro.TextAlignmentOptions.Center;
playTxt.fontSize = 32;
playTxt.color = UnityEngine.Color.white;
var playLabelRt = playTxt.GetComponent<UnityEngine.RectTransform>();
playLabelRt.anchorMin = UnityEngine.Vector2.zero;
playLabelRt.anchorMax = UnityEngine.Vector2.one;
playLabelRt.offsetMin = playLabelRt.offsetMax = UnityEngine.Vector2.zero;

// Wire serialized fields on HomePanelView via SerializedObject
var soHome = new UnityEditor.SerializedObject(homeView);
soHome.FindProperty("_goldLabel").objectReferenceValue = goldTxt;
soHome.FindProperty("_playButton").objectReferenceValue = playBtn;
soHome.ApplyModifiedProperties();

// --- MatchmakingPanel ---
var mmGo = Find("MainCanvas/ContentRoot/MatchmakingPanel");
mmGo.AddComponent<MixIt.Archetype.UI.Panels.MatchmakingPanelView>();
var mmLabelGo = new UnityEngine.GameObject("StatusLabel");
mmLabelGo.transform.SetParent(mmGo.transform, false);
var mmRt = mmLabelGo.AddComponent<UnityEngine.RectTransform>();
mmRt.anchorMin = new UnityEngine.Vector2(0.1f, 0.4f);
mmRt.anchorMax = new UnityEngine.Vector2(0.9f, 0.6f);
mmRt.offsetMin = mmRt.offsetMax = UnityEngine.Vector2.zero;
var mmTxt = mmLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
mmTxt.text = "Finding opponent...";
mmTxt.alignment = TMPro.TextAlignmentOptions.Center;
mmTxt.fontSize = 28;
mmTxt.color = UnityEngine.Color.white;

// --- MatchPanel ---
var matchGo = Find("MainCanvas/ContentRoot/MatchPanel");
var matchView = matchGo.AddComponent<MixIt.Archetype.UI.Panels.MatchPanelView>();
// Content parent: an empty child that fills the match panel
var contentGo = new UnityEngine.GameObject("PluginContent");
contentGo.transform.SetParent(matchGo.transform, false);
var contentRt = contentGo.AddComponent<UnityEngine.RectTransform>();
contentRt.anchorMin = UnityEngine.Vector2.zero;
contentRt.anchorMax = UnityEngine.Vector2.one;
contentRt.offsetMin = contentRt.offsetMax = UnityEngine.Vector2.zero;
var soMatch = new UnityEditor.SerializedObject(matchView);
soMatch.FindProperty("_contentParent").objectReferenceValue = contentRt;
soMatch.ApplyModifiedProperties();

// --- ResultPanel ---
var resultGo = Find("MainCanvas/ContentRoot/ResultPanel");
var resultView = resultGo.AddComponent<MixIt.Archetype.UI.Panels.ResultPanelView>();

var outcomeLabelGo = new UnityEngine.GameObject("OutcomeLabel");
outcomeLabelGo.transform.SetParent(resultGo.transform, false);
var outcomeRt = outcomeLabelGo.AddComponent<UnityEngine.RectTransform>();
outcomeRt.anchorMin = new UnityEngine.Vector2(0, 0.65f);
outcomeRt.anchorMax = new UnityEngine.Vector2(1, 0.85f);
outcomeRt.offsetMin = outcomeRt.offsetMax = UnityEngine.Vector2.zero;
var outcomeTxt = outcomeLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
outcomeTxt.text = "RESULT";
outcomeTxt.alignment = TMPro.TextAlignmentOptions.Center;
outcomeTxt.fontSize = 48;
outcomeTxt.color = UnityEngine.Color.yellow;

var rewardLabelGo = new UnityEngine.GameObject("RewardLabel");
rewardLabelGo.transform.SetParent(resultGo.transform, false);
var rewardRt = rewardLabelGo.AddComponent<UnityEngine.RectTransform>();
rewardRt.anchorMin = new UnityEngine.Vector2(0, 0.45f);
rewardRt.anchorMax = new UnityEngine.Vector2(1, 0.62f);
rewardRt.offsetMin = rewardRt.offsetMax = UnityEngine.Vector2.zero;
var rewardTxt = rewardLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
rewardTxt.text = "+0 Gold";
rewardTxt.alignment = TMPro.TextAlignmentOptions.Center;
rewardTxt.fontSize = 32;
rewardTxt.color = UnityEngine.Color.white;

var contBtnGo = new UnityEngine.GameObject("ContinueButton");
contBtnGo.transform.SetParent(resultGo.transform, false);
var contBtnRt = contBtnGo.AddComponent<UnityEngine.RectTransform>();
contBtnRt.anchorMin = new UnityEngine.Vector2(0.25f, 0.2f);
contBtnRt.anchorMax = new UnityEngine.Vector2(0.75f, 0.38f);
contBtnRt.offsetMin = contBtnRt.offsetMax = UnityEngine.Vector2.zero;
var contImg = contBtnGo.AddComponent<UnityEngine.UI.Image>();
contImg.color = new UnityEngine.Color(0.8f, 0.4f, 0.1f);
var contBtn = contBtnGo.AddComponent<UnityEngine.UI.Button>();
var contLabelGo = new UnityEngine.GameObject("Label");
contLabelGo.transform.SetParent(contBtnGo.transform, false);
var contTxt = contLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
contTxt.text = "CONTINUE";
contTxt.alignment = TMPro.TextAlignmentOptions.Center;
contTxt.fontSize = 28;
contTxt.color = UnityEngine.Color.white;
var contLabelRt = contTxt.GetComponent<UnityEngine.RectTransform>();
contLabelRt.anchorMin = UnityEngine.Vector2.zero;
contLabelRt.anchorMax = UnityEngine.Vector2.one;
contLabelRt.offsetMin = contLabelRt.offsetMax = UnityEngine.Vector2.zero;

var soResult = new UnityEditor.SerializedObject(resultView);
soResult.FindProperty("_outcomeLabel").objectReferenceValue = outcomeTxt;
soResult.FindProperty("_rewardLabel").objectReferenceValue = rewardTxt;
soResult.FindProperty("_continueButton").objectReferenceValue = contBtn;
soResult.ApplyModifiedProperties();

// --- LoadingPanel ---
var loadingGo = Find("MainCanvas/ContentRoot/LoadingPanel");
loadingGo.AddComponent<MixIt.Archetype.UI.Panels.LoadingPanelView>();
var loadingLabelGo = new UnityEngine.GameObject("Label");
loadingLabelGo.transform.SetParent(loadingGo.transform, false);
var loadingRt = loadingLabelGo.AddComponent<UnityEngine.RectTransform>();
loadingRt.anchorMin = new UnityEngine.Vector2(0.1f, 0.4f);
loadingRt.anchorMax = new UnityEngine.Vector2(0.9f, 0.6f);
loadingRt.offsetMin = loadingRt.offsetMax = UnityEngine.Vector2.zero;
var loadingTxt = loadingLabelGo.AddComponent<TMPro.TextMeshProUGUI>();
loadingTxt.text = "Loading...";
loadingTxt.alignment = TMPro.TextAlignmentOptions.Center;
loadingTxt.fontSize = 28;
loadingTxt.color = UnityEngine.Color.white;

EditorSceneManager.SaveScene(UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene());
return "Scene wiring done";
```

- [ ] **Step 2: Verify scene — check hierarchy in Unity**

In Unity Hierarchy: HomePanel should have `HomePanelView` component with `_goldLabel` and `_playButton` wired. MatchPanel should have `MatchPanelView` with `_contentParent` wired. ResultPanel should have all three refs wired.

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Game/Scenes/Main.unity
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(scene): add panel views + UI to Main scene — Home, Matchmaking, Match, Result, Loading"
```

---

## Task 8: Fix FlowController VContainer registration + smoke test

VContainer does not allow registering the same instance as both `IFlowController` and `IStartable` via two separate `Register` calls. The correct pattern is a single registration with multiple interfaces.

- [ ] **Step 1: Verify GameLifetimeScope compiles and check for VContainer registration errors**

Enter Play mode. Check Console. If you see `VContainerException: Type FlowController is already registered`, update `GameLifetimeScope.Configure` to use:

```csharp
builder.Register<FlowController>(Lifetime.Singleton)
    .As<IFlowController>()
    .As<IStartable>();
```

And remove the separate `builder.RegisterEntryPoint<FlowController>()` line. Also remove the duplicate `builder.RegisterEntryPoint<Bootstrapper>()` if FlowController's `Start()` already handles flow.

Final `Configure` method (reference — only apply if duplicates exist):

```csharp
protected override void Configure(IContainerBuilder builder)
{
    builder.Register<UIRouter>(Lifetime.Singleton).As<IUIRouter>();
    builder.Register<WalletService>(Lifetime.Singleton).As<IWalletService>();
    builder.Register<FlowController>(Lifetime.Singleton).As<IFlowController>().As<IStartable>();

    builder.Register<LiquidPuzzlesPlugin>(Lifetime.Singleton).As<IPlugin>();

    builder.RegisterComponentInHierarchy<HomePanelView>();
    builder.RegisterComponentInHierarchy<MatchmakingPanelView>();
    builder.RegisterComponentInHierarchy<MatchPanelView>().As<IMatchPanelView>();
    builder.RegisterComponentInHierarchy<ResultPanelView>();
    builder.RegisterComponentInHierarchy<LoadingPanelView>();

    builder.RegisterEntryPoint<Bootstrapper>();

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
```

- [ ] **Step 2: Enter Play mode — full smoke test**

Expected sequence:
1. "Loading..." panel shows briefly
2. HomePanel shows with "Gold: 0" and "PLAY" button
3. Tap PLAY → MatchmakingPanel shows "Finding opponent..." for ~1.5s
4. MatchPanel shows with a blue "TAP TO PLAY" button
5. Tap it → ResultPanel shows "VICTORY!" or "DEFEAT" + "+100 Gold" or "+25 Gold"
6. Tap CONTINUE → HomePanel shows with updated gold (100 or 25)
7. Exit Play mode, re-enter Play mode → gold counter should persist

- [ ] **Step 3: Verify gold persistence**

In step 7 above, note the gold value after first match. Re-enter Play mode. HomePanel should show the same gold value. If PlayerPrefs don't persist between Editor play sessions by default, this is expected behavior — the real test is a full editor restart or checking `PlayerPrefs.GetInt("wallet.gold")` in Console.

- [ ] **Step 4: Run all EditMode tests**

Unity Test Runner → EditMode → Run All. Expected: 9 tests pass (4 UIRouter + 5 WalletService).

- [ ] **Step 5: Commit any fixes**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(game): Phase 1 vertical slice complete — Home→Match→Result→Home loop"
```

---

## Task 9: Phase 1 done-criterion checklist + completion note

- [ ] **Step 1: Run all gates**

1. Unity Test Runner: 9 tests pass (0 failed).
2. Play mode: Home → Matchmaking → Match (tap button) → Result → Home loop completes without exceptions.
3. Gold counter increments correctly (+100 win / +25 loss).
4. Gold persists across Play mode sessions (PlayerPrefs verified).
5. Console: no red errors during full loop.
6. `MixIt.Plugin.LiquidPuzzles.Runtime.asmdef` references: `MixIt.Archetype.Contracts`, `UniTask`, `Unity.ugui` — **no** `MixIt.Archetype.Runtime` or `MixIt.Archetype.UI`.

- [ ] **Step 2: Write completion note**

Path: `Assets/_Game/PHASE_1_DONE.md`

```markdown
# Phase 1 complete

- WalletService: gold balance, PlayerPrefs persistence.
- FlowController: Loading→Home boot, Home→Matchmaking→Match→Result→Home loop.
- LiquidPuzzlesPlugin: real tap-button match session, 50/50 win/lose.
- Five panel views wired via VContainer field injection.
- Gold reward on match complete (+100 win / +25 loss), persists across restarts.
- EditMode tests: 9/9 green.
- Plugin boundary maintained: no Archetype.Runtime/UI refs in plugin asmdef.

Ready for Phase 2: full Liquid Puzzles gameplay to v7.5 fidelity.
```

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Game/PHASE_1_DONE.md
git -C "D:/Projects/mix-it/MixIt" commit -m "docs: Phase 1 complete"
```

---

## Appendix — troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `VContainerException: already registered` for FlowController | Registered as both IStartable via RegisterEntryPoint and IFlowController separately | Use single `.As<IFlowController>().As<IStartable>()` chain (Task 8 Step 1) |
| `RegisterComponentInHierarchy` throws "not found" | Panel MonoBehaviour not attached to scene GO yet | Task 7 must run before Play mode |
| MatchmakingPanel shows but never proceeds | `destroyCancellationToken` not available in Unity < 2022 | Replace with `this.GetCancellationTokenOnDestroy()` (UniTask extension) |
| "TAP TO PLAY" button doesn't show | `_contentParent` not wired on MatchPanelView | Check Inspector: MatchPanelView._contentParent should point to PluginContent RectTransform |
| Gold always resets to 0 | WalletService constructor calls Load() before PlayerPrefs key is set | Expected on first run — gold 0 is correct default |
| TMP text invisible | TMP Essentials not imported | Window → TextMeshPro → Import TMP Essential Resources |
