---
phase: 07-menu-bar-verification-strategy
plan: 02
subsystem: testing
tags: [xcodebuild, xctest, xcuitest, verification, menu-bar]
requires:
  - phase: 06-planning-truth-cleanup
    provides: current wake-surface and validation-truth baseline
  - phase: 07-01
    provides: controller entry-flow regression coverage
provides:
  - stable phase 7 regression runner for controller and direct-launch UI smoke coverage
  - phase-owned validation contract that maps automated and manual tray-entry layers
affects: [07-03, 08-validation-debt-closure, verification-docs]
tech-stack:
  added: [bash, xcodebuild]
  patterns: [named regression slice wrapper, phase-owned validation contract]
key-files:
  created:
    - scripts/run_menu_bar_verification_slice.sh
    - .planning/phases/07-menu-bar-verification-strategy/07-VALIDATION.md
  modified: []
key-decisions:
  - "Expose the Phase 7 regression path through one bash wrapper instead of scattered xcodebuild commands."
  - "State the tray-entry boundary directly: automation covers controller seams and direct-launch windows, while live tray entry remains manual."
patterns-established:
  - "Verification scripts should print the exact coverage boundary before running."
  - "Phase validation files should map each requirement to concrete automated artifacts and an explicit manual checklist."
requirements-completed: [AUTO-01, AUTO-03]
duration: 6min
completed: 2026-04-13
---

# Phase 7 Plan 2: Menu-Bar Verification Strategy Summary

**Named Phase 7 regression runner plus a validation contract that maps controller seams, direct-launch UI smoke, and manual tray-entry checks**

## Performance

- **Duration:** 6 min
- **Started:** 2026-04-13T08:16:15Z
- **Completed:** 2026-04-13T08:22:25Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added one executable script that runs the intended controller and utility-window regression slice.
- Centralized the Phase 7 coverage story in a validation contract that maps `AUTO-01`, `AUTO-02`, and `AUTO-03`.
- Locked the wording that the automated slice does not prove live tray clicks and paired it with a concrete manual tray-entry checklist.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add a stable regression runner for the polished menu and utility-window slice** - `22e05c8` (feat)
2. **Task 2: Write the phase validation contract around the layered coverage truth** - `5e6b446` (docs)

## Files Created/Modified

- `scripts/run_menu_bar_verification_slice.sh` - canonical Phase 7 regression runner for controller suites and direct-launch UI smoke.
- `.planning/phases/07-menu-bar-verification-strategy/07-VALIDATION.md` - requirement map and manual tray-entry boundary contract for Phase 7.

## Decisions Made

- Use one named `bash` wrapper for the regression slice so maintainers do not have to reconstruct the right `xcodebuild` filters.
- Keep live tray entry explicit as manual coverage until a separate automation harness exists, instead of overstating what launch-argument UI smoke proves.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The referenced `StatusBarControllerEntryFlowTests` artifact had already landed through the parallel Phase 7 workstream, so this plan validated and reused that committed coverage instead of recreating it.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 7 now has one stable automated slice and one phase-owned validation contract for the current coverage boundary.
- Plan `07-03` can now rewrite surrounding verification docs to point at these canonical artifacts instead of repeating command details.

## Self-Check

PASSED

- Verified created artifacts exist: `scripts/run_menu_bar_verification_slice.sh`, `07-VALIDATION.md`, and `07-02-SUMMARY.md`.
- Verified task commits exist: `22e05c8`, `5e6b446`.
- Stub scan found no placeholder or TODO-style content in plan-created artifacts.

---
*Phase: 07-menu-bar-verification-strategy*
*Completed: 2026-04-13*
