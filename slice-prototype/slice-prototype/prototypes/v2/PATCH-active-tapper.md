# PATCH — Slice Tycoon → tożsamość „Active-Tapper z presją + idle incremental"

> **Cel patcha:** przekuć prototyp v2 z niejasnej tożsamości (cozy-idle vs active-tapper) w spójny **active-tapper z presją + wspierające elementy idle incremental**.
> **Plik docelowy implementacji:** `prototypes/v2/index.html` — `CONFIG` (l.401-457), `SCHEMA_DEFAULT` (l.478-492), runtime slice/auto (l.761-881).
> **Status:** spec gotowy do implementacji. Wszystkie wartości potwierdzone w kodzie; benchmarki gatunku to **generyczne wzorce** (pliki `gs-prototype-designer/knowledge/*.md` nie były dostępne w środowisku) — przed produkcyjnym strojeniem zwaliduj na realnych danych.
> **Data:** 2026-06-28

---

## 0. Decyzja projektowa (kontekst)

**Tożsamość:** active core (hold-slice + combo + boss-rush 30 s) to **GWIAZDA**; warstwa idle (auto-cutters, offline, prestige) jest **WSPIERAJĄCA** i podporządkowana — *active musi out-earnować idle ~2.5-5×*. Presja płynie z **czasu i skilla** (zegar bossa, decay combo), **nie** z bariery zatrzymującej rdzeń.

**Co ta decyzja robi z audytem:**
- ✅ **Ratyfikuje** boss-gated chapters i carryover draft (były 🔴 „innowacja w złej warstwie" pod cozy-idle; pod presją to filary).
- ❌ **Wyrzuca** pozycjonowanie „cozy / relaks / no pressure" (komunikacja, FTUE, tuning idą w „opanuj presję").
- 🔧 **Przerabia** staminę (twardy blok → paliwo Overdrive) — patrz §1.
- 🔧 **Naprawia** Auto-Slicer dzielący pool staminy — patrz §2.
- ➕ **Wymaga dodać** prestige (§3) i daily loop (§5) — bez nich „idle incremental" i skala dzień/tydzień są puste.

---

# CZĘŚĆ A — EKONOMIA

## 1. Refactor staminy: twardy blok → paliwo „Overdrive Fuel"

### 1.1 Diagnoza (baseline potwierdzony w kodzie)

| Wielkość | Wartość | Źródło |
|---|---|---|
| Tempo cięcia (hold) | `holdInterval = 260·cutFactor / sliceSpeedMult` ms | l.1060-1062 |
| Tomato Lv0 hold | 260 ms → **3.85 cięć/s** | wyliczenie |
| Regen staminy | 3/s | l.409, 552 |
| Netto drenaż przy holdzie | 3.85 − 3.0 = **0.85/s** | wyliczenie |
| Czas do opróżnienia (pool 60) | ≈ **70 s** | wyliczenie |
| Po opróżnieniu | **twardy klamp do 3 cięć/s** (l.764 `return`) | l.763-765 |
| Auto-Slicer | dzieli ten sam pool, czeka przy 0 | l.800-804, 871-881 |

**Problem:** po ~70 s sustainu gracz bezterminowo traci 22% throughputu, a Auto-Slicer (idle) kradnie z tego samego poola — idle sabotuje active. To jest „bariera zatrzymująca rdzeń", której tożsamość zabrania.

### 1.2 Decyzja: Wariant A „Overdrive Fuel" (Wariant B „Heat/overheat" odrzucony)

**Dlaczego A:** A **nagradza ryzyko** (graj agresywnie → wyższy mnożnik, palisz paliwo); B **karze sukces** (im lepiej tniesz, tym szybciej dostajesz debuff) = ukryty throttle pod inną nazwą. A daje czysty impatience-lever dla gemów (refill → natychmiast wróć do Overdrive) i czytelny UI (pasek paliwa = pasek mocy).

**Model:**
1. Pasek staminy → **„Fuel"**. Tap/hold **zawsze działa** — twardy blok (l.764) **znika**.
2. Fuel powyżej progu + hold → **Overdrive**: ×wartość i ×szybkość. Fuel drenuje.
3. Fuel = 0 → **brak bloku**, gracz spada do **Normal tempa** (bazowy holdInterval, bazowy mnożnik). Fuel regeneruje, można znów odpalić.
4. Regen zawsze; przy 0 **boost regenu** (szybki re-arm).

### 1.3 CONFIG — before/after

```diff
- staminaMaxBase: 60, staminaMaxPerLevel: 20,
- staminaRegenBase: 3, staminaRegenPerLevel: 1,
- staminaPerSlice: 1,
- staminaCostBase: 800, staminaCostGrowth: 1.4,
- staminaRegenCostBase: 1100, staminaRegenCostGrowth: 1.4,
- staminaRefillGems: 1,
+ // ---- FUEL / OVERDRIVE (zastępuje twardy stamina-gate) ----
+ fuelMaxBase: 100, fuelMaxPerLevel: 25,          // większy pool — Overdrive ma "oddychać"
+ fuelRegenBase: 6, fuelRegenPerLevel: 1.5,       // /s w Normal; nie jest już capem dochodu
+ fuelEmptyRegenMult: 2.0,                         // przy Fuel=0 regen ×2 (szybki re-arm)
+ overdriveThreshold: 15,                          // Fuel>=15 i hold => Overdrive ON (histereza: OFF dopiero przy 0)
+ overdriveDrainPerSlice: 1.0,                     // bazowy drenaż na cięcie w Overdrive (skalowany combo, niżej)
+ overdriveValueMult: 1.8,                         // ×wartość monet w Overdrive
+ overdriveSpeedMult: 1.35,                        // ×tempo cięcia w Overdrive
+ fuelMaxCostBase: 800, fuelMaxCostGrowth: 1.4,    // (port z staminaCost)
+ fuelRegenCostBase: 1100, fuelRegenCostGrowth: 1.4,
+ fuelRefillGems: 1,                               // natychmiastowy full-refill = 1 gem (impatience lever zachowany)
```

**Migracja schema:** `stamina:{cur}` → `fuel:{cur}`; `staminaLevel/staminaRegenLevel` → `fuelMaxLevel/fuelRegenLevel` (kopiuj 1:1 — graczom nic nie znika; `deepDefault` l.495 ogarnia stare save'y).

### 1.4 Formuły

```
fuelMax()        = fuelMaxBase + fuelMaxLevel · fuelMaxPerLevel
fuelRegen(empty) = (fuelRegenBase + fuelRegenLevel · fuelRegenPerLevel) · (empty ? fuelEmptyRegenMult : 1)
overdriveOn      = holding && fuel >= overdriveThreshold        // OFF dopiero przy fuel=0 (histereza, by nie migotał)
holdInterval()   = max(holdMinMs, holdBaseMs·cutFactor / (sliceSpeedMult · carryMult · (overdriveOn?overdriveSpeedMult:1)))
coinsPerSlice    = base · comboMult · laneMult · incomeMult · (overdriveOn ? overdriveValueMult : 1)
drenaż/cięcie    = overdriveDrainPerSlice · comboMult          // im wyższe combo, tym drożej palisz (ryzyko/nagroda)
```

### 1.5 Krzywa (Tomato Lv0)

- Overdrive tempo: 260 / 1.35 = 193 ms → **5.18 cięć/s**.
- Przy combo max (×2.0): drenaż 5.18 · 2.0 = 10.36 Fuel/s, regen 6/s → netto **−4.36/s**.

| Stan | Czas Overdrive z pełnego poola (100) | Re-arm do progu (15) |
|---|---|---|
| Combo niski (×1.0) | ~podtrzymywalny (early power fantasy) | n/d |
| Combo średni (×1.5) | ~47 s | ~1.3 s |
| Combo max (×2.0) | ~20 s | ~1.3 s |

**% uplift vs dziś:**

| Tryb | cięć/s | mnożnik | coins/s (Tomato, combo max) | vs dzisiejszy klamp |
|---|---|---|---|---|
| Dziś (po opróżnieniu) | 3.0 | ×2.0 | 6.0 | baseline |
| **Overdrive ON** | 5.18 | ×3.6 | **18.6** | **+210%** |
| **Normal (Fuel pusty, bez bloku)** | 3.85 | ×2.0 | 7.7 | **+28%** |

**Kluczowe:** nawet z pustym paliwem gracz tnie szybciej niż dziś (+28%, bo bariera znika). Overdrive to ciasteczko (+210% w szczycie), nie warunek grania. Gem-refill kupuje *uplift* (luksus), nie *prawo do gry*.

---

## 2. Rozdzielenie poola Auto-Slicera

**Before:** `autoChefMs() = holdInterval()`, tnie z `state.stamina.cur`, czeka przy 0 (l.803, 877). Idle zżera paliwo aktywnej gry.

**After:** Auto-Slicer **bez paliwa**, własne stałe tempo, **zero Fuel**.

```diff
- autoChefCost: 4000,   // (zostaje)
+ autoChefCost: 4000,
+ // ---- AUTO-SLICER (idle, własne tempo, ZERO Fuel) ----
+ autoChefBaseMs: 1500,          // stałe ~0.67 cięć/s (NIE skaluje od Slice Speed)
+ autoChefSpeedPerLevel: 0.10,   // osobny, opcjonalny idle gold-sink
+ autoChefNeverOverdrive: true,  // idle nigdy nie wchodzi w Overdrive
```

```
autoChefMs() = autoChefBaseMs / (1 + autoChefSpeedLevel · autoChefSpeedPerLevel)
// USUŃ: drenaż Fuel (l.803-804) i warunek na Fuel (l.877) — Auto-Slicer nie czyta Fuel
// coins idle = base · laneMult · incomeMult (combo-neutralny, BEZ overdrive)
```

**Dowód rozdzielenia (Tomato Lv0, równe poziomy):**

| Ścieżka | cięć/s | mnożnik | coins/s |
|---|---|---|---|
| Auto-Slicer (idle) | 0.67 | ×1.0 | 0.67 |
| Active Normal | 3.85 | ×2.0 | 7.7 |
| Active Overdrive | 5.18 | ×3.6 | 18.6 |

**Reguła kalibracji:** suma całego idle throughputu (Auto-Slicer + wszystkie lane-autos) = **20-40% active-Normal coins/s** → active out-earn **2.5-5×**. Ponieważ idle ma stałe tempo (nie skaluje od Slice Speed), kupowanie active-upgrade'ów **rozszerza** przewagę active — cementuje hierarchię „active = gwiazda".

---

## 3. Prestige math (przywrócenie long-term meta)

- **Waluta:** **„Michelin Stars" ⭐** (akumulują, nie kolidują z coins/gems).
- **Reset:** coins → 60, lane levels → 0, unlocked → 1, income/sliceSpeed/autoSpeed/fuel levels → 0, chapter → 0, Auto-Slicer unlock → false.
- **NIE resetuje:** **gems** (premium nie znika — krytyczne dla zaufania), **gear**, **Stars**, lifetime stats.
- **Efekt:** `prestigeMult = 1 + stars · starBonus` na wszystkie coin-faucety (active i idle równo → nie odwraca hierarchii).

```
prestigeGain = floor( starK · sqrt( totalCoinsEarned / starScale ) ) - starsAlreadyOwned
starK     = 1.0
starScale = 5000     // 1. prestige osiągalny w ~jednej sesji
starBonus = 0.10     // każdy star = +10% globalnego dochodu (10 starów = ×2.0)
```

**Dlaczego `sqrt`:** zapobiega zgarnianiu setek starów naraz przez late-game gracza (kanon idle, kontrola inflacji meta).

| Prestige # | Stary przed | Wymagane `totalCoinsEarned` | Stary po | Zysk | `prestigeMult` po | Szac. czas |
|---|---|---|---|---|---|---|
| #1 | 0 | 5 000 | 1 | +1 | ×1.10 | ~15 min |
| #2 | 1 | 20 000 | 2 | +1 | ×1.20 | +~12 min |
| #3 | 2 | 45 000 | 3 | +1 | ×1.30 | +~12 min |
| #4 | 3 | 80 000 | 4 | +1 | ×1.40 | +~13 min |
| #5 | 4 | 180 000 | 6 | +2 | ×1.60 | +~18 min |
| #6 | 6 | 405 000 | 9 | +3 | ×1.90 | +~22 min |

**UI:** persistent **„♻ PRESTIGE READY"** (jak boss CTA — opt-in, nigdy auto). Pokaż gdy `prestigeGain ≥ 1` i bieżący mnożnik przyspieszy re-grind o ≥30%. Pierwszy opłacalny prestige ~15-20 min od fresh save.

---

## 4. Gem sinks / faucets

**Before:** 1 faucet (Gold-boss), 1 sink (refill) → waluta martwa.
**Cel:** F2P zarabia ~5-6 gemów/dzień i ma na co wydać; premium dokupuje resztę.

### Faucety

| Faucet | Wartość | Uzasadnienie |
|---|---|---|
| Gold-boss drop | 2 gemy / Gold-tier boss | rzadki (0.32·chapterGoal) → premiowy |
| **Daily login** | dzień 1-7: 1,1,2,2,3,3,**5** (reset tyg.) | ~2.4 gem/dzień śr. |
| **Rewarded-ad „Tip Jar"** | 1 gem / ad, cap 3/dzień | reuse istniejącej infra ad (`rushAdBonus`) |
| **Chapter milestone** | co 5. chapter: 3 gemy | nagroda za progresję |

### Sinki

| Sink | Koszt | Uzasadnienie |
|---|---|---|
| **Fuel refill** (przemianowany) | 1 gem | impatience lever |
| **Overdrive Surge** | 3 gemy → 60 s Overdrive bez drenażu | premiowy spike (~×3.6/min), chętny w boss-rush |
| **Boss Retry / +15 s** | 2 gemy | konwersja porażki bossa (opt-in, nie blokuje F2P) |
| **Instant lane-auto unlock** | 5 gemów / lane | skraca grind idle; skaluje z 14 lanes |
| **Prestige skip-grind** (+1 ⭐) | 8 gemów, limit 1/prestige | whale sink; nie psuje krzywej §3 |

**Zasada zdrowia:** żaden gem-sink nie jest *jedyną* drogą do progresji rdzenia — gemy kupują **czas i wygodę**, nie **dostęp**. Spójne z „presja z czasu/skilla, nie z bariery".

---

# CZĘŚĆ B — SYSTEMY RETENCYJNE

## 5. Daily loop pod presję — „Daily Pressure Slate"

**Filozofia:** generyczny login-reward = anty-wzorzec. Logowanie *odblokowuje* slate; nagrodę zdobywa się **rękami na ekranie cięcia**. Złota zasada: *jeśli nagrodę da się odebrać bez dotknięcia ekranu cięcia — to zła nagroda.*

**Struktura:** 3 wyzwania/dzień (1 łatwe, 1 średnie, 1 trudne), **active-only** (auto-cutter/offline NIE liczą się do progresu). Komplet 3 → bonus-chest + tick streaka. **Reset 00:00 UTC.** Nieukończone przepadają bez kary.

### Pula wyzwań (10 do rotacji) — `pc` = prestige-currency (Stars-feed)

| # | Wyzwanie | Trudność | Warunek (active-only) | Nagroda (orientacyjna) |
|---|----------|----------|------------------------|------------------------|
| 1 | Combo Chain | Łatwe | combo x15 w jednym dishu | ~150 coins + 1 pc |
| 2 | Rush Service | Łatwe | podaj 12 dań manualnie | ~200 coins + 1 pc |
| 3 | Iron Hands | Łatwe | 5 dań bez wyzerowania Fuel | ~150 coins + 1 pc |
| 4 | Max Combo | Średnie | combo MAX (25) raz | ~300 coins + 2 pc |
| 5 | Silver Plate | Średnie | boss ≥Silver | ~400 coins + 2 pc + szansa gear |
| 6 | Speed Cuts | Średnie | 250 manualnych cięć | ~300 coins + 2 pc |
| 7 | Smart Prep | Średnie | wykorzystaj carryover w oknie 5 min | ~250 coins + 2 pc |
| 8 | Gold Plate | Trudne | boss na Gold | ~600 coins + 4 pc + gwar. gear |
| 9 | Flawless Boss | Trudne | boss bez wyzerowania Fuel | ~500 coins + 3 pc + 5 gems |
| 10 | Combo Marathon | Trudne | combo ≥20 przez 60 s łącznie | ~500 coins + 3 pc + 5 gems |

> Twarda waluta (gems) tylko na trudnych — drobny, zarobiony przez skill faucet (gems pozostają głównie premium). Gear drop wpina się w istniejący `gearDropMinScore`.

### Streak (nagradza konsekwencję, nie obecność — liczy dni z pełnym Daily Complete)

| Dzień streaka | Mnożnik nagród | Milestone |
|---|---|---|
| 1-2 | ×1.0 | — |
| 3-4 | ×1.15 | — |
| 5-6 | ×1.3 | — |
| 7 | ×1.5 | **Weekly Streak Chest:** ~10 gems + 5 pc |
| 8+ | ×1.5 (plateau) | chest co 7 dni |

**Streak-shield:** opuszczenie 1 dnia cofa o 1 poziom (nie zeruje); druga z rzędu absencja → reset do 1. Plateau ×1.5 zapobiega „przymusowi nie-do-stracenia".

**Sesja:** 3 wyzwania ≈ 1-2 boss-runy + cięcie = **~5-8 min**, spójne z beatem bossa.

### State

```
daily: { dateKey:"", slate:[ /*3× {id,progress,target,done}*/ ], completedToday:false, streak:0, lastCompleteKey:"" }
```

---

## 6. Weekly meta + rola prestige

| Warstwa | Pętla | Beat | Dostarcza |
|---|---|---|---|
| Sekundy-minuty | slice → dish → coins | combo, hold-slice | dopamina rdzenia |
| ~5-7 min | chapter → boss-rush | tier + perk + unlock | główny beat presji (istnieje) |
| Dzień | daily slate + streak | nowe cele + `pc` | powód codziennego powrotu (§5) |
| **Tydzień** | akumulacja `pc` → **PRESTIGE** | reset z mnożnikiem | week-to-week cel |

**Rola prestige (struktura):**
1. Opt-in CTA „♻ PRESTIGE READY" (jak boss). Nigdy auto.
2. Tempo **~1 prestige/tydzień** dla zaangażowanego gracza; 1. prestige ~D5-D7.
3. `pc` z dailies = **przyspieszacz prestige'a** (wydane przed resetem podbija start / pomija część grindu). Efekt: gracz codzienny prestiguje szybciej → domyka pętlę day↔week.
4. Po prestige onboarding leci skrótem (mnożnik → wczesne chaptery pędzą) → tydzień 2+ NIE jest pustym powtórzeniem.

**Anty-pustka:** prestige to *cel*, nie *brama*. Kto nie chce resetować — daily slate + streak + Rush Hour dają tygodniową treść.

### Weekly Pressure Pass — REKOMENDACJA: TAK, minimalny scope (nice-to-have)

Pełny 30-dniowy battle pass = za duży narzut na prototyp. Zamiast tego: **7-dniowy „Weekly Pressure Pass"** reużywający `pc` jako walutę postępu (zero nowego XP), ~10 progów, free-tor (coins/gems/gear + knife-skin na końcu). Tor premium **odroczyć** (lub jeden hak „×2 za rewarded-ad"). Ratio free:premium docelowo 1:3–1:5.

> **Priorytet:** §5 (daily) + §6.1-6.3 (prestige jako cel tygodnia) = **must-have**. Pass = **nice-to-have**, dodać po walidacji, że daily generuje dość `pc`.

---

## 7. Sekwencja odblokowań (onboarding systemów)

Zasada: **jeden system na raz**; max 1 nowy pełnoekranowy tutorial/CTA na sesję. Chapter = główny zegar onboardingu.

| # | Feature | Trigger | Powód timingu |
|---|---|---|---|
| 1 | Core slice (hold, combo, dish→coins) | Start | rdzeń — poczuj cięcie najpierw |
| 2 | Fuel/Overdrive | pierwsze wejście w Overdrive (1-2 min) | presja z gry, nie z tutoriala |
| 3 | Lanes / leveling | po 1. daniu / ~40 coins | 1. decyzja wydatkowa |
| 4 | Global upgrades | ~35 coins (`incomeCostBase`) | 2. warstwa wyborów |
| 5 | Boss / chapter | `chapterEarned ≥ chapterGoal()` (~5 min) | 1. duży beat presji (istnieje) |
| 6 | Carryover modifier | po 1. bossie (≥Bronze) | meta bez osobnego tutoriala |
| 7 | Auto-cutter (per-lane) | lane Lv10 | pierwsze idle, gdy active jest nawykiem |
| 8 | Daily Slate | start chapteru 1 LUB 1. powrót nazajutrz | dailies potrzebują znajomości boss+combo |
| 9 | Auto-Slicer | 4000 coins, gate chapter 3 (istnieje) | głębsze idle |
| 10 | Prestige | próg (~D5-D7 / chapter 5-6) | gdy gracz ma co resetować |
| 11 | Weekly Pressure Pass (opc.) | po 1. prestige / start 2. tygodnia | najwyższa meta |
| 12 | Rush Hour event | 1. weekend po odblokowaniu bossa | live-ops na końcu |

---

## 8. Live-ops hook — „Rush Hour" (szkielet)

Okresowe okno (np. weekend) z podkręconą presją i nagrodami. **Reużywa boss/rush pipeline — zero nowej mechaniki.**

| Element | Decyzja |
|---|---|
| Wyzwalacz | okno czasowe (Sob 00:00 → Niedz 23:59 UTC); w prototypie flaga `event.rushHourActive` |
| Modyfikator | boss-rush dostaje +czas LUB ×mnożnik wypłaty (liczba = strojenie ekonomii) |
| Aktywny hak | powtarzalny Rush Hour boss w oknie (nie raz/chapter) |
| Nagrody | podbity gear drop + bonus `pc`; **bez** ekskluzywnych itemów dających przewagę (kosmetyka/`pc` only → łagodne FOMO) |
| Powtarzalność | co tydzień → przegapienie = pominięcie dawki bonusu, nie unikalnej nagrody |
| UI | reuse boss CTA banner („🔥 RUSH HOUR" + countdown) |
| State | `event: { rushHourActive:false, endsAt:0 }` |

---

# CZĘŚĆ C — IMPLEMENTACJA

## 9. Zbiorczy diff CONFIG / SCHEMA

**CONFIG — usuń (stamina):** `staminaMaxBase, staminaMaxPerLevel, staminaRegenBase, staminaRegenPerLevel, staminaPerSlice, staminaCostBase, staminaCostGrowth, staminaRegenCostBase, staminaRegenCostGrowth, staminaRefillGems`

**CONFIG — dodaj:**
- Fuel/Overdrive: `fuelMaxBase, fuelMaxPerLevel, fuelRegenBase, fuelRegenPerLevel, fuelEmptyRegenMult, overdriveThreshold, overdriveDrainPerSlice, overdriveValueMult, overdriveSpeedMult, fuelMaxCostBase, fuelMaxCostGrowth, fuelRegenCostBase, fuelRegenCostGrowth, fuelRefillGems` (wartości §1.3)
- Auto-Slicer: `autoChefBaseMs, autoChefSpeedPerLevel, autoChefNeverOverdrive` (§2)
- Prestige: `starK, starScale, starBonus` (§3)
- Gem economy + daily/event nagrody: wartości §4, §5 (przenieść do CONFIG lub osobnej tabeli danych)

**SCHEMA_DEFAULT — zmień/dodaj:**
```
- stamina:{cur:CONFIG.staminaMaxBase}
+ fuel:{cur:CONFIG.fuelMaxBase}
  progression: { ..., fuelMaxLevel:0, fuelRegenLevel:0, autoChefSpeedLevel:0, stars:0, prestiges:0 }
+ daily: { dateKey:"", slate:[], completedToday:false, streak:0, lastCompleteKey:"" }
+ event: { rushHourActive:false, endsAt:0 }
+ pass: { /* opcjonalnie, gdy Weekly Pressure Pass wejdzie */ }
```
`deepDefault` (l.495) zapewnia kompatybilność starych save'ów — bez ręcznej migracji.

## 10. Checklist implementacyjny (kolejność)

- [ ] **A1** — Fuel/Overdrive: usuń twardy blok (l.764), dodaj stałe + formuły §1.3-1.4, podłącz pasek UI „Fuel/power".
- [ ] **A2** — Rozdziel Auto-Slicer od Fuel (usuń l.803-804, 877), dodaj `autoChefMs()` §2.
- [ ] **A3** — Walidacja out-earn 2.5-5× (active Normal vs pełny idle stack) — strojenie lane-autos jeśli poza pasmem.
- [ ] **A4** — Prestige: waluta Stars, `prestigeGain`, reset logic, CTA „♻ PRESTIGE READY".
- [ ] **A5** — Gem faucety (login, ad Tip Jar, milestone) + sinki (Surge, Retry, lane-unlock, prestige-skip).
- [ ] **B1** — Daily Pressure Slate: generacja 3 wyzwań/dzień, tracker active-only, reset UTC, chest.
- [ ] **B2** — Streak + streak-shield + Weekly Streak Chest.
- [ ] **B3** — Prestige jako cel tygodniowy (`pc` przyspieszacz) — strojenie tempa ~1/tydzień.
- [ ] **B4** — (nice-to-have) Weekly Pressure Pass: 7 dni, 10 progów, free-tor.
- [ ] **B5** — Rush Hour event flag + boss modyfikator + UI banner.
- [ ] **C1** — Onboarding gating wg §7 (max 1 nowy CTA/sesja).

## 11. Otwarte pytania do walidacji

1. **Stamina/Fuel — A/B:** trzymam, że twardy blok był najsłabszym ogniwem. Co potwierdziłoby starą wersję (twardy blok): dane, że gracze **refillują za gemy** zamiast odbijać przy 0. Jeśli taki sygnał się pojawi — twardy blok się broni.
2. **Strojenie liczb:** `starScale`, `overdriveValueMult`, dzienne wartości gemów i `pc` → walidacja na realnych benchmarkach (pliki/web niedostępne w tym przebiegu).
3. **Balans `pc`:** ile `pc`/dzień daje pełen daily vs ile realnie przyspiesza 1 prestige (cel: 1 prestige/tydzień).

---

*Patch złożony z dwóch specjalistycznych analiz (Economy + Systems) + decyzji projektowej o tożsamości. Plik źródłowy `index.html` nietknięty — to dokument projektowy/patch, nie zmiana kodu.*
