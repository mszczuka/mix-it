# Faza 1 — Spięcie luźnych systemów (spec implementacyjny)

> Cel: koniec wiszących luzem systemów. Automatyzacja staje się czytelną **brygadą whole-mine**, cel działki wyzwala makro, loot przestaje rozjeżdżać ekonomię i przenosi się na cash-out, 3 martwe staty zaczynają działać.
> Zależy od Fazy 0 (offline, `auto_gps()`, persystencja). Pseudokod = specyfikacja.
> Model (spójny z DESIGN §1, §3): **części = jak dobra linia; brygada = czy jedzie sama. Bez operatorów per-stacja.**

---

## 0. Granice Fazy 1

**ROBIMY:** refaktor `workers` per-lokacja → jedna brygada `crew`; przebudowa ekranu DZIAŁKI na progresję lokacji; przeniesienie działki po celu; cap na loot; loot → warsztat/cash-out; ożywienie 3 martwych statów; sprzątnięcie martwych pól.

**NIE robimy jeszcze:** linia/bufory/wąskie gardła i fokus (Faza 2), **ożywienie 9 zablokowanych części** (Faza 2 — tam mają czym sterować: przepustowość), koniec auto-sprzedaży + model ceny (Faza 2), premium currency/sklep (Faza 2), retencja (Faza 3).

---

## 1. Brygada whole-mine (refaktor `workers`)

Dziś `workers` jest per-lokacja (`{"california":0,"alaska":0}`) — to fasada. Zamieniamy na **jedną brygadę** obsługującą całą linię (spójne z Fazą 0, gdzie `auto_gps()` już liczy whole-mine).

### 1.1 Model danych

```
# ZASTĄP: var workers := {"california":0,"alaska":0}
var crew: int = 0                 # liczba brygad (whole-mine); 0 = brak AUTO

const CREW_BASE := 150.0
const CREW_MULT := 1.8            # stroma krzywa (rekomendacja ekonomii)
const MAX_CREW := 5

func crew_cost() -> float:
    return round(CREW_BASE * pow(CREW_MULT, crew))

func can_hire_crew() -> bool:
    return crew < MAX_CREW and cash >= crew_cost()

func hire_crew() -> bool:
    if not can_hire_crew():
        return false
    cash -= crew_cost()
    crew += 1
    cash_changed.emit(cash)
    crew_changed.emit()           # NOWY sygnał (zastępuje workers_changed)
    return true

signal crew_changed
```

### 1.2 Przepięcie AUTO z Fazy 0 na `crew`

Faza 0 miała `automation_level()` z `total_workers()`. Zastępujemy jednym licznikiem:

```
# poziom automatyzacji 0..1 (whole-mine)
func automation_level() -> float:
    return clampf(float(crew) / float(MAX_CREW), 0.0, 1.0)

# auto_gps() z Fazy 0 — bez zmian strukturalnych, tylko źródło automation_level:
func auto_gps() -> float:
    if automation_level() <= 0.0:
        return 0.0
    var base := manual_ref_gps() * AUTO_EFFICIENCY * automation_level()
    return base * (1.0 + auto_recovery())
```

Interpretacja: pełna brygada (`crew = MAX_CREW`) → AUTO ≈ `manual_ref_gps() * 0.28` (~1/3.5 uzysku ręcznego). Zero brygady → zero AUTO. **Wąskie gardło z części dochodzi w Fazie 2** — tu AUTO jest jeszcze whole-mine bez etapów.

### 1.3 Sprzątnięcie po `workers`

- Usuń `workers`, `MAX_WORKERS`, `IDLE_G_PER_WORKER_PER_MIN`, `worker_cost`, `can_buy_worker`, `buy_worker`, `total_workers`, `worker_count`, sygnał `workers_changed`.
- W `main.gd`: `workers_changed.connect(_refresh_plots)` → `crew_changed.connect(...)`; usuń `_on_buy_worker`; przenieś najem brygady do jednego miejsca (patrz §2 — nowy przycisk na HOME lub w overlayu DZIAŁKI jako pojedyncza pozycja, nie sloty per-lokacja).

---

## 2. Przebudowa ekranu DZIAŁKI (workers → progresja lokacji)

**Uwaga (delta vs kod):** obecny `main.gd` (`_refresh_plots`, ~477–537) rysuje sloty pracowników per-lokacja (`ZATRUDNIJ $X`, sloty ●/+, `MAX_WORKERS`) + `_on_buy_worker`/`_on_unlock_location`. To znika.

- **DZIAŁKI** staje się listą lokacji z: bieżącą działką (postęp do `plot_goal`), grade rudy, kosztem przenosin, statusem odblokowania. Usuń sloty pracowników i `_on_buy_worker`; `_on_unlock_location` zostaje (przenosiny).
- **Najem brygady** ląduje w jednym miejscu (pojedyncza pozycja „BRYGADA: N/5 [ZATRUDNIJ $X]"), np. na HOME lub jako jeden wiersz w DZIAŁKI. Nie sloty per-lokacja.

### 2.1 Rozszerzenie lokacji na działki

```
var locations := [
    {"id":"california", "name":"Kalifornia", "unlocked":true,  "unlock_cost":0.0,    "plot_goal":50.0,  "grade":1.0},
    {"id":"alaska",     "name":"Alaska",     "unlocked":false, "unlock_cost":2000.0, "plot_goal":140.0, "grade":1.6},
    {"id":"yukon",      "name":"Jukon",      "unlocked":false, "unlock_cost":9000.0, "plot_goal":380.0, "grade":2.5},
    {"id":"klondike",   "name":"Klondike",   "unlocked":false, "unlock_cost":32000.0,"plot_goal":950.0, "grade":3.8},
    # ... docelowo 5–8 działek (liczby stroi ekonomia; profil idle: content na 30–90 dni)
]
var current_location := "california"

func current_grade() -> float:
    return location_by_id(current_location).get("grade", 1.0)
```

### 2.2 Wpięcie grade w uzysk

```
func gold_per_nugget() -> float:
    return (0.8 + 0.18 * _e("table","nachylenie")) \
        * bonus_gold_mult * gold_grade() * gold_mult_wash() * gold_retain_mult() \
        * current_grade()      # <- NOWE: bogatsza działka = więcej złota/grudkę
```

### 2.3 Wyzwolenie po celu

`plot_goal` bierz z bieżącej lokacji (nie stałej `50.0`). Po `add_raw_gold(v, true)` sprawdź:
```
signal plot_completed(location_id)

func check_plot_complete() -> void:
    if plot_progress >= location_by_id(current_location).plot_goal:
        plot_completed.emit(current_location)   # main.gd → popup „przenieś sprzęt"
```

### 2.4 Przeniesienie sprzętu

```
func next_location_id() -> String:
    var idx := ... # indeks current_location w locations
    return locations[idx+1].id if idx+1 < locations.size() else ""

func move_to_next_plot() -> bool:
    var nid := next_location_id()
    if nid == "":
        return false                    # ostatnia działka — endgame (późniejszy prestiż-loop)
    var loc := location_by_id(nid)
    if not loc.unlocked:
        if cash < loc.unlock_cost:
            return false
        cash -= loc.unlock_cost         # koszt przenosin = sink gotówki
        loc.unlocked = true
    current_location = nid
    plot_progress = 0.0
    plot_name = loc.name
    plot_number = randi() % 9000 + 1000
    cash_changed.emit(cash)
    goal_changed.emit(plot_progress, loc.plot_goal)
    return true
```

Zasada: **part_levels i brygada ZOSTAJĄ** (przenosisz sprzęt). Zmienia się grade i ściana kosztów. Miękki prestiż bez pełnego resetu.

### 2.5 Popup „działka wyczerpana" (main.gd, reuse popup_layer)

```
┌───────────────────────────────────────┐
│   🏆  DZIAŁKA WYCZERPANA               │
│   Kalifornia — wydobyto 50 g           │
│   Następna: ALASKA (ruda ×1.6)         │
│   Koszt przenosin: $2000                │
│   [ PRZENIEŚ SPRZĘT ]   [ ZOSTAŃ ]      │
└───────────────────────────────────────┘
```
- `PRZENIEŚ` → `move_to_next_plot()`; brak kasy → disabled „brakuje $X".
- `ZOSTAŃ` → gracz dalej kopie (nadmiar ponad goal leci normalnie), popup wróci przy następnym wejściu/sprzedaży. Nie blokuj gry.

---

## 3. Cap na loot (koniec rozjeżdżania krzywej)

```
const CAP_GOLD_MULT    := 1.5
const CAP_GLINT_ADD     := 0.25
const FLOOR_RELOAD_MULT := 0.5

func apply_part(part: Dictionary) -> void:
    match part.kind:
        "gold":   bonus_gold_mult   = clampf(bonus_gold_mult + part.magnitude, 1.0, CAP_GOLD_MULT)
        "glint":  bonus_glint_add   = clampf(bonus_glint_add + part.magnitude, 0.0, CAP_GLINT_ADD)
        "reload": bonus_reload_mult = clampf(bonus_reload_mult - part.magnitude, FLOOR_RELOAD_MULT, 1.0)
```

Brak martwych dropów przy capie:
```
func available_loot_kinds() -> Array:
    var k := []
    if bonus_gold_mult   < CAP_GOLD_MULT:      k.append("gold")
    if bonus_glint_add   < CAP_GLINT_ADD:      k.append("glint")
    if bonus_reload_mult > FLOOR_RELOAD_MULT:  k.append("reload")
    return k
# pusta (wszystko na capie) → zamiast części drop „samorodek": mały cash (np. randf_range(30,90))
```
Loot-boost czasowy „ponad cap" (za gemy) dochodzi w Fazie 2.

---

## 4. Loot → warsztat + cash-out (decyzja z DESIGN §4)

### 4.1 Kumulacja zamiast przerwania

```
var found_parts: Array = []       # znaleziska bieżące, nierozliczone
const FOUND_PART_CHANCE := 0.20   # szansa na część przy udanym batchu (tunable)
```

W `main.gd`: **usuń 28%-owe `_show_loot_popup()` z `_reveal`** — `_reveal` woła teraz zawsze `_resolve_reveal()`. Znaleziska dodawaj po udanym zbiorze złota (gałąź gold w `_on_pick_done`):
```
if GameState.available_loot_kinds().size() > 0 and randf() < GameState.FOUND_PART_CHANCE:
    GameState.found_parts.append(GameState.roll_part())
    _update_workshop_badge()     # tylko badge, ZERO modala
```

### 4.2 Rozliczenie na ekranie sprzedaży

`_open_sell` (istnieje): jeśli `found_parts` niepuste → sekcja wrap-up nad przyciskiem sprzedaży (karty: KUP $X / ZEZŁOMUJ).
- `KUP` → `cash>=cost`: `add_cash(-cost)` + `apply_part(part)` + usuń z `found_parts`.
- `ZEZŁOMUJ` → usuń z `found_parts` (opcjonalnie drobny zwrot w Fazie 2).

> **Nota międzyfazowa:** auto-otwieranie sprzedaży po batchu usuwamy dopiero w Fazie 2. W Fazie 1 loot rozlicza się więc na (wciąż auto-otwieranym) ekranie sprzedaży — badge warsztatu (§4.3) domyka to, gdy auto-open zniknie.

### 4.3 Warsztat (badge na HOME)

- Badge z liczbą `found_parts.size()` (np. przy MASZYNY lub nowa ikona WARSZTAT).
- Tap → ta sama lista rozliczeniowa co §4.2 (rytm lootu ≠ rytm sprzedaży).

---

## 5. Ożywienie 3 martwych statów

| Stat (martwa) | Maszyna/część | Nowa rola | Wpięcie |
|---|---|---|---|
| `shake_target()` | koparka / silnik | **Próg odsłonięcia** — wyższy silnik = mniej smyrania do reveal | W `_erode_soil_at` zamień `0.68` na `reveal_threshold()`; `reveal_threshold() = lerp(0.68, 0.45, norm(silnik))` |
| `glint_window()` | płuczka / sita | **Okno tolerancji po reveal** — masz `glint_window()` s zanim uzysk łagodnie spada; wyższe sita = więcej luzu | Timer w `S.REVEALED`; po przekroczeniu mnożnik uzysku maleje ku `auto_recovery()` floor |
| `water_power()` | pompa / silnik | **Moc płukania** — mnożnik tempa zmywania błota; szybciej = krótszy cykl | W `_clean_at` przemnóż ilość zdejmowanego błota/tick przez `water_power()` |

`auto_recovery()` podłączona już w Fazie 0. Po Fazie 1 z 4 martwych statów zostaje zero. `part_effect_text` dla tych części aktualizuje opis (np. „Próg odsłonięcia: X%").

---

## 6. Sprzątnięcie martwych pól (main.gd)

Usuń nieużywane pozostałości: `EXIT_Y`, `_glint_end_y`, `_pile_speed`, `_shake`, `_shake_accum`, `_batch_gold`, `_mud_cleared`, `_mud_total` (potwierdzone jako martwe; smyranie/czyszczenie liczą `_soil_opaque_*`/`_clean_*`). Jeśli §5 przejmuje część logiki (próg odsłonięcia), zostaw tylko realnie użyte.

---

## 7. Parametry (do strojenia)

| Parametr | Wartość start | Uwaga |
|---|---|---|
| `CREW_BASE` / `CREW_MULT` | 150 / 1.8 | krzywa brygady |
| `MAX_CREW` | 5 | |
| `CAP_GOLD_MULT` | 1.5 | twardy cap permanentnego bonusu |
| `CAP_GLINT_ADD` | 0.25 | |
| `FLOOR_RELOAD_MULT` | 0.5 | |
| `FOUND_PART_CHANCE` | 0.20 | na udany batch |
| działki grade/goal/cost | §2.1 | stroi ekonomia |
| `reveal_threshold` zakres | 0.68 → 0.45 | koparka silnik |

---

## 8. Testy akceptacyjne

1. **Brygada włącza AUTO:** `crew=0` → `auto_gps()=0`; `crew≥1` → `auto_gps()>0`; `crew=MAX_CREW` → ≈ `manual_ref_gps()*0.28`.
2. **Refaktor workers:** brak referencji do `workers`/per-lokacja pracowników; gra kompiluje; DZIAŁKI pokazuje progresję lokacji, nie sloty pracowników.
3. **Cel działki wyzwala:** dobij `plot_goal` aktywnie → popup „przenieś sprzęt"; przeniesienie zeruje `plot_progress`, podnosi grade, part_levels i `crew` zachowane.
4. **Grade działa:** po Alasce `gold_per_nugget()` ×1.6.
5. **Loot cap:** stack „gold" nie przekracza 1.5; przy capie „gold" nie wypada (albo samorodek cash).
6. **Loot nie przerywa:** ręczne granie bez modala; znaleziska w `found_parts` + badge; rozliczenie na sprzedaży/w warsztacie.
7. **Martwe staty żyją:** koparka/silnik → mniej smyrania; pompa/silnik → szybsze płukanie; płuczka/sita → dłuższe okno.
8. **9 zablokowanych części:** nadal oznaczone (nie ruszane w tej fazie) — świadomie do Fazy 2.
