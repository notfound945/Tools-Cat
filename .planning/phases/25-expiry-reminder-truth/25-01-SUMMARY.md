---
phase: 25-expiry-reminder-truth
plan: 01
subsystem: ui
tags: [swift, macos, notifications, appkit, xctest, keep-awake]
requires:
  - phase: 24-timed-reminder-scheduling
    provides: shared keep-awake reminder scheduler seam with pre-expiry scheduling and session-scoped cancellation
provides:
  - truthful timed keep-awake expiry delivery tied to confirmed shutdown outcomes
  - reminder-availability ownership in the keep-awake session model without blocking timed sessions
  - two-line keep-awake status-row rendering for countdown truth plus reminder-unavailable truth
affects: [timed-keep-awake, local-notifications, status-bar-menu, phase-24-reminder-scheduling]
tech-stack:
  added: []
  patterns:
    - extend the existing reminder scheduler seam for all keep-awake reminder side effects
    - bind expiry notification truth to confirmed off transitions plus session UUID identity
    - reuse one disabled menu row for single-line or two-line keep-awake status rendering
key-files:
  created: []
  modified:
    - Tools Cat/KeepAwakeReminderScheduling.swift
    - Tools Cat/KeepAwakeSessionModel.swift
    - Tools Cat/AppDelegate.swift
    - Tools Cat/KeepAwakePresentation.swift
    - Tools Cat/StatusBarController.swift
    - Tools CatTests/AppDelegateNotificationTests.swift
    - Tools CatTests/KeepAwakeSessionModelTests.swift
    - Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift
    - Tools CatTests/KeepAwakeMenuStateTests.swift
key-decisions:
  - Keep expiry reminder delivery inside the existing keep-awake reminder scheduler seam instead of adding a second notification path.
  - Tie end-of-session reminder truth to confirmed `.off` stop outcomes plus active timed-session UUID, not `endDate` alone.
  - Reuse the existing keep-awake status row with attributed two-line rendering for reminder-unavailable truth instead of adding a new menu section.
patterns-established:
  - "KeepAwakeSessionModel owns session-scoped reminder truth, stop reasons, and reminder availability."
  - "StatusBarController renders existing disabled status rows as plain or attributed titles based on presentation status lines."
requirements-completed: [NOTF-03, NOTF-05]
duration: 22m
completed: 2026-05-10
---

# Phase 25 Plan 01: Expiry Reminder Truth Summary

**Truthful timed keep-awake expiry reminders now deliver only after confirmed shutdown, while the existing status row can show countdown truth and reminder-unavailable truth together**

## Performance

- **Duration:** 22m
- **Started:** 2026-05-10T03:11:25Z
- **Completed:** 2026-05-10T03:33:24Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- Extended the existing keep-awake reminder scheduler seam so launch wiring, authorization checks, immediate expiry delivery, and foreground reminder presentation stay behind one testable boundary.
- Made `KeepAwakeSessionModel` own reminder availability and timed-expiry truth, so only confirmed timed-expiry shutdown paths can deliver one `.expiry` notification and denied notifications never block timed keep-awake.
- Reused the existing disabled keep-awake status row for one-line or two-line rendering, letting countdown truth and reminder-unavailable truth appear together without adding menu surface area.

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend the reminder scheduler and session lifecycle for truthful expiry delivery** - `ba245cb` (`test`), `18c0098` (`feat`)
2. **Task 2: Render countdown truth and reminder-unavailable truth together in the existing keep-awake status row** - `39e1cb8` (`test`), `136d111` (`feat`)

_Note: Both tasks followed TDD and therefore produced paired test and feature commits._

## Files Created/Modified

- `Tools Cat/KeepAwakeReminderScheduling.swift` - Added authorization-state fetch, immediate expiry delivery, and foreground banner/list presentation under the existing reminder scheduler seam.
- `Tools Cat/KeepAwakeSessionModel.swift` - Added reminder availability state, timed-expiry stop reasons, session-scoped expiry identifiers, and confirmed-shutdown-only expiry reminder delivery.
- `Tools Cat/AppDelegate.swift` - Installed the reminder foreground presentation delegate before launch-time authorization requests.
- `Tools Cat/KeepAwakePresentation.swift` - Replaced one-string status text with structured primary/secondary status lines.
- `Tools Cat/StatusBarController.swift` - Rendered the existing keep-awake status row as hidden, single-line, or attributed two-line output without changing the menu structure.
- `Tools CatTests/AppDelegateNotificationTests.swift` - Covered launch ordering through the injected scheduler seam.
- `Tools CatTests/KeepAwakeSessionModelTests.swift` - Covered truthful expiry delivery, stale-reminder suppression, and reminder-unavailable handling for short timed sessions.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` - Covered single-line and two-line keep-awake status-row rendering.
- `Tools CatTests/KeepAwakeMenuStateTests.swift` - Realigned keep-awake presentation expectations after the status API changed.

## Decisions Made

- Kept expiry reminder delivery inside the existing `KeepAwakeReminderScheduling` seam so all notification-side effects remain testable without a second notification service.
- Gated expiry reminder delivery on confirmed `.off` stop outcomes plus the active timed-session UUID, which prevents false end reminders on manual stops, replacements, or failed disable attempts.
- Reused the existing disabled keep-awake status row for reminder-unavailable messaging and added attributed two-line rendering instead of expanding the menu with a notification-specific section.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Realigned keep-awake presentation tests to the new status-line API**
- **Found during:** Task 2 (Render countdown truth and reminder-unavailable truth together in the existing keep-awake status row)
- **Issue:** `KeepAwakePresentation` moved from `statusText` to structured `statusLines`, which left `Tools CatTests/KeepAwakeMenuStateTests.swift` out of sync and blocked the status-row test slice.
- **Fix:** Updated the affected keep-awake menu-state assertions to compile against the structured status-line presentation.
- **Files modified:** `Tools CatTests/KeepAwakeMenuStateTests.swift`
- **Verification:** Focused status-row controller tests and the combined wave gate passed.
- **Committed in:** `39e1cb8` (part of Task 2 commit set)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The follow-on test alignment was required to keep the planned status presentation refactor verifiable. No runtime scope change.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 25 implementation is ready for the remaining manual notification checks documented in `.planning/phases/25-expiry-reminder-truth/25-VALIDATION.md`.
- The reminder scheduler, session model, and status-row seams now provide a stable base for future notification preference work without reopening the current menu structure.

## Self-Check: PASSED

- Verified summary file exists at `.planning/phases/25-expiry-reminder-truth/25-01-SUMMARY.md`.
- Verified task commits `ba245cb`, `18c0098`, `39e1cb8`, and `136d111` exist in git history.

---
*Phase: 25-expiry-reminder-truth*
*Completed: 2026-05-10*
