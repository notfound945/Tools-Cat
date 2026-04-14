---
phase: 02-device-library-management
plan: 03
subsystem: ui
tags: [swiftui, appkit, wol, userdefaults, xctest, xcuitest]
requires:
  - phase: 02-device-library-management
    provides: shared saved-device persistence, management window, and library session/store seams
provides:
  - WOL presets now resolve from the shared saved-device library instead of a hardcoded array
  - App launch arguments can open the device-library window against an isolated defaults suite
  - A seeded XCUITest smoke path exists for the management window
affects: [03-saved-device-wake-flows, testing]
tech-stack:
  added: []
  patterns: [shared observable store injection across windows, launch-argument UI smoke seams]
key-files:
  created: []
  modified:
    - Mac OS Swiss Knife/AppDelegate.swift
    - Mac OS Swiss Knife/WOLSessionModel.swift
    - Mac OS Swiss Knife/WOLView.swift
    - Mac OS Swiss Knife/WOLWindow.swift
    - Mac OS Swiss Knife/SavedDeviceLibraryStore.swift
    - Mac OS Swiss Knife/DeviceLibraryView.swift
    - Mac OS Swiss KnifeTests/WOLSessionModelTests.swift
    - Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift
key-decisions:
  - "Use one retained SavedDeviceLibraryStore for both the WOL window and device manager so saved-device order and identity stay canonical."
  - "Use launch arguments plus an isolated UserDefaults suite to open the manager window deterministically in UI tests."
  - "Switch the app to a regular activation policy only during the UI smoke path so macOS automation can attach to the menu bar app."
patterns-established:
  - "WOL preset selection should track SavedDevice identity (UUID) and resolve the MAC address from the shared store at send time."
  - "Menu bar UI smoke tests can bootstrap native windows through AppDelegate launch arguments instead of menu-bar automation."
requirements-completed: [DEVS-01, DEVS-04, UX-02]
duration: 11min
completed: 2026-04-11
---

# Phase 2 Plan 3: Device Library Management Summary

**Shared saved-device presets now drive Wake-on-LAN selection, and the app can auto-open the device manager against isolated persisted test data**

## Performance

- **Duration:** 11 min
- **Started:** 2026-04-11T11:14:53Z
- **Completed:** 2026-04-11T11:25:38Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Replaced the last hardcoded WOL preset path with the shared `SavedDeviceLibraryStore`, keyed by saved-device `UUID`.
- Injected the shared device library into the WOL window and picker so device order now matches the canonical persisted library.
- Added launch-argument seams for opening the device-library window under XCUITest with an isolated defaults suite and seeded data.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace hardcoded WOL presets with the shared saved-device library** - `85bbe93` (test), `40b33b5` (feat)
2. **Task 2: Add an isolated UI smoke seam for the management window** - `c8c69ac` (feat)

_Note: Task 1 used TDD and therefore produced separate RED and GREEN commits._

## Files Created/Modified
- `Mac OS Swiss Knife/AppDelegate.swift` - Shares the saved-device store between windows and adds UI-test launch-argument handling.
- `Mac OS Swiss Knife/WOLSessionModel.swift` - Tracks preset selection by saved-device ID and resolves the current MAC through the shared store.
- `Mac OS Swiss Knife/WOLView.swift` - Renders picker content directly from `deviceLibrary.devices` in persisted order.
- `Mac OS Swiss Knife/WOLWindow.swift` - Injects the shared saved-device library into the WOL SwiftUI view.
- `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` - Adds device lookup by UUID for WOL preset resolution.
- `Mac OS Swiss Knife/DeviceLibraryView.swift` - Adds accessibility hooks used while building the manager-window smoke path.
- `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` - Covers saved-device preset sends, deleted-device disablement, and manual-mode regressions.
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` - Seeds an isolated defaults suite and launches the manager window directly for smoke coverage.

## Decisions Made

- Shared store injection takes precedence over copying preset data into WOL-specific state so both windows stay in sync while open.
- Preset-mode WOL selection now stores only the selected saved-device ID; the send path resolves the live MAC at the moment of send.
- The UI smoke path uses AppDelegate launch arguments instead of menu-bar automation because the latter is brittle for an `LSUIElement` app.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Enabled regular activation policy for the UI smoke launch path**
- **Found during:** Task 2
- **Issue:** The first targeted UI-test run timed out while enabling automation mode against the menu bar app.
- **Fix:** Switched the app to `.regular` activation only when `--ui-test-open-device-library` is present.
- **Files modified:** `Mac OS Swiss Knife/AppDelegate.swift`
- **Verification:** The targeted XCUITest advanced past automation setup and reached manager-window assertions.
- **Committed in:** `c8c69ac`

**2. [Rule 3 - Blocking] Added explicit accessibility hooks for manager-row smoke assertions**
- **Found during:** Task 2
- **Issue:** SwiftUI list content did not surface as queryable elements in the targeted XCUITest.
- **Fix:** Added row/text accessibility identifiers and switched the smoke to deterministic identifier-based queries.
- **Files modified:** `Mac OS Swiss Knife/DeviceLibraryView.swift`, `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift`
- **Verification:** The smoke still fails on this host, but the failure is now isolated to missing seeded-row visibility rather than launch/automation setup.
- **Committed in:** `c8c69ac`

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both fixes were necessary to make the UI smoke runnable against a menu bar app. No scope creep, but one verification gap remains.

## Issues Encountered

- The targeted UI smoke still fails to observe seeded manager rows in XCUITest after the app window opens successfully. The remaining uncertainty is whether the isolated suite data is not visible cross-process under the sandbox or whether SwiftUI `List` accessibility is still collapsing the seeded rows on this host.

## Deferred Issues

- `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` still fails because the seeded device-library rows are not queryable in the launched app, even though the `设备库` window opens.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 3 can now treat the saved-device library as the WOL source of truth without another preset migration.
- Before using the manager-window smoke as a hard gate, the seeded-row visibility problem in XCUITest should be resolved.

## Self-Check: PASSED

- Found `.planning/phases/02-device-library-management/02-03-SUMMARY.md`
- Found commit `85bbe93`
- Found commit `40b33b5`
- Found commit `c8c69ac`
