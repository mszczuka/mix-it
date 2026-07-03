# Slice Tycoon — Audyt ekonomii + changelog balansu

**Data:** 2026-07-03
**Zakres:** diagnostyka read-only `index.html` (v2), następnie wdrożenie fixów #1, #2, #3, #5. #4 świadomie wstrzymane (decyzja projektowa).
Wszystkie stałe cytowane do `index.html`. Odniesienia benchmarkowe z bazy wiedzy pluginu (`benchmarks.md`, `genre-profiles/idle.md`).

---

## Diagnoza — ranking imbalansów (najgorsze pierwsze)

### #1 — Runaway inflacja: dochód kompounduje szybciej niż bramka rozdziału
- Cel rozdziału rósł ×1.6/ch (`chapterGoalGrowth`), ale dochód na rozdział rośnie **multiplikatywnie**: wartość produktu ~1.5× × lane mult (do ×2.0) × income mult × gear idle factor (do ×2.875).
- Dochód wyprzedzał bramkę → każdy kolejny rozdział **tańszy w realnym czasie**, nie trudniejszy. Brak prestige = brak hamulca. To główne źródło uczucia „brak balansu".

### #2 — Gemy: krany >> sinki
- Wpływ ~10+ gemów/dzień (daily 5 + login 2 + ad 3 + milestone + boss gold + streak). Jedyny realny sink: refill staminy za **1 gem**.
- Premium waluta bez wartości i bez ciągu monetyzacyjnego. Refill za 1 gem czynił bramkę staminy bez znaczenia.

### #3 — Stamina: droga za bramkę, która nie gryzie
- `staminaPerSlice=1`: drain ~3.85/s vs regen 3/s → pula 60 pusta dopiero po ~71s (93% uptime). Bramka praktycznie nieodczuwalna.
- A upgrade'y Stamina (cum lv5 = 8755) i Recharge (~26k do floora) wyceniane jak odblokowanie produktu — drogo za throttle, który nie throttluje i omijalny za 1 gem.

### #4 — Loot NIE jest osią progresji (sprzeczne z USP) — WSTRZYMANE
- Rozdziały bramkują na coinach; loot tylko przyspiesza zarabianie (cadence/crit + idle factor). Skalowanie rarity prawie płaskie (Rare 8.5%→13.3% przez 8 rozdziałów). Pierwszy gear ~Ch2 / ~10 min in.
- Gracz optymalizujący progres zignoruje statystyki gearu i zgrinduje coiny. **To decyzja projektowa — nie ruszane w tym przejściu.**

### #5 — Martwe sinki
- Auto-Slicer Tempo `2500×1.4^lv`: wzrost 1.4 wyceniał późne poziomy znacznie powyżej ich malejącego zysku ms (floor `holdMinMs 70`) → pułapkowy sink.
- Lane auto-cuttery: ~1 coin/s na Tomato, obsolete po odblokowaniu kolejnego produktu.

### Zdrowe (bez zmian)
- Roster produktów spaced ~1.5×/unlock. Pierwszy upgrade @40 coinów ≈ 3 dania. Pity lootu 25/120.

---

## Changelog — wdrożone zmiany

| # | Zmiana | Było → Jest | Efekt |
|---|---|---|---|
| 3 | `staminaPerSlice` | 1 → **2** | Drain 7.7/s vs regen 3/s → pula pusta w ~13s, potem 5s lockout (~72% uptime na starcie). Gryzie. |
| 3 | Boss zwolniony ze staminy | `sliceOne` owinięte `if(!rush)` | 30s climax = nieprzerwany frenzy, bez lockoutów |
| 3 | `staminaCostGrowth` / `staminaRegenCostGrowth` | 1.4 → **1.25** | Upgrade'y osiągalne — a że bramka gryzie, mają realną wartość |
| 2 | `staminaRefillGems` | 1 → **15** | Realna cena impatience + prawdziwy gem sink |
| 2 | `dailyGemReward` / `loginGemBase` | 5→**3** / 2→**1** | Darmowy drip gemów ~7 → ~4/dzień |
| 1 | `chapterGoalGrowth` | 1.6 → **2.0** | Bramka nadąża za mnożonym dochodem → koniec runaway inflacji |
| 5 | `autoChefSpeedCost` base/growth | 2500/1.4 → **2000/1.3** | Auto-Slicer Tempo przestaje być pułapką |

## Świadomie NIE ruszone
- **#4** — loot jako oś progresji (decyzja projektowa).
- **Lane auto-cuttery** — skalowanie ich income do najlepszego produktu wpompowałoby dochód i wróciłoby do inflacji #1. Auto to darmowe schodki (lvl 10), leveling daje wartość aktywną.
- **Aspiracyjny gem sink** — ścięcie kranów + drogi refill naprawia *ratio*, ale brak aspiracyjnego wydawania gemów to feature, nie tuning (sąsiaduje z #4).

## Do weryfikacji w grze
Podbicie staminy 2× to najagresywniejsza zmiana. Cel: 72% uptime ma *gryźć, nie irytować*. Pokrętła awaryjne: `staminaMaxBase 60→75` (dłuższy burst) lub `staminaEmptyCooldownMs 5000→4000` (krótszy lockout).
