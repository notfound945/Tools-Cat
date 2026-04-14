---
phase: 05-native-menu-polish
plan: 01
subsystem: ui
tags: [swift, appkit, menu-bar, xctest, wol, keep-awake]
requires:
  - phase: 03-saved-device-wake-flows
    provides: compact recent-device wake rows, full-library wake access, and durable wake result state
  - phase: 04-timed-keep-awake
    provides: fixed keep-awake root actions and presentation-driven keep-awake status rendering
provides:
  - three-section native status menu anchors with exactly two separators
  - idle collapse for keep-awake and wake status rows
  - truthful wake status visibility even when no saved devices exist
affects: [phase-05-plan-02, native-menu-polish, menu-bar ui, controller tests]
tech-stack:
  added: []
  patterns: [fixed AppKit menu anchors with dynamic wake rows, controller-level menu contract regression coverage]
key-files:
  created:
    - .planning/phases/05-native-menu-polish/05-01-SUMMARY.md
    - Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift
  modified:
    - Mac OS Swiss Knife/StatusBarController.swift
    - Mac OS Swiss Knife.xcodeproj/project.pbxproj
    - Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift
key-decisions:
  - "Keep the root menu anchored as keep-awake, wake, then management with separators outside the dynamic wake rebuild path."
  - "Always create the wake status row so truthful manual-send feedback can appear even when the saved-device library is empty."
patterns-established:
  - "StatusBarController keeps permanent section boundaries and only inserts wake rows around the fixed manual-send anchor."
  - "Controller regressions may retain AppKit fixtures for test-process lifetime when XCTest teardown trips actor-owned session deallocation."
requirements-completed: [UX-01]
duration: 15 min
completed: 2026-04-12
---

# Phase 05 Plan 01: Native Menu Contract Summary

**Three-section native status menu with fixed separators, compact idle density, and truthful wake feedback even without saved devices**

## Performance

- **Duration:** 15 min
- **Started:** 2026-04-12T08:20:30Z
- **Completed:** 2026-04-12T08:35:53Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added dedicated controller regressions for the Phase 5 menu contract, covering separator order, idle collapse, empty-library wake feedback, and management-row placement.
- Refactored the status menu into fixed keep-awake, wake, and management groups with exactly two native separators and dynamic wake rows inserted only inside the wake section.
- Kept wake feedback truthful by rendering the disabled wake status row independently of saved-device availability, while preserving keep-awake presentation semantics and existing wake-send behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add dedicated controller regression coverage for the Phase 5 menu contract** - `37a0839` (`test`)
2. **Task 2: Rebuild the root menu around fixed section anchors and on-demand status density** - `1ba82b9` (`feat`)

**Plan metadata:** Pending final docs commit

_Note: Task 1 is the RED-side TDD commit for the menu contract; Task 2 makes the slice green._

## Files Created/Modified

- `Mac OS Swiss Knife/StatusBarController.swift` - Pins the root menu to fixed section anchors, rebuilds wake rows around the manual-send row, and keeps wake status independent from library size.
- `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift` - Locks the Phase 5 separator contract, idle collapse rules, empty-library wake status behavior, and management-row ordering.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - Registers the dedicated menu-polish regression file in the unit-test target.
- `Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift` - Updates the existing keep-awake controller regression to the new separator-backed root-menu index.

## Decisions Made

- Kept the two section separators permanent and outside `rebuildWakeMenu()` so wake-library changes cannot disturb the top-level keep-awake or management anchors.
- Left the keep-awake status row fully presentation-driven and only changed wake-section structure and visibility rules, which preserves Phase 4 truth semantics.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Retained menu-polish controller fixtures to avoid XCTest teardown aborts**
- **Found during:** Task 2 (Rebuild the root menu around fixed section anchors and on-demand status density)
- **Issue:** The new controller regression suite crashed during teardown because `WOLSessionModel` deallocation hit a libmalloc abort inside XCTest's scope cleanup.
- **Fix:** Retained `StatusBarController` fixtures for the test-process lifetime inside `StatusBarControllerMenuPolishTests` so the controller/session graph no longer deallocates during the XCTest cleanup path.
- **Files modified:** `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift`
- **Verification:** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'`
- **Committed in:** `1ba82b9`

**2. [Rule 3 - Blocking] Updated the legacy keep-awake index regression to match the new wake section boundary**
- **Found during:** Task 2 (Rebuild the root menu around fixed section anchors and on-demand status density)
- **Issue:** The existing keep-awake controller test still expected the manual WOL row immediately after the keep-awake status row, which is no longer true once the new separator-backed wake section is in place.
- **Fix:** Adjusted the expected `wolMenuIndexForTesting` value in the existing keep-awake regression so the suite verifies the new fixed-section contract instead of the pre-Phase-5 layout.
- **Files modified:** `Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift`
- **Verification:** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'`
- **Committed in:** `1ba82b9`

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Both auto-fixes were required to complete the planned controller refactor and keep the regression slice stable. No scope creep.

## Issues Encountered

- `xcodebuild` reported a pre-existing unused-result warning in `Mac OS Swiss Knife/AppDelegate.swift` during Task 2 verification. It is outside this plan's file ownership and did not block the controller slice.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The root status menu now satisfies the locked Phase 5 controller contract and is ready for the window-polish work in `05-02`.
- Dedicated controller regressions are in place for separator order, idle compactness, and truthful manual-only wake feedback, which narrows future changes to visual/window polish instead of menu structure.

## Self-Check: PASSED

- Found `.planning/phases/05-native-menu-polish/05-01-SUMMARY.md`
- Found task commits `37a0839` and `1ba82b9` in git history

---
*Phase: 05-native-menu-polish*
*Completed: 2026-04-12*
