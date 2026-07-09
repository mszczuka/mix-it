# Faza 2 — Głębia idle (spec implementacyjny)

> Cel: linia wydobywcza staje się łańcuchem etapów o różnym tempie z buforami i **wąskim gardłem napędzanym częściami** — to zamienia „którą maszynę obsłużyć" w realną decyzję (keystone). Plus: 9 zablokowanych części ożywa jako dźwignie przepustowości, kurs staje się decyzją, wchodzi waluta premium.
> Zależy od Faz 0–1 (offline, brygada `crew`, działki). Pseudokod = specyfikacja.
> Model (DESIGN §1, §3): **brygada = czy linia jedzie; części = jak szybki każdy etap; wąskie gardło = najsłabsza maszyna. Bez operatorów per-stacja.**

---

## 0. Granice Fazy 2

**ROBIMY:** etapy linii + bufory + wąskie gardło (z części), ożywienie 9 zablokowanych części jako dźwignie `throughput(m)`, fokus (ręczna obsługa maszyny = boost jej etapu), koniec auto-sprzedaży, model ceny AR1+dryf+spike + poprawka skali wykresu, waluta premium (gemy) + sklep.

**NIE robimy:** retencja (Faza 3), realne SDK reklam/IAP (integracja platformowa — tu stuby), pełny prestiż-loop.

---

## 1. Linia + bufory + wąskie gardło (KEYSTONE)

### 1.1 Idea

Linia to łańcuch etapów; brygada (`crew`) prowadzi całość, ale tempo etapu zależy od jego **części**:
```
KOPARKA → [buf.0] → WYWROTKA → [buf.1] → PŁUCZKA → [buf.2] → POMPA → [buf.3] → STÓŁ → raw_gold
```
Etap wolniejszy niż poprzedni → jego bufor wejściowy rośnie (**wąskie gardło**). Cała linia jedzie tempem **najwolniejszego etapu**. Gracz albo ulepsza części tej maszyny (trwale), albo **staje przy niej ręcznie** (fokus — chwilowy boost + loot + progres celu).

Jednostka w buforach: abstrakcyjny **„ładunek" (load unit)**; Stół konwertuje ładunek → gramy (`LOAD_TO_GOLD`).

### 1.2 Ożywienie 9 zablokowanych części → `throughput(m)`

To TUTAJ 9 dotąd zablokowanych części dostaje sens (sterują przepustowością etapu). `is_locked` znika; `part_effect_text` pokazuje wpływ na tempo.

```
# przepustowość etapu m w ładunkach/s — z części danej maszyny (w tym ożywionych)
func throughput(m: String) -> float:
    return THR_BASE[m] * station_stat_factor(m)
```

| Etap | Części napędzające przepustowość (w tym OŻYWIONE) |
|---|---|
| excavator | `pile_scale()` (łyżka) + tempo z `silnik` |
| truck | `1/reload_time()` (silnik) + **opony/zawieszenie/hamulce** (ożywione) |
| wash | `gold_mult_wash()` (maty) + **hopper/rynny** (ożywione) |
| pump | `water_power()` (silnik) + **filtr/rury/zawory** (ożywione) |
| table | człon bazowy `gold_per_nugget()` (nachylenie) + **wibro/dopływ** (ożywione) |

Zdefiniuj proste funkcje statu dla ożywionych części (np. `truck_flow() = 1.0 + 0.12*_e("truck","opony") + ...`) i złóż w `station_stat_factor(m)`. Po tej fazie **wszystkie 25 części działa**.

### 1.3 Tick produkcyjny (zastępuje prosty `_idle_timer` z Fazy 0)

```
func production_tick(dt: float) -> void:
    if crew <= 0: return                       # brak brygady = linia stoi
    var eff := crew_efficiency()               # z automation_level()/crew
    # od końca łańcucha do początku — zwolnione miejsce propaguje w tył
    var refine := min(buffer[3], throughput("table")*eff*dt)
    buffer[3] -= refine
    add_raw_gold(refine * LOAD_TO_GOLD, false) # AUTO nie liczy do celu
    _flow(2, "pump",  eff, dt)                 # buf[2]→buf[3]
    _flow(1, "wash",  eff, dt)                 # buf[1]→buf[2]
    _flow(0, "truck", eff, dt)                 # buf[0]→buf[1]
    buffer[0] += min(throughput("excavator")*eff*dt, BUFFER_CAP - buffer[0])  # ziemia→buf[0]

func _flow(i, m, eff, dt):
    var f := min(buffer[i], throughput(m)*eff*dt, BUFFER_CAP - buffer[i+1])
    buffer[i] -= f; buffer[i+1] += f
```

Wąskie gardło emerguje samo: najwolniejszy `throughput` dławi łańcuch. **Ciągłość z Fazą 1:** dobierz `LOAD_TO_GOLD` i `THR_BASE` tak, by przy równych poziomach części `production_tick` dawał ≈ `manual_ref_gps()*AUTO_EFFICIENCY` (czyli tyle, co whole-mine `auto_gps()` z Fazy 1).

> **Offline z buforami:** nie symuluj sekunda-po-sekundzie. `auto_gps_effective = min(throughput(m) for m) * LOAD_TO_GOLD * crew_efficiency()` (najwolniejszy etap rządzi) × `capped`. Zachowuje wąskie gardło w offline bez pełnej symulacji.

### 1.4 `crew_efficiency()`

```
func crew_efficiency() -> float:
    return clampf(float(crew) / float(MAX_CREW), 0.0, 1.0)   # spójne z automation_level() z Fazy 1
```

---

## 2. Fokus (ręczna obsługa maszyny = boost etapu)

```
var focus_machine := ""     # reuse current_machine

func set_focus(m): focus_machine = m
func clear_focus(): focus_machine = ""
```

Obsługa maszyny ręcznie (wejście w jej mini-grę): przez czas sesji jej `throughput` dostaje **mnożnik ręczny** (gracz jest szybszy niż baseline) + daje **loot** + **progres celu** (`add_raw_gold(_, true)`). Jeśli to wąskie gardło — rozładowujesz je i cała linia przyspiesza. To realizacja „usiądź przy zapchanej maszynie".

> Uwaga strukturalna: obecna mini-gra to jedna pętla (SYP→smyranie→płukanie→zbiór) obejmująca kroki wielu maszyn. „Fokus na maszynę" mapuj na krok tej pętli odpowiadający maszynie (koparka=SYP/smyranie, pompa/płuczka=płukanie, stół=zbiór). To najgłębsza i najbardziej otwarta część — doprecyzujemy layout przy implementacji Fazy 2.

---

## 3. UI zapełnienia buforów (reuse `_show_machine_list`)

Na liście maszyn pokaż bufor WYJŚCIOWY etapu + ostrzeżenie o gardle:
```
KOPARKA     ▓▓▓▓▓░░░░░  52%   moc 4  ›
WYWROTKA    ▓▓▓▓▓▓▓▓▓░  91% ⚠  moc 3  ›     ← wąskie gardło
PŁUCZKA     ▓▓░░░░░░░░  18%   moc 5  ›
```
- Pasek = `buffer[i]/BUFFER_CAP`. `⚠` gdy `≥ 0.85`.
- Tap maszyny → detal (części) + „OBSŁUŻ RĘCZNIE" (ustawia fokus, wchodzi w mini-grę).

---

## 4. Kurs złota jako decyzja

### 4.1 Koniec auto-sprzedaży

W `main.gd` **usuń** auto `_open_sell()` z `_on_pick_done` (dziś: `_fade_hide_layer(zoom_layer, 0.3, func(): _open_sell())` → zostaw samo `_fade_hide_layer(zoom_layer, 0.3)`). Sprzedaż tylko przez nawigację SPRZEDAJ. `raw_gold` gromadzi się (ręczny + AUTO + offline). Warsztat (Faza 1 §4.3) przejmuje rozliczanie lootu, gdy sprzedaż nie otwiera się sama.

### 4.2 Model ceny AR(1) + dryf + spike (+ poprawka wykresu)

```
const PRICE_MEAN := 63.0
const PRICE_RHO  := 0.85
const PRICE_NOISE := 4.0
const SPIKE_CHANCE := 0.04
const SPIKE_MAG := 22.0

func tick_price() -> void:
    var drift := PRICE_RHO * (price - PRICE_MEAN)
    var noise := randf_range(-PRICE_NOISE, PRICE_NOISE)
    var spike := 0.0
    if randf() < SPIKE_CHANCE:
        spike = randf_range(0.5, 1.0) * SPIKE_MAG * (1 if randf() < 0.7 else -1)
    price = clampf(PRICE_MEAN + drift + noise + spike, price_min, price_max + SPIKE_MAG)
    price_history.append(price)
    if price_history.size() > PRICE_HISTORY_MAX: price_history.pop_front()
    price_changed.emit(price)
    _check_price_alert()
```

**Poprawka spójności (niespójność #9):** `_draw_price_chart` skaluje dziś do `price_min/price_max` (linie ~424–425). Spike może przekroczyć `price_max` → punkt wyjdzie za ramkę. Zmień skalę wykresu na **min/max z `price_history`** (dynamiczny zakres), nie stałe `price_min/price_max`.

### 4.3 Alert kursu

```
signal price_spiked(value)
func _check_price_alert():
    var p90 := percentile(price_history, 0.90)
    if price >= p90 and price >= PRICE_MEAN + 12.0:
        price_spiked.emit(price)   # main.gd: toast (push w Fazie 3)
```

---

## 5. Waluta premium (gemy) + sklep

### 5.1 Waluta i efekty

```
var gems: int = 0
signal gems_changed(value)
func add_gems(v): gems += v; gems_changed.emit(gems)
func spend_gems(v) -> bool:
    if gems < v: return false
    gems -= v; gems_changed.emit(gems); return true

var perm_mult_2x := false
func global_mult() -> float: return 2.0 if perm_mult_2x else 1.0   # mnóż finalny uzysk ręczny i AUTO

func time_warp(hours: float) -> float:
    var g := auto_gps_effective() * hours * 3600.0
    add_raw_gold(g, false); return g

func extend_offline_cap(hours: int): offline_cap_s = hours * 3600
```
Faucety gemów (bez IAP): ukończenie działki (+5–15), rzadki loot, rewarded ad.

### 5.2 HUD — reflow na 4. chip (niespójność #10)

Dziś HUD ma 3 chipy (`gold` x40, `price` x370, `cash` x740) zajmujące ~40–1040 px. Chip gemów nie ma gdzie wejść. **Przełóż layout HUD na 4 chipy** (węższe, np. ~250 px każdy) albo przenieś kurs na baner — zanim dołożysz gemy przez `_make_chip`.

### 5.3 Katalog sklepu (ceny/gemy do strojenia)

| Pozycja | Koszt | Efekt |
|---|---|---|
| Remove ads | IAP $2.99–4.99 | flaga `ads_removed` |
| Permanentne ×2 | IAP $4.99–9.99 | `perm_mult_2x = true` |
| Time-warp 2h/8h/24h | gemy / IAP $0.99–4.99 | `time_warp(h)` |
| Rozszerzenie cap offline | gemy / IAP $2.99–4.99 | `extend_offline_cap(8/12)` |
| Packi gemów | IAP $0.99/4.99/9.99/19.99/49.99 | +100/550/1200/2600/6500 |
| Starter bundle (1×) | IAP $1.99–4.99 | 500 gemów + 2h warp + boost |

> Reklamy i IAP = **stuby** (klik = sukces). Realne SDK to osobna integracja platformowa.

### 5.4 Rewarded ads (stub)

| Rewarded | Efekt |
|---|---|
| 2× offline przy powrocie | `collect_offline(2.0)` (już w Fazie 0) |
| Boost 30 min | tymczasowy mnożnik ręczny ×2 / AUTO ×3 |
| Time-warp lite | `time_warp(1.0)` |

---

## 6. Zmiany w main.gd (zbiorczo)

1. `_idle_timer` callback → `GameState.production_tick(dt)` (zamiast prostego `add_raw_gold(idle_rate())`).
2. Usuń auto-`_open_sell()` z `_on_pick_done`.
3. Lista maszyn: paski buforów + `⚠`.
4. Wejście w mini-grę = `set_focus(m)`; powrót na HOME = `clear_focus()`.
5. Nowy ekran SKLEP + chip gemów (po reflow HUD §5.2).
6. Podłącz `global_mult()` do finalnego uzysku (ręczny w `_on_nugget`, AUTO w `production_tick`).
7. `price_spiked` → toast. Zmień skalę `_draw_price_chart` na dynamiczny zakres historii.

---

## 7. Parametry (do strojenia)

| Parametr | Wartość start | Uwaga |
|---|---|---|
| `BUFFER_CAP` | 100.0 | pojemność bufora |
| `LOAD_TO_GOLD` | kalibracja | ciągłość z `manual_ref_gps` z Fazy 1 |
| `THR_BASE[m]` | per etap | tak, by przy równych poziomach gardło było łagodne |
| `PRICE_RHO` | 0.85 | autokorelacja |
| `SPIKE_CHANCE`/`SPIKE_MAG` | 0.04 / 22 | okna sprzedaży |
| ożywione części (9) | §1.2 | dźwignie throughput |
| gemy: ceny/nagrody | §5.3 | stroi ekonomia |

---

## 8. Testy akceptacyjne

1. **9 części żyje:** ulepszenie opony/hopper/filtr/wibro zmienia `throughput` odpowiedniego etapu; `is_locked` już nie istnieje.
2. **Wąskie gardło:** niski `throughput` Stołu → `buffer[3]` rośnie do capu → koparka staje; UI `⚠` na gardle.
3. **Fokus:** ręczna obsługa gardła → bufor spada, linia przyspiesza; dostajesz loot + progres celu.
4. **Ciągłość z Fazą 1:** przy równych poziomach części `production_tick` ≈ `manual_ref_gps()*AUTO_EFFICIENCY` (brak skoku uzysku vs Faza 1).
5. **Offline z gardłem:** offline nalicza wg najwolniejszego etapu × `crew_efficiency`.
6. **Kurs to decyzja:** brak auto-sprzedaży; cena ma trend; spike wyzwala alert; wykres nie ucieka poza ramkę przy spike (dynamiczna skala).
7. **Gemy/sklep:** time-warp dolewa `auto_gps_effective()*h`; ×2 podwaja uzysk ręczny i AUTO; cap offline rośnie; 4. chip mieści się w HUD.
