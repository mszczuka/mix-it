# Mix-It — Design Overview

This is the index for the **final game design**. The game runs a full genre-standard meta stack — arenas, stakes, season pass, weekly cadence, collection layer, packs, flash offers, daily habit loops — plus **Venue**, our unique plugin-themed system (the bar/café the player owns and upgrades, which has no direct Match Masters analogue).

Detail lives in six companion docs:

| Doc | Scope |
|---|---|
| [design-match.md](design-match.md) | In-match rules: core loop, customer queue, pour mechanics, scoring, color palette |
| [design-progression.md](design-progression.md) | Arena ladder, trophy formula, hard floors, Trophy Road, daily missions, Star Race |
| [design-boosters.md](design-boosters.md) | 9-booster roster, tier intent, counter-play, unlock schedule, economy |
| [design-systems.md](design-systems.md) | Matchmaking, stakes wager flow, result screen, time investment, bot AI, persistence, FTUE |
| [design-meta.md](design-meta.md) | Bar Pass, Venue, Album, Pack Opener, Weekly Missions, Flash Offers, Lucky Box, secondary currencies |
| [design-bottle-skins.md](design-bottle-skins.md) | Bottle skins — soft passive modifiers, rarity tiers, Venue integration, F2P pacing, PvP fairness caps |

The MVP slice (playtest scope, intentionally cuts a subset of the meta) is described separately in `design-mvp-playtest.md`. That doc is a **shipping plan**, not a design redirection — the final game is what these six docs describe.

---

## Archetype & plugin

- **Archetype:** PvP arena 1v1 — Match Masters / Clash Royale / Rush Royale / 8 Ball Pool / Trophy Hunter
- **Plugin:** Bottle puzzle (Magic Sort) + customer service ("your bar / your café")
- **Match format:** Real-time, 90 seconds, both players see both bottle boards and a shared customer queue
- **Win condition:** Higher score when the timer expires

---

## The four commitments

The design rests on four non-negotiable principles. Every detail in the companion docs traces back to one of them.

1. **Auto-serve is the default core-loop behavior.** A bottle that holds 4 same-color layers matching a waiting customer's order serves itself. The player's decisions live in mixing and consolidation, not in confirmation taps.
2. **Full Match Masters–scale meta + one unique system (Venue).** The retention stack matches the genre: Bar Pass (season), Weekly Missions (week), Star Race (week leaderboard), Daily Missions (day), Album (collection), Pack Opener (reveal), Flash Offers (peak monetization), Lucky Box (mid-session). **Venue is ours, not theirs** — a plugin-themed bar/café the player builds, matching the customer-service fantasy. Multiple currencies follow: coins, BPP, Sticker Tokens, Silver/Gold Pack Tokens, Venue Tokens, Venue Sticker Shards.
3. **Hard floor per arena, no seasonal trophy reset.** The trophy ladder is identity, not pacing. Players below an arena's skill ceiling park at the floor; Star Race, Weekly Missions, and Bar Pass carry retention regardless of ladder position.
4. **Booster grammar by tier.** Bronze = solo utility (no PvP). Silver = match control (board manipulation + soft denial). Gold = opponent attack (resource denial).

---

## Design principles

- **One new thing per arena promotion.** Color count and bottle count never grow in the same step (except the finale).
- **Starting state is always entropic.** Every match begins with mixed-color source bottles. No bottle is auto-servable in frame 0. No booster may pre-consolidate.
- **Customer queue is shared between both players, capped at 3 visible.** Both players race for the same customers. The visible slot count is fixed — boosters cannot extend visibility.
- **Symmetric information, asymmetric tools.** Both players see both boards and the shared queue. Players differentiate through booster mastery and decision quality.
- **Parking is intentional.** No oscillation noise on the ladder; bad-fit players get a clean home arena. Star Race, Weekly Missions, and Bar Pass compensate.
- **Result screen is rich, not minimal.** Sequential reward reveal (trophies, coins, stars, On Fire), progression notes (milestone ready, Star Race tier, daily missions, On Fire next, arena promotion), forced 1–2 s beat before "Play Again". Silent matchmaking softening on long losing streaks.
- **Plugin is visible everywhere.** Customer queue surfaces in boosters (Customer Lock), daily missions ("serve N"), arena fantasy (Juice → Grand Hotel), and attacks.

---

## File map by question

- *"What happens during a match?"* → [design-match.md](design-match.md)
- *"How do I progress on the ladder?"* → [design-progression.md](design-progression.md)
- *"What boosters exist and how do they work?"* → [design-boosters.md](design-boosters.md)
- *"How does matchmaking / stakes / result screen / FTUE work?"* → [design-systems.md](design-systems.md)
- *"What's Bar Pass, Venue, Album, packs, flash offers?"* → [design-meta.md](design-meta.md)
- *"What are bottle skins and how do they work?"* → [design-bottle-skins.md](design-bottle-skins.md)
- *"What's the MVP slice — what ships first?"* → `design-mvp-playtest.md`
