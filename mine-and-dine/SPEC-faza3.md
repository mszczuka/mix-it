# Faza 3 — Retencja (spec implementacyjny)

> Cel: dać powody do powrotu (D1/D7). Minimalny, skuteczny zestaw: daily login, kilka daily questów na istniejących czasownikach, powiadomienia. Świadomie bez gildii/PvP/battle passa na tym etapie.
> Zależy od Faz 0–2 (offline, operatorzy, działki, gemy). Pseudokod = specyfikacja.

---

## 0. Granice Fazy 3

**ROBIMY:** 7-dniowy daily login, 2–3 daily questy z pulą, powiadomienia lokalne (magazyn pełny / kurs skoczył / operator gotów).

**NIE robimy:** gildie/klany, PvP, leaderboardy, battle pass, eventy sezonowe — przedwczesne dla solo-kaskady; dochodzą dopiero gdy rdzeń retencji stoi (zasada „warstwuj złożoność stopniowo").

Kolejność warstwowania (z profilu idle): D1 offline (Faza 0) → pierwszy operator/AUTO (Faza 1) → pierwsze wąskie gardło (Faza 2) → **daily login + questy (tu)** → przeniesienie działki jako cel D7 (Faza 1, spina się tutaj).

---

## 1. Daily login (7-dniowy kalendarz)

### 1.1 Model danych

```
var last_login_date := ""      # "YYYY-MM-DD" ostatniego odebranego dnia
var login_day_index := 0       # 0..6, pozycja w 7-dniowym cyklu
var login_streak := 0          # dni z rzędu (dla ewentualnego mnożnika)

const LOGIN_REWARDS := [
    {"day":1, "type":"cash",     "amount":200},
    {"day":2, "type":"gems",     "amount":15},
    {"day":3, "type":"warp",     "amount":2.0},          # time-warp 2h
    {"day":4, "type":"cash",     "amount":600},
    {"day":5, "type":"gems",     "amount":30},
    {"day":6, "type":"warp",     "amount":8.0},          # time-warp 8h
    {"day":7, "type":"part_rare","amount":1},            # gwarantowana rzadka część do warsztatu
]
```

### 1.2 Logika

```
func check_daily_login(today: String) -> Dictionary:
    if today == last_login_date:
        return {}                                  # już odebrane dziś
    var yesterday := date_minus_one(last_login_date)
    if last_login_date == "" or today != yesterday:
        # nowy gracz lub przerwana passa
        if last_login_date != "" and today != yesterday:
            login_day_index = 0                    # reset cyklu przy złamaniu passy (bez odbierania nagród)
            login_streak = 0
    var reward = LOGIN_REWARDS[login_day_index]
    return reward                                  # main.gd pokazuje popup z CTA ODBIERZ

func claim_daily_login(today: String) -> void:
    var reward = LOGIN_REWARDS[login_day_index]
    _grant(reward)                                 # cash/gems/warp/part
    last_login_date = today
    login_day_index = (login_day_index + 1) % LOGIN_REWARDS.size()
    login_streak += 1
    save_state()
```
Zasada: **złamanie passy resetuje licznik cyklu, ale nie odbiera już zdobytych nagród** (loss-aversion bez karania — profil retencji).

### 1.3 UI (popup przy pierwszym wejściu dnia, reuse popup_layer)

7 kafli w rzędzie (dzień 1–7), aktualny dzień podświetlony, przeszłe wyszarzone/✓, `[ ODBIERZ ]`. Dzień 7 wyróżniony (rzadka część).

---

## 2. Daily questy (2–3 dziennie)

### 2.1 Model danych

```
var daily_quests: Array = []       # aktywne dziś
var daily_quests_date := ""

const QUEST_POOL := [
    {"id":"syp_manual", "desc":"Nasyp ręcznie %d razy",        "target":15, "reward":{"type":"cash","amount":400}},
    {"id":"sell_high",  "desc":"Sprzedaj przy kursie > $%d",   "target":75, "reward":{"type":"gems","amount":12}},
    {"id":"collect_x2", "desc":"Odbierz zarobek offline %d×",  "target":1,  "reward":{"type":"warp","amount":1.0}},
    {"id":"upgrade",    "desc":"Ulepsz %d części maszyn",       "target":3,  "reward":{"type":"cash","amount":300}},
    {"id":"bottleneck", "desc":"Rozładuj ręcznie zapchaną stację %d×", "target":2, "reward":{"type":"gems","amount":10}},
    {"id":"plot_gold",  "desc":"Wydobądź %d g na działce",      "target":40, "reward":{"type":"gems","amount":15}},
]
```

### 2.2 Losowanie i reset

```
func roll_daily_quests(today: String) -> void:
    if today == daily_quests_date:
        return
    daily_quests_date = today
    daily_quests = pick_random(QUEST_POOL, 3)      # 3 różne, wyzeruj progres
    for q in daily_quests:
        q.progress = 0
        q.done = false
```

### 2.3 Hooki postępu (w istniejących czasownikach)

| Quest | Hook w kodzie |
|---|---|
| `syp_manual` | `_on_syp()` → `quest_progress("syp_manual", 1)` |
| `sell_high` | `_on_sell()` → jeśli `price > target`: `quest_progress("sell_high", 1)` |
| `collect_x2` | `collect_offline()` → `quest_progress("collect_x2", 1)` |
| `upgrade` | `upgrade_part()` / `hire_operator()` → `quest_progress("upgrade", 1)` |
| `bottleneck` | ręczne rozładowanie stacji przy buforze ≥0.85 → `quest_progress("bottleneck", 1)` |
| `plot_gold` | `add_raw_gold(v, true)` → `quest_progress("plot_gold", v)` |

```
func quest_progress(id: String, amount) -> void:
    for q in daily_quests:
        if q.id == id and not q.done:
            q.progress += amount
            if q.progress >= q.target:
                q.done = true
                emit_signal("quest_completed", q)      # main.gd: toast + odbiór nagrody
```

### 2.4 UI

Panel questów (reuse styl overlaya) dostępny z HOME: 3 wiersze z paskiem postępu + `[ ODBIERZ ]` gdy `done`. Opcjonalnie: komplet 3/3 → bonus (np. +20 gemów).

---

## 3. Powiadomienia lokalne

> Zależność platformowa: Godot nie ma wbudowanych powiadomień lokalnych — wymaga wtyczki (Android/iOS notification plugin). Tu specyfikujemy **triggery i harmonogram**; integracja SDK to osobny krok.

### 3.1 Triggery

| Powiadomienie | Kiedy zaplanować | Treść |
|---|---|---|
| Magazyn pełny (cap offline) | przy wyjściu: `now + offline_cap_s` | „Magazyn pełny — kopalnia czeka. Wróć po złoto!" |
| Kurs skoczył | na `price_spiked` gdy gra w tle (jeśli platforma pozwala) LUB heurystyka czasowa | „Kurs złota skoczył do $X/g — czas sprzedać!" |
| Operator gotów do awansu | gdy `cash >= operator_cost(m)` dla dostępnego awansu przy wyjściu | „Stać Cię na awans operatora — kopalnia przyśpieszy" |

### 3.2 Zasady higieny

- **Cap 2–3/dzień** — nie wypalać.
- Planuj przy `save_state()`/wyjściu; anuluj nieaktualne przy wejściu (`clear_scheduled()`).
- Opt-out w ustawieniach (wymóg platform).

### 3.3 Kontrakty (abstrakcja nad wtyczką)

```
func schedule_notification(id: String, delay_s: int, title: String, body: String) -> void
func cancel_notification(id: String) -> void
func cancel_all_notifications() -> void
```
Implementacja woła wtyczkę platformową; w edytorze/desktop = no-op (log).

---

## 4. Zmiany w main.gd (zbiorczo)

1. `_ready()` po offline-popup: `GameState.roll_daily_quests(today)`; `var r = GameState.check_daily_login(today)` → jeśli `r` niepuste: `_show_daily_login(r)`.
2. Hooki questów w: `_on_syp`, `_on_sell`, `collect_offline`, `upgrade_part`/`hire_operator`, ręczne rozładowanie, `add_raw_gold`.
3. Sygnały `quest_completed` → toast + nagroda; przyciski HOME: LOGIN (jeśli nieodebrane), QUESTY (badge z liczbą `done`-do-odbioru).
4. `_notification` (wyjście, z Fazy 0) rozszerz o `schedule_notification(...)` dla 3 triggerów; wejście → `cancel_all_notifications()`.
5. `date_today()` = `Time.get_date_string_from_system()` ("YYYY-MM-DD").

---

## 5. Persystencja (rozszerzenie zapisu z Fazy 0)

Dodaj do `save_state()`/`load_state()`: `last_login_date`, `login_day_index`, `login_streak`, `daily_quests`, `daily_quests_date`, `gems`, `perm_mult_2x`, `ads_removed`, `offline_cap_s`, `operators`, `current_location`, stan `buffer`.

---

## 6. Parametry (do strojenia)

| Parametr | Wartość start | Uwaga |
|---|---|---|
| Nagrody login D1–D7 | patrz §1.1 | rosnące, D7 rzadka część |
| Liczba questów/dzień | 3 | z puli 6 |
| Cele questów | patrz §2.1 | stroi ekonomia |
| Cap powiadomień | 2–3/dzień | higiena |

---

## 7. Testy akceptacyjne

1. **Login pierwszego dnia:** popup z dniem 1; ODBIERZ → nagroda przyznana, `login_day_index=1`, ponowne wejście tego samego dnia → brak popupu.
2. **Passa i reset:** wejście następnego dnia → dzień 2; pominięcie dnia → cykl reset do dnia 1, ale wcześniejsze nagrody zostają.
3. **Questy losują się raz dziennie:** 3 różne questy; kolejnego dnia nowy zestaw z wyzerowanym progresem.
4. **Hooki liczą:** nasyp ręcznie 15× → `syp_manual` done; sprzedaż przy kursie > $75 → `sell_high`; odbiór offline → `collect_x2`.
5. **Nagroda questa:** komplet → toast + przyznanie; badge znika po odbiorze.
6. **Powiadomienia:** przy wyjściu planowane ≤3; wejście czyści; desktop = no-op bez błędu.
7. **Persystencja:** login/questy/gemy przetrwają restart.

---

## 8. Domknięcie A — mapa wszystkich faz

| Faza | Rdzeń | Naprawia (dziury z diagnozy) |
|---|---|---|
| **0** | offline + persystencja + AUTO skalowane + popup powrotu | brak offline, płaskie idle, `auto_recovery` martwa |
| **1** | operatorzy per-stacja, działki, loot cap, loot→cash-out, 3 martwe staty | `plot_goal` bez efektu, `locked_parts`, loot bez capu, loot przerywa flow, martwe staty |
| **2** | bufory/wąskie gardła, fokus, kurs=decyzja, gemy/sklep | kaskada bez znaczenia stacji, kurs kosmetyczny, brak premium currency |
| **3** | daily login, questy, powiadomienia | zero retencji dziennej (D1/D7) |

Po A: `game_state.gd`/`main.gd` mają pełną specyfikację przebudowy z „aktywnej gry dotykowej udającej idle" w „idle backbone + dotyk jako hook". Gotowe do B (implementacja fazami, z testami akceptacyjnymi per faza).
