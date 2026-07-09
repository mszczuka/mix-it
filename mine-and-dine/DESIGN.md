# Mine & Dine — Dokument projektowy

> Jeden punkt prawdy dla przebudowy prototypu w kierunku **„idle backbone + dotyk jako hook"**.
> Status: greybox Godot 4.7 (mobile, 1080×1920). Cała gra w `game_state.gd` (stan/ekonomia) + `main.gd` (pętla/UI).

---

## 1. Wizja i pozycjonowanie

**Realistyczny, wiarygodny feel wydobycia złota osadzony w idle backbonie.** Luka rynkowa: symulatory kopalni na mobile są niskobudżetowe i bez dojrzałego F2P; idle mining (Idle Miner Tycoon) jest zatłoczony. Wchodzimy na skrzyżowaniu: **dotykowy, wiarygodny rdzeń wydobycia (smyranie, płukanie, wybieranie) + idle/offline/automatyzacja jako kręgosłup retencji.**

**Model dwóch warstw na tej samej linii wydobywczej** (Koparka → Wywrotka → Płuczka → Pompa → Stół):

| Tryb | Kto | Uzysk | Kiedy |
|---|---|---|---|
| **RĘCZNY (hero)** | gracz — dotykowa mini-gra | wysoki (+loot +progres celu) | gdy gracz obsługuje linię |
| **AUTO (idle)** | **brygada** (najęta) | baseline | w tle + offline |

Docelowy stosunek **RĘCZNY : AUTO = 3.5×** (widełki 3–4×).

### Dwie prostopadłe osie (fundament — nie mylić)
- **Części** = *jak dobra i szybka* jest linia (uzysk + tempo per maszyna). Działają na RĘCZNY **i** AUTO. To drzewo progresji/sink.
- **Brygada (automatyzacja)** = *czy* linia jedzie sama (idle/offline). Jeden system whole-mine, on/off + poziom.

Brygada **nie zastępuje** części. Nie ma „operatorów per-maszyna" — jest jedna brygada obsługująca całą linię; o tempie linii decydują części, a linia jest tak szybka jak jej **najsłabsza maszyna (wąskie gardło)**.

---

## 2. Stan wyjściowy (werdykt)

- **Plugin (dotyk) ~85%** — smyranie (`_erode_soil_at`), płukanie ze staminą (`_water_stamina`), wybieranie grudek, juice. To fundament i przewaga. ZOSTAJE.
- **Backbone (idle) ~10%** — `workers`/`idle_rate()`/`locations` istnieją, ale jako **fasada**: płaskie, odklejone od maszyn, bez offline, bez persystencji.

Dziś to *aktywna gra dotykowa udająca idle*. Cel: prawdziwy idle backbone pod istniejącym hookiem.

---

## 3. Keystone: wąskie gardło z części (którą maszynę obsłużyć)

Dziś 5 maszyn to tylko dostawcy statów do jednej pętli → „którą maszyną się zająć" nie ma znaczenia. Rozwiązanie: **linia produkcyjna z etapami o różnym tempie.**

```
KOPARKA → WYWROTKA → PŁUCZKA → POMPA → STÓŁ → raw_gold
```

- Tempo każdego etapu (przepustowość) zależy od jego **części**.
- Brygada (AUTO) prowadzi całą linię, ale **linia jest tak szybka, jak jej najwolniejszy etap** (wąskie gardło).
- Słabo ulepszona maszyna = wąskie gardło = cała linia zwalnia. Gracz albo **ulepsza jej części** (trwale poszerza gardło), albo **staje przy niej ręcznie** (chwilowy boost + loot + progres celu).
- W Fazie 2 dochodzą **bufory** wizualizujące, gdzie się dławi (pasek zapełnienia + ⚠).

**To keystone:** bez różnicy temp między maszynami „gdzie włożyć ręce" nie istnieje. Napęd to części, nie operatorzy per-stacja.

---

## 4. Decyzja: kiedy pokazywać loot części

**NIE podczas odkrywania hałdy** (dziś: 28% w `_reveal` → przerywa flow motoryczny modalem ekonomicznym).

**TAK przy cash-out (sprzedaż) + zapasowy warsztat z badge'em.**
- Części kumulują się cicho podczas ręcznej sesji („znaleziono w urobku").
- Rozliczenie na ekranie sprzedaży (tryb ekonomiczny, świeża gotówka w ręku) jako wrap-up.
- Badge/tacka „Warsztat" na HOME — bo po usunięciu auto-sprzedaży rytm sprzedaży ≠ rytm lootu.
- Drop-rate zostaje przy aktywnym graniu (nagroda za dotyk); przenosi się tylko **decyzja**.

---

## 5. Plan fazowy

### Faza 0 — Fundament idle (P0)
Cel: „idle" zaczyna istnieć. Największy hook D1 przy najmniejszej zmianie.
1. **Persystencja + offline:** `last_seen`, `offline_cap_s`, `save_state`/`load_state`, naliczanie offline z capem → `raw_gold` (GRAMY, nie do celu).
2. **AUTO skalowane:** koniec płaskiego `IDLE_G_PER_WORKER_PER_MIN`; `auto_gps()` z `part_levels` × `AUTO_EFFICIENCY`. Martwa `auto_recovery()` → mnożnik efektywności AUTO. Automatyzację napędza istniejący `workers` jako **interim brygada** (refaktor do jednego licznika w Fazie 1).
3. **Popup powrotu** z `[ZBIERZ]` / `[ZBIERZ ×2]` (reklama = stub).

### Faza 1 — Spięcie luźnych systemów (P1)
1. **Brygada whole-mine:** refaktor `workers` (per-lokacja) → jeden licznik `crew` + krzywa kosztu; jedno miejsce najmu. **Bez** operatorów per-stacja.
2. **Ekran DZIAŁKI** przestaje zarządzać pracownikami → staje się **progresją lokacji**: `plot_goal` osiągnięty → popup „przenieś sprzęt na [next]" (reuse `unlock_location`), reset progresu, wyższy cel, bogatsza ruda (`grade` per działka). Miękki prestiż (part_levels zostają).
3. **Cap na loot:** `bonus_gold_mult ≤ 1.5`; przy capie loot → samorodek cash (nic martwego). Loot wypada tylko przy ręcznym graniu.
4. **Loot → cash-out** (patrz §4): trigger z `_reveal` do warsztatu + ekranu sprzedaży.
5. **Ożyw 3 martwe staty:** `shake_target` (→ próg odsłonięcia), `glint_window` (→ okno tolerancji), `water_power` (→ tempo płukania).
6. **Sprzątnięcie** martwych pól (`_shake`, `_pile_speed`, `_glint_end_y`, `_batch_gold`, `_mud_cleared/_total`, `EXIT_Y`).
> 9 zablokowanych części (`locked_parts`) NIE są tu ruszane — ożywają w Fazie 2 jako dźwignie przepustowości. W Fazie 1 pozostają czytelnie oznaczone.

### Faza 2 — Głębia idle (P2)
1. **Linia + bufory + wąskie gardło:** `buffer` między etapami, `throughput(m)` z części danej maszyny; auto-tempo linii = najwolniejszy etap × efektywność brygady.
2. **Ożyw 9 zablokowanych części** jako dźwignie `throughput(m)` (opony/zawieszenie/hamulce → Wywrotka; hopper/rynny → Płuczka; filtr/rury/zawory → Pompa; wibro/dopływ → Stół). Teraz mają czym sterować.
3. **Fokus:** obsługa maszyny ręcznie = chwilowy boost jej etapu (+loot +progres). Reuse `current_machine` → `focus_machine`.
4. **Kurs = decyzja:** koniec auto-sprzedaży (`_on_pick_done` już nie otwiera `_open_sell`); model ceny AR(1)+dryf+spike; alert „kurs skoczył". (Uwaga: dopasuj skalę wykresu `_draw_price_chart` do zakresu spike'ów.)
5. **Waluta premium (gemy) + sklep** (time-warp / 2× / cap offline / remove-ads). Dołóż 4. chip do HUD (reflow layoutu — dziś 3 chipy zajmują szerokość).

### Faza 3 — Retencja (P3) — **ZAPARKOWANA**
Daily login, questy, powiadomienia. Spec w `SPEC-faza3.md`. Wstrzymana na życzenie.

---

## 6. Ekonomia — parametry przed/po

| Parametr | PRZED | PO | Powód |
|---|---|---|---|
| Stosunek ręczny:auto | ~4:1 (przypadkiem) | **3.5×** (celowo) | `idle.md` 2–5× |
| `IDLE_G_PER_WORKER_PER_MIN` | 0.5 stała | **skalowane z part_levels** (`auto_gps`) | idle nie może być rounding error |
| `AUTO_EFFICIENCY` | — | **≈ 0.28** | = 1/3.5 |
| `offline_cap_s` | brak | **7200 (2h) → 4h → 8h → 12h (IAP)** | 8h offline ≈ 1–2h aktywu |
| `bonus_gold_mult` | += mag, bez capu | **cap 1.5** | jedyne co dziś rozjeżdża krzywą |
| `glint_chance` clamp | 0.92 | **0.75** | 0.92×0.72 = 66% trafień za dużo |
| `part_cost` exponent | 1.42 | **1.42–1.45** | krzywa zdrowa, nie ruszać mocno |
| Auto-open sprzedaży | tak | **nie** | kurs = decyzja |
| Idle → cel działki | nie | **nie** (świadomie) | pieniądze śpiąc, progres rękami |
| `workers` per-lokacja | tak | **jedna brygada `crew`** | automatyzacja whole-mine, nie per-stacja |

**Waluty:** cash (soft) · raw_gold (zasób pośredni) · **gemy (premium, NOWE — Faza 2)** · Deeds/akty własności (prestiż-meta, opcja).

**Monetyzacja (widełki z `idle.md`/`benchmarks.md`):** remove-ads $2.99–4.99 · permanentne 2× $4.99–9.99 · time-warp $0.99–4.99 · cap offline $2.99–4.99 · starter bundle $1.99–4.99 · packi gemów $0.99/4.99/9.99/19.99/49.99. Rewarded ads = 40–60% przychodu.
**KPI cel:** D1 35%+, D7 15–22%, IAP conv 1.5–3%, ARPDAU $0.04–0.10.

---

## 7. Martwe/luźne elementy do sprzątnięcia

- Martwe pola po wyciętej mechanice taśmy-timera: `EXIT_Y`, `_glint_end_y`, `_pile_speed`, `_shake`, `_shake_accum`, `_batch_gold`, `_mud_cleared`, `_mud_total` — usunąć (Faza 1).
- 4 martwe staty: `auto_recovery` (Faza 0), `shake_target`/`glint_window`/`water_power` (Faza 1) — podłączyć.
- 9 `locked_parts` — ożywić jako dźwignie przepustowości (Faza 2), NIE wyrzucać.
- `workers` per-lokacja → jedna brygada `crew` (Faza 1).

---

## 8. Referencje (zweryfikowane)

- Idle Miner Tycoon — Kolibri/Fluffy Fairy ([Google Play](https://play.google.com/store/apps/details?id=com.fluffyfairygames.idleminertycoon)) — wzorzec: automatyzacja szybów, offline, rewarded 2×.
- Gold and Goblins — Redcell/AppQuantum ([Google Play](https://play.google.com/store/apps/details?id=com.redcell.goldandgoblins)) — mining idle + smash + kolejne kopalnie jako makro.
- Benchmarki/wzorce: pliki wiedzy `genre-profiles/idle.md`, `benchmarks.md`, `f2p-taxonomy.md`.
