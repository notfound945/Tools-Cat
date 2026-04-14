---
phase: 01-truthful-foundations
plan: 03
subsystem: ui
tags: [swift, xctest, appkit, macos, iokit, keep-awake]
requires:
  - phase: 01-01
    provides: "Keep-awake transition and outcome contracts used by the menu controller rewrite"
provides:
  - "Pure keep-awake menu presentation rules for confirmed, pending, and failed states"
  - "Typed power-assertion outcomes behind an injectable async keep-awake controller seam"
  - "Status bar rendering that keeps icon and checkmark aligned with confirmed assertion outcomes only"
  - "Keep-awake controller tests for pending copy, confirmed success, failure recovery, and duplicate-toggle suppression"
affects: [01-02, phase-1-wave-2, keep-awake, timed-keep-awake]
tech-stack:
  added: []
  patterns:
    - "Presentation-driven AppKit menu rendering from confirmed plus pending state"
    - "Async side-effect adapter returning typed keep-awake toggle outcomes"
key-files:
  created: []
  modified:
    - Mac OS Swiss Knife/KeepAwakePresentation.swift
    - Mac OS Swiss Knife/PowerAssertionManager.swift
    - Mac OS Swiss Knife/StatusBarController.swift
    - Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift
key-decisions:
  - "The keep-awake toggle label and a dedicated disabled status row both render pending copy immediately, while the confirmed icon and checkmark wait for the async completion."
  - "StatusBarController now depends on KeepAwakePowerControlling so tests can hold completion open and prove the UI no longer trusts optimistic singleton toggles."
patterns-established:
  - "Menu truth pattern: pending copy may change immediately, but steady-state visuals move only on confirmed success or unchanged outcomes."
  - "Failure recovery pattern: restore the last confirmed keep-awake state and surface the human-readable error in the menu context."
requirements-completed: [RELY-05]
duration: 5 min
completed: 2026-04-11
---

# Phase 01 Plan 03: Truthful Keep-Awake Summary

**Truthful keep-awake menu rendering with typed power outcomes, pending menu copy, and controller tests that prove steady-state visuals wait for confirmed success**

## Performance

- **Duration:** 5 min
- **Started:** 2026-04-11T04:30:00Z
- **Completed:** 2026-04-11T04:35:24Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Added pure keep-awake presentation helpers for exact pending titles, pending status-row copy, steady-state menu state, and truthful icon selection.
- Changed the power assertion boundary from optimistic void toggles to typed enable/disable outcomes behind an injectable async adapter.
- Reworked the status bar controller so pending feedback is visible immediately but the steady icon and checkmark move only after confirmed success, with failure copy preserved in the menu.
- Expanded keep-awake XCTest coverage from a scaffold to pure-state and controller-behavior checks.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement pure keep-awake presentation rules and typed power-assertion outcomes** - `f927b33` (feat)
2. **Task 2: Rework StatusBarController so menu state follows confirmed keep-awake outcomes only** - `e9253e9` (feat)

**Plan metadata:** committed with this summary file

## Files Created/Modified
- `Mac OS Swiss Knife/KeepAwakePresentation.swift` - defines exact pending titles, status-row text, steady-state menu state, and icon selection from confirmed state.
- `Mac OS Swiss Knife/PowerAssertionManager.swift` - returns typed keep-awake outcomes, switches to `kIOPMAssertPreventUserIdleDisplaySleep`, and adds the injectable async `KeepAwakePowerControlling` adapter.
- `Mac OS Swiss Knife/StatusBarController.swift` - owns confirmed/pending/message state, renders the dedicated `keepAwakeStatusItem`, and updates steady-state visuals only after completion.
- `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` - covers presentation rules plus pending, success, failure, injected-seam, and duplicate-toggle controller behavior.

## Decisions Made
- Used `KeepAwakePresentation` as the single rendering contract so the menu title, status row, checkmark, and icon stay derived from the same confirmed/pending state.
- Routed quit-time keep-awake shutdown through the injected controller seam to avoid bypassing the truthful status boundary with direct singleton calls.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The keep-awake lane now satisfies the Phase 1 truth requirement: pending copy is visible on a concrete menu surface, steady-state visuals wait for confirmed outcomes, and failures keep the last confirmed state visible.
- Automated shared-gate verification already passed with `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:"Mac OS Swiss KnifeTests"`.
- The native menu-bar smoke test from `01-VALIDATION.md` is still a shared Wave 2 manual check because it requires observing the live menu surface during a real toggle.

## Self-Check: PASSED

---
*Phase: 01-truthful-foundations*
*Completed: 2026-04-11*
