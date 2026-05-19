# Mix-It — Progression Design

Arena ladder, trophy formula, hard floors, Trophy Road, daily missions, Star Race.

For in-match rules see [design-match.md](design-match.md). For booster unlocks see [design-boosters.md](design-boosters.md).

---

## 1. Arena ladder — 14 arenas

**Design principle: no arena introduces both a new color AND a new bottle in the same step** (except the finale). Color-introduction arenas keep the board size constant. Bottle-growth arenas reuse the existing color set.

| #  | Arena             | Colors | Source | Empty | Total | Change |
|----|-------------------|--------|--------|-------|-------|---|
| 1  | Juice Stand       | 3      | 3      | 2     | 5     | start |
| 2  | Lemonade Stand    | 3      | 3      | 3     | 6     | +empty |
| 3  | Smoothie Bar      | 3      | 4      | 3     | 7     | +source |
| 4  | Boba Tea          | **4**  | 4      | 3     | 7     | **+color** |
| 5  | Coffee House      | 4      | 4      | 4     | 8     | +empty |
| 6  | Tea Garden        | **5**  | 4      | 4     | 8     | **+color** |
| 7  | Iced Café         | 5      | 5      | 4     | 9     | +source |
| 8  | Cocktail Lounge   | 5      | 5      | 5     | 10    | +empty + **Stakes ×2/×3/×4 unlock** |
| 9  | Tiki Bar          | **6**  | 5      | 5     | 10    | **+color** |
| 10 | Wine Cellar       | 6      | 6      | 5     | 11    | +source |
| 11 | Whiskey Den       | 6      | 6      | 6     | 12    | +empty |
| 12 | Champagne Room    | **7**  | 6      | 6     | 12    | **+color** |
| 13 | Penthouse Bar     | 7      | 7      | 6     | 13    | +source |
| 14 | Grand Hotel       | **8**  | 7      | 7     | **14**| **+color +empty (finale)** |

Constants: glass capacity = 4 layers, match duration = 90 s.

### Color readability requirement

The 8th color at Grand Hotel ships only after the smallest supported device passes a structured legibility test (colorblind simulation, peripheral vision check, sub-300 ms recognition test). This is an implementation gate — Grand Hotel is defined with 8 colors, and any device that cannot render them legibly is unsupported.

---

## 2. Trophy formula

Asymmetric win/loss. Win base is constant at +25. Loss base climbs from −15 to −20 across the ladder — early arenas are forgiving (Net +5 @ 50% WR), late arenas demand a clearly positive win rate to keep climbing.

| #  | Arena             | Win  | Loss | Net @ 50% | Floor |
|----|-------------------|-----:|-----:|----------:|------:|
| 1  | Juice Stand       | +25  | −15  | +5.0      | 0     |
| 2  | Lemonade Stand    | +25  | −15  | +5.0      | 100   |
| 3  | Smoothie Bar      | +25  | −15  | +5.0      | 250   |
| 4  | Boba Tea          | +25  | −16  | +4.5      | 400   |
| 5  | Coffee House      | +25  | −16  | +4.5      | 600   |
| 6  | Tea Garden        | +25  | −17  | +4.0      | 850   |
| 7  | Iced Café         | +25  | −17  | +4.0      | 1,100 |
| 8  | Cocktail Lounge   | +25  | −18  | +3.5      | 1,400 |
| 9  | Tiki Bar          | +25  | −18  | +3.5      | 1,750 |
| 10 | Wine Cellar       | +25  | −19  | +3.0      | 2,150 |
| 11 | Whiskey Den       | +25  | −19  | +3.0      | 2,600 |
| 12 | Champagne Room    | +25  | −20  | +2.5      | 3,100 |
| 13 | Penthouse Bar     | +25  | −20  | +2.5      | 3,700 |
| 14 | Grand Hotel       | +25  | −20  | +2.5      | 4,400 |

### Modifiers

| Modifier        | Effect | Applies to |
|-----------------|--------|------------|
| On Fire ×2      | Doubles trophy and coin reward at match end | Wins only, when the player has won 3+ matches in a row in the current session |
| Stakes ×N       | Multiplies both win base and loss base by N | Both win and loss, unlocked at Arena 8 |
| Cross-arena +1  | Win × 0.5, loss × 0.25 | When matchmaking pairs the player against an opponent at +1 arena above |
| Cross-arena +2  | Win × 0.25, loss × 0.10 | When matchmaking pairs the player against an opponent at +2 arenas above |

Order of operations: `final_trophies = round( base × cross_arena_scale × stake × (on_fire ? 2 : 1) )`. On Fire never multiplies a loss.

### Draw payout

A draw (equal scores at match end) awards 0 trophies and a small fixed coin amount (see [design-systems.md](design-systems.md) for coin payout table).

---

## 3. Hard floor per arena

Trophies cannot drop below the current arena's `MinTrophies`. Once a player crosses into a new arena, they cannot demote. One rule, applied uniformly. No demotion banners, no grace periods, no per-arena exceptions.

### Parking

A player whose true skill is below an arena's level will lose more than they win, hit the floor, and stay there. This is intentional:

- The trophy ladder is **identity**, not pacing.
- Parked players still get a weekly winnable goal via **Star Race** (§7) — decoupled from arena.
- Daily missions (§6) reward play volume, not ladder position — parked players still tick progress.

### Recovery pool

A silent matchmaking intervention for severely stuck players:

- **Trigger:** the player has lost 20 consecutive matches while sitting at their arena floor.
- **Effect:** matchmaking switches the player into a recovery pool — ±300 trophy band, bot-heavy, slightly easier opponent quality.
- **Exit:** after 10 matches OR after the player wins 3 (whichever first), recovery pool ends and normal matchmaking resumes.
- **UI:** none. The intervention is silent. Players who notice the pattern read it as luck.

The trophy formula is unchanged during recovery pool; only opponent selection changes.

### Why no seasonal trophy reset — genre alignment

**Common confusion:** "but archetype games reset trophies, no?" The answer is: **yes, but only for the top-tier elite, never for the casual majority**. Mix-It's entire ladder maps to the casual-majority zone.

#### Two-mode ladder pattern in the archetype

Genre-leading PvP 1v1 mobile games run **two distinct ladder modes layered on top of each other**:

1. **Casual ladder (below threshold)** — permanent climb, hard floor, **no reset**. The identity track for the 90%+ of players.
2. **Competitive top ladder (above threshold)** — periodic reset, leaderboard race, prestige rewards. Where the top elite competes.

Below the threshold trophies act like identity ("how far have I climbed"). Above the threshold they act like ranked points ("how high did I peak this season").

#### Per-game thresholds — where each ladder switches mode

| Game | Reset above threshold | Threshold | Below threshold (where Mix-It lives) |
|---|---|---|---|
| **Clash Royale** | Monthly soft reset, trims to 10k–12k band scaled by peak | **10,000 trophies** | **No reset. Hard arena gates. Never demotes.** |
| **Match Masters** | Monthly hard reset to 30,000 | **30,000 trophies** (Legends League entry) | **No reset. Permanent climb.** |
| **Brawl Stars** | Per-brawler monthly reset to 1,000 (Feb 2026 rework is **dismantling** this in favor of Prestige) | **1,000 trophies per brawler** | **No reset.** |
| **8 Ball Pool** | Weekly promo/relegation between league brackets | bracket-based | **Brass / Bronze demotion-protected** — equivalent to hard floor |
| **Rush Royale** | Universal reset to 4,000 each ~30 days (outlier — smaller-audience title) | none | n/a — everyone resets |

Sources: Supercell Support (Clash Royale Trophy Road, 2025); RoyaleAPI Trophy Road rework (2025-07); Match Masters Fandom (Seasons / Masters & Legends League); Candivore Zendesk (Masters Ranks, 2024–25); Supercell News (Brawl Stars Trophy Season Rework, 2026); MY.GAMES Support (Rush Royale End of Season); Miniclip Support (8 Ball Pool Leagues, 2024–25).

#### Where Mix-It sits

Our 14-arena ladder spans **0 → 4,400 trophies** (Juice Stand → Grand Hotel).

- 4,400 < 10,000 (Clash Royale threshold) ✓
- 4,400 < 30,000 (Match Masters threshold) ✓
- 4,400 ≫ 1,000 in absolute terms but mapped onto our per-game scale this is equivalent territory to Brawl Stars below-threshold range

**Mix-It's entire ladder maps onto the "casual ladder below threshold" zone of every reference game.** In Clash Royale, Match Masters, and Brawl Stars, a player with trophies anywhere in our 0–4,400 range **never experiences a trophy reset**. Hard floor, permanent climb.

So our design — no reset, hard floor per arena, no demotion — is **identical** to what these games do for players in our trophy range. We are not out of step; we are mirroring exactly.

#### What we DO reset (just not trophies)

Trophies are not the only periodic system. Two other cadences exist and **do** reset:

- **Bar Pass — monthly seasonal reset.** ~30 days per season. BPP counter resets to 0; Bar Pass tier rewards expire; seasonal Album rotates. See [design-meta.md §1](design-meta.md).
- **Star Race — weekly reset.** Monday 00:00 local. Stars reset to 0; bucket position resets; cosmetic frame paid out per final placement. See §7.

These are the **seasonal** and **weekly** cadences the archetype expects — but they apply to season-pass progress and leaderboard stars, not to the trophy ladder. The trophy ladder remains permanent.

#### Genre trend (last 12 months)

Moving **toward** permanence for the casual majority, **away from** punishing resets:

- Clash Royale, July 2025 — expanded the no-reset zone (everything under 10k is now formally permanent)
- Brawl Stars, Feb 2026 — announced removal of Trophy Season resets in favor of permanent Prestige + a 4-month Pro Pass

The archetype is moving in the direction we already chose.

#### Conclusion

Mix-It's "no reset, hard floor, parking intentional" stance is **correct for the current 14-arena range**. Bar Pass (monthly) and Star Race (weekly) deliver the cadences. Trophies remain permanent identity.

### Post-launch lever (not in scope for MVP or v1)

If, after launch, telemetry shows the top ~5% of players stacking at the Grand Hotel floor and the top of the ladder loses competitive differentiation, the lever is:

- **Add a 15th tier "Legends Lounge" (or similar) at ~5,500+ trophies**
- Apply a **monthly threshold soft reset modeled on Clash Royale**: at season end, trophies above 5,500 are trimmed to a 5,500–6,000 band scaled by peak placement
- **Below 5,500, nothing resets** — preserves the identity climb for everyone under the threshold
- Reward at reset: cosmetic season badge + Bar Pass premium tier boost

This lever is held in reserve. Do not add it speculatively — only if the top-stack problem is measured.

---

## 4. Promotion behaviour

When a player's trophies cross into a new arena's floor:

1. Arena state advances (visible immediately on Home / HUD)
2. Trophy Road milestone triggers (booster grant, Stakes unlock, or cosmetic — see §5)
3. Promotion banner shows on next return to Home
4. Bot pool, color count, and bottle count change starting from the next match
5. Cross-arena scaling rules apply to any matchmaking against neighbours at the old arena

There is no animation gate on promotion — the player can play their next match immediately at the new arena's config.

---

## 5. Trophy Road — 26 milestones

Trophy Road runs along the trophy axis. Milestones interleave between arena floors so players get reward beats during long climbs, not just at promotion moments.

**Composition:** 14 arena-entry milestones (most carrying a booster grant or the Stakes unlock) + 12 between-arena milestones (coin grants and 3 cosmetic frames). 26 total.

| #  | Trophies | Type        | Reward                                          |
|----|---------:|-------------|-------------------------------------------------|
| 1  | 0        | Arena entry | Juice Stand + Extra Bottle + Mise en Place      |
| 2  | 50       | Between     | 200 coins                                       |
| 3  | 100      | Arena entry | Lemonade Stand                                  |
| 4  | 175      | Between     | 300 coins + cosmetic frame I                    |
| 5  | 250      | Arena entry | Smoothie Bar + Combo Primer                     |
| 6  | 325      | Between     | 400 coins                                       |
| 7  | 400      | Arena entry | Boba Tea (4th color)                            |
| 8  | 500      | Between     | 1 free silver booster (grant)                   |
| 9  | 600      | Arena entry | Coffee House + Color Splash                     |
| 10 | 725      | Between     | 600 coins                                       |
| 11 | 850      | Arena entry | Tea Garden (5th color)                          |
| 12 | 975      | Between     | 800 coins + cosmetic frame II                   |
| 13 | 1,100    | Arena entry | Iced Café + Tube Sort                           |
| 14 | 1,250    | Between     | 1 free silver booster (grant)                   |
| 15 | 1,400    | Arena entry | Cocktail Lounge + **Stakes ×2/×3/×4 unlock**    |
| 16 | 1,575    | Between     | 1,000 coins                                     |
| 17 | 1,750    | Arena entry | Tiki Bar (6th color)                            |
| 18 | 1,950    | Between     | 1,200 coins                                     |
| 19 | 2,150    | Arena entry | Wine Cellar + Customer Lock                     |
| 20 | 2,375    | Between     | 1 free gold booster (grant)                     |
| 21 | 2,600    | Arena entry | Whiskey Den + Clear Bottle                      |
| 22 | 2,850    | Between     | 1,500 coins + cosmetic frame III                |
| 23 | 3,100    | Arena entry | Champagne Room (7th color)                      |
| 24 | 3,700    | Arena entry | Penthouse Bar + Bottle Lock                     |
| 25 | 4,050    | Between     | 2,000 coins + 1 free gold booster               |
| 26 | 4,400    | Arena entry | Grand Hotel + Time Freeze (finale)              |

Milestones do **not** reset. Once claimed, a milestone is permanently consumed. Future trophy-loss back into a milestone's trophy value does not re-trigger it (and trophies can't drop below the arena floor anyway).

---

## 6. Daily missions

**3 active daily missions per day.** Refreshed every 24 hours on local midnight. No rotation pool. No weekly cadence.

### Mission slots (one of each verb-class per day)

- **Outcome:** "Win N matches today" (N = 3–5, scales by arena)
- **Plugin:** "Serve N customers today" / "Complete N flawless serves" (N tuned to ~3–5 matches of normal play)
- **Mastery:** "Use N boosters today" / "Win N matches with no booster used" (N = 2–3)

### Rewards

- **Per mission completion:** 50–100 coins (size scales with mission difficulty by arena)
- **All-3 daily bonus:** one **free random booster** from the highest tier the player has unlocked
  - 50% bronze / 35% silver / 15% gold within unlocked tiers
- Per-mission rewards are intentionally moderate. A player who completes 1 of 3 still feels accomplished. A player who completes all 3 gets a meaningful bonus pop.

### Reset rules

- Refresh time: local midnight (player's device timezone)
- Daily progress carries over within the day — finishing the 3rd mission at 23:50 still counts
- Missed missions do not bank — they reset cleanly at midnight

---

## 7. Star Race

Weekly leaderboard cycle, cosmetic-only, **decoupled from the trophy ladder**. Star Race is one of several meta layers in the full game (see [design-meta.md](design-meta.md) for Bar Pass, Album, Venue, Pack Opener, Weekly Missions, Flash Offers, Lucky Box). Star Race is documented in this doc because it is tightly coupled to per-match scoring and the result screen.

### Mechanic

- Every match awards **stars** based on performance (serves completed, win/loss, On Fire streak, score margin). Stars are separate from trophies.
- Star value is **arena-independent** — a Juice player and a Grand Hotel player both score 1–5 stars per match. **Parked players still climb their Star Race bucket every week.**
- Players are bucketed into ~100-entity leaderboards (matched on trophy range, ±400 trophies typical). Bots fill thin buckets.

### Star formula (per match)

```
stars =  base from outcome  ( win = 3, draw = 1, loss = 0 )
      +  serves contribution  ( + 1 if served ≥ 8 customers, +1 more if served ≥ 12 )
      +  on_fire bonus        ( + 1 if On Fire was active at match end )
```

Range: 0–5 stars per match. A player who loses every match still scores 0–2 stars per match (via serves and On Fire — though On Fire usually requires wins, so realistic losing-streak floor is 0–1).

### Reset and reward

- **Reset:** every Monday 00:00 local
- **End-of-week payout:** cosmetic-only rewards (frames, sticker variants, profile flair) based on final leaderboard position
- **Payout tiers (sample, exact rewards owned by content):**
  - Top 1: gold-tier cosmetic
  - Top 2–5: silver-tier cosmetic
  - Top 6–25: bronze-tier cosmetic
  - 26–100: participation flair

### Role in the design

Time-scale of each progression axis in the full game:

- **Match (90 s):** scoring, serves, combos, On Fire trigger
- **Today (1 session):** daily missions
- **This week (3–7 days):** Star Race + Weekly Missions
- **This season (~30 days):** Bar Pass
- **Months:** Trophy ladder (the identity climb, parking allowed)
- **Cross-axis collection:** Album / Venue / Pack Opener (see [design-meta.md](design-meta.md))

Star Race specifically gives a **winnable weekly goal regardless of ladder position**. A player parked at an arena floor still climbs Star Race every week, because star value is arena-independent.

---

## 8. Order of operations on match result

When a match ends, the order in which the player's state updates:

1. Match score is finalised (sum of points, walkaways applied — see [design-match.md](design-match.md))
2. Outcome computed (win / loss / draw)
3. Trophy delta computed: `base × cross_arena_scale × stake × (on_fire ? 2 : 1)`
4. Coin payout computed (see [design-systems.md](design-systems.md) for table)
5. On Fire state updated: win → streak++; loss/draw → streak resets
6. Trophies updated, **clamped to current arena floor** if dropping
7. Coins updated
8. Trophy Road milestone check — if any milestones are passed this frame, queue their rewards
9. Daily mission tick
10. Star Race stars awarded
11. Promotion check — if arena floor crossed, trigger promotion sequence on next Home return
12. Result screen presented to player
