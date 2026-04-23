# Mix-It Design Patch v7.4 — FTUE + Tuning Pass

**Patch date:** 2026-04-23
**Applies to:** v7.3.1-patch-economy-correction (2026-04-23)
**Purpose:** Lock FTUE design, bot cushion curve, post-FTUE matchmaking, and final tuning tables. Propagate v7.3 drift cleanup after flattened-curve decision. Ship account/username/privacy minimal spec.

**Scope:** Design specs + tuning numbers. No tech implementation. Soft-launch target is post-v7.5 (ads + pre-launch polish).

---

## Patch scope

### ✅ Decisions locked this patch
- §1 Session + retention targets (Q1, Q2)
- §2 Matchmaking algorithm — trophy-only, MM-faithful (Q3, revised from earlier hybrid to archetype-aligned)
- §3 Flattened trophy curve (Q4, Cocktail at 1,000 preserved)
- §4 Bonus Bank post-Pass-completion (Q5, Royal Match pattern)
- §5 Profile showcase free for all (Q6 correction, matches MM/8BP/CR)
- §6 No trophy reset (Q7, MM-pattern)
- §7 FTUE final structure — 2 solo puzzles + 4 bot matches, combo not taught (Q8)
- §8 M4→M5 scripted stake-pressure moment (new systems spec)
- §9 Bot WR cushion curve — arena-tied 70/65/60/55/52% (Q9)
- §10 Post-FTUE bot-fill rules (new systems spec)
- §11 `star_source` migration hook (new systems spec, future-proofs v9 Teams)
- §12 Account / Username / Privacy minimal spec (new)
- §13 Interstitials deferred to post-MVP (Q10)
- §14 Ranked mode deferred to post-MVP (Q3 aftermath)
- §15 Full tuning tables — Trophy Road re-pace, Venue Token pacing, arena promotion chests, Daily Chest, Shop SKUs, VIP curve validation, Obsidian whale ceiling check

### ⏭ Deferred to v7.5 (final pre-launch polish)
- Rewarded video integration (2 placements from v7.3 scope — tech dependency)
- Coin bundle IAP pricing localization + platform-specific SKUs
- Final art direction for Home UI reshuffle (v7.3 §14)
- Reconnection / anti-cheat baseline

### ⏸ Deferred post-MVP
- Interstitial ads (with FTUE protection + spender-exclusion rules TBD)
- Opt-in Ranked mode (Clash Royale Path of Legends pattern)
- Real Teams system (v9), Guild Match (v10), LTMs, tournaments, subscription, whale SKU ladder, country leaderboards beyond arena (see v7.3 §16)
- MM/8BP in-client screenshot captures (v7.3 §18 verification items)

---

## §1 — Session + retention targets

### Session target (Q1 lock)
- **Session length:** 4–5 minutes
- **Sessions per day:** 4–5
- **Matches per day (engaged):** ~15
- **Pattern:** quick-burst (MM / Clash Royale shape)
- **Implication:** plugin's high cognitive load is absorbed by short sessions; Venue/Profile/Ranking must reward glance-engagement, not deep dwell

### Retention targets (Q2 lock — two-gate soft-launch)

| Gate | D1 | D7 | D30 | Action |
|---|---|---|---|---|
| **Minimum viable** | 40% | 18% | 8% | Continue development, investigate weak spots |
| **Go-to-scale (primary target)** | **45%** | **23%** | **12%** | Match Masters tier; green light paid UA |
| Stretch | 50% | 28% | 15% | Top 1%; unexpected upside |

Benchmarks: GameRefinery 2023–2024, Naavik 2022–2024 deconstructions, AppMagic public data (casual PvP arena genre).

---

## §2 — Matchmaking: trophy-only, MM-faithful (Q3 revised)

Earlier v7.4 Q&A tentatively locked Option C (trophy band + hidden WR sort). Subsequent archetype verification (2026-04-23) showed:

- **MM 2026:** trophy-only ([Candivore Zendesk](https://candivore.zendesk.com/hc/en-us/articles/360019633059-Trophies), [Naavik 2023](https://naavik.co/deep-dives/match-masters-deconstruction/))
- **Clash Royale Trophy Road:** trophy + King Level hybrid (NOT hidden WR) ([Supercell 2021-02](https://supercell.com/en/games/clashroyale/blog/news/matchmaking-changes/))
- **Clash Royale Path of Legends:** separate ranked mode with visible league ladder
- **8 Ball Pool:** coin bracket + hidden "Strength" rating (band = coin entry fee, not trophies)

**Pure trophy band + hidden WR is used by zero verified reference games.** Original Option C was archetype innovation (🔴). Corrected to **Option A — trophy-only** (MM-faithful).

**Ranked mode (CR Path of Legends pattern) deferred to post-MVP** — revisit if skill-expression becomes a stated player need after soft-launch.

---

## §3 — Flattened trophy curve (Q4 resolution)

Earlier v7.4 Q&A tentatively picked 1.5× multiplicative curve with Cocktail at 1,300. Follow-up math showed this added ~29 days of pre-stake grind for F2P engaged at the Arena 4 cushion WR. Reverted to **1,000-at-Cocktail flattened curve**:

| # | Arena | Trophy gate | Stakes | Booster roster (cum) | Promotion chest |
|---|---|---:|---|---:|---|
| 1 | Juice Stand | 0 | ×1 | 2 | Wood |
| 2 | Smoothie Bar | 150 | ×1 | 3 | Wood+ |
| 3 | Coffee House | 400 | ×1 | 4 | Bronze |
| 4 | Tea Garden | 700 | ×1 | 5 | Bronze+ |
| 5 | **Cocktail Lounge** | **1,000** | **×1/×2/×3/×4** | 6 | Silver |
| 6 | Wine Cellar | 1,500 | ×1–×4 | 7 | Silver+ |
| 7 | Champagne Room | 2,200 | ×1–×4 | 8 | Gold |
| 8 | Grand Hotel | 3,200 | ×1–×4 (×5 post-MVP) | 8 (cap) | Gold+ |

Trophy ceiling: 4,500 (Trophy Road extends past Arena 8).

---

## §4 — Bonus Bank: post-Pass-completion hook (Q5)

Royal Match pattern ([Dream Games Helpshift](https://dreamgames.helpshift.com/hc/en/3-royal-match/faq/112-royal-pass/)).

- After completing tier 30 of Bar Pass, additional **400 BPP = 100 coins banked**
- **Hard cap: 5,000 coins per season** (~10% of Pass Premium total value from v7.3 §15.I)
- Resets with season on 1st of month
- Bonus Bank coin payout animates as "Bank" pool filling, separate from main Pass tier UI

Whales who finish Pass in ~15 days (per v7.3.1 BPP curve) now have a 15-day trailing coin drip capped at 5,000c. Prevents economy leak while protecting whale engagement for the back half of each season.

---

## §5 — Profile Showcase: free for everyone (Q6 correction)

v7.3 §11 had gated the Favorite-3 Stickers showcase slot behind Diamond VIP (~$1,200 lifetime). Archetype verification showed all three primary references give profile self-expression free:

- Match Masters: character outfit (earned via albums)
- 8 Ball Pool: equipped cue + stats
- Clash Royale: favorite card

**Change:** Favorite-3 Stickers showcase unlocks free for all players once they have 3 stickers of any rarity. Diamond VIP loses nothing material — still has weekly free Gold Pack, legendary frame, and the Obsidian leaderboard name highlight remains the whale status signal.

v7.3 §11 updated to remove Diamond gating on showcase.

---

## §6 — No trophy reset (Q7)

MM pattern — trophies persist across seasons. Monthly re-race is already served by:
- Star Race (§4 of v7.3)
- Arena Leaderboard (monthly reset, v7.3 §9)
- Country Leaderboard (monthly reset, v7.3 §9)
- Global Leaderboard (monthly reset, v7.3 §9)
- Bar Pass (30-day season)

Layering a trophy reset on top would make climb feel Sisyphean for mid-core players. Lifetime trophy progression preserved as King-of-the-Hill motivation.

---

## §7 — FTUE final structure (Q8 + FTUE reward validation)

### Principle
Progressive mechanic drip (CR + Royal Match pattern). Minimal coach-markers. Royal Match cushion model adapted for PvP. Combo NOT taught explicitly — emerges as ambient juice.

### Sequence

| # | Format | Mechanics introduced | Reward | Duration | Completion | Forced popups |
|---|---|---|---|---|---|---|
| **M1** | Solo puzzle A | Pour, Fill, Serve, Color Spawn. No timer, no opponent. | **100 coins** | ~90s | Auto-pass on correct solve; fail → auto-retry with hint | Welcome overlay pre-match; solve celebration post-match |
| **M2** | Solo puzzle B | **Customer patience timer** (20s) introduced | **200 coins + avatar frame "Apprentice Bartender"** | ~75s | Auto-pass; timer-out → retry with timer paused + tutorial callout | Patience-timer overlay pre-match |
| **M3** | Easy bot (cushion ~30–40% bot WR) | Full plugin live; **first-serve competition** emerges organically from shared queue | **600 coins + 1 Bronze booster + Starter Chest (Lucky Box 50% pre-fill, coin component only, doesn't stack with M3-earned progress)** | ~90s | Standard match end; loss allowed, framed "good match, keep going" | Post-match Trophy Road reveal popup (first milestone #1 claimed = 50 trophies) |
| **M4** | Easy bot (cushion WR ~70%) | Standard PvP framing; no new mechanics — consolidation match | Standard match coin + trophies | ~90s | Standard | Post-match: §8 stake-teaser popup |
| **M5** | **Scripted ×2 stake match** (bot tuned ~65% player WR) | **Stake multiplier** introduced; free Silver booster equipped as stake | ×2 coin + trophy on win; replacement booster grant on loss | ~90s | Win or loss both resolve cleanly; rage-quit = loss path | Pre: stake tutorial overlay. Post: result cascade. Post-post: Starter Pack $2.99 popup |
| **M6+** | Real PvP with cushion (per §10) | Real opponents + bot fallback; arena-tied cushion WR curve kicks in (70% Arena 1, 65% Arena 2, ...) | Standard match rewards | ~90s | Standard | None — FTUE ends |

### Post-M3 first album screen discovery
- Natural flow via Trophy Road milestone #1 → player visits album screen
- First-time-view of album triggers: **1 Welcome Silver Sticker Pack + 1 Sticker Token** drop
- Introduces stickers + Sticker Token mechanic (v7.3.1 §7 F2P supply valve)
- NO Gold pack — preserves "Gold is aspirational" semantics

### Day-1 coin projection
- FTUE rewards: ~900c coin-equivalent
- Post-M3 album pack: ~500c (Silver)
- First real PvP matches (4–5 × Arena 1 base × 70% WR): ~70c
- First Lucky Box claim (pre-filled 50%): ~50c
- Daily Missions if completed session 1: ~600c
- **Total: ~1,700c on Day 1** = 1.25× F2P casual daily ceiling → retention-hook appropriate (validated by economy agent 2026-04-23)

### FTUE reward principle (locked for v7.4+)
> **FTUE rewards must be items the player has seen or used within the last 30 seconds of gameplay, or immediately visible on the screen they return to.**
>
> No mystery rewards. No collection items before the collection system is visible. No VIP/boosters/stakes before those mechanics exist.

### Starter Pack trigger
- Post-M5 (after scripted stake match resolves) OR D1 return, whichever first
- Contents per v7.3.1 §15.F
- Red-dot persists on Shop for 24h after dismissal

---

## §8 — M4→M5 scripted stake-pressure moment (new systems spec)

### Intent
Place the Starter Pack trigger on real tension, not a hypothetical. M5 is a scripted ×2 stake match with a free booster — teaches stake UI, delivers the win/loss cascade, primes the $2.99 pack on the follow-up screen.

### M4 end state
- Standard Easy-bot match resolves; player returns to Home
- Popup (blocking, single CTA): **"Ready to raise the stakes? Stake a booster for ×2 rewards on your next match."**
- Red-dot pulse on Play button until M5 starts

### M5 pre-match
- Tutorial overlay (skippable after 1st view; NOT skippable in FTUE): animated explainer on ×2 stake — doubled coins + doubled trophies, booster at risk if you lose
- **Free Silver booster granted and auto-equipped as the stake**
- Stake multiplier locked to ×2 for this tutorial match (higher stakes not available regardless of unlock state)
- "Enter Match" CTA; no opt-out of the stake

### M5 match
- Plays as normal PvP-framed (vs cushion bot from §10)
- Persistent ×2 STAKE badge in match HUD — pulsing on first appearance
- Bot tuned to ~65% player WR specifically — majority experiences win cascade, minority sees loss cascade. Both outcomes are designed.

### M5 result

**Win (~65% of players):**
- Result screen with ×2 multiplier called out: "×2 STAKE — DOUBLED REWARDS"
- Coin + trophy pills count up with ×2 burst animation
- Booster card shows "KEPT" stamp, animates back into inventory

**Loss (~35% of players):**
- Result screen shows "LOST STAKE" animation; Silver booster card animates out of inventory (desaturate + fade)
- **Replacement grant popup follows immediately** (blocking):
  - Copy: "That was your tutorial — here's a free booster. Now go play for real."
  - New Silver booster animates into the empty slot
- No scolding, no "you failed" framing — tone is "lesson learned, here's your tool back"

### Post-M5 (both outcomes)
- Starter Pack ($2.99) popup triggers after result/replacement flow fully resolves and player is back on Home
- Dismiss → red-dot persists on Shop for 24h

### Edge cases
- **Rage-quit mid-match:** treat as loss. Grant replacement on next Home load
- **Already owns Starter Pack:** still run scripted M5 match; skip post-M5 Starter Pack popup
- **Crash / disconnect before result:** re-enter from server state; if no state, replay with `m5_redo` flag; on second failure, treat as win (fail-soft — never punish tutorial on client bug)

### Tracking events
- `m4_stake_teaser_shown`
- `m5_stake_tutorial_shown`
- `m5_stake_tutorial_booster_granted`
- `m5_stake_outcome` (win / loss)
- `m5_replacement_booster_granted` (loss path only)
- `m5_ragequit` (boolean)
- `starter_pack_shown_post_m5`
- `starter_pack_purchased_post_m5` (24h attribution window)

---

## §9 — Bot WR cushion curve (Q9)

### Target player win rates per arena

| Arena | Target WR | Rationale |
|---|---|---|
| 1 Juice Stand | **70%** | Heavy cushion — FTUE-adjacent retention |
| 2 Smoothie Bar | **65%** | Step-down, still generous |
| 3 Coffee House | **60%** | Balanced for continued progression |
| 4 Tea Garden | **55%** | Slight positive tilt, net-positive trophies |
| 5 Cocktail Lounge (stakes unlock) | **52%** | Cushion fades; normal MM |
| 6–8 | **52%** | Normal MM continues |

Solves v7.3.1 trophy-math concern (F2P casual at 50% WR goes negative pre-Cocktail). All 4 pre-stake arenas net-positive trophy gain with this curve.

Cushion implementation details in §10.

---

## §10 — Post-FTUE bot-fill rules (new systems spec)

### Trophy-band matchmaking
| Arena | Band width |
|---|---|
| 1 Juice Stand, 2 Smoothie Bar | ±80 trophies |
| 3 Coffee House, 4 Tea Garden, 5 Cocktail Lounge | ±150 trophies |
| 6 Wine Cellar, 7 Champagne Room, 8 Grand Hotel | ±200 trophies |

Symmetric bands around searching player. No ELO layer at MVP.

### Queue wait → bot fallback
- **15s threshold.** At 15s queue returns bot with surface trophy count sampled from player's trophy band
- Pre-15s: real opponent preferred
- Band widens +50% at 10s as soft expansion before bot-fill
- Bot-fill fires silently — no "matching with bot" indicator

### Cushion mechanism (Arenas 1–4)
- Bot pool tagged with scripted skill level (1–5)
- In cushion arenas, sampler weighted toward lower-skill bots → observed aggregate WR converges on §9 target
- Real-opponent matches included in aggregate — sampler self-corrects
- Personal WR rolling window: last 20 matches. If player drops >10pp below arena target for 10+ matches, sampler nudges bot skill one step lower until recovery.

### Cushion fade
- Crossing into Arena 5 (Cocktail, 1,000 trophies) exits cushion pool permanently
- Demotion back below 1,000 does NOT re-enable cushion
- Post-cushion bot pool is skill-uniform; aggregate ~52% WR

### Star Race integrity
- **Stars earned vs bots do NOT count toward Star Race leaderboard** (v7.3 §4 rule)
- Stars vs bots DO count toward Weekly Missions "Earn Stars" target (activity, not competition)
- Server-side filter on `match.opponent_type = bot` at leaderboard aggregation
- Trophy gains/losses vs bots apply normally

### Bot transparency
- **Bots are NOT revealed as bots in client UI.** Full player-like profiles: avatar, frame, country flag, VIP tier badge (from generator pool), coherent username
- Integrity protected by Star Race exclusion + trophy-band sampling
- Internal telemetry: `opponent_type` logged per match for auditing; not exposed

### Star Race gate (FTUE UX protection)
- Star Race leaderboard UI hidden until player reaches Arena 3 (400 trophies)
- Before gate: Ranking button shows Arena + Country + Global tabs; Star Race greyed with "Unlocks at Arena 3" copy
- Rationale: empty/cold leaderboard in FTUE kills aspirational framing
- First unlock triggers one-shot popup: "Star Race is live — compete this week in Coffee House"

---

## §11 — `star_source` migration hook (new systems spec)

Future-proofs v9 Teams conversion of Star Race to Team Box.

### Enum definition
```
enum star_source {
  SOLO_WEEKLY       // MVP — feeds solo Star Race leaderboard
  TEAM_BOX          // v9 — shared team container (reserved)
  EVENT_STAR_RACE   // v9+ — LTM/seasonal events (reserved)
}
```

MVP grants all stars with `SOLO_WEEKLY`. Writer path is a single constant; no branching ships.

### MVP schema
- Table `match_star_grants`: `(grant_id, player_id, match_id, stars_earned, star_source, arena_at_grant, week_bucket, created_at)`
- Table `star_race_weekly_totals`: materialized per `(player_id, arena, week_bucket)` filtered `WHERE star_source = SOLO_WEEKLY`
- No `team_id` column at MVP. Added in v9 as nullable; MVP rows stay NULL.

### Backward-compat rule (critical)
**Stars granted with `SOLO_WEEKLY` keep that value for life.** v9 does NOT rewrite historical rows.

- Stars earned during current Star Race week at v9 ship time stay `SOLO_WEEKLY` and complete that week normally
- First post-v9 Monday reset starts granting `TEAM_BOX` (if player in a team) or `SOLO_WEEKLY`
- No retroactive Team Box backfill — stars earned pre-team-join have no team to credit

### v9 migration plan — clean flush
- Chosen: clean flush. Pending SOLO_WEEKLY stars pay out via existing Star Race on post-v9 Monday reset, then writer switches
- Rejected: dual-credit (over-rewards migration cohort)
- Rejected: retroactive backfill (audit confusion)

### Team Box spec outline (v9 stub)
- Shared container; teammate `TEAM_BOX` stars sum into weekly bar
- Reset: weekly, Monday 00:00 UTC (matches MM team-box pattern)
- Tiered (Bronze/Silver/Gold thresholds); opens at reset; contents distributed equally to members contributing ≥1 star
- Star contribution visible on team roster (anti-freeloader transparency)
- Team Star Race (team-vs-team weekly board) uses `EVENT_STAR_RACE` — separate faucet, co-exists

### Schema impact matrix
| Change | MVP | v9 |
|---|---|---|
| `match_star_grants.star_source` enum | ships with SOLO_WEEKLY only | values activated via feature flag |
| `match_star_grants.team_id` nullable | — | added; MVP rows stay NULL |
| `team_box_weekly` aggregate | — | new |
| `star_race_weekly_totals` query filter | `WHERE source = SOLO_WEEKLY` | unchanged |
| Writer path | single constant | branches on `player.team_id IS NULL` |

---

## §12 — Account / Username / Privacy minimal spec (new)

### First-launch flow
1. Splash → EULA/Privacy accept (regional copy)
2. **Username prompt:**
   - Auto-generated suggestion: `[RoleNoun]_[4-digit]` pattern (e.g., "Bartender_3481", "Mixologist_7204"). Pool ~40 role nouns.
   - "Use this name" primary CTA
   - "Change" secondary → text input, 3–16 chars alphanumeric + underscore, profanity filter (client blocklist + server re-check)
   - Server auto-appends `_[4-digit]` suffix on collision — eliminates "name taken" friction
3. Avatar = default starter (Trophy Road #1 unlocks first real avatar)
4. Country = device locale (read-only at MVP per v7.3 §9)
5. Enter M1

No email. No password. No social auth. No age gate beyond platform store.

### Username lock
- Locked after setup. Mid-game rename blocked in-client.
- Rationale: anti-impersonation + leaderboard integrity + moderation cost
- Escape hatch: one-time rename via customer support (post-MVP tool; MVP = manual DB edit on written request)

### Account / save model
- **Device-bound save at MVP.** Local + cloud-mirrored PlayerID at first launch.
- Player ID shown in Profile → Settings → Account: copyable string with warning "Save this — it's your only recovery key before accounts ship."
- **Restore from PlayerID flow:** clean-install → "I already have an account" → paste PlayerID → server validates + returns save if not claimed. Single-device-at-a-time: restoring revokes previous device session (explicit confirmation).
- **No account linking** (Apple/Google/Facebook) at MVP. Deferred to post-MVP platform auth pass.

### Email capture — single channel only
- Email NOT collected at install
- Email collected via Teams stub "Notify me" opt-in (v7.3 §8) — push permission requested first; email field fallback only if push denied
- Marketing consent flag explicit, regional (GDPR/CCPA). Stored separately from gameplay data.

### Privacy / moderation at MVP
- No free-text bio, no DM, no friend-add (v7.3 §11 rules)
- Report button on every public profile → server-side flag queue → manual review (low volume expected at soft-launch scale)
- Profanity filter: client blocklist + server re-check on name creation and report triggers
- Chat NOT present at MVP (Teams stub only) → no chat moderation infrastructure needed

### Post-MVP deferrals (explicit)
- Apple/Google/Facebook account linking (cross-device, loss recovery)
- Self-serve rename (once per N months, coin-cost or VIP-gated)
- Bio/status field with moderation pipeline
- Friend system (bundles with Teams v9 per v7.3 §16)

---

## §13 — Interstitial ads: deferred to post-MVP (Q10)

Rationale: protect retention measurement at soft-launch. Interstitials add UX friction that depresses session quality and can mask real retention signal. Rewarded video (tech-deferred to v7.5) is the prioritized ad format because it's opt-in.

Post-MVP implementation notes (for whenever interstitials ship):
- **FTUE protection:** no interstitials in first 3 days OR first 20 matches (whichever later)
- **Spender exclusion:** no interstitials for players with any IAP in last 30 days (rewards payers with cleaner UX)
- **Frequency:** every 4th match-end for eligible players
- **Skippable after 5s**

---

## §14 — Ranked mode: deferred to post-MVP

Original v7.4 Q3 discussion raised Clash Royale split-ladder pattern (trophy-only casual + opt-in Ranked mode). MVP ships trophy-only only (MM-faithful).

Post-MVP revisit if skill-expression becomes a stated player need after soft-launch. CR Path of Legends is the reference pattern ([Supercell Support](https://support.supercell.com/clash-royale/en/articles/path-of-legends-3.html)).

---

## §15 — Tuning tables (from economy agent 2026-04-23)

### §15.A — Trophy Road — 25 milestones (flattened curve re-pace)

Stakes unlock at #7/1,000. Arena skins tied to arena-gate milestones (#2, #4, #6, #7, #10, #14, #19).

| # | Trophy | Δ prev | Reward | Type |
|---:|---:|---:|---|---|
| 1 | 50 | +50 | 200c | Coin |
| 2 | 150 | +100 | Booster unlock: Pour-Back + Smoothie Bar arena skin | Cosmetic+Booster |
| 3 | 250 | +100 | 1 Silver Sticker Pack | Sticker |
| 4 | 400 | +150 | 500c + Booster unlock: Extra Tube + Coffee House arena skin | Coin+Booster+Cosmetic |
| 5 | 550 | +150 | Avatar frame "Barista" | Cosmetic |
| 6 | 700 | +150 | 800c + Booster unlock: Color Swap + Tea Garden arena skin | Coin+Booster+Cosmetic |
| 7 | 1,000 | +300 | **Stakes ×2/×3/×4 unlock** + Cocktail Lounge arena skin + 1,000c | Unlock+Coin+Cosmetic |
| 8 | 1,150 | +150 | Booster: Undo ×3 + 1 Silver Pack | Booster+Sticker |
| 9 | 1,300 | +150 | 1 Gold Sticker Pack | Sticker |
| 10 | 1,500 | +200 | 1,200c + Booster: Freeze Timer + Wine Cellar arena skin | Coin+Booster+Cosmetic |
| 11 | 1,700 | +200 | Emote pack "Mixologist" | Cosmetic |
| 12 | 1,900 | +200 | 1,500c + 1 Silver Pack | Coin+Sticker |
| 13 | 2,100 | +200 | Booster: Hint+ | Booster |
| 14 | 2,200 | +100 | 1 Gold Sticker Pack + Champagne Room arena skin | Sticker+Cosmetic |
| 15 | 2,400 | +200 | 2,000c | Coin |
| 16 | 2,600 | +200 | Profile frame "Sommelier" | Cosmetic |
| 17 | 2,850 | +250 | 2,500c + Booster: Auto-Sort | Coin+Booster |
| 18 | 3,050 | +200 | 1 Gold Sticker Pack | Sticker |
| 19 | 3,200 | +150 | **Grand Hotel entry bonus: 4,000c + exclusive frame "Concierge"** | Coin+Cosmetic |
| 20 | 3,500 | +300 | Emote pack "Grand" | Cosmetic |
| 21 | 3,750 | +250 | 1 Gold Sticker Pack | Sticker |
| 22 | 4,000 | +250 | 3,000c + 1 Silver Pack | Coin+Sticker |
| 23 | 4,250 | +250 | Legendary avatar frame | Cosmetic |
| 24 | 4,400 | +150 | 2 Gold Sticker Packs | Sticker |
| 25 | 4,500 | +100 | 7,500c + seasonal cosmetic bundle (ceiling reward) | Coin+Cosmetic |

Total Trophy Road coins: ~26,000c (amortized ~100c/day casual pace).

### §15.B — Venue Token pacing (flattened curve)

Wins-to-promote using §9 cushion WR curve and ±30 trophy swing/match. Net trophies/win at WR w: `30 × (2w−1)`.

| Arena | WR | Net 🏆/win | Trophy span | Wins to clear |
|---|---:|---:|---:|---:|
| 1 | 70% | +12.0 | 0→150 | ~13 |
| 2 | 65% | +9.0 | 150→400 | ~28 |
| 3 | 60% | +6.0 | 400→700 | ~50 |
| 4 | 55% | +3.0 | 700→1,000 | ~100 |
| 5 | 52% | +1.2 | 1,000→1,500 | ~417 |
| 6 | 52% | +1.2 | 1,500→2,200 | ~583 |
| 7 | 52% | +1.2 | 2,200→3,200 | ~833 |

District pacing (targets: 70% completion at promotion):

| District | Arenas | Trophy span | Wins to promote | Base tokens/win | Avg stake mult | Tokens/win eff. | Tokens earned |
|---|---|---|---:|---:|---:|---:|---:|
| 1 Café Row | 1–3 | 0→700 | ~91 | 1.0 | ×1.0 pre-stake | 1.0 | ~91 |
| 2 Boulevard | 4–5 | 700→1,500 | ~517 | 0.3 | ×1.8 avg 2-stake | 0.54 | ~280 |
| 3 Uptown | 6–8 | 1,500→3,200 | ~1,416 | 0.1 | ×2.2 avg 2–3 stake | 0.22 | ~311 |

### §15.C — Building cost per district-level

So district completion aligns with 70% target:

| District | L1 | L2 | L3 | Per building | District total (10 buildings) |
|---|---:|---:|---:|---:|---:|
| 1 Café Row | 2 | 4 | 6 | 12 | 120 |
| 2 Boulevard | 6 | 12 | 18 | 36 | 360 |
| 3 Uptown | 10 | 20 | 30 | 60 | 600 |

70% target check: D1 70%≈84 tokens (earn ~91 ✓), D2 70%≈252 (earn ~280 ✓), D3 70%≈420 (earn ~311 — slightly under, intended as post-Arena-8 endgame tail).

Soft cap 200 Venue Tokens preserved from v7.3.1 §8; overflow converts 5 Venue Tokens → 1 Sticker Shard.

### §15.D — Arena promotion chest contents

One-time grant on first promotion into each arena. Sticker Pack coin-equivalents: Silver 500c, Gold 1,500c.

| # | Arena | Tier | Coins | Silver | Gold | Boosters | Coin-equiv |
|---|---|---|---:|---:|---:|---|---:|
| 1 | Juice Stand | Wood | 300 | 1 | — | 2 Bronze | ~900 |
| 2 | Smoothie Bar | Wood+ | 500 | 2 | — | 3 Bronze + 1 Silver | ~1,650 |
| 3 | Coffee House | Bronze | 700 | 2 | 1 | 3 Silver | ~3,400 |
| 4 | Tea Garden | Bronze+ | 1,000 | 3 | 1 | 4 Silver | ~4,500 |
| 5 | Cocktail Lounge | Silver | 1,500 | 3 | 2 | 2 Silver + 2 Gold | ~6,300 |
| 6 | Wine Cellar | Silver+ | 2,000 | 2 | 3 | 3 Gold | ~8,700 |
| 7 | Champagne Room | Gold | 2,500 | — | 4 | 4 Gold | ~11,000 |
| 8 | Grand Hotel | Gold+ | 3,000 | — | 5 | 5 Gold + 1 Diamond-equiv | ~13,500 |

### §15.E — Daily Chest contents (3/3 Daily Missions)

Scales with current arena.

| Arena | Coins | Silver | Gold | Sticker Token | Booster | Coin-equiv |
|---|---:|---:|---:|---:|---|---:|
| 1 Juice Stand | 300 | 1 | — | — | 1 Bronze mixed | ~900 |
| 2 Smoothie Bar | 400 | 1 | — | — | 1 Bronze mixed | ~1,000 |
| 3 Coffee House | 500 | 1 | — | 10% | 1 Silver mixed | ~1,150 |
| 4 Tea Garden | 700 | 1 | — | 15% | 1 Silver mixed | ~1,350 |
| 5 Cocktail Lounge | 900 | 1 | — | 25% | 1 Silver mixed | ~1,600 |
| 6 Wine Cellar | 1,100 | — | 1 | 33% | 2 Silver mixed | ~2,800 |
| 7 Champagne Room | 1,300 | — | 1 | 50% | 2 Silver mixed | ~3,000 |
| 8 Grand Hotel | 1,500 | — | 1 | 50% | 1 Gold mixed | ~3,400 |

### §15.F — Shop: Section A (Booster Shop)

Per-unit prices per v7.3.1 §9 unchanged. Quantity bundles ≤25% discount (stake losses must sting).

| SKU | Price (c) | Per-unit | Discount |
|---|---:|---:|---:|
| 1 Bronze | 50 | 50 | — |
| 5 Bronze bundle | 225 | 45 | 10% |
| 1 Silver | 150 | 150 | — |
| 5 Silver bundle | 650 | 130 | 13% |
| 1 Gold | 400 | 400 | — |
| 3 Gold bundle | 1,100 | 367 | 8% |
| 10 Gold bundle | 3,500 | 350 | 12.5% |
| Mixed "Shaker" (2B + 2S + 1G) | 750 | — | ~9% |

### §15.G — Shop: Section B (Coin Packs, $ ladder)

MVP ceiling $19.99. Coins-per-$ escalates toward top.

| SKU | Price | Base coins | Bonus % | Total coins | Coins/$ | VIP pts |
|---|---:|---:|---:|---:|---:|---:|
| Pocket | $0.99 | 1,000 | 0% | 1,000 | 1,010 | 99 |
| Handful | $2.99 | 3,200 | +7% | 3,424 | 1,145 | 299 |
| Stack | $4.99 | 5,600 | +12% | 6,272 | 1,257 | 499 |
| Pile | $9.99 | 11,500 | +20% | 13,800 | 1,381 | 999 |
| Vault | $19.99 | 23,000 | +35% | 31,050 | 1,554 | 1,999 |

### §15.H — Shop: Section C (Bundles)

| SKU | Price | Coins | Silver | Gold | Boosters | Cosmetic | Displayed value | Multiplier |
|---|---:|---:|---:|---:|---|---|---:|---:|
| Happy Hour | $4.99 | 4,500 | 3 | 1 | 5 Silver mixed | — | ~8,250c | 3.3× vs Stack |
| Mixologist | $9.99 | 9,000 | 3 | 3 | 3 Gold + 5 Silver | seasonal frame | ~19,500c | 3.5× vs Pile |
| Grand Service | $19.99 | 18,000 | 4 | 6 | 10 Gold + 5 Silver | exclusive emote + frame | ~39,000c | 3.9× vs Vault |

### §15.I — Shop: Section D (Pass Premium)

- Price: $9.99 (locked from v7.3 §15.I)
- BPP curve: 400 flat per tier × 30 tiers = 12,000 BPP (per v7.3.1 §6)
- Tier-sample rewards per v7.3 §15.I unchanged
- Catch-up SKUs: $0.99 / 3 tiers, $4.99 / 15 tiers, cap T28 (v7.3 §15.J)
- Bonus Bank post-tier-30: 400 BPP → 100c, cap 5,000c/season (§4)

### §15.J — Shop: Section F (Sticker Pack SKUs)

Shop prices at-cost (no markup) to preserve bundle value by comparison.

| SKU | Shop price (c) | Coin-equiv | Markup |
|---|---:|---:|---:|
| Silver Sticker Pack | 500 | 500 | 0% |
| Gold Sticker Pack | 1,500 | 1,500 | 0% |
| Silver ×5 bundle | 2,250 | 2,500 | −10% |
| Gold ×3 bundle | 4,200 | 4,500 | −7% |
| Daily deal Silver (1/day) | 300 | 500 | −40% (FOMO) |

### §15.K — VIP point curve validation (no dead zones)

| Tier | Name | Pts req | ≈$ | Reachable via |
|---|---|---:|---:|---|
| 1 | Bronze I | 30 | $3 | Any Pocket $0.99 or Starter $2.99 — unlocks on first purchase |
| 2 | Bronze II | 100 | $10 | Starter ($2.99, 299 pts) alone clears |
| 3 | Bronze III | 250 | $25 | Starter + Pass = 1,298 pts — overshoots to T5 boundary |
| 4 | Silver I | 500 | $50 | Pass alone (999 pts) |
| 5 | Silver II | 1,000 | $100 | 2×Pass = 1,998 or Pass + Mixologist = 1,998 |
| 6 | Silver III | 2,000 | $200 | 2 Pass + 1 Grand Service = 2,997 |
| 7 | Gold I | 4,000 | $400 | ~4 Pass + 1 Vault + bundles — month 4–5 |
| 8 | Gold II | 7,000 | $700 | 7 Pass + 1 Vault + bundles — month 7–8 |
| 9 | Diamond | 12,000 | $1,200 | Year 1 committed dolphin |
| 10 | Obsidian | 20,000 | $2,000 | Year 1–2 whale |

No dead zones. Every tier reachable via 5 coin packs + 3 bundles + Pass combinations.

### §15.L — Obsidian whale daily coin ceiling sanity

VIP Tier 10 (+50% coin bonus, −25% booster shop), Arena 8, ×4 stakes routine, 25 matches/day, Pass Premium + Bonus Bank capped:

| Source | Obsidian daily | Notes |
|---|---:|---|
| Match wins base (Arena 8, 25 matches, ×1) | 1,500 | |
| On-Fire × stake (capped per v7.3.1 §2B) at ×4 | 1,400 | |
| Losses (25c avg) | 375 | |
| Lucky Box (Arena 8 @ 350/claim × 3) | 1,050 | |
| Dailies + Daily Chest | 600 | |
| Weekly Missions amortized | 600 | |
| Star Race Top 10 Arena 8 (15k/wk) | 2,143 | |
| Trophy Road amortized | 150 | |
| Pass Premium amortized | 1,167 | |
| Bonus Bank (5k/30d) | 167 | Post-T30 faucet, capped |
| Album rewards amortized | 280 | |
| Weekly reset chest amortized | 360 | |
| Subtotal | 9,792 | |
| VIP +50% bonus on ~60% applicable sources | +2,100 | |
| **TOTAL** | **~11,900** | **79% of 15k bound ✓** |

Obsidian stake-and-lose pain: 4 Gold × 400c × 0.75 VIP discount = 1,200c = **10%** of daily. Slightly below v7.3.1's 25% whale-pain target. Minor note for post-soft-launch tuning: consider Obsidian booster discount −25% → −15% if whale stakes feel too painless (not locked; monitor data first).

Monday peak: 19k (15k Star Race + 2.5k reset chest + 1.5k Missions) = 2.0× daily average, within v7.3.1 §5 guardrail.

---

## §16 — Drift cleanup from v7.3 (applied in edits 2026-04-23)

Already applied to v7.3 file:
- §2 tuning note: resolved to flattened curve (0/150/400/700/1,000/1,500/2,200/3,200)
- §2 scope table: Cocktail Lounge trophy gate 1,000
- §8 Teams stub unlock state: 1,000 trophies (was 1,300 briefly)
- §8 tracking events: ≥1000 trophies
- §14 bottom-nav Teams badge: 1,000 trophies
- §15.A arena curve: Tea Garden 700, Cocktail 1,000, Wine Cellar 1,500, Champagne 2,200, Grand Hotel 3,200
- §16 post-MVP Teams unlock: 1,000 trophies
- §16 post-MVP new adds: Interstitials, Ranked mode
- §18 #5 verification disclosure: marked RESOLVED

Verified in v7.3.1 — no changes needed:
- §1 Lucky Box table Cocktail row @ 1,000 was already correct
- §4 Star Race and §2 match-win tables reference arenas by NAME, no numeric drift

---

## §17 — Open items forwarded to v7.5

- Rewarded video integration (2 placements: post-match double coins, Color Spawn recharge)
- Coin bundle IAP localization + platform SKUs
- Home UI mockup after v7.3 §14 reshuffle (final art direction)
- Reconnection / anti-cheat baseline
- Matchmaking telemetry dashboard (band fill rate, bot-fill %, cushion WR accuracy)
- MM/8BP in-client screenshot verifications (v7.3 §18 items 1–4)
- Final SKU price localization pass per country
- Ad mediation setup (ironSource/MAX/AdMob) for v7.5 ad launch

---

## §18 — Tag distribution (projected after v7.4)

| Tag | v7.3 | **v7.4** | Δ |
|---|---|---|---|
| 🟢 Aligned | 36 | 39 | +3 (matchmaking trophy-only, profile showcase free, no reset) |
| 🟡 Hybrid | 3 | 2 | −1 (matchmaking no longer hybrid) |
| 🟣 Innovation (plugin) | 8 | 8 | 0 |
| 🔴 Innovation (archetype) | 0 | 0 | 0 |
| ⚫ Missing | 2 | 1 | −1 (FTUE closed; rewarded video remains in v7.5) |
| ⏸ Paused (explicitly planned) | 9 | 11 | +2 (interstitials, ranked mode added) |
| ⚠️ Problematic | 0 | 0 | 0 |
| ❓ Unknown | 3 | 1 | −2 (session target, retention target locked) |

---

## §19 — Sources

- [Naavik — Match Masters deconstruction (2023-05)](https://naavik.co/deep-dives/match-masters-deconstruction/) — flagged as needing cushion revamp
- [Naavik — Royal Match deconstruction (2022-05)](https://naavik.co/deep-dives/royal-match/) — cushion philosophy reference
- [Matthew Le — Clash Royale sticky FTUE LinkedIn (2016-03)](https://www.linkedin.com/pulse/clash-royale-creating-sticky-first-time-user-experience-matthew-le) — 7 training battles pattern (stale flag)
- [Supercell — Matchmaking Changes (2021-02)](https://supercell.com/en/games/clashroyale/blog/news/matchmaking-changes/) — trophy + King Level hybrid MM
- [Supercell Support — Path of Legends](https://support.supercell.com/clash-royale/en/articles/path-of-legends-3.html) — ranked mode reference
- [Miniclip Support — 8BP Matchmaking](https://support.miniclip.com/hc/en-us/articles/360013462898-How-does-the-matchmaking-system-work-) — hidden Strength rating reference
- [Candivore Zendesk — Trophies](https://candivore.zendesk.com/hc/en-us/articles/360019633059-Trophies)
- [Candivore Zendesk — Game Modes Unlocked](https://candivore.zendesk.com/hc/en-us/articles/9363812490266-Game-Modes-Unlocked) — Academy FTUE wrapper
- [simplegameguide — MM Studios & Levels (2024-07)](https://simplegameguide.com/match-masters-studios-levels/) — MM 2026 unlock thresholds
- [allloot — MM Teams Guide](https://allloot.com/match-masters-teams/) — MM 2026 teams unlock ~1,300
- [Dream Games Helpshift — Royal Pass Bonus Bank](https://dreamgames.helpshift.com/hc/en/3-royal-match/faq/112-royal-pass/) — post-completion pattern primary source
- Internal: v7.3-patch-mvp-completion.md, v7.3.1-patch-economy-correction.md

---

**End of v7.4 patch.**
