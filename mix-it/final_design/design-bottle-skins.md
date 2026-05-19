# Mix-It — Bottle Skins

A **soft-modifier cosmetic equipment system** layered onto the bar/café fantasy. The player owns and equips bottle skins; each grants a small passive modifier in addition to its visual identity. Designed against the **8 Ball Pool Cues** precedent for cosmetic-with-stats in 1v1 PvP F2P, **not** Match Masters (whose cosmetics are pure visual; their gameplay layer is Boosters, which we already have).

This system is a second monetization pillar alongside Bar Pass, deeply tied to **Venue** — our unique meta system. See [design-meta.md](design-meta.md) for the broader meta stack.

---

## 1. Commitments

1. **One skin equipped per match, applies to all 5 bottles.** Single equip slot on the Loadout screen alongside the 3 booster slots. No per-bottle skins.
2. **One soft modifier per skin.** Single modifier line — readable, auditable, not multi-stat-array like 8 Ball Pool Cues. Holds the math simple and lets us A/B individual modifier types.
3. **Strength capped at 10% delta on any single dimension.** Common 2-3% → Rare 5% → Epic 7-8% → Legendary 10%. The genre's "soft" band sits at 10-25% (Brawl Stars Gears); we run softer than the leader.
4. **Skins never touch core rules.** Glass capacity, serve trigger, walkaway penalty amount for opponent, match duration, base trophy/stake math — all off-limits. Modifiers operate on rates, durations, and percentages only.
5. **Legendary = paywall, Epic = grindable in a season, Rare = weekly, Common = constant.** Genre-standard acquisition cadence.
6. **Venue is the free path.** Each district has a signature 3-skin set unlocked through building upgrades. A fully-engaged free player who upgrades all four districts owns ~12 Rare-equivalent skins.

---

## 2. Modifier dimensions and rarity budget

Each skin carries **exactly one** modifier from this list:

| Modifier dimension | What it tweaks | Common | Rare | Epic | Legendary |
|---|---|---:|---:|---:|---:|
| **Spawn recharge speed** | Charge regen rate (base 1.0 s/charge) | −2% | −5% | −7% | −10% |
| **Spawn starting charges** | Charges at match start (base 5) | — | +1 | +1 | +2 |
| **Spawn max cap** | Max stored charges (base 12) | — | +1 | +1 | +2 |
| **Customer patience** | Patience on arrival (base 24 s) | +3% (~+0.7 s) | +5% (~+1.2 s) | +8% (~+1.9 s) | +10% (~+2.4 s) |
| **Combo bonus** | Bonus per combo step (base +50) | +2% | +5% | +7% | +10% |
| **Combo window** | Time between serves (base 10 s) | — | +0.5 s | +1.0 s | +1.5 s |
| **Walkaway mitigation (wearer only)** | Wearer's walkaway penalty (base −25) | −2% (−24.5) | −5% (−23.75) | −7% (−23.25) | −10% (−22.5) |
| **Coin payout** | Post-match coin bonus on win | +2% | +4% | +6% | +8% (held under 10% to protect economy) |
| **Star Race bonus** | Stars on win | — | flat +0 | +1 every 5 wins | +1 every 3 wins |

**Wearer-only rule:** modifiers affect only the equipped player. The opponent's walkaway penalty, opponent's patience, etc. are never touched by your skin. This prevents PtW critique tied to symmetric-affecting effects.

---

## 3. Rarity tiers

| Tier | Strength | Sources | Visual treatment |
|------|----------|---------|------------------|
| **Common** | 2-3% delta | Shop (rotating slot), Trophy Road early milestones, Bar Pass free tier 5 | Solid color recolor, simple silhouette |
| **Rare** | ~5% delta | Bar Pass free track, Star Race top 2-5, Big Pack lottery, **all Venue building-unlocked skins** | Metallic finish, accent details |
| **Epic** | 7-8% delta | Bar Pass premium track, Star Race top 1, Big Pack lottery (low), Trophy Road #22 | Animated material (subtle pour FX, glow on serve) |
| **Legendary** | ~10% delta | Bar Pass premium tier 30, IAP-only bundles, Big Pack ultra-rare | Full custom geometry, distinct silhouette, particle FX |

Maximum 4 tiers. No Diamond, no Special Edition — keeps the band tight and the Common-vs-Legendary delta within the audit window.

---

## 4. Acquisition paths

### Shop (coins)

| Rarity | Coin price | Rotation |
|--------|-----------:|----------|
| Common | 800 | Daily slot |
| Rare | 2,500 | Every 3 days |
| Epic | 8,000 | Weekly |
| Legendary | not sold for coins | — |

Owned skins are not re-offered; the shop never sells a duplicate.

### Pack Opener (probabilistic)

Big Pack adds an 12% chance that one of its slots resolves to a skin instead of a sticker:

| Pack | Skin slot chance | Skin rarity distribution if rolled |
|------|------------------|-------------------------------------|
| Small (3 slots) | 0% | — |
| Standard (5 slots) | 4% on one slot | 70 C / 25 R / 5 E / 0 L |
| Big (10 slots) | 12% on one slot | 50 C / 35 R / 13 E / 2 L |

A Big Pack yields Legendary at 12% × 2% = **0.24% per pack** — effectively a paywall for F2P (≈400 packs expected; an engaged F2P opens ~4 Big Packs per season ⇒ 99% probability of zero Legendaries over a season).

### Bar Pass tier rewards

| Tier | Free track | Premium track |
|------|-----------|---------------|
| 5    | Common skin | Common skin |
| 12   | — | Rare skin |
| 18   | Rare skin | Epic skin |
| 25   | — | Epic skin |
| 30   | — | **Legendary skin** (premium-only) |

Free-track skins per season: 2 (1 Common, 1 Rare). Premium-track total: 1 Common + 1 Rare + 2 Epic + 1 Legendary.

### Star Race weekly leaderboard

| Position | Skin grant |
|----------|------------|
| Top 1 | 40% chance Epic skin (else gold cosmetic frame) |
| Top 2-5 | 25% chance Rare skin (else silver cosmetic) |
| Top 6+ | No skin (existing cosmetic frames only) |

No Legendaries from Star Race — Legendary remains gated to Bar Pass premium + IAP.

### Trophy Road grants

Skin grants insert into the existing 26-milestone Trophy Road as **between** milestones:

| Milestone | Trophies | Rarity |
|-----------|---------:|--------|
| #4 (replacement) | 175 | Common |
| #12 (replacement) | 975 | Rare |
| #22 (replacement) | 2,850 | Epic |

(The replaced milestones' coin/cosmetic rewards bundle with the skin grant rather than disappear — see [design-progression.md §5](design-progression.md) for adjustment.)

### Venue building upgrades — the free path

Each district has a 3-skin signature set, each unlocked at **building level 3** of a specific anchor building. All Venue skins are **Rare-equivalent strength** (5-7% delta).

| District | Anchor buildings | Signature skins | Modifier dimension family |
|----------|------------------|------------------|---------------------------|
| **Cafe Row** | Juice Stand / Lemonade Stand / Smoothie Bar | Sunny Tumbler / Striped Highball / Frosted Mason | **Spawn** (−6% recharge / +1 start / +1 cap) |
| **Boulevard** | Coffee House / Tea Garden / Cocktail Lounge | Espresso Demi / Teahouse Cup / Coupe Glass | **Customer / patience** (+1.5 s first-customer / +1 s grace / −7% walkaway) |
| **Uptown** | Tiki Bar / Wine Cellar / Whiskey Den | Tiki Mug / Crystal Goblet / Cut Tumbler | **Scoring** (+6% combo bonus / +5% speed bonus / +1 s combo window) |
| **Penthouse** | Champagne Room / Penthouse Bar / Grand Hotel | Coupe Tower / Skyline Flute / Grand Crystal | **Economy** (+8% coin payout / +3% trophy / +1 BPP per match) |

Twelve free Rare-equivalent skins across the full Venue progression — the F2P "competitive baseline" floor.

### IAP direct

| Bundle | Price | Contents |
|--------|------:|----------|
| Single Legendary | $9.99 | 1 chosen Legendary + 500 coins |
| Skin Trio | $19.99 | 1 Legendary + 2 Epic + 1,500 coins |
| Season Skin Vault | $29.99 | 4 Epic + 1 Legendary + Bar Pass premium upgrade |

---

## 5. Economy: currency flow

No new top-level currency. Skins use existing coins + a lightweight sub-currency for duplicate protection.

| Source | Currency in | Sink |
|--------|-------------|------|
| Match wins | Coins | Skin shop purchase |
| Trophy Road / Bar Pass / Star Race | Direct skin grant | — |
| Big Pack open | Skin (lottery slot) | — |
| Duplicate skin pulled | **Skin Shards** (new sub-currency, same pattern as Sticker Tokens / Venue Sticker Shards) | Direct skin claim at thresholds |
| IAP | Skin directly | — |

### Duplicate handling

Two paths depending on skin source:

- **Venue skins** (rank-up via building level). Each subsequent building level past 3 grants +1 skin XP to that skin. Skins have 5 ranks (I → V). Ranks scale the modifier within the cap (e.g. spawn recharge −4% → −5% → −6% → −7% → −8%). Building levels are the only XP source for Venue skins.
- **Shop / Pack / IAP / Bar Pass / Star Race / Trophy Road skins** (shards). Duplicate pulled = converts to Skin Shards automatically.

| Dupe rarity | Shards granted | Threshold to claim of same rarity |
|-------------|---------------:|------------------------------------:|
| Common | 5 | 20 (claim Common) |
| Rare | 15 | 60 (claim Rare) |
| Epic | 40 | 150 (claim Epic) |
| Legendary | 100 | 400 (claim Legendary) |

Shard spend at a **Skin Forge** sub-screen — player picks a specific target skin from the catalog; if shard threshold met, claim. Bad-luck protection valve parallel to Sticker Tokens.

A whale pulling ~50+ packs/season can craft 1 Legendary per ~4 seasons through shards alone — keeps Legendary aspirational even for heavy spenders, protecting the IAP price ladder.

---

## 6. F2P pacing

Median engaged F2P at Coffee House (5 matches/day, ~50% WR, ~138 coins/day net before sinks, ~190 coins/day available for skins after booster spend):

| Acquisition | Source | Time to first |
|---|---|---|
| First Common | Trophy Road milestone #4 (175 trophies) | Day 3-5 |
| First Rare | Bar Pass free tier 18 OR shop @ 2,500 c | Day 13 |
| First Epic | Shop @ 8,000 c OR Trophy Road #22 (2,850 trophies) | ~6 weeks (shop) / ~7-9 weeks (Trophy Road) |
| First Legendary | Big Pack lottery only at 0.24%/pack | Effectively unreachable F2P (paywall) |

A free player who climbs the ladder reasonably and engages with Venue building upgrades fills out **12 Venue Rare skins by mid-to-late game**, plus 2 Bar Pass free skins per season, plus Trophy Road grants. That's a strong floor without ever spending.

---

## 7. PvP fairness model and hard caps

### Mode-by-mode

| Mode | Skins active? | Notes |
|---|---|---|
| ×1 stake | Full strength | Default casual play |
| ×2 stake | Full strength | Standard competitive |
| ×3 stake | Full strength | Skins are part of the meta investment loop |
| ×4 stake | **Capped to Rare-tier delta** | Epic/Legendary skin modifiers down-scaled to the Rare cap. Preserves variance at top stakes without P2W ceiling |
| Ranked tournament (post-MVP) | **Off — Basic Glass forced** | Pure-skill mode. Marketed as the integrity surface |
| FTUE M1-M4 | Off | Skin slot not yet introduced |
| Recovery pool | Active normally | Recovery pool only alters opponent selection, not modifiers |

### Hard caps (applied after summing all sources — skin + booster + future systems)

| Dimension | Cap | Reasoning |
|---|---|---|
| Spawn recharge time | floor **0.70 s** (base 1.00 s) | Hard limit on spawn density |
| Spawn starting charges | ceiling **8** (base 5) | Opening burst limit |
| Spawn max charges | ceiling **14** (base 12) | Late-game economy limit |
| Customer patience (first customer) | ceiling **+12 s** (base 24 s) | Even Mise en Place + Boulevard skin stack within this |
| Customer grace window | ceiling **3.5 s** (base 2 s) | Multi-source grace stack |
| Walkaway penalty reduction | floor **−15 points** (base −25, never zero) | Penalty must always sting |
| Combo window | ceiling **12 s** (base 10 s) | Two-source stack ceiling |
| Combo bonus multiplier | ceiling **+15%** | Additive cap across all sources |
| Speed-bonus value | ceiling **+15%** | Additive cap |
| Coin payout multiplier (skin only) | ceiling **+10%** | Applied after stake & On Fire |
| Trophy payout multiplier (skin only) | ceiling **+5%** | Applied after stake & On Fire |

Stack ceilings are enforced as a **final clamp** after all sources have contributed.

### Worst-case PtW math

A maximally-stacked paid player vs maximally-stacked F2P, same arena:

- **Paid:** Legendary skin equipped (+10% spawn recharge), with best booster loadout
- **F2P:** Best Venue Rare skin equipped (+5% spawn recharge), with same booster loadout
- **Net paid advantage:** 5 percentage points on one dimension, plus 0% on every other

That sits inside the soft-modifier safe zone (≤10% absolute, ≤5% delta vs free track). Bot tuning (3% mistake rate, 50% target WR) easily absorbs a 5% nudge without skewing matchmaking target WR by more than ~1-2 percentage points.

---

## 8. System mechanics & integration

### Loadout screen

A new **4th slot** is added to the existing Loadout panel, **left of** the three booster slots, in a distinct "Bottle" silhouette (~1.3× the booster icon — skin is identity, boosters are tools).

```
[Bottle Skin] [Bronze Booster] [Silver Booster] [Gold Booster]
```

- Tap → opens skin picker (owned skins grouped by rarity, modifier text under each)
- Equip locks at the 3-s match countdown (same window as boosters)
- Default skin: **Basic Glass** — granted at account creation, cannot be sold/destroyed, no modifier. The fallback ensures the slot is never empty and provides a baseline for ranked play.

### Modifier application

| When | What |
|------|------|
| Pre-match (loadout) | Modifier text visible on slot ("Spawn Recharge −8%") |
| 3 s countdown | Modifier baked into match config (deterministic, like boosters) |
| Match start | Passive in effect; no per-action visual on the modifier |
| In-match HUD | Small skin icon (24 px) next to the player's score plate. Long-press shows modifier text (curious players). No floating numeric callouts — soft modifiers are felt, not announced |
| Result screen | Skin contribution shown only when measurable: "🍾 Tip Jar: +12 bonus coins" |

### Opponent visibility

- Visual: **yes** — opponent sees your skin applied to your 5 bottle sprites the whole match. The cosmetic value lands.
- Numeric: **no** — opponent does not see your modifier text. Keeps PvP info-clean; opponent doesn't play around your buff.

### Interaction with boosters

- **Default: stack additively.** Customer Lock (8 s freeze) + Boulevard skin (+1 s grace) on the same customer = 9 s of denied walkaway plus an extended grace on serve. Hard caps absorb worst stacks.
- **No forbidden combinations.** Hard caps make explicit blacklists unnecessary.
- **Voids:** the only explicit void in MVP — if a future "first serve = guaranteed combo step 3" skin ships alongside Combo Primer (Bronze), the higher of the two suppresses the other (logged silently, no UI warning).

### Inventory

- **No hard cap.** ~60 skins ship at launch (12 Venue free + 48 shop/pack/IAP); even whales own well under 100.
- **Permanent ownership.** Skins are never lost to gameplay or season rotation. Once granted, always owned (server-side persistence, same model as boosters).
- **Season-exclusive flag.** Bar Pass premium signature skin and Star Race weekly winner skin are flagged `seasonal=true`. Owned forever; not re-obtainable after the season closes. FOMO without punishing latecomers (next season grants its own).

---

## 9. FTUE integration

The bottle skin system is introduced **after** the FTUE proper, in two staged beats:

| Beat | Trigger | What player sees |
|------|---------|------------------|
| Slot visible, locked | First post-FTUE match | Empty Bottle Skin slot with a small lock icon on the Loadout screen. Hint: "Unlock at Arena 2." |
| Slot unlocked + starter granted | Promotion to Arena 2 (Lemonade Stand) | Promotion popup: *"Your first bottle skin! 🍾 Sunny Tumbler equipped."* Skin picker opens once automatically; then becomes a regular Loadout option |

Starter skin: **Sunny Tumbler** (Cafe Row Rare, spawn recharge −4% / Rank I). Mirrors the booster starter pair pattern. Player now has: skin slot taught, Cafe Row hinted ("upgrade Juice Stand to unlock more like this"), Venue hook planted.

The FTUE matches themselves (M1-M4) **do not introduce the skin system** — they focus on pour mechanics, spawn, walkaway, and the bot opponent. Skin is the first **post-FTUE** progression beat alongside Stakes (Arena 8) and Star Race (weekly cadence).

---

## 10. Where this sits in the meta stack

In the broader meta context ([design-meta.md](design-meta.md)):

- **Bar Pass** is the seasonal pacing — skins are placed at specific tiers as reward beats
- **Venue** is the F2P skin path — all Venue-unlocked skins are Rare-equivalent
- **Pack Opener** is the lottery path — Big Packs roll for skins, dupes feed Skin Shards
- **Star Race** is the weekly competitive path — top placements roll for skins
- **Trophy Road** is the long-arc identity path — 3 between-milestones replaced with skin grants
- **IAP** is the direct paywall path — Legendary bundles, season vaults

Skins are a **second monetization pillar** under Bar Pass. They:
1. Give players an expression layer their meta investment is visible in (your bottles on screen the whole match)
2. Give Venue a gameplay-affecting payoff beyond visual progress
3. Provide a duplicate-protection valve (Skin Shards) that creates a long-tail F2P claim path

Without skins, the only equipped pre-match expression is the booster loadout, and Venue is purely cosmetic. With skins, both gain a structural payoff that compounds the value of every other meta layer.

---

## 11. Open questions for future passes

1. **Rank cap on shop/pack skins.** Venue skins rank via building levels (I → V). Non-Venue skins use Skin Shards to claim duplicates. Should non-Venue skins also have a rank system (separate XP track via match use), or do they stay flat? **Recommendation:** flat in MVP, rank-up in Season 2 if engagement warrants. Decide before Season 2 content commits so we don't paint into a corner.
2. **Bottle Skin Shard sink at full inventory.** Once a player owns all skins of a given rarity, what do additional shards do? **Recommendation:** convert to coins at a 1:1 rate (Common shard = 1 coin, Rare = 5, Epic = 15, Legendary = 30) once all skins of that rarity are owned. Same pattern as Pokémon dust overflow.
3. **Premium IAP skins exclusivity.** Are IAP-only skins fully exclusive (never appear in packs/Bar Pass), or do they rotate into Bar Pass after 2 seasons? **Recommendation:** rotate after 2 seasons for catalog longevity; flag exclusive in inventory and add a small "former IAP" indicator on the icon.
4. **Stake-locked seasonal modifier.** The ×4 stake cap (Epic/Legendary → Rare-strength) is the simplest fairness lever. Test whether ×4 players notice the down-scale or whether it kills the prestige feeling. If the latter, alternative: keep modifier full but **double the Star Race bucket** for ×4 players (high-stakes glory compensates).
5. **Visual budget per skin tier.** Common = recolor, Legendary = full custom geometry + particle FX. The art-pipeline cost ramps fast. Confirm with art team whether 4 Legendaries per season is achievable.
