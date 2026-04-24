# Phase 2 — Liquid Puzzles Match Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a playable 90s bartender PvP match with customer queue, pour/serve mechanics, simulated opponent, and matchmaking avatar carousel — all inside the LiquidPuzzles plugin boundary.

**Architecture:** Pure-C# Model layer (engine-agnostic, EditMode-testable) with Unity UI View layer on top. Archetype defines `IMatchIntroPresenter` contract; plugin supplies themed implementation. MatchSession orchestrates model ticks, view updates, and AI simulation via a UniTask-driven clock.

**Tech Stack:** Unity 6.3, VContainer 1.16.9, UniTask 2.5.10, TextMeshPro, UnityEngine.UI, C# 9.

**Spec:** `docs/superpowers/specs/2026-04-24-phase-2-liquid-puzzles-match-design.md`

**Unity project root:** `D:\Projects\mix-it\MixIt`

---

## File structure overview

```
Assets/
├── _Archetype/
│   ├── Contracts/
│   │   └── IMatchIntroPresenter.cs                (NEW)
│   └── Runtime/
│       ├── DefaultMatchIntroPresenter.cs          (NEW)
│       └── MixIt.Archetype.Runtime.asmdef          (MODIFY — add Unity.TextMeshPro + UGUI for default impl)
├── _Archetype/UI/Panels/
│   └── MatchmakingPanelView.cs                     (MODIFY — inject IMatchIntroPresenter)
├── _Plugins/LiquidPuzzles/
│   ├── Runtime/
│   │   ├── LiquidPuzzlesPlugin.cs                  (MODIFY — expose arena + config)
│   │   ├── LiquidPuzzlesMatchSession.cs            (REWRITE — real orchestration)
│   │   ├── MixIt.Plugin.LiquidPuzzles.Runtime.asmdef (already correct)
│   │   ├── Model/
│   │   │   ├── LayerColor.cs                       (NEW)
│   │   │   ├── Glass.cs                            (NEW)
│   │   │   ├── PourRules.cs                        (NEW)
│   │   │   ├── Customer.cs                         (NEW)
│   │   │   ├── CustomerQueue.cs                    (NEW)
│   │   │   └── MatchState.cs                       (NEW)
│   │   ├── Simulation/
│   │   │   ├── OpponentAI.cs                       (NEW)
│   │   │   └── MatchClock.cs                       (NEW)
│   │   ├── Config/
│   │   │   ├── MatchConfig.cs                      (NEW — plain C# data class for Phase 2)
│   │   │   ├── ArenaProfile.cs                     (NEW)
│   │   │   └── CustomerPersona.cs                  (NEW)
│   │   └── Avatar/
│   │       └── LiquidPuzzlesIntroPresenter.cs      (NEW)
│   └── UI/
│       ├── MixIt.Plugin.LiquidPuzzles.UI.asmdef    (MODIFY — add Runtime ref)
│       ├── MatchBoardView.cs                       (NEW)
│       ├── GlassView.cs                            (NEW)
│       ├── CustomerQueueView.cs                    (NEW)
│       └── MatchHudView.cs                         (NEW)
├── _Game/Bootstrap/
│   └── GameLifetimeScope.cs                        (MODIFY — register intro presenter)
└── _Tests/EditMode/
    ├── MixIt.Archetype.Tests.asmdef                (keep — existing tests)
    └── Plugin/
        ├── MixIt.Plugin.LiquidPuzzles.Tests.asmdef (NEW)
        ├── GlassTests.cs                           (NEW)
        ├── PourRulesTests.cs                       (NEW)
        ├── CustomerQueueTests.cs                   (NEW)
        ├── MatchStateTests.cs                      (NEW)
        └── OpponentAITests.cs                      (NEW)
```

---

## Task 1: Model foundation — LayerColor, Glass, PourRules

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/LayerColor.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/Glass.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/PourRules.cs`
- Create: `Assets/_Tests/EditMode/Plugin/MixIt.Plugin.LiquidPuzzles.Tests.asmdef`
- Create: `Assets/_Tests/EditMode/Plugin/GlassTests.cs`
- Create: `Assets/_Tests/EditMode/Plugin/PourRulesTests.cs`

- [ ] **Step 1: Create plugin tests asmdef**

Path: `Assets/_Tests/EditMode/Plugin/MixIt.Plugin.LiquidPuzzles.Tests.asmdef`

```json
{
    "name": "MixIt.Plugin.LiquidPuzzles.Tests",
    "rootNamespace": "MixIt.Plugin.LiquidPuzzles.Tests",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Plugin.LiquidPuzzles.Runtime",
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner",
        "UniTask"
    ],
    "includePlatforms": ["Editor"],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": true,
    "precompiledReferences": ["nunit.framework.dll"],
    "autoReferenced": false,
    "defineConstraints": ["UNITY_INCLUDE_TESTS"],
    "versionDefines": [],
    "noEngineReferences": false
}
```

- [ ] **Step 2: Create `LayerColor.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/LayerColor.cs`

```csharp
namespace MixIt.Plugin.LiquidPuzzles.Model
{
    public enum LayerColor
    {
        Red,
        Blue,
        Yellow,
        Green,
        Purple,
        Orange,
        Pink,
        Teal
    }
}
```

- [ ] **Step 3: Write failing Glass tests**

Path: `Assets/_Tests/EditMode/Plugin/GlassTests.cs`

```csharp
using MixIt.Plugin.LiquidPuzzles.Model;
using NUnit.Framework;

namespace MixIt.Plugin.LiquidPuzzles.Tests
{
    public class GlassTests
    {
        [Test]
        public void NewGlass_IsEmpty()
        {
            var g = new Glass(4);
            Assert.IsTrue(g.IsEmpty);
            Assert.IsFalse(g.IsFull);
            Assert.AreEqual(0, g.Count);
        }

        [Test]
        public void Push_IncreasesCountAndTop()
        {
            var g = new Glass(4);
            g.Push(LayerColor.Red);
            g.Push(LayerColor.Blue);
            Assert.AreEqual(2, g.Count);
            Assert.AreEqual(LayerColor.Blue, g.Top);
        }

        [Test]
        public void Pop_ReturnsTopAndDecreasesCount()
        {
            var g = new Glass(4);
            g.Push(LayerColor.Red);
            g.Push(LayerColor.Blue);
            var popped = g.Pop();
            Assert.AreEqual(LayerColor.Blue, popped);
            Assert.AreEqual(1, g.Count);
            Assert.AreEqual(LayerColor.Red, g.Top);
        }

        [Test]
        public void IsFull_WhenAtCapacity()
        {
            var g = new Glass(2);
            g.Push(LayerColor.Red);
            g.Push(LayerColor.Red);
            Assert.IsTrue(g.IsFull);
        }

        [Test]
        public void IsServeable_OnlyWhenFullAndMonochrome()
        {
            var g = new Glass(3);
            g.Push(LayerColor.Red);
            g.Push(LayerColor.Red);
            Assert.IsFalse(g.IsServeable, "not full yet");
            g.Push(LayerColor.Red);
            Assert.IsTrue(g.IsServeable, "full and pure");
        }

        [Test]
        public void IsServeable_False_WhenFullButMixed()
        {
            var g = new Glass(3);
            g.Push(LayerColor.Red);
            g.Push(LayerColor.Blue);
            g.Push(LayerColor.Red);
            Assert.IsFalse(g.IsServeable);
        }

        [Test]
        public void Clear_EmptiesGlass()
        {
            var g = new Glass(4);
            g.Push(LayerColor.Red);
            g.Push(LayerColor.Red);
            g.Clear();
            Assert.IsTrue(g.IsEmpty);
        }
    }
}
```

- [ ] **Step 4: Run tests — expect 7 FAIL (Glass missing)**

Unity Test Runner → EditMode → Run All. Or via Unity MCP `test_run` with EditMode.
Expected: compile error OR 7 failures referencing Glass.

- [ ] **Step 5: Create `Glass.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/Glass.cs`

```csharp
using System.Collections.Generic;

namespace MixIt.Plugin.LiquidPuzzles.Model
{
    public sealed class Glass
    {
        readonly List<LayerColor> _layers;

        public Glass(int capacity)
        {
            Capacity = capacity;
            _layers = new List<LayerColor>(capacity);
        }

        public int Capacity { get; }
        public int Count => _layers.Count;
        public bool IsEmpty => _layers.Count == 0;
        public bool IsFull => _layers.Count >= Capacity;
        public LayerColor Top => _layers[_layers.Count - 1];
        public IReadOnlyList<LayerColor> Layers => _layers;

        public bool IsServeable
        {
            get
            {
                if (!IsFull) return false;
                var c = _layers[0];
                for (int i = 1; i < _layers.Count; i++)
                    if (_layers[i] != c) return false;
                return true;
            }
        }

        public void Push(LayerColor color)
        {
            if (IsFull) throw new System.InvalidOperationException("Glass is full");
            _layers.Add(color);
        }

        public LayerColor Pop()
        {
            if (IsEmpty) throw new System.InvalidOperationException("Glass is empty");
            var top = _layers[_layers.Count - 1];
            _layers.RemoveAt(_layers.Count - 1);
            return top;
        }

        public void Clear() => _layers.Clear();
    }
}
```

- [ ] **Step 6: Run tests — expect 7 PASS**

- [ ] **Step 7: Write failing PourRules tests**

Path: `Assets/_Tests/EditMode/Plugin/PourRulesTests.cs`

```csharp
using MixIt.Plugin.LiquidPuzzles.Model;
using NUnit.Framework;

namespace MixIt.Plugin.LiquidPuzzles.Tests
{
    public class PourRulesTests
    {
        [Test]
        public void CanPour_False_WhenSourceEmpty()
        {
            var src = new Glass(4);
            var dst = new Glass(4);
            dst.Push(LayerColor.Red);
            Assert.IsFalse(PourRules.CanPour(src, dst));
        }

        [Test]
        public void CanPour_False_WhenTargetFull()
        {
            var src = new Glass(4);
            src.Push(LayerColor.Red);
            var dst = new Glass(2);
            dst.Push(LayerColor.Red);
            dst.Push(LayerColor.Red);
            Assert.IsFalse(PourRules.CanPour(src, dst));
        }

        [Test]
        public void CanPour_False_WhenColorsMismatch()
        {
            var src = new Glass(4);
            src.Push(LayerColor.Red);
            var dst = new Glass(4);
            dst.Push(LayerColor.Blue);
            Assert.IsFalse(PourRules.CanPour(src, dst));
        }

        [Test]
        public void CanPour_True_WhenTargetEmpty()
        {
            var src = new Glass(4);
            src.Push(LayerColor.Red);
            var dst = new Glass(4);
            Assert.IsTrue(PourRules.CanPour(src, dst));
        }

        [Test]
        public void CanPour_True_WhenTopColorsMatch()
        {
            var src = new Glass(4);
            src.Push(LayerColor.Blue);
            src.Push(LayerColor.Red);
            var dst = new Glass(4);
            dst.Push(LayerColor.Red);
            Assert.IsTrue(PourRules.CanPour(src, dst));
        }

        [Test]
        public void ApplyPour_MovesTopLayer()
        {
            var src = new Glass(4);
            src.Push(LayerColor.Blue);
            src.Push(LayerColor.Red);
            var dst = new Glass(4);
            PourRules.ApplyPour(src, dst);
            Assert.AreEqual(1, src.Count);
            Assert.AreEqual(LayerColor.Blue, src.Top);
            Assert.AreEqual(1, dst.Count);
            Assert.AreEqual(LayerColor.Red, dst.Top);
        }
    }
}
```

- [ ] **Step 8: Create `PourRules.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/PourRules.cs`

```csharp
namespace MixIt.Plugin.LiquidPuzzles.Model
{
    public static class PourRules
    {
        public static bool CanPour(Glass source, Glass target)
        {
            if (source.IsEmpty) return false;
            if (target.IsFull) return false;
            if (target.IsEmpty) return true;
            return source.Top == target.Top;
        }

        public static void ApplyPour(Glass source, Glass target)
        {
            if (!CanPour(source, target))
                throw new System.InvalidOperationException("Invalid pour");
            target.Push(source.Pop());
        }
    }
}
```

- [ ] **Step 9: Run all tests — expect 13 PASS (7 Glass + 6 PourRules + existing 11 = 24 total)**

- [ ] **Step 10: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Model/ Assets/_Tests/EditMode/Plugin/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-model): LayerColor, Glass, PourRules + tests"
```

---

## Task 2: Customer + CustomerQueue model

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/Customer.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/CustomerQueue.cs`
- Create: `Assets/_Tests/EditMode/Plugin/CustomerQueueTests.cs`

- [ ] **Step 1: Write failing tests**

Path: `Assets/_Tests/EditMode/Plugin/CustomerQueueTests.cs`

```csharp
using MixIt.Plugin.LiquidPuzzles.Model;
using NUnit.Framework;

namespace MixIt.Plugin.LiquidPuzzles.Tests
{
    public class CustomerQueueTests
    {
        static readonly LayerColor[] Palette = {
            LayerColor.Red, LayerColor.Blue, LayerColor.Yellow, LayerColor.Green
        };

        [Test]
        public void StartsWith_ThreeVisibleCustomers()
        {
            var q = new CustomerQueue(seed: 42, palette: Palette);
            Assert.AreEqual(3, q.Visible.Count);
        }

        [Test]
        public void Tick_DecaysPatienceAfterGrace()
        {
            var q = new CustomerQueue(seed: 42, palette: Palette);
            var firstPatience = q.Visible[0].Patience;
            q.Tick(3f); // past 2s grace
            Assert.Less(q.Visible[0].Patience, firstPatience);
        }

        [Test]
        public void Tick_DoesNotDecayDuringGrace()
        {
            var q = new CustomerQueue(seed: 42, palette: Palette);
            var firstPatience = q.Visible[0].Patience;
            q.Tick(1f); // within grace
            Assert.AreEqual(firstPatience, q.Visible[0].Patience, 0.01f);
        }

        [Test]
        public void Tick_WalkawayIncrementsCounter()
        {
            var q = new CustomerQueue(seed: 42, palette: Palette);
            q.Tick(100f); // exceed all patience
            Assert.Greater(q.Walkaways, 0);
        }

        [Test]
        public void TryServe_ReturnsSlotIndex_WhenColorMatches()
        {
            var q = new CustomerQueue(seed: 42, palette: Palette);
            var color = q.Visible[1].Order;
            int slot = q.TryServe(color);
            Assert.AreEqual(1, slot);
        }

        [Test]
        public void TryServe_ReturnsNegativeOne_WhenNoMatch()
        {
            var paletteSingle = new[] { LayerColor.Red };
            var q = new CustomerQueue(seed: 42, palette: paletteSingle);
            int slot = q.TryServe(LayerColor.Teal);
            Assert.AreEqual(-1, slot);
        }

        [Test]
        public void TryServe_AdvancesQueue()
        {
            var q = new CustomerQueue(seed: 42, palette: Palette);
            var initialVisible = new[] {
                q.Visible[0].Order, q.Visible[1].Order, q.Visible[2].Order
            };
            q.TryServe(q.Visible[0].Order);
            Assert.AreNotSame(initialVisible[0], q.Visible[0].Order == initialVisible[0] ? (object)null : initialVisible[0]);
            // at minimum, visible slot 0 is a new customer object (different patience reset)
            Assert.AreEqual(3, q.Visible.Count);
        }
    }
}
```

- [ ] **Step 2: Create `Customer.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/Customer.cs`

```csharp
namespace MixIt.Plugin.LiquidPuzzles.Model
{
    public sealed class Customer
    {
        public LayerColor Order { get; }
        public float Patience { get; set; }
        public float GraceRemaining { get; set; }

        public Customer(LayerColor order, float patience, float grace)
        {
            Order = order;
            Patience = patience;
            GraceRemaining = grace;
        }
    }
}
```

- [ ] **Step 3: Create `CustomerQueue.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/CustomerQueue.cs`

```csharp
using System.Collections.Generic;

namespace MixIt.Plugin.LiquidPuzzles.Model
{
    public sealed class CustomerQueue
    {
        public const int VisibleSlots = 3;
        public const float CustomerPatience = 24f;
        public const float GraceWindow = 2f;
        public const float SpawnRechargeTime = 1f;
        public const int MaxQueue = 12;
        public const int PreCharged = 5;

        readonly List<Customer> _visible = new(VisibleSlots);
        readonly Queue<Customer> _spawnBuffer = new();
        readonly System.Random _rng;
        readonly LayerColor[] _palette;
        float _spawnTimer;

        public CustomerQueue(int seed, LayerColor[] palette)
        {
            _rng = new System.Random(seed);
            _palette = palette;
            for (int i = 0; i < VisibleSlots; i++)
                _visible.Add(SpawnCustomer());
            for (int i = 0; i < PreCharged; i++)
                _spawnBuffer.Enqueue(SpawnCustomer());
        }

        public IReadOnlyList<Customer> Visible => _visible;
        public int Walkaways { get; private set; }

        public void Tick(float dt)
        {
            for (int i = 0; i < _visible.Count; i++)
            {
                var c = _visible[i];
                if (c.GraceRemaining > 0f)
                {
                    c.GraceRemaining -= dt;
                    continue;
                }
                c.Patience -= dt;
                if (c.Patience <= 0f)
                {
                    Walkaways++;
                    _visible[i] = DequeueOrSpawn();
                }
            }
            _spawnTimer += dt;
            while (_spawnTimer >= SpawnRechargeTime && _spawnBuffer.Count < MaxQueue)
            {
                _spawnTimer -= SpawnRechargeTime;
                _spawnBuffer.Enqueue(SpawnCustomer());
            }
        }

        public int TryServe(LayerColor color)
        {
            for (int i = 0; i < _visible.Count; i++)
            {
                if (_visible[i].Order == color)
                {
                    _visible[i] = DequeueOrSpawn();
                    return i;
                }
            }
            return -1;
        }

        Customer DequeueOrSpawn()
        {
            return _spawnBuffer.Count > 0 ? _spawnBuffer.Dequeue() : SpawnCustomer();
        }

        Customer SpawnCustomer()
        {
            var color = _palette[_rng.Next(_palette.Length)];
            return new Customer(color, CustomerPatience, GraceWindow);
        }
    }
}
```

- [ ] **Step 4: Run tests — expect 7 PASS (all CustomerQueueTests)**

- [ ] **Step 5: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Model/Customer.cs Assets/_Plugins/LiquidPuzzles/Runtime/Model/CustomerQueue.cs Assets/_Tests/EditMode/Plugin/CustomerQueueTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-model): Customer + CustomerQueue with patience, walkaway, spawn"
```

---

## Task 3: MatchState — scoring, combo, timer

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/MatchState.cs`
- Create: `Assets/_Tests/EditMode/Plugin/MatchStateTests.cs`

- [ ] **Step 1: Write failing tests**

Path: `Assets/_Tests/EditMode/Plugin/MatchStateTests.cs`

```csharp
using MixIt.Archetype.Contracts;
using MixIt.Plugin.LiquidPuzzles.Model;
using NUnit.Framework;

namespace MixIt.Plugin.LiquidPuzzles.Tests
{
    public class MatchStateTests
    {
        [Test]
        public void PlayerServe_AppliesBasePoints()
        {
            var s = new MatchState(matchDuration: 90f);
            int points = s.ApplyPlayerServe(layerCount: 4, unopposed: false);
            Assert.AreEqual(200, points);
            Assert.AreEqual(200, s.PlayerScore);
        }

        [Test]
        public void PlayerServe_UnopposedAddsSpeedBonus()
        {
            var s = new MatchState(matchDuration: 90f);
            int points = s.ApplyPlayerServe(layerCount: 4, unopposed: true);
            Assert.AreEqual(250, points);
        }

        [Test]
        public void PlayerServe_ConsecutivesWithinWindowBuildCombo()
        {
            var s = new MatchState(matchDuration: 90f);
            s.ApplyPlayerServe(4, false);          // combo=1, +200 (no combo bonus on first)
            s.TickCombo(1f);
            int p2 = s.ApplyPlayerServe(4, false); // combo=2, +200 + 50*1
            Assert.AreEqual(250, p2);
            s.TickCombo(1f);
            int p3 = s.ApplyPlayerServe(4, false); // combo=3, +200 + 50*2
            Assert.AreEqual(300, p3);
        }

        [Test]
        public void PlayerServe_ComboResetsAfterWindow()
        {
            var s = new MatchState(matchDuration: 90f);
            s.ApplyPlayerServe(4, false);
            s.TickCombo(11f); // past 10s window
            int p2 = s.ApplyPlayerServe(4, false);
            Assert.AreEqual(200, p2, "combo reset, base only");
        }

        [Test]
        public void OpponentServe_ResetsPlayerCombo()
        {
            var s = new MatchState(matchDuration: 90f);
            s.ApplyPlayerServe(4, false); // combo=1
            s.ApplyOpponentServe(4, false);
            s.TickCombo(1f);
            int p2 = s.ApplyPlayerServe(4, false);
            Assert.AreEqual(200, p2, "combo reset by opponent");
        }

        [Test]
        public void Walkaway_Penalizes25()
        {
            var s = new MatchState(matchDuration: 90f);
            s.ApplyPlayerServe(4, false); // 200
            s.ApplyWalkaway();
            Assert.AreEqual(175, s.PlayerScore);
        }

        [Test]
        public void BuildResult_WinWhenPlayerHigher()
        {
            var s = new MatchState(matchDuration: 90f);
            s.ApplyPlayerServe(4, false);
            var r = s.BuildResult();
            Assert.IsTrue(r.Win);
            Assert.AreEqual(200, r.Score);
        }

        [Test]
        public void BuildResult_LossWhenOpponentHigher()
        {
            var s = new MatchState(matchDuration: 90f);
            s.ApplyOpponentServe(4, false);
            var r = s.BuildResult();
            Assert.IsFalse(r.Win);
        }
    }
}
```

- [ ] **Step 2: Create `MatchState.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Model/MatchState.cs`

```csharp
using System.Collections.Generic;
using MixIt.Archetype.Contracts;

namespace MixIt.Plugin.LiquidPuzzles.Model
{
    public sealed class MatchState
    {
        public const int PointsPerLayer = 50;
        public const int SpeedBonus = 50;
        public const int ComboBonus = 50;
        public const int WalkawayPenalty = -25;
        public const float ComboWindow = 10f;

        public MatchState(float matchDuration)
        {
            TimeRemaining = matchDuration;
        }

        public int PlayerScore { get; private set; }
        public int OpponentScore { get; private set; }
        public int ComboCount { get; private set; }
        public float ComboTimer { get; private set; }
        public float TimeRemaining { get; set; }
        public int DrinksServed { get; private set; }
        public int BestCombo { get; private set; }

        public int ApplyPlayerServe(int layerCount, bool unopposed)
        {
            int bonusCombo = ComboCount * ComboBonus;
            int points = layerCount * PointsPerLayer + bonusCombo + (unopposed ? SpeedBonus : 0);
            PlayerScore += points;
            ComboCount++;
            ComboTimer = ComboWindow;
            DrinksServed++;
            if (ComboCount > BestCombo) BestCombo = ComboCount;
            return points;
        }

        public void ApplyOpponentServe(int layerCount, bool unopposed)
        {
            int points = layerCount * PointsPerLayer + (unopposed ? SpeedBonus : 0);
            OpponentScore += points;
            ComboCount = 0;
            ComboTimer = 0f;
        }

        public void ApplyWalkaway()
        {
            PlayerScore += WalkawayPenalty;
        }

        public void TickCombo(float dt)
        {
            if (ComboTimer <= 0f) return;
            ComboTimer -= dt;
            if (ComboTimer <= 0f)
            {
                ComboTimer = 0f;
                ComboCount = 0;
            }
        }

        public MatchResult BuildResult()
        {
            bool win = PlayerScore > OpponentScore;
            var telemetry = new Dictionary<string, float>
            {
                ["opp_score"] = OpponentScore,
                ["drinks"] = DrinksServed,
                ["best_combo"] = BestCombo
            };
            return new MatchResult(win, PlayerScore, telemetry);
        }
    }
}
```

- [ ] **Step 3: Run tests — expect 8 PASS**

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Model/MatchState.cs Assets/_Tests/EditMode/Plugin/MatchStateTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-model): MatchState — scoring, combo, walkaway, result"
```

---

## Task 4: Config data classes

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Config/MatchConfig.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Config/ArenaProfile.cs`
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Config/CustomerPersona.cs`

- [ ] **Step 1: Create `MatchConfig.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Config/MatchConfig.cs`

```csharp
using MixIt.Plugin.LiquidPuzzles.Model;

namespace MixIt.Plugin.LiquidPuzzles.Config
{
    public sealed class MatchConfig
    {
        public float MatchDuration = 90f;
        public float CountdownDuration = 3f;
        public int GlassCapacity = 4;
        public int PlayerGlassCount = 5;
        public float WarningThreshold = 15f;

        public LayerColor[] Palette = {
            LayerColor.Red, LayerColor.Blue, LayerColor.Yellow, LayerColor.Green,
            LayerColor.Purple, LayerColor.Orange, LayerColor.Pink, LayerColor.Teal
        };

        public static MatchConfig Default() => new();
    }
}
```

- [ ] **Step 2: Create `ArenaProfile.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Config/ArenaProfile.cs`

```csharp
using MixIt.Plugin.LiquidPuzzles.Model;

namespace MixIt.Plugin.LiquidPuzzles.Config
{
    public sealed class ArenaProfile
    {
        public string Id = "juice";
        public float BotBaseInterval = 1.8f;
        public float BotCushionMult = 1.55f;
        public float MistakeRate = 0.03f;
        public int PlayerGlassCount = 5;

        public LayerColor[] Palette = {
            LayerColor.Red, LayerColor.Blue, LayerColor.Yellow, LayerColor.Green
        };

        public LayerColor[][] PlayerStartingLayout = {
            new[] { LayerColor.Red, LayerColor.Blue, LayerColor.Red },
            new[] { LayerColor.Yellow, LayerColor.Green, LayerColor.Yellow },
            new[] { LayerColor.Blue, LayerColor.Red, LayerColor.Blue },
            new LayerColor[0],
            new LayerColor[0]
        };

        public static ArenaProfile Juice() => new();
    }
}
```

- [ ] **Step 3: Create `CustomerPersona.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Config/CustomerPersona.cs`

```csharp
namespace MixIt.Plugin.LiquidPuzzles.Config
{
    public sealed class CustomerPersona
    {
        public string Name;
        public string Emoji;
        public string Tagline;
        public int TrophyStub;

        public static CustomerPersona[] JuiceRoster() => new[]
        {
            new CustomerPersona { Name = "Mango Mia",   Emoji = "🥭", Tagline = "Blends like nobody's watching", TrophyStub = 120 },
            new CustomerPersona { Name = "Berry Ben",   Emoji = "🫐", Tagline = "One berry at a time",           TrophyStub = 140 },
            new CustomerPersona { Name = "Citrus Sue",  Emoji = "🍊", Tagline = "Pulp or no pulp?",              TrophyStub = 160 },
            new CustomerPersona { Name = "Melon Moe",   Emoji = "🍉", Tagline = "Seeds are for sissies",         TrophyStub = 100 },
            new CustomerPersona { Name = "Kiwi Kat",    Emoji = "🥝", Tagline = "Tart wins",                     TrophyStub = 180 }
        };
    }
}
```

- [ ] **Step 4: Refresh + compile check**

Via Unity MCP `asset_refresh` then `editor_get_compilation_status`. Expected: 0 errors.

- [ ] **Step 5: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Config/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-config): MatchConfig, ArenaProfile, CustomerPersona (juice roster)"
```

---

## Task 5: Opponent AI

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Simulation/OpponentAI.cs`
- Create: `Assets/_Tests/EditMode/Plugin/OpponentAITests.cs`

- [ ] **Step 1: Write failing tests**

Path: `Assets/_Tests/EditMode/Plugin/OpponentAITests.cs`

```csharp
using System.Collections.Generic;
using MixIt.Plugin.LiquidPuzzles.Config;
using MixIt.Plugin.LiquidPuzzles.Model;
using MixIt.Plugin.LiquidPuzzles.Simulation;
using NUnit.Framework;

namespace MixIt.Plugin.LiquidPuzzles.Tests
{
    public class OpponentAITests
    {
        static List<Glass> MakeGlasses(params LayerColor[][] layouts)
        {
            var list = new List<Glass>();
            foreach (var layout in layouts)
            {
                var g = new Glass(4);
                foreach (var c in layout) g.Push(c);
                list.Add(g);
            }
            return list;
        }

        [Test]
        public void EvaluatePour_EmptyingSourceScoresThree()
        {
            var glasses = MakeGlasses(
                new[] { LayerColor.Red },        // src idx 0
                new[] { LayerColor.Red }         // dst idx 1 (can accept)
            );
            var ai = new OpponentAI(glasses, ArenaProfile.Juice(), seed: 1);
            int score = ai.EvaluatePour(0, 1);
            Assert.AreEqual(2 + 3, score, "color-match (+2) + empty-source (+3)");
        }

        [Test]
        public void EvaluatePour_CreatingServeScoresEight()
        {
            var glasses = MakeGlasses(
                new[] { LayerColor.Red },                                   // src
                new[] { LayerColor.Red, LayerColor.Red, LayerColor.Red }    // dst: 3/4 Red, would become full Red = serveable
            );
            var ai = new OpponentAI(glasses, ArenaProfile.Juice(), seed: 1);
            int score = ai.EvaluatePour(0, 1);
            // +2 color match, +3 empties source, +8 serve, +4 pure glass (served stays pure)
            Assert.GreaterOrEqual(score, 8);
        }

        [Test]
        public void EvaluatePour_InvalidPourScoresZero()
        {
            var glasses = MakeGlasses(
                new[] { LayerColor.Red },
                new[] { LayerColor.Blue }  // color mismatch
            );
            var ai = new OpponentAI(glasses, ArenaProfile.Juice(), seed: 1);
            Assert.AreEqual(0, ai.EvaluatePour(0, 1));
        }

        [Test]
        public void PickBestPour_ReturnsHighestEvaluated()
        {
            var glasses = MakeGlasses(
                new[] { LayerColor.Red },                                  // 0
                new[] { LayerColor.Red, LayerColor.Red, LayerColor.Red },  // 1 (serve target, high score)
                new LayerColor[0]                                          // 2 (empty, can accept anything = color match 0 since empty gives +0 match but empties source +3)
            );
            var ai = new OpponentAI(glasses, ArenaProfile.Juice(), seed: 1);
            var (src, dst) = ai.PickBestPour();
            Assert.AreEqual(0, src);
            Assert.AreEqual(1, dst, "should pick serve-creating pour");
        }
    }
}
```

- [ ] **Step 2: Create `OpponentAI.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Simulation/OpponentAI.cs`

```csharp
using System;
using System.Collections.Generic;
using MixIt.Plugin.LiquidPuzzles.Config;
using MixIt.Plugin.LiquidPuzzles.Model;

namespace MixIt.Plugin.LiquidPuzzles.Simulation
{
    public sealed class OpponentAI
    {
        public const float ServeCheckInterval = 2.5f;

        readonly List<Glass> _glasses;
        readonly ArenaProfile _arena;
        readonly Random _rng;
        float _nextPourIn;
        float _nextServeCheckIn;

        public OpponentAI(List<Glass> glasses, ArenaProfile arena, int seed)
        {
            _glasses = glasses;
            _arena = arena;
            _rng = new Random(seed);
            _nextPourIn = arena.BotBaseInterval * arena.BotCushionMult;
            _nextServeCheckIn = ServeCheckInterval;
        }

        public IReadOnlyList<Glass> Glasses => _glasses;

        public int EvaluatePour(int srcIdx, int dstIdx)
        {
            var src = _glasses[srcIdx];
            var dst = _glasses[dstIdx];
            if (!PourRules.CanPour(src, dst)) return 0;
            int score = 0;
            // +2 color match when target non-empty and colors match
            if (!dst.IsEmpty && src.Top == dst.Top) score += 2;
            // +3 empties source
            if (src.Count == 1) score += 3;
            // +4 creates pure glass (pour into empty dst)
            if (dst.IsEmpty) score += 4;
            // +8 creates serve (dst becomes full + pure)
            int dstCountAfter = dst.Count + 1;
            if (dstCountAfter == dst.Capacity && DstWouldBePureAfter(dst, src.Top)) score += 8;
            return score;
        }

        static bool DstWouldBePureAfter(Glass dst, LayerColor newTop)
        {
            for (int i = 0; i < dst.Count; i++)
                if (dst.Layers[i] != newTop) return false;
            return true;
        }

        public (int src, int dst) PickBestPour()
        {
            int bestScore = -1;
            (int, int) best = (-1, -1);
            for (int i = 0; i < _glasses.Count; i++)
            {
                for (int j = 0; j < _glasses.Count; j++)
                {
                    if (i == j) continue;
                    int s = EvaluatePour(i, j);
                    if (s > bestScore)
                    {
                        bestScore = s;
                        best = (i, j);
                    }
                }
            }
            return best;
        }

        public (int src, int dst) PickRandomValidPour()
        {
            var valid = new List<(int, int)>();
            for (int i = 0; i < _glasses.Count; i++)
                for (int j = 0; j < _glasses.Count; j++)
                    if (i != j && PourRules.CanPour(_glasses[i], _glasses[j]))
                        valid.Add((i, j));
            if (valid.Count == 0) return (-1, -1);
            return valid[_rng.Next(valid.Count)];
        }

        public bool ShouldPourThisTick(float dt)
        {
            _nextPourIn -= dt;
            if (_nextPourIn > 0f) return false;
            _nextPourIn = _arena.BotBaseInterval * _arena.BotCushionMult;
            return true;
        }

        public bool ShouldCheckServe(float dt)
        {
            _nextServeCheckIn -= dt;
            if (_nextServeCheckIn > 0f) return false;
            _nextServeCheckIn = ServeCheckInterval;
            return true;
        }

        public int FindServeableGlass()
        {
            for (int i = 0; i < _glasses.Count; i++)
                if (_glasses[i].IsServeable) return i;
            return -1;
        }

        public bool RollMistake() => _rng.NextDouble() < _arena.MistakeRate;
    }
}
```

- [ ] **Step 3: Run tests — expect 4 PASS**

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Simulation/OpponentAI.cs Assets/_Tests/EditMode/Plugin/OpponentAITests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-sim): OpponentAI — evaluate/pick/random, mistake roll"
```

---

## Task 6: MatchClock — countdown + 90s loop

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Simulation/MatchClock.cs`

This class owns the per-frame tick and phase transitions. Not directly tested — it's a thin wrapper over UniTask and delegates state mutations to MatchState/OpponentAI/CustomerQueue which are all tested.

- [ ] **Step 1: Create `MatchClock.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Simulation/MatchClock.cs`

```csharp
using System;
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Plugin.LiquidPuzzles.Model;

namespace MixIt.Plugin.LiquidPuzzles.Simulation
{
    public enum MatchPhase { Idle, Countdown, Playing, Ended }

    public sealed class MatchClock
    {
        public MatchPhase Phase { get; private set; } = MatchPhase.Idle;
        public float CountdownRemaining { get; private set; }

        public event Action<int> OnCountdownSecond;      // 3, 2, 1
        public event Action OnCountdownEnd;               // "MIX!"
        public event Action<float> OnTick;                // dt per frame in Playing
        public event Action OnMatchEnd;

        public async UniTask RunCountdown(float duration, CancellationToken ct)
        {
            Phase = MatchPhase.Countdown;
            CountdownRemaining = duration;
            int lastSecond = -1;
            while (CountdownRemaining > 0f)
            {
                int current = (int)Math.Ceiling(CountdownRemaining);
                if (current != lastSecond)
                {
                    OnCountdownSecond?.Invoke(current);
                    lastSecond = current;
                }
                await UniTask.Yield(PlayerLoopTiming.Update, ct);
                CountdownRemaining -= UnityEngine.Time.deltaTime;
            }
            OnCountdownEnd?.Invoke();
        }

        public async UniTask RunMatch(MatchState state, CancellationToken ct)
        {
            Phase = MatchPhase.Playing;
            while (state.TimeRemaining > 0f)
            {
                float dt = UnityEngine.Time.deltaTime;
                state.TimeRemaining -= dt;
                state.TickCombo(dt);
                OnTick?.Invoke(dt);
                await UniTask.Yield(PlayerLoopTiming.Update, ct);
            }
            Phase = MatchPhase.Ended;
            OnMatchEnd?.Invoke();
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Simulation/MatchClock.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-sim): MatchClock — countdown + playing loop with events"
```

---

## Task 7: IMatchIntroPresenter contract + default impl

**Files:**
- Create: `Assets/_Archetype/Contracts/IMatchIntroPresenter.cs`
- Create: `Assets/_Archetype/Runtime/DefaultMatchIntroPresenter.cs`
- Modify: `Assets/_Archetype/Runtime/MixIt.Archetype.Runtime.asmdef` — add `Unity.TextMeshPro`, `Unity.ugui` to references

- [ ] **Step 1: Create `IMatchIntroPresenter.cs`**

Path: `Assets/_Archetype/Contracts/IMatchIntroPresenter.cs`

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;
using UnityEngine;

namespace MixIt.Archetype.Contracts
{
    public interface IMatchIntroPresenter
    {
        UniTask Present(Transform container, CancellationToken ct);
    }
}
```

- [ ] **Step 2: Modify Contracts asmdef to reference UnityEngine (for Transform)**

Path: `Assets/_Archetype/Contracts/MixIt.Archetype.Contracts.asmdef`

Read current content first (it likely has `noEngineReferences: false` already). Add `"Unity.ugui"` reference only if `Transform` isn't resolvable. `Transform` is in `UnityEngine.CoreModule` which is auto-referenced when `noEngineReferences` is false — usually already fine.

Run `asset_refresh` + `editor_get_compilation_status`. If `Transform` unresolved, add `"UnityEngine"` (no) — actually just ensure `noEngineReferences` is false. That's default. No asmdef change expected.

- [ ] **Step 3: Modify `MixIt.Archetype.Runtime.asmdef` to add UI refs**

Path: `Assets/_Archetype/Runtime/MixIt.Archetype.Runtime.asmdef`

```json
{
    "name": "MixIt.Archetype.Runtime",
    "rootNamespace": "MixIt.Archetype.Runtime",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Archetype.Data",
        "UniTask",
        "VContainer",
        "VContainer.Unity",
        "Unity.TextMeshPro",
        "Unity.ugui"
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

- [ ] **Step 4: Create `DefaultMatchIntroPresenter.cs`**

Path: `Assets/_Archetype/Runtime/DefaultMatchIntroPresenter.cs`

```csharp
using System;
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using TMPro;
using UnityEngine;

namespace MixIt.Archetype.Runtime
{
    public sealed class DefaultMatchIntroPresenter : IMatchIntroPresenter
    {
        static readonly string[] CyclingNames = { "Player A", "Player B", "Player C" };
        const float CycleInterval = 0.5f;
        const int CycleCount = 4;

        public async UniTask Present(Transform container, CancellationToken ct)
        {
            ClearContainer(container);
            var labelGo = new GameObject("IntroLabel", typeof(RectTransform));
            labelGo.transform.SetParent(container, false);
            var rt = (RectTransform)labelGo.transform;
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = rt.offsetMax = Vector2.zero;
            var txt = labelGo.AddComponent<TextMeshProUGUI>();
            txt.alignment = TextAlignmentOptions.Center;
            txt.fontSize = 36;
            txt.color = Color.white;

            for (int i = 0; i < CycleCount; i++)
            {
                txt.text = CyclingNames[i % CyclingNames.Length];
                await UniTask.Delay(TimeSpan.FromSeconds(CycleInterval), cancellationToken: ct);
            }
            txt.text = "OPPONENT FOUND";
            await UniTask.Delay(TimeSpan.FromSeconds(1f), cancellationToken: ct);
        }

        static void ClearContainer(Transform container)
        {
            for (int i = container.childCount - 1; i >= 0; i--)
                UnityEngine.Object.Destroy(container.GetChild(i).gameObject);
        }
    }
}
```

- [ ] **Step 5: Refresh + compile — expect 0 errors**

- [ ] **Step 6: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Contracts/IMatchIntroPresenter.cs Assets/_Archetype/Runtime/DefaultMatchIntroPresenter.cs Assets/_Archetype/Runtime/MixIt.Archetype.Runtime.asmdef
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): IMatchIntroPresenter contract + default cycling impl"
```

---

## Task 8: LiquidPuzzlesIntroPresenter (plugin variant)

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/Runtime/Avatar/LiquidPuzzlesIntroPresenter.cs`

- [ ] **Step 1: Create `LiquidPuzzlesIntroPresenter.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/Avatar/LiquidPuzzlesIntroPresenter.cs`

```csharp
using System;
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using MixIt.Plugin.LiquidPuzzles.Config;
using TMPro;
using UnityEngine;

namespace MixIt.Plugin.LiquidPuzzles.Avatar
{
    public sealed class LiquidPuzzlesIntroPresenter : IMatchIntroPresenter
    {
        const float CycleInterval = 0.5f;
        const int CycleCount = 3;

        readonly CustomerPersona[] _roster = CustomerPersona.JuiceRoster();
        readonly System.Random _rng = new();

        public async UniTask Present(Transform container, CancellationToken ct)
        {
            ClearContainer(container);

            var emojiLabel = CreateLabel(container, "EmojiLabel", 72, new Vector2(0.3f, 0.55f), new Vector2(0.7f, 0.85f));
            var nameLabel = CreateLabel(container, "NameLabel", 28, new Vector2(0.1f, 0.35f), new Vector2(0.9f, 0.52f));
            var tagLabel = CreateLabel(container, "TaglineLabel", 16, new Vector2(0.1f, 0.22f), new Vector2(0.9f, 0.34f));
            var trophyLabel = CreateLabel(container, "TrophyLabel", 14, new Vector2(0.1f, 0.1f), new Vector2(0.9f, 0.2f));

            nameLabel.color = Color.white;
            tagLabel.color = new Color(1f, 1f, 1f, 0.7f);
            trophyLabel.color = new Color(1f, 0.85f, 0.1f);

            CustomerPersona chosen = _roster[_rng.Next(_roster.Length)];
            for (int i = 0; i < CycleCount; i++)
            {
                var p = _roster[_rng.Next(_roster.Length)];
                emojiLabel.text = p.Emoji;
                nameLabel.text = p.Name;
                tagLabel.text = $"\"{p.Tagline}\"";
                trophyLabel.text = $"🏆 {p.TrophyStub}";
                await UniTask.Delay(TimeSpan.FromSeconds(CycleInterval), cancellationToken: ct);
            }
            emojiLabel.text = chosen.Emoji;
            nameLabel.text = chosen.Name;
            tagLabel.text = $"\"{chosen.Tagline}\"";
            trophyLabel.text = $"🏆 {chosen.TrophyStub}";
            await UniTask.Delay(TimeSpan.FromSeconds(1f), cancellationToken: ct);
        }

        static TextMeshProUGUI CreateLabel(Transform parent, string name, int fontSize, Vector2 anchorMin, Vector2 anchorMax)
        {
            var go = new GameObject(name, typeof(RectTransform));
            go.transform.SetParent(parent, false);
            var rt = (RectTransform)go.transform;
            rt.anchorMin = anchorMin;
            rt.anchorMax = anchorMax;
            rt.offsetMin = rt.offsetMax = Vector2.zero;
            var txt = go.AddComponent<TextMeshProUGUI>();
            txt.alignment = TextAlignmentOptions.Center;
            txt.fontSize = fontSize;
            txt.color = Color.white;
            return txt;
        }

        static void ClearContainer(Transform container)
        {
            for (int i = container.childCount - 1; i >= 0; i--)
                UnityEngine.Object.Destroy(container.GetChild(i).gameObject);
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/Avatar/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin): LiquidPuzzlesIntroPresenter — themed persona carousel"
```

---

## Task 9: MatchmakingPanelView — use IMatchIntroPresenter

**Files:**
- Modify: `Assets/_Archetype/UI/Panels/MatchmakingPanelView.cs`

- [ ] **Step 1: Replace file content**

Path: `Assets/_Archetype/UI/Panels/MatchmakingPanelView.cs`

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using UnityEngine;
using VContainer;

namespace MixIt.Archetype.UI.Panels
{
    public class MatchmakingPanelView : MonoBehaviour
    {
        [SerializeField] RectTransform _introContainer;

        IFlowController _flow;
        IMatchIntroPresenter _intro;

        [Inject]
        public void Construct(IFlowController flow, IMatchIntroPresenter intro)
        {
            _flow = flow;
            _intro = intro;
        }

        void OnEnable()
        {
            RunIntro().Forget();
        }

        async UniTaskVoid RunIntro()
        {
            var ct = destroyCancellationToken;
            Transform container = _introContainer != null ? _introContainer : transform;
            await _intro.Present(container, ct);
            if (isActiveAndEnabled) _flow.StartMatch();
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors (existing DI registration for `_flow` still works; `_intro` will be wired in Task 14)**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/UI/Panels/MatchmakingPanelView.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "refactor(archetype-ui): MatchmakingPanelView delegates to IMatchIntroPresenter"
```

---

## Task 10: GlassView — tap input + layer rendering

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/UI/GlassView.cs`
- Modify: `Assets/_Plugins/LiquidPuzzles/UI/MixIt.Plugin.LiquidPuzzles.UI.asmdef` — ensure Runtime + UGUI + TMP refs

- [ ] **Step 1: Read + update UI asmdef**

Path: `Assets/_Plugins/LiquidPuzzles/UI/MixIt.Plugin.LiquidPuzzles.UI.asmdef`

Read current content, then ensure:

```json
{
    "name": "MixIt.Plugin.LiquidPuzzles.UI",
    "rootNamespace": "MixIt.Plugin.LiquidPuzzles.UI",
    "references": [
        "MixIt.Archetype.Contracts",
        "MixIt.Plugin.LiquidPuzzles.Runtime",
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

- [ ] **Step 2: Create `GlassView.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/UI/GlassView.cs`

```csharp
using System;
using System.Collections.Generic;
using MixIt.Plugin.LiquidPuzzles.Model;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace MixIt.Plugin.LiquidPuzzles.UI
{
    public enum GlassHighlight { Default, Source, Target, Serveable }

    public class GlassView : MonoBehaviour, IPointerClickHandler
    {
        public event Action<GlassView> OnTap;

        [SerializeField] Image _outline;
        [SerializeField] RectTransform _layersRoot;

        readonly List<Image> _layerImages = new();
        int _capacity;
        public int Index { get; private set; }

        public void Configure(int index, int capacity)
        {
            Index = index;
            _capacity = capacity;
        }

        public void Render(Glass glass, Func<LayerColor, Color> colorMap)
        {
            EnsureCapacity(colorMap);
            for (int i = 0; i < _capacity; i++)
            {
                if (i < glass.Count)
                {
                    _layerImages[i].enabled = true;
                    _layerImages[i].color = colorMap(glass.Layers[i]);
                }
                else
                {
                    _layerImages[i].enabled = false;
                }
            }
        }

        public void SetHighlight(GlassHighlight h)
        {
            if (_outline == null) return;
            _outline.color = h switch
            {
                GlassHighlight.Source    => new Color(0.6f, 0.83f, 1f),
                GlassHighlight.Target    => new Color(0.29f, 0.89f, 0.37f),
                GlassHighlight.Serveable => new Color(1f, 0.78f, 0.02f),
                _                        => new Color(0.3f, 0.3f, 0.3f)
            };
        }

        void EnsureCapacity(Func<LayerColor, Color> colorMap)
        {
            while (_layerImages.Count < _capacity)
            {
                var go = new GameObject($"Layer{_layerImages.Count}", typeof(RectTransform));
                go.transform.SetParent(_layersRoot, false);
                var rt = (RectTransform)go.transform;
                float h = 1f / _capacity;
                int idx = _layerImages.Count;
                rt.anchorMin = new Vector2(0, idx * h);
                rt.anchorMax = new Vector2(1, (idx + 1) * h);
                rt.offsetMin = rt.offsetMax = Vector2.zero;
                var img = go.AddComponent<Image>();
                img.color = Color.white;
                _layerImages.Add(img);
            }
        }

        public void OnPointerClick(PointerEventData eventData) => OnTap?.Invoke(this);
    }
}
```

- [ ] **Step 3: Refresh + compile — expect 0 errors**

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/UI/GlassView.cs Assets/_Plugins/LiquidPuzzles/UI/MixIt.Plugin.LiquidPuzzles.UI.asmdef
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-ui): GlassView — layer rendering, highlights, tap input"
```

---

## Task 11: CustomerQueueView

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/UI/CustomerQueueView.cs`

- [ ] **Step 1: Create `CustomerQueueView.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/UI/CustomerQueueView.cs`

```csharp
using System;
using System.Collections.Generic;
using MixIt.Plugin.LiquidPuzzles.Model;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace MixIt.Plugin.LiquidPuzzles.UI
{
    public class CustomerQueueView : MonoBehaviour
    {
        [SerializeField] RectTransform _slotsRoot;

        readonly List<Slot> _slots = new();

        class Slot
        {
            public Image ColorBg;
            public Image PatienceBar;
            public TextMeshProUGUI Emoji;
        }

        public void EnsureSlots(int count)
        {
            while (_slots.Count < count) _slots.Add(CreateSlot(_slots.Count, count));
        }

        public void Render(IReadOnlyList<Customer> visible, Func<LayerColor, Color> colorMap)
        {
            EnsureSlots(visible.Count);
            for (int i = 0; i < _slots.Count; i++)
            {
                if (i < visible.Count)
                {
                    var c = visible[i];
                    _slots[i].ColorBg.color = colorMap(c.Order);
                    _slots[i].PatienceBar.fillAmount = Mathf.Clamp01(c.Patience / CustomerQueue.CustomerPatience);
                    _slots[i].Emoji.text = "🧑";
                }
                else
                {
                    _slots[i].ColorBg.enabled = false;
                }
            }
        }

        Slot CreateSlot(int index, int total)
        {
            var go = new GameObject($"Slot{index}", typeof(RectTransform));
            go.transform.SetParent(_slotsRoot, false);
            var rt = (RectTransform)go.transform;
            float w = 1f / total;
            rt.anchorMin = new Vector2(index * w, 0);
            rt.anchorMax = new Vector2((index + 1) * w, 1);
            rt.offsetMin = new Vector2(4, 4);
            rt.offsetMax = new Vector2(-4, -4);

            var bg = go.AddComponent<Image>();
            bg.color = Color.gray;

            var emojiGo = new GameObject("Emoji", typeof(RectTransform));
            emojiGo.transform.SetParent(go.transform, false);
            var eRt = (RectTransform)emojiGo.transform;
            eRt.anchorMin = new Vector2(0, 0.25f);
            eRt.anchorMax = new Vector2(1, 0.9f);
            eRt.offsetMin = eRt.offsetMax = Vector2.zero;
            var emoji = emojiGo.AddComponent<TextMeshProUGUI>();
            emoji.alignment = TextAlignmentOptions.Center;
            emoji.fontSize = 32;
            emoji.text = "🧑";

            var barGo = new GameObject("Patience", typeof(RectTransform));
            barGo.transform.SetParent(go.transform, false);
            var bRt = (RectTransform)barGo.transform;
            bRt.anchorMin = new Vector2(0.1f, 0.05f);
            bRt.anchorMax = new Vector2(0.9f, 0.15f);
            bRt.offsetMin = bRt.offsetMax = Vector2.zero;
            var bar = barGo.AddComponent<Image>();
            bar.color = Color.white;
            bar.type = Image.Type.Filled;
            bar.fillMethod = Image.FillMethod.Horizontal;
            bar.fillAmount = 1f;

            return new Slot { ColorBg = bg, PatienceBar = bar, Emoji = emoji };
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/UI/CustomerQueueView.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-ui): CustomerQueueView — 3-slot patience bars"
```

---

## Task 12: MatchHudView

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/UI/MatchHudView.cs`

- [ ] **Step 1: Create `MatchHudView.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/UI/MatchHudView.cs`

```csharp
using MixIt.Plugin.LiquidPuzzles.Model;
using TMPro;
using UnityEngine;

namespace MixIt.Plugin.LiquidPuzzles.UI
{
    public class MatchHudView : MonoBehaviour
    {
        [SerializeField] TextMeshProUGUI _timerLabel;
        [SerializeField] TextMeshProUGUI _playerScoreLabel;
        [SerializeField] TextMeshProUGUI _opponentScoreLabel;
        [SerializeField] TextMeshProUGUI _comboLabel;
        [SerializeField] TextMeshProUGUI _countdownLabel;

        public void SetCountdown(string text)
        {
            if (_countdownLabel == null) return;
            _countdownLabel.text = text;
            _countdownLabel.enabled = !string.IsNullOrEmpty(text);
        }

        public void Render(MatchState state, float warningThreshold)
        {
            if (_timerLabel != null)
            {
                int seconds = Mathf.Max(0, Mathf.CeilToInt(state.TimeRemaining));
                _timerLabel.text = $"{seconds / 60}:{(seconds % 60):D2}";
                _timerLabel.color = state.TimeRemaining <= warningThreshold
                    ? new Color(1f, 0.27f, 0.27f)
                    : Color.white;
            }
            if (_playerScoreLabel != null) _playerScoreLabel.text = state.PlayerScore.ToString();
            if (_opponentScoreLabel != null) _opponentScoreLabel.text = state.OpponentScore.ToString();
            if (_comboLabel != null)
            {
                if (state.ComboCount > 1)
                {
                    _comboLabel.enabled = true;
                    _comboLabel.text = $"COMBO ×{state.ComboCount}";
                }
                else
                {
                    _comboLabel.enabled = false;
                }
            }
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/UI/MatchHudView.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-ui): MatchHudView — timer, scores, combo, countdown"
```

---

## Task 13: MatchBoardView — orchestrates glasses + queue + HUD, builds itself in code

**Files:**
- Create: `Assets/_Plugins/LiquidPuzzles/UI/MatchBoardView.cs`

- [ ] **Step 1: Create `MatchBoardView.cs`**

Path: `Assets/_Plugins/LiquidPuzzles/UI/MatchBoardView.cs`

```csharp
using System;
using System.Collections.Generic;
using MixIt.Plugin.LiquidPuzzles.Config;
using MixIt.Plugin.LiquidPuzzles.Model;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace MixIt.Plugin.LiquidPuzzles.UI
{
    public class MatchBoardView : MonoBehaviour
    {
        public event Action<int> OnGlassTap;

        readonly List<GlassView> _glasses = new();
        CustomerQueueView _queueView;
        MatchHudView _hud;
        Func<LayerColor, Color> _colorMap;
        int _selectedSource = -1;
        MatchConfig _config;

        public IReadOnlyList<GlassView> Glasses => _glasses;
        public CustomerQueueView QueueView => _queueView;
        public MatchHudView Hud => _hud;

        public void Build(RectTransform parent, MatchConfig config)
        {
            _config = config;
            _colorMap = Palette;
            var root = (RectTransform)transform;
            root.SetParent(parent, false);
            root.anchorMin = Vector2.zero;
            root.anchorMax = Vector2.one;
            root.offsetMin = root.offsetMax = Vector2.zero;

            BuildHud(root);
            BuildQueue(root, config);
            BuildGlasses(root, config);
        }

        public void ApplyState(Glass[] playerGlasses, IReadOnlyList<Customer> visibleCustomers, MatchState state)
        {
            for (int i = 0; i < _glasses.Count; i++)
            {
                _glasses[i].Render(playerGlasses[i], _colorMap);
                var hl = playerGlasses[i].IsServeable ? GlassHighlight.Serveable : GlassHighlight.Default;
                if (_selectedSource == i) hl = GlassHighlight.Source;
                _glasses[i].SetHighlight(hl);
            }
            _queueView.Render(visibleCustomers, _colorMap);
            _hud.Render(state, _config.WarningThreshold);
        }

        public void SetCountdown(string text) => _hud.SetCountdown(text);
        public void SetSelection(int sourceIndex) => _selectedSource = sourceIndex;

        static readonly Dictionary<LayerColor, Color> PaletteMap = new()
        {
            { LayerColor.Red,    new Color(0.92f, 0.26f, 0.26f) },
            { LayerColor.Blue,   new Color(0.26f, 0.55f, 0.92f) },
            { LayerColor.Yellow, new Color(0.96f, 0.86f, 0.18f) },
            { LayerColor.Green,  new Color(0.29f, 0.80f, 0.36f) },
            { LayerColor.Purple, new Color(0.62f, 0.28f, 0.85f) },
            { LayerColor.Orange, new Color(0.98f, 0.60f, 0.17f) },
            { LayerColor.Pink,   new Color(1.00f, 0.48f, 0.75f) },
            { LayerColor.Teal,   new Color(0.18f, 0.78f, 0.73f) },
        };

        static Color Palette(LayerColor c) => PaletteMap[c];

        void BuildHud(RectTransform parent)
        {
            var hudGo = new GameObject("Hud", typeof(RectTransform));
            hudGo.transform.SetParent(parent, false);
            var rt = (RectTransform)hudGo.transform;
            rt.anchorMin = new Vector2(0, 0.88f);
            rt.anchorMax = new Vector2(1, 1f);
            rt.offsetMin = rt.offsetMax = Vector2.zero;
            var bg = hudGo.AddComponent<Image>();
            bg.color = new Color(0f, 0f, 0f, 0.4f);

            var playerScore = MakeLabel(hudGo.transform, "PlayerScore", new Vector2(0.02f, 0.1f), new Vector2(0.25f, 0.9f), 28, TextAlignmentOptions.Left);
            var timer       = MakeLabel(hudGo.transform, "Timer",       new Vector2(0.35f, 0.1f), new Vector2(0.65f, 0.9f), 32, TextAlignmentOptions.Center);
            var oppScore    = MakeLabel(hudGo.transform, "OppScore",    new Vector2(0.75f, 0.1f), new Vector2(0.98f, 0.9f), 28, TextAlignmentOptions.Right);

            var comboGo = new GameObject("Combo", typeof(RectTransform));
            comboGo.transform.SetParent(parent, false);
            var cRt = (RectTransform)comboGo.transform;
            cRt.anchorMin = new Vector2(0.35f, 0.82f);
            cRt.anchorMax = new Vector2(0.65f, 0.88f);
            cRt.offsetMin = cRt.offsetMax = Vector2.zero;
            var combo = comboGo.AddComponent<TextMeshProUGUI>();
            combo.alignment = TextAlignmentOptions.Center;
            combo.fontSize = 20;
            combo.color = new Color(1f, 0.78f, 0.02f);
            combo.enabled = false;

            var cdGo = new GameObject("Countdown", typeof(RectTransform));
            cdGo.transform.SetParent(parent, false);
            var cdRt = (RectTransform)cdGo.transform;
            cdRt.anchorMin = new Vector2(0, 0.4f);
            cdRt.anchorMax = new Vector2(1, 0.6f);
            cdRt.offsetMin = cdRt.offsetMax = Vector2.zero;
            var countdown = cdGo.AddComponent<TextMeshProUGUI>();
            countdown.alignment = TextAlignmentOptions.Center;
            countdown.fontSize = 96;
            countdown.color = Color.white;
            countdown.enabled = false;

            _hud = hudGo.AddComponent<MatchHudView>();
            var fields = typeof(MatchHudView).GetFields(System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            foreach (var f in fields)
            {
                if (f.Name == "_timerLabel")         f.SetValue(_hud, timer);
                if (f.Name == "_playerScoreLabel")   f.SetValue(_hud, playerScore);
                if (f.Name == "_opponentScoreLabel") f.SetValue(_hud, oppScore);
                if (f.Name == "_comboLabel")         f.SetValue(_hud, combo);
                if (f.Name == "_countdownLabel")     f.SetValue(_hud, countdown);
            }
        }

        void BuildQueue(RectTransform parent, MatchConfig config)
        {
            var qGo = new GameObject("Queue", typeof(RectTransform));
            qGo.transform.SetParent(parent, false);
            var rt = (RectTransform)qGo.transform;
            rt.anchorMin = new Vector2(0.02f, 0.70f);
            rt.anchorMax = new Vector2(0.98f, 0.86f);
            rt.offsetMin = rt.offsetMax = Vector2.zero;
            _queueView = qGo.AddComponent<CustomerQueueView>();
            var slotsRootGo = new GameObject("Slots", typeof(RectTransform));
            slotsRootGo.transform.SetParent(qGo.transform, false);
            var sRt = (RectTransform)slotsRootGo.transform;
            sRt.anchorMin = Vector2.zero;
            sRt.anchorMax = Vector2.one;
            sRt.offsetMin = sRt.offsetMax = Vector2.zero;
            var f = typeof(CustomerQueueView).GetField("_slotsRoot", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            f.SetValue(_queueView, sRt);
            _queueView.EnsureSlots(3);
        }

        void BuildGlasses(RectTransform parent, MatchConfig config)
        {
            var strip = new GameObject("Glasses", typeof(RectTransform));
            strip.transform.SetParent(parent, false);
            var rt = (RectTransform)strip.transform;
            rt.anchorMin = new Vector2(0.05f, 0.1f);
            rt.anchorMax = new Vector2(0.95f, 0.65f);
            rt.offsetMin = rt.offsetMax = Vector2.zero;

            int n = config.PlayerGlassCount;
            for (int i = 0; i < n; i++)
            {
                var gGo = new GameObject($"Glass{i}", typeof(RectTransform));
                gGo.transform.SetParent(strip.transform, false);
                var gRt = (RectTransform)gGo.transform;
                float w = 1f / n;
                gRt.anchorMin = new Vector2(i * w + 0.02f, 0);
                gRt.anchorMax = new Vector2((i + 1) * w - 0.02f, 1);
                gRt.offsetMin = gRt.offsetMax = Vector2.zero;

                var outlineImg = gGo.AddComponent<Image>();
                outlineImg.color = new Color(0.3f, 0.3f, 0.3f);

                var layersGo = new GameObject("Layers", typeof(RectTransform));
                layersGo.transform.SetParent(gGo.transform, false);
                var lRt = (RectTransform)layersGo.transform;
                lRt.anchorMin = new Vector2(0.12f, 0.08f);
                lRt.anchorMax = new Vector2(0.88f, 0.92f);
                lRt.offsetMin = lRt.offsetMax = Vector2.zero;

                var gv = gGo.AddComponent<GlassView>();
                var fOutline = typeof(GlassView).GetField("_outline", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
                var fLayers = typeof(GlassView).GetField("_layersRoot", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
                fOutline.SetValue(gv, outlineImg);
                fLayers.SetValue(gv, lRt);
                gv.Configure(i, config.GlassCapacity);
                gv.OnTap += v => OnGlassTap?.Invoke(v.Index);
                _glasses.Add(gv);
            }
        }

        static TextMeshProUGUI MakeLabel(Transform parent, string name, Vector2 aMin, Vector2 aMax, int fontSize, TextAlignmentOptions align)
        {
            var go = new GameObject(name, typeof(RectTransform));
            go.transform.SetParent(parent, false);
            var rt = (RectTransform)go.transform;
            rt.anchorMin = aMin;
            rt.anchorMax = aMax;
            rt.offsetMin = rt.offsetMax = Vector2.zero;
            var t = go.AddComponent<TextMeshProUGUI>();
            t.alignment = align;
            t.fontSize = fontSize;
            t.color = Color.white;
            t.text = "";
            return t;
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/UI/MatchBoardView.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin-ui): MatchBoardView — self-building glasses + queue + HUD"
```

---

## Task 14: LiquidPuzzlesMatchSession — full orchestration

**Files:**
- Modify: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs` (replace Phase 1 stub)

- [ ] **Step 1: Replace file content**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs`

```csharp
using System.Collections.Generic;
using System.Threading;
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using MixIt.Plugin.LiquidPuzzles.Config;
using MixIt.Plugin.LiquidPuzzles.Model;
using MixIt.Plugin.LiquidPuzzles.Simulation;
using MixIt.Plugin.LiquidPuzzles.UI;
using UnityEngine;

namespace MixIt.Plugin.LiquidPuzzles
{
    public class LiquidPuzzlesMatchSession : IMatchSession
    {
        readonly MatchConfig _config;
        readonly ArenaProfile _arena;
        readonly int _seed;

        readonly Glass[] _playerGlasses;
        readonly List<Glass> _opponentGlasses;
        readonly CustomerQueue _queue;
        readonly MatchState _state;
        readonly OpponentAI _ai;
        readonly MatchClock _clock = new();

        int _selectedSource = -1;
        MatchBoardView _view;
        bool _opponentServedThisCustomer;

        public GameObject SceneRoot { get; } = new GameObject("LPRoot", typeof(RectTransform));

        public LiquidPuzzlesMatchSession(MatchConfig config, ArenaProfile arena, int seed)
        {
            _config = config;
            _arena = arena;
            _seed = seed;

            _playerGlasses = BuildStartingGlasses(arena, config);
            _opponentGlasses = new List<Glass>(BuildStartingGlasses(arena, config));
            _queue = new CustomerQueue(seed, _config.Palette);
            _state = new MatchState(_config.MatchDuration);
            _ai = new OpponentAI(_opponentGlasses, arena, seed + 1);
        }

        static Glass[] BuildStartingGlasses(ArenaProfile arena, MatchConfig config)
        {
            var result = new Glass[arena.PlayerGlassCount];
            for (int i = 0; i < arena.PlayerGlassCount; i++)
            {
                var g = new Glass(config.GlassCapacity);
                if (i < arena.PlayerStartingLayout.Length)
                    foreach (var c in arena.PlayerStartingLayout[i])
                        g.Push(c);
                result[i] = g;
            }
            return result;
        }

        public async UniTask<MatchResult> Run(CancellationToken ct)
        {
            BuildView();
            HookInput();
            HookClock();

            await _clock.RunCountdown(_config.CountdownDuration, ct);
            _view.SetCountdown("");
            await _clock.RunMatch(_state, ct);

            return _state.BuildResult();
        }

        void BuildView()
        {
            var rt = SceneRoot.GetComponent<RectTransform>();
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = rt.offsetMax = Vector2.zero;

            var viewGo = new GameObject("Board", typeof(RectTransform));
            _view = viewGo.AddComponent<MatchBoardView>();
            _view.Build(rt, _config);
            _view.ApplyState(_playerGlasses, _queue.Visible, _state);
        }

        void HookInput()
        {
            _view.OnGlassTap += OnGlassTapped;
        }

        void HookClock()
        {
            _clock.OnCountdownSecond += sec => _view.SetCountdown(sec.ToString());
            _clock.OnCountdownEnd += () => _view.SetCountdown("MIX!");
            _clock.OnTick += OnTick;
        }

        void OnTick(float dt)
        {
            _queue.Tick(dt);
            while (_queue.Walkaways > _lastWalkaways)
            {
                _state.ApplyWalkaway();
                _lastWalkaways++;
            }

            if (_ai.ShouldPourThisTick(dt))
            {
                var (src, dst) = _ai.RollMistake() ? _ai.PickRandomValidPour() : _ai.PickBestPour();
                if (src >= 0 && dst >= 0)
                    PourRules.ApplyPour(_opponentGlasses[src], _opponentGlasses[dst]);
            }
            if (_ai.ShouldCheckServe(dt))
            {
                int idx = _ai.FindServeableGlass();
                if (idx >= 0)
                {
                    var color = _opponentGlasses[idx].Top;
                    int slot = _queue.TryServe(color);
                    if (slot >= 0)
                    {
                        _state.ApplyOpponentServe(_opponentGlasses[idx].Count, unopposed: !_opponentServedThisCustomer);
                        _opponentGlasses[idx].Clear();
                        _opponentServedThisCustomer = true;
                    }
                }
            }

            _view.ApplyState(_playerGlasses, _queue.Visible, _state);
        }

        int _lastWalkaways;

        void OnGlassTapped(int index)
        {
            if (_clock.Phase != MatchPhase.Playing) return;
            var g = _playerGlasses[index];

            if (g.IsServeable)
            {
                int slot = _queue.TryServe(g.Top);
                if (slot >= 0)
                {
                    _state.ApplyPlayerServe(g.Count, unopposed: !_opponentServedThisCustomer);
                    g.Clear();
                    _opponentServedThisCustomer = false;
                }
                _selectedSource = -1;
                _view.SetSelection(-1);
                return;
            }

            if (_selectedSource < 0)
            {
                if (!g.IsEmpty)
                {
                    _selectedSource = index;
                    _view.SetSelection(index);
                }
                return;
            }

            if (_selectedSource == index)
            {
                _selectedSource = -1;
                _view.SetSelection(-1);
                return;
            }

            var src = _playerGlasses[_selectedSource];
            var dst = _playerGlasses[index];
            if (PourRules.CanPour(src, dst))
                PourRules.ApplyPour(src, dst);

            _selectedSource = -1;
            _view.SetSelection(-1);
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesMatchSession.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin): LiquidPuzzlesMatchSession — full orchestration (countdown, tick, input, AI)"
```

---

## Task 15: LiquidPuzzlesPlugin — provide config + seed

**Files:**
- Modify: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesPlugin.cs`

- [ ] **Step 1: Replace file content**

Path: `Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesPlugin.cs`

```csharp
using MixIt.Archetype.Contracts;
using MixIt.Plugin.LiquidPuzzles.Config;

namespace MixIt.Plugin.LiquidPuzzles
{
    public sealed class LiquidPuzzlesPlugin : IPlugin
    {
        public PluginManifest Manifest { get; } = new PluginManifest(
            Id: "liquid-puzzles",
            DisplayName: "Liquid Puzzles",
            Icon: null
        );

        public IMatchSession StartMatch(MatchRequest request)
        {
            var config = MatchConfig.Default();
            var arena = ArenaProfile.Juice();
            return new LiquidPuzzlesMatchSession(config, arena, request.Seed);
        }
    }
}
```

- [ ] **Step 2: Refresh + compile — expect 0 errors**

- [ ] **Step 3: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Plugins/LiquidPuzzles/Runtime/LiquidPuzzlesPlugin.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(plugin): LiquidPuzzlesPlugin provides MatchConfig + ArenaProfile (juice)"
```

---

## Task 16: DI registration + scene wiring

**Files:**
- Modify: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`
- Modify: `Assets/_Game/Scenes/Main.unity` (via Unity MCP)

- [ ] **Step 1: Update `GameLifetimeScope.cs`**

Path: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`

Read the current file first. Add the intro presenter registration after the `LiquidPuzzlesPlugin` line. Expected updated content:

```csharp
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime;
using MixIt.Archetype.Runtime.UI;
using MixIt.Archetype.UI.Panels;
using MixIt.Plugin.LiquidPuzzles;
using MixIt.Plugin.LiquidPuzzles.Avatar;
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
            builder.Register<UIRouter>(Lifetime.Singleton).As<IUIRouter>();
            builder.Register<WalletService>(Lifetime.Singleton).As<IWalletService>();
            builder.Register<FlowController>(Lifetime.Singleton).As<IFlowController>().As<IStartable>();

            builder.Register<LiquidPuzzlesPlugin>(Lifetime.Singleton).As<IPlugin>();
            builder.Register<LiquidPuzzlesIntroPresenter>(Lifetime.Singleton).As<IMatchIntroPresenter>();

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
    }
}
```

Also verify `MixIt.Game.asmdef` has a reference to `MixIt.Plugin.LiquidPuzzles.Runtime` (should already from Phase 1). If not present, add it.

- [ ] **Step 2: Add IntroContainer to MatchmakingPanel via Unity MCP**

Use `editor_execute_code` with usings `["UnityEditor.SceneManagement", "UnityEngine.UI", "MixIt.Archetype.UI.Panels"]`:

```csharp
var scene = EditorSceneManager.OpenScene("Assets/_Game/Scenes/Main.unity", OpenSceneMode.Single);
var mmGo = UnityEngine.GameObject.Find("MainCanvas/ContentRoot/MatchmakingPanel");
var existing = mmGo.transform.Find("IntroContainer");
UnityEngine.RectTransform introRt;
if (existing != null)
{
    introRt = (UnityEngine.RectTransform)existing;
}
else
{
    var introGo = new UnityEngine.GameObject("IntroContainer", typeof(UnityEngine.RectTransform));
    introGo.transform.SetParent(mmGo.transform, false);
    introRt = (UnityEngine.RectTransform)introGo.transform;
    introRt.anchorMin = new UnityEngine.Vector2(0.1f, 0.2f);
    introRt.anchorMax = new UnityEngine.Vector2(0.9f, 0.75f);
    introRt.offsetMin = introRt.offsetMax = UnityEngine.Vector2.zero;
}
var view = mmGo.GetComponent<MixIt.Archetype.UI.Panels.MatchmakingPanelView>();
var so = new UnityEditor.SerializedObject(view);
var prop = so.FindProperty("_introContainer");
if (prop != null)
{
    prop.objectReferenceValue = introRt;
    so.ApplyModifiedProperties();
}
// Remove old static "Finding opponent..." label if present (superseded by presenter UI)
var oldStatus = mmGo.transform.Find("StatusLabel");
if (oldStatus != null) UnityEngine.Object.DestroyImmediate(oldStatus.gameObject);

EditorSceneManager.MarkSceneDirty(scene);
EditorSceneManager.SaveScene(scene);
return "wired";
```

- [ ] **Step 3: Verify via `scene_get_hierarchy`** — MatchmakingPanel has IntroContainer child, no StatusLabel.

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Game/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(game): register LiquidPuzzlesIntroPresenter + wire IntroContainer"
```

---

## Task 17: Play Mode smoke + completion

**Files:**
- Create: `Assets/_Game/PHASE_2_DONE.md`

- [ ] **Step 1: Run EditMode tests — expect all green**

Via Unity MCP `test_run` EditMode. Expected total: 11 previous + 7 Glass + 6 PourRules + 7 CustomerQueue + 8 MatchState + 4 OpponentAI = **43 tests**.

- [ ] **Step 2: Play Mode smoke**

Via Unity MCP:
1. `scene_open` Main.unity
2. `console_clear`
3. `editor_enter_play_mode`
4. Wait ~4s (covers Loading → Home)
5. `console_get_entries` — expect no errors; `Boot OK ... router current=Home`
6. `editor_exit_play_mode`

Manual verification (post-plan): user opens editor, taps PLAY, observes:
- Matchmaking carousel cycles 3 personas then locks
- Countdown "3 2 1 MIX!" (3 seconds)
- 5 glasses appear with juice-arena starting layout; 3 customer slots above
- Timer counts down from 1:30
- Player taps 2 glasses → pour resolves if valid
- Full pure glass → tap serves if color matches customer, score increments
- Opponent score ticks up over match
- After 90s → ResultPanel shows VICTORY/DEFEAT + reward gold

- [ ] **Step 3: Create PHASE_2_DONE.md**

Path: `Assets/_Game/PHASE_2_DONE.md`

```markdown
# Phase 2 complete

- Model layer: Glass, PourRules, Customer, CustomerQueue, MatchState (pure C#, 32 EditMode tests).
- Simulation: OpponentAI (evaluate/best/random/mistake), MatchClock (countdown + 90s loop).
- Config: MatchConfig, ArenaProfile (juice), CustomerPersona (5-person roster).
- Plugin UI: GlassView, CustomerQueueView, MatchHudView, MatchBoardView.
- Archetype contract: IMatchIntroPresenter + DefaultMatchIntroPresenter; plugin variant LiquidPuzzlesIntroPresenter.
- LiquidPuzzlesMatchSession orchestrates input, AI tick, customer tick, scoring.
- Plugin boundary preserved — no Archetype.Runtime/UI refs in plugin Runtime asmdef.
- EditMode tests: 43/43 green.

Ready for Phase 3: archetype meta systems (Wallet+Rating+MM, BP+TR, Venue+Album, Shop, FTUE+Analytics).
```

- [ ] **Step 4: Commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Game/PHASE_2_DONE.md
git -C "D:/Projects/mix-it/MixIt" commit -m "docs: Phase 2 complete"
```

---

## Appendix — troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Compile error: `IMatchIntroPresenter` not found in MatchmakingPanelView | Contracts asmdef missing UI.panels ref | `MixIt.Archetype.UI.asmdef` already refs Contracts — check asset_refresh ran |
| VContainer throws "no IMatchIntroPresenter registered" | Task 16 registration not applied | Add `builder.Register<LiquidPuzzlesIntroPresenter>().As<IMatchIntroPresenter>()` |
| Glasses show nothing | `_layersRoot` serialized field null after code-build | `MatchBoardView.BuildGlasses` uses reflection to set field — ensure assembly allows non-public field write (default in Unity C#) |
| Pour allowed but nothing visible | `ApplyState` not called after input | Confirm `_view.ApplyState` invoked in `OnGlassTapped` and `OnTick` |
| Opponent score always 0 | AI tick intervals not reset | Check `ShouldPourThisTick` resets `_nextPourIn` only after firing |
| Timer stays at 1:30 | `MatchClock.RunMatch` not awaited | Confirm `Run` awaits both `RunCountdown` and `RunMatch` |
| "MIX!" overlay never clears | `SetCountdown("")` not called after countdown | Call happens right after `RunCountdown` returns |
| Carousel shows placeholder text | Plugin presenter not registered, fell back to default | Task 16 Step 1 registration is the swap — confirm order |
