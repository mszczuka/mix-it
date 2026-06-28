# Slice Tycoon — Pakiet "Rush Service + Knife Bench" (A+B)

Cel: naprawić płaską minutę (brak napięcia/wyborów w sesji), nie ruszając dobrego feelu sekundy
(tap/krojenie/combo/particle/audio) ani krzywej prestige idle core.

Mapowanie na CONFIG prototypu: używane wyłącznie istniejące pola — `comboStep 0.12`, `combo max 25`,
`comboMult = 1 + min(combo,25)*0.12`, `decay 2200ms`, `wearPerSlice 1.4`, `bladeMult +0.35/lvl`,
`plateBonusMult`, `val`, `slices`, `cost`, tiery 1–7. Liczby `[balans: economy]` wymagają tuningu od agenta ekonomii.

---

## 1. Diagnoza → fix (jedno zdanie)
Płaska minuta = brak stawki i wyborów w idle core; fix wstrzykuje napięcie i decyzje do **runu
auto-wyzwalanego na koniec stage'a ("Rush Service") — 75 s timer-jako-wynik + draft buffów co kurs** — zasilanego
permanentnym buildem sprzętu z **Knife Bench (zakładka Kitchen)**. ZERO nowych walut — wszystko na
istniejących coins/gems; idle core nietknięty, prestiż degradowany do tła (nie jest już świętą metą).

Uwaga: właściwym fixem minuty jest **Tryb A (run) + timer**. B (sprzęt) to GŁĘBIA, nie fix — buduj po walidacji A.

---

## 2. Tryb A — "Rush Service" (RUN)

**Wejście: finał stage'a, AUTOMATYCZNIE — zero przycisku, zero prompta.** Po ukończeniu stage'a
(serwuj N talerzy) gra czyta, czy gracz jest aktywny, i decyduje sama. Rush to kulminacja stage'a:
prep (idle) → dinner rush (Rush) → nagroda + unlock składnika. Zero ticketów/cooldownu — tempo robi
się z istniejącego systemu stage'ów (wcześnie często = hook, późno rzadziej = event).
- **Aktywny (tapał w ostatnich ~3–5 s):** Rush AUTO-STARTUJE z „3-2-1 DINNER RUSH!" → płynnie w 75 s.
- **AFK (brak tapów):** Rush AUTO-POMIJA się → bazowa nagroda stage'a, idle leci dalej.
  NIE wpadać w aktywny tryb (auto-slice jest w Rush OFF, więc AFK = 0 cięć = zły UX).
- Porzucenie w połowie = skromny wynik, brak fail-state/kary. Pominięty Rush nie boli (gear zdobywasz
  tylko z realnie granych Rushy — spójne z idle: pasywny gracz = pasywne nagrody).
- **Knob częstotliwości:** jeśli „co stage" za często wcześnie → „co 2–3 stage'e" lub Rush Meter
  (pasek z serwowanych talerzy, niezależny od długości stage'a; dodatkowy UI — zostaw na potem).

**Stawka — timer-as-score (rekomendacja).** „Usmaż max talerzy w 75 s. Combo decayuje gdy
przestajesz tapać (istniejący 2200ms). Między talerzami draftujesz 1 z 3 buffów."

Dlaczego timer, nie patience/leaderboard: reużywa istniejący dobry feel combo, nie wprowadza
fail-state (prototyp świadomie ma wear jako sink, nie porażkę), najtańszy do prototypu. Leaderboard
= warstwa na później (wymaga backendu/populacji).

**Długość:** ~75 s rdzeń + ~10 s drafty = ~90 s gęstej minuty.

**Choice-node — między KURSAMI, nie talerzami.** Run dzieli się na 3 kursy (przystawka → danie
główne → deser/boss-dish), draft na początku każdego kursu = **3 drafty/run**. NIE co talerz —
~8–12 talerzy/75s dałoby draft co ~6–9 s: przerywa flow tapania, spłaszcza wagę buffa, zmęczenie
decyzyjne. Kursy dają runowi łuk (eskalacja + kulminacja na boss-dish). 3 opcje. Reroll 1× za
rewarded ad lub gems. Buffy kumulują się w sesji, znikają na końcu (build permanentny jest w B).
Prostszy wariant zamiast kursów: draft co 3 talerze.

### Buffy do draftu (przez istniejący CONFIG, tylko w sesji Rush)
| # | Buff | Efekt | Rola |
|---|---|---|---|
| 1 | Whetstone Edge | `comboStep` 0.12→0.18 | combo rośnie szybciej |
| 2 | Steady Hands | `decay` 2200→3500ms | bufor na drafty |
| 3 | Overcap | combo max 25→32 | wyższy sufit dla skillu |
| 4 | Bulk Board | `slices` bieżącego składnika −30% | więcej talerzy/czas |
| 5 | Golden Plate | `plateBonusMult` ×1.5 na 2 talerze | burst wyniku |
| 6 | Sharp All Round | ignoruj `wearPerSlice` do końca sesji | draftowalna tekstura wear |
| 7 | Tier Skip | następny talerz tier niżej `val`, ale ×2 plastrów | realny trade-off: wartość vs tempo |
| 8 | Combo Primer | start następnego talerza z combo=10 | anty-decay po długim warzywie |

Buffy 6–7 to świadome warunkowe wybory — bez nich draft jest pusty. Min. 1 trade-off na 3 opcje.

**Koniec:** timer=0. Brak fail-state. Ekran wyniku: talerze, max combo, **Service Score**
(suma `plateEarned×plateBonusMult`, naliczana w walucie Rush, NIE w coins) → Plating Tokens.
Rewarded ad: „+50% Plating Tokens". CTA: „Spend at Knife Bench".

---

## 3. Meta B — "Knife Bench" (realizacja Kitchen)
3 sloty permanentnego buildu, staty mapowane na istniejące mechaniki. Bonus działa w idle ORAZ w Rush
(wpływ na idle coins ograniczony — patrz firewall).

| Slot | Stat główny | Stat drugi |
|---|---|---|
| Knife | `bladeMult` flat / multi-cut (1 tap=2 plastry %) / `wearPerSlice` resist | crit (`val`×2 %) |
| Board | combo retention: `comboStep`+ lub `decay`+ | start combo (Primer pasywny) |
| Plate | `plateBonusMult` flat / pojemność receptury | tip (bonus coins/talerz) `[balans]` |

Przykłady (Common/Rare/Epic):
- **Knife:** Paring (`bladeMult`+0.10) → Cleaver (+0.20, wear −15%) → Damascus (+0.35, 12% multi-cut)
- **Board:** Pine (`decay`+400) → Bamboo (+800, `comboStep`+0.02) → Walnut (+1200, start combo +8)
- **Plate:** Tin (`plateBonusMult`+0.10) → Ceramic (+0.25) → Gold (+0.50, 8% tip)

**Pozyskanie: dropy + merge, NIE gacha, NIE osobna waluta.** Common/Rare dropią z Rush
(milestone Score, deterministycznie). Upgrade itemu za **coins** (istniejąca waluta). Merge 3× tier
N → tier N+1 (używa samych itemów, nie waluty). Gacha odrzucona: solo prototyp bez populacji =
pusty hazard; dropy+merge daje tę samą głębię, deterministycznie, completable bez płacenia.

---

## 4. Spięcie A+B
B→A: lepszy build = wyższy sufit Score = więcej dropów/coins = szybszy progres B (pętla zaangażowania).
A→B: Rush to JEDYNE źródło dropów sprzętu — B nie rośnie bez grania w A.
B→idle: sprzęt daje pasywny bonus też poza Rush, ale **cap ≤ +25% na idle coin gen** `[balans]`
(jeśli prestiż zostaje — boost idle coins pośrednio go przyspiesza; jeśli prestiż wypadnie, cap zbędny).

---

## 5. Ekonomia / waluty — ZERO nowych walut
Nie wprowadzamy żadnej nowej waluty. Wszystko jedzie na 3 istniejących. (Wcześniejsza wersja miała
Plating Tokens + Whetstones + Rush Tickets — wycięte jako przekombinowane: tickety niepotrzebne do
fixu, Whetstones to redundantny podział, Plating Tokens istniały tylko po to by firewallować prestiż,
który i tak degradujemy.)

| Waluta | Status | Rola po zmianie |
|---|---|---|
| coins | istniejąca | kup warzyw, sharpen, **upgrade sprzętu**, koszt rerollu (alt), nagroda z Rush |
| gems | istniejąca (dziś martwe) | reroll draftu, opcjonalne boosty — wreszcie dostają sink |
| masterKnives | istniejąca | prestiż w tle |
| sprzęt (itemy) | NIE waluta | kolekcja: drop z Rush + merge 3→1, upgrade za coins |

**Trade-off zamiast firewalla:** bez zamkniętej waluty Rush płacący coins przyspiesza `runCoins`,
czyli `MK=floor(sqrt(runCoins/800))`. Mitygacja: Rush nagradza **głównie dropami sprzętu + skromnym
złotem**, nie wiadrem coins. Jeśli prestiż wypadnie później (sek. dot. prestiżu) — problem znika sam.

Rough numbers `[economy-agent]`: nagroda coins z Rush skalowana skromnie vs idle income; koszt upgrade
sprzętu rośnie z poziomem (wzorzec jak `Sharpen`); merge 3:1; cap pasywnego boostu sprzętu→idle +25%
(tylko jeśli prestiż zostaje).

---

## 6. Monetyzacja (completable bez płacenia; reklama/IAP = akcelerator)
| Punkt | Typ | Zakres (źródło) |
|---|---|---|
| Rush wynik: +50% nagrody | rewarded | opt-in 40–70%, ≤15/dzień (benchmarks.md) |
| Reroll draftu 1× | rewarded / gems | sink dla gems |
| 2x offline (istniejący stub) | rewarded | eCPM $10–40 US (benchmarks.md) |
| Permanent +2x nagroda z Rush | IAP | $4.99–9.99 (idle.md) |
| Starter bundle (Rare+tickets+gems) | IAP first | $1.99–4.99 (idle.md/benchmarks.md) |
| Knife Bench Pass (event, full) | season pass | $9.99, 28–42 dni, free:premium 1:3–1:5 (benchmarks.md) |

IAP conversion idle 1.5–3% (idle.md).

---

## 7. Integracja z istniejącym
- **Combo:** rdzeń stawki Rush; buffy modują step/decay/max. Mechanika bez zmian.
- **Wear:** WYŁĄCZONY w Rush domyślnie (blunt-stall w 75s = zabija flow). Zostaje sinkiem w idle.
  Ekspozycja tylko jako opcjonalny buff #6.
- **Stage:** ukończenie stage'a AUTO-WYZWALA Rush (finał stage'a). To jest jedyny trigger — bez przycisku/ticketów.
- **Prestige:** degradowany do tła (nie świętą metą); Rush płaci skromnie, by nie rozpędzać `runCoins`. Sprzęt B nie resetuje się przy prestiżu — główną metą jest gear, nie prestiż.
- **Offline:** bez zmian; sprzęt może lekko boostować offline w ramach capa +25% `[balans]`.
- Przeprojektowania w idle core: ŻADNE. Jedyna zmiana: gems dostają realne sinki.

---

## 8. Kolejność budowy
| Faza | Zakres | Po co najpierw |
|---|---|---|
| **F0 MVP — walidacja minuty** | Tylko Tryb A: RUSH button, 75s timer, combo=wynik, draft 1-z-3 (buffy 1–5), ekran wyniku. BEZ waluty/sprzętu/ticketów (nielimitowany dostęp). | Najtańszy test: czy run+draft naprawia płaską minutę. To JEST fix. |
| F1 — pętla A | Nagroda coins z Rush + ekran wyniku + buffy 6–8. Bez nowych walut. | Zamyka pętlę nagrody. |
| F2 — meta B | Knife Bench: 3 sloty, Common/Rare dropy, upgrade za coins. B→A. | Głębia po walidacji fixu. |
| F3 — full | Merge (Epic), pasywny B→idle (cap), monetyzacja, reroll za gems, ewent. leaderboard/soft-gate. | Live-ops, długoterminowa głębia. |

**MVP = F0.** Walidujesz fix jednym runem; reszta to depth.

---

## 9. Ryzyka
1. **Nagrody Rush przyspieszają prestiż.** Bez zamkniętej waluty coins z Rush podbijają `runCoins`.
   Unik: Rush płaci głównie dropami sprzętu + skromnym złotem; cap +25% na pasywny boost sprzętu→idle.
   Jeśli prestiż wypadnie — ryzyko znika.
2. **Draft 1-z-3 pusty bez trade-offu.** Unik: min. 1 warunkowy buff (wear/Tier Skip) na pool.
3. **Rush kanibalizuje lean-back idle.** Unik: ticket gate trzyma run jako epizod obok idle, osobne waluty/wejścia.
4. **Wear w Rush zabija flow.** Unik: wear OFF w Rush domyślnie.
5. **Gear-check Epic psuje dostępność A.** Unik: deterministyczne dropy, Common build wystarcza do completion.

---

## 10. Automatyzacja + multi-slice (idle core — ortogonalne do Rush, można budować niezależnie)

Oba trafiają w IDLE core (lean-back), nie w Rush (lean-in). Domykają tożsamość trybów:
idle = fantazja automatyzacji, Rush = fantazja skillu.

### Auto-Slicer (nowy upgrade w Upgrades, obok Auto-Buyera)
- Stat = slices/sec (SPS). Start ~0.3 SPS („mega wolno"), rośnie z poziomem za coins. Materializuje
  istniejące `offlineAssumedSps: 1.4` na ekranie.
- **Combo-neutralny:** tnie po AKTUALNYM `comboMult`, ale go nie inkrementuje. Tapiesz → rozkręcasz
  combo → auto-slice jedzie na nim aż zdecayuje (2200ms). Daje tapaniu wartość w idle bez zabijania
  powodu do tapania. Czyste AFK = combo→x1.
- **Zużywa wear normalnie** — ratuje system wear przed byciem vestigial; AFK nadal wymusza sharpen.
  Otwiera późniejszy **Auto-Sharpener** (trójka: Auto-Buyer + Auto-Slicer + Auto-Sharpener).
- **W Rush: OFF** (Rush = manual skill).
- Ramp „coraz szybsze" = krzywa upgrade'ów. Within-session warmup opcjonalny (koliduje z combo) — później.

### Slices per Tap (multi-slice)
- **Główny dom:** upgrade „Slices per Tap" w Upgrades (flat N: 1→2→3…) za coins. Mniej tapów/warzywo.
- **Sprzęt (knife):** +1 warstwa na wysokim tierze (ujednolicony „multi-cut" na flat +1 zamiast %).
- **NIE osobny buff Rush** — „Bulk Board" (−30% slices) już pokrywa tę oś w Rush.
- **Combo per TAP, nie per slice:** 1 tap = N slices = combo+1 (inaczej combo rozpędza się ×N i
  łamie krzywą). Combo = rytm tapania, multi-slice = plon/tap (ortogonalne). Zarobek = N × val × comboMult.
- Implementacja: `sliceOne()` tnie N plastrów na wywołanie, combo++ raz, wear ×N.

### Spięcie
| Mechanika | Dom | Combo | Wear | W Rush? |
|---|---|---|---|---|
| Auto-Slicer (SPS) | idle upgrade | tnie po combo, nie buduje | zużywa | OFF |
| Slices per Tap (N) | idle upgrade | +1 per tap | zużywa ×N | tak (nie jako draft) |
| Multi-cut | gear (knife) | jw. | — | przez build |

**Ryzyko:** auto-slice + multi-slice mogą strywializować manualne krojenie w idle. OK — ale TYLKO
dlatego, że Rush jest wentylem skillu. Bez Rush te dodatki wypatroszyłyby grę. To kolejny argument
za dwu-trybowym podziałem.

---
Źródła: benchmarks.md, genre-profiles/idle.md, f2p-taxonomy.md (plugin knowledge 3.32.0).
Referencje do Archero/Cooking Fever = user-cited/strukturalne wzorce, nie wprowadzone jako fakty.
