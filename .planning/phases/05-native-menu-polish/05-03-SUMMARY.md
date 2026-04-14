---
phase: 05-native-menu-polish
plan: 03
subsystem: ui
tags: [swiftui, appkit, xcuitest, macos, accessibility]
requires:
  - phase: 05-01
    provides: locked three-section native menu contract and idle status collapse
  - phase: 05-02
    provides: polished WOL and device-library window hierarchy with stable accessibility identifiers
provides:
  - direct launch seams for the retained WOL and device-library windows under XCUITest
  - Phase 5 UI smoke coverage for both polished native utility windows
  - final WOL utility-window spacing adjustments from human visual feedback without changing the compact single-column contract
affects: [phase-05-complete, native-menu-polish, xcuitest-smoke, utility-window-spacing]
tech-stack:
  added: []
  patterns: [launch-argument-driven-ui-smoke, retained-appkit-window-testing, compact-native-utility-window-spacing]
key-files:
  created:
    - .planning/phases/05-native-menu-polish/05-03-SUMMARY.md
  modified:
    - Mac OS Swiss Knife/AppDelegate.swift
    - Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift
    - Mac OS Swiss Knife/WOLView.swift
    - Mac OS Swiss Knife/WOLWindow.swift
key-decisions:
  - "Open retained utility windows directly from launch arguments during UI smoke so the tests verify the real AppKit-owned surfaces without menu-bar automation."
  - "Address the WOL checkpoint feedback with more top and bottom breathing room and a small shell-height increase instead of changing the single-column hierarchy."
patterns-established:
  - "Phase 5 UI smoke reaches native utility windows through launch seams on AppDelegate rather than brittle status-item interaction."
  - "Human visual feedback on compact utility windows should be resolved with minimal spacing and shell-size adjustments before changing structure."
requirements-completed: [UX-01, UX-04]
duration: 11 min
completed: 2026-04-12
---

# Phase 05 Plan 03: Native Menu Polish Summary

**Direct launch seams and UI smoke coverage for the polished native windows, plus a final WOL spacing pass from human review**

## Performance

- **Duration:** 11 min
- **Started:** 2026-04-12T08:47:02Z
- **Completed:** 2026-04-12T08:58:23Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added direct AppDelegate launch seams so XCUITest can open the retained WOL and device-library windows without menu-bar interaction.
- Extended the Phase 5 UI smoke slice to cover the WOL window, seeded manager form mode, and empty manager state through stable accessibility identifiers.
- Fixed the WOL window’s top and bottom breathing room after the human checkpoint while keeping the compact single-column utility-window contract intact.

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend launch seams and UI smoke coverage for the polished native windows** - `12676d9` (`feat`)
2. **Task 2: Manually approve the final native menu and utility-window polish** - `20fe865` (`fix`)

**Plan metadata:** Pending final docs commit

## Files Created/Modified

- `Mac OS Swiss Knife/AppDelegate.swift` - Adds the direct WOL-window launch seam and regular-activation behavior for utility-window UI smoke launches.
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` - Covers WOL-window structure, seeded manager form mode, and empty-state manager launch behavior.
- `Mac OS Swiss Knife/WOLView.swift` - Adds extra top and bottom insets so the heading and action row sit with more comfortable breathing room.
- `Mac OS Swiss Knife/WOLWindow.swift` - Slightly raises the compact WOL shell height to preserve the refined spacing at the existing 460pt width.

## Decisions Made

- Reused the retained AppKit window ownership path for automation instead of adding test-only alternative surfaces.
- Treated the checkpoint response as concrete Phase 5 visual feedback and fixed only WOL spacing, staying inside the locked polish scope.
- Re-ran both the narrow Phase 5 UI-smoke slice and the full `xcodebuild test` suite before closing the plan.

## Deviations from Plan

None - plan executed through the intended checkpoint/resume loop without scope creep.

## Issues Encountered

- The human visual checkpoint found that the WOL heading sat too close to the title bar and the bottom action row sat too close to the window edge. The fix stayed limited to root content insets and a small window-height increase, then the Phase 5 UI smoke and full suite were rerun successfully.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 5 is now fully covered by controller tests, native-window UI smoke, and explicit human visual review feedback.
- The milestone is ready for whatever post-phase verification or shipping workflow comes next; no Phase 5 blockers remain.

## Self-Check: PASSED

- Found `.planning/phases/05-native-menu-polish/05-03-SUMMARY.md`
- Found task commits `12676d9` and `20fe865` in git history
- No blocking stub markers detected in the plan-touched product files

---
*Phase: 05-native-menu-polish*
*Completed: 2026-04-12*
