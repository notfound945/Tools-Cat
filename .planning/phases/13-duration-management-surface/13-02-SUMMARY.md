---
phase: 13-duration-management-surface
plan: 02
subsystem: ui
tags: [swiftui, appkit, menu-bar, xcuitest, keep-awake]
requires:
  - phase: 13-01
    provides: "The shared duration-management session model and CRUD validation contract."
provides:
  - "Native duration-management window and SwiftUI CRUD surface"
  - "Status-menu entry and app callback path for opening the duration manager"
  - "Direct-launch UI smoke and controller/menu regression coverage"
affects: [phase-14-managed-duration-menu-integration, keep-awake-management, status-menu]
tech-stack:
  added: []
  patterns:
    - "New utility surfaces open through AppDelegate-owned reusable windows and lightweight status-menu callbacks."
key-files:
  created:
    - Tools Cat/KeepAwakeDurationManagementView.swift
    - Tools Cat/KeepAwakeDurationManagementWindow.swift
  modified:
    - Tools Cat.xcodeproj/project.pbxproj
    - Tools Cat/AppDelegate.swift
    - Tools Cat/StatusBarController.swift
    - Tools CatTests/StatusBarControllerEntryFlowTests.swift
    - Tools CatTests/StatusBarControllerMenuPolishTests.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Open the duration manager through a dedicated root-menu row named `管理常亮时长…`, parallel to the existing WOL and device-library management entries."
  - "Keep the fixed keep-awake root rows untouched in Phase 13; the manager mutates the shared store, but dynamic root-menu rendering still waits for Phase 14."
patterns-established:
  - "Direct-launch UI smoke for native windows uses launch arguments plus the isolated defaults-suite harness already used by the device library."
  - "Status-menu integration remains callback-based, so `StatusBarController` does not own secondary window lifetime."
requirements-completed: []
duration: 7 min
completed: 2026-04-15
---

# Phase 13 Plan 02: Duration Management Surface Summary

**The app now exposes a real native duration-management window from both direct launch and the status menu, while leaving Phase 14’s dynamic root-menu work untouched**

## Performance

- **Duration:** 7 min
- **Started:** 2026-04-15T16:28:58+08:00
- **Completed:** 2026-04-15T16:35:35+08:00
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Added `KeepAwakeDurationManagementView` as a SwiftUI list/form/delete surface for timed durations only.
- Added `KeepAwakeDurationManagementWindow` as a reusable native window controller that reloads the shared session before showing.
- Wired one shared manager session and window into `AppDelegate`, including a new direct-launch UI-test flag.
- Added a new status-menu row `管理常亮时长…` and routed it through a dedicated callback path.
- Extended UI and controller regression coverage so the management surface is proven through both direct launch and menu-entry dispatch.
- Updated menu-polish tests to account for the new management row while preserving the existing root-menu section boundaries and last-row quit contract.

## Task Commit

The two tightly coupled UI and integration tasks shipped together because the shared `AppDelegate` composition path spans both:

1. **Tasks 1-2: Add the native duration-management surface and wire it into the status menu** - `43efc0f` (feat)

## Files Created/Modified

- `Tools Cat/KeepAwakeDurationManagementView.swift` - Renders the timed-duration list, add/edit form, delete alert, and accessibility markers for UI smoke coverage.
- `Tools Cat/KeepAwakeDurationManagementWindow.swift` - Owns the reusable native window and reload-before-show behavior.
- `Tools Cat/AppDelegate.swift` - Composes the shared manager session/window, adds the direct-launch flag, and routes the status-menu callback into the new window.
- `Tools Cat/StatusBarController.swift` - Adds the `管理常亮时长…` entry and callback dispatch path.
- `Tools CatTests/StatusBarControllerEntryFlowTests.swift` - Verifies the new management entry dispatches through the callback seam.
- `Tools CatTests/StatusBarControllerMenuPolishTests.swift` - Verifies the new row fits inside the existing post-keep-awake utility section without breaking separators or quit placement.
- `Tools CatUITests/Tools_CatUITests.swift` - Adds a direct-launch smoke proving the seeded timed durations and add form render in the native manager window.
- `Tools Cat.xcodeproj/project.pbxproj` - Registers the new view/window Swift files in the synced project roots.

## Decisions Made

- Reused the repo’s `DeviceLibraryWindow` pattern rather than embedding CRUD UI into the menu, keeping the duration manager small and native.
- Used visible button titles and field labels in the XCUITest assertions where macOS accessibility proved more stable than custom SwiftUI identifiers for some controls.

## Deviations from Plan

- The two planned tasks were committed together instead of separately because `AppDelegate` needed to compose the new window and the new menu callback as one coherent integration path. No functional scope was dropped.

## Issues Encountered

- The initial UI smoke used custom accessibility identifiers for the add button and form-action container. On macOS XCUITest, those controls exposed their visible titles more reliably than the custom identifiers, so the test was adjusted to query the user-facing labels instead.

## User Setup Required

None.

## Next Phase Readiness

- Phase 13 is fully implemented and ready for formal `verify-work`.
- Phase `14` can now replace the fixed timed root rows with store-driven rows without needing new manager UI or persistence work.

## Self-Check: PASSED

---
*Phase: 13-duration-management-surface*
*Completed: 2026-04-15*
