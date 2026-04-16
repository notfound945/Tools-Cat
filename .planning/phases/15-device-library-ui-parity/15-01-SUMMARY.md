---
phase: 15-device-library-ui-parity
plan: 01
subsystem: ui
tags: [swiftui, macos, xctest, list, sheet]
requires:
  - phase: 14-duration-management-ui-polish
    provides: retained manager shell with native list and shared add/edit sheet
provides:
  - device-library manager keeps the list shell visible during add and edit
  - populated device browsing uses a native macOS List in normal mode
  - focused session and direct-launch smoke coverage lock the retained list plus sheet flow
affects: [15-02, device-library-ui-parity, wol-device-library]
tech-stack:
  added: []
  patterns: [retained manager shell, shared sheet presentation, native swiftui list]
key-files:
  created: []
  modified:
    - Tools Cat/DeviceLibraryView.swift
    - Tools Cat/DeviceLibrarySessionModel.swift
    - Tools CatTests/DeviceLibrarySessionModelTests.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Use currentFormMode as the only add/edit presentation truth and derive sheet visibility from it."
  - "Keep reorder mode on its existing dedicated List path while moving only the normal browse path to native list semantics."
patterns-established:
  - "Device-library parity now matches the duration manager's retained-shell plus shared-sheet interaction pattern."
  - "Direct-launch UI smoke should assert sheet-level seams and stable actions instead of brittle placeholder or label lookups."
requirements-completed: [DEVS-06, DEVS-07]
duration: 7 min
completed: 2026-04-16
---

# Phase 15 Plan 01: Device Library UI Parity Summary

**Native device-library list browsing with retained-shell add/edit sheets over the existing manager window**

## Performance

- **Duration:** 7 min
- **Started:** 2026-04-16T06:03:30Z
- **Completed:** 2026-04-16T06:10:32Z
- **Tasks:** 1
- **Files modified:** 4

## Accomplishments
- Reworked the `设备库` manager so the list shell stays visible and add/edit is presented through a shared sheet instead of a full-view route swap.
- Replaced the normal populated browse stack with a native SwiftUI `List` while keeping explicit reorder mode and delete confirmation behavior intact.
- Extended focused unit and direct-launch UI coverage to lock the new form presentation truth and the reorder-exit guardrail.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace full-view list/form swapping with a native list plus shared sheet presentation** - `b270b92` (feat)

## Files Created/Modified
- `Tools Cat/DeviceLibraryView.swift` - Keeps the manager shell visible, presents the shared form sheet, and uses a native `List` for normal browsing.
- `Tools Cat/DeviceLibrarySessionModel.swift` - Removes the old full-screen route enum and drives add/edit presentation directly from `currentFormMode`.
- `Tools CatTests/DeviceLibrarySessionModelTests.swift` - Updates session truth assertions to the new form-mode model and locks add/edit exiting reorder mode.
- `Tools CatUITests/Tools_CatUITests.swift` - Verifies the seeded manager keeps the list visible while the add sheet is open through stable sheet seams.

## Decisions Made
- Reused the duration manager's retained-shell shape directly instead of inventing a device-specific presentation abstraction.
- Kept semantic action styling out of this plan so `15-02` can own the accent/destructive affordance pass cleanly.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `saveDraft()` shadowing after removing the old route enum**
- **Found during:** Task 1 (Replace full-view list/form swapping with a native list plus shared sheet presentation)
- **Issue:** `saveDraft()` rebound `currentFormMode` as a local constant, which broke the build when the code later cleared the sheet state.
- **Fix:** Renamed the local binding to `activeFormMode` so save logic can switch on the active mode and still clear `currentFormMode`.
- **Files modified:** `Tools Cat/DeviceLibrarySessionModel.swift`
- **Verification:** Required `xcodebuild test` slice passed after the fix.
- **Committed in:** `b270b92` (part of task commit)

**2. [Rule 3 - Blocking] Stabilized the UI smoke around macOS sheet accessibility**
- **Found during:** Task 1 (Replace full-view list/form swapping with a native list plus shared sheet presentation)
- **Issue:** The direct-launch smoke was asserting sheet label and placeholder nodes that were not exposed reliably once the form moved into a macOS sheet.
- **Fix:** Updated the smoke to assert the retained list, shared sheet seam, and stable form action buttons instead of brittle inner accessibility nodes.
- **Files modified:** `Tools CatUITests/Tools_CatUITests.swift`
- **Verification:** Required `xcodebuild test` slice passed with both direct-launch UI tests green.
- **Committed in:** `b270b92` (part of task commit)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking)
**Impact on plan:** Both fixes were necessary to complete the planned list-plus-sheet refactor and keep the verification slice deterministic. No scope creep.

## Issues Encountered
- macOS sheet accessibility exposed the sheet container and action buttons reliably, but not every inner label or placeholder. The smoke now targets the durable seams that actually matter for this flow.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `15-02` can now focus only on semantic edit/delete styling and any follow-on polish because the device-library surface shape already matches the shipped duration manager pattern.
- Saved-device CRUD, delete confirmation, reorder behavior, and direct-launch management coverage remained intact through the targeted regression slice.

## Self-Check: PASSED
- Confirmed `.planning/phases/15-device-library-ui-parity/15-01-SUMMARY.md` exists.
- Confirmed task commit `b270b92` is present in git history.

---
*Phase: 15-device-library-ui-parity*
*Completed: 2026-04-16*
