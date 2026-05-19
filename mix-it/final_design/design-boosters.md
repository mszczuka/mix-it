# Mix-It — Booster Design

Nine boosters across three tiers. Full spec, tier intent, counter-play, prices, unlock schedule, in-match effects, and economy.

For in-match effect rules see [design-match.md §9](design-match.md). For unlock placement on the Trophy Road see [design-progression.md §5](design-progression.md).

---

## 1. Roster

| Tier      | Theme                                          | Boosters                                       |
|-----------|------------------------------------------------|------------------------------------------------|
| 🥉 Bronze | Solo utility (no PvP)                          | Extra Bottle, Mise en Place, Combo Primer      |
| 🥈 Silver | Match control (board manipulation + soft denial) | Color Splash, Tube Sort, Customer Lock        |
| 🥇 Gold   | Opponent attack (resource denial)              | Clear Bottle, Bottle Lock, Time Freeze         |

---

## 2. Full booster spec

### Bronze tier — solo utility, passive

| Booster        | Effect                                                                 | Activation | Decisions |
|----------------|------------------------------------------------------------------------|------------|-----------|
| Extra Bottle   | +1 empty bottle is added to the player's board at match start          | Pre-equip (auto-applied at match start) | 0 |
| Mise en Place  | The first customer in the queue arrives with +10 s patience            | Pre-equip (auto-applied at match start) | 0 |
| Combo Primer   | The player's combo timer is set to 10 s at match start. The first serve qualifies as combo step 2 (+50 bonus instead of 0) | Pre-equip (auto-applied at match start) | 0 |

### Silver tier — match control, in-match activation

| Booster        | Effect                                                                 | Activation | Decisions |
|----------------|------------------------------------------------------------------------|------------|-----------|
| Color Splash   | Recolor the top contiguous monochrome segment of one of the player's bottles (up to 2 layers) to a chosen color | Tap booster → pick bottle → pick color | 2 |
| Tube Sort      | Pick a color and a target bottle on the player's board. All top layers of that color across the player's bottles snap to the target, capped at glass capacity | Tap booster → pick color → pick target bottle | 2 |
| Customer Lock  | The customer currently in slot 0 of the shared queue is frozen for 8 s — their patience timer does not tick down during the lock | Tap booster (no target needed; always slot 0) | 0 (target is fixed) |

### Gold tier — opponent attack, in-match activation

| Booster        | Effect                                                                 | Activation | Decisions |
|----------------|------------------------------------------------------------------------|------------|-----------|
| Clear Bottle   | One of the player's own bottles is emptied instantly. Layers are discarded | Tap booster → pick own bottle | 1 |
| Bottle Lock    | Pick one of the opponent's bottles. Locked for 10 s — opponent cannot pour to or from it. Contents preserved | Tap booster → pick opponent bottle | 1 |
| Time Freeze    | Pause the opponent's match timer for 5 s. The opponent's score window shrinks; the shared customer queue continues to age | Tap booster (no target) | 0 |

---

## 3. Tier intent

### Bronze — teaches solo play

All three bronze boosters are **passive** — no in-match input needed beyond owning the booster. The player learns the booster has a **cost** (a slot, paid pre-match) and an **effect** (visible at match start), but does not yet learn timing.

- **Extra Bottle** teaches board management (more space = more options)
- **Mise en Place** teaches queue management (first customer has more time)
- **Combo Primer** teaches the combo system (player notices the +50 callout on first serve)

Bronze has **zero PvP**.

### Silver — teaches match control

Silver boosters introduce **in-match activation** and **target picking**. Each silver booster requires the player to make a decision during the 90-second match — when to spend, what to spend on.

- **Color Splash** teaches surgical board fixes
- **Tube Sort** teaches large-scale board consolidation
- **Customer Lock** teaches queue management at a strategic moment

Customer Lock is the first booster that touches the **shared customer queue**. It locks slot 0 — meaning both players are denied the walkaway penalty on that customer, and the booster user buys themselves time to serve before the opponent does.

### Gold — teaches opponent attack

Gold boosters introduce **direct interference with the opponent's match state**. Each gold booster denies the opponent a resource.

- **Clear Bottle** is a one-sided reset on the player's own board — it's a "panic button" escape
- **Bottle Lock** denies the opponent one bottle for 10 s — strategic, board-domain attack
- **Time Freeze** denies the opponent time — the finishing-move attack

---

## 4. Counter-play map

How a defender can mitigate each attack:

| Attack on the player                   | Defender's options |
|----------------------------------------|---------------------|
| Customer Lock on slot 0 (8 s freeze)   | Serve other queue slots; the rest of the player's board still works; the lock prevents walkaway, so the player doesn't lose −25 if patience runs out |
| Bottle Lock on a player bottle (10 s)  | Pour from / to the player's other bottles; Extra Bottle (if equipped) gives a wider buffer; Clear Bottle reorganizes elsewhere |
| Time Freeze on player timer (5 s)      | No direct counter — encourages building a score lead before the final 10 s; once timer resumes, the player has lost the time gap |

**Time Freeze is uncountered by design.** Each tier needs one match-breaking ability; in gold, that ability lives on the time axis.

**Bottle Lock and Customer Lock have clean counter-play.** This is intentional: gold has a hierarchy where Bottle Lock is the **strategic attacker** (set up, plan around it) and Time Freeze is the **finisher** (deploy in final 10 s for the win).

---

## 5. Pre-match equip & in-match activation

### Equip

Before each match (on the matchmaking screen), the player **equips up to 3 boosters** — one per tier (one bronze, one silver, one gold). The player can equip fewer (zero in any tier is allowed).

- Equipping a booster does **not** consume it. Boosters live in the player's inventory as **owned items**; equipping is just selection.
- A booster slot can be left empty.
- The same booster cannot be equipped in multiple slots (the tier filter prevents this).

### Consumption

A booster is **consumed when used**. Specifically:

- **Bronze boosters:** consumed on match start (they auto-apply once the countdown ends). Even if the match is forfeited, the booster is consumed.
- **Silver and Gold boosters:** consumed on activation in-match. If the player never activates them, the booster is **returned to inventory** at match end. The booster is locked-in only when the activation tap fires.

### Per-match limits

- One activation per booster per match. After a silver or gold booster is activated, its slot is empty for the rest of the match.
- No cooldown between booster activations beyond the one-per-match limit. The player can use silver → gold → next slot — all within the same 90 s if owned and timed.

---

## 6. Pricing & shop economy

### Shop prices (coin only)

| Tier   | Coin price |
|--------|-----------:|
| Bronze | 50         |
| Silver | 150        |
| Gold   | 400        |

The booster shop sells one of each unlocked booster individually. Player taps **buy**, pays coins, booster is added to inventory.

### Inventory model

- Boosters are **stackable**. The player can own multiple of the same booster.
- No cap on inventory size per booster.
- Inventory is **persistent** — boosters owned today are still owned tomorrow, across sessions, across arena promotions.

### Acquisition paths

A booster can enter the player's inventory by:

1. **Shop purchase** — coin price per tier (above)
2. **Trophy Road grant** — milestones grant either a specific booster (on the milestone arena's unlock) or a free booster of an unlocked tier (see [design-progression.md §5](design-progression.md))
3. **Daily missions all-3 bonus** — one free random booster from the highest unlocked tier, weighted 50% bronze / 35% silver / 15% gold

There are no boosters granted from Star Race (Star Race is cosmetic-only).

### Booster grants

When a player crosses a Trophy Road milestone that **unlocks a new booster**, the player receives **one** of that booster as a free starting grant. After that, the booster is available for purchase from the shop.

When a Trophy Road "Between" milestone grants `1 free silver booster` or `1 free gold booster`, the player can choose which booster of that tier they receive (UI: small picker on the milestone collect screen). If only one booster of that tier is currently unlocked, no picker is shown.

---

## 7. Booster unlock schedule

Mapped across the 14-arena ladder. Rules:
- Color-introduction arenas (4, 6, 9, 12) do **not** unlock boosters — players consolidate the new color first
- Arena 8 (Stakes unlock) does **not** unlock a booster — Stakes is the headline reward
- Tiers ramp: bronze (1–3) → silver (5, 7, 10) → gold (11, 13, 14)

| #  | Arena             | New booster                                  | Tier     | Cumulative |
|----|-------------------|----------------------------------------------|----------|-----------:|
| 1  | Juice Stand       | Extra Bottle + Mise en Place (starter pair)  | bronze   | 2 |
| 2  | Lemonade Stand    | —                                            | —        | 2 |
| 3  | Smoothie Bar      | Combo Primer                                 | bronze   | 3 |
| 4  | Boba Tea          | — (new color)                                | —        | 3 |
| 5  | Coffee House      | Color Splash                                 | silver   | 4 |
| 6  | Tea Garden        | — (new color)                                | —        | 4 |
| 7  | Iced Café         | Tube Sort                                    | silver   | 5 |
| 8  | Cocktail Lounge   | — (Stakes ×2/×3/×4 unlock)                   | —        | 5 |
| 9  | Tiki Bar          | — (new color)                                | —        | 5 |
| 10 | Wine Cellar       | Customer Lock                                | silver   | 6 |
| 11 | Whiskey Den       | Clear Bottle                                 | gold     | 7 |
| 12 | Champagne Room    | — (new color)                                | —        | 7 |
| 13 | Penthouse Bar     | Bottle Lock                                  | gold     | 8 |
| 14 | Grand Hotel       | Time Freeze                                  | gold     | 9 |

**Endgame fantasy at Arena 14 (Grand Hotel):**
- Final 8th color unlocked
- Final bottle slot unlocked (max board = 14)
- First-ever direct timer attack unlocked (Time Freeze)
- Player has arrived at the top with the complete arsenal

---

## 8. Booster availability gating

A locked booster is **invisible in the shop** until the player crosses its unlock milestone. Once unlocked:

- Visible in shop for coin purchase
- Eligible for daily missions all-3 bonus (random pick)
- Eligible for "free silver/gold booster" Trophy Road grants (in-tier picker)

A booster cannot be acquired before its unlock arena under any path — including Trophy Road. The schedule above is the authoritative ordering.

---

## 9. Match Booster Bar UI (rules, not visual spec)

This doc owns the rule layer of the booster activation UI. Visual / animation spec is owned by the polish doc.

- 3 booster slots are shown at the bottom of the match HUD (one bronze, one silver, one gold)
- Each slot shows the equipped booster's icon, name, and tier color
- Bronze slot icons show as "active" during match (booster effect has been applied) — non-interactive
- Silver and Gold slot icons are interactive **taps**. After tap:
  - Slot enters a target-pick mode if the booster needs targets (see §2 column "Decisions")
  - Tap on a valid target activates the effect
  - Slot greys out for the rest of the match
- If a booster's target picker times out (no target picked after, say, 8 s of indecision), the activation cancels and the slot remains active — the player keeps the booster for later use in the match

No special icon state exists for "used vs unused" past match end — boosters are settled when the result screen presents.
