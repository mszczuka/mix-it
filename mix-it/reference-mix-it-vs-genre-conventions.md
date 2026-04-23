# Mix-It v7 vs. Casual PvP Arena Genre — Point-by-Point Review

**Baseline:** Mix-It `design-v6.md` + v7.0 Match Masters refactor + v7.1 coin-economy + v7.2 MM-fidelity patches.
**Reference:** `reference-casual-pvp-arena-genre.md` (this folder).
**Date:** 2026-04-22.

**Legend:**
- ✅ **Match** — Mix-It follows the convention.
- 🟡 **Hybrid / Modified** — Mix-It deviates, but in a known/acceptable way that other titles in the genre also do.
- 🔶 **Intentional Divergence** — Mix-It departs from convention on purpose; flagged risk.
- ❌ **Gap** — Convention absent; worth reviewing.
- ⏸ **Deferred** — In scope but post-MVP.

---

## TL;DR — verified edition

**Verification pass 2026-04-22.** Each row has been checked against web sources. Genre-status labels reflect what's actually confirmed across the 8 reference titles. Labels:

- **[defining]** = confirmed in 6+/8 titles via primary or trade-press sources
- **[common]** = confirmed in 3–5 titles
- **[variation]** = confirmed in 1–2 titles; often an MM or TSG signature, not genre-wide
- **[unverified]** = commonly claimed but no primary-source citations surfaced; **do not treat as genre-standard**

**Scope notes:** Stumble Guys (32-player BR) and Archero 2 PvP (async side-mode in a roguelike) are **structural outliers**. They're only valid references for the meta/monetization layer (pass, ads, crews, IP crossovers), not for core-match-structure conventions.

| # | Convention | Confirmed in | Genre-status | Mix-It v7.2 | Status |
|---:|---|---|---|---|---|
| 1 | Real-time sync 1v1 match | MM, Golf Clash, Bowling Crew, Mini Golf King, Trophy Hunter, 8BP | [defining] | Parallel boards, shared queue, AI opponent | 🟡 |
| 2 | Turn-based within real-time framing | MM, 8BP, Golf Clash, Bowling Crew, Mini Golf King, Trophy Hunter | [defining] | Parallel simultaneous — not turn-based | 🟡 |
| 3 | 2–5 min match length | Bowling Crew ("<3 min"), Mini Golf King ("1–2 min") | [common] | Implied, not explicit | 🟡 |
| 4 | Skill + noise mix | Golf Clash (wind), MM (booster RNG), 8BP (cue stats) | [common] | Pour-sort + Color Spawn RNG | ✅ |
| 5 | Coin/soft-currency ante per match | MM, 8BP, Golf Clash | [defining] | **None** — free to enter | 🔶 |
| 6 | Trophy/ELO ladder | MM, Golf Clash, Trophy Hunter | [defining] | Trophy Road 0→4000 | ✅ |
| 7 | Arena/Tour/Alley tiers | MM, Golf Clash, Bowling Crew | [defining] | 6 arenas, clean gates | ✅ |
| 8 | Per-tier content pools | Golf Clash, Bowling Crew | [common] | Boosters unlock per arena | ✅ |
| 9 | Trophy cap per tier (asymmetric) | — (no primary cite surfaced) | [unverified] | Not implemented | 🟡 (drop claim) |
| 10 | Auto-tier (no selector) | — (no primary cite surfaced) | [unverified] | Selector removed in v7.2 | 🟡 (drop claim) |
| 11 | Visible opponent stake pre-match | MM, 8BP | [common] | Pill shown at ≥2 stakes | ✅ |
| 12 | Booster Stakes Multiplier | MM | [variation — MM signature] | ×2/×3/×4 Gold-only | ✅ (MM-faithful copy) |
| 13 | Card-shard equipment upgrade | Golf Clash, 8BP, Bowling Crew | [common] | **None** — flat-power boosters | 🔶 (MM-faithful) |
| 14 | 3–4 rarity bands | Golf Clash, MM | [common] | 3 booster + 4 sticker rarities | ✅ |
| 15 | Chest drop w/ real-time timers | Golf Clash | [variation] | No chest slots; Star Meter + Lucky Box | 🔶 (MM-faithful) |
| 16 | Pay-to-skip chest timers | Golf Clash | [variation] | Coin-skip Star Chest | 🟡 |
| 17 | Single soft currency only | MM | [variation — MM exception] | Coins only | ✅ (MM-faithful) |
| 18 | Hard currency (gems/cash) | 8BP (Pool Cash), Golf Clash (Gems), Stumble Guys (Gems) | [defining — MM is the exception] | **None** | 🔶 (MM-aligned; gap vs others) |
| 19 | No stamina/energy | MM, 8BP, Golf Clash | [defining] | None | ✅ |
| 20 | Sticker/card album collection | MM | [variation — MM signature] | 3 Regular + 1 Seasonal | ✅ |
| 21 | Cosmetic-only content | Stumble Guys; MM stickers arguably | [variation] | Trophy Road cosmetics + Venue | ✅ |
| 22 | Weekly league + reset | Golf Clash | [common, thin cites] | Missing | ❌ |
| 23 | Trophy Road / season milestones | — (no primary cite surfaced) | [unverified] | Trophy Road 20 milestones | 🟡 (claim is fine; just un-cited) |
| 24 | First-IAP starter pack ($1–5) | — (no per-game "first-purchase-specific" cite) | [unverified] | $2.99, 48h | ✅ (shipped pattern) |
| 25 | Seasonal Battle Pass (28–42d) | Stumble Guys ($5.99 Stumble Pass) | [common, genre-default] | Bar Pass 30d $9.99 | ✅ |
| 26 | Rewarded-video ads | MM, Trophy Hunter, Stumble Guys | [defining] | Missing | ❌ |
| 27 | VIP / loyalty points ladder | — (no primary cite surfaced) | [unverified] | Missing | 🟡 (drop claim as "genre standard") |
| 28 | Clubs/Crews/Teams | MM, Golf Clash, Trophy Hunter | [common] | Deferred | ⏸ |
| 29 | Canned chat / predefined emotes | 8BP | [variation, thin cites] | Not implemented | 🟡 |
| 30 | Friend challenges / friendlies | — (no primary cite surfaced) | [unverified] | Deferred | ⏸ |
| 31 | Leaderboards (country/world/club) | Trophy Hunter (league) | [variation, thin cites] | Not implemented | ❌ / ⏸ |
| 32 | Gifting between players | MM | [variation] | Deferred (needs teams) | ⏸ |
| 33 | Daily login calendar | — (no primary cite surfaced) | [unverified] | Fused into Lucky Box + missions | 🟡 (drop claim) |
| 34 | Daily missions (3/day) | MM | [variation, thin cites] | 3/day rotating | ✅ |
| 35 | Named AI bot personas | — (no primary cite; community-reported) | [unverified] | 12/arena personas | 🟡 (drop claim as "standard") |
| 36 | LTM tournaments w/ entry fees | Golf Clash, Bowling Crew | [common] | Deferred | ⏸ |
| 37 | Limited-time game modes | MM, Stumble Guys | [common] | Deferred | ⏸ |
| 38 | Licensed / IP crossovers | Stumble Guys | [variation — SG signature] | Not planned | ⏸ |
| 39 | Base/hub meta (Lodge/Hub/Venue) | Trophy Hunter, MM | [variation] | Venue (29 buildings) | ✅ |
| 40 | Score-margin star rating | — (no primary cite surfaced) | [unverified] | v7.2 ratio ≥ 0.35 | 🟡 (drop claim; keep mechanic) |
| 41 | Win-streak / "On Fire" multiplier | MM (primary), 8BP (secondary) | [variation — MM signature] | On Fire ×2 | ✅ |
| 42 | Progression front-loaded | — (no primary cite surfaced) | [unverified] | Fast arena unlocks | 🟡 (drop claim) |
| 43 | $ Bundle SKUs ($1–20) | — (inferred from 8BP Codashop) | [common, thin cites] | 3 tiers $1.99/$4.99/$19.99 | ✅ |
| 44 | Whale SKU ($49.99+) | — (no primary cite) | [unverified] | Top SKU $19.99 | 🟡 |
| 45 | Flash offers (behavioural) | — (no primary cite; industry norm) | [unverified] | 4 triggers | ✅ |
| 46 | Direct-buy rare $ items | — | [unverified] | Token-only | 🟡 |
| 47 | Side currencies (meta tokens) | MM (event tokens, matchinko), Trophy Hunter (lodge) | [common] | Venue Tokens + Sticker Tokens | ✅ |
| 48 | Themed seasonal content | Stumble Guys (Nightland etc.), MM (game modes) | [common] | Seasonal Album rotation | ✅ |
| 49 | Session length 5–15 min | — (inferred from match length) | [unverified] | Implied | 🟡 |
| 50 | Dual-gate session stop-out | — (genre analysis, not primary) | [unverified] | Weak — no ante, no chest slots | 🔶 |
| 51 | Tutorial forced-win vs bot | — | [unverified] | Not explicit | 🟡 |
| 52 | Early win-rate 60–70% | — | [unverified] | Not explicit | 🟡 |

**Revised status totals:** 21 ✅ / 20 🟡 / 5 🔶 / 2 ❌ / 4 ⏸

Net movement vs. prior pass: many ✅/❌ moved to 🟡 once the "genre-defining" claim itself turned out to be unverified. Mix-It doesn't lose anything by not shipping an unverified-as-genre feature.

### Top risk flags (only from *verified* genre claims)

1. ❌ **No rewarded-video ads** — primary-confirmed in 3/8 titles (MM, Trophy Hunter, Stumble Guys). Cheap add; ship before launch.
2. ❌ **No weekly league** — confirmed in Golf Clash. Thin cites elsewhere but likely common. Consider lightweight weekly leaderboard.
3. ⏸ **No clubs/chat** — confirmed in 3/8 (MM, Golf Clash, Trophy Hunter). Expected deferred; plan post-MVP.
4. 🔶 **No coin ante** — confirmed in 3/8 (MM, 8BP, Golf Clash). Mix-It follows MM specifically, which ships with no-ante; acceptable trade-off.
5. 🔶 **No hard currency** — 7/8 ship one; MM is the exception. Mix-It follows MM. Monetization ceiling risk, but design-aligned.
6. 🔶 **Weak session stop-out** — no chest slots + no ante = no natural friction. Industry-analysis claim, not primary-sourced. Playtest signal.

### Claims I should NOT make about this genre until re-verified

- "Every casual PvP arena has a VIP ladder" — not sourced.
- "Trophy cap per tier is genre-standard" — not sourced in this pass.
- "Auto-tier is MM-specific and unique" — I don't have a primary cite confirming which titles use player-selectable tiers vs. auto-tier.
- "Named AI bots are a convention" — widely claimed in fan forums, not primary-sourced.
- "Daily login calendar is universal" — not sourced.
- "Score-margin star rating is a convention" — only MM confirmed (via Naavik); unknown for others.
- "Progression is always front-loaded in first hour" — design-community claim, not sourced.

### Corrections to flag in the prior doc

- **MM "Cash" hard-currency claim** — wrong, already corrected. MM is Coins-only.
- **Stumble Guys used as a core-arena reference** — category error. Only valid for meta/monetization layer (rows 25, 26, 28, 37, 38).
- **Archero 2 PvP used as anything more than "async best-of-3 structure"** — it's a side-mode in a roguelike, not a core arena title.
- **"Booster Stakes Multiplier" framed as genre-standard** — it's an MM signature. Mix-It copies MM specifically.
- **"Single soft currency" framed as a Mix-It divergence** — it's actually MM-faithful. Other titles are the ones diverging from MM.

---

## 1. Core match structure

| Convention | Mix-It v7.2 state | Status | Notes on modification / hybrid |
|---|---|---|---|
| Real-time 1v1 synchronous match | Parallel boards, shared customer queue, real-time race. No actual multiplayer — AI opponent with named personas. | 🟡 | Single-player simulation of 1v1 is standard genre practice for prototypes (8BP, Golf Clash all started with bot-heavy matchmaking). Acceptable for POC; flag for production scale. |
| Turn-based within real-time framing | Both players pour and serve in parallel; Color Spawn recharges on timer. Not strictly turn-based — closer to simultaneous real-time. | 🟡 | Bowling Crew is simultaneous-turn; Match Masters is turn-based. Mix-It's parallel-board real-time is a valid in-genre variation, closer to Bowling Crew's simultaneous model. |
| Short match length (2–5 min) | Match length set by timer (v6 §5; per-match timer ~0:27-range in HUD sample). Not explicitly stated but within range. | ✅ | Should be explicit in docs if not already. |
| Skill + noise mix | Water-sort routing (skill) + Color Spawn RNG + customer queue RNG. | ✅ | Direct MM analog: match-3 skill + board-gen noise. |
| 1v1 structure (not FFA/BR) | 1v1. | ✅ | |

---

## 2. Matchmaking & stakes

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Coin ante per match | **Removed in v7.1** — matches are free to enter. Only risk is staked boosters. | 🔶 | **Intentional MM-faithful divergence.** MM has no per-match coin entry on 1v1 matchmade games (v7.2 §22 flags this as unverified-pending-primary-source). Genre-wise, 8BP/Golf Clash/Bowling Crew **do** charge ante — MM and Mix-It are the outliers. Risk: loses a monetization lever; gains a "never broke" UX. |
| Trophy/ELO ladder | Trophies from win/loss; Trophy Road 20 milestones 0→4000. | ✅ | Direct match. |
| Arena/Tier tiers with trophy gates | 6 arenas: Juice Stand (0) → Beach Bar (200) → Cocktail Lounge (500) → Speakeasy (1000) → Rooftop (2000) → Grand Hotel (3500). | ✅ | Clean 6-tier ladder. |
| Per-tier content pools | Boosters unlock per arena (Bronze at Juice Stand, Silver at Beach Bar, Gold at Cocktail Lounge, etc.). | ✅ | Direct genre pattern. |
| Trophy cap per tier (asymmetric) | **Not implemented.** Trophies monotonic; no per-arena cap. | ❌ / 🟡 | Golf Clash + Bowling Crew use this to force backtracking. MM does **not** (it auto-tiers cleanly). Since v7.2 adopted MM's auto-tier, absence of cap is consistent with MM — acceptable omission. |
| Auto-tier (no selector) | **v7.2 deleted the Arena Selector.** Player is auto-placed by current trophy count. | ✅ | MM-faithful; correct. |
| Bot-fills for matchmaking | Named AI personas (~12/arena) + Rematch. Entire "PvP" is AI in MVP. | 🟡 | Prototype standard. Production would introduce real MM on top. |
| Wager / stake mechanic | **Booster Stakes Multiplier (×2 / ×3 / ×4).** Gold-only stakes, 0–4 slots, multiplier shown at ≥2. MM-faithful. | ✅ | Direct MM copy (v7.2 §4). ×5 deferred to future. |
| Visible opponent stake pre-match | Opponent card shows stake count pill at ≥2 stakes. | ✅ | |

---

## 3. Progression meta

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Trophy-gated content unlock | Trophy Road consolidates arena promos, booster grants, cosmetics, sticker drops. | ✅ | |
| Chest drop from victories | **Not direct.** No per-win chest slot with real-time timer. Replaced by **Star Meter** (25 stars → Star Chest) + Lucky Box (4h timer) + Daily Chest (missions) + chests from Trophy Road. | 🔶 | **Major divergence.** Classic genre (Clash Royale / Golf Clash / 8BP) ships a 3–4-chest-slot system with timers. Mix-It replaced this with MM's Star Meter. MM does this successfully — so it's a valid in-genre hybrid, but note: Mix-It loses "chest slot saturation" as a session stop-out gate. |
| Pay-to-skip chest timers | **Star Chest shortcut** in Shop B priced in Coins (not gems). Lucky Box not skip-able. | 🟡 | Replaces the classic gem-skip sink with a coin-skip sink, because Mix-It has no gem currency at all. See §5. |
| Weekly / seasonal league | **Not implemented.** No weekly league ladder with reset + rewards. | ❌ / ⏸ | Weekly league is genre-defining across 8BP/Bowling Crew/Golf Clash. Mix-It relies on Bar Pass (30-day) for seasonal rhythm, but lacks a weekly ladder competition layer. Consider adding. |
| Seasonal reset | Bar Pass runs 30 days with seasonal album archival on rotation; no trophy reset. | 🟡 | Trophy-reset convention varies across genre; MM does soft-reset. Bar Pass cadence is standard. |

---

## 4. Content system

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Collectible equipment with card-shard upgrades | **Not implemented.** Boosters have **flat power per tier** — no card-upgrade-powers-booster system (explicit MVP cut, v7.0 §17.2). Upgrades come from inventory count, not card levels. | 🔶 | **Major divergence** from 8BP/Golf Clash/Bowling Crew. MM matches Mix-It (boosters are flat-power consumables in MM too). Gains: simpler balance, no power-creep grind. Loses: collection-driven upgrade dopamine. |
| Rarity tiers (3–4 bands) | 3 booster rarities (Bronze/Silver/Gold) + future Diamond. 4 sticker rarities (White/Silver/Gold/Diamond, 60/28/10/2). | ✅ | Matches MM exactly. |
| Boosters-as-content (MM variation) | Staking on boosters, 9-booster roster across 3 tiers. Staked Gold consumed on loss. | ✅ | Direct MM copy. |
| Primary collection system | **Stickers** — 3 Regular Albums (20 stickers each) + 1 Seasonal Album (20). Sticker Tokens to force-unlock missing. | ✅ | MM-faithful (MM has 5 album types; Mix-It ships 2 with 3 reserved). |
| Cosmetic content | Trophy Road cosmetics (avatars, frames, titles) + Bar Pass Premium exclusives + $ bundle exclusives. Venue buildings also cosmetic-flex. | ✅ | Strong cosmetic ladder; aligns with 8BP/Stumble Guys model. |

---

## 5. Economy & currencies

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Single soft currency (coins) | **Coins only** (Gold currency removed in v7.1). Stars are an accumulator, not a spendable wallet. | ✅ | MM-faithful. |
| Soft currency = ante | **No ante in Mix-It.** Coins spent on booster shop, sticker packs, chest shortcut. | 🔶 | See §2 — MM-faithful no-ante divergence from broader genre. |
| Hard currency (gems) | **Not implemented.** No gem/hard-currency layer. Only Coins + $ IAP direct. | 🔶 | **MM-faithful.** 8BP/Golf Clash/Bowling Crew/Mini Golf King all have dual-currency (soft + gem). **MM itself is single-currency (Coins only)** — [Candivore Zendesk — Coins](https://candivore.zendesk.com/hc/en-us/articles/360019827339-Coins). "Diamond" in MM is a booster rarity tier, not a wallet. Mix-It's single-currency model mirrors MM correctly. Trade-off: lower monetization ceiling than Clash-lineage titles, in exchange for cleaner UX and MM fidelity. Accepted. |
| No stamina / energy | No energy system. Practice Mode removed (v7.1). | ✅ | Matches MM + broader genre. |
| Chest timer system | **Only the 4h Lucky Box timer.** No 3/8/24h chest-slot tiered timers. | 🔶 | See §3. Lucky Box pulls the "come back in 4h" hook, but without tiered slot saturation. Acceptable MM-style, but less timer-hook density than Clash-style competitors. |
| Booster-as-consumable-currency | Gold boosters function as stake fuel; lost on stake-loss; repurchasable from Coin shop. | ✅ | Direct MM pattern. |
| Side currencies | **Venue Tokens** (played-not-paid, building upgrades), **Sticker Tokens** (force-unlock). Each has clean sink. | ✅ | Trophy Hunter's Lodge-token model — solid meta currency pattern. |

---

## 6. Monetization patterns

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| First-purchase starter pack ($0.99–$4.99) | Starter Pack at $2.99, 48h window, one-time. 2,000 Coins + 10 boosters + 5 stickers + Token + Founder's Frame + Beach Bar Star Chest. | ✅ | Sized correctly. |
| Seasonal Battle Pass | **Bar Pass** — 30 tiers, Free + Premium ($9.99), 30-day season. Match-only BPP. | ✅ | Pricing at upper end of $5–15 range; season cadence correct. |
| Chest/gacha = card randomisation | Star Chest + Lucky Box + Sticker Packs = sticker RNG. No card gacha (no cards in design). | 🟡 | Collection gacha lives in sticker packs; monetization shape correct. Absence of power-card gacha is consequence of §4 divergence. |
| VIP / club loyalty points | **Not implemented.** No VIP ladder. | ❌ | 8BP VIP is a significant whale-retention lever. Consider post-MVP. |
| Rewarded video ads | Not in current spec (v7 docs don't mention rewarded-video ads). | ❌ / ⏸ | Trophy Hunter + Bowling Crew confirm this is expected. Low-hanging add for pre-launch. |
| Direct-buy rare items | Diamond stickers via Sticker Tokens (earn-only). No $ direct-buy for specific Gold boosters / rare stickers. | 🟡 | 8BP Legendary cue events offer $-priced specific rares. Mix-It could add this to Flash Offers. |
| Chat packs / micro-IAP cosmetics | **Not implemented.** No chat system → no chat packs. | ❌ | Consequence of missing chat — see §7. |
| $ Bundle SKUs | 3 tiered bundles at $1.99 / $4.99 / $19.99 (Bartender's Starter / Weekend Warrior / Grand Stock). | ✅ | Standard shape. |
| Flash offers (loss-trigger, promo-trigger, low-currency, collection-frustration) | 4 triggers: 3-loss streak, arena promo, low-coins after Daily Chest, 3rd sticker pack without Gold pull. Prices $0.99–$2.99. | ✅ | Well-structured; covers standard genre triggers. |
| IAP range $0.99–$99.99 | Top bundle is $19.99. No $49.99 / $99.99 whale SKU. | 🟡 | Prototype scope — production would add whale SKUs. Flag. |

---

## 7. Social & retention

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Clubs / Crews / Teams | **Not in MVP.** Explicitly deferred (v7.0 §17.2 + §11.2). | ⏸ | Expected post-MVP. Sticker trading + team albums + team gifts reserved slots. |
| Predefined chat / canned emotes | **Not implemented.** | ❌ / ⏸ | Genre-defining for 8BP/MM/Bowling Crew. Absence OK in single-player prototype, critical for real PvP. |
| Friend challenges / friendlies | **Not in MVP.** Rematch button vs. persona is closest analog. | ⏸ | |
| Leaderboards | **Not implemented.** Trophy number visible but no country/world/club ladders. Star Race deferred (v7.0 §17.2). | ❌ / ⏸ | Genre-defining but deferred. Consider lightweight fake-leaderboard for prototype flavor. |
| Gifting | **Not in MVP** (teams deferred). | ⏸ | |
| Daily login | **No explicit daily login calendar.** Lucky Box 4h + Daily Missions serve similar role. | 🟡 | Acceptable substitute. Many genre titles run a daily login on top of daily missions; Mix-It fuses them. |
| Sticker collection | 3 Regular + 1 Seasonal album, 80 total MVP stickers. | ✅ | Strong — MM-faithful. Trading reserved for teams. |
| Replays / spectate / party hub | **Not implemented.** | ⏸ | Stumble Guys feature; not a casual-PvP-arena must-have. |

---

## 8. Session design

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Target session 5–15 min | Not explicitly set in docs. Implied by 2–5 min match × 2–4 matches. | 🟡 | Make explicit in design doc. |
| Matches per session 2–4 | v7.2 §12.3 pacing assumes 8–12 matches/day engaged → 2–4 sessions × 3 matches. | ✅ | Consistent with genre. |
| Dual-gate stop-out (chest saturation + ante exhaustion) | **Neither gate exists.** No chest slot limit, no ante to exhaust. Only Gold booster inventory is a self-imposed stop. | 🔶 | Consequence of §2 (no ante) and §3 (no chest slot system). Mix-It has a weaker stop-out than classic genre — players can grind without natural friction. MM similar. Re-check in playtest. |
| Core loop cadence | Matches core genre pattern. | ✅ | |

---

## 9. Onboarding

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Tutorial = first forced win vs. weak bot | Not explicit in v7 docs but implied (Starter inventory + Juice Stand AI). | 🟡 | Should be spec'd. |
| Early win-rate tuning (60–70%) | Not explicit. | ❌ / 🟡 | Genre-standard; assume implicit. |
| First IAP in first 1–3 sessions | Starter Pack triggers within 48h. | ✅ | |
| Progression front-loaded | Arena unlocks rapid on Trophy Road (Beach Bar at 200, Cocktail at 500). Starter gives 50 coins + some boosters. | ✅ | |

---

## 10. Live-ops & events

| Convention | Mix-It v7.2 state | Status | Notes |
|---|---|---|---|
| Seasonal league reset | Bar Pass 30-day season; no separate league reset. | 🟡 | See §3. |
| Battle Pass seasons (28–42 days) | 30-day Bar Pass. | ✅ | |
| Themed seasonal content drops | Seasonal Album (1 at a time, 30-day, archives on rotation). | ✅ | Match-Masters-faithful. |
| Limited-time tournaments with entry fees | **Not in MVP.** Reserved in v7.1 §17.2. | ⏸ | Key genre feature for ARPDAU lift; plan post-MVP. |
| Limited-time game modes | **Not implemented.** | ⏸ | Stumble Guys / 8BP Lucky Shot model. Consider for live-ops phase. |
| Licensed / crossover collabs | **Not planned.** | ❌ / ⏸ | Scale feature; not expected at prototype. |
| Flash offers (behavioural) | 4 triggers implemented. | ✅ | See §6. |

---

## Aggregate scorecard

| Bucket | ✅ Match | 🟡 Hybrid | 🔶 Intentional Divergence | ❌ Gap | ⏸ Deferred |
|---|---:|---:|---:|---:|---:|
| 1. Match structure | 3 | 2 | 0 | 0 | 0 |
| 2. Matchmaking & stakes | 5 | 1 | 1 | 1 | 0 |
| 3. Progression meta | 2 | 1 | 1 | 0 | 1 |
| 4. Content system | 3 | 0 | 1 | 0 | 0 |
| 5. Economy & currencies | 3 | 1 | 3 | 0 | 0 |
| 6. Monetization | 4 | 2 | 0 | 3 | 1 |
| 7. Social & retention | 1 | 1 | 0 | 3 | 5 |
| 8. Session design | 2 | 1 | 1 | 0 | 0 |
| 9. Onboarding | 2 | 2 | 0 | 0 | 0 |
| 10. Live-ops & events | 3 | 1 | 0 | 1 | 3 |
| **Total** | **28** | **12** | **7** | **8** | **10** |

---

## Highest-risk divergences (flag for review)

1. **No weekly league.** Bar Pass covers seasonal rhythm, but weekly competition is genre-defining. **Action:** lightweight weekly-reset leaderboard with small rewards.
2. **No rewarded-video ad integration.** Low-effort, high-value. **Action:** add before launch.
3. **No chest slot system + no ante = weak session stop-out.** Players can grind indefinitely with no natural friction point. **Action:** monitor in playtest; if stalls appear, consider adding Gold-booster-regen gate or chest-slot cap.
4. **No clubs/teams/chat in MVP.** Expected for prototype, but the post-MVP social plan should be explicit before soft-launch — social is a 20–40% retention lift in this genre.
5. **No VIP ladder.** Medium-term monetization risk for whale retention.
6. **No hard currency (gems) — MM-faithful but caps monetization ceiling.** MM itself is Coins-only so this is aligned with the target archetype, not a flaw. If post-soft-launch revenue trails 8BP/Golf Clash benchmarks, reopen; do not pre-emptively add a gem layer just because other genre titles have one. **Source:** [Candivore Zendesk — Coins](https://candivore.zendesk.com/hc/en-us/articles/360019827339-Coins).

## Lowest-risk confirmed-MM-faithful divergences (keep as-is)

- No per-match ante (MM-faithful).
- Auto-tier arena, no selector (MM-faithful, added in v7.2).
- Flat-power boosters, no card-upgrade system (MM-faithful).
- Stickers as primary collection, not equipment cards (MM-faithful).
- Single soft currency, no hard currency (MM-faithful — MM is Coins-only per [Candivore Zendesk](https://candivore.zendesk.com/hc/en-us/articles/360019827339-Coins)).
- Score-margin star rule (MM-faithful, added in v7.2).
