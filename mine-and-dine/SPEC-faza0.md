# Faza 0 — Fundament idle (spec implementacyjny)

> Cel: „idle" zaczyna istnieć. Persystencja + offline + AUTO skalowane z maszynami + popup powrotu.
> Najmocniejszy hook D1 przy najmniejszej zmianie. Pseudokod = specyfikacja, nie finalny GDScript.
> Pliki: `game_state.gd` (stan/logika), `main.gd` (tick, hooki cyklu życia, popup).

---

## 0. Granice Fazy 0

**ROBIMY:** zapis/odczyt stanu, naliczanie offline z capem, zamiana płaskiego idle na AUTO skalowane statami maszyn, popup powrotu z opcją ×2 (reklama).

**NIE robimy jeszcze (późniejsze fazy):** operatorzy per-stacja (Faza 1), bufory/wąskie gardła (Faza 2), fokus stacji (Faza 2), koniec auto-sprzedaży i model ceny (Faza 2), premium currency (Faza 2), rebalans krzywych/`glint_chance` (Faza 1). W Fazie 0 automatyzację napędza istniejący licznik `workers` (interim) — Faza 1 przepnie go na operatorów per-stacja.

---

## 1. Nowe pola stanu (`game_state.gd`)

```
# --- idle / offline ---
const AUTO_EFFICIENCY := 0.28        # AUTO ≈ 1/3.5 uzysku ręcznego (idle.md: aktyw 2–5× > idle)
const T_CYCLE_REF     := 11.0        # sek: uśredniony pełny cykl ręczny SYP→zbiór (do zmierzenia w grze)
const P_GOLD_REF      := 0.25        # udział SYP-ów kończących się złotem (do zmierzenia)

var last_seen: int = 0               # unix (s) ostatniego zapisu; 0 = pierwsze uruchomienie
var offline_cap_s: int = 7200        # 2h early (Faza 1 podniesie: 4h/8h/12h)
var pending_offline_g: float = 0.0   # policzone offline, jeszcze NIE dodane (czeka na ZBIERZ)
```

---

## 2. Model AUTO (interim, przed buforami)

Zastępujemy płaski `idle_rate()`. AUTO ma skalować się z ulepszeniami maszyn **i** z liczbą pracowników (musisz kogoś zatrudnić, żeby cokolwiek szło automatem).

```
# grama złota w jednej udanej partii — SKALUJE się z częściami (nugget_count, gold_per_nugget)
func batch_gold_g() -> float:
    return nugget_count() * gold_per_nugget()

# referencyjny uzysk RĘCZNY w gramach/s (skaluje się z częściami)
func manual_ref_gps() -> float:
    return (P_GOLD_REF * batch_gold_g()) / T_CYCLE_REF

# poziom automatyzacji 0..1 (interim: z workers; Faza 1 → operatorzy per-stacja)
func automation_level() -> float:
    return clampf(float(total_workers()) / float(MAX_WORKERS), 0.0, 1.0)

# uzysk AUTO w gramach/s — 0 gdy brak pracowników
func auto_gps() -> float:
    if automation_level() <= 0.0:
        return 0.0
    var base := manual_ref_gps() * AUTO_EFFICIENCY * automation_level()
    return base * (1.0 + auto_recovery())   # <- podłącza MARTWĄ auto_recovery() (płuczka „bęben”)

# ZASTĄP starą treść idle_rate() (dziś: total_workers()*0.5/60) tym:
func idle_rate() -> float:
    return auto_gps()
```

Efekt: (a) `auto_recovery()` przestaje być martwa — staje się mnożnikiem efektywności AUTO; (b) AUTO rośnie z każdym ulepszeniem części, nigdy nie jest błędem zaokrąglenia; (c) zero pracowników = zero AUTO (zachęta do zatrudniania).

> Uwaga: `T_CYCLE_REF`/`P_GOLD_REF` to stałe do strojenia. Faza 2 może je zastąpić **pomiarem na żywo** (średnia krocząca g/s podczas aktywnej gry) dla większej dokładności.

---

## 3. Offline — naliczanie

```
# Wołane RAZ przy starcie (po load_state), przed pokazaniem HOME.
# Liczy, ale NIE dodaje — czeka na ZBIERZ (żeby ×2 mogło podwoić).
func compute_offline(now_unix: int) -> Dictionary:
    if last_seen <= 0:
        return {"gained": 0.0, "elapsed": 0, "used": 0, "capped": false}
    var elapsed: int = max(0, now_unix - last_seen)     # ujemny zegar → 0
    var used: int = min(elapsed, offline_cap_s)
    var g: float = auto_gps() * float(used)             # part_levels/workers nie zmieniają się offline → dokładne
    pending_offline_g = g
    return {
        "gained": g, "elapsed": elapsed, "used": used,
        "capped": elapsed > offline_cap_s, "price": price
    }

# ZBIERZ (popup): dodaje pending jako GRAMY, NIE do celu działki
func collect_offline(multiplier: float = 1.0) -> float:
    var g := pending_offline_g * multiplier
    add_raw_gold(g, false)      # to_goal = false — offline nie posuwa plot_progress
    pending_offline_g = 0.0
    return g
```

Reguły twarde:
1. Offline produkuje **gramy**, nie gotówkę → sprzedaż po `price` w chwili powrotu (rynek nietknięty).
2. Offline **nie** liczy się do `plot_progress` (`to_goal=false`) — postęp makro tylko rękami.
3. Powyżej `offline_cap_s` naliczanie staje (cap = hook: „magazyn pełny, wróć").

---

## 4. Persystencja

**Co zapisujemy** (minimalny stan gry): `cash`, `raw_gold`, `part_levels`, `workers`, `locations` (pole `unlocked`), `plot_name/number/goal/progress`, `price`, `price_history`, `bonus_gold_mult`, `bonus_glint_add`, `bonus_reload_mult`, `last_seen`.

**Kiedy zapisujemy:**
- Wyjście / pauza aplikacji (mobile: utrata fokusu) — `last_seen = now`.
- Autosave co ~30 s (backup na crash).
- Po istotnych zdarzeniach (zakup operatora, sprzedaż) — opcjonalnie.

**Format:** `ConfigFile` lub JSON w `user://savegame.cfg`. Wersjonowanie: pole `save_version` (na przyszłe migracje).

**Kontrakty:**
```
func save_state() -> void          # serializuje pola wyżej; ustawia last_seen = Time.get_unix_time_from_system()
func load_state() -> bool          # wczytuje; false gdy brak/uszkodzony (nowa gra)
```

**Kolejność w `_ready()` (`game_state.gd`):** inicjalizacja domyślna (part_levels, price_history) → `load_state()` → dopiero potem `main.gd` woła `compute_offline(now)`.

---

## 5. Popup powrotu (`main.gd`, reuse `popup_layer`)

**Trigger:** po `load_state()` + `compute_offline()`, jeśli `gained > 0` → pokaż przed oddaniem sterowania.

**Layout (reuse stylu loot popupu):**
```
┌───────────────────────────────────────┐
│      ⛏  KOPALNIA PRACOWAŁA             │
│                                         │
│      +  X.X g                (licznik animowany 0→X) │
│      kurs: $Y/g  ·  wartość ≈ $Z        │
│                                         │
│  [ jeśli capped: „Magazyn pełny od HH:MM │
│    — wracaj częściej” ]                  │
│                                         │
│  [ ZBIERZ ]      [ ZBIERZ ×2 ▶reklama ] │
└───────────────────────────────────────┘
```

**Flow przycisków:**
- `ZBIERZ` → `GameState.collect_offline(1.0)` → toast „+X.X g do magazynu" → zamknij.
- `ZBIERZ ×2 ▶` → (Faza 0: stub reklamy = od razu sukces) → `GameState.collect_offline(2.0)` → toast → zamknij. Realne SDK reklam podłączymy przy monetyzacji.
- `capped` → podtytuł informujący, że część czasu przepadła (motywacja do częstszych powrotów).

**Wartość $:** `Z = round(gained * price)` — pokazuje ile to warte po bieżącym kursie (nie sprzedaje automatycznie).

---

## 6. Zmiany w `main.gd`

1. **Cykl życia / zapis:**
```
func _notification(what: int) -> void:
    if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_GO_BACK_REQUEST]:
        GameState.save_state()
# + Timer autosave 30 s → GameState.save_state()
```
2. **Start:** w `_ready()` po zbudowaniu UI: `var r = GameState.compute_offline(Time.get_unix_time_from_system())` → jeśli `r.gained > 0`: `_show_welcome_back(r)`.
3. **`_idle_timer` (online tick):** treść callbacku bez zmian strukturalnych — dalej co 1 s `add_raw_gold(GameState.idle_rate() * 1.0, false)`. Ponieważ `idle_rate()` = `auto_gps()`, online idle jest teraz spójny z offline. (Pauzę idle podczas ręcznego fokusu dołożymy w Fazie 2.)

---

## 7. Parametry startowe (do strojenia w Fazie 1)

| Parametr | Wartość | Uwaga |
|---|---|---|
| `AUTO_EFFICIENCY` | 0.28 | ≈ 1/3.5 |
| `offline_cap_s` | 7200 (2h) | Faza 1: 4h/8h/12h |
| `T_CYCLE_REF` | 11.0 s | zmierzyć w grze |
| `P_GOLD_REF` | 0.25 | zmierzyć w grze |
| autosave | 30 s | backup crash |

---

## 8. Testy akceptacyjne (do B)

1. **Persystencja:** zamknij i otwórz grę → cash/gold/part_levels/workers/plot zachowane.
2. **Offline daje gramy:** ustaw `workers ≥ 1`, cofnij `last_seen` o 1h w zapisie → start → popup „+X g", X ≈ `auto_gps()*3600`, cash bez zmian dopóki nie sprzedasz.
3. **Cap działa:** cofnij `last_seen` o 5h przy cap 2h → X = `auto_gps()*7200`, podtytuł „magazyn pełny".
4. **Zero pracowników = zero offline:** `workers = 0` → brak popupu.
5. **AUTO skaluje:** ulepsz część Stołu (`nachylenie`) → `auto_gps()` rośnie; ulepsz płuczkę `beben` → rośnie mnożnik (`auto_recovery`).
6. **Offline nie rusza celu:** po ZBIERZ `plot_progress` bez zmian; `raw_gold` +X.
7. **×2:** ZBIERZ ×2 daje 2× względem ZBIERZ.
8. **Ujemny zegar:** cofnięcie zegara systemowego → brak ujemnego/absurdalnego naliczenia (elapsed=0).
