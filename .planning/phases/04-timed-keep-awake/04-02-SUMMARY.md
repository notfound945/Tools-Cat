---
phase: 04-timed-keep-awake
plan: 02
subsystem: ui
tags: [swift, xctest, appkit, menu-bar, combine]
requires:
  - phase: 04-timed-keep-awake
    provides: shared keep-awake session model and presentation contract from 04-01
provides:
  - root-menu keep-awake actions in the exact fixed Chinese order
  - shared-session driven menu state, icon, tooltip, and status row rendering
  - controller regression coverage for keep-awake ordering, dispatch, pending disablement, and stable titles
affects: [04-03 verification, menu-bar ui, keep-awake lifecycle]
tech-stack:
  added: []
  patterns: [shared session injection, presentation-driven menu rendering, controller-level appkit regression tests]
key-files:
  created:
    - Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift
  modified:
    - Mac OS Swiss Knife/AppDelegate.swift
    - Mac OS Swiss Knife/StatusBarController.swift
    - Mac OS Swiss Knife/StatusBarControllerWakeMenuTests.swift
    - Mac OS Swiss Knife.xcodeproj/project.pbxproj
key-decisions:
  - "All keep-awake visual state comes from KeepAwakePresentation built off the shared session, so menu rows never speculate on power-controller outcomes."
  - "Countdown text is confined to the disabled status row; the six action titles remain fixed for scanability and regression safety."
patterns-established:
  - "AppDelegate owns one KeepAwakeSessionModel and injects it into StatusBarController at launch."
  - "StatusBarController subscribes to session objectWillChange and renders menu state, icon, and tooltip from one presentation object."
requirements-completed: [AWAKE-01, AWAKE-02, AWAKE-03]
duration: 18m
completed: 2026-04-12
---

# Phase 4 Plan 2: Shared Keep-Awake Menu Wiring Summary

**The menu bar now exposes timed keep-awake as a fixed root action group backed by one shared session model and controller regression tests**

## Performance

- **Duration:** 18m
- **Started:** 2026-04-12T06:45:15Z
- **Completed:** 2026-04-12T07:03:05Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Replaced the legacy single keep-awake toggle with the exact six-row root menu action group plus one disabled status row in Chinese.
- Wired AppDelegate and StatusBarController to share one `KeepAwakeSessionModel`, so checkmarks, disabled state, tooltip, and symbol all render from the same truth source.
- Added controller tests that lock row order, shared-session dispatch, pending disabling, stable action titles, and icon/tooltip behavior.

## Task Commits

Each task was committed atomically through the TDD cycle:

1. **Task 1 GREEN: shared keep-awake menu group wiring** - `2ad6f53` (`feat`)
2. **Task 2 RED: keep-awake menu controller regressions** - `e6ec671` (`test`)
3. **Task 2 GREEN: presentation-driven controller binding** - `c9763b4` (`feat`)

## Files Created/Modified

- `Mac OS Swiss Knife/AppDelegate.swift` - Retains and injects one shared keep-awake session at launch.
- `Mac OS Swiss Knife/StatusBarController.swift` - Builds the fixed keep-awake rows, subscribes to session changes, and renders menu state, tooltip, and symbol from `KeepAwakePresentation`.
- `Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift` - Covers fixed ordering, action dispatch, pending disablement, stable titles, and menu-bar icon/tooltip semantics.
- `Mac OS Swiss Knife/StatusBarControllerWakeMenuTests.swift` - Adapts the wake-menu seam to the controller initializer that now accepts a shared keep-awake session.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - Registers the new controller regression test file.

## Decisions Made

- Kept `关闭常亮` visible in every state and never checked, so users always have an explicit manual stop affordance without conflicting selection semantics.
- Used session-driven presentation for the button tooltip and symbol, matching the same off, pending, indefinite, and timed copy contract tested in `04-01`.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The Wave 2 executor timed out before writing its summary, but the code path itself was intact; targeted `xcodebuild test` verification confirmed the remaining GREEN step and allowed a clean manual completion.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The menu surface is ready for `04-03` verification with fixed root rows and truthful state transitions.
- Automated regression coverage is in place for the Phase 4 menu contract, so the remaining work is focused on human smoke verification and lifecycle exit behavior.

## Self-Check: PASSED

- Found `.planning/phases/04-timed-keep-awake/04-02-SUMMARY.md` on disk.
- Verified commits `2ad6f53`, `e6ec671`, and `c9763b4` in git history.
- Verified the targeted Phase 4 test slice passes.

---
*Phase: 04-timed-keep-awake*
*Completed: 2026-04-12*
