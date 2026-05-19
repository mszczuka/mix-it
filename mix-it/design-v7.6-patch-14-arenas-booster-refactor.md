# Mix-It — Design Patch v7.6: 14-Arena Ladder + Booster Refactor

**Status:** Design proposal (not yet implemented)
**Scope:** Arena ladder expansion (8 → 14), trophy curve rebase, booster roster refactor

---

## 1. Summary

This patch proposes three coordinated changes:

1. **Arena ladder expanded from 8 to 14 arenas**, with colors capped at 8 (the full palette in `CFG_MATCH.ALL_COLORS`) and bottle count capped at **14** (hard UI ceiling).
2. **Trophy thresholds rebased** across 14 arenas with Match Masters-inspired pacing (slightly flattened for a smaller live-ops surface).
3. **Booster roster refactored** — 3 of the 9 boosters replaced (one broken, two underpowered), 1 bugfix on `autoServe`.

The core design principle for arena progression: **no arena introduces both a new color AND a new bottle in the same step** (except final). Each promotion teaches one thing at a time.

The core design principle for the booster refactor: **every tier should have a board-utility, a strategic option, and one PvP-aware option.** The current roster fails this test — ~44% of boosters are filler or broken.

---

## 2. Arena Ladder — 8 → 14 Arenas

### Rationale

- Match Masters runs **12 studios** before Master Ranks ([SimpleGameGuide, 2024](https://simplegameguide.com/match-masters-studios-levels/), *as of 2024, may be stale*). Mix-It's previous 8-arena ladder feels short for a casual PvP game targeting long-term retention.
- UI hard cap: **14 bottles maximum** on the smallest supported device. This ceiling drives the endgame design.
- Decoupling color growth from bottle growth lets each arena promotion feel distinct.

### New ladder

| #  | Arena             | Colors | Source | Empty | Total bottles | Δ vs prev |
|----|-------------------|--------|--------|-------|---------------|-----------|
| 1  | Juice Stand 🍹    | 3      | 3      | 2     | **5**         | start     |
| 2  | Lemonade Stand 🍋 | 3      | 3      | 3     | **6**         | +empty    |
| 3  | Smoothie Bar 🥤   | 3      | 4      | 3     | **7**         | +source   |
| 4  | Boba Tea 🧋       | **4**  | 4      | 3     | 7             | **+color** |
| 5  | Coffee House ☕   | 4      | 4      | 4     | **8**         | +empty    |
| 6  | Tea Garden 🍵     | **5**  | 4      | 4     | 8             | **+color** |
| 7  | Iced Café 🧊      | 5      | 5      | 4     | **9**         | +source   |
| 8  | Cocktail Lounge 🍸| 5      | 5      | 5     | **10**        | +empty + 🔓 Stakes ×2/×3/×4 |
| 9  | Tiki Bar 🌴       | **6**  | 5      | 5     | 10            | **+color** |
| 10 | Wine Cellar 🍷    | 6      | 6      | 5     | **11**        | +source   |
| 11 | Whiskey Den 🥃    | 6      | 6      | 6     | **12**        | +empty    |
| 12 | Champagne Room 🥂 | **7**  | 6      | 6     | 12            | **+color** |
| 13 | Penthouse Bar 🌆  | 7      | 7      | 6     | **13**        | +source   |
| 14 | Grand Hotel 🏨    | **8**  | 7      | 7     | **14**        | **+color +empty** (finale) |

### Progression curves

- **Colors:** 3 → 3 → 3 → 4 → 4 → 5 → 5 → 5 → 6 → 6 → 6 → 7 → 7 → 8 (5 bumps, evenly spaced)
- **Bottles:** monotonic 5 → 14 over 9 of the 13 transitions; the 4 flat-bottle transitions (arenas 4, 6, 9, 12) are the color-introduction arenas
- **Sort-fairness ratio at endgame (Grand):** 14 bottles for 8 colors = N+6 buffer. Classic water-sort needs N+2; the surplus is justified by the PvP race format + spawn drip

### Rule reminders

- `GLASS_CAPACITY = 4` layers stays constant across all arenas
- Color-introduction arenas (4, 6, 9, 12) leave the board layout untouched — players learn the new color on a familiar board
- Bottle-growth arenas reuse the existing color set — players manage known entropy in a new workspace

---

## 3. Trophy Thresholds

Rebased for 14 arenas. Pacing inspired by Match Masters' studio gaps (~+15–25% per tier on late game), slightly flattened to suit Mix-It's smaller live-ops surface.

| #  | Arena             | Trophies |
|----|-------------------|----------|
| 1  | Juice Stand       | 0        |
| 2  | Lemonade Stand    | 100      |
| 3  | Smoothie Bar      | 250      |
| 4  | Boba Tea          | 400      |
| 5  | Coffee House      | 600      |
| 6  | Tea Garden        | 850      |
| 7  | Iced Café         | 1,100    |
| 8  | Cocktail Lounge   | 1,400    |
| 9  | Tiki Bar          | 1,750    |
| 10 | Wine Cellar       | 2,150    |
| 11 | Whiskey Den       | 2,600    |
| 12 | Champagne Room    | 3,100    |
| 13 | Penthouse Bar     | 3,700    |
| 14 | Grand Hotel       | 4,400    |

### Notes

- **Stakes ×2/×3/×4 unlock at Arena 8 (Cocktail Lounge, 1,400 trophies).** This replaces the previous Cocktail unlock at 1,000 trophies — the new threshold tracks with the longer ladder.
- **Master Ranks tier (post-arena 14)** is out of scope for this patch but the threshold curve leaves room: e.g., Challenger I at 5,500, Master I at 7,000, Grand Master at 10,000+.
- Total trophy mileage to endgame: **~4,400** (vs Match Masters' ~3,200 to its 12th studio). Slightly longer to extend retention with a wider arena set.

---

## 4. Booster Refactor

### Audit of current roster (v7.5)

| #  | Booster      | Tier   | Verdict       | Reason |
|----|--------------|--------|---------------|--------|
| 1  | extraBottle  | bronze | ✅ KEEP        | Foundational utility, scales with arenas |
| 2  | firstPour    | bronze | ⚠️ REPLACE    | "Free instant pours" — vague, hard for players to value |
| 3  | spawnPlus3   | bronze | ✅ KEEP (mild)| Pure stat buff, acceptable as budget bronze |
| 4  | colorSplash  | silver | ✅ KEEP        | Exemplary booster — fixes top-color frustration |
| 5  | swap         | silver | ❌ BROKEN      | Swapping full contents between bottles is mechanically a no-op (bottle position is meaningless in this game). See [index-v7.html:4179-4181](index-v7.html#L4179-L4181) |
| 6  | customerLock | silver | ✅ KEEP        | Only PvP-aware booster — strategic, unique angle |
| 7  | clearBottle  | gold   | ✅ KEEP        | Classic escape hatch, decisive |
| 8  | autoServe    | gold   | ✅ KEEP (fix) | **Bug:** description says 20s, code says 30s (`AUTO_SERVE_DURATION:30`). Aligning both to **20s** |
| 9  | doubleServe  | gold   | ⚠️ REPLACE    | Pure passive score buff, no decision, weak for a gold-tier booster |

**Result:** 5 strong, 1 mild-but-acceptable, 2 weak, 1 broken. **~44% of the roster is filler or broken.**

### Comparison with Magic Sort (Grand Games)

[Magic Sort](https://apps.apple.com/us/app/magic-sort/id6499209744) is **solo, untimed** — not a direct comparison for Mix-It's PvP race format. Its booster set is intentionally thin:

- **Undo** — reverse the last move
- **Shuffle** — reorganize puzzle elements
- **"+1 bottle"** — fail-state recovery offer
- Plus a meta "Cauldron / Ingredient brewing" system that gates booster acquisition

Takeaway: solo puzzle gets away with 3 boosters because there's no opponent to play against. PvP race games (Match Masters, etc.) typically run 5–10 boosters across multiple tiers because PvP creates demand for *opponent-facing* tools — attack, defense, timing manipulation. **Mix-It's current roster has only 1 PvP-aware booster (customerLock).** That's the deeper structural gap behind the "filler" verdict.

### Replacements

#### Replace `swap` → **Tube Sort** 🌀 (silver)

> *Pick a color and a target bottle; all top layers of that color across all bottles snap to the target.*

- **Inspiration:** Magic Sort's Shuffle, but color-targeted and player-controlled.
- **Use case:** "Red is buried at the top of 4 bottles under wrong colors — Tube Sort red → all 4 reds collapse into one chosen bottle, ready to serve."
- **Power:** High but justified at silver. Capacity-validated (max `GLASS_CAPACITY = 4` per target).
- **Decisions:** color (which to consolidate) + target bottle (where to send it). Two real choices.
- **Readability:** Instant animation — all matching tops fly to one location.

#### Replace `firstPour` → **Pre-Sort** 🧹 (bronze)

> *Start the match with one random color already pre-consolidated into a single bottle.*

- **Use case:** Onboarding-friendly — new players see "this bottle is already clean" at match start. Experienced players save ~5–10s of early sorting.
- **Power:** Mild bronze, same intended power level as `firstPour` but with a clear, visible value prop.
- **Readability:** Visible on game-start screen — instant understanding.

#### Replace `doubleServe` → **Time Freeze** ⏸️ (gold)

> *Pause the opponent's timer for 5 seconds.*

- **Inspiration:** Match Masters' attack-oriented power-ups (Spinning Wheel, etc.).
- **Use case:** Final seconds of a tied match — freeze opponent, complete one more serve, win.
- **Power:** Match-deciding. Gold tier strongly justified.
- **Symmetry with customerLock:** silver freezes 1 customer for 8s; gold freezes the entire opponent for 5s. Clear tier ladder.
- **Strategic significance:** **The first active attack on the opponent in the roster.** Gives endgame players agency that the previous roster did not.

#### Bugfix: `autoServe` duration

Description currently says "20s", `CFG_MATCH.AUTO_SERVE_DURATION` is `30` ([index-v7.html:3968](index-v7.html#L3968)). Align to **20s** in both. Rationale: 30s = ~33% of a 90s match on autopilot, too dominant. 20s = strong but still requires player engagement for the remaining 70s.

### Refactored roster

| Tier      | Booster              | Effect                                              | Archetype       |
|-----------|----------------------|-----------------------------------------------------|-----------------|
| 🥉 bronze | extraBottle 🧪       | +1 empty bottle for the match                       | utility         |
| 🥉 bronze | **Pre-Sort 🧹**       | Start with 1 color pre-consolidated                | utility         |
| 🥉 bronze | spawnPlus3 ✨        | +3 spawn charges at start                           | stat buff       |
| 🥈 silver | colorSplash 🎨       | Recolor top ≤2 layers to customer color             | board-fix       |
| 🥈 silver | **Tube Sort 🌀**      | Consolidate one color into one chosen bottle       | board-power     |
| 🥈 silver | customerLock 🔒      | Freeze 1 customer's patience for 8s                 | time-pvp (def)  |
| 🥇 gold   | clearBottle 🗑️       | Discard all contents of 1 bottle                    | escape          |
| 🥇 gold   | autoServe ⚡         | 20s auto-serve of serveable bottles                 | autopilot       |
| 🥇 gold   | **Time Freeze ⏸️**    | Freeze opponent's timer for 5s                     | time-pvp (off)  |

### Tier-level design grammar (after refactor)

- **Bronze:** mild personal utility — three different angles (empty space, board state, spawn pacing)
- **Silver:** strategic board manipulation + defensive PvP — four boosters covering recolor, consolidation, and customer protection
- **Gold:** decisive game-breakers — board destruction, autopilot, opponent attack

Each tier has its **own role** in the PvP learning ladder:
- bronze → "learn to manage your board"
- silver → "learn to defend your time"
- gold → "learn to attack the opponent"

### Pricing

Prices retained at **50 / 150 / 400 coins** for bronze / silver / gold respectively. Tube Sort and Time Freeze are strictly more powerful than the items they replace, but coin economy implications should be reviewed by the economy team before commit (see Open Questions).

---

## 5. Arena → Booster Unlock Schedule

Mapped across the 14-arena ladder. Rules:

- Color-introduction arenas (4, 6, 9, 12) **do not unlock new boosters** — players consolidate the new color first
- Arena 8 (Stakes unlock) **does not unlock a new booster** — Stakes ×2/×3/×4 is the headline reward
- Tiers ramp: bronze (1–3) → silver (5, 7, 10) → gold (11, 13, 14)
- 2 booster "rest" arenas at 8 and 12 (between dense gold unlocks)

| #  | Arena             | New booster              | Tier   | Cumulative roster |
|----|-------------------|--------------------------|--------|-------------------|
| 1  | Juice Stand       | extraBottle + **Pre-Sort** (starters) | bronze | 2 |
| 2  | Lemonade Stand    | —                        | —      | 2                 |
| 3  | Smoothie Bar      | spawnPlus3               | bronze | 3                 |
| 4  | Boba Tea          | — (new color)            | —      | 3                 |
| 5  | Coffee House      | colorSplash              | silver | 4                 |
| 6  | Tea Garden        | — (new color)            | —      | 4                 |
| 7  | Iced Café         | **Tube Sort**            | silver | 5                 |
| 8  | Cocktail Lounge   | — (🔓 Stakes ×2/×3/×4)   | —      | 5                 |
| 9  | Tiki Bar          | — (new color)            | —      | 5                 |
| 10 | Wine Cellar       | customerLock             | silver | 6                 |
| 11 | Whiskey Den       | clearBottle              | gold   | 7                 |
| 12 | Champagne Room    | — (new color)            | —      | 7                 |
| 13 | Penthouse Bar     | autoServe                | gold   | 8                 |
| 14 | Grand Hotel       | **Time Freeze**          | gold   | 9                 |

**Endgame fantasy at Arena 14 (Grand Hotel):**
- Final 8th color unlocked
- Final bottle slot unlocked (max board = 14)
- First-ever direct attack on opponent unlocked (Time Freeze)
- Player has arrived at the top of the ladder with the complete arsenal

---

## 6. Implementation Notes

### Code changes required

- **[index-v7.html:1235-1248](index-v7.html#L1235-L1248)** — `BOOSTERS` object: replace `firstPour`, `swap`, `doubleServe`; fix `autoServe` description
- **[index-v7.html:3979-3988](index-v7.html#L3979-L3988)** — `ARENA_V6` object: replace 8-entry config with 14-entry config (new arena IDs: `juice`, `lemonade`, `smoothie`, `boba`, `coffee`, `tea`, `icedCafe`, `cocktail`, `tiki`, `wine`, `whiskey`, `champagne`, `penthouse`, `grand`)
- **[index-v7.html:1258-1267](index-v7.html#L1258-L1267)** — `ARENA_COIN_PAYOUT`: extend to 14 entries (interpolate win/loss/draw values)
- **[index-v7.html:1269-1279](index-v7.html#L1269-L1279)** — `ARENAS` array: extend to 14 entries with new trophy `min` values
- **[index-v7.html:1283-1292](index-v7.html#L1283-L1292)** — `ARENA_BOOSTER_UNLOCKS`: rewrite with 14 entries per the unlock schedule above
- **[index-v7.html:1294-1295](index-v7.html#L1294-L1295)** — `LEGACY_ARENA_MAP`: extend save migration to map old IDs (`juice`, `smoothie`, `coffee`, `tea`, `cocktail`, `wine`, `champagne`, `grand`) into new 14-arena slots. Recommended: legacy IDs stay at the same ordinal positions (`juice`→`juice`, `smoothie`→`smoothie`, etc., shifted as needed); legacy save trophies may straddle two new arenas — round down to the lower new arena
- **[index-v7.html:3968](index-v7.html#L3968)** — `AUTO_SERVE_DURATION`: 30 → 20
- **District system ([index-v7.html:1474+](index-v7.html#L1474))** — extend Café Row / Boulevard / Uptown to cover 14 arenas (suggested split: Café Row 1–4, Boulevard 5–8, Uptown 9–11, Penthouse District 12–14)

### New booster implementations

- **Pre-Sort (`preSort`)** — at match start, after `generateBoard`, pick a random color, find that color's layers across all source bottles, consolidate into one bottle up to capacity. Visual: a brief "✨" pulse on the pre-sorted bottle during countdown.
- **Tube Sort (`tubeSort`)** — on activation, prompt color picker (show all colors currently in play), then bottle target picker. Iterate all bottles; pop top layers matching the chosen color; push onto target up to `GLASS_CAPACITY`. Animate as flying layers.
- **Time Freeze (`timeFreeze`)** — set a flag on opponent's match state pausing their AI tick for 5s. Visual: opponent's timer chip pulses blue, "FROZEN" overlay.

### Trophy Road sync

The current 25-milestone Trophy Road ([index-v7.html:1299+](index-v7.html#L1299)) needs rebasing:
- 14 arena unlocks (replacing the old 8)
- 9 booster grants (one per booster — including the 3 new ones)
- Stakes ×2/×3/×4 unlock at Cocktail (arena 8)
- ~3 cosmetic frames retained from current Trophy Road
- Total: ~26 milestones, basically 1:1 with current count

---

## 7. Open Questions

1. **8th color (Teal) readability on small screens.** At Grand Hotel, the player faces 8 colors on a 14-bottle board in a 90s race. Pink (#FF66AA) vs Red, Teal (#00CCBB) vs Blue/Green — collision risk under time pressure. Needs playtest on smallest target device before committing to 8-color endgame. **Fallback:** cap at 7 colors and make Grand Hotel a different kind of prestige (skin / VIP-only / unique Stakes tier).
2. **Time Freeze duration tuning.** 5s is the initial proposal. 3s might be too weak for a gold-tier; 7s might be match-breaking. Needs PvP playtest in the final 20s of close matches.
3. **Coin pricing of new boosters.** Tube Sort and Time Freeze are strictly more powerful than `swap` and `doubleServe`. Whether the existing 150/400 price points are still fair needs economy review against the 14-arena coin payout curve.
4. **Trophy curve calibration.** The proposed curve assumes Mix-It's casual audience; a more competitive audience might want a steeper late-game curve (closer to MM's). Needs telemetry once live.
5. **`spawnPlus3` survival.** Kept as the third bronze, but it remains the weakest item in the refactored roster. Open to replacement with another bronze utility (e.g., "Customer Preview" — show the next 2 customers in the queue earlier than normal).

---

## 8. Verification & Sources

- Match Masters arena/studio data: [SimpleGameGuide, 2024](https://simplegameguide.com/match-masters-studios-levels/) — fan source, not officially confirmed (Candivore help center returned HTTP 403). Treat as *as of 2024, may be stale*.
- Magic Sort booster data: [App Store listing](https://apps.apple.com/us/app/magic-sort/id6499209744), [Gamigion analysis (2024)](https://www.gamigion.com/magic/), [Marlvel.ai intel report](https://marlvel.ai/intel-report/games/magic-sort) — Magic Sort is solo/untimed; comparison is structural, not direct.
- All Mix-It code references verified against `index-v7.html` in this repository (current as of v7.5).
