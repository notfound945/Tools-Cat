---
phase: 05-native-menu-polish
plan: 02
subsystem: ui
tags: [swiftui, appkit, xcuitest, accessibility, macos]
requires:
  - phase: 02-device-library-management
    provides: list-first device manager window, stable row identifiers, and management presentation copy
  - phase: 03-saved-device-wake-flows
    provides: retained WOL session state, truthful wake status, and saved-device picker behavior
provides:
  - WOL utility-window hierarchy with explicit automation identifiers for mode, input, status, and actions
  - Device-library hierarchy polish that preserves list-first behavior while exposing top-action and form-action seams
  - Stable UX-04 hooks for Phase 5 window smoke coverage without pixel assertions
affects: [phase-05-final-smoke, native-windows, xcuitest-smoke]
tech-stack:
  added: []
  patterns: [native-spacing-polish, accessibility-identifier-driven-ui-smoke, retained-appkit-shell-plus-swiftui-content]
key-files:
  created: []
  modified:
    - Mac OS Swiss Knife/WOLView.swift
    - Mac OS Swiss Knife/WOLWindow.swift
    - Mac OS Swiss Knife/DeviceLibraryView.swift
key-decisions:
  - "Keep the WOL window as one compact single-column utility surface and express hierarchy through spacing, labels, and deterministic accessibility identifiers rather than extra chrome."
  - "Keep the device-library manager list-first, preserve the normal scroll-stack versus reorder List split, and strengthen the top action row and row hierarchy instead of introducing structural UI changes."
patterns-established:
  - "Phase 5 window polish exposes section-level accessibility identifiers so later XCUITest smoke can prove hierarchy without visual assertions."
  - "Native utility-window refinement stays inside the retained AppKit shell and uses stock SwiftUI typography, spacing, and button prominence for hierarchy."
requirements-completed: [UX-04]
duration: 4min
completed: 2026-04-12
---

# Phase 05 Plan 02: Native Menu Polish Summary

**Polished the WOL and device-library utility windows into clearer native hierarchies with stable UI-smoke identifiers while preserving their existing interaction models**

## Performance

- **Duration:** 4 min
- **Started:** 2026-04-12T08:20:30Z
- **Completed:** 2026-04-12T08:24:38Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Refined the WOL window into a compact single-column tool surface with explicit mode, input, status, and action identifiers for later automation.
- Strengthened the device-library window hierarchy with a stable top action row, centered empty state CTA, roomier list rows, and a tagged form action row.
- Re-verified the Phase 5 window work with the required `xcodebuild build-for-testing` and seeded device-library UI smoke slice.

## Task Commits

Each task was committed atomically:

1. **Task 1: Refine the WOL utility window hierarchy and add UI-smoke identifiers** - `fa3d34d` (fix)
2. **Task 2: Polish the device-library window without breaking the list-first interaction model** - `e4c554f` (fix)

## Files Created/Modified
- `Mac OS Swiss Knife/WOLView.swift` - Reworked the WOL view spacing, labels, action row, and accessibility identifiers while keeping one visible input at a time.
- `Mac OS Swiss Knife/WOLWindow.swift` - Kept the 460pt AppKit shell and raised the window height only enough to fit the refined hierarchy.
- `Mac OS Swiss Knife/DeviceLibraryView.swift` - Strengthened the top action row, empty state, row typography, and form action-row seam without changing list-first behavior.

## Decisions Made

- Kept the WOL polish inside the existing single-column structure so UX-04 improves without reopening any WOL interaction or ownership decisions.
- Left `DeviceLibraryWindow.swift` unchanged because the existing 520pt shell already supports the refined spacing; the polish stayed in the SwiftUI content.
- Preserved the Phase 2 normal-mode `ScrollView` versus reorder-mode `List` split so the existing `device-row-*` XCUITest seam remains intact.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `gsd-tools` advanced the plan state and roadmap counters, but the visible progress text in `STATE.md` and the Phase 5 roadmap table stayed stale. Those metadata files were corrected manually before the final docs commit.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 5 now has the WOL and manager-window accessibility hooks needed for the final UI smoke plan.
- The windows remain on the existing retained AppKit shell and truthful session models, so Plan `05-03` can focus on smoke coverage and human visual approval rather than UI rewrites.

## Self-Check

PASSED

- Found `.planning/phases/05-native-menu-polish/05-02-SUMMARY.md`
- Found commit `fa3d34d`
- Found commit `e4c554f`
- No placeholder or stub markers detected in the modified files for this plan

---
*Phase: 05-native-menu-polish*
*Completed: 2026-04-12*
