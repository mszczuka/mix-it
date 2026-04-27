# Phase 7B Task 8 — HudBar & BottomNav Audit Report

**Date:** 2026-04-27
**Status:** Read-only investigation complete
**Scope:** `HudBarView` (top persistent overlay), `BottomNavView` (bottom persistent overlay) vs HTML v7.

## Executive summary

Unity HudBar and BottomNav are **~60 % parity** with v7. Structure and routing are sound, but **reactivity gaps** dominate: HudBar runs a one-shot `Refresh()` (no event subscriptions on `ICurrencyService` / `IMailService` / `IStarRaceService` / `ILuckyBoxService` / `IDailyLoginService`); BottomNav has no mail badge binding; Stars currency and Star Race chip are absent from HudBar. **4 blockers, 5 important, 1 nice-to-have.** Estimated fix effort: ~5 dev-days.

---

## HudBar matrix

| v7 element | Unity status | Evidence | Severity |
|---|---|---|---|
| Avatar icon | OK | `HudBarView.cs:13` `_avatarIcon` | — |
| Username | STALE | `HudBarView.cs:79` hardcoded `"Bartender"` (Phase 7B defers username spec) | Important |
| Trophy count + icon | OK | `HudBarView.cs:16` reads `IRatingService.Trophies`, OnSaved sub | — |
| Coins balance | STALE | `HudBarView.cs:17` reads `Coins` only in `Refresh()`; no `OnChanged` sub | **Blocker** |
| Frame overlay (Apprentice) | OK | `HudBarView.cs:14` `_frameOverlay`, conditional on `HasApprenticeFrame` | — |
| Stars balance | MISSING | v7 has `#hud-stars`; Unity HudBar has no `_starsLabel` field | **Blocker** |
| Gold / hard currency | (not in v7) | v7 has Gold only in Shop/ante, not HUD currency row | — |
| Gems | (not in v7) | Out of MVP scope | — |
| Star Race chip (`{stars}★ · Top {pct}%`) | MISSING | v7 Home has `#star-race-btn`/`#srb-stars`/`#srb-tier`; HudBar doesn't bind `IStarRaceService` | **Blocker** |
| Daily Login indicator | MISSING | v7 design-v7.0 §10.1; HudBar has no badge for `IDailyLoginService` | Important |
| Lucky Box meter | MISSING | v7 Home has `#luckybox-btn`; HudBar doesn't expose `ILuckyBoxService` | Important |
| Mail icon + unread badge | MISSING | v7 specs mail badge; HudBar has no `IMailService` binding | **Blocker** |
| Settings/profile gear | OK | `HudBarView.cs:18` `_avatarButton` → `PanelId.Profile` | — |

**Reactivity failure pattern:** `HudBarView.Refresh()` is called once `OnEnable` (`HudBarView.cs:48`) and once on `OnSaved` (`HudBarView.cs:45–46`). No event subscriptions to `ICurrencyService.OnChanged`, `IMailService.UnclaimedCountChanged`, `IStarRaceService.OnChanged` or similar. Coins will not update mid-screen when earned from match rewards. design-v7.0 §15 ("Currency row updates reactively") is violated.

---

## BottomNav matrix

| v7 element | Unity status | Evidence | Severity |
|---|---|---|---|
| Shop tab | OK | `BottomNavView.cs:13` → `PanelId.Shop` | — |
| Teams tab | OK | `BottomNavView.cs:14` → `PanelId.Teams` | — |
| Home tab (centered) | OK | `BottomNavView.cs:15` active state on init | — |
| Venue tab | OK | `BottomNavView.cs:16` → `PanelId.Venue` | — |
| Albums tab | OK | `BottomNavView.cs:17` → `PanelId.Albums` | — |
| Active-state highlight | OK | `BottomNavView.cs:157–174` `RefreshActive()` polls `IUIRouter.Current` every Update | — |
| Shop badge (Starter Pack pending) | OK | `BottomNavView.cs:138–147` reads `ISaveProfile.StarterPackPending` + `RedDotExpiresAt` | — |
| Teams badge ("NEW") | STALE | `BottomNavView.cs:149` hardcoded `SetDot(_teamsDot, false)` | Nice-to-have |
| Home badge (mail unread) | MISSING | `BottomNavView.cs:150` hardcoded false; no `IMailService.UnclaimedCount` binding | **Blocker** |
| Venue badge | OK | `BottomNavView.cs:151–152` reads `IVenueService.PendingClaimable.Count` | — |
| Albums badge | OK | `BottomNavView.cs:153–154` reads `IFtueService.AlbumFirstViewPending` | — |
| Tap routing | OK | `BottomNavView.cs:80–97` per-button `IUIRouter.GoTo` | — |

**Reactivity:** `RefreshActive()` runs every Update — correct for routing state. `Refresh()` (badges) is called only `OnEnable` + `OnSaved` (`BottomNavView.cs:102–109`); mail badge won't update mid-session, Venue claim requires manual rebind.

---

## Routing & reactivity findings

### `IUIRouter`
`IUIRouter.cs:7` exposes only `Current` and `GoTo(id)` — no `OnPanelChanged` event. BottomNav works via Update polling. Cleaner design would emit a panel-changed event; current pattern is safe but inefficient (nice-to-have).

### Event subscription gaps
1. **`ICurrencyService`** — no `OnCoinsChanged` / `OnStarsChanged` events.
2. **`IMailService`** — no `OnUnclaimedCountChanged`. BottomNav cannot reactively show mail badge.
3. **`IStarRaceService`** — `OnChanged` exists per the agent's read (Task 5 rewrite), but HudBar has no Star Race binding at all.
4. **`ILuckyBoxService`** — not referenced from HudBar.
5. **`IDailyLoginService`** — not referenced from HudBar.

design-v7.0 §15 mandates reactive currency rows; current implementation reads once per panel-enter.

### Correctly absent (v7 doesn't have them either)
- Gold in HudBar (v7 keeps Gold in Shop/ante only).
- Gems (out of MVP scope).

---

## Recommended fix tasks

### Blocker — Phase 7B Task 8.5

1. **[M] Add Stars to HudBar + bind to `ICurrencyService`** — add `_starsLabel`, subscribe to `OnStarsChanged` (create event), update on Save + event.
2. **[M] Add Mail badge to BottomNav + bind to `IMailService`** — add `_mailBadge` (or repurpose unused `_homeDot`), subscribe to `OnUnclaimedCountChanged` (create event), show when `UnclaimedCount > 0`.
3. **[M] Make Coins / Stars reactive** — add `event Action OnCoinsChanged`, `event Action OnStarsChanged` to `ICurrencyService`, emit in mutators, subscribe in HudBar.
4. **[M] Add Star Race chip to HudBar** — bind `IStarRaceService.GetStarsByArena(currentArenaIdx)` + `GetSyntheticPercentile(...)`, format `{stars}★ · Top {pct}%`, subscribe to `OnChanged`. (Note: post-Task 5, the chip moves from HomePanel to HudBar — confirm with design before shipping.)

### Important — Next sprint
5. **[S] Add `OnUnclaimedCountChanged` event to `IMailService`** — emit on `Add` and `Claim`.
6. **[S] Username field** — bind once Phase 8 ships username.
7. **[S] Daily Login streak indicator** in HudBar.
8. **[S] Lucky Box meter** — likely on Home (HudBar space-constrained), bind `ILuckyBoxService`.

### Nice-to-have
9. **[S] Replace BottomNav Update polling with `IUIRouter.OnPanelChanged` event** — small perf win, cleaner code.

---

## Evidence index

| File | Line(s) | Finding |
|---|---|---|
| `HudBarView.cs` | 34–85 | One-shot `Start()`/`OnEnable` refresh; only `OnSaved` sub |
| `HudBarView.cs` | 67–85 | Coins/Trophies updated in `Refresh()` only — no event loop |
| `HudBarView.cs` | 79 | Username hardcoded `"Bartender"` |
| `BottomNavView.cs` | 102–155 | `RefreshActive()` polls every frame; `Refresh()` one-shot |
| `BottomNavView.cs` | 149–150 | Teams + Home badges hardcoded false |
| `ICurrencyService.cs` | full | No `OnChanged` event |
| `IMailService.cs` | full | No `OnUnclaimedCountChanged` event |
| `IStarRaceService.cs` | full | `OnChanged` exists; HudBar doesn't use it |
| `IUIRouter.cs` | 7 | No `OnPanelChanged` event |
| `design-v7.0-patch-match-masters-refactor.md` | §15 | "Currency row updates reactively" — design intent |
| `index-v7.html` | 833–848 | HUD: avatar, name, trophies, coins, stars (no gold, gems, mail) |
| `index-v7.html` | 1115–1121 | BottomNav: 5 tabs, each with badge slot |

---

**Disposition:** Ship 4 blocker fixes as Task 8.5 in this phase if scope allows; otherwise roll to Phase 7C. Important items can wait. Nice-to-have is post-launch.
