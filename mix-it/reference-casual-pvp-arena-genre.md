# Casual PvP Arena — Genre Conventions Reference

**Prepared:** 2026-04-22
**Reference titles:** Match Masters (Candivore), 8 Ball Pool (Miniclip), Golf Clash (Playdemic/EA), Bowling Crew (Wargaming), Mini Golf King (PNIX Games / Krafton), Trophy Hunter (Ten Square Games), Archero 2 PvP (Habby), Stumble Guys (Scopely).
**Verification:** All game-specific claims web-verified with dated citations. Applied gs-prototype-designer Verification Gates.

---

## Title identity verification

| Title | Developer / Publisher (verified) | Source | Notes |
|---|---|---|---|
| Match Masters | Candivore (Tel Aviv) | [Candivore](https://www.candivore.io/games/match-masters/); [Game Developer, 2022](https://www.gamedeveloper.com/business/-i-match-masters-i-dev-candivore-nets-12-million-to-drive-user-acquisition) | 60M+ downloads. |
| 8 Ball Pool | Miniclip | [Wikipedia](https://en.wikipedia.org/wiki/8_Ball_Pool); [Sensor Tower, 2020](https://sensortower.com/blog/8-ball-pool-revenue) | Confirmed. |
| Golf Clash | Playdemic (EA, acquired 2021 for $1.4B) | [Game Developer, 2021](https://www.gamedeveloper.com/business/ea-buys-i-golf-clash-i-developer-playdemic-from-at-t-and-wb-games-for-1-4b) | Confirmed. |
| Bowling Crew | Wargaming (Belgrade) | [Flexion, 2022](https://flexion.games/flexion-mobile-signs-bowling-crew-from-wargaming-group/); [Press Kit](https://bowlingcrew.com/press-kit/) | Confirmed. |
| Mini Golf King | PNIX Games (Krafton) | [Google Play](https://play.google.com/store/apps/details?id=com.pnixgames.minigolfking); [Krafton](https://www.krafton.com/en/games/mini-golfking/) | "Roi Games / AppOnAuto" unverified — PNIX is correct. |
| Trophy Hunter | Ten Square Games — global launch 2025-07-03 | [TSG press](https://tensquaregames.com/2025/07/03/global-release-of-trophy-hunter-test-your-skills-in-the-next-evolution-of-hunting-games/) | 1v1 sniper duels. |
| Archero 2 (PvP) | Habby — global launch 2025-01-07; "PvP 2.0" best-of-three | [PocketGamer.biz](https://www.pocketgamer.biz/hybridcasual-hitmaker-habby-launches-archero-2-pitting-players-against-the-lone-archer/); [App Store](https://apps.apple.com/us/app/archero-2/id6502820653) | PvP is a sub-mode inside a hybrid-casual roguelike. |
| Stumble Guys | Scopely (acquired from Kitka, 2022-09) | [Scopely press](https://www.scopely.com/en/news/welcome-stumble-guys-to-the-scopely-portfolio); [Mobilegamer.biz](https://mobilegamer.biz/scopely-has-acquired-stumble-guys-from-kitka-games/) | 32-player BR — **structural outlier**. |

---

## Summary

Casual PvP Arena is a super-genre of short, skill-gated 1v1 (sometimes FFA) real-time matches wrapped around a Clash-Royale-style meta: trophy road progression, card-based equipment collection gated by chests, coin ante per match, premium gem layer, seasonal pass. Core loop: *"free match → risk coins on stake → win more coins + trophies + card drops → upgrade equipment → unlock new arena tier with better prizes."*

Conventions marked **[genre-defining]** are near-universal; **[common]** appear in most titles; **[variation]** shows meaningful divergence.

---

## 1. Core match structure

- **Real-time 1v1 synchronous matches [genre-defining]** — both players present, shared clock. Standard for 8 Ball Pool, Golf Clash, Bowling Crew, Mini Golf King, Match Masters, Trophy Hunter.
- **Turn-based within real-time framing [common]** — Match Masters is turn-based on a shared match-3 board; 8 Ball Pool alternates shots with a per-shot timer; Bowling Crew is simultaneous-turn bowling. Source: [Naavik — Match Masters](https://naavik.co/deep-dives/match-masters-deconstruction/).
- **Short match length (2–5 minutes) [genre-defining]** — commute-tuned. Match Masters: 4 rounds ([Fandom Wiki](https://match-masters.fandom.com/wiki/Match_Masters_Wiki)). Archero 2 PvP: best-of-three ([PocketGamer.biz](https://www.pocketgamer.biz/hybridcasual-hitmaker-habby-launches-archero-2-pitting-players-against-the-lone-archer/)). Trophy Hunter: three-round duels ([TSG, 2025](https://tensquaregames.com/2025/07/03/global-release-of-trophy-hunter-test-your-skills-in-the-next-evolution-of-hunting-games/)).
- **Skill + noise mix [genre-defining]** — input skill (aim, power, spin, timing) layered with equipment RNG, board-gen randomness, or guideline/wind chance. [Om Tandon on 8BP](https://medium.com/@omtandon/miniclips-8-ball-pool-a-melting-pot-of-skill-chance-based-gratification-part-1-ca295b4cba68).
- **FFA / Battle Royale [variation]** — Stumble Guys (32 players, elimination) is the outlier.

---

## 2. Matchmaking & stakes

- **Coin ante / wager per match [genre-defining]** — soft currency wagered, winner takes ~2x minus rake. 8 Ball Pool room antes scale from beginner to "Expert" ([Billiards Base](https://billiardsbase.com/blog/what-is-the-coin-limit-per-tier-in-8-ball-pool/) — secondary source). Bowling Crew Chips ante ([FAQ](https://bowlingcrew.zendesk.com/hc/en-us/articles/17655534250769-Frequently-Asked-Questions)). Match Masters scales rewards by *opponent's staked booster rarity* ([Match Masters Wiki](https://match-masters.fandom.com/wiki/Match_Masters_Wiki)).
- **Trophy/ELO ladder [genre-defining]** — +trophies win / −trophies loss → arena placement. Golf Clash trophies drive Tour unlocks ([Playdemic Help](https://playdemic.helpshift.com/hc/en/6-golf-clash/faq/446-what-are-trophies/)). Bowling Crew trophies unlock Alleys ([FAQ](https://bowlingcrew.zendesk.com/hc/en-us/articles/4414078993297-How-to-receive-trophies-for-winning-matches)).
- **Arena/Tour/Alley tiers [genre-defining]** — themed zones, per-tier stake ranges, per-tier content pools. Golf Clash Tour 6 ~2200 trophies, Tour 7 ~3900 ([Golf Clash Notebook](https://golfclashnotebook.io/clubs/), community). Bowling Crew uses trophy caps forcing backtrack to lower alleys.
- **Trophy cap per tier (asymmetric) [common]** — max win allowed per tier, excess must be earned higher. Golf Clash + Bowling Crew both use.
- **Auto-tier / no selector [genre-defining]** — player always plays their current trophy-band arena. Confirmed from MM [Naavik](https://naavik.co/deep-dives/match-masters-deconstruction/).
- **Bot-fills [common, inferred]** — widely suspected, not officially disclosed.
- **Skill + power hybrid matchmaking [common]** — balances trophies + equipment tier.

---

## 3. Progression meta (Trophy Road)

- **Trophy-gated content unlock [genre-defining]** — trophies unlock arenas, clubs, features, chest contents. Golf Clash ([Playdemic Help](https://playdemic.helpshift.com/hc/en/6-golf-clash/faq/446-what-are-trophies/)). Bowling Crew ([FAQ](https://bowlingcrew.zendesk.com/hc/en-us/articles/17655534250769-Frequently-Asked-Questions)).
- **Chest drop from victories [genre-defining]** — win slot → real-time timer unlock or gem-skip. Clash Royale lineage. Golf Clash chests have tiered timers including a 4-hour Free/Season chest ([Golf Clash Notebook — Chests](https://golfclashnotebook.io/chests/)).
- **Weekly / seasonal league [genre-defining]** — competitive layer on top of trophies. Bowling Crew league resets Monday UTC ([FAQ](https://bowlingcrew.zendesk.com/hc/en-us/articles/17655534250769-Frequently-Asked-Questions)). 8 Ball Pool weekly leaderboards reset Monday ([Miniclip](https://support.miniclip.com/hc/en-us/articles/360001712887--Clubs-Leaderboards)).
- **Seasonal reset [common]** — trophies or leaderboards reset on a weekly/monthly cadence.

---

## 4. Content system

- **Collectible equipment with card-shard upgrades [genre-defining]** — Clash-Royale-style cards. Duplicates upgrade card level. Golf Clash: clubs + balls, 3 rarities ([allclash](https://www.allclash.com/best-clubs-in-golf-clash-best-upgrade-order/)). 8 Ball Pool: cues up to Legendary, 4-piece unlock ([allclash](https://www.allclash.com/8-ball-pool-all-legendary-cues-how-you-can-get-them/)). Bowling Crew: ball archetypes (Bounce/Precise/Power). Mini Golf King: full bag + balls + gloves ([Google Play](https://play.google.com/store/apps/details?id=com.pnixgames.minigolfking)).
- **Rarity tiers (3–4 bands) [genre-defining]** — Common → Rare → Epic → Legendary, color-coded. Drop rates rarely published.
- **Boosters-as-content [variation]** — Match Masters collects 30+ match-time *boosters* with a bet-risk twist: lose → you also lose the staked booster ([Candivore Zendesk](https://candivore.zendesk.com/hc/en-us/articles/6793235546650-Match-Masters-Tips-and-Tricks); [Naavik](https://naavik.co/deep-dives/match-masters-deconstruction/)). Genre's most inventive content-system variation.
- **Cosmetic-only content [variation]** — Stumble Guys is skins/emotes/footsteps because gameplay is cosmetic-neutral ([Stumble Pass Wiki](https://stumbleguys.fandom.com/wiki/Stumble_Pass)). Sports titles have *functional* content.

---

## 5. Economy & currencies

- **Soft currency = ante [genre-defining]** — primary soft exists to be wagered. Coins (MM/GC/8BP), Chips (Bowling Crew).
- **Hard currency (gems) for shortcuts, cosmetics, chest skips [common, not universal]** — priced $0.99–$99.99. Present in 8BP (Pool Cash), Golf Clash (Gems), Bowling Crew, Mini Golf King. **Match Masters is the notable exception** — MM ships with Coins as the *only* currency, no premium wallet ([Candivore Zendesk — Coins](https://candivore.zendesk.com/hc/en-us/articles/360019827339-Coins); "Diamond" in MM is a booster rarity tier, not a currency). Golf Clash daily shop club cards: 1/10/100 gems by rarity ([Golf Clash Notebook FAQ](https://golfclashnotebook.io/faq/), community).
- **No stamina / energy on matches [common]** — energy replaced by *ante*. Deliberate contrast with gacha-RPG energy systems.
- **Chest timer system [genre-defining]** — 3h / 8h / 24h unlocks, gem-skip primary sink. Golf Clash, Mini Golf King.
- **Pay-to-skip chest timers [genre-defining]** — biggest mid-spender gem sink.
- **Booster/consumable currency [variation]** — Match Masters' boosters = quasi-currency; losing consumes them.

---

## 6. Monetization patterns

- **First-purchase starter pack ($0.99–$4.99) [genre-defining]** — deep discount; conversion driver.
- **Seasonal Battle Pass / Pool Pass / Stumble Pass [genre-defining]** — 8BP Pool Pass + Elite Pass ([Miniclip](https://support.miniclip.com/hc/en-us/articles/360036840073--Pool-Pass-Elite-Pass-Your-Ultimate-Guide-8-Ball-Pool)). Stumble Pass: 30 levels, free + premium + Deluxe tiers. 28–42 day seasons, $5–15, 30–50 tiers.
- **Chest/gacha = card randomisation [genre-defining]** — primary gacha vector; drop rates rarely disclosed publicly. 8BP Rare/Epic/Legendary boxes with multi-piece unlock for Legendary ([allclash](https://www.allclash.com/8-ball-pool-all-legendary-cues-how-you-can-get-them/)).
- **VIP / club loyalty points [common]** — 8BP VIP system from purchases + ring completions ([Miniclip VIP](https://support.miniclip.com/hc/en-us/articles/360000639967-VIP-Points-8-Ball-Pool)).
- **Rewarded video ads for free coin top-ups / extra chest opens [common]** — Trophy Hunter confirms ([TSG](https://tensquaregames.com/2025/07/03/global-release-of-trophy-hunter-test-your-skills-in-the-next-evolution-of-hunting-games/)); Bowling Crew includes optional ad-rewards.
- **Direct-buy rare items (legendary shop) [common]** — 8BP legendary cue events.
- **Chat packs / cosmetic emotes as micro-IAP [common]** — 8BP chat packs ([Miniclip](https://support.miniclip.com/hc/en-us/articles/34212511439249-Chat-Emojis-Gifting-Take-your-social-game-to-the-next-level-8-Ball-Pool)).
- **IAP range** $0.99–$99.99. ARPDAU Sports benchmark: $0.06–$0.20+.

---

## 7. Social & retention

- **Clubs / Crews / Teams (guild layer) [genre-defining]** — 8BP Clubs: chat, friendlies, club-vs-club + country leaderboards ([Miniclip Clubs](https://support.miniclip.com/hc/en-us/articles/360001712887--Clubs-Leaderboards), [Gifts/Chat](https://support.miniclip.com/hc/en-us/articles/360001677828--Clubs-Gifts-Chat-and-Friendly-Matches)). Match Masters Teams with daily gift-giving.
- **Predefined chat / canned emotes [genre-defining]** — open chat blocked; premade Chat Packs or emote wheels. 8BP is archetype. Moderation + localization.
- **Friend challenges / friendlies [genre-defining]** — 0-stake matches vs. known opponents ([Miniclip](https://support.miniclip.com/hc/en-us/articles/360001677828--Clubs-Gifts-Chat-and-Friendly-Matches)).
- **Leaderboards: country + world + club + friends [genre-defining]** — weekly reset cycle ([8BP Leaderboards](https://support.miniclip.com/hc/en-us/articles/204975658-Leaderboards-8-Ball-Pool)).
- **Gifting [common]** — MM Teams 1 gift/day; 8BP club gifts.
- **Daily login [genre-defining]** — every title runs one.
- **Sticker/trading collections [variation]** — Match Masters has stickers players collect and trade.
- **Party-hub / replays / spectate [variation]** — Stumble Guys Party Hub with replay clipping.

---

## 8. Session design

- **Target session: 5–15 min, 2–5 sessions/day [genre-defining]**. Driven by 3–5-min match cadence.
- **Matches per session: 2–4** — bounded by chest slot saturation + ante exhaustion. Intentional dual-gate stop-out.
- **Core loop cadence**: *Open → collect chest/daily → matchmake → match (3–5 min) → results + chest drop → open/queue → repeat 2–3x → saturation or ante low → close.*

---

## 9. Onboarding patterns *(directional — less primary-sourced)*

- **Tutorial = first forced win vs. weak bot [common, inferred]**.
- **Early win-rate tuning (60–70%) [common, inferred]**.
- **First IAP pitched in first 1–3 sessions**, usually post-match starter-pack modal.
- **Progression front-loaded** — arena unlocks rapid in first hour to show the full ladder. Clash-Royale DNA.

---

## 10. Live-ops & events

- **Seasonal league resets [genre-defining]** — weekly or monthly.
- **Battle/Pool/Stumble Pass seasons [genre-defining]** — 28–42 days.
- **Themed seasonal content drops [common]** — Stumble Guys' "Nightland" season ([stumbleguys.com](https://www.stumbleguys.com/news/Nightland-season)); Golf Clash seasonal tournaments ([Playdemic](https://playdemic.helpshift.com/hc/en/6-golf-clash/section/57-tournaments/)).
- **Limited-time tournaments (entry-fee brackets) [genre-defining]** — Golf Clash tournaments with entry fees + tiered prizes ([Notebook](https://golfclashnotebook.io/tournaments/)). 8BP Underground Circuit Tables ([8ballpool.com](https://8ballpool.com/en/news/underground-circuit-tables)).
- **Limited-time game modes [common]** — 8BP Lucky Shot / Golden Shot; Stumble Guys rotating maps.
- **Licensed / crossover collabs [common at scale]** — Golf Clash 2025 "licensed tournaments"; Stumble Guys brand crossovers.
- **Flash offers post-match (loss-trigger, win-trigger) [common, inferred]**.

---

## Divergences & cautions

- **Stumble Guys** does NOT fit §1–§2 (BR, no ante, no 1v1). Fits §6/§7/§10 as reference for **battle-pass-led cosmetic monetization** and **seasonal cadence**.
- **Archero 2 PvP** is a sub-mode of a hybrid-casual roguelike. Use only as "best-of-three duel structure" reference.
- **Trophy Hunter** launched 2025-07-03; retention/monetization data not yet public. Structural reference only.
- **Match Masters** is the creative outlier — staked-booster system.

---

## Table-stakes features for a new prototype

1. 1v1 real-time match, 3–5 min, alternating turns + shot clock
2. Coin ante per match; trophies = ladder
3. Arena tiers with trophy gates; per-tier content pools
4. Chest drops from wins, staggered timers, gem-skip
5. Card-based equipment upgrades (3–4 rarity bands)
6. Gems at $0.99–$99.99
7. Seasonal battle pass (~30 days, $5–10)
8. Weekly-reset league / leaderboards
9. Clubs with chat + friendlies + gifts
10. Canned/emote-only communication
11. Daily login + daily shop rotation
12. Rewarded-video coin top-ups

## Differentiators (where new entrants compete)

- Novel match resolution (Match Masters' staked boosters)
- Signature skill input (Golf Clash 2-circle aim, 8BP angle/spin)
- Strong theme/IP (licensed sport, franchise, personality)
- Asymmetric per-arena content pools
- Hybrid modes (PvP + coop roguelike — Archero 2)

---

## Notes on items NOT independently confirmed

- Exact IAP price points, conversion rates, drop rates per title — publishers rarely disclose.
- Specific bot-fill policies — widely suspected, not officially confirmed.
- Exact FTUE win-rate targeting — design-community consensus, not primary-sourced.

---

## Sources

**Match Masters:** [Candivore site](https://www.candivore.io/games/match-masters/), [Game Developer funding](https://www.gamedeveloper.com/business/-i-match-masters-i-dev-candivore-nets-12-million-to-drive-user-acquisition), [Naavik deep-dive](https://naavik.co/deep-dives/match-masters-deconstruction/), [Fandom Wiki](https://match-masters.fandom.com/wiki/Match_Masters_Wiki), [Candivore Zendesk](https://candivore.zendesk.com/hc/en-us/articles/6793235546650-Match-Masters-Tips-and-Tricks), [Booster Stakes Multiplier article](https://candivore.zendesk.com/hc/en-us/articles/6352690476314-Booster-Stakes-Multiplier-x2-x3-x4-x5).

**8 Ball Pool:** [Wikipedia](https://en.wikipedia.org/wiki/8_Ball_Pool), [Sensor Tower](https://sensortower.com/blog/8-ball-pool-revenue), [Miniclip Support — Pool Pass](https://support.miniclip.com/hc/en-us/articles/360036840073--Pool-Pass-Elite-Pass-Your-Ultimate-Guide-8-Ball-Pool), [VIP Points](https://support.miniclip.com/hc/en-us/articles/360000639967-VIP-Points-8-Ball-Pool), [Clubs Chat/Gifting](https://support.miniclip.com/hc/en-us/articles/34212511439249-Chat-Emojis-Gifting-Take-your-social-game-to-the-next-level-8-Ball-Pool), [Clubs Leaderboards](https://support.miniclip.com/hc/en-us/articles/360001712887--Clubs-Leaderboards), [Fandom Cues](https://8ballpool.fandom.com/wiki/Cues), [Underground Circuit](https://8ballpool.com/en/news/underground-circuit-tables), [allclash legendaries](https://www.allclash.com/8-ball-pool-all-legendary-cues-how-you-can-get-them/), [Om Tandon analysis](https://medium.com/@omtandon/miniclips-8-ball-pool-a-melting-pot-of-skill-chance-based-gratification-part-1-ca295b4cba68).

**Golf Clash:** [EA/Playdemic acquisition](https://www.gamedeveloper.com/business/ea-buys-i-golf-clash-i-developer-playdemic-from-at-t-and-wb-games-for-1-4b), [Playdemic Help — Clubs/Trophies/Tournaments](https://playdemic.helpshift.com/hc/en/6-golf-clash/section/57-tournaments/), [Golf Clash Notebook](https://golfclashnotebook.io/), [allclash clubs](https://www.allclash.com/best-clubs-in-golf-clash-best-upgrade-order/).

**Bowling Crew:** [Press Kit](https://bowlingcrew.com/press-kit/), [FAQ](https://bowlingcrew.zendesk.com/hc/en-us/articles/17655534250769-Frequently-Asked-Questions), [Flexion Mobile](https://flexion.games/flexion-mobile-signs-bowling-crew-from-wargaming-group/).

**Mini Golf King:** [Google Play](https://play.google.com/store/apps/details?id=com.pnixgames.minigolfking), [Krafton](https://www.krafton.com/en/games/mini-golfking/).

**Trophy Hunter:** [TSG press release 2025-07-03](https://tensquaregames.com/2025/07/03/global-release-of-trophy-hunter-test-your-skills-in-the-next-evolution-of-hunting-games/).

**Archero 2:** [App Store](https://apps.apple.com/us/app/archero-2/id6502820653), [PocketGamer.biz](https://www.pocketgamer.biz/hybridcasual-hitmaker-habby-launches-archero-2-pitting-players-against-the-lone-archer/).

**Stumble Guys:** [Scopely](https://www.scopely.com/en/news/welcome-stumble-guys-to-the-scopely-portfolio), [Mobilegamer.biz](https://mobilegamer.biz/scopely-has-acquired-stumble-guys-from-kitka-games/), [Nightland](https://www.stumbleguys.com/news/Nightland-season), [Stumble Pass](https://www.stumbleguys.com/news/stumblepass), [Fandom](https://stumbleguys.fandom.com/wiki/Stumble_Pass).
