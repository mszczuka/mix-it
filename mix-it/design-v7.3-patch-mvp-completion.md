# Mix-It Design Patch v7.3 — MVP Completion

**Patch date:** 2026-04-23
**Applies to:** v7.2-patch-mm-fidelity (2026-04-21)
**Purpose:** Fill archetype gaps identified in the 2026-04-22 design review that require **design decisions** (not tech infrastructure or separate research passes).
**Soft-launch target:** after v7.5 (v7.3 = meta structure + UI, v7.4 = FTUE + tuning, v7.5 = ads + pre-launch polish)

---

## Patch scope

### ✅ In this patch
- §1 Ante confirmation (no change — homework closed)
- §2 Arena count 6 → 8 + retuned trophy curve
- §3 Trophy Road 20 → 25 milestones
- §4 Star Meter archetype fix → Star Race (weekly solo leaderboard)
- §5 Weekly loop: Star Race + Weekly Missions + reset reward
- §6 Pass catch-up tier purchase
- §7 Venue: scope cut (6 → 3 districts) + Home display selector
- §8 Teams stub (fake-it UI with notify-me capture)
- §9 Ranking hub: Arena + Country + Global leaderboards
- §10 VIP ladder (new — M-7 from gap list)
- §11 Profile / Showcase feed (new — M-13 from gap list)
- §12 Sticker album reward visibility
- §13 Offer transparency (booster content preview)
- §14 Home UI reshuffle (Trophy Road + Ranking side-buttons, Teams in bottom nav)
- §15 Appendices: trophy curve, Trophy Road, Star Race rewards, Weekly Missions, album rewards, VIP ladder math, Starter Pack, Flash Offers, Pass Premium, coin generation ceiling, Venue Token pacing

### ⏭ Deferred to v7.4
- FTUE spec (forced-win match 1, bot WR curve, sequential mechanic unlocks)
- Starter rewards + first-purchase popup timing
- Interstitial ad decision
- Target session length + sessions/day KPI
- Reconnection / anti-cheat baseline
- Final tuning pass on all numbers in this patch's appendices

### ⏭ Deferred to v7.5 (tech-blocked)
- Rewarded video integration (2 placements: post-match double coins, Color Spawn recharge)

### ⏸ Deferred post-MVP (explicitly planned — see §16 for full list)
- Real Teams system (v9: chat, boxes, events, donations)
- Guild Match / Football Rivals pattern (v10)
- Tournaments / LTMs
- Whale SKU ladder ($49.99+)
- Subscription, piggy bank
- Additional albums, arenas, Venue districts (seasonal drops)

---

## §1 — Ante: verified, no change

Web-verified 2026-04-23 via Naavik Match Masters deconstruction:

> "There is no entry fee or coin cost to play individual 1v1 matches. Instead, players must select a booster before each match, which functions as the primary monetization mechanism."

v7.2 §22 decision stands. The **booster is the ante** — Booster Stakes Multiplier captures the wager dynamic. **No design change.**

**Source:** [Naavik — Match Masters deconstruction](https://naavik.co/deep-dives/match-masters-deconstruction/) (2023-05).

---

## §2 — Arena count: 6 → 8

**Change:** Expand arena ladder from 6 to 8 tiers. Retune trophy curve.

**Rationale:**
- Clash Royale launched with ~9 arenas, scaled to 28 over a decade
- Match Masters now runs 22 (launch count unverified)
- 6 arenas sits at the low end of the defensible soft-launch range; 8 adds 2 promotion reward moments and better matchmaking distribution
- 10+ at MVP would over-scope relative to reference set

**New 8-arena trophy curve** (full table in §15.A):
| # | Arena | Trophy gate | Stakes | Boosters (cum) |
|---|---|---|---|---|
| 1 | Juice Stand | 0 | ×1 | 2 |
| 2 | Smoothie Bar | 150 | ×1 | 3 |
| 3 | Coffee House | 400 | ×1 | 4 |
| 4 | Tea Garden | 800 | ×1 | 5 |
| 5 | **Cocktail Lounge** | **1,000** | **×1/×2/×3/×4** | 6 |
| 6 | Wine Cellar | 2,000 | ×1–×4 | 7 |
| 7 | Champagne Room | 2,900 | ×1–×4 | 8 |
| 8 | Grand Hotel | 4,000 | ×1–×4 (×5 post-MVP) | 8 |

**Trophy ceiling:** 4,500 (was 4,000).

**Locked curve:** 0 / 150 / 400 / 700 / 1,000 / 1,500 / 2,200 / 3,200. Cocktail Lounge stakes unlock at 1,000 preserved from v7.2 narrative. Flattened early curve chosen over 1.5× multiplicative to avoid excessive Arena 4 pre-stake grind (v7.4 Q4 decision, 2026-04-23).

**Asset cost:** +33% on arena art, booster skins, promotion chests. No new mechanics.

---

## §3 — Trophy Road: 20 → 25 milestones

Extended to match the 4,500 trophy ceiling. Staking unlock sits at milestone #7 (1,000 trophies — Cocktail Lounge gate, preserved from v7.2). See full table in §15.B.

---

## §4 — Star Meter → Star Race (archetype fix)

### Problem
Current v7 Star Meter → 25-star Star Chest is **not MM-aligned**. Web-verified 2026-04-23:

> "Stars are another progression vector, used in the game primarily for team play to unlock weekly team boxes or star race events to compete with other players on a leaderboard."
> — Naavik, 2023

MM stars feed (a) **team boxes** and (b) **star race leaderboard events**. There is no solo 25-star Star Chest. The v6/v7 tag of "🟢 aligned" was wrong.

### Decision: reframe as Star Race (weekly solo leaderboard)

Solves two problems at once: removes the archetype divergence AND fills the week-scale loop gap (biggest time-scale hole in v7.2 review).

### Design

- **Stars earned per match (MM-1:1):**
  - Win by ≥30% margin → **3 stars**
  - Win → **2 stars**
  - Loss (non-technical) → **1 star**
- **Star Race leaderboard:** weekly, **arena-scoped** (8 boards total). Resets Monday 00:00 UTC.
- **Rewards** (full table in §15.C):
  - Top 10, Top 100, Top 500, Participation (≥10 stars)
  - Coins + sticker packs, scaling by arena tier (Arena 1 Top 10 = 1,500 coins + 2 Silver; Arena 8 Top 10 = 25,000 coins + 3 Gold)
- **Rewards mailed at reset, 14-day claim window**

### Visual separation from Trophy Road (critical)

| | Trophy Road | Star Race |
|---|---|---|
| HUD placement | Top-right, avatar-adjacent (rank identity) | Home right-side button + below-fold weekly meter (activity) |
| Iconography | 🏆 trophy icon + number | 🥇 star icon + countdown timer |
| Color language | Arena-tier colors | Weekly season color |
| Player perception | "I'm climbing" (permanent rank) | "I'm earning" (resetting activity) |

### Star Chest — REMOVED for MVP
- Reclaim reward density via Lucky Box + Daily Chest + Star Race weekly payout
- **Post-MVP (v9 Teams):** revive as Team Box — stars feed team progress (archetype-correct)
- **Data-model hook:** keep `star_source` field on match-result so stars can be repointed to team boxes without schema migration

### In-game language
Star Race screen shows "Solo leaderboard — Team Leagues coming soon" to preview the upgrade path.

---

## §5 — Weekly loop: Star Race + Weekly Missions + reset reward

Fills the single largest time-scale gap (week-scale KotH layer was absent in v7.2).

### Star Race (see §4)
Core weekly loop. Measurable, arena-scoped, Monday reset.

### Weekly Missions (3 concurrent)

- Extends the 3/day mission system with a 7-day counter
- Mission pool of 10 (full list in §15.D). Mix of volume / skill / variety verbs so any 3 are achievable by a 15-min/day player
- 3 active missions per week, no rotation mid-week
- **Reward per mission:** 300 coins + 1 Silver sticker pack
- **Full-clear bonus (3/3):** 1,500 coins + 1 Gold sticker pack

### Weekly reset reward chest

Players who stayed above a trophy threshold in their current arena at reset get a tier-scaled chest:
- Arena 1–2: small (300c + 1 Silver)
- Arena 3–5: medium (1,000c + 1 Silver + shards)
- Arena 6–8: large (2,500c + 1 Gold + shards)

---

## §6 — Pass catch-up tier purchase

- **$0.99 per 3 tiers** OR **$4.99 per 15 tiers** (bulk discount = 25% per-tier)
- **Caps at tier 28** — final 2 tiers must be earned
- UI: Pass screen shows "Skip Ahead" button adjacent to current tier
- Protects pass revenue for late joiners and players who miss days

---

## §7 — Venue: scope cut + Home display selector

### Scope reduction
- **Districts: 6 → 3** for MVP (reserve 3 for post-MVP seasonal drops)
- **Buildings per district: 29 → 10**
- **Levels per building: 3 (unchanged)**
- **Total:** 522 → 90 building-levels (**83% asset cost reduction**)

### Arena-to-district mapping

| Arenas | District |
|---|---|
| 1–3 (Juice Stand → Coffee House) | **District 1: Café Row** (sunny, casual) |
| 4–5 (Tea Garden → Cocktail Lounge) | **District 2: Boulevard** (mid-tier urban) |
| 6–8 (Wine Cellar → Grand Hotel) | **District 3: Uptown** (luxury, aspirational) |

### Venue Token pacing (see §15.K for math)
Tokens per match-win scale down with arena (1 / 0.5 / 0.15) so the current arena's district completes to ~70% by the time the player crosses into the next arena. ×2/×3/×4 stake wins grant proportional bonus tokens — whales progress faster without breaking the curve.

### Home display selector (new feature)

- **Default:** Home shows the district mapped to the player's current arena
- **Override:** picker UI lets the player switch Home view to any **unlocked** district
- **Locked districts:** visible in picker as silhouettes (aspiration drivers)
- **Transition:** smooth camera pan between districts, no loading screen

### Post-MVP roadmap
- Districts 4, 5, 6 ship as seasonal content drops alongside arena expansions 9–12

---

## §8 — Teams stub (fake-it UI)

### Principle: aspiration without infrastructure

Ship the **promise** of teams, not the system. Measures player intent (do people care?) at minimal engineering cost. Supercell-pattern: multiple Supercell games ran "Clans coming soon" buttons at soft-launch.

### Screen 1 (above fold)
- Hero art: mock team banner with 5 silhouette avatars
- Tagline: **"Your crew is coming."**
- Coming-soon ribbon (diagonal corner badge)
- Primary CTA: **"Notify me"** → opt-in modal (push permission prompt; if already denied, email field)
- Secondary: "Preview features ↓" scroll hint

### Screen 2 (below fold, scrollable)
Four mock feature cards with static illustration + 1-line copy:
1. **Team Chat** — "Coordinate with your crew"
2. **Team Box** — "Open together, win together"
3. **Team Star Race** — "Compete as a team"
4. **Booster Donations** — "Share boosters with teammates"

Footer: "Launching v9 — estimated [season placeholder]"

### Unlock-state variant (player ≥ 1,000 trophies — Cocktail Lounge)
- Same screens, header treatment changes
- Ribbon becomes **"Unlocking soon!"** in gold
- CTA becomes **"Get ready"** with countdown-style visual (no real date — builds anticipation without committing)
- Bottom-nav Teams badge: 🔒 replaces "NEW"

### Tracking events
- `teams_tab_click` (source: bottom_nav / deeplink)
- `teams_notify_opt_in` (method: push / email)
- `teams_screen_scroll_depth` (0 / 25 / 50 / 75 / 100)
- `teams_unlock_state_view` (first time player hits ≥1000 trophies and opens tab)

### Design guardrails
- Do **NOT** show fake team list / fake member list / fake chat messages (players hate feeling deceived)
- Do **NOT** imply a hard launch date unless marketing can commit
- Do **NOT** let any tap resolve to an empty screen — dead buttons read as bugs

### Launch activation (v9 Teams phase)
- Notify-me opt-in list → push campaign on launch day
- Star Race converts to Team League; stars now feed Team Box (archetype-correct)
- Designed-in hooks from MVP go live without schema migration

---

## §9 — Ranking hub (Arena + Country + Global)

New top-level destination, accessed via the Home right-side **Ranking 🥇** button (see §14). Houses four leaderboard surfaces as tabs:

### Tab 1 — Star Race *(default landing tab)*
Weekly, arena-scoped. See §4.

### Tab 2 — Arena Leaderboard
- Top 100 trophies in each of 8 arenas
- Reset monthly with season
- Rewards: top 10 coin pack + sticker pack; top 11–100 smaller coin pack

### Tab 3 — Country Leaderboard *(M-11 from gap list)*

**Archetype verification:** Country leaderboards are **genre-standard** — 8 Ball Pool ships them ([Miniclip Support](https://support.miniclip.com/hc/en-us/articles/204975658-Leaderboards-8-Ball-Pool), weekly reset, top-3 prizes), Clash Royale ships them ([Supercell Support](https://support.supercell.com/clash-royale/en/articles/ranked-2.html), top 100 per country, monthly reset). Match Masters has **no verified country leaderboard** — Mix-It's inclusion aligns with CR/8BP, not MM.

**Structure:**
- One board per (arena × country), top 100 per combination
- Player appears only on board for current arena; demotion drops them from higher-arena board
- **Reset:** monthly with season (1st of month, 00:00 UTC)
- **Rewards:** top 10 → coin pack + 1 sticker pack + exclusive monthly frame; top 11–100 → smaller coin pack + sticker shards
- **Geo-detection:** device locale captured at account creation, locked (MVP simplicity; v8 consideration: IP + locale cross-check for anti-farm)
- **Visual:** flag emoji prefix on entries
- Archived to player profile as "Best country rank: #X, [Month Year]"

### Tab 4 — Global Leaderboard *(M-12 from gap list)*

**Archetype reference:** [Clash Royale Global Leaderboard](https://royaleapi.com/players/leaderboard?lang=en) ships a top-1,000 "Hall of Fame" pattern.

**Structure:**
- Top 1,000 players worldwide by total trophies
- **Vanity-only — NO rewards.** Appearance IS the reward.
- "Top 1000" profile badge granted for every season finished ranked (badges stack — e.g., "×3 Top 1000")
- Reset monthly with season
- Tie-break: higher arena → earlier trophy-milestone timestamp → account age
- Player's current rank pinned above scrollable list ("Not ranked — need X trophies to enter" state if below cut)

### Ranking hub UX
- Tab header shows countdown timer to next reset
- Player's rank always pinned above list
- Tap any entry → opens public profile (§11)

---

## §10 — VIP ladder *(M-7 from gap list)*

### Archetype note
8 Ball Pool's VIP Club uses **6 tiers** (Bronze → Silver → Gold → Emerald → Diamond → Black Diamond) per [Miniclip Support](https://support.miniclip.com/hc/en-us/articles/360000639967-VIP-Points-8-Ball-Pool). Mix-It's **10-tier** variant is an original extension of the 8BP pattern — not 1:1. Justification: 10 tiers give more granular promotion hits at the dolphin/whale price points, matching Mix-It's smaller LTV ceiling (no hard currency, no $99 SKU at MVP).

### Earning rule
- **100 VIP points per $1 USD spent**
- Points lifetime-accumulated (non-decaying) drive **tier**
- Rolling 30-day window drives optional **VIP multiplier events** (post-MVP)
- **Free players never earn VIP points** — intentional separator

### Tier structure (10 tiers, full table in §15.G)

| Tier | Name | VIP pts | ~$ to reach | Perks (stacking) |
|---|---|---|---|---|
| 1 | Bronze I | 30 | $3 | +5% coin gen, VIP1 frame |
| 3 | Bronze III | 250 | $25 | +15% coin, extra daily mission slot (3→4), exclusive emote |
| 5 | Silver II | 1,000 | $100 | +25% coin, 2× Lucky Box capacity, animated frame |
| 7 | Gold I | 4,000 | $400 | +35% coin, mission slot (4→5), priority-queue cosmetic anim |
| 10 | Obsidian | 20,000 | $2,000 | +50% coin, −25% booster shop, leaderboard name highlight, concierge cosmetic bundle |

### Perk categories
- **Cosmetic (all tiers):** tier ring around avatar, tier-colored name in chat/leaderboards, exclusive frames (Silver+), exclusive titles (Gold+), animated avatar border (Diamond+)
- **Economy (upper tiers):**
  - Coin gen % multiplier on match wins
  - Booster shop discount
  - Bar Pass XP multiplier (Gold+)
  - Extra daily mission slot (T3, T7)
  - Extra Lucky Box capacity (T5)
  - Monthly/weekly free Gold sticker pack (T6, T9)
- **Fairness-safe perks only** — no matchmaking advantage, no in-match power boosts

### Tier UX
- Dedicated VIP screen accessible via profile HUD badge
- Progress bar to next tier + point delta + nearest offer that would trigger promotion
- Next-tier preview card (blurred perks, "Unlock at X pts")
- Promotion moment: full-screen takeover, tier-ring animation, perk reveal, gift grant

### Visibility
- Tier ring on Home HUD avatar (top-left)
- VIP tier badge on public profile (§11)
- Tier name next to username on all leaderboards

---

## §11 — Profile / Showcase feed *(M-13 from gap list)*

### Archetype verification
All three reference games surface **progression stat + collection flex + social tag**:
- **Match Masters:** character (customisable outfits from albums), trophies, sticker collection, team — per [Fandom Stickers & Albums](https://match-masters.fandom.com/wiki/Stickers_,Sticker_sending_and_Albums)
- **8 Ball Pool:** level (up to 999), equipped cue + stats, Cue Collection Power, club — per [Miniclip — Cue Collection Power](https://support.miniclip.com/hc/en-us/articles/360011839377--Cue-Collection-Power-Frequently-Asked-Questions)
- **Clash Royale:** trophies (current + best), arena, W/L, favourite card, clan, badges — per [Fandom Player Profile](https://clashroyale.fandom.com/wiki/Player_Profile)

### Public profile contents (view-only by others)
- Avatar + frame + title (stacked visual identity block)
- Total trophies (lifetime peak + current)
- Highest arena reached (with arena art thumbnail)
- Sticker album completion % per album (4 mini progress bars)
- VIP tier badge (Silver+ only — hidden for Bronze to protect new-player dignity)
- **Favorite 3 stickers showcase** — **Diamond VIP and above only**. Locked slot visible to others with "Unlock at Diamond VIP" teaser (aspirational monetization hook)
- Country flag (from §9 geo)
- "Top 1000" season badges (stacked, from §9 Tab 4)

### Access
- Tap opponent avatar from:
  - Match-result screen
  - Any leaderboard entry (all 4 Ranking tabs)
  - Star Race standings
- **No friend-add, no DM at MVP** (moderation scope too heavy)

### Privacy / moderation (MVP)
- Username **locked after initial setup** (prevents impersonation churn)
- **No free-text bio** (moderation cost)
- Report button on every public profile → server-side flag queue
- Profanity filter on usernames at setup (client + server)

### Own-profile customization screen
- Avatar picker (unlocked via Trophy Road / Pass / VIP)
- Frame picker (unlocked via VIP tiers / season ranks)
- Title picker (unlocked via events / VIP / album completion)
- Favorite-3 sticker picker (Diamond VIP+ gated)
- Live preview pane

---

## §12 — Sticker album reward visibility

### Problem
Players can't preview what they'll earn from pages / full albums. Hidden rewards kill collection aspiration.

### Full-album banner (top of album screen)
- Prominent horizontal banner, ~1/4 screen height
- End-reward icon + quantity + "Complete all 20 stickers → [reward]"
- Progress bar: X/20 stickers collected
- Claimed state: banner flips to gold with "Claimed ✓" stamp + claim date

### Per-page header (each 5-sticker page)
- Reward icon + quantity left-aligned
- Progress: "Unlocks at 5/5 this page" with mini-bar
- States:
  - **Locked** (0–4/5): greyed icon, desaturated
  - **Claimable** (5/5 unclaimed): glowing pulse, "CLAIM" CTA
  - **Claimed**: green checkmark overlay + "Claimed ✓" label, icon stays colored but dimmed

### Tap-to-expand reward detail popup
- Full reward breakdown (quantity, rarity, use)
- Coin rewards: exact amount
- Sticker packs: pack contents / rarity odds (ties to §13 transparency)
- "Got it" dismiss

### Navigation polish
- Sticky page-header as user scrolls within a page (progress always visible)
- Page-dots at bottom show claim state at a glance (grey / pulse / green-check)

Full per-page and per-album reward table in §15.E.

### Archetype note
MM confirms per-page rewards and full-album completion rewards exist ([SimpleGameGuide](https://simplegameguide.com/match-masters-daily-free-gifts/), [MatchMastersCoin](https://matchmasterscoin.com/match-masters-stickers/)), but whether MM **previews rewards upfront in the UI** couldn't be verified from public sources — capture MM in-client screenshots before final art direction.

---

## §13 — Offer transparency (booster content preview)

### Header row
- Offer name (left) · countdown timer (center) · price CTA button (right, platform-localized)

### Contents grid (main body)
- 2–4 column grid of booster/reward icons
- Each icon:
  - **Tier border color** (Bronze / Silver / Gold — matches in-game)
  - Quantity badge (bottom-right, e.g., "×5")
  - Rarity dot (top-left)
- Tap any icon → detail popup: full name, description, where used, current inventory count

### Footer
- **"What's inside" expand button** → accordion reveals:
  - Full rarity breakdown (e.g., "3 Gold, 2 Silver, 5 Bronze")
  - Sticker guarantees (e.g., "1 guaranteed Seasonal sticker")
  - Coin-equivalent value (honest — no inflated "value $XX" claims)
- Legal disclaimer line (small grey text)

### Applies to
Starter Pack, Flash Offers, Shop Bundles, Pass Premium preview, seasonal offers.

### Mystery elements
Permitted **only** on seasonal offers, and **only for ≤ 30% of the bundle value**. Mystery slot must display "?" with rarity range ("Gold or Silver guaranteed"). **Never on Starter Pack** (trust-critical) or **Pass** (transparency-critical).

### Archetype note
Itemised shop offers are genre-standard ([Clash Royale — Shop Offers](https://support.supercell.com/clash-royale/en/articles/shop-offers.html), [8BP Pool Pass Guide](https://support.miniclip.com/hc/en-us/articles/360036840073--Pool-Pass-Elite-Pass-Your-Ultimate-Guide-8-Ball-Pool)). Supercell publishes drop-rate info where offers involve probabilistic elements. Mix-It's transparency level aligns with CR/8BP pattern.

---

## §14 — Home UI reshuffle

### Home right-side button stack (top → bottom)
1. **Trophy Road 🏆** — badge: distance to next unclaimed milestone ("3 🏆")
2. **Ranking 🥇** — badge: current Star Race rank in arena ("#7")

Both badges live-update on return to Home. Empty-state: no badge pip rendered.

### Bottom navigation (5 slots, left → right)

| Slot | Before | After |
|---|---|---|
| 1 | Home | Home |
| 2 | Road | **Teams** (stub per §8) |
| 3 | Shop | Shop |
| 4 | Pass | Pass |
| 5 | Profile | Profile |

### Badge rules

| Slot | Badge logic |
|---|---|
| Home | Red dot if unclaimed daily login / event tile |
| Teams | "NEW" until first tab-click → cleared → reappears as 🔒 when player hits 1,000 trophies unlock state (Cocktail Lounge) |
| Shop | Red dot on new offer OR ending-soon offer (<1h) |
| Pass | "!" if unclaimed tier reward, hidden otherwise |
| Profile | Red dot if unclaimed VIP tier-up or profile customization unlock |

### Rationale
- **Elevates Teams** to a persistent top-level destination even as a stub. Click-through rate is the primary social-demand KPI.
- **Progression views cluster on Home** (Trophy Road + Ranking) — matches Clash Royale / Brawl Stars hub pattern.
- **Ranking button** gives Star Race + Arena + Country + Global a unified UI surface they previously lacked.

### Asset cost
UI only. No new mechanics. Button icons + Home layout pass + Ranking hub tab controller.

---

## §15 — Appendices: tuning tables

> ⚠️ **Tuning disclaimer:** Numbers below are **first-pass starting values** from the economy agent. Final tuning pass happens in v7.4 after FTUE spec lands (FTUE retention targets feed back into coin gen and reward density). Items labeled `[invented]` are placeholders for values that depend on cosmetic shop pricing (not yet specced).

### §15.A — 8-arena trophy curve + promotion chests

| # | Arena | Trophy gate | Stakes unlock | Booster roster (cum) | Promotion Chest |
|---|---|---|---|---|---|
| 1 | Juice Stand | 0 | ×1 | 2 | Wood |
| 2 | Smoothie Bar | 150 | ×1 | 3 | Wood+ |
| 3 | Coffee House | 400 | ×1 | 4 | Bronze |
| 4 | Tea Garden | 700 | ×1 | 5 | Bronze+ |
| 5 | Cocktail Lounge | 1,000 | ×1/×2/×3/×4 | 6 | Silver |
| 6 | Wine Cellar | 1,500 | ×1–×4 | 7 | Silver+ |
| 7 | Champagne Room | 2,200 | ×1–×4 | 8 | Gold |
| 8 | Grand Hotel | 3,200 | ×1–×4 (×5 post-MVP) | 8 (cap) | Gold+ |

### §15.B — Trophy Road: 25 milestones

| # | Trophy | Reward |
|---|---|---|
| 1 | 50 | 200 coins |
| 2 | 150 | Booster unlock: Pour-Back |
| 3 | 250 | 1 Silver Sticker Pack |
| 4 | 400 | 500 coins + Booster unlock: Extra Tube |
| 5 | 600 | Avatar frame "Barista" |
| 6 | 800 | 800 coins + Booster unlock: Color Swap |
| 7 | 1,000 | **Stakes ×2/×3/×4 unlock** + 1,000 coins |
| 8 | 1,300 | Cocktail Lounge arena skin + Booster: Undo ×3 |
| 9 | 1,600 | 1 Gold Sticker Pack |
| 10 | 2,000 | 1,500 coins + Booster: Freeze Timer |
| 11 | 2,300 | Emote pack "Mixologist" |
| 12 | 2,600 | 2,000 coins + 1 Silver Pack |
| 13 | 2,900 | Booster: Hint+ |
| 14 | 3,100 | 1 Gold Sticker Pack |
| 15 | 3,300 | 2,500 coins |
| 16 | 3,500 | Profile frame "Sommelier" |
| 17 | 3,700 | 3,000 coins + Booster: Auto-Sort |
| 18 | 3,900 | 1 Gold Sticker Pack |
| 19 | 4,000 | Grand Hotel entry bonus 5,000 coins |
| 20 | 4,100 | Emote pack "Concierge" |
| 21 | 4,200 | 1 Gold Sticker Pack |
| 22 | 4,300 | 3,500 coins |
| 23 | 4,400 | Legendary avatar frame |
| 24 | 4,450 | 2 Gold Sticker Packs |
| 25 | 4,500 | 10,000 coins + seasonal cosmetic bundle |

### §15.C — Star Race weekly rewards

| Arena | Top 10 | Top 100 | Top 500 | Participation (≥10★) |
|---|---|---|---|---|
| 1 Juice Stand | 1,500c + 2 Silver | 800c + 1 Silver | 400c | 150c |
| 2 Smoothie Bar | 2,500c + 2 Silver | 1,200c + 1 Silver | 600c | 250c |
| 3 Coffee House | 4,000c + 3 Silver | 1,800c + 2 Silver | 900c | 400c |
| 4 Tea Garden | 6,000c + 1 Gold | 2,800c + 2 Silver | 1,400c | 600c |
| 5 Cocktail Lounge | 9,000c + 1 Gold | 4,200c + 3 Silver | 2,000c + 1 Silver | 900c |
| 6 Wine Cellar | 13,000c + 2 Gold | 6,000c + 1 Gold | 2,800c + 1 Silver | 1,300c |
| 7 Champagne Room | 18,000c + 2 Gold | 8,500c + 1 Gold | 4,000c + 2 Silver | 1,800c |
| 8 Grand Hotel | 25,000c + 3 Gold | 12,000c + 2 Gold | 5,500c + 1 Gold | 2,500c |

### §15.D — Weekly Missions (pool of 10)

| # | Mission | Target | Reward |
|---|---|---|---|
| 1 | Win matches | 15 | 300c + 1 Silver Pack |
| 2 | Win at stakes ×2+ | 8 | 300c + 1 Silver Pack |
| 3 | Earn Stars | 40 | 300c + 1 Silver Pack |
| 4 | Complete any sticker page | 1 | 300c + 1 Silver Pack |
| 5 | Use boosters in a win | 10 | 300c + 1 Silver Pack |
| 6 | Win without using a booster | 5 | 300c + 1 Silver Pack |
| 7 | Promote or defend arena | 1 | 300c + 1 Silver Pack |
| 8 | Win 3 in a row | 2 streaks | 300c + 1 Silver Pack |
| 9 | Play matches | 30 | 300c + 1 Silver Pack |
| 10 | Sort tubes cleanly | 50 | 300c + 1 Silver Pack |
| — | **Full-clear bonus (3/3)** | — | **+1,500c + 1 Gold Sticker Pack** |

Active missions: 3 concurrent per week, randomized from pool. No rotation mid-week.

### §15.E — Sticker album rewards

**Regular Album (×3)** — 20 stickers / 4 pages of 5

| Page | Reward |
|---|---|
| 1 (5/20) | 500c + 1 Silver Pack |
| 2 (10/20) | 1,000c + 1 Silver Pack |
| 3 (15/20) | 1,500c + 1 Gold Pack |
| 4 (20/20) | 2,500c + 1 Gold Pack |
| **Full album** | **10,000c + exclusive avatar frame + 2 Gold Packs** |

**Seasonal Album (×1)** — 20 stickers / 4 pages of 5

| Page | Reward |
|---|---|
| 1 | 800c + 1 Gold Pack |
| 2 | 1,500c + 1 Gold Pack |
| 3 | 2,500c + 1 Gold Pack + seasonal emote |
| 4 | 4,000c + 2 Gold Packs |
| **Full album** | **20,000c + exclusive seasonal arena skin + exclusive frame + 5 Gold Packs** |

### §15.F — Starter Pack $2.99

| Item | Qty | Coin-equiv value |
|---|---|---|
| Coins | 3,000 | 3,000 |
| Silver Sticker Pack | 3 | 1,500 |
| Gold Sticker Pack | 1 | 1,500 |
| Booster: Extra Tube | 5 | 1,000 |
| Booster: Color Swap | 5 | 1,500 |
| Exclusive Starter frame | 1 | 2,500 `[invented]` |
| VIP points | 30 | — (unlocks Bronze I) |
| **Displayed value total** | | **~11,000 coins** |
| **Price** | | **$2.99** |
| **Displayed multiplier** | | **5×** (vs. $2.99 base shop ≈ 2,200c) |

### §15.G — VIP ladder (10 tiers, full)

| Tier | Name | VIP pts | ~$ lifetime | Perks (cumulative, 2–3 new per tier) |
|---|---|---|---|---|
| 1 | Bronze I | 30 | $3 | +5% coin bonus; VIP1 frame |
| 2 | Bronze II | 100 | $10 | +10% coin bonus; booster shop −5%; VIP2 frame |
| 3 | Bronze III | 250 | $25 | +15% coin bonus; extra daily mission slot (3→4); exclusive emote pack |
| 4 | Silver I | 500 | $50 | +20% coin bonus; booster shop −10%; cosmetic priority-queue animation |
| 5 | Silver II | 1,000 | $100 | +25% coin bonus; 2× Lucky Box capacity; VIP5 animated frame |
| 6 | Silver III | 2,000 | $200 | +30% coin bonus; booster shop −15%; monthly 1 free Gold Pack |
| 7 | Gold I | 4,000 | $400 | +35% coin bonus; extra mission slot (4→5); cosmetic priority-queue (full) |
| 8 | Gold II | 7,000 | $700 | +40% coin bonus; booster shop −20%; exclusive seasonal skin |
| 9 | Diamond | 12,000 | $1,200 | +45% coin bonus; weekly 1 free Gold Pack; VIP9 legendary frame |
| 10 | Obsidian | 20,000 | $2,000 | +50% coin bonus; booster shop −25%; name highlight in leaderboards; personal concierge cosmetic bundle |

### §15.H — Flash Offers

| Trigger | Price | Contents | Displayed multiplier |
|---|---|---|---|
| Loss streak (3 in 24h) | $1.99 | 1,500c + 8 Extra Tube + 8 Color Swap + 2 Silver Packs | 4× |
| Arena promotion | $1.99 | 2,500c + 1 Gold Pack + new-arena frame + 5 mixed boosters | 4.5× |
| Low coins (<200c for 2h) | $1.99 | 4,000c + 3 Silver Packs + 3 mixed boosters | 4× |
| 3rd pack without Gold sticker | $1.99 | 1 Gold Pack (guaranteed) + 1,500c + 2 Silver Packs | 4× |

### §15.I — Bar Pass Premium $9.99 — sampled tiers

| Tier | Free | Premium |
|---|---|---|
| 1 | 100c | 300c + 1 Silver Pack |
| 5 | 300c | 800c + 1 Gold Pack + exclusive emote |
| 10 | 1 Silver Pack | 1,500c + 1 Gold Pack + tier-10 frame |
| 15 | 500c | 2,000c + 2 Gold Packs + exclusive arena skin |
| 20 | 1 Silver Pack | 2,500c + 1 Gold Pack + animated frame |
| 25 | 800c | 3,500c + 2 Gold Packs + exclusive booster variant |
| 30 | 1 Gold Pack | **Grand: 7,500c + 3 Gold Packs + legendary frame + exclusive title** |
| **Totals** | ~6,000c + 4 packs | **~35,000c + 14 Gold + 6 Silver + 5 cosmetics** |

### §15.J — Pass catch-up

| Offer | Price | Tiers | Cost/tier | Cap |
|---|---|---|---|---|
| Small catch-up | $0.99 | 3 | $0.33 | T28 |
| Bulk catch-up | $4.99 | 15 | $0.33 | T28 |
| Max purchasable tier | — | — | — | **T28** (final 2 earned only) |

### §15.K — Venue Token pacing

| District | Arenas | Trophy span | Est. wins to promote | Tokens / win | 70% target @ promote |
|---|---|---|---|---|---|
| 1 Café Row | 1–3 | 0 → 400 | ~70 | 1 | 70 tokens ✓ |
| 2 Boulevard | 4–5 | 400 → 1,300 | ~160 | 0.5 (1 per 2 wins) | 80 tokens ≈ 70% ✓ |
| 3 Uptown | 6–8 | 1,300 → 4,000 | ~490 | 0.15 (1 per 7 wins) | 70 tokens ✓ |

Stake multiplier also multiplies token grant (×2/×3/×4 wins).

### §15.L — Coin generation ceiling per day

| Arena | Lucky Box | Dailies | Star residual | **Passive** | Coin/×1 win | Active (×1, 30 wins) | Active (×4, 25 wins) |
|---|---|---|---|---|---|---|---|
| 1 | 500 | 600 | 200 | **1,300** | 20 | 600 | — |
| 2 | 600 | 600 | 200 | **1,400** | 30 | 900 | — |
| 3 | 700 | 600 | 200 | **1,500** | 40 | 1,200 | — |
| 4 | 800 | 600 | 200 | **1,600** | 55 | 1,650 | — |
| 5 | 1,000 | 600 | 200 | **1,800** | 70 | 2,100 | 7,000 |
| 6 | 1,200 | 600 | 200 | **2,000** | 90 | 2,700 | 9,000 |
| 7 | 1,400 | 600 | 200 | **2,200** | 115 | 3,450 | 11,500 |
| 8 | 1,600 | 600 | 200 | **2,400** | 150 | 4,500 | 15,000 |

VIP/Pass bonuses stack on top and are excluded from ceiling math.

---

## §16 — Post-MVP deferral list (explicit)

### v9 — Teams phase (~3 months post-soft-launch, IF notify-me signal is strong)
- Real Teams system: chat (canned + emoji only at launch), booster donations, sticker donations, Team Box, Team Events
- Unlock: 1,000 trophies (Cocktail Lounge)
- Size: 30 members (smaller than MM/8BP 50, matches soft-launch population)
- Roles: Owner / Admin / Member
- **Star Race → Team League conversion** (stars now feed Team Box — archetype-correct)
- Friend system (bundled with Teams)

### v10 — Guild Match phase (~6 months post-soft-launch)
- Football Rivals-style real-time guild-vs-guild drink-serve contest
- Requires Teams infrastructure stable first
- 48h match windows, weekly cycle

### Seasonal content drops (ongoing)
- Arenas 9–12
- Venue districts 4, 5, 6
- 5th album type (MM ships 5, MVP ships 4)
- Additional Bar Pass seasons
- Limited-time events (LTMs)
- Tournaments (entry + prize pool)

### Other post-MVP
- **Interstitial ads** (with FTUE protection + spender-exclusion rules TBD) — deferred v7.4 decision, 2026-04-23
- **Opt-in Ranked mode** (Clash Royale Path of Legends pattern) — deferred v7.4 decision, revisit if skill-expression becomes stated player need
- Whale SKU ladder ($49.99, $99.99)
- Subscription SKU (8BP Pool Pass pattern)
- Piggy bank / save-up SKU
- Return-player offer (win-back)
- Outfit / character customization depth (Expressionist layer)
- Photo / share mode
- Achievement / medal system
- Match replay / spectating
- Sticker trading (P2P)
- Premium+ / deluxe pass tier
- Post-cap prestige / seasonal trophy reset decision

---

## §17 — Tag distribution (projected after patch)

| Tag | v7.2 | v7.3 | Δ |
|---|---|---|---|
| 🟢 Aligned | 29 | 36 | +7 |
| 🟡 Hybrid | 4 | 3 | −1 |
| 🟣 Innovation (plugin) | 8 | 8 | 0 |
| 🔴 Innovation (archetype) | 0 | 0 | 0 |
| ⚫ Missing | 6 | 2 | −4 |
| ⏸ Paused (explicitly planned) | 4 | 9 | +5 |
| ⚠️ Problematic | 0 | 0 | 0 |
| ❓ Unknown | 4 | 3 | −1 |

**Closed this patch:** Weekly league + country leaderboard + global leaderboard + VIP ladder + profile showcase + arena count gap + Star Meter archetype divergence + Venue scope + album transparency + offer transparency.

**Still missing (pre-soft-launch):** FTUE (v7.4), rewarded video (v7.5 tech).

---

## §18 — Verification disclosures

Per Verification Gates. Items requiring in-client screenshot capture before final art / copy direction:

1. **8 Ball Pool VIP exact tier thresholds** — Miniclip Support confirms 6-tier Bronze → Black Diamond structure, but precise point thresholds returned 403 on direct fetch. Mix-It's 10-tier math uses generic casual-PvP benchmark ranges. Capture 8BP VIP screen before finalizing.
2. **MM album reward UI preview pattern** — reward existence confirmed (per-page + full-album), **UI affordance (whether rewards are previewed upfront) unverified**. Capture MM album screen.
3. **MM opponent-avatar tap behavior** — profile access pattern unverified. Capture MM post-match screen interaction.
4. **MM country leaderboard** — no verified evidence MM ships country leaderboards. Mix-It aligns with 8BP/CR pattern, not MM.
5. ~~Cocktail Lounge trophy gate — 1,300 vs 1,000~~ **RESOLVED (v7.4 Q4, 2026-04-23):** 1,000 trophies, flattened curve.

Items flagged `[invented]` in appendix tables:
- Cosmetic coin-equivalent values (frames, skins) in bundle-value math
- Sticker pack coin-equivalents (Silver Pack ≈ 500c, Gold Pack ≈ 1,500c baseline) — finalize when booster/sticker shop pricing lands

---

## §19 — Open questions for v7.4

1. Target session length + sessions/day (explicit KPI)
2. Target D1 / D7 / D30 retention
3. Target ARPDAU / ARPPU / conversion %
4. Platform decision (iOS first? both?)
5. Full FTUE spec (Match 1 forced-win, bot WR curve, sequential unlocks, starter rewards)
6. Interstitial ad decision (ship y/n)
7. Matchmaking algorithm (ELO-like? trophy-only? bot-fallback threshold?)
8. Reconnection / anti-cheat baseline
9. Final tuning pass on all §15 appendix values
10. Bar Pass XP curve per tier (source of XP, amount needed, milestone rewards)
11. Arena promotion chest exact contents per tier
12. Daily Chest exact contents
13. Shop section A/B/C/D/F full SKU list + price ladder
14. Home UI mockup after §14 reshuffle (art direction)

---

## Sources

- [Naavik — Match Masters deconstruction (2023-05)](https://naavik.co/deep-dives/match-masters-deconstruction/) — ante verification, star usage
- [Candivore Zendesk — Stars](https://candivore.zendesk.com/hc/en-us/articles/360019600139-Stars) — star earning rules
- [allloot — Match Masters Teams Guide](https://allloot.com/match-masters-teams/) — teams structure
- [simplegameguide — Match Masters Teams Guide](https://simplegameguide.com/match-masters-teams-guide/) — teams mechanics
- [8 Ball Pool Fandom — Clubs](https://8ballpool.fandom.com/wiki/Clubs) — clubs archetype
- [Miniclip — VIP Points (8BP)](https://support.miniclip.com/hc/en-us/articles/360000639967-VIP-Points-8-Ball-Pool) — VIP 6-tier structure
- [Miniclip — VIP Level Multipliers](https://support.miniclip.com/hc/en-us/articles/360017470114--VIP-Level-Multipliers-in-Promotions-and-Minigames) — VIP perk pattern
- [Miniclip — Leaderboards (8BP)](https://support.miniclip.com/hc/en-us/articles/204975658-Leaderboards-8-Ball-Pool) — country leaderboard precedent
- [Supercell Support — Ranked (Clash Royale)](https://support.supercell.com/clash-royale/en/articles/ranked-2.html) — country leaderboard + season reset
- [RoyaleAPI — Global Leaderboard](https://royaleapi.com/players/leaderboard?lang=en) — top-1000 vanity pattern
- [RoyaleAPI — Country Info on Leaderboards](https://royaleapi.com/blog/leaderboard-player-country?lang=en)
- [Clash Royale Fandom — Player Profile](https://clashroyale.fandom.com/wiki/Player_Profile) — profile showcase content pattern
- [Miniclip — Cue Collection Power](https://support.miniclip.com/hc/en-us/articles/360011839377--Cue-Collection-Power-Frequently-Asked-Questions) — 8BP profile showcase
- [Supercell — Shop Offers / Info](https://support.supercell.com/clash-royale/en/articles/shop-offers.html) — offer transparency genre standard
- [Miniclip — Pool Pass Guide](https://support.miniclip.com/hc/en-us/articles/360036840073--Pool-Pass-Elite-Pass-Your-Ultimate-Guide-8-Ball-Pool) — pass itemization pattern
- [MatchMastersCoin — Stickers Guide](https://matchmasterscoin.com/match-masters-stickers/) — MM album completion rewards
- [SimpleGameGuide — MM Free Gifts](https://simplegameguide.com/match-masters-daily-free-gifts/) — MM per-page reward confirmation

---

**End of v7.3 patch.**
