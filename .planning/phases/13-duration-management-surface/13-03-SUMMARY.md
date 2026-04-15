---
phase: 13-duration-management-surface
plan: 03
subsystem: ui
tags: [swiftui, appkit, menu-bar, keep-awake, xcuitest]
requires:
  - phase: 13-01
    provides: "The managed-duration store and shared CRUD session contract."
  - phase: 13-02
    provides: "The native duration-management window, menu entry wiring, and direct-launch UI smoke."
provides:
  - "Keep-awake timed rows now rebuild from the managed duration store and refresh live after CRUD changes"
  - "Add and edit now share one compact list-local modal instead of replacing the manager surface"
  - "Regression coverage now locks menu placement, dynamic refresh truth, and the compact modal affordance"
affects: [phase-14-managed-duration-menu-integration, keep-awake-management, status-menu]
tech-stack:
  added: []
  patterns:
    - "Status-menu keep-awake rows can be rebuilt in place from the managed duration store publisher."
    - "SwiftUI list managers can preserve context while presenting one shared add/edit sheet from session state."
key-files:
  created: []
  modified:
    - Tools Cat/StatusBarController.swift
    - Tools Cat/KeepAwakeDurationManagementSessionModel.swift
    - Tools Cat/KeepAwakeDurationManagementView.swift
    - Tools CatTests/KeepAwakeDurationManagementSessionModelTests.swift
    - Tools CatTests/StatusBarControllerMenuPolishTests.swift
    - Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Move `管理常亮时长…` into the keep-awake section so duration management stays grouped with the actions it controls."
  - "Pull the minimum live root-menu sync slice forward into Phase 13 instead of leaving CRUD truth stale until a later phase."
patterns-established:
  - "Keep-awake menu tests should assert both static ordering and post-mutation refresh truth against an isolated in-memory duration repository."
  - "macOS UI smoke for native sheets is more stable when it asserts the live list remains visible and the shared form sheet appears on top."
requirements-completed: [AWAKE-05, AWAKE-06, AWAKE-07, AWAKE-08, AWAKE-09]
duration: 24 min
completed: 2026-04-15
---

# Phase 13 Plan 03: Duration Management Gap Closure Summary

**Keep-awake menu rows now follow managed durations live, and add/edit happen in one compact in-place modal instead of replacing the management surface**

## Performance

- **Duration:** 24 min
- **Started:** 2026-04-15T17:19:59+08:00
- **Completed:** 2026-04-15T17:44:19+08:00
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Moved `管理常亮时长…` to the bottom of the keep-awake section, above the native separator into the WOL section.
- Rebuilt timed keep-awake rows from `KeepAwakeDurationStore`, so add, edit, and delete now refresh the root menu immediately in sorted order while `无限常亮` stays fixed first.
- Replaced the full-window add/edit screen swap with one shared compact sheet that opens from the live duration list for both create and edit flows.
- Extended controller, session, and UI smoke coverage so the menu grouping, live sync truth, and compact modal behavior are all locked by automation.

## Task Commit

The two planned tasks shipped together because the session-model, SwiftUI sheet, and menu rebuild changes share one execution seam:

1. **Tasks 1-2: Close menu placement, live sync, and compact modal gaps** - `efa995b` (fix)

## Files Created/Modified

- `Tools Cat/StatusBarController.swift` - Rebuilds timed keep-awake rows from the managed duration store and relocates the management entry into the keep-awake group.
- `Tools Cat/KeepAwakeDurationManagementSessionModel.swift` - Replaces page-level screen state with shared add/edit sheet state while keeping one save path.
- `Tools Cat/KeepAwakeDurationManagementView.swift` - Keeps the list visible and presents one reusable add/edit sheet above it.
- `Tools CatTests/KeepAwakeDurationManagementSessionModelTests.swift` - Updates state assertions for sheet-driven add/edit flow.
- `Tools CatTests/StatusBarControllerMenuPolishTests.swift` - Locks the new management-entry placement and live menu refresh after duration-store mutations.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` - Verifies keep-awake timed rows still expose the expected ordered actions through the dynamic menu path.
- `Tools CatUITests/Tools_CatUITests.swift` - Proves the duration list stays visible while the shared compact sheet appears from the live manager surface.

## Decisions Made

- Kept `无限常亮` out of duration management entirely and treated only timed rows as managed data.
- Considered the stale root-menu truth a Phase 13 blocker, not an acceptable wait-for-Phase-14 issue.

## Deviations from Plan

- The planned work was executed as one code commit instead of two task-separated commits because the menu rebuild, sheet presentation, and regression updates all depend on the same controller/session/view seam.
- The gap closure intentionally pulled the minimal dynamic menu slice of planned Phase 14 forward so CRUD truth is already live at the root menu.

## Issues Encountered

- The original blocker was environmental, not product code: sandboxed `xcodebuild` could not write DerivedData or test logs. Once full local access was restored, the targeted UI smoke and full Phase 13 slice both passed.

## User Setup Required

None.

## Next Phase Readiness

- Phase 13 execution is complete and ready for formal `$gsd-verify-work 13`.
- The originally planned Phase 14 menu-integration scope is now largely absorbed by this gap closure and should be re-evaluated after verification instead of executed blindly.

## Self-Check: PASSED

---
*Phase: 13-duration-management-surface*
*Completed: 2026-04-15*
