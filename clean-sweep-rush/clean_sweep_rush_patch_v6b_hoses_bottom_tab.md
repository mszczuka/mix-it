# Clean Sweep Rush — Economy + World 2 + Hoses Bottom Tab Patch
**Patch ID:** `design-patch-v6b-gold-world2-hoses-bottom-tab`  
**Applies to:** `index.html`, `design-doc.md`, `clean_sweep_rush_patch_v3_regen_tank_gold_feedback.md`, `clean_sweep_rush_patch_v5_add_20_levels.md`  
**Audience:** Product, Game Design, Economy, UI/UX, Level Design, Claude Code  
**Status:** Proposed working patch  

---

## 1. Patch Goal

This patch rewrites the previous Hoses teaser direction and makes three coordinated changes:

1. **Increase Gold rewards** so later levels are less punishing economically.
2. **Add 20 more levels** after World 1, expanding the prototype to **43 total levels**.
3. **Move `Hoses` into the bottom navigation as the 3rd tab**, instead of a left-side drawer.

This keeps the current product direction:
- level-based
- explicit goals
- timer-driven
- optional boosters
- light permanent progression
- no Archero-like run-build system
- no real hose equipment mechanic yet

---

## 2. Why This Rewrite Is Needed

The current design foundation still assumes a **portrait-first, level-based casual product** with bottom-safe UI and persistent bottom navigation outside active gameplay. The current design patch explicitly defines bottom navigation as `Home` + `Upgrades`, and the current HTML implementation matches that with exactly two bottom tabs. The new request is to revise that shell so `Hoses` becomes the **3rd tab in the same bottom navigation family**, rather than a separate left-side teaser surface. This is a deliberate override of the earlier “no third tab in MVP” stance.  

The rewrite is safe because `Hoses` remains:
- non-gameplay
- non-stat
- teaser-only
- outside gameplay HUD
- hidden during active levels

So the product still avoids a deep second meta system.

---

## 3. High-Level Decision

### Previous direction
- bottom nav: `Home`, `Upgrades`
- Hoses teaser: left-side drawer/tab

### New direction
- bottom nav: `Home`, `Upgrades`, `Hoses`
- remove left-side drawer entrypoint entirely
- keep Hoses as **preview-only collection tab**

### Important constraint
`Hoses` is still **not** a real equipment mechanic.

No hose item:
- changes stats
- can be equipped
- affects gameplay
- spends currency
- appears on intro screen as loadout

---

## 4. Bottom Navigation Rewrite

## 4.1. New Bottom Menu

Persistent bottom nav outside active levels:

- `Home`
- `Upgrades`
- `Hoses`

During gameplay:
- bottom nav remains hidden
- only gameplay HUD is visible

## 4.2. Navigation Purpose

### Home
Primary progression hub.

### Upgrades
Permanent utility progression for the cleaning tool.

### Hoses
Preview collection / aspirational cosmetic teaser.

## 4.3. Why This Is Better Than the Left Tab
The 3-tab bottom menu is better for this version because:
- it matches the existing shell already implemented
- it feels more native and less bolted on
- it is easier to discover than a side teaser
- it still keeps Hoses in meta space, away from gameplay
- it avoids visual competition with gameplay HUD and water tank

---

## 5. Hoses Tab — Final Design

## 5.1. Purpose
The Hoses tab exists to communicate:
- future collectible fantasy
- future rarity/status layer
- long-term aspiration
- visual variety of the player’s cleaning setup

It does **not** yet introduce:
- a gear meta
- rarity balance
- power-based cosmetics
- equip logic
- loot economy
- gacha

## 5.2. Screen Type
`Hoses` is a full meta screen, parallel to `Upgrades`.

Recommended header:
- title: `Hoses`
- subtitle: `Coming Soon`

Recommended top-right info:
- Gold remains visible for shell consistency
- but no hose can be purchased yet

## 5.3. Content Layout
Main content:
- 12 hose cards
- 3 cards per row
- 4 rows total
- grid centered in portrait layout
- scroll allowed if needed on smaller devices

Each card shows:
- hose preview silhouette / concept art
- hose name
- star rarity row
- lock icon
- small footer label: `Coming Soon`

## 5.4. Interaction
Tapping a hose card opens a lightweight modal or tooltip:

```text
Coming Soon
Hose collections and rarities will unlock in a future update.
```

That is all.
No equip button.
No unlock CTA.
No price.
No progression gate yet.

---

## 6. Hoses Teaser Inventory

Add 12 placeholder hose entries with rarity fantasy only:

| ID | Name | Rarity | Stars |
|---|---|---|---|
| h01 | Starter Blue | Common | ★ |
| h02 | Garden Mint | Common | ★ |
| h03 | Patio Orange | Common | ★ |
| h04 | Neon Twist | Uncommon | ★★ |
| h05 | Carbon Coil | Uncommon | ★★ |
| h06 | Sunset Flex | Uncommon | ★★ |
| h07 | Hydro Chrome | Rare | ★★★ |
| h08 | Toxic Lime | Rare | ★★★ |
| h09 | Midnight Pipe | Rare | ★★★ |
| h10 | Rose Gold Jet | Epic | ★★★★ |
| h11 | Prism Spiral | Epic | ★★★★ |
| h12 | Royal Pressure | Legendary | ★★★★★ |

## 6.1. Visual Rule
Rarity should be communicated through:
- border treatment
- glow treatment
- star row
- silhouette polish
- background treatment

But every card still remains:
- locked
- non-functional
- teaser-only

---

## 7. UI Rules for the Hoses Tab

## 7.1. Screen Hierarchy
The Hoses tab must remain secondary to:
- Play CTA
- progression through levels
- Upgrades

It is a fantasy tab, not a productivity tab.

## 7.2. Visual Tone
The Hoses screen should feel:
- collectible
- aspirational
- premium
- readable
- clean

It should **not** feel:
- like a store
- like a lootbox menu
- like a missing required power system

## 7.3. Messaging Rules
Use explicit teaser messaging:
- `Coming Soon`
- `Future Collection`
- `Preview Only`
- `Locked`

Do not imply:
- player is underpowered without these
- player should grind for them now
- player can unlock them today

---

## 8. Economy Patch — More Gold for Later Levels

## 8.1. Goal
Later levels are harder and should reward progress more clearly.

The economy should not create a double punishment where:
- levels are harder
- and progression slows at the same time

## 8.2. New Base Reward Curve

Replace the current reward curve with:

| Level Range | Base Reward |
|---|---:|
| 1–5 | 70 Gold |
| 6–10 | 85 Gold |
| 11–15 | 105 Gold |
| 16–20 | 125 Gold |
| 21–23 | 150 Gold |
| 24–28 | 165 Gold |
| 29–33 | 185 Gold |
| 34–38 | 210 Gold |
| 39–43 | 240 Gold |

## 8.3. Bonus Reward Update

| Bonus Type | New Value |
|---|---:|
| No Continue Bonus | +20 |
| 20s+ Left Bonus | +15 |
| Perfect / Optional Star Bonus | +15 |

### Restore Bonus
- single restore: `+10 Gold`
- dual restore: `+15 Gold`
- finale restore combination: `+20 Gold`

### Relief Level Bonus
Add `+20 Gold` on:
- Level 10
- Level 20
- Level 30
- Level 40

## 8.4. Fail Retention
Increase fail retention to:

- default target: **65% retained on fail**

Optional curve:
- Levels 1–20: 60%
- Levels 21–43: 70%

---

## 9. Result Screen Reward Breakdown

For stronger clarity, result screens for wins should show:

```text
Base Gold
+ No Continue Bonus
+ Time Bonus
+ Restore Bonus
+ Relief Bonus
= Total Gold
```

This helps players understand why difficult or premium-feel levels are worth clearing.

---

## 10. Add 20 More Levels

## 10.1. Scope
Add **Levels 24–43**.

This creates:
- **World 1:** Backyard Chaos — Levels 1–23
- **World 2:** Food Court Meltdown — Levels 24–43

This matches the design goal that each world should contain **20–40 levels** and have a distinct visual identity.

---

## 11. World 2 — `Food Court Meltdown`

## 11.1. Theme
A messy indoor food court / mall dining area:
- spills
- soda puddles
- grease
- trays
- tables
- vending machines
- counters
- neon and kiosk lights

## 11.2. Dirt Families
- sticky spills
- soda puddles
- grease
- trash
- sludge

## 11.3. Restore Actions
- restore neon sign
- restart soda machine
- reactivate kiosk lights
- restore display case
- restore central food-court sign
- restore fountain display

## 11.4. Hazard Family
World 2 soft hazards:
- leaking fryer grease
- intermittent soda spray
- slippery spill zones
- light electrical spill near vending machines

Readable and light only.  
No chaotic overlap in early World 2.

---

## 12. Levels 24–43 — Full Plan

### Level 24 — `Tray Trouble`
**Timer:** 65s  
**Targets:** Trays x4  
**Main System:** world reset / easy recognition

### Level 25 — `Sticky Tables`
**Timer:** 70s  
**Targets:** Tables x2, Sticky Spills x4  
**Main System:** mixed goals  
**Note:** unlocks `Move Speed`

### Level 26 — `Counter Wipe`
**Timer:** 70s  
**Targets:** Counter Area 70%  
**Main System:** simple static area target

### Level 27 — `Neon Reset`
**Timer:** 75s  
**Targets:** Restore Neon Sign x1  
**Main System:** restore refresher

### Level 28 — `Grease Trail`
**Timer:** 75s  
**Targets:** Grease Puddles x6  
**Main System:** stronger route planning

### Level 29 — `Dining Rush`
**Timer:** 80s  
**Targets:** Tables x2, Trash x6  
**Main System:** broader route

### Level 30 — `Quick Sweep` *(relief)*
**Timer:** 60s  
**Targets:** Trays x6, Chairs x4  
**Main System:** easy reward-feel cleanup

### Level 31 — `Soda Burst`
**Timer:** 80s  
**Targets:** Soda Puddles x6, Restore Soda Machine x1  
**Main System:** first soft hazard in World 2

### Level 32 — `Kiosk Lights`
**Timer:** 85s  
**Targets:** Restore Kiosk Lights x2  
**Main System:** dual restore

### Level 33 — `Grease Route`
**Timer:** 85s  
**Targets:** Grease x5, Tables x2, Trash x4  
**Main System:** 3-target route planning

### Level 34 — `Display Case`
**Timer:** 85s  
**Targets:** Restore Display Case x1, Sticky Spills x5  
**Main System:** restore + blockers

### Level 35 — `Food Court Core`
**Timer:** 90s  
**Targets:** Main Food Court Area 75%  
**Main System:** large static area target

### Level 36 — `Vending Row`
**Timer:** 90s  
**Targets:** Vending Machines x2, Soda Puddles x6  
**Main System:** hazard-lite route

### Level 37 — `Slippery Shift`
**Timer:** 95s  
**Targets:** Grease x7, Restore Neon Sign x1  
**Main System:** late-world route pressure

### Level 38 — `Service Access`
**Timer:** 95s  
**Targets:** Trash x6, Restore Service Door x1  
**Main System:** one meaningful lock + restore

### Level 39 — `After Lunch`
**Timer:** 95s  
**Targets:** Tables x3, Trays x8  
**Main System:** dense cleanup wave

### Level 40 — `Coin Vacuum` *(relief)*
**Timer:** 65s  
**Targets:** Trays x8, Chairs x6  
**Main System:** gold relief level

### Level 41 — `Machine Restart`
**Timer:** 100s  
**Targets:** Restore Soda Machine x1, Restore Kiosk Lights x1  
**Main System:** dual restore route

### Level 42 — `Grease Shutdown`
**Timer:** 100s  
**Targets:** Grease x8, Soda x5  
**Main System:** dual dirt pressure

### Level 43 — `Food Court Reborn`
**Timer:** 110s  
**Targets:** Main Food Court Area 80%, Restore Central Sign x1, Restore Fountain Display x1  
**Main System:** World 2 capstone

---

## 13. New Bottom Nav Behavior

## 13.1. Tabs
Bottom nav should now render:

- `Home`
- `Upgrades`
- `Hoses`

## 13.2. Active State
The active tab highlight should work for all three tabs.

## 13.3. Visibility
Bottom nav remains:
- visible on `Home`
- visible on `Upgrades`
- visible on `Hoses`
- hidden on `Intro`
- hidden on `Gameplay`
- hidden on `Result`

This preserves the original gameplay clarity rule.

---

## 14. Implementation Notes for `index.html`

## 14.1. Replace the Current Two-Tab Bottom Nav
Current implementation has only:
- `Home`
- `Upgrades`

Update it to:

```html
<div id="bottom-nav" class="hidden">
  <button class="nav-tab active" data-tab="home">
    <span class="nav-tab-icon">🏠</span>Home
  </button>
  <button class="nav-tab" data-tab="upgrades">
    <span class="nav-tab-icon">⬆️</span>Upgrades
  </button>
  <button class="nav-tab" data-tab="hoses">
    <span class="nav-tab-icon">🧵</span>Hoses
  </button>
</div>
```

## 14.2. Add New Screen
Add a new meta screen container:

```html
<div id="screen-hoses" class="screen hidden">
  <div id="hoses-header">
    <div id="hoses-title">Hoses</div>
    <div id="hoses-subtitle">Coming Soon</div>
  </div>
  <div id="hoses-grid"></div>
</div>
```

## 14.3. Add Screen Handling
Update screen manager to support:
- `hoses`

Add:
- `populateHosesScreen()`
- `updateNavTabs('hoses')`

## 14.4. Add Data
Add:
```ts
const HOSE_TEASER_ITEMS = [
  { id: "h01", name: "Starter Blue", rarity: 1, locked: true },
  { id: "h02", name: "Garden Mint", rarity: 1, locked: true },
  { id: "h03", name: "Patio Orange", rarity: 1, locked: true },
  { id: "h04", name: "Neon Twist", rarity: 2, locked: true },
  { id: "h05", name: "Carbon Coil", rarity: 2, locked: true },
  { id: "h06", name: "Sunset Flex", rarity: 2, locked: true },
  { id: "h07", name: "Hydro Chrome", rarity: 3, locked: true },
  { id: "h08", name: "Toxic Lime", rarity: 3, locked: true },
  { id: "h09", name: "Midnight Pipe", rarity: 3, locked: true },
  { id: "h10", name: "Rose Gold Jet", rarity: 4, locked: true },
  { id: "h11", name: "Prism Spiral", rarity: 4, locked: true },
  { id: "h12", name: "Royal Pressure", rarity: 5, locked: true }
];
```

## 14.5. Add UI State
Add:
```ts
state.screen = "home" | "upgrades" | "hoses" | "intro" | "gameplay" | "result";
```

No equip state required.

## 14.6. Add Hoses Screen Builder
Create a screen builder that:
- renders 12 cards
- uses 3 columns
- shows lock state
- shows stars
- uses a `Coming Soon` footer on each card

## 14.7. Update Nav Click Handling
Add:
```ts
if (target === 'hoses') showScreen('hoses');
```

---

## 15. Acceptance Criteria

This patch is successful when:

### Economy
- later levels give noticeably better Gold
- upgrades feel reachable despite higher difficulty
- hard level failure no longer feels like economic dead time

### Content
- game contains **43 levels total**
- World 2 feels like a real second pack
- progression remains readable and fair

### UI
- bottom nav now has **3 tabs**
- `Hoses` opens as a full screen, not a side drawer
- the Hoses screen shows **12 locked hose cards**
- cards are laid out **3 per row**
- no hose affects gameplay

### Product Direction
- no Archero-like loadout reading
- no deep gear/equipment economy
- collectible aspiration increases without adding real mechanical complexity

---

## 16. Final Decision

### Keep
- current shell
- current upgrade lanes
- current hold-to-spray tank model
- current Gold feedback
- current bottom-nav-first meta navigation

### Add
- more generous Gold economy
- Levels 24–43
- World 2: Food Court Meltdown
- `Hoses` as the 3rd bottom-nav tab
- 12 locked rarity-based hose previews

### Reject
- left-side Hoses drawer
- real hose equipment system
- hose stats
- hose upgrade economy
- gameplay-affecting rarity system for now

---

## 17. Final Product Shape After This Patch

After this patch, the prototype becomes:

> **a 43-level two-world vertical slice with healthier late-level rewards and a 3-tab meta shell: Home, Upgrades, and a teaser-only Hoses collection screen**

That keeps the UI more coherent than splitting Hoses into a separate side surface.

---
