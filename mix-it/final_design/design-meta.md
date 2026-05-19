# Mix-It — Meta Design

The meta layers of the **final game**. These systems sit above the core match loop (see [design-match.md](design-match.md)) and the ladder/Trophy Road/Daily Missions/Star Race (see [design-progression.md](design-progression.md)).

The full meta stack matches genre standard (Match Masters / Clash Royale) **plus one system unique to us**: **Venue**, our plugin-themed bar/café ownership layer that has no direct Match Masters analogue.

For the time-axis view of where each meta layer lives, see [design-progression.md §7 "Role in the design"](design-progression.md).

For MVP slicing — what to launch first vs hold for later — see `design-mvp-playtest.md`. This doc describes the **full final game**.

---

## 1. Bar Pass

Source: `BarPassService.cs`, design-v7.3.

Season-pass-style progression layered over the ladder. Players earn **BPP** (Bar Pass Points) from matches; BPP fills tiers; each tier hands out a reward.

| Parameter         | Value | Notes |
|-------------------|------:|-------|
| Total tiers       | 30    | Per season |
| BPP per tier      | 400   | Linear |
| Total BPP / season| 12,000 | 30 × 400 |
| Bonus bank cap    | 5,000 coins | For overflow past tier 30 |
| Coins per overflow tier | 100 | After tier 30, excess BPP converts to coins, capped at bank |

Rewards (per tier) include coins, boosters, sticker tokens, and venue building tokens. The Bar Pass has both a **free track** and a **premium track** unlocked by IAP (hooks already in code).

Bar Pass is the **primary seasonal cadence**. Its 30-day arc creates the rhythm the entire meta stack rides on — Weekly Missions feed BPP, Daily Missions feed BPP, match outcomes feed BPP.

---

## 2. Weekly Missions

Source: `WeeklyMissionCatalog.cs`, `WeeklyMissionService.cs`, design-v7.3 §5.

A 7-day mission arc above Daily Missions. Three missions are sampled deterministically per ISO week from a pool of 10.

| Parameter         | Value |
|-------------------|------:|
| Mission pool      | 10 missions |
| Active per week   | 3 (sampled from the pool) |
| Reward per mission| 300 coins + 1 Silver Pack Token |
| Reset cadence     | Weekly, ISO week boundary |

Mission examples from the pool (full list in code): *Win 20 matches*, *Earn 5,000 coins*, *Open 3 packs*, *Reach Trophy 1,000*, *Win 3 ×2-stake matches*, *Reach 5★ in Star Race*, *Pull 5 Rare stickers*, *Use 30 boosters*, *Spend 2,000 coins in Shop*.

Weekly Missions are **the glue layer** — every other meta system feeds into them. Bar Pass progress, Star Race participation, Pack Opener activity, Shop spending, Stake matches, Trophy thresholds. A player who engages with the meta will pass weekly missions naturally; a player who doesn't gets a nudge each week to try the deeper systems.

---

## 3. Venue (our unique design)

Source: `VenueService.cs`, `DistrictCatalog.cs`, design-v7.3 §7, design-v6.5.

**Venue is unique to Mix-It.** Match Masters does not have a Venue equivalent. We added it because our plugin is customer service ("your bar / your café") and the player owning and upgrading an actual bar is a natural fantasy extension of that. The closest genre analogue is Royal Match's Robert's Castle — a meta-progression where match-3 currency rebuilds a property.

Three districts, each containing buildings the player upgrades using **Venue Tokens (VT)**.

| District   | Unlock arena (current code, 8-arena ladder) | Theme |
|------------|------------|-------|
| Cafe Row   | Arena 0 (Juice / Smoothie / Coffee) | Sunny, casual |
| Boulevard  | Arena 3 (Tea / Cocktail) | Mid-tier urban |
| Uptown     | Arena 5 (Wine / Champagne / Grand) | Luxury, aspirational |

| Parameter | Value |
|-----------|------:|
| Venue Token cap | 200 |
| VT per arena promotion | 5 |
| VT per seasonal album page | 1 |
| Shards → Silver Pack | 5 shards |
| VT per shard conversion | 5 |

### 14-arena re-mapping

The current `DistrictCatalog.cs` maps districts onto the 8-arena codebase. For the 14-arena final ladder the re-mapping is:

| District          | Arenas (14-arena ladder) |
|-------------------|--------------------------|
| Cafe Row          | 1–4 (Juice → Boba Tea) |
| Boulevard         | 5–8 (Coffee → Cocktail) |
| Uptown            | 9–11 (Tiki → Whiskey) |
| Penthouse District | 12–14 (Champagne → Grand Hotel) — **new district** |

Penthouse District is the new top-tier district added for the 14-arena final ladder, called out as a hook in `design-v7.6-patch-14-arenas-booster-refactor.md`.

Venue's role: it answers "what did I build" while Trophy Road answers "where did I climb". Two different progression emotions on the same loop.

---

## 4. Album (sticker collection)

Source: `AlbumService.cs`, `AlbumCatalog.cs`, design-v7.5.

Sticker-collection meta. Stickers pulled from packs; complete sets earn coins and venue tokens.

| Parameter        | Value |
|------------------|------:|
| Albums           | 4 (Bar Classics / City Nights / Grand Hotel / Summer Rooftop) |
| Stickers / album | 10 |
| Stickers / page  | 5 (so 2 pages per album) |
| Reward per page  | 150 coins |
| Reward per full album | 2,000 coins + 1 Venue Token |

Albums 1–3 are **evergreen**: Bar Classics, City Nights, Grand Hotel. Album 4 (Summer Rooftop) is **seasonal** — rotates with each Bar Pass season's theme.

Albums plug into Venue (full-album rewards include VT) and Pack Opener (stickers come from packs). The three layers are designed as one unit.

---

## 5. Pack Opener

Source: `PackOpener.cs`, design-v7.3.1.

Reveal experience for sticker packs. Packs come from Trophy Road, Weekly Missions, Bar Pass, and Flash Offers.

| Pack size | Stickers revealed |
|-----------|-------------------|
| Small     | 3 |
| Standard  | 5 |
| Big       | 10 |

**Rarity weights (normal pack):**
- White 60% / Silver 28% / Gold 10% / Diamond 2%

**Big pack — forced rare on one slot:**
- Gold 80% / Diamond 20% for the forced slot

**Duplicate handling:** owned stickers convert to **Sticker Tokens** — the F2P duplicate-protection valve introduced in design-v7.3.1 §7. Sticker Tokens can be spent to claim chosen stickers, capping bad luck.

---

## 6. Lucky Box

Source: `LuckyBoxService.cs`, design-v6.x phase 6.3g.

Mid-session pacing reward. A meter fills as the player earns coins; when full, the player opens it for a guaranteed reward.

| Parameter            | Value |
|----------------------|------:|
| Full progress        | 100 points |
| Coins → progress     | 5 coins = 1 point |
| Open reward          | 200 coins + 1 random Bronze booster |
| FTUE pre-fill (M3)   | 50 points (so the player can open it shortly after onboarding) |

Lucky Box is **independent of arena, missions, or Bar Pass**. It gives players who don't engage with deeper meta layers something concrete to chase every few matches. Lower-engagement players see the meter; deeper-engagement players see Bar Pass on top.

---

## 7. Flash Offers

Source: `FlashOfferCatalog.cs`, design-v6.x.

Time-limited IAP bundles triggered by emotional moments.

| Offer ID    | Title              | Bundle (current text)                       | Window  | Trigger |
|-------------|--------------------|---------------------------------------------|---------|---------|
| comeback    | Comeback Bundle    | 900 coins + 3 mixed boosters                | 30 min  | 3 consecutive losses |
| promotion   | Promotion Pack     | Arena-scaled coins + 5 boosters             | 24 h    | Arena promotion |
| refill      | Refill Pack        | 1,000 coins + 2 boosters                    | 2 h     | Low-coin state |
| sticker     | Sticker Splurge    | 1 Big Pack + 1 Sticker Token                | 2 h     | After pack open |

Flash Offers sit above the regular shop. They appear only when the player is in an emotional state where the offer is genuinely appealing — a comeback bundle after a losing streak, a celebration pack after promotion.

---

## 8. Mail

Source: `MailService.cs`.

Asynchronous reward delivery: weekly mission completion grants, season-end Bar Pass rewards, customer support compensation, special event drops.

Mail is **infrastructure, not a feature**. It is invisible to design but required for any system that delivers rewards outside the moment-of-action.

---

## 9. Daily Login indicator

Source: `DailyLoginService.cs`.

A small visible streak counter on the Home screen ("Day 4 in a row"). Reinforces the habit loop.

Trivially small in scope. Operates alongside Daily Missions but is a **passive visible indicator**, not an actionable system.

---

## 10. Full currency stack

The final game runs **multiple currencies**, each tied to a specific subsystem. This is genre-standard for Match Masters–scale meta.

| Currency | Source | Sink | Role |
|----------|--------|------|------|
| **Coins** | Match payouts, Bar Pass, Trophy Road, Lucky Box, Daily/Weekly Missions, sticker page rewards, Flash Offers | Booster shop, Pack Opener (paid packs) | Primary currency. The match-driven income. |
| **Bar Pass Points (BPP)** | Match outcomes, Daily Missions, Weekly Missions | Bar Pass tier progression | Seasonal pacing currency. |
| **Sticker Tokens** | Duplicate stickers from Pack Opener, Flash Offers | Direct sticker claim (duplicate protection) | F2P bad-luck valve. |
| **Silver Pack Tokens** | Weekly Missions, Trophy Road, Bar Pass | Silver Pack opening | Mid-tier pack-acquisition currency. |
| **Gold Pack Tokens** | Trophy Road, Bar Pass premium track, Flash Offers | Gold Pack opening (forced-rare) | Premium pack-acquisition currency. |
| **Venue Tokens (VT)** | Arena promotions, full-album completion, seasonal album pages | Venue building upgrades | Drives Venue progression. Cap 200. |
| **Venue Sticker Shards** | Sticker pulls (Venue-specific stickers) | Convert to Silver Pack (5 shards = 1 pack) | Sub-resource bridging Pack Opener → Venue. |

The currency stack **activates progressively** in the player's experience — coins from match 1, BPP once Bar Pass introduces, Sticker Tokens once Albums start filling, etc. New players don't see all currencies at once; the UI introduces each currency only when the system it powers becomes accessible.

---

## 11. Meta layer interaction summary

Each meta layer feeds and consumes other layers. The web:

- **Match** → coins, BPP, Star Race stars, Daily/Weekly mission progress, Lucky Box meter, Trophy Road
- **Trophy Road** → coins, boosters, Stakes unlock, cosmetics, possibly pack tokens
- **Daily Missions** → coins, BPP, free booster bonus (all-3)
- **Weekly Missions** → coins, Silver Pack Tokens, BPP
- **Bar Pass tier-up** → coins, boosters, Sticker Tokens, Venue Tokens, Pack Tokens
- **Star Race week-end** → cosmetics only (no currency)
- **Pack Opener** → stickers (which fill Albums), Sticker Tokens (on duplicates)
- **Album page / full** → coins, Venue Tokens
- **Venue building upgrade** → bar visual progress, sometimes cosmetic unlocks
- **Lucky Box** → coins, Bronze booster
- **Flash Offers** → IAP-purchased bundles (coins, boosters, packs)

No layer is a dead end. Every reward feeds another layer of the stack. That density is what genre standard looks like, and is what the final design commits to.
