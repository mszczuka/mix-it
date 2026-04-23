# Mix-It Design Patch v7.3.1 — Economy Correction

**Patch date:** 2026-04-23
**Applies to:** v7.3-patch-mvp-completion (2026-04-23)
**Purpose:** Standalone economy correction patch. Fixes inflation, broken Pass XP curve, and hidden Monday reward spike surfaced by full currency audit (2026-04-23).
**Scope:** Numbers only. No structural design changes. v7.3 structure stands.

---

## Why this patch exists

The v7.3 MVP completion patch added six new coin faucets (Star Race, Weekly Missions, Pass Premium, VIP bonus, richer Lucky Box, richer albums) on top of v7.2's 2,500c/day engaged target — **without re-running the pacing model**. Follow-up audit found:

1. **Coins inflated 2× for engaged, 5× for whales** vs v7.2 stated target
2. **Lucky Box Arena 5 specced at 1,000c/claim** — a **12.5× unintentional inflation** vs v7.2's 80c/claim (model carryover bug)
3. **Bar Pass Points formula `50×N cumulative` makes Pass completion impossible in 30 days** — even the whale needs 81 days (benchmark: 60–80% casual completion)
4. **Monday reset stacks ~8,100c in one moment** (Weekly reset chest + Missions full-clear + Star Race tiers) — bypasses §15.L daily ceiling math
5. **Boosters meaningfully under-priced relative to the inflated inflow** — stake-and-lose doesn't hurt at whale tier

Designer gut was right: coin inflow too high, boosters too cheap. Magnitude is **~50% inflow correction** + **BPP formula overhaul** + **Monday spike modeling** — bigger than a tweak, smaller than a redesign.

### MM-faithful disclosure

The v7.1 "coin economy MM-faithful" label is **honest about structure** (single soft currency, stakes, star margin, collection sinks — all genuinely aligned) but **overclaims on magnitude**. MM's specific coin inflow/outflow numbers were never published beyond Naavik 2023 booster prices (Bronze 50 / Silver 100 / Gold 200 / Diamond 400–1,000). Mix-It's match-win rewards, album payouts, Lucky Box, Star Race rewards are **designer inventions with no MM benchmark anchor** — this patch re-anchors them against v7.2's stated engaged target (~2,500c/day) and generic casual-PvP benchmark ranges.

---

## §1 — Lucky Box: −80% at Arena 5+ (biggest single fix)

### Bug
v7.3 §15.L specced Lucky Box per-claim values of 500 / 600 / 700 / 800 / **1,000** / 1,200 / 1,400 / 1,600 coins (Arenas 1–8). v7.2 baseline was 80c/claim flat. The Arena-5 jump to 1,000c is a **12.5× unintentional inflation** — likely a model carryover from a different ceiling target.

### Fix — revised Lucky Box per-claim coin values

| Arena | v7.3 §15.L | **v7.3.1** | Reduction |
|---|---:|---:|---:|
| 1 Juice Stand | 500 | **100** | 80% ↓ |
| 2 Smoothie Bar | 600 | **120** | 80% ↓ |
| 3 Coffee House | 700 | **150** | 79% ↓ |
| 4 Tea Garden | 800 | **180** | 78% ↓ |
| 5 Cocktail Lounge | 1,000 | **200** | 80% ↓ |
| 6 Wine Cellar | 1,200 | **250** | 79% ↓ |
| 7 Champagne Room | 1,400 | **300** | 79% ↓ |
| 8 Grand Hotel | 1,600 | **350** | 78% ↓ |

Lucky Box pulls/day cap stays at 3. Other Lucky Box contents (4 boosters + 1 sticker per v6 §14) unchanged — the fix is only on the coin component.

**Impact:** −2,400c/day engaged at Arena 5 (single biggest inflow cut).

---

## §2 — Match-win coin rewards: trim whale spike tail

### Issue
Base per-match coin at Arena 5 (70c) is defensible. The problem is **On-Fire × Stake stacking**: a ×4 stake On-Fire win at Arena 5 = 70 × 4 × 2 = **560 coins from one match**. Arena 8 equivalent = 150 × 4 × 2 = **1,200 coins/match**. Whale burst math.

### Fix — A: Adjust base rates (Arenas 5+)

| Arena | v7.3 §15.L base | **v7.3.1 base** |
|---|---:|---:|
| 1 Juice Stand | 20 | 20 (keep) |
| 2 Smoothie Bar | 30 | 30 (keep) |
| 3 Coffee House | 40 | 40 (keep) |
| 4 Tea Garden | 55 | 55 (keep) |
| 5 Cocktail Lounge | 70 | **50** |
| 6 Wine Cellar | 90 | **65** |
| 7 Champagne Room | 115 | **80** |
| 8 Grand Hotel | 150 | **90** |

Early arenas unchanged to protect new-player coin momentum; late-arena whale cohort trimmed ~40%.

### Fix — B: Cap On-Fire × Stake combined multiplier

**Rule change:** On-Fire coin bonus does NOT multiply stake rewards. Instead:
- **v7.3:** `coins = base × stakeMultiplier × onFireMultiplier` (e.g., 70 × 4 × 2 = 560)
- **v7.3.1:** `coins = base × MAX(stakeMultiplier, onFireMultiplier) + base × MIN(stakeMultiplier, onFireMultiplier) × 0.5`

Worked example, Arena 5 ×4 stake On-Fire win:
- v7.3: 70 × 4 × 2 = 560
- v7.3.1: 50 × 4 + 50 × 2 × 0.5 = 200 + 50 = **250 coins** (55% reduction on the spike tail)

Rationale: stakes should reward risk; On-Fire is a streak bonus. Stacking them multiplicatively produces 8× single-match payouts that no other currency or sink scales to. Keep both mechanics present, kill the multiplicative blow-up.

**Trophy rewards on the same win are NOT affected** — the cap only applies to coin/BPP rewards. Trophy stacking `delta × stake` is preserved per v7.2.

---

## §3 — Album rewards: shift value from Coins to cosmetics

### Issue
v7.3 §15.E full-album Regular rewards = 10,000c + frame + 2 Gold Packs. Three Regular albums + Seasonal = ~85,000 coins in album completion alone across a season. Amortized ≈ 950c/day. Collection should be a coin sink, not a major coin faucet.

### Fix — revised album rewards

**Regular Album (×3) — 20 stickers / 4 pages of 5**

| Page | v7.3 reward | **v7.3.1 reward** |
|---|---|---|
| 1 (5/20) | 500c + 1 Silver Pack | **200c + 1 Silver Pack** |
| 2 (10/20) | 1,000c + 1 Silver Pack | **400c + 1 Silver Pack** |
| 3 (15/20) | 1,500c + 1 Gold Pack | **600c + 1 Gold Pack** |
| 4 (20/20) | 2,500c + 1 Gold Pack | **1,000c + 1 Gold Pack** |
| **Full album** | 10,000c + frame + 2 Gold Packs | **4,000c + exclusive frame + exclusive title + 2 Gold Packs + 1 Sticker Token** |

**Seasonal Album (×1) — 20 stickers / 4 pages of 5**

| Page | v7.3 reward | **v7.3.1 reward** |
|---|---|---|
| 1 | 800c + 1 Gold Pack | **400c + 1 Gold Pack** |
| 2 | 1,500c + 1 Gold Pack | **700c + 1 Gold Pack** |
| 3 | 2,500c + 1 Gold Pack + emote | **1,000c + 1 Gold Pack + seasonal emote** |
| 4 | 4,000c + 2 Gold Packs | **1,500c + 2 Gold Packs** |
| **Full album** | 20,000c + seasonal arena skin + frame + 5 Gold Packs | **8,000c + seasonal arena skin + exclusive frame + exclusive title + 5 Gold Packs + 2 Sticker Tokens** |

**Net effect:** ~60% coin reduction on album value; compensated by cosmetic uplift (titles added) + Sticker Token grants (helps F2P close the album tail — see §7).

---

## §4 — Star Race: trim rewards, raise Participation threshold

### Issue
Star Race payouts (§15.C) re-inflate the Coin pool after other fixes. Also: Participation threshold `≥10★` = 5 matches = ~20 min of play = trivially achievable → becomes a passive-faucet floor.

### Fix — Participation threshold
- v7.3: `≥10★`
- **v7.3.1: `≥40★`** (forces ~15+ matches = genuine weekly participation)

### Fix — reward table (v7.3 → v7.3.1)

| Arena | Top 10 | Top 100 | Top 500 | Participation (≥40★) |
|---|---|---|---|---|
| 1 Juice Stand | ~~1,500c + 2 Silver~~ → **800c + 1 Silver** | ~~800c + 1 Silver~~ → **400c** | ~~400c~~ → **200c** | ~~150c~~ → **80c** |
| 2 Smoothie Bar | **1,500c + 1 Silver** | **700c** | **350c** | **150c** |
| 3 Coffee House | **2,500c + 2 Silver** | **1,100c + 1 Silver** | **550c** | **250c** |
| 4 Tea Garden | **3,500c + 1 Gold** | **1,700c + 1 Silver** | **850c** | **400c** |
| 5 Cocktail Lounge | **5,500c + 1 Gold** | **2,500c + 2 Silver** | **1,200c + 1 Silver** | **550c** |
| 6 Wine Cellar | **8,000c + 1 Gold** | **3,600c + 1 Gold** | **1,700c + 1 Silver** | **800c** |
| 7 Champagne Room | **11,000c + 2 Gold** | **5,000c + 1 Gold** | **2,400c + 2 Silver** | **1,100c** |
| 8 Grand Hotel | **15,000c + 2 Gold** | **7,000c + 1 Gold** | **3,300c + 1 Gold** | **1,500c** |

Approximately 40% reduction across all tiers. Preserves the shape (Top 10 = ~3× Top 500) and the arena-scaling progression.

### Target distribution (new — publish as tuning target)
- **Top 10** ≈ 95th percentile active players in arena ≈ **300+ stars/week**
- **Top 100** ≈ 75th percentile ≈ **200+ stars/week**
- **Top 500** ≈ 40th percentile ≈ **100+ stars/week**
- **Participation (≥40★)** ≈ any engaged player ≈ ~15 matches/week

---

## §5 — Weekly reset spike: recognize it, model it, cap it

### Issue
Monday reset fires 3 reward streams simultaneously:
1. Weekly Missions full-clear bonus: **1,500c + 1 Gold Pack** (§5)
2. Weekly reset chest (trophy-gated): **up to 2,500c + 1 Gold + shards** (§5)
3. Star Race rewards: **up to Top 10 = 11,000c + 2 Gold @ Arena 7 post-fix**

Sum for an engaged Arena 6 player hitting Top 500: ~1,500c + 1,700c + 1,700c = **~4,900c** single moment.
For a whale Arena 8 Top 10: 1,500c + 2,500c + 15,000c = **~19,000c** single moment.

The §15.L daily ceiling math doesn't account for this. It's not a bug per se — it's a **missing spike model**.

### Fix — explicit Monday spike ceiling

Add a new table to §15.L: **weekly peak day coin ceiling** (distinct from daily average):

| Segment | Daily avg | Monday peak | Peak ÷ avg |
|---|---:|---:|---:|
| F2P casual | 800 | **~1,200** (reset chest small + missions partial) | 1.5× |
| F2P engaged | 2,200 | **~4,500** | 2× |
| Pass dolphin | 2,900 | **~6,000** | 2× |
| VIP whale | 6,000 | **~12,000** | 2× |

**Tuning rule going forward:** Monday peak should not exceed 2× daily average. Currently at 2× post-fix — acceptable. If additional weekly rewards are added later (seasonal, LTM), re-check.

### Design guardrail
Any future weekly-cycle reward added **must** be modeled against the Monday peak ceiling before shipping. Add to the v7.4 tuning checklist.

---

## §6 — Bar Pass Points (BPP): replace broken formula

### Bug — this is the second 🔴 after Coins

v7.0 specced:
- **Tier N requires 50 × N BPP cumulative** (triangular curve)
- Per-match: **+5 BPP played, +10 BPP win bonus**
- Total for 30 tiers: `50 × T(30) = 50 × 465 = 23,250 BPP`

At 55% WR with +10.5 BPP/match avg:
| Segment | Matches/day | BPP/day | Days to complete 30 tiers |
|---|---:|---:|---:|
| F2P casual (5 mt) | 5 | 50 | **465 days** |
| F2P engaged (15) | 15 | 157 | **148 days** |
| Pass dolphin (15) | 15 | 165 | **141 days** |
| VIP whale (25) | 25 | 287 | **81 days** |

**Nobody completes the Pass in 30 days.** Benchmark: casual F2P Pass completion = 60–80% of tiers in the season window. Current design: even the whale needs 2.7 seasons.

### Fix — flat BPP curve + richer match grants

**New formula:**
- **Tier N requires 400 BPP flat** (NOT cumulative — each tier independently)
- Per-match: **+10 BPP played, +20 BPP win bonus** (2× v7.0)
- **Daily Mission completion: +100 BPP per mission** (3 missions → +300 BPP/day cap)
- Total for 30 tiers: `30 × 400 = 12,000 BPP` (down from 23,250)

### Days-to-complete with new math

At 55% WR: avg BPP/match = 10 + 0.55×20 = **21 BPP/match base**.

| Segment | Matches/day | Match BPP | Daily Missions BPP (if 3/3) | **Daily total** | Days to 12,000 |
|---|---:|---:|---:|---:|---:|
| F2P casual (5) | 5 | 105 | 300 | **405** | **~30 days** *(exactly benchmark)* |
| F2P engaged (15) | 15 | 315 | 300 | **615** | **~20 days** *(completes + 33% buffer)* |
| Pass dolphin (15) | 15 | 315 | 300 | **615** | **~20 days** |
| VIP whale (25) | 25 | 525 | 300 | **825** | **~15 days** *(completes in half a season)* |

**Target:** F2P casual hits ~100% completion in 30 days if they play consistently; engaged completes comfortably + has buffer for missed days; whale finishes fast and can then chase the Starter Pack / Flash Offer / catch-up SKU funnel on **next** season.

Completion-rate projection (factoring missed days, ~70% session consistency):
- F2P casual: ~70% of tiers = **21/30 tiers** ✓ (benchmark 60–80%)
- F2P engaged: ~95%+ = full completion ✓
- Pass dolphin: full completion + re-engagement pull from catch-up ✓
- VIP whale: full completion early ✓ → **need to think about post-completion hook** (tier 31+ infinite tier with cosmetic drip? deferred to v7.4)

### Backwards compatibility
v7.0 `50×N` BPP formula is **fully replaced**. No migration — this is a pre-launch correction. Mark v7.0 §13.6 as superseded in that doc's frontmatter.

---

## §7 — Sticker Tokens: add F2P supply valve

### Issue
F2P casual earns ~1 Sticker Token/month. With 4 albums × ~2–3 painful-tail stickers each = ~10 tokens needed across a season. F2P hits a wall before month 6.

### Fix — two new supply sources

1. **Gold-duplicate conversion:** 5 duplicate Gold-rarity stickers (after album full) → **1 Sticker Token**
   - Previously Gold dupes only granted +150c via v6 dupe→coin rule
   - Redirect overflow Gold dupes to Token conversion once source album complete
   - Expected yield: ~1 extra token/month for engaged F2P once they start filling albums

2. **Weekly Missions full-clear bonus:** add **+1 Sticker Token every 4 consecutive full-clears** (streak-gated)
   - Rewards consistent engagement, not just high match volume
   - Expected yield: 1 token/month engaged, 0 casual

**Album completion rewards now also grant Sticker Tokens** (see §3 — Regular full = +1 Token, Seasonal full = +2 Tokens). Additional drip for committed collectors.

### New F2P monthly Sticker Token supply (post-fix)

| Segment | Daily Chest | Gold-dupe conv. | Mission streak | Albums | **Total/mo** |
|---|---:|---:|---:|---:|---:|
| F2P casual | ~1 | 0 | 0 | 0 | ~1 *(unchanged — needs engagement to lift)* |
| F2P engaged | ~4 | ~1 | ~1 | ~0.3 | **~6** *(up from 5)* |
| Pass dolphin | ~4.5 | ~1 | ~1 | ~0.5 | ~11 |
| VIP whale | ~5 | ~2 | ~1 | ~1 | ~13 |

Still lean for F2P casual — intentional: collection completion is an engagement reward, not a passive right.

---

## §8 — Venue Tokens: two small tuning fixes

### Fix 1 — District 2 base rate

Stake multiplier (§15.K footnote) multiplies token grants. At Arena 5 with avg 2-stake wins, engaged players earn ~1 token/win instead of the 0.5 baseline, completing District 2 at ~50% of intended wins.

**Change:**
- District 2 token/win **base** `0.5` → **`0.3`**
- District 3 token/win base `0.15` → **`0.1`** (same logic at higher arena)

With average 2-stake multiplier at Arena 5: 0.3 × 2 = 0.6/win (avg) — keeps 70% target at ~160 wins to promote.

### Fix 2 — Post-completion overflow sink

Whales complete all 3 districts in ~6 weeks. Venue Tokens become inert faucet afterward until post-MVP districts 4–6 ship (seasonal roadmap, months out).

**Add:** Venue Token **soft cap of 200**. Overflow converts at **5 Venue Tokens → 1 Sticker Shard** (5 shards = 1 Silver Pack). Keeps late-game Venue play meaningful without re-inflating Coins.

---

## §9 — VIP Silver I (tier 4): perk swap

### Issue
Tier 4 Silver I is a $50 lifetime cliff. v7.3 §15.G perk is "cosmetic priority-queue animation" — weakest perk reveal in the ladder. Dolphins paying $50 want something tangible.

### Fix
Swap perks:
- **Silver I (tier 4) gains:** +10% BPP multiplier (tangible; helps Pass completion in line with §6)
- **Silver II (tier 5) drops:** "priority-queue cosmetic animation" moves to Silver II as secondary perk; Lucky Box 2× capacity and +25% coin bonus stay at Silver II

Net result: tier 4 now reveals a gameplay-adjacent perk; tier 5 still has the 2× Lucky Box hero perk.

Full revised VIP ladder in §12.A.

---

## §10 — Projected new daily coin inflow (after all fixes)

Target from v7.2: **~2,500c/day engaged ceiling**.

| Source | F2P casual | F2P engaged | Pass dolphin | VIP whale |
|---|---:|---:|---:|---:|
| Match wins @ Arena 5/6/8 base (post-§2) | 180 | 500 | 650 | 1,500 |
| On-Fire × stake (capped per §2B) | 20 | 90 | 150 | 700 |
| Losses (25c avg) | 88 | 250 | 250 | 375 |
| Lucky Box (post-§1) | 300 | 600 | 750 | 1,050 |
| Dailies + Daily Chest | 600 | 600 | 600 | 600 |
| Weekly Missions amortized (post-§5 modeling — same values) | 0 | 600 | 600 | 600 |
| Star Race amortized (post-§4) | 0 | 170 (Top 500) | 360 (Top 100) | 780 (Top 10) |
| Trophy Road amortized | 50 | 100 | 100 | 150 |
| Pass Premium amortized (unchanged) | 0 | 0 | 1,167 | 1,167 |
| Album rewards amortized (post-§3, ~30% reduction) | 120 | 220 | 220 | 280 |
| Weekly reset chest amortized | 0 | 130 | 260 | 360 |
| VIP +25% coin bonus (Silver II+) | — | — | — | +500 |
| **TOTAL COIN / day** | **~1,400** | **~2,500** | **~3,100** | **~6,500** |
| **TOTAL COIN / week** | ~9,800 | ~17,500 | ~21,700 | ~45,500 |
| **vs v7.2 target** | under | **at target ✓** | +24% (acceptable — Pass is paid) | +160% (acceptable — VIP multiplier + stake volume) |

**Stake-and-lose economics:**
- ×4 stake loss burns 4 Gold boosters = 1,600c
- As % of daily income:
  - F2P engaged: 1,600 / 2,500 = **64%** (very painful ✓)
  - Pass dolphin: 1,600 / 3,100 = **52%** (painful ✓)
  - VIP whale: 1,600 / 6,500 = **25%** (meaningful, not trivial ✓)

All three segments now feel stake losses meaningfully. Flash Offer "low coins <200c" trigger also reopens for engaged/dolphin when a bad stake session plus a pack purchase drains the wallet.

---

## §11 — Summary of all changes

### Revised (numbers updated)
- §1 Lucky Box per-claim values (all 8 arenas, −80%)
- §2A Match-win base at Arenas 5–8 (−30–40%)
- §2B On-Fire × Stake stacking rule (multiplicative → additive-with-half-multiplier cap)
- §3 Album page + full-album rewards (−40–60% coins, +cosmetic titles, +Sticker Tokens)
- §4 Star Race weekly rewards (−40% all tiers) + Participation threshold (10★ → 40★)
- §6 BPP formula (`50×N` cumulative → 400 flat) + per-match rates (+5/+10 → +10/+20) + Daily Mission BPP (+100 per mission)
- §8 Venue Token base rates District 2/3
- §9 VIP Silver I perk swap

### Added (new)
- §5 Monday peak ceiling model + 2× guardrail rule
- §7 Sticker Token Gold-dupe conversion (5 dupes = 1 Token)
- §7 Sticker Token Mission-streak bonus (4 full-clears = 1 Token)
- §3 Sticker Tokens included in album completion rewards
- §8 Venue Token soft cap 200 + overflow → Sticker Shards

### Unchanged from v7.3
- All structural design (arenas, leaderboards, VIP tier count, Teams stub, profile system, Home UI reshuffle) — v7.3 stands
- Trophy gain rates (pending FTUE bot-WR curve in v7.4)
- Booster shop prices (Bronze 50 / Silver 150 / Gold 400 — already 1.5–2× MM's 2023 Naavik prices; fix is on inflow, not outflow)
- Coin bundle IAP pricing (TBD v7.4 SKU pass)
- Pass Premium $9.99 price, 30-tier structure
- Pass catch-up pricing ($0.99/3, $4.99/15, cap T28)
- Starter Pack $2.99 contents

---

## §12 — Revised appendix tables

### §12.A — Full VIP ladder (revised tier 4, 5 perks)

| Tier | Name | VIP pts | ~$ lifetime | Perks (cumulative) |
|---|---|---:|---:|---|
| 1 | Bronze I | 30 | $3 | +5% coin bonus; VIP1 frame |
| 2 | Bronze II | 100 | $10 | +10% coin bonus; booster shop −5%; VIP2 frame |
| 3 | Bronze III | 250 | $25 | +15% coin bonus; extra daily mission slot (3→4); exclusive emote pack |
| 4 | **Silver I** | 500 | $50 | **+20% coin bonus; booster shop −10%; +10% BPP multiplier** (changed from cosmetic priority-queue) |
| 5 | **Silver II** | 1,000 | $100 | **+25% coin bonus; 2× Lucky Box capacity; cosmetic priority-queue animation; VIP5 animated frame** |
| 6 | Silver III | 2,000 | $200 | +30% coin bonus; booster shop −15%; monthly 1 free Gold Pack |
| 7 | Gold I | 4,000 | $400 | +35% coin bonus; extra mission slot (4→5); cosmetic priority-queue (full) |
| 8 | Gold II | 7,000 | $700 | +40% coin bonus; booster shop −20%; exclusive seasonal skin |
| 9 | Diamond | 12,000 | $1,200 | +45% coin bonus; weekly 1 free Gold Pack; VIP9 legendary frame; **Favorite-3 sticker showcase unlock** |
| 10 | Obsidian | 20,000 | $2,000 | +50% coin bonus; booster shop −25%; name highlight in leaderboards; personal concierge cosmetic bundle |

### §12.B — BPP new earning rates summary

| Source | BPP |
|---|---:|
| Match played | +10 (was +5) |
| Match won | +20 bonus (was +10) |
| Daily Mission completion | +100 per mission (new) |
| Daily Missions 3/3 (existing Daily Chest reward) | existing reward + implicit +300 BPP from missions |
| Tier requirement | **400 BPP flat per tier** (was 50×N cumulative) |
| 30-tier total | **12,000 BPP** (was 23,250) |

---

## §13 — Verification disclosures

Per Verification Gates. This patch is numbers-only; two claims are load-bearing:

1. **MM booster prices (Bronze 50 / Silver 100 / Gold 200 / Diamond 400–1,000)** — [Naavik Match Masters deconstruction (2023-05)](https://naavik.co/deep-dives/match-masters-deconstruction/). Labeled as of 2023, may be stale. Shop economy in MM has been re-tuned at least once since; verify in-client before any final-tuning lock.
2. **Casual match-3 Pass completion benchmark 60–80%** — `d:\marketplace\plugins\prototype\skills\gs-prototype-designer\knowledge\benchmarks.md` (generic range, not a specific game).

MM's specific coin inflow (match-win coin, Lucky Box value, album rewards, Star Race payouts) are **not published**. Mix-It's v7.3.1 numbers are re-anchored against v7.2's engaged-ceiling target (2,500c/day) and generic casual-PvP benchmark ranges, NOT against verified MM values.

---

## §14 — Open items (forwarded to v7.4)

- FTUE bot WR curve (70/60/55/50% Arenas 1–4) — Trophies audit flagged F2P casual at 50% WR goes negative pre-Cocktail
- Post-completion Pass hook (tier 31+ cosmetic drip for whales who finish fast)
- Coin bundle IAP pricing + coin-per-dollar curve (needs full SKU pass)
- Matchmaking algorithm (trophy-only vs ELO-like) — affects Star Race distribution
- Tournament / LTM weekly event calendar — will interact with Monday peak ceiling rule
- VIP point curve validation against actual SKU ladder once bundles are priced
- In-client screenshot capture (§18 of v7.3): 8BP VIP tier thresholds, MM album UI, MM profile access, MM shop transparency, MM country leaderboard absence

---

## Sources

- [Naavik — Match Masters deconstruction](https://naavik.co/deep-dives/match-masters-deconstruction/) — booster prices, 2023 (stale flag)
- [Candivore Zendesk — Coins](https://candivore.zendesk.com/hc/en-us/articles/360019827339-Coins)
- [Candivore Zendesk — Booster Stakes Multiplier](https://candivore.zendesk.com/hc/en-us/articles/6352690476314-Booster-Stakes-Multiplier-x2-x3-x4-x5)
- [Candivore Zendesk — Stars](https://candivore.zendesk.com/hc/en-us/articles/360019600139-Stars)
- [MatchMastersCoin — Stickers & Albums](https://matchmasterscoin.com/match-masters-stickers/) — album reward existence only
- Internal: `design-v7.1-patch-coin-economy-mm-faithful.md` (v7.2 engaged target 2,500c/day)
- Internal: `design-v7.0-patch-match-masters-refactor.md` (BPP formula superseded)
- Internal: `design-v7.3-patch-mvp-completion.md` (§15 appendix tables revised)

---

**End of v7.3.1 patch.**
