# PATCH: Match-Masters-style Booster System (v5.2)

**Applies to:** `index-arrows-v5.1.html` (ARROWS GO! — turn-based PvP arrow puzzle)
**Date:** 2026-05-14
**Purpose:** Wprowadzić warstwę boosterów spójną z archetypem Match Masters (Candivore) — pre-match equip, in-match charge, jednorazowe użycie, wymierne skill expression, brak "win buttonów". Sześć boosterów dobranych pod core mechaniki prototypu (exit rule, cascade, streak).

**Source for archetype assumptions:** Naavik — *Match Masters: A Global Success No One Believed In* (2024-03); Gamersdunia *Match Masters Boosters List 2025*; Candivore Zendesk *Booster Stakes Multiplier* via search snippet (2026-05). Wszystkie szczegóły procedurowe MM oznaczone w sekcji **§ 0** poniżej.

---

## § 0 — Reference assumptions (MM-faithful)

To, co kopiujemy z Match Masters i co celowo upraszczamy w MVP:

| MM mechanic | Co bierzemy do MVP | Co odkładamy (post-MVP) |
|---|---|---|
| 1 booster equipped per match | ✅ Tak | — |
| Booster charge przez "blue stars" (7 na ładowanie) | ✅ Adaptowane: charge przez cascade depth + streak ticks | Visual "star bar" UI — w v5.3 |
| Booster activation = 1 tap, instant effect | ✅ Tak | — |
| Booster Stakes (×N multiplier z lossem) | ⏸ Defer | v5.4 lub razem z meta layer |
| 4 rarity tiers (Bronze/Silver/Gold/Diamond) | ⏸ Defer | wszystkie 6 boosterów są "flat tier" w MVP |
| Perk slot (osobny od booster slot) | ⏸ Defer | v5.3 |
| Booster Shield consumable | ⏸ Defer | tylko gdy Stakes wejdą |

**Decyzja architektoniczna:** w MVP — **1 slot, 1 booster, 1 użycie/mecz**. Nie wprowadzać rzadkości, perków, stakes — dodać ścieżkę upgrade'u jednym patchem po playteście.

---

## § 1 — Summary of changes

1. Nowy moduł **`BOOSTERS`** — definicje 6 boosterów (id, name, color, activation behavior).
2. Pre-match **booster pick screen** — gracz wybiera 1 booster z 6 (MVP: wszystkie dostępne za darmo; post-MVP: inventory).
3. **Booster charge bar** w HUD — ładuje się 0 → 100 podczas meczu; gdy pełny, booster button staje się tappable.
4. **Charge accrual rules** — punkty ładowania z cascade depth, streak ticks, i partial slides (no-exit moves NIE ładują, by uniknąć farmingu pustych ruchów).
5. **Booster activation handler** — różny per booster; wszystkie integrują się z istniejącym `cascadeQueue` / `streakFlags` / `state.grid`.
6. **Bot booster AI** — bot dostaje losowy booster, ładuje go tym samym systemem, aktywuje heurystyką (poniżej).
7. **Result screen** — pokazuje czy booster został użyty (tracking pod przyszły Stakes system).

---

## § 2 — Booster catalog (6 sztuk, MVP)

Wszystkie boostery są **single-use per match**, wymagają **full charge bar (100)** przed aktywacją, są tappable tylko **w twojej turze** i **poza aktywnym cascade**.

### 2.1 `PATH_CLEAR` — Line Sweep
**Kategoria:** A (line clear directional) — MM analog: *Crazy Rocket / Sweep It*
**Effect:** Gracz tapuje wybrany rząd LUB kolumnę z board overlay (rows/cols highlight). Wszystkie strzały, których HEAD leży na wybranej linii, **w kolejności od najbliższej krawędzi w stronę kierunku ich `dir`**, próbują wyjść:
- jeśli `slideDistance(grid, arr).offBoard === true` → exit z normalnym scoringiem (jak manual tap), **ale BEZ wkładu do streak** (booster ≠ skill move) i **bez cascade**.
- jeśli `offBoard === false` → strzała znika bez punktów (nie ma "partial slide for free").

**Tradeoff dla skill expression:** wybór wiersza/kolumny z największym ratio "fires-able / wasted arrows" — gracz musi czytać planszę.
**Implementation note:** iterować po `state.arrows` filtr `arr.headY === row` (lub `headX === col`), sortować po `dir`-relative distance to edge, releaseArrow() w pętli.

---

### 2.2 `RICOCHET` — Bend
**Kategoria:** E (cascade enabler) — **arrow-puzzle native** mechanic, brak MM analoga
**Effect:** Gracz tapuje 1 dowolną strzałę → jej `dir` rotuje o 90° (default: clockwise; long-press = counter-clockwise). Tap nie odpala strzały — to czysty setup move (nie konsumuje `movesLeft`).
**Tradeoff:** marnowany jeśli nowy kierunek nadal nie jest valid; wymaga read board geometry. Najwyższy skill ceiling z całej szóstki.
**Implementation note:** zmień `arr.dir`; przerenderuj DOM strzałki (rotacja transform). Nie wywołuj `releaseArrow()`. Nie konsumuje `state.movesLeft`.

---

### 2.3 `FIRESTORM_CHARGE` — Hot Start
**Kategoria:** G (multiplier / streak boost) — MM analog: *Energy Boost perk + Checkmate Charles tempo*
**Effect:** Twój `streak` jumps to threshold T2 (current `streakFlagsYou.t2Active = true`), pierwszy następny exit od razu dostaje `STREAK_T2_BONUS` (+20%). Tier 3 (+1 move) osiągany po 2 exitach od momentu aktywacji zamiast 3.
**Tradeoff:** zmarnowany jeśli nie zrobisz min. 2 udanych exitów w turze aktywacji. Nie pomaga zablokowanym planszom.
**Implementation note:** ustaw `state.streakYou = streakThresholds.t2` (lub odpowiednik current state); ustaw `streakFlagsYou.t2 = true` i `t2Active = true`. NIE odpalaj banner T2 (to nie był "real" streak — pokaż osobny "HOT START" banner).

---

### 2.4 `EXTRA_MOVE` — Encore
**Kategoria:** H (chain extender) — MM analog: *Billie Boom / Cross Perk*
**Effect:** `state.bonusMovesYou += 1` natychmiastowo. Jeśli `movesLeft === 0` ale tura jeszcze nie przełączona (timer biegnie) — gracz dostaje +1 move od razu w tej turze.
**Tradeoff:** najprostszy booster — niska skill in execution, średnia w timingu. To safety net dla casual segmentu, kategorialnie ważny dla retention. Trzymamy go w katalogu mimo low skill expression.
**Implementation note:** trywialne — używać tej samej ścieżki co istniejący `bonusMovesYou` z streak T3.

---

### 2.5 `ROTATE_PAIR` — Twist
**Kategoria:** I (board manipulator) — MM analog: *Mastermind setup*
**Effect:** Gracz tapuje 2 sąsiednie strzały (musi być head-to-head 4-neighbor adjacent — używać tej samej `wouldCreateBlockingCycle` adjacency definition co cascade). Obie strzały rotują o 90° clockwise. Wymaga, by po rotacji ich kształty (`shapeCells`) były nadal valid (nie wychodzą poza grid, nie kolidują z innymi strzałami) — w przeciwnym razie aktywacja anulowana, booster NIE konsumowany.
**Tradeoff:** najmocniejszy setup tool, ale 2 ruchy ROTATE bez exit = 0 punktów. Sukces wymaga PO rotacji wykonania właściwego tapu (kolejny ruch).
**Implementation note:** weryfikacja `canPlace(grid, arr.headX, arr.headY, {tplIdx: arr.tplIdx, dir: rotateClockwise(arr.dir)})` po wyłączeniu obu strzał z gridu. Jeśli OK — apply; jeśli nie — flash invalid + abort.

---

### 2.6 `OVERDRIVE` — Direction Lock
**Kategoria:** C (filter buff) — MM analog: *Paint Bucket / Doctor Color*
**Effect:** Gracz wybiera 1 z 4 kierunków (↑↓←→) z modal pickera. **Na tę turę** (i tylko tę turę) wszystkie cascade chains starting from arrow o tym `dir` dostają:
- `CASCADE_DEPTH_CAP`: 4 → 6
- `CASCADE_HARD_LIMIT`: 6 → 8
- `CASCADE_ARROW_LIMIT`: 8 → 12
**Tradeoff:** bezużyteczny jeśli plansza nie ma dominującego kierunku; wybiera się ZANIM odpalisz cascade — read-ahead skill.
**Implementation note:** dodać `state.overdriveDir = null` + `state.overdriveExpiresAtTurnEnd = false`. W `releaseArrow` / cascade enqueue logic — jeśli `arr.dir === state.overdriveDir`, użyj rozszerzonych capów. Reset na `switchTurn()`.

---

## § 3 — Constants block

Dodać w bloku v5.1 tuning knobs (po linii 204):

```js
// v5.2 — Booster tuning knobs
const BOOSTER_CHARGE_MAX        = 100;     // full bar threshold
const CHARGE_PER_EXIT_MANUAL    = 12;      // your tap, off-board exit
const CHARGE_PER_CASCADE_HIT    = 6;       // each arrow released via cascade
const CHARGE_PER_STREAK_TICK    = 8;       // each streak threshold crossed (T2/T3/T4/T5)
const CHARGE_PER_PARTIAL_SLIDE  = 0;       // explicit zero — no-exit moves don't charge
const CHARGE_PER_TIER_BONUS     = [0,2,4,8]; // common/rare/epic/legendary extra on exit
const BOOSTER_OVERDRIVE_CAPS    = { depth:6, hard:8, arrow:12 };
const BOOSTER_FIRESTORM_PRESET_TIER = 2;   // which streak tier to preset
```

**Rationale liczbowe:**
- Average match: ~12-18 udanych exitów (3 min × 2 graczy × ~3 exits/turn). Z `CHARGE_PER_EXIT_MANUAL=12` → potrzeba ~9 udanych exitów na full bar → booster gotowy do użycia w **drugiej połowie meczu**. To intencja: MM ładuje booster do końca 2-3 rundy, nie od razu.
- Cascade hits ładują wolniej (6 vs 12) — premia za skill, ale nie pozwala farmować chargeu przez 1 setup-cascade.
- Tier bonus (`legendary +8 charge`) lekko skaluje, by gold arrows były bardziej "value-loaded".

---

## § 4 — State additions

Rozszerzyć `state` object (po linii 281):

```js
boosters: {
  you: {
    equipped: null,        // 'PATH_CLEAR' | 'RICOCHET' | ...
    charge: 0,             // 0..BOOSTER_CHARGE_MAX
    used: false,           // once-per-match
    targeting: null,       // null | 'row'|'col'|'arrow'|'pair'|'dir' — UI state
  },
  opp: {
    equipped: null,
    charge: 0,
    used: false,
    targeting: null,
  },
},
overdriveDir: null,        // 'up'|'down'|'left'|'right'|null
overdriveOwner: null,      // 'you'|'opp' — whose turn it lasts for
```

Reset blocks:
- `resetMatch()` (lub equivalent w prototypie): zerować `boosters.*.charge`, `used=false`, `targeting=null`, `overdriveDir=null`. Pre-match equip NIE jest resetowany w ramach match — ustawiany przez pre-match screen.
- `switchTurn()` po przełączeniu: jeśli `overdriveOwner !== state.turn` → `overdriveDir = null; overdriveOwner = null` (overdrive wygasa razem ze swoją turą).

---

## § 5 — Charge accrual hooks

Należy zmodyfikować existing functions w prototypie:

### 5.1 `releaseArrow(arr, owner, isCascade)` (lub ekwivalent)

Po sukcesie exit (offBoard true):

```js
// existing scoring logic...

// v5.2: booster charge
const target = state.boosters[owner];
if (!target.used && target.equipped) {
  const tierIdx = arr.tierIdx;
  const tierBonus = CHARGE_PER_TIER_BONUS[tierIdx] || 0;
  const base = isCascade ? CHARGE_PER_CASCADE_HIT : CHARGE_PER_EXIT_MANUAL;
  target.charge = Math.min(BOOSTER_CHARGE_MAX, target.charge + base + tierBonus);
  updateBoosterUI(owner);
}
```

### 5.2 Streak threshold crossings

W miejscu gdzie aktualnie ustawiasz `streakFlags*.tN = true` po raz pierwszy (T2/T3/T4/T5), dodać:

```js
const target = state.boosters[owner];
if (!target.used && target.equipped) {
  target.charge = Math.min(BOOSTER_CHARGE_MAX, target.charge + CHARGE_PER_STREAK_TICK);
  updateBoosterUI(owner);
}
```

**WAŻNE:** charge accrual z streaków nie liczyć dla T2 jeśli T2 został ustawiony przez `FIRESTORM_CHARGE` booster (sprawdzić flag — np. `streakFlagsYou.t2FromBooster`). Inaczej booster ładuje się sam → exploit.

### 5.3 Partial slides

Explicit no-op: `CHARGE_PER_PARTIAL_SLIDE = 0`. Nie dodajemy hooka — to świadoma decyzja.

---

## § 6 — Activation flow per booster

Szkielet handler (do umieszczenia w nowym module `Boosters`):

```js
function activateBooster(owner) {
  const b = state.boosters[owner];
  if (b.used || !b.equipped) return;
  if (b.charge < BOOSTER_CHARGE_MAX) return;
  if (state.turn !== owner) return;
  if (state.cascadeOwner) return; // cascade in progress
  if (state.inputLocked) return;

  switch (b.equipped) {
    case 'PATH_CLEAR':       startTargeting(owner, 'rowcol'); break;
    case 'RICOCHET':         startTargeting(owner, 'arrow', { rotateOnly: true }); break;
    case 'FIRESTORM_CHARGE': applyFirestormCharge(owner); finalizeBooster(owner); break;
    case 'EXTRA_MOVE':       applyExtraMove(owner); finalizeBooster(owner); break;
    case 'ROTATE_PAIR':      startTargeting(owner, 'pair'); break;
    case 'OVERDRIVE':        startTargeting(owner, 'dir'); break;
  }
}

function finalizeBooster(owner) {
  state.boosters[owner].used = true;
  state.boosters[owner].charge = 0;
  state.boosters[owner].targeting = null;
  updateBoosterUI(owner);
}
```

**Per-booster activation funkcje** (`applyPathClear`, `applyRicochet`, `applyFirestormCharge`, `applyExtraMove`, `applyRotatePair`, `applyOverdrive`) — implementacje w § 2.

---

## § 7 — UI changes

### 7.1 HUD — booster slot per player

Dodać do istniejącego HUD (po score / streak indicator):

```
+------------+
| [icon]     |  ← booster icon (greyed gdy not full)
| ▓▓▓▓░░░░░░ |  ← charge bar 0..100
+------------+
```

Po stronie `you` — tappable button gdy `charge === MAX` && `!used` && `state.turn === 'you'` && `!state.cascadeOwner`. Pulse glow na fully charged.
Po stronie `opp` — read-only display (gracz widzi że bot ma boostera ready jako tension cue).

### 7.2 Pre-match booster picker

Nowy overlay przed `intro` overlay. 6 kart 2×3 grid, każda z:
- Icon (placeholder emoji ok dla MVP)
- Name
- Short description (1 linia, ~50 chars)
- Tap → highlight + "CONFIRM" button → set `state.boosters.you.equipped` → bot losuje swoje → start match

**Bot pick rule (MVP):** uniform random z 6.

### 7.3 Targeting overlays

Per targeting type:
- `'rowcol'` (PATH_CLEAR): pokazać kratki podświetlone na hover po row/col; tap = confirm
- `'arrow'` (RICOCHET): pokazać outline na każdej strzałce; tap = rotate
- `'pair'` (ROTATE_PAIR): pierwsza strzała highlight selected, druga musi być adjacent valid (highlight tylko adjacent legal options)
- `'dir'` (OVERDRIVE): 4-button picker ↑↓←→ as modal

Wszystkie targeting overlays mają **CANCEL button** — anuluje bez konsumpcji boostera.

### 7.4 Result screen

Po match end, w result overlay dodać 1 linię: "Booster used: <Name>" lub "Booster unused" (pod przyszły Stakes system trzeba wiedzieć czy zużyty).

---

## § 8 — Bot booster AI (MVP heuristic)

Bot aktywuje booster gdy:
- `charge === MAX` ORAZ
- jest jego tura ORAZ
- prosta heurystyka per booster:

| Booster | Bot aktywuje gdy |
|---|---|
| `PATH_CLEAR` | Istnieje row/col z ≥ 2 strzałami z `offBoard:true` → ten row/col |
| `RICOCHET` | Istnieje strzała, której po rotacji o 90° `slideDistance().offBoard` staje się true → ta strzała |
| `FIRESTORM_CHARGE` | Bot ma ≥ 2 dostępne `offBoard:true` arrows do zagrania w tej turze → aktywuj na początku tury |
| `EXTRA_MOVE` | `movesLeft === 0` i istnieje ≥ 1 valid exit move → aktywuj |
| `ROTATE_PAIR` | Istnieje para adjacent która po rotacji daje ≥ 1 nowy valid exit → ta para |
| `OVERDRIVE` | Najliczniejszy `dir` na planszy ma ≥ 3 strzały i ≥ 1 z nich może uruchomić cascade depth ≥ 2 |

Jeśli żadna heurystyka nie trigger'uje przez 2 tury z full charge — bot aktywuje "best available" w turze 3 (nie marnujemy ładunku, gracz musi widzieć że bot użył boostera).

**Out-of-scope dla MVP:** bot pre-pick strategy (np. dopasowanie boostera do board layout). Random pick wystarczy do playtestu.

---

## § 9 — Balance risks & acceptance gates

### 9.1 Self-flagged ryzyka

- **🟡 RICOCHET trywializuje cascade.** Jeśli gracz dostanie booster gdy na planszy jest "1 obrót do firestorm" — to single-button win. **Mitigation:** RICOCHET ładuje się standardowymi rule'ami (≥ 9 exits before charge), więc nie aktywuje się przed turn 4-5. Sprawdzić w playtest: czy RICOCHET aktywacja w turach 4-6 daje win rate >55% — jeśli tak, podnieść `BOOSTER_CHARGE_MAX` do 120 i zostawić accrual rates.
- **🟡 OVERDRIVE × FIRESTORM stacking.** Jeśli FIRESTORM_CHARGE → exit → exit → T3+ z OVERDRIVE buffem na ten sam kierunek = 30+ pts/tura. **Decyzja:** akceptujemy w MVP, mierzymy. Jeśli >25% meczy ma turn-score >40 — wprowadzić rule "tylko 1 booster effect aktywny na turę".
- **🟡 PATH_CLEAR wyrzuca legendary arrows bez cascade.** Może być źle odebrany jako "marnowanie wartości". **Mitigation:** w UI overlay dla rowcol pokazać tier dot na każdej strzale tak by gracz świadomie wybierał. **NIE** dawać "skip legendary" — to dodaje complexity bez wartości.
- **🟢 EXTRA_MOVE low skill** — akceptowane jako safety net dla casual segmentu (zob. § 2.4 rationale).

### 9.2 Acceptance checklist (przed merge)

- [ ] Każdy z 6 boosterów aktywuje się i kończy bez exception w console.
- [ ] Booster charge bar pełna w 8-12 udanych exitach (z różnymi tierami).
- [ ] FIRESTORM_CHARGE nie powoduje recursive charge (nie ładuje sam siebie via T2 hook).
- [ ] PATH_CLEAR rygorystycznie tylko exit arrows, nie partial slide.
- [ ] ROTATE_PAIR anuluje się czysto przy invalid rotation (no state corruption).
- [ ] OVERDRIVE wygasa na koniec własnej tury (overdriveDir = null po switchTurn).
- [ ] Bot używa boostera w 90%+ meczy (mierzy się przez log w console).
- [ ] Result screen pokazuje booster usage stan dla obu graczy.
- [ ] Pre-match picker działa na touch i mouse.
- [ ] Brak race condition: booster button disabled podczas active cascade.

### 9.3 Out-of-scope (świadomie odłożone)

- Booster rarities (Bronze/Silver/Gold/Diamond)
- Booster inventory / earn loop (post-match drops)
- Booster Stakes (×N wager z lossem)
- Booster Shield consumable
- Perks (osobny slot)
- Booster cosmetics / SE variants
- Charge bar animations beyond simple width transition
- Audio cues per booster activation

---

## § 10 — File organization

**Single-file prototype constraint** — wszystkie zmiany w `index-arrows-v5.1.html` → zapis jako `index-arrows-v5.2.html` (zachować v5.1 jako reference).

Sugerowany internal layout (komentarze sekcyjne):

```
// === v5.1 constants ===
// (existing)

// === v5.2 booster constants ===  ← § 3

// === v5.2 booster catalog ===
const BOOSTERS = { PATH_CLEAR: {...}, RICOCHET: {...}, ... };

// === v5.2 state additions ===  ← § 4

// (existing game functions)

// === v5.2 booster system ===
//   activateBooster, finalizeBooster, applyPathClear, applyRicochet, ...
//   startTargeting, cancelTargeting
//   updateBoosterUI, drawChargeBar
//   botBoosterTick (called from existing bot loop)
```

**UI additions** — nowe overlay-y `<div id="overlay-booster-pick">`, `<div id="overlay-targeting">`, plus booster slot markup w HUD.

---

## § 11 — Implementation order (suggested)

1. **Constants + state** (§ 3, § 4) — bez UI, tylko struktura
2. **Charge accrual** (§ 5) — z console.log, verify że bar pełnia w expected liczbie ruchów
3. **HUD booster slot UI** (§ 7.1) — readonly view bar
4. **Pre-match picker** (§ 7.2) — najprostsze, set equipped, hard-coded pick=PATH_CLEAR żeby kontynuować test
5. **Activation skeleton** (§ 6) — handler + finalize, bez per-booster effects
6. **EXTRA_MOVE** (§ 2.4) — najprostszy, validate end-to-end flow
7. **FIRESTORM_CHARGE** (§ 2.3) — drugi non-targeting
8. **PATH_CLEAR** (§ 2.1) — pierwszy targeting (rowcol)
9. **OVERDRIVE** (§ 2.6) — dir picker
10. **RICOCHET** (§ 2.2) — single-arrow targeting
11. **ROTATE_PAIR** (§ 2.5) — pair targeting (most complex)
12. **Bot AI** (§ 8) — po wszystkich graczy boosterach działających
13. **Result screen + acceptance gates** (§ 9.2)

Każdy krok = osobny commit, testowalny standalone.

---

## § 12 — Open questions for playtest

1. Czy 1 booster/mecz to wystarczająco "feel" dla MM-faithful audience, czy gracze będą chcieli 2-3 (jak post-MVP perk slot)?
2. Czy `BOOSTER_CHARGE_MAX = 100` z accrual rates daje booster ready w połowie meczu — czy szybciej/wolniej?
3. Czy ROTATE_PAIR jest zrozumiały bez tutorial overlay, czy wymaga FTUE step?
4. Który booster ma najwyższy use rate? Który najniższy? (Telemetry hook w `finalizeBooster`.)
5. Czy RICOCHET single-button-win risk się materializuje?
6. Czy bot z `random pick + heuristic activate` jest "fair" — czy gracze postrzegają bot booster jako BS?

---

**Patch ready for implementation. Recommend creating worktree branch `feature/v5.2-boosters` from current state of `match-arrows/`.**
