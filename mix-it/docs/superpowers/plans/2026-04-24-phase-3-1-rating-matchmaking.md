# Phase 3.1 — Rating + Matchmaking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship archetype trophy/rating system, arena resolution, AI matchmaking service, and unified JSON save profile. Refactor WalletService onto save profile. Hook FlowController for rating delta and opponent picking.

**Architecture:** Pure-C# services in `MixIt.Archetype.Runtime`. Single `ISaveProfile` JSON blob consumed by Wallet + Rating. Static tables (no SO yet) for arena definitions + persona roster.

**Tech Stack:** Unity 6.3, VContainer 1.16.9, UniTask 2.5.10, C# 9, Unity `JsonUtility` for persistence.

**Spec:** `docs/superpowers/specs/2026-04-24-phase-3-1-rating-matchmaking-design.md`

**Unity project root:** `D:\Projects\mix-it\MixIt`

---

## File structure

```
Assets/_Archetype/
├── Contracts/
│   ├── IRatingService.cs           (NEW)
│   ├── IMatchmakingService.cs      (NEW)
│   ├── ISaveProfile.cs             (NEW)
│   ├── OpponentProfile.cs          (NEW record)
│   ├── ArenaInfo.cs                (NEW record)
│   └── IFlowController.cs          (MODIFY — add CurrentOpponent, LastRatingDelta)
├── Runtime/
│   ├── ArenaTable.cs               (NEW)
│   ├── PersonaRoster.cs            (NEW)
│   ├── RatingService.cs            (NEW)
│   ├── MatchmakingService.cs       (NEW)
│   ├── FlowController.cs           (MODIFY — hook rating + mm)
│   ├── WalletService.cs            (REWRITE — backed by ISaveProfile)
│   └── Persistence/
│       ├── SaveProfile.cs          (NEW)
│       └── JsonSaveStore.cs        (NEW)
└── _Game/Bootstrap/
    └── GameLifetimeScope.cs        (MODIFY — register new services)

Assets/_Tests/EditMode/
├── WalletServiceTests.cs           (MIGRATE — inject ISaveProfile)
├── ArenaTableTests.cs              (NEW)
├── SaveProfileTests.cs             (NEW)
├── RatingServiceTests.cs           (NEW)
└── MatchmakingServiceTests.cs      (NEW)
```

---

## Task 1: Contracts — IRatingService, IMatchmakingService, ISaveProfile, OpponentProfile, ArenaInfo

**Files:** 5 new in `Assets/_Archetype/Contracts/`

- [ ] **Step 1: Create `OpponentProfile.cs`**

```csharp
namespace MixIt.Archetype.Contracts
{
    public sealed record OpponentProfile(string Name, string Icon, string Tagline, int Trophies, string ArenaId);
}
```

- [ ] **Step 2: Create `ArenaInfo.cs`**

```csharp
namespace MixIt.Archetype.Contracts
{
    public sealed record ArenaInfo(string Id, string Name, string Icon, int MinTrophies, int TrophyBase, int Index);
}
```

- [ ] **Step 3: Create `ISaveProfile.cs`**

```csharp
using System;

namespace MixIt.Archetype.Contracts
{
    public interface ISaveProfile
    {
        int Gold { get; set; }
        int Trophies { get; set; }
        int ConsecWins { get; set; }
        void Save();
        void Load();
        event Action OnSaved;
    }
}
```

- [ ] **Step 4: Create `IRatingService.cs`**

```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IRatingService
    {
        int Trophies { get; }
        int ConsecWins { get; }
        ArenaInfo CurrentArena { get; }
        int ApplyWin(int matchArenaIdx, int stakeCount);
        int ApplyLoss(int matchArenaIdx);
        void ApplyDraw();
    }
}
```

- [ ] **Step 5: Create `IMatchmakingService.cs`**

```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IMatchmakingService
    {
        OpponentProfile PickOpponent();
    }
}
```

- [ ] **Step 6: Compile + commit**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Contracts/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(contracts): IRatingService, IMatchmakingService, ISaveProfile, OpponentProfile, ArenaInfo"
```

---

## Task 2: ArenaTable + tests

**Files:**
- Create: `Assets/_Archetype/Runtime/ArenaTable.cs`
- Create: `Assets/_Tests/EditMode/ArenaTableTests.cs`

- [ ] **Step 1: Failing tests**

Path: `Assets/_Tests/EditMode/ArenaTableTests.cs`

```csharp
using MixIt.Archetype.Runtime;
using NUnit.Framework;

namespace MixIt.Archetype.Tests
{
    public class ArenaTableTests
    {
        [Test] public void ZeroTrophies_ResolvesToJuice() => Assert.AreEqual("juice", ArenaTable.Resolve(0).Id);
        [Test] public void JustBelowSmoothie_StaysJuice() => Assert.AreEqual("juice", ArenaTable.Resolve(149).Id);
        [Test] public void At150_SmoothieBar() => Assert.AreEqual("smoothie", ArenaTable.Resolve(150).Id);
        [Test] public void At999_TeaGarden() => Assert.AreEqual("tea", ArenaTable.Resolve(999).Id);
        [Test] public void At1000_Cocktail() => Assert.AreEqual("cocktail", ArenaTable.Resolve(1000).Id);
        [Test] public void At10000_Grand() => Assert.AreEqual("grand", ArenaTable.Resolve(10000).Id);
        [Test] public void Index_MatchesTableOrder()
        {
            Assert.AreEqual(0, ArenaTable.Resolve(0).Index);
            Assert.AreEqual(4, ArenaTable.Resolve(1000).Index);
            Assert.AreEqual(7, ArenaTable.Resolve(3200).Index);
        }
        [Test] public void TrophyBase_JuiceIs25() => Assert.AreEqual(25, ArenaTable.Resolve(0).TrophyBase);
        [Test] public void TrophyBase_GrandIs38() => Assert.AreEqual(38, ArenaTable.Resolve(3200).TrophyBase);
    }
}
```

- [ ] **Step 2: Create `ArenaTable.cs`**

```csharp
using MixIt.Archetype.Contracts;

namespace MixIt.Archetype.Runtime
{
    public static class ArenaTable
    {
        public static readonly ArenaInfo[] Table =
        {
            new ArenaInfo("juice",     "Juice Stand",     "\U0001F379", 0,    25, 0),
            new ArenaInfo("smoothie",  "Smoothie Bar",    "\U0001F964", 150,  26, 1),
            new ArenaInfo("coffee",    "Coffee House",    "☕",     400,  28, 2),
            new ArenaInfo("tea",       "Tea Garden",      "\U0001F375", 700,  30, 3),
            new ArenaInfo("cocktail",  "Cocktail Lounge", "\U0001F378", 1000, 32, 4),
            new ArenaInfo("wine",      "Wine Cellar",     "\U0001F377", 1500, 34, 5),
            new ArenaInfo("champagne", "Champagne Room",  "\U0001F942", 2200, 36, 6),
            new ArenaInfo("grand",     "Grand Hotel",     "\U0001F3E8", 3200, 38, 7)
        };

        public static ArenaInfo Resolve(int trophies)
        {
            ArenaInfo result = Table[0];
            for (int i = 0; i < Table.Length; i++)
            {
                if (trophies >= Table[i].MinTrophies) result = Table[i];
                else break;
            }
            return result;
        }

        public static float WinScale(int playerIdx, int matchIdx)
        {
            int delta = matchIdx - playerIdx;
            if (delta <= 0) return 1.0f;
            if (delta == 1) return 0.5f;
            return 0.25f;
        }

        public static float LossScale(int playerIdx, int matchIdx)
        {
            int delta = matchIdx - playerIdx;
            if (delta <= 0) return 1.0f;
            if (delta == 1) return 0.25f;
            return 0.10f;
        }
    }
}
```

- [ ] **Step 3: Tests pass. Commit.**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/ArenaTable.cs Assets/_Tests/EditMode/ArenaTableTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): ArenaTable — 8 arenas + depth scaling helpers"
```

---

## Task 3: SaveProfile + JsonSaveStore + tests

**Files:**
- Create: `Assets/_Archetype/Runtime/Persistence/SaveProfile.cs`
- Create: `Assets/_Archetype/Runtime/Persistence/JsonSaveStore.cs`
- Create: `Assets/_Tests/EditMode/SaveProfileTests.cs`

- [ ] **Step 1: `SaveProfile.cs`**

```csharp
using System;

namespace MixIt.Archetype.Runtime.Persistence
{
    [Serializable]
    public sealed class SaveProfile
    {
        public int Gold;
        public int Trophies;
        public int ConsecWins;
    }
}
```

- [ ] **Step 2: `JsonSaveStore.cs`**

```csharp
using System;
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Archetype.Runtime.Persistence
{
    public sealed class JsonSaveStore : ISaveProfile
    {
        const string Key = "mixit.save.v1";

        SaveProfile _data;

        public JsonSaveStore()
        {
            _data = new SaveProfile();
            Load();
        }

        public int Gold { get => _data.Gold; set => _data.Gold = value; }
        public int Trophies { get => _data.Trophies; set => _data.Trophies = value; }
        public int ConsecWins { get => _data.ConsecWins; set => _data.ConsecWins = value; }

        public event Action OnSaved;

        public void Save()
        {
            var json = JsonUtility.ToJson(_data);
            PlayerPrefs.SetString(Key, json);
            PlayerPrefs.Save();
            OnSaved?.Invoke();
        }

        public void Load()
        {
            if (!PlayerPrefs.HasKey(Key))
            {
                _data = new SaveProfile();
                return;
            }
            var json = PlayerPrefs.GetString(Key);
            try { _data = JsonUtility.FromJson<SaveProfile>(json) ?? new SaveProfile(); }
            catch { _data = new SaveProfile(); }
        }
    }
}
```

- [ ] **Step 3: `SaveProfileTests.cs`**

```csharp
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime.Persistence;
using NUnit.Framework;
using UnityEngine;

namespace MixIt.Archetype.Tests
{
    public class SaveProfileTests
    {
        [SetUp] public void Setup() => PlayerPrefs.DeleteKey("mixit.save.v1");
        [TearDown] public void Teardown() => PlayerPrefs.DeleteKey("mixit.save.v1");

        [Test]
        public void NoKey_LoadsDefaults()
        {
            var store = new JsonSaveStore();
            Assert.AreEqual(0, store.Gold);
            Assert.AreEqual(0, store.Trophies);
            Assert.AreEqual(0, store.ConsecWins);
        }

        [Test]
        public void SaveLoad_RoundtripsState()
        {
            var s1 = new JsonSaveStore();
            s1.Gold = 500;
            s1.Trophies = 1200;
            s1.ConsecWins = 3;
            s1.Save();

            var s2 = new JsonSaveStore();
            Assert.AreEqual(500, s2.Gold);
            Assert.AreEqual(1200, s2.Trophies);
            Assert.AreEqual(3, s2.ConsecWins);
        }

        [Test]
        public void CorruptedJson_LoadsDefaults()
        {
            PlayerPrefs.SetString("mixit.save.v1", "{{not valid json");
            PlayerPrefs.Save();
            var s = new JsonSaveStore();
            Assert.AreEqual(0, s.Gold);
        }

        [Test]
        public void Save_RaisesOnSaved()
        {
            var s = new JsonSaveStore();
            int count = 0;
            s.OnSaved += () => count++;
            s.Save();
            Assert.AreEqual(1, count);
        }
    }
}
```

- [ ] **Step 4: Compile + test — expect 43 + 9 + 4 = 56 pass**. Commit.

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/Persistence/ Assets/_Tests/EditMode/SaveProfileTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): SaveProfile + JsonSaveStore (PlayerPrefs+JsonUtility backed)"
```

---

## Task 4: WalletService refactor

**Files:**
- Modify: `Assets/_Archetype/Runtime/WalletService.cs`
- Modify: `Assets/_Tests/EditMode/WalletServiceTests.cs`

- [ ] **Step 1: Rewrite `WalletService.cs`**

```csharp
using MixIt.Archetype.Contracts;

namespace MixIt.Archetype.Runtime
{
    public sealed class WalletService : IWalletService
    {
        readonly ISaveProfile _profile;

        public WalletService(ISaveProfile profile)
        {
            _profile = profile;
        }

        public int Gold => _profile.Gold;

        public void AddGold(int amount)
        {
            if (amount <= 0) return;
            _profile.Gold += amount;
        }

        public bool SpendGold(int amount)
        {
            if (amount > _profile.Gold) return false;
            _profile.Gold -= amount;
            return true;
        }

        public void Save() => _profile.Save();
        public void Load() => _profile.Load();
    }
}
```

- [ ] **Step 2: Update `WalletServiceTests.cs`** — inject `JsonSaveStore`:

```csharp
using MixIt.Archetype.Runtime;
using MixIt.Archetype.Runtime.Persistence;
using NUnit.Framework;
using UnityEngine;

namespace MixIt.Archetype.Tests
{
    public class WalletServiceTests
    {
        WalletService _wallet;
        JsonSaveStore _store;

        [SetUp]
        public void SetUp()
        {
            PlayerPrefs.DeleteKey("mixit.save.v1");
            _store = new JsonSaveStore();
            _wallet = new WalletService(_store);
        }

        [TearDown] public void TearDown() => PlayerPrefs.DeleteKey("mixit.save.v1");

        [Test] public void Gold_StartsAtZero_WhenNoSavedData() => Assert.AreEqual(0, _wallet.Gold);

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

            var store2 = new JsonSaveStore();
            var wallet2 = new WalletService(store2);
            Assert.AreEqual(500, wallet2.Gold);
        }

        [Test]
        public void AddGold_ZeroOrNegative_DoesNotChangeBalance()
        {
            _wallet.AddGold(100);
            _wallet.AddGold(0);
            _wallet.AddGold(-50);
            Assert.AreEqual(100, _wallet.Gold);
        }

        [Test]
        public void Load_NoSavedData_ReturnsZero()
        {
            _wallet.AddGold(500);
            _wallet.Load();
            Assert.AreEqual(0, _wallet.Gold);
        }
    }
}
```

- [ ] **Step 3: Compile + all tests pass (previous 43 + 9 ArenaTable + 4 SaveProfile + 7 Wallet migrated = 52 after dedup; actually: 11 existing other + 9 + 4 + 7 = 31 archetype + 32 plugin = 63)**. Commit.

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/WalletService.cs Assets/_Tests/EditMode/WalletServiceTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "refactor(archetype): WalletService backed by ISaveProfile"
```

---

## Task 5: RatingService + tests

**Files:**
- Create: `Assets/_Archetype/Runtime/RatingService.cs`
- Create: `Assets/_Tests/EditMode/RatingServiceTests.cs`

- [ ] **Step 1: Failing tests**

Path: `Assets/_Tests/EditMode/RatingServiceTests.cs`

```csharp
using MixIt.Archetype.Runtime;
using MixIt.Archetype.Runtime.Persistence;
using NUnit.Framework;
using UnityEngine;

namespace MixIt.Archetype.Tests
{
    public class RatingServiceTests
    {
        JsonSaveStore _store;
        RatingService _rating;

        [SetUp]
        public void Setup()
        {
            PlayerPrefs.DeleteKey("mixit.save.v1");
            _store = new JsonSaveStore();
            _rating = new RatingService(_store);
        }

        [TearDown] public void Teardown() => PlayerPrefs.DeleteKey("mixit.save.v1");

        [Test]
        public void NewProfile_ZeroTrophies_JuiceArena()
        {
            Assert.AreEqual(0, _rating.Trophies);
            Assert.AreEqual("juice", _rating.CurrentArena.Id);
        }

        [Test]
        public void ApplyWin_JuiceArena_Adds25()
        {
            int delta = _rating.ApplyWin(matchArenaIdx: 0, stakeCount: 0);
            Assert.AreEqual(25, delta);
            Assert.AreEqual(25, _rating.Trophies);
            Assert.AreEqual(1, _rating.ConsecWins);
        }

        [Test]
        public void ApplyWin_AfterTwoConsec_DoublesForOnFire()
        {
            _rating.ApplyWin(0, 0); // +25, consec=1
            _rating.ApplyWin(0, 0); // +25, consec=2 (next win will get onFire)
            int d = _rating.ApplyWin(0, 0);
            Assert.AreEqual(50, d);
        }

        [Test]
        public void ApplyLoss_Subtracts25_ClampsAtZero()
        {
            _rating.ApplyLoss(0);
            Assert.AreEqual(0, _rating.Trophies);
        }

        [Test]
        public void ApplyLoss_ResetsConsecWins()
        {
            _rating.ApplyWin(0, 0);
            _rating.ApplyLoss(0);
            Assert.AreEqual(0, _rating.ConsecWins);
        }

        [Test]
        public void ApplyDraw_NoTrophyChange_ResetsConsecWins()
        {
            _rating.ApplyWin(0, 0);
            _rating.ApplyDraw();
            Assert.AreEqual(25, _rating.Trophies);
            Assert.AreEqual(0, _rating.ConsecWins);
        }

        [Test]
        public void ApplyWin_StakeCountTwo_Doubles()
        {
            int d = _rating.ApplyWin(0, stakeCount: 2);
            Assert.AreEqual(50, d);
        }

        [Test]
        public void ApplyWin_AboveThreshold_ChangesArena()
        {
            _store.Trophies = 149;
            int d1 = _rating.ApplyWin(0, 0); // juice base 25 → 174 total
            Assert.AreEqual(25, d1);
            Assert.AreEqual(174, _rating.Trophies);
            Assert.AreEqual("smoothie", _rating.CurrentArena.Id);
        }
    }
}
```

- [ ] **Step 2: Create `RatingService.cs`**

```csharp
using MixIt.Archetype.Contracts;
using UnityEngine;

namespace MixIt.Archetype.Runtime
{
    public sealed class RatingService : IRatingService
    {
        readonly ISaveProfile _profile;

        public RatingService(ISaveProfile profile)
        {
            _profile = profile;
        }

        public int Trophies => _profile.Trophies;
        public int ConsecWins => _profile.ConsecWins;
        public ArenaInfo CurrentArena => ArenaTable.Resolve(_profile.Trophies);

        public int ApplyWin(int matchArenaIdx, int stakeCount)
        {
            int playerIdx = CurrentArena.Index;
            int baseValue = CurrentArena.TrophyBase;
            float scale = ArenaTable.WinScale(playerIdx, matchArenaIdx);
            int stakeMult = Mathf.Max(1, stakeCount);
            int onFireMult = _profile.ConsecWins >= 2 ? 2 : 1;
            int delta = Mathf.RoundToInt(baseValue * scale) * stakeMult * onFireMult;
            _profile.Trophies += delta;
            _profile.ConsecWins++;
            return delta;
        }

        public int ApplyLoss(int matchArenaIdx)
        {
            int playerIdx = CurrentArena.Index;
            int baseValue = CurrentArena.TrophyBase;
            float scale = ArenaTable.LossScale(playerIdx, matchArenaIdx);
            int delta = Mathf.RoundToInt(baseValue * scale);
            _profile.Trophies = Mathf.Max(0, _profile.Trophies - delta);
            _profile.ConsecWins = 0;
            return -delta;
        }

        public void ApplyDraw()
        {
            _profile.ConsecWins = 0;
        }
    }
}
```

- [ ] **Step 3: Compile + tests pass**. Commit.

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/RatingService.cs Assets/_Tests/EditMode/RatingServiceTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): RatingService — win/loss/draw deltas, scale, stakes, onFire"
```

---

## Task 6: PersonaRoster

**Files:**
- Create: `Assets/_Archetype/Runtime/PersonaRoster.cs`

- [ ] **Step 1: Create file**

```csharp
using System.Collections.Generic;
using MixIt.Archetype.Contracts;

namespace MixIt.Archetype.Runtime
{
    public static class PersonaRoster
    {
        public sealed record Persona(string Name, string Icon, string Tagline);

        static readonly Dictionary<string, Persona[]> ByArena = new()
        {
            ["juice"] = new[] {
                new Persona("Sunny Sam",   "\U0001F31E", "Fresh squeezed wins."),
                new Persona("Lemon Liz",   "\U0001F34B", "Tart 'n tidy."),
                new Persona("Pulpy Pete",  "\U0001F965", "Keep the fiber.")
            },
            ["smoothie"] = new[] {
                new Persona("Berry Bea",   "\U0001FAD0", "Blend fast."),
                new Persona("Mango Milo",  "\U0001F96D", "Tropical trouble."),
                new Persona("Kiwi Kai",    "\U0001F95D", "Kiwi crew king.")
            },
            ["coffee"] = new[] {
                new Persona("Barista Bo",  "☕",     "One shot, one win."),
                new Persona("Espresso Eva","\U0001F331", "Double down."),
                new Persona("Latte Lola",  "\U0001F95B", "Foam art, clean pour.")
            },
            ["tea"] = new[] {
                new Persona("Sencha Sue",  "\U0001F375", "Steep slow."),
                new Persona("Oolong Omar", "\U0001F343", "Half-oxidized hustle."),
                new Persona("Matcha Mei",  "\U0001F33F", "Whisked to win.")
            },
            ["cocktail"] = new[] {
                new Persona("Velvet Viv",  "\U0001F378", "Shaken, never stirred."),
                new Persona("Olive Otto",  "\U0001FAD2", "Salty finish."),
                new Persona("Ruby Rose",   "\U0001F339", "Pink drinks, pink slips.")
            },
            ["wine"] = new[] {
                new Persona("Cellar Cass",    "\U0001F377", "Cork twice, check vintage."),
                new Persona("Vintage Vic",    "\U0001F347", "Age before ambition."),
                new Persona("Sommelier Syd",  "\U0001F943", "Nose first, pour second.")
            },
            ["champagne"] = new[] {
                new Persona("Bubbly Bel",  "\U0001F942", "Pop the cork, pour the line."),
                new Persona("Flute Flynn", "\U0001F3B7", "Fizz and finesse."),
                new Persona("Rosé Rhea",  "\U0001F338", "Pink means pro.")
            },
            ["grand"] = new[] {
                new Persona("Maestro Max", "\U0001F3BC", "Every pour is a symphony."),
                new Persona("Duchess Dee", "\U0001F451", "Pedigreed pours only."),
                new Persona("Baron Bo",    "\U0001F3AD", "House specialty: winning.")
            }
        };

        public static IReadOnlyList<Persona> ForArena(string arenaId)
        {
            return ByArena.TryGetValue(arenaId, out var arr) ? arr : ByArena["juice"];
        }
    }
}
```

- [ ] **Step 2: Compile. Commit.**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/PersonaRoster.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): PersonaRoster — 24 personas across 8 arenas"
```

---

## Task 7: MatchmakingService + tests

**Files:**
- Create: `Assets/_Archetype/Runtime/MatchmakingService.cs`
- Create: `Assets/_Tests/EditMode/MatchmakingServiceTests.cs`

- [ ] **Step 1: Failing tests**

```csharp
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime;
using MixIt.Archetype.Runtime.Persistence;
using NUnit.Framework;
using UnityEngine;

namespace MixIt.Archetype.Tests
{
    public class MatchmakingServiceTests
    {
        JsonSaveStore _store;
        RatingService _rating;

        [SetUp]
        public void Setup()
        {
            PlayerPrefs.DeleteKey("mixit.save.v1");
            _store = new JsonSaveStore();
            _rating = new RatingService(_store);
        }

        [TearDown] public void Teardown() => PlayerPrefs.DeleteKey("mixit.save.v1");

        [Test]
        public void PickOpponent_ReturnsNonNullPersonaFields()
        {
            var mm = new MatchmakingService(_rating, seed: 42);
            var opp = mm.PickOpponent();
            Assert.IsNotNull(opp.Name);
            Assert.IsNotNull(opp.Icon);
            Assert.IsNotNull(opp.Tagline);
            Assert.AreEqual("juice", opp.ArenaId);
        }

        [Test]
        public void PickOpponent_TrophiesWithinPlusMinus100()
        {
            _store.Trophies = 500;
            var mm = new MatchmakingService(_rating, seed: 42);
            for (int i = 0; i < 100; i++)
            {
                var opp = mm.PickOpponent();
                Assert.GreaterOrEqual(opp.Trophies, 400);
                Assert.LessOrEqual(opp.Trophies, 600);
            }
        }

        [Test]
        public void PickOpponent_FloorsOppTrophiesAtZero()
        {
            _store.Trophies = 10;
            var mm = new MatchmakingService(_rating, seed: 42);
            for (int i = 0; i < 100; i++)
            {
                var opp = mm.PickOpponent();
                Assert.GreaterOrEqual(opp.Trophies, 0);
            }
        }

        [Test]
        public void PickOpponent_DeterministicWithSeed()
        {
            var mm1 = new MatchmakingService(_rating, seed: 123);
            var mm2 = new MatchmakingService(_rating, seed: 123);
            Assert.AreEqual(mm1.PickOpponent().Name, mm2.PickOpponent().Name);
        }
    }
}
```

- [ ] **Step 2: `MatchmakingService.cs`**

```csharp
using System;
using MixIt.Archetype.Contracts;

namespace MixIt.Archetype.Runtime
{
    public sealed class MatchmakingService : IMatchmakingService
    {
        readonly IRatingService _rating;
        readonly Random _rng;

        public MatchmakingService(IRatingService rating) : this(rating, 0) { }

        public MatchmakingService(IRatingService rating, int seed)
        {
            _rating = rating;
            _rng = seed == 0 ? new Random() : new Random(seed);
        }

        public OpponentProfile PickOpponent()
        {
            var arena = _rating.CurrentArena;
            var roster = PersonaRoster.ForArena(arena.Id);
            var persona = roster[_rng.Next(roster.Count)];
            int jitter = _rng.Next(-100, 101);
            int oppTrophies = Math.Max(0, _rating.Trophies + jitter);
            return new OpponentProfile(persona.Name, persona.Icon, persona.Tagline, oppTrophies, arena.Id);
        }
    }
}
```

- [ ] **Step 3: Compile + test. Commit.**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/Runtime/MatchmakingService.cs Assets/_Tests/EditMode/MatchmakingServiceTests.cs
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(archetype): MatchmakingService — pick persona + jitter trophies"
```

---

## Task 8: FlowController integration

**Files:**
- Modify: `Assets/_Archetype/Contracts/IFlowController.cs` — add CurrentOpponent + LastRatingDelta
- Modify: `Assets/_Archetype/Runtime/FlowController.cs`

- [ ] **Step 1: Update `IFlowController.cs`**

```csharp
namespace MixIt.Archetype.Contracts
{
    public interface IFlowController
    {
        MatchResult LastResult { get; }
        int LastReward { get; }
        int LastRatingDelta { get; }
        OpponentProfile CurrentOpponent { get; }
        void GoHome();
        void RequestMatch();
        void StartMatch();
        void CompleteMatch(MatchResult result);
    }
}
```

- [ ] **Step 2: Update `FlowController.cs`**

Read current file, then rewrite with rating + mm hooks:

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
        readonly IRatingService _rating;
        readonly IMatchmakingService _mm;
        CancellationTokenSource _matchCts;

        public MatchResult LastResult { get; private set; }
        public int LastReward { get; private set; }
        public int LastRatingDelta { get; private set; }
        public OpponentProfile CurrentOpponent { get; private set; }

        [Inject]
        public FlowController(
            IUIRouter router,
            IPlugin plugin,
            IWalletService wallet,
            IMatchPanelView matchPanel,
            IRatingService rating,
            IMatchmakingService mm)
        {
            _router = router;
            _plugin = plugin;
            _wallet = wallet;
            _matchPanel = matchPanel;
            _rating = rating;
            _mm = mm;
        }

        public void Start() => GoHome();

        public void GoHome() => _router.GoTo(PanelId.Home).Forget();

        public void RequestMatch()
        {
            CurrentOpponent = _mm.PickOpponent();
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
            try
            {
                var session = _plugin.StartMatch(new MatchRequest(UnityEngine.Random.Range(0, int.MaxValue)));
                await _router.GoTo(PanelId.Match);
                var result = await _matchPanel.ShowMatch(session, ct);
                CompleteMatch(result);
            }
            catch (System.OperationCanceledException)
            {
                _router.GoTo(PanelId.Home).Forget();
            }
        }

        public void CompleteMatch(MatchResult result)
        {
            LastResult = result;
            var arenaIdx = _rating.CurrentArena.Index;
            LastRatingDelta = result.Win ? _rating.ApplyWin(arenaIdx, 0) : _rating.ApplyLoss(arenaIdx);
            LastReward = result.Win ? GoldOnWin : GoldOnLoss;
            _wallet.AddGold(LastReward);
            _wallet.Save();
            _router.GoTo(PanelId.Result).Forget();
        }
    }
}
```

- [ ] **Step 3: Compile** — will fail in Plan Task 9 until DI updated. Don't commit yet.

---

## Task 9: DI registration + smoke + PHASE_3_1_DONE.md

**Files:**
- Modify: `Assets/_Game/Bootstrap/GameLifetimeScope.cs`
- Create: `Assets/_Game/PHASE_3_1_DONE.md`

- [ ] **Step 1: Update `GameLifetimeScope.cs`**

Read current. Insert `JsonSaveStore`, `RatingService`, `MatchmakingService` registrations before the plugin line:

```csharp
using Cysharp.Threading.Tasks;
using MixIt.Archetype.Contracts;
using MixIt.Archetype.Runtime;
using MixIt.Archetype.Runtime.Persistence;
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

            builder.Register<JsonSaveStore>(Lifetime.Singleton).As<ISaveProfile>();
            builder.Register<WalletService>(Lifetime.Singleton).As<IWalletService>();
            builder.Register<RatingService>(Lifetime.Singleton).As<IRatingService>();
            builder.Register<MatchmakingService>(Lifetime.Singleton).As<IMatchmakingService>();

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

- [ ] **Step 2: Compile — 0 errors. Run EditMode tests — expect ~63 pass (11 prior archetype after Wallet migration + new ArenaTable 9 + SaveProfile 4 + Rating 8 + MM 4 = 36 archetype + 32 plugin = 68). Actual count may vary; verify total > 60.**

- [ ] **Step 3: Play Mode smoke**

`scene_open` → `console_clear` → `editor_enter_play_mode` → wait 2s → `console_get_entries` (expect "Boot OK", no errors, no VContainer exceptions) → exit.

- [ ] **Step 4: Create `Assets/_Game/PHASE_3_1_DONE.md`**

```markdown
# Phase 3.1 complete — Rating + Matchmaking

- `ISaveProfile` + `JsonSaveStore` unified save blob (PlayerPrefs + JsonUtility).
- `WalletService` migrated to `ISaveProfile` — no more raw PlayerPrefs key.
- `ArenaTable` — 8 arenas (juice → grand), depth scaling win/loss helpers.
- `RatingService` — trophy deltas, stake + On Fire multipliers, arena-depth scale, floor 0.
- `PersonaRoster` — 24 personas across 8 arenas.
- `MatchmakingService` — persona pick + ±100 trophy jitter.
- `FlowController` hooks: `RequestMatch` picks opponent; `CompleteMatch` applies rating delta.
- EditMode tests green (60+ total).

Ready for Phase 3.2: Analytics event bus.
```

- [ ] **Step 5: Commit final**

```bash
git -C "D:/Projects/mix-it/MixIt" add Assets/_Archetype/ Assets/_Game/
git -C "D:/Projects/mix-it/MixIt" commit -m "feat(game): wire Rating+MM+SaveProfile into DI; Phase 3.1 complete"
```

---

## Appendix — troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `VContainerException: JsonSaveStore has no registration` | Register order wrong — Wallet/Rating need ISaveProfile first | Register JsonSaveStore BEFORE wallet/rating lines |
| Wallet tests fail after migration | Old `"wallet.gold"` key still set in editor PlayerPrefs | Setup/Teardown deletes `"mixit.save.v1"` — fine for fresh session; if leftover old key, manually delete |
| `IMatchIntroPresenter` receives `OpponentProfile` — how? | Phase 4 job, not 3.1 | 3.1 only stores `CurrentOpponent` on FlowController; presenter keeps current behavior (random roster pick) for now |
| `FlowController` constructor param count changed — VContainer errors | Missing registration for IRatingService or IMatchmakingService | Add registrations per Task 9 |
