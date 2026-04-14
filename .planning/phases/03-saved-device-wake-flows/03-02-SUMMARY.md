---
phase: 03-saved-device-wake-flows
plan: 02
subsystem: ui
tags: [macos, appkit, wol, menu-bar, xctest]
requires:
  - phase: 03-01
    provides: shared saved-device recents state, durable wake result state, and one retained WOL session
provides:
  - compact recent-device wake rows in the menu bar
  - full saved-device wake access under `所有设备`
  - persistent wake status feedback in the status menu
affects: [phase-03-plan-03, phase-05-native-menu-polish, saved-device-wake-flows]
tech-stack:
  added: []
  patterns: [shared app delegate injection for menu controllers, menu-bar wake actions driven by one retained WOL session, targeted XCTest menu regression coverage]
key-files:
  created: [.planning/phases/03-saved-device-wake-flows/03-02-SUMMARY.md]
  modified:
    - Mac OS Swiss Knife/AppDelegate.swift
    - Mac OS Swiss Knife/StatusBarController.swift
    - Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests.swift
key-decisions:
  - Keep the root status menu compact with up to three recent wake rows and move the full library into an `所有设备` submenu.
  - Drive menu wake actions and status feedback from the same retained `WOLSessionModel` used by the WOL window so duplicate sends stay blocked everywhere.
patterns-established:
  - Status bar menu sections can subscribe to shared observable models and rebuild their dynamic items from canonical store/session state.
  - Durable wake feedback in native menus should come from `lastCompletedWake` rather than inferred strings or separate transient callbacks.
requirements-completed: [WOL-01, WOL-04, RELY-04, UX-03]
duration: 12 min
completed: 2026-04-12
---

# Phase 03 Plan 02: Saved-Device Wake Flows Summary

**Compact saved-device wake actions with recent-device shortcuts, full-library access, and persistent truthful wake status in the menu bar**

## Performance

- **Duration:** 12 min
- **Started:** 2026-04-12T10:57:08+08:00
- **Completed:** 2026-04-12T11:09:24+08:00
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Injected the shared `SavedDeviceLibraryStore` and `WOLSessionModel` into the status bar controller so menu wake actions reuse the same retained session as the WOL window.
- Added a compact recent-devices section plus an `所有设备` submenu so every saved device stays wakeable without crowding the root menu.
- Added a disabled persistent wake-status row that shows in-flight send feedback and preserves the last truthful local success or failure message.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add compact recent-device wake actions plus the full-library path to the status menu** - `d1b423e` (test), `f0c169c` (feat)
2. **Task 2: Add the persistent wake-status row to the status menu** - `320c6ab` (test), `da07785` (feat)

**Plan metadata:** Pending final docs commit

_Note: TDD tasks include separate RED and GREEN commits._

## Files Created/Modified

- `Mac OS Swiss Knife/AppDelegate.swift` - passes the shared device library and shared WOL session into the status bar controller at launch.
- `Mac OS Swiss Knife/StatusBarController.swift` - renders recent wake rows, the `所有设备` submenu, disabled in-flight states, and the persistent wake status row from shared session state.
- `Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests.swift` - locks the menu behavior with regression coverage for recents, shared-session dispatch, disabled sends, and persistent status-row messages.

## Decisions Made

- Kept the root menu intentionally short by exposing only up to three recent devices inline and moving the full library behind `所有设备`.
- Reused the retained `WOLSessionModel` for both wake dispatch and menu feedback so the app has one authoritative send state across surfaces.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Preserve the status row across terminal send states**
- **Found during:** Task 2 (Add the persistent wake-status row to the status menu)
- **Issue:** The plan described showing `lastCompletedWake.message` when `sendState` returns to `.idle`, but the current `WOLSessionModel` keeps terminal `.success` and `.failure` states after completion. Following the plan literally would have hidden truthful result feedback.
- **Fix:** Render the persistent status row from `lastCompletedWake` for `.success` and `.failure` as well as the no-send fallback path.
- **Files modified:** `Mac OS Swiss Knife/StatusBarController.swift`
- **Verification:** `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests'`
- **Committed in:** `da07785`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The deviation preserved the plan's intended truthful persistent status behavior against the actual shared-session contract. No scope creep.

## Issues Encountered

- AppKit menu auto-enable behavior initially overrode manual wake-action disabling during in-flight sends. The controller now disables `autoenablesItems` on the root menu and `所有设备` submenu and refreshes wake UI from `wolSession.objectWillChange` on the next main-queue turn.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The menu bar is now a complete saved-device wake surface with shared-session truth and stable recents behavior.
- Phase `03-03` can focus on reopening the WOL window with last-used saved-device defaults without reworking menu dispatch or wake-result state ownership.

## Self-Check: PASSED

- Found `.planning/phases/03-saved-device-wake-flows/03-02-SUMMARY.md`
- Found task commits `d1b423e`, `f0c169c`, `320c6ab`, and `da07785` in git history

---
*Phase: 03-saved-device-wake-flows*
*Completed: 2026-04-12*
