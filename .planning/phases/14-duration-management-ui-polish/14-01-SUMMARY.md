---
phase: 14-duration-management-ui-polish
plan: 01
subsystem: ui
tags: [swiftui, macos, list, xctest]
requires:
  - phase: 13-duration-management-surface
    provides: shared duration-manager shell, CRUD flow, and accessibility seams
provides:
  - native SwiftUI List presentation for populated keep-awake durations
  - stable UI smoke coverage for the add sheet over the live duration list
affects: [keep-awake-duration-management, ui-smoke-tests]
tech-stack:
  added: []
  patterns: [native SwiftUI List in retained manager shell, app-level sheet assertions in macOS UI smoke]
key-files:
  created: [.planning/phases/14-duration-management-ui-polish/14-01-SUMMARY.md]
  modified:
    - Tools Cat/KeepAwakeDurationManagementView.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Use a native SwiftUI List for populated durations and remove the custom card stack instead of restyling the old ScrollView surface."
  - "Keep the existing list surface and row accessibility identifiers stable while moving add-sheet assertions to app scope for reliable macOS sheet detection."
patterns-established:
  - "Duration manager list polish stays inside the existing SwiftUI view and leaves CRUD/store/menu behavior untouched."
  - "macOS sheet smoke checks should query the app tree when sheet content is presented outside the titled window subtree."
requirements-completed: [AWAKE-14]
duration: 6 min
completed: 2026-04-16
---

# Phase 14 Plan 01: Native Duration List Summary

**Native SwiftUI `List` presentation for managed keep-awake durations with a smoke test that still proves the live add sheet overlays on top of the manager window**

## Performance

- **Duration:** 6 min
- **Started:** 2026-04-16T03:20:00Z
- **Completed:** 2026-04-16T03:26:15Z
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments
- Replaced the populated timed-duration `ScrollView` and `LazyVStack` region with a native SwiftUI `List`.
- Removed bespoke rounded-card row chrome so the manager reads as a true macOS list while preserving the existing shell and row actions.
- Kept the focused UI smoke green by anchoring add-sheet assertions to app-level sheet content instead of the titled window subtree.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace the custom timed-duration stack with a native macOS list presentation** - `78767fa` (feat)

**Plan metadata:** pending docs commit

## Files Created/Modified
- `Tools Cat/KeepAwakeDurationManagementView.swift` - swaps the populated duration region to a native `List` and removes the custom stacked row shell.
- `Tools CatUITests/Tools_CatUITests.swift` - keeps the direct-launch duration-manager smoke stable by querying the add sheet from the app tree.
- `.planning/phases/14-duration-management-ui-polish/14-01-SUMMARY.md` - records plan output, verification, and deviation tracking.

## Decisions Made
- Used the native `List` control directly inside the existing manager shell rather than preserving custom scroll/card styling.
- Kept the manager heading row, add flow, delete confirmation, and accessibility seams unchanged so the plan stayed within the Wave 1 UI-only boundary.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Re-anchored add-sheet smoke assertions to app scope**
- **Found during:** Task 1 (Replace the custom timed-duration stack with a native macOS list presentation)
- **Issue:** The focused UI smoke still queried sheet labels and controls from the titled manager window subtree, which no longer reliably exposed the live sheet content during verification.
- **Fix:** Updated the smoke to assert `keep-awake-duration-form-sheet`, the minutes label, input field, save button, and cancel button through `app`-level queries while preserving the original scenario.
- **Files modified:** `Tools CatUITests/Tools_CatUITests.swift`
- **Verification:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'`
- **Committed in:** `78767fa` (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Verification-only fix. No scope creep and no reopened CRUD/store/root-menu behavior.

## Issues Encountered

- The first focused UI smoke run failed after the `List` swap because the sheet-content assertions were scoped too narrowly to the titled window. Updating the smoke to query the app tree resolved it.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The duration manager now starts from native list semantics, so Phase 14-02 can focus on semantic edit/delete action styling without reopening presentation structure again.
- Existing accessibility seams remain available for the next UI-polish slice.
