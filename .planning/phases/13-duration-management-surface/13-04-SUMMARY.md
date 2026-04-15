---
phase: 13-duration-management-surface
plan: 04
subsystem: ui
tags: [swiftui, appkit, macos, keep-awake, xcuitest]
requires:
  - phase: 13-03
    provides: "The shared duration manager flow, live menu sync, and list-local add/edit sheet."
provides:
  - "A grouped native surface that makes timed keep-awake durations immediately read as a list"
  - "Row-level hierarchy that stays restrained while keeping edit and delete affordances clear"
  - "UI smoke coverage for the duration list surface accessibility seam"
affects: [phase-13-verification, keep-awake-management, ui-polish]
tech-stack:
  added: []
  patterns:
    - "Native macOS utility lists can use grouped panel hierarchy and subtle row surfaces instead of plain window-background text."
key-files:
  created: []
  modified:
    - Tools Cat/KeepAwakeDurationManagementView.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Treat the cosmetic UAT issue as a list-surface problem only and leave the existing CRUD interaction flow untouched."
  - "Use AppKit-backed grouped backgrounds, borders, and spacing instead of flashy custom styling so the window still feels native."
patterns-established:
  - "UI smoke can lock native list discoverability with an explicit accessibility seam on the list surface container."
requirements-completed: [AWAKE-06]
duration: 8 min
completed: 2026-04-15
---

# Phase 13 Plan 04: Duration Management Cosmetic Gap Summary

**The keep-awake duration manager now presents timed durations inside a clearly grouped native list surface instead of letting them disappear into the window background**

## Performance

- **Duration:** 8 min
- **Started:** 2026-04-15T18:14:09+0800
- **Completed:** 2026-04-15T18:22:09+0800
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments

- Wrapped the timed-duration area in a grouped native panel with its own header, border, padding, and background so the region reads as a list at a glance.
- Gave each duration row a subtle surface and spacing hierarchy while preserving the existing title, minutes, edit, and delete affordances.
- Extended the existing macOS UI smoke to assert the list-surface accessibility seam and kept the add-sheet flow covered.

## Task Commits

Each task was committed atomically:

1. **Task 1: Give the timed-duration area a recognizable native list surface** - `5aa9910` (fix)

## Files Created/Modified

- `Tools Cat/KeepAwakeDurationManagementView.swift` - Adds the grouped list container, row surfaces, and the list-surface accessibility marker.
- `Tools CatUITests/Tools_CatUITests.swift` - Verifies the list surface exists in the seeded manager flow and scopes the cancel-button lookup to the active window.

## Decisions Made

- Kept the existing add/edit sheet, delete confirmation, and menu-sync behavior unchanged and limited the fix to visual discoverability.
- Chose understated native hierarchy over heavier ornament so the window still matches the rest of the app's macOS utility style.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Scoped the cancel button query to the management window**
- **Found during:** Task 1 (Give the timed-duration area a recognizable native list surface)
- **Issue:** The focused UI smoke had a flaky global `取消` button lookup once the add/edit sheet was presented.
- **Fix:** Changed the test to resolve `取消` from the active window instead of the whole app.
- **Files modified:** Tools CatUITests/Tools_CatUITests.swift
- **Verification:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'`
- **Committed in:** 5aa9910

---

**Total deviations:** 1 auto-fixed (Rule 1 bug)
**Impact on plan:** No scope creep. The deviation only stabilized the existing smoke path while the cosmetic list-surface fix shipped.

## Issues Encountered

- The executor agent finished the implementation but its verification handoff was interrupted before it wrote summary and tracking artifacts. The focused UI smoke was rerun locally and passed, so the plan closed without code changes beyond the committed fix.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 13 execution is complete and ready for formal verification rerun.
- This closes the last diagnosed Phase 13 gap, so the remaining step is verifier confirmation and phase completion bookkeeping.

## Self-Check: PASSED

---
*Phase: 13-duration-management-surface*
*Completed: 2026-04-15*
