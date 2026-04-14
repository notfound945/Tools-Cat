---
phase: 07-menu-bar-verification-strategy
plan: 01
subsystem: testing
tags: [xctest, appkit, menu-bar, wol]
requires:
  - phase: 06-planning-truth-cleanup
    provides: "Current wake-surface truth and verification-boundary language"
provides:
  - "Dedicated controller-seam regression coverage for the root wake and management menu rows"
  - "Explicit in-flight disabled-state coverage for the root wake row while management remains available"
affects: [phase-07-validation-contract, auto-01, menu-bar-verification]
tech-stack:
  added: []
  patterns: ["Controller-seam NSMenuItem action tests", "Blocking WakeSending fake for in-flight menu-state assertions"]
key-files:
  created: ["Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift"]
  modified: ["Mac OS Swiss Knife.xcodeproj/project.pbxproj"]
key-decisions:
  - "Keep the new coverage at the StatusBarController seam and do not present it as live NSStatusItem click automation"
  - "Use a blocking wake sender so the disabled-state assertion observes the shared WOLSessionModel in flight"
patterns-established:
  - "Name tray-entry tests after the controller seam they prove, not after live tray automation"
  - "Trigger real NSMenuItem actions and observe callback seams for deterministic menu-entry coverage"
requirements-completed: [AUTO-01]
duration: 5min
completed: 2026-04-13
---

# Phase 7 Plan 1: Root entry controller-seam regression coverage summary

**StatusBarController now has a dedicated XCTest slice proving the root `发送 WOL …` and `管理 WOL 设备…` rows dispatch through their callback seams and that the wake row disables during shared in-flight sends.**

## Performance

- **Duration:** 5min
- **Started:** 2026-04-13T08:16:15Z
- **Completed:** 2026-04-13T08:20:54Z
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments
- Added `StatusBarControllerEntryFlowTests` as the phase-owned regression artifact for root wake and management entry flows.
- Locked the root-row dispatch assertions to `onOpenWOL` and `onOpenDeviceLibrary` without overstating the coverage as live tray automation.
- Proved the root wake row disables during a shared in-flight send while the management row stays enabled.

## Task Commits

Each task was committed atomically through the TDD cycle:

1. **Task 1 RED: add failing entry-flow regression tests** - `e1dfdd7` (`test`)
2. **Task 1 GREEN: implement controller entry-flow regression slice** - `5c9d4f5` (`feat`)

**Plan metadata:** recorded in the final docs commit after summary/state updates.

## Files Created/Modified
- `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift` - Dedicated controller-seam tests for root wake/management entry dispatch and in-flight disabled-state coverage.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - Registers the new regression file in the unit-test target's synchronized test group.

## Decisions Made
- Kept the artifact self-contained inside a dedicated test file so maintainers can point to one explicit controller-seam coverage file for root entry rows.
- Reused the existing menu-test pattern of fake power/countdown dependencies and an in-memory repository instead of introducing new production seams.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None beyond the intentional RED-phase compile failure for the missing local test helpers.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 7 now has one concrete automated artifact for `AUTO-01`.
- Plan 07-02 can build on this by publishing the stable regression slice and broader validation contract.

## Self-Check: PASSED
