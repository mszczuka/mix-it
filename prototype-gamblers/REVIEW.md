# Gamblers Table — Archetype + Plugin Review (4-agent audit)

Date: 2026-05-15
Inputs reviewed: prototype-gamblers/index.html (1256 LoC, fully working), prototype-gamblers-idle.md (230 LoC spec)
Agents dispatched: prototype-review · prototype-economy · prototype-systems · prototype-analyst

## TL;DR

- **Archetype is mis-labeled.** It's a **Prestige Incremental** (AdCap / Cookie Clicker lineage), not an Idle Tycoon (Idle Miner / Cash Inc.). Affects every benchmark choice downstream.
- **Plugin core is solid** — click-to-flip, draggable coins, helpers, oxidation, sacrifice, alt-tables — all faithful to the Steam source.
- **Plugin identity silently eroded** by two scaffolding shortcuts the spec did not authorize: `FLIP ALL` button + `MERGE_COST=5` auto-merge. Within 10 min the player never clicks an individual coin again. (Review + Analyst agreed.)
- **Math breaks at sacrifice #4.** Threshold grows ×10/prestige, no permanent multiplier exists → loop dies. (Review + Economy agreed.)
- **Skull faucet is ~3 orders of magnitude oversized.** 5 hats × 10 skulls = 50 total lifetime sink vs ~5/sec generation. Skulls inert within minutes. (All 3 design agents flagged.)
- **Day-to-day layer is empty.** No FTUE, no daily login, no quests, no BP, no events, no inbox, no premium currency, no IAP/ad stubs, no leaderboards. (All 3 design agents flagged.)
- **Store-policy risk.** "Gamblers" name + casino aesthetic + 50/50 + skulls trips Apple Guideline 5.3 (17+ rating) and Google's expanded April/Oct 2025 gambling-policy updates. Blocker for mobile launch. (Analyst.)
- **One live bug:** `OXIDATION_MS` undefined at index.html:1195 — tick-loop oxidation visual silently broken; only renderCoins() refreshes it.

---

## Ranked holes (consolidated, cross-validated)

### 🔴 R1 — Archetype label is wrong
Code shape (log-scale prestige formula, tiered-generator ladder, flat-multiplier talent tree, auto-merge consumption, no spatial business, no managers-per-station) is **Prestige Incremental**, not Idle Tycoon. The "Idle Tycoon" label drags in wrong benchmarks (Idle Miner expects visible business expansion + manager hire-tree; this game has neither). Picking the right archetype is foundational — every meta system downstream is benched against archetype peers.

**Patch:** rename archetype to **Prestige Incremental** (or **Prestige Clicker**). Re-bench all meta systems vs AdVenture Capitalist / Cookie Clicker / Egg Inc., not vs Idle Miner.

### 🔴 R2 — Plugin identity drift via FLIP ALL + MERGE_COST
- `#flipAllBtn` (index.html:312, 870-884) is **not in spec**; converts per-coin-attention into one-button play.
- `MERGE_COST = 5` (index.html:497, 990-1002) auto-consumes lower-tier coins on higher-tier purchase. The spec explicitly demanded the opposite (line 22: "more coins = more flips per click cycle") and called table-filling a Validation Goal (§9.3).
- Result: by minute ~10 the donor's signature ("attend to physical coins on a table") is gone; what's left is a generic generator ladder.

**Patch:** decide once and commit:
- **Option A — Click-to-flip identity wins.** Remove FLIP ALL; remove MERGE_COST; add a hard coin cap (e.g. 30) so tier-up means *sacrificing* count for value. Physics stays meaningful.
- **Option B — Ladder identity wins.** Remove coin physics (they're decorative anyway); rebrand as "Coin Tycoon" without the gambler-table fantasy; lean into AdCap-style generator UI.
- *Currently the build straddles both and feels neither.*

### 🔴 R3 — Prestige curve dies at sacrifice #4
- Threshold = `1e5 × 10^sacrificeCount`: 100K → 1M → 10M → 100M → 1B.
- Reward = `1 + floor(log10(cash/threshold))`.
- No permanent multiplier exists; talents are flat one-shot perks (max 11 SP total across all 6).
- Post-sacrifice-3, player has to redo the entire $0→$100M climb at the **same earn rate** as run 1.

**Patch:** add `globalMult = 1 + sacrificeCount × 0.25` (or per-SP perm-bonus track separate from one-shot talents). Classic AdCap "Angels" / Cookie Clicker "Heavenly Chips" shape — non-negotiable for an incremental.

### 🔴 R4 — Day-scale layer is empty
Five cadence buckets — daily / weekly / seasonal / annual + permanent. Only **permanent** has content (sacrifice). Idle/incremental D7 ~15-20% retention is unreachable without daily anchors.

Minimum-viable patch stack (in priority order, each is its own ClickUp-sized chunk):
1. Daily login calendar (7-day or 28-day rotating)
2. 3 daily quests with rotating template (flip N, trigger M oxidations, hire 1 helper)
3. Inbox + 4 push triggers (offline-cap-full, oxidation-ready, daily-reset, event-ending)
4. Weekly Lucky Table event (temporary table modifier, 7-day window)
5. 4-week season pass (XP from flips/sacrifices, free + premium track)

### 🔴 R5 — Skull currency dies in <60 seconds
- Faucet: 50% of flips → 1 skull. Mid-game ~5/sec, ~18K/hr.
- Sink: 50 skulls total (5 hats × 10) — reachable in 10 seconds of mid-game.
- Skull Table (30/70 cash/skulls) actively makes the imbalance worse; High Roll Table (no skulls) is a strict upgrade once you've collected all 5 hats.

**Patch:** dupe-to-shard system, escalating gacha cost (10 → 25 → 50 → 100…), or skull-priced upgrades (talent re-spec, helper boost, oxidation early-trigger). Add 20+ hats minimum (Steam source has 149).

### 🔴 R6 — Store-policy / IP risk
- Name "Gamblers Table" is a trademarked Steam IP (greenpixels & Bossforge); cannot ship under that title.
- Casino aesthetic + "Gamblers" word + skulls + 50/50 + "High Roll Table" hits Apple Guideline 5.3 → 17+ rating (June 2025 update). Likely also Google policy friction (April + Oct 2025 updates).
- Apple 17+ rating crushes installs in this category.

**Patch:** rename project; replace skull symbology (clover / X / "miss" coin); reframe 50/50 as "two rewards" not win/lose (already a stated design rule — visually enforce it); publish gacha drop rates per loot-box disclosure regs.

### 🟡 R7 — Platinum minion mathematically unbuyable
- Cost: $10M. Earn rate: 1500 × 0.20 × 0.5 = $150/s.
- Payback: 66,667s = 18.5h. Offline cap = 4h.
- **Cannot be recouped passively, ever.**

**Patch:** drop cost to ~$2M, OR raise flipsPerSec to 1.0, OR raise offline cap to 24h for higher-tier minions. (Economy agent flagged Gold minion as borderline too.)

### 🟡 R8 — Talent tree depth way too thin
- 6 nodes, all flat one-shots, no branching, no synergy. Source game promises "talents that flip your strategy" (per Steam page); prototype talents are "+10% cash."
- Mobile-genre baseline is 20-40+ nodes across multiple axes (income / automation / helpers / cosmetic / risk).

**Patch:** expand to ~25 nodes in a real tree with prerequisites; add re-spec via skull sink (kills two birds, see R5).

### 🟡 R9 — Tier ramp incoherent without merge cap
- Buying 50 extra Coppers ($500) yields $25/flip; buying 1 Silver ($500) yields $5/flip. **Silver dominated by Copper spam unless coin count is capped.**
- The cap currently exists only via MERGE_COST (auto-consume 5 lower per 1 higher). If R2 is patched by removing MERGE_COST, R9 must be patched in tandem.

**Patch:** depends on R2 resolution. If Option A (keep physics): add explicit table cap; show "X / 30" counter; tier-up consumes count visibly. If Option B (kill physics): replace tier-buy with AdCap-style "Owned: N, Buy ×1/×10/×100" UI.

### 🟡 R10 — Zero FTUE / zero first-payment hook
- No `state.ftueStep` field, no tutorial, no progressive tab unlock — all 5 bottom-nav tabs visible from second 1.
- No starter pack, no first-paywall, no "show me a gem icon" moment.
- D1 retention is decided in the first 5 minutes; the prototype's good loop is invisible without staging.

**Patch:** FTUE state machine with: forced first flip (highlight) → first skull reveal explanation → oxidation discovery beat at ~90s → first-sacrifice cinematic at ~15min → starter pack offer (no-op stub OK) at `sacrificeCount === 1`. Tabs unlock progressively (Coins first, Helpers after first helper, Tables after first sacrifice, Skills permanently from sacrifice #1).

### 🟢 R11 — Live bug: oxidation visual refresh
`tick()` at index.html:1186-1200 references undefined `OXIDATION_MS`. Should be `oxidationMs()`. Currently the in-tick visual refresh silently no-ops; oxidation glow only updates on `renderCoins()` calls (renderShop loop calls it indirectly every 1s). Functional but degraded.

### 🟢 R12 — `super_lucky` talent violates own design rule
Spec §10 line 197: "The 50/50 is real and uncompromising. Don't soften it to 70/30." Talent `super_lucky` (index.html:587) shifts to 55/45. Either delete the talent or rewrite the rule.

### 🟢 R13 — Innovation in archetype layer (risk flag)
Tables-as-global-modifier (5 alt rule sets, SP-gated) is structurally novel for incremental archetype. Framework guidance is "innovate in plugin, copy archetype." This is innovation in the wrong layer. May still work — flag to validate playtest-side, not assume.

### 🟢 R14 — Social / competitive layer = zero
For an incremental, minimum-viable: async leaderboards (sacrifices-this-week, fastest-to-prestige) + one synthetic "Rival ghost" card on Home. Skip guilds/PvP at this scope. Not blocker; D14+ retention nice-to-have.

---

## What's working (don't touch)

- Click-to-flip moment-to-moment juice — flip anim + float text + helper-toss particle (index.html:822-855, 708-740). Solid.
- Oxidation alt-loop is the plugin's most distinctive innovation — keep, polish FTUE for discoverability.
- Save/load + auto-save at 5s — works.
- Offline earnings model with 4h cap — correct shape for the archetype.
- Helper-throws-coin visual (708-740) is richer than the Steam source (which uses simple auto-flip).

## Source-fidelity score

| Layer | Faithfulness vs Steam Gamblers Table | Notes |
|---|---|---|
| Core mechanic | High | 50/50, draggable coins, oxidation, tiers — all present |
| Helpers | High | Visible lane + throw animation (richer than source) |
| Hat gacha | Low (scope) | 5 hats vs 149 in source — appropriate for prototype |
| Talent tree | Low (depth) | 6 flat nodes vs source's strategy-flipping branching tree |
| Alt-tables | Medium | Structure matches, specific table effects invented |
| Mobile adaptation | N/A | Source is desktop; offline cap + bottom-nav are mobile-add |

---

## Suggested next moves (you pick)

1. **Patch R1-R6 (red tier) before any new content** — these are foundational. Estimated 2-3 days of HTML iteration: rename archetype, kill or commit FLIP ALL+MERGE, add prestige perm-mult, build daily/inbox stack stubs, rename + de-gamble the theme.
2. **Or freeze HTML, port to Unity, fix in Unity** — viable if you want the Unity meta-system layer (BP, daily quests, inbox) to be the *first* place these systems get built. R1 (archetype rename) is still required up-front.
3. **Or scope-down** — accept R4 and R10 as "Phase 2" (already spec'd that way) and only patch R1-R3 and R5-R6 now. Demo-quality prototype with known meta gaps.

---

## File references

- `prototype-gamblers/index.html` lines: 312 (FLIP ALL), 487-527 (CONFIG), 497 (MERGE_COST), 509-516 (TALENTS), 520-527 (TABLES), 587 (super_lucky), 610-616 (sacrifice math), 822-855 (flipCoin), 1186-1200 (tick + OXIDATION_MS bug), 1205-1228 (offline calc)
- `prototype-gamblers-idle.md` §3 (time-scales), §5 (data model), §8 (tuning), §9 (validation goals), §10 (critical rules)
- Source: [Steam](https://store.steampowered.com/app/3618390/Gamblers_Table/), [Kotaku 2026-01](https://kotaku.com/i-cant-stop-flicking-coins-and-hiring-tiny-dudes-in-this-new-steam-game-2000660664), [NeonLightsMedia](https://www.neonlightsmedia.com/blog/gamblers-table-review-idle-clicker-coins), [Apple 17+ policy](https://www.casino.org/news/apple-is-requiring-gambling-apps-to-come-with-17-ratings/)
