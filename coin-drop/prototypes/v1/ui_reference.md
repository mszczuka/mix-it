# UI Reference — donor: Monopoly GO

Date: 2026-05-15
Source: c (WebSearch)
Orientation: portrait
Evidence files:
- https://60fps.design/apps/monopoly-go
- https://arvindhsv.medium.com/deconstructing-monopoly-go-will-it-be-a-100m-hit-f0272f4e08e8
- https://www.pocketgamer.biz/under-the-hood-deconstructing-monopoly-go-as-it-passes-2-billion-in-revenue/
- https://playliner.com/2308-monopolygo
- https://www.thegamer.com/monopoly-go-sticker-albums-faq-complete-guide/
- https://monopolygo.wiki/
- https://www.monopolygo.com/sticker-album

Confidence: medium overall. Layout/tab inventory high-confidence (multiple teardowns corroborate). Pixel sizes, hex values, typography are observation-based estimates.

## 1. Viewport & safe area
- Target device: 6.1"–6.7" portrait phones; ~390–430 dp logical width
- Viewport ratio: 9:19.5 to 9:20 (iPhone 13/14/15 class)
- Safe-area: top inset (~44 dp), bottom inset (~34 dp); chrome floats over content

## 2. Top bar contract
- Height: ~76 px
- Left: circular avatar with gold-ring + level chip overlay
- Center: empty on board screen; event banner/timer chip during events
- Right (slot order):
  1. Cash (green bill) + "+" topup
  2. Dice rolls (white/blue dice) + "+"
  3. Contextual event currency (when active)
- Background: transparent strip; chips have own dark translucent capsules with gold stroke
- Divider: none — soft gradient shadow under chips

## 3. Bottom nav contract
- Present: yes
- Tab count: 5
- Tab order (left → right):
  1. Shop (bag/cart)
  2. Events / Tournaments (trophy)
  3. **Board / Home (center)** — house/board icon, dice CTA anchored here
  4. Sticker Album (book)
  5. Friends / Social (people)
- Center prominence: lifted + accent gold ring, slightly larger
- Icon style: chunky, filled, bevelled cartoon icons; active tab on tinted plate
- Labels: short caps-style under each icon always visible
- Badges: red dot (unread), numeric pill (count), yellow NEW ribbon
- Background: dark wood/navy gradient with gold top-edge piping, ~84-96 px including safe-area

## 4. Card system
- Radius: ~18 px (generous, toy-like)
- Padding: ~16 px horizontal, ~14 px vertical
- Shadow: `0 6px 14px rgba(0,0,0,0.28)` + inner highlight `inset 0 1px 0 rgba(255,255,255,0.35)`
- Border: 2-3 px gold stroke on premium/reward cards; none on neutral
- Sections: themed header strip, body (icon+value+desc), footer CTA/progress; ribbon callouts angled top-right

## 5. Primary CTA
- Shape: pill / lozenge; ~24 px radius
- Size: ~64 px tall, full-width on modals; ~120 px wide stadium for board roll
- Position: bottom-center above bottom nav, anchored
- Color: bright green for primary; red for premium/offer CTAs
- Press state: scale 0.95, inner shadow flash, confetti on success
- Typography: bold uppercase, slight outline, inner highlight

## 6. Secondary buttons / chips
- Chip: rounded capsule (~20 px radius, 32-40 px height), dark translucent fill, thin gold stroke, icon-left/value-right + "+" inline
- Tertiary: blue rounded-rect for nav/info (~44 px tall)

## 7. Panel grid pattern
- Mixed: list-card for events/quests; 3-column grid for sticker album; hero + horizontal shelf for shop
- Gutters: ~12 px between cards, ~24 px between sections
- Section headers: bold uppercase left, chevron/see-all right

## 8. Modal / popup pattern
- Center-card dominant (rewards, offers, character speech); bottom-sheet for confirm; full-screen for event intros / FTUE
- Dismiss: circular gold X top-right; tap-outside for non-blocking
- Backdrop: ~60-70% black + slight blur; reward modals add radial light rays

## 9. Color application rules
- Gold/yellow: reserved for premium (level chip, premium stroke, center tab ring, ribbons)
- Green: primary action + cash currency
- Red: offers / urgency / monetization CTAs (NOT regular danger)
- Soft red-orange + shake: insufficient-resource feedback
- Amber pill: quest timers near expiry

## 10. Typography ramp
- Display (modal titles, big reward numbers): 32-40 px, extra-bold italic, outlined stroke + drop shadow; rounded-display face (Lilita / Fredoka family)
- Title: 18-22 px bold uppercase tight tracking
- Body: 14-16 px semibold sans-serif rounded
- Caption: 11-12 px semibold uppercase low opacity
- Numerals: tabular, heavy, 1-2 px dark outline for board legibility

## 11. Iconography
- Chunky, bevelled, slightly cartoon-3D; toy aesthetic
- Tokens 3D-rendered; UI icons stylized 2D with gradient + soft shadow

## 12. Motion idioms
- Panel transitions: slide-up for sheets; scale-fade with overshoot spring for center modals; crossfade + icon-bounce on tab switch
- Press: scale 0.95 + inner shadow + soft haptic; specular sweep on button appearance
- Reward burst: confetti + cash particle eruption, center shimmer reveal, counter tick-up in top bar with pulse, final card flip/stamp; sticker peel-and-place; dice tumble-then-hop with screen shake per land
- Style: heavy squash-stretch + overshoot + layered particles ("juicy")

## 13. Token derivation (preview for Stage 2)

Color palette:
- bg: `#0E2A47` (deep navy)
- surface-dark: `#1B3E6E`
- surface-light: `#F6E9C9` (board frame cream)
- primary (action): `#2BB673` (cash green)
- accent (premium): `#F4C430` (gold)
- text-primary-on-dark: `#FFFFFF`
- text-primary-on-light: `#1B1B1B`
- text-secondary: `#C9D4E3`
- danger/offer: `#E33B3B`
- success: `#2BB673`
- warning: `#F39C2A`

Type scale (px): `[12, 14, 16, 18, 22, 28, 36]`
Space rhythm (px): `[4, 8, 12, 16, 24, 32, 48]`
Radius scale (px): `[8, 12, 16, 20, 28, 9999]`

Shadow recipes:
- card-soft: `0 2px 6px rgba(0,0,0,0.18)`
- card-lift: `0 6px 14px rgba(0,0,0,0.28), inset 0 1px 0 rgba(255,255,255,0.35)`
- cta: `0 4px 0 rgba(0,0,0,0.35), 0 6px 12px rgba(0,0,0,0.30)` (chunky bottom-edge button base)

## 14. Open variances
- Tab inventory shifts across versions (Friends sometimes top-bar, fifth slot sometimes Tournaments). Taken most common 2024-era layout — medium confidence.
- Third currency slot is contextual.
- Typography face unconfirmed; Lilita One / Fredoka closest match.
- Hex values are observational estimates — re-sample from current screenshot before committing.
- No primary Scopely source found; all evidence community/teardown.
