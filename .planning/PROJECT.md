# Tools Cat

## What This Is

Tools Cat is a personal macOS menu bar utility for two everyday jobs: keeping the display awake and waking devices on the local network with Wake-on-LAN. It now has a hardened native baseline with saved-device management, truthful status feedback, explicit verification boundaries, user-managed timed keep-awake durations, and a consistent shipped identity across the app, automation, and planning surface.

## Core Value

From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## Current State

- Shipped: `v1.4 Duration UI Polish` on 2026-04-16
- Live product identity: `Tools Cat`
- Latest shipped scope: truthful WOL and keep-awake state, saved-device management, shared saved-device wake flows through `快速 WOL` plus the dedicated `发送 WOL …` row, timed keep-awake, native menu/window polish, planning-truth cleanup, validation rebaseline, explicit verification strategy, full rename closure, the keep-awake menu-truth fix, macOS 14 baseline support, user-managed keep-awake durations with live root-menu synchronization, a native duration-manager list presentation, semantic edit/delete affordances, and a stabilized direct-launch duration-manager smoke path
- Planning state: `v1.5 Device Library UI Parity` is active and scoped for requirements and roadmap definition

## Next Milestone Goals

- Align the WOL device-library management surface with the shipped duration-manager visual language.
- Keep add, edit, and delete affordances semantically obvious and visually consistent across both management windows.
- Preserve saved-device CRUD, reorder behavior, and direct-launch management coverage while polishing the device-library presentation.

## Current Milestone: v1.5 Device Library UI Parity

**Goal:** Make the WOL device-library manager feel visually and behaviorally consistent with the shipped duration-management surface without reopening saved-device truth or menu behavior.

**Target features:**
- Replace the populated device-library custom stacked list surface with a native list-first presentation that matches the duration manager's current visual contract.
- Style device-row edit and delete controls with the same accent/destructive semantics used in the duration manager.
- Keep add, edit, delete, reorder, and direct-launch device-library behavior stable while tightening UI smoke coverage around the polished surface.

## Latest Shipped Milestone: v1.4 Duration UI Polish

**Result:** The `常亮时长` manager now reads as a native macOS list, the row actions communicate edit versus delete intent immediately, and the shipped CRUD and keep-awake menu truth remain intact.

**Delivered:**
- Replaced the custom populated timed-duration stack with a native SwiftUI `List` while preserving the manager shell and accessibility seams.
- Styled `编辑` with the app accent color and kept `删除` destructive so the row actions are semantically obvious without adding decorative chrome.
- Stabilized the direct-launch duration-manager smoke and reran the full Phase 14 regression slice cleanly.

<details>
<summary>Previous shipped milestone: v1.3 Duration Management</summary>

**Result:** The app now treats timed keep-awake durations as managed user data instead of fixed presets, and the shipped native management flow keeps the root menu truthful without reopening the broader wake surface.

**Delivered:**
- Persist and validate managed durations with exact-once default seeding.
- Ship a dedicated native duration-management window with add, edit, delete, and confirmation flows.
- Keep `无限常亮` fixed first while timed keep-awake rows stay live-synchronized and sorted shortest-to-longest in the root menu.
- Restore macOS 14 deployment-target truth and keep the real 14.8.3 launch check as an explicit manual verification boundary.

<details>
<summary>Previous shipped milestone: v1.2 Menu Truth</summary>

The shipped baseline now keeps the keep-awake action group truthful in idle and active states, and the evidence chain for that behavior is fully closed from implementation through milestone audit.

It delivered:
- Hide `关闭常亮` whenever keep-awake is already off and no stop transition is running
- Preserve one direct `关闭常亮` action for active or stopping keep-awake sessions
- Lock the idle/active keep-awake truth boundary with focused controller regressions, a formal Phase 10 verification report, and closed milestone traceability

The shipped baseline became easier to trust and maintain: current-facing planning docs matched shipped behavior, verification boundaries became explicit, validation debt closed for Phases 01-04, and the live app / automation / documentation surface all aligned on `Tools Cat`.

</details>
</details>

## Requirements

### Validated

- ✓ Keep the display awake from a menu bar toggle — existing
- ✓ Send a Wake-on-LAN magic packet from a native macOS utility window — existing
- ✓ Run as a lightweight menu bar app without a main document window — existing
- ✓ Manual Wake-on-LAN entry now validates in real time with exact user-facing format errors — validated in Phase 1
- ✓ Wake results now describe local send success or failure without implying the target device woke — validated in Phase 1
- ✓ Keep-awake menu state now follows confirmed assertion outcomes instead of optimistic UI toggles — validated in Phase 1
- ✓ Save and manage multiple Wake-on-LAN devices locally without editing source code — validated in Phase 2
- ✓ Add editable device notes so devices are easy to identify at a glance — validated in Phase 2
- ✓ Remember recently used saved devices to reduce repetitive input and reopen the WOL window with the right context — validated in Phase 3
- ✓ Make Wake-on-LAN flows stable enough for daily use, including accurate status and duplicate-send protection across menu and window surfaces — validated in Phase 3
- ✓ Ship timed keep-awake with explicit duration presets, live countdown feedback, immediate replacement, and automatic expiry — validated in Phase 4
- ✓ Planning and verification docs now reflect the shipped `快速 WOL` / `发送 WOL …` wake surface without stale recents/menu-path claims — validated in Phase 6
- ✓ Menu-bar entry flows now have an explicit, durable layered regression strategy — validated in Phase 7
- ✓ Phase 01-04 validation artifacts now match actual coverage, wave-0 truth, and explicit ownership — validated in Phase 8
- ✓ Rename the shipped app, current planning docs, automation scripts, and packaging outputs to `Tools Cat` without breaking saved-device persistence or regression coverage — validated in Phase 9
- ✓ Keep-awake idle menus no longer show `关闭常亮` when there is no active session to stop — validated in Phase 10 and closed through Phase 11 verification
- ✓ Active or stopping keep-awake sessions still expose one clear `关闭常亮` action from the menu — validated in Phase 10 and closed through Phase 11 verification
- ✓ The keep-awake menu-truth contract is now locked by focused regression coverage and formal traceability — validated in Phase 10 and closed through Phase 11 verification
- ✓ User can manage timed keep-awake durations without affecting the fixed `无限常亮` action — validated in v1.3
- ✓ The keep-awake menu now renders timed rows from the managed duration list in ascending duration order — validated in v1.3
- ✓ Managed durations are validated, persisted, and reflected correctly after add/edit/delete operations — validated in v1.3
- ✓ User can scan managed keep-awake durations inside a clearly native macOS list surface instead of rows blending into the window background — validated in Phase 14
- ✓ User can distinguish edit versus delete actions immediately through semantic styling, with edit in the app theme color and delete in destructive red — validated in Phase 14
- ✓ User can use the polished list UI without regressing existing add, edit, delete, sorting, or live root-menu sync behavior — validated in Phase 14

### Active

- [ ] User sees saved WOL devices inside a clearly native list surface that matches the duration manager's shipped list treatment
- [ ] User sees device-library add, edit, and delete affordances styled consistently with the duration manager's current add/edit/delete semantics
- [ ] User can use the polished device-library UI without regressing saved-device add, edit, delete, reorder, or direct-launch management behavior

### Out of Scope

- Cross-platform support — this tool is intentionally optimized for personal macOS use
- Cloud sync, accounts, or shared device management — unnecessary complexity for a self-use utility
- Broad marketplace-style device discovery or fleet management — the goal is quick access to a small personal set of devices
- Restoring root-level recent-device wake shortcuts outside the shipped `快速 WOL` / `发送 WOL …` structure during the completed hardening cycle — deferred and tracked as `CONV-04`
- Reopening the duration data model, validation rules, or root-menu behavior in this milestone — v1.3 already shipped those contracts; this pass is UI polish only
- Pulling in a third-party component library before exhausting the native macOS list/table components — native consistency and lower maintenance take priority
- Public-distribution polish as the primary milestone — signing/notarization matters later, but current scope is daily-use quality first

## Context

This is a brownfield macOS app with an existing codebase map under `.planning/codebase/`. The current app already ships two core capabilities: display-sleep prevention through `PowerAssertionManager` and WOL packet sending through `WOLSender`, exposed via an AppKit status bar menu and a SwiftUI-hosted WOL window.

The implementation remains optimized for one person's usage and shows that in several ways: WOL preset data started as hardcoded UI data, window lifecycle is coordinated with notifications, and core system interactions are only lightly abstracted. The recent milestones moved the project from functional-but-fragile to a more trustworthy daily baseline without changing its intentionally local, native, personal-use scope.

Phase 1 completed the trust layer for manual WOL entry and keep-awake status: validation and send feedback now come from explicit contracts, the WOL window keeps an app-session state owner, and keep-awake visuals wait for confirmed power-assertion outcomes.

Phase 2 added a local saved-device library with native CRUD, notes, ordering, and a dedicated management window. Phase 3 turned that library into the fast daily wake path: the shipped menu keeps saved-device wake actions under `快速 WOL`, keeps the dedicated `发送 WOL …` row for manual or window-driven sends, shares one retained session across the menu and WOL window, keeps the last truthful local result visible, and restores the last-used saved-device context when reopening the WOL window without stealing unfinished manual drafts.

Phase 4 completed timed keep-awake as a first-class menu feature: the root menu now offers explicit Chinese preset rows, one shared keep-awake session drives icon/status truth, countdown feedback stays confined to the disabled status row, and timed sessions can be replaced or expire back to off without extra banners.

The v1.0 roadmap work is archived. A follow-on idea to restore root-level recent-device wake shortcuts was intentionally removed from the hardening cycle, so the shipped wake surface remains `快速 WOL` plus the dedicated `发送 WOL …` row. Any shortcut recovery work now belongs to a later planning cycle under `CONV-04`.

The v1.1 hardening work made the verification boundary explicit instead of implying stronger automation than the repo has. Controller tests cover menu grouping and root entry dispatch, direct-launch UI smoke covers the retained `WOL 发送器` and `设备库` windows through launch arguments, and manual tray-entry checks still own the real live `NSStatusItem` click path.

The v1.2 milestone kept scope intentionally narrow: it fixed a keep-awake truth leak inside the already-shipped menu contract, where the idle menu still showed `关闭常亮` even though there was nothing to stop.

The v1.3 milestone then converted timed keep-awake from fixed presets into managed persisted data. Phase 12 established the canonical duration store and fixed-row bridge, Phase 12.1 restored the real macOS 14 compatibility baseline, and Phase 13 shipped the native duration-management flow plus live root-menu synchronization and final visual polish.

The v1.4 milestone is intentionally narrower again: it does not reopen duration persistence or keep-awake behavior. It only revisits the `常亮时长` manager presentation so the timed list can lean harder on native list semantics and clearer edit/delete affordances.

Phase 9 completed the live rename to `Tools Cat`: the Xcode project, targets, module, bundle IDs, regression scripts, release packaging defaults, and active docs now agree on one product identity. Historical workflow-stability exception: the planning artifact directory remains `.planning/phases/09-mac-os-swiss-knife-tools-cat/`.

## Constraints

- **Platform**: macOS menu bar app — the product should stay native to the existing AppKit/SwiftUI environment
- **Use case**: Personal daily-use utility — scope should optimize for one user's repeated workflows, not multi-tenant generalization
- **UX direction**: Small, restrained, polished — UI changes should feel native macOS rather than flashy or cross-platform
- **Reliability**: Core menu state must reflect real system/network state — false success is unacceptable for keep-awake and WOL actions
- **Maintainability**: New functionality should reduce coupling, not deepen it — architecture work must create clearer seams around UI state and side effects

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Keep the project focused on personal self-use | The user wants a dependable personal utility, not a generalized product surface | Active |
| Prioritize WOL device management and reliability before distribution polish | Daily usability was the immediate bottleneck and hardening needed to follow shipped functionality | Validated in Phases 1-9 |
| Preserve a native macOS visual language | The desired UX is small, restrained, and polished rather than highly branded or flashy | Active |
| Use architecture cleanup as an enabler, not a separate rewrite | Device management and stable UI flows ship faster when system/network logic is separated from views and controllers | Validated in Phases 1-3 |
| Keep saved-device management in a dedicated native surface instead of deep menu editing | CRUD and reorder flows need more space and clearer state ownership than a compact menu can provide | Validated in Phase 2 |
| Keep shipped saved-device waking behind `快速 WOL` and preserve the dedicated `发送 WOL …` row | The current menu stays compact without presenting removed root-level recents / `所有设备` behavior as shipped truth | Validated in Phases 3-9 |
| Share one retained `WOLSessionModel` across the menu and WOL window | Wake status and duplicate-send blocking must come from one source of truth across surfaces | Validated in Phase 3 |
| Share one retained `KeepAwakeSessionModel` across app launch and render keep-awake UI from `KeepAwakePresentation` | Timed keep-awake must stay truthful across menu actions, countdown updates, replacement, and quit handling | Validated in Phase 4 |
| Defer root-level recent-device tray recovery to a future milestone | Hardening closed without restoring shortcut rows, so any recovery now belongs to `CONV-04` | Decided 2026-04-13 |
| Keep menu-bar verification layered instead of implying live tray automation | Controller seams and direct-launch UI smoke are automated; live tray-entry coverage remains manual | Validated in Phase 7 |
| Treat validation debt closure as documentation-truth work, not new harness work | Phase 8 only needed validation contracts rewritten to match current evidence | Validated in Phase 8 |
| Keep runtime storage on `UserDefaults.standard` and treat the legacy bundle-ID suite only as a one-time migration source | Using the app bundle identifier as a custom defaults suite causes macOS warnings and breaks the intended storage model | Validated in Phase 9 |
| Pass `-project "Tools Cat.xcodeproj"` through release automation | Rename residue can temporarily leave multiple project directories in the worktree, so the release path must be explicit | Validated in Phase 9 |
| Keep MENU traceability anchored to the phase that shipped the behavior, even when a later closure phase only fixes verification debt | Phase 11 closes documentation truth without pretending it shipped the runtime keep-awake change | Validated in Phase 11 |
| Keep timed keep-awake durations as persisted user data instead of fixed menu presets | Users need duration customization and persistence without turning the root menu into a CRUD surface | Validated in Phases 12-13 |
| Keep duration CRUD in a dedicated native management window while `无限常亮` stays outside the managed list | Timed-duration editing needs validation, list clarity, and confirmation flows that do not fit a compact root menu | Validated in Phase 13 |
| Pull live managed-duration root-menu sync into Phase 13 and remove standalone Phase 14 | The milestone needed shipped CRUD truth in the root menu, and verification proved the separate follow-on phase was redundant | Validated in v1.3 |
| Prefer native macOS list components and semantic button colors for duration-manager polish | This milestone is visual refinement of an existing native surface, so platform-consistent affordances beat extra UI-library complexity | Validated in Phase 14 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-16 after starting milestone v1.5 Device Library UI Parity*
