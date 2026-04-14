---
phase: 02-device-library-management
plan: 02
subsystem: ui
tags: [swiftui, appkit, xctest, macos, wol]
requires:
  - phase: 01-truthful-foundations
    provides: retained window/session patterns, truthful validation contracts, and targeted XCTest coverage
provides:
  - Dedicated `设备库` AppKit window retained independently from the WOL sender
  - Compact SwiftUI list/form manager UI for add, edit, delete confirmation, and reorder mode
  - Exact-copy presentation contract and unit tests for manager labels and confirmation text
affects: [02-03, saved-device wake flows, native menu polish]
tech-stack:
  added: []
  patterns: [retained-window-controller, observedobject-session-ui, presentation-copy-contract]
key-files:
  created:
    - Mac OS Swiss Knife/DeviceLibraryManagementPresentation.swift
    - Mac OS Swiss Knife/DeviceLibraryView.swift
    - Mac OS Swiss Knife/DeviceLibraryWindow.swift
    - Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests.swift
  modified:
    - Mac OS Swiss Knife/AppDelegate.swift
    - Mac OS Swiss Knife/StatusBarController.swift
    - Mac OS Swiss Knife/DeviceLibrarySessionModel.swift
    - Mac OS Swiss Knife.xcodeproj/project.pbxproj
key-decisions:
  - "Keep device management in a second retained native window owned by AppDelegate so it stays independent from the WOL sender."
  - "Model the manager as one shared SwiftUI surface with only list and form modes, using an explicit reorder toggle to gate drag moves and row actions."
patterns-established:
  - "Presentation copy contract: exact visible manager strings live in a dedicated enum and are locked by focused XCTest coverage before UI wiring."
  - "Window lifecycle ownership: AppDelegate retains one shared store, one session model, and one NSWindowController per tool surface."
requirements-completed: [UX-02, DEVS-02, DEVS-03, DEVS-04, DEVS-05, RELY-01]
duration: 7min
completed: 2026-04-11
---

# Phase 02 Plan 02: Device Library Manager Summary

**Dedicated native device-library management window with locked copy, list/form CRUD flow, delete confirmation, and explicit reorder mode from the menu bar**

## Performance

- **Duration:** 7 min
- **Started:** 2026-04-11T11:03:20Z
- **Completed:** 2026-04-11T11:09:53Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Added an exact-copy presentation contract and focused tests for the manager window labels, form titles, reorder toggle, and delete confirmation text.
- Built a dedicated `设备库` AppKit window hosting a compact SwiftUI list/form management surface with empty, populated, form, reorder, and delete-confirm states.
- Wired a new `管理设备…` status-menu entry through `StatusBarController` and `AppDelegate` while keeping the management window independent from the existing WOL window.

## Task Commits

Each task was committed atomically:

1. **Task 1: Lock the manager-window copy and state labels with presentation tests** - `04267fa` (test), `c420d37` (feat)
2. **Task 2: Wire the compact management window, list/form flow, and menu entry** - `87f118c` (feat)

## Files Created/Modified
- `Mac OS Swiss Knife/DeviceLibraryManagementPresentation.swift` - Central copy contract for the device manager UI.
- `Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests.swift` - Focused exact-copy tests for manager labels and confirmation text.
- `Mac OS Swiss Knife/DeviceLibraryWindow.swift` - Retained native AppKit window controller for the device library.
- `Mac OS Swiss Knife/DeviceLibraryView.swift` - SwiftUI management surface with list, empty-state, form, reorder, and delete-alert behavior.
- `Mac OS Swiss Knife/DeviceLibrarySessionModel.swift` - Added derived form-mode and validation helpers used by the manager UI.
- `Mac OS Swiss Knife/AppDelegate.swift` - Retains the shared saved-device store, manager session, and manager window.
- `Mac OS Swiss Knife/StatusBarController.swift` - Adds the `管理设备…` menu entry and callback wiring.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - Registers the new presentation contract/test files in the synchronized Xcode groups.

## Decisions Made
- Retained the manager as a separate utility window instead of merging device management into the WOL sender, matching the phase context and preserving independent windows.
- Reused the existing `DeviceLibrarySessionModel` and store seam rather than creating a parallel UI-specific model, so validation and persistence remain consistent with Phase 2 foundations.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Replaced unavailable macOS edit-mode wiring with a move-disabled reorder gate**
- **Found during:** Task 2 (Wire the compact management window, list/form flow, and menu entry)
- **Issue:** SwiftUI's `EnvironmentValues.editMode` is unavailable on macOS, which blocked the initial reorder-mode implementation from compiling.
- **Fix:** Kept the explicit reorder mode but gated row moving with `moveDisabled(!session.isReordering)` on the `ForEach`, while also suppressing edit/delete actions during reorder mode.
- **Files modified:** `Mac OS Swiss Knife/DeviceLibraryView.swift`
- **Verification:** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests'`
- **Committed in:** `87f118c`

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The auto-fix was required for a working macOS build and kept the intended reorder interaction without expanding scope.

## Issues Encountered
- SwiftUI list reordering APIs differ on macOS from iOS-oriented examples; the final implementation uses a macOS-safe move gate instead of environment edit mode.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- The app now exposes a real native saved-device manager with shared store/session ownership, ready for Phase 02 Plan 03 to replace the hardcoded WOL preset list.
- The main residual risk is manual UX verification of drag-handle behavior and independent-window presentation, which remains outside the current automated unit scope.

## Self-Check
PASSED

---
*Phase: 02-device-library-management*
*Completed: 2026-04-11*
