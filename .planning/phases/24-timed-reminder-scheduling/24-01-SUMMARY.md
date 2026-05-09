---
phase: 24-timed-reminder-scheduling
plan: 01
subsystem: ui
tags: [swift, macos, usernotifications, xctest, menu-bar, keep-awake]
requires:
  - phase: 04-timed-keep-awake
    provides: shared timed keep-awake lifecycle, countdown truth, and menu/status-row rendering seams
  - phase: 22-wol-result-timeout
    provides: the repo pattern for session-owned cancellable side-effect schedulers plus deterministic fake-scheduler tests
provides:
  - launch-time local-notification authorization wiring for timed keep-awake reminders
  - one `UNUserNotificationCenter` reminder scheduling seam with conservative permission handling and pending-request cancellation
  - session-scoped pre-expiry reminder ownership in `KeepAwakeSessionModel`, including skip-under-two-minutes and stale-reminder cancellation behavior
  - focused unit/controller coverage proving reminder-unavailable feedback reuses the existing keep-awake status row
affects: [phase-25-expiry-reminder-truth, keep-awake, status-bar-menu, notifications]
tech-stack:
  added: [UserNotifications]
  patterns:
    - session-owned local reminder orchestration through an injected scheduler abstraction
    - launch-time authorization request in `AppDelegate` with test-only injection and no real system prompt during XCTest
key-files:
  created:
    - .planning/phases/24-timed-reminder-scheduling/24-01-SUMMARY.md
    - Tools Cat/KeepAwakeReminderScheduling.swift
    - Tools CatTests/AppDelegateNotificationTests.swift
  modified:
    - Tools Cat/AppDelegate.swift
    - Tools Cat/KeepAwakeSessionModel.swift
    - Tools CatTests/KeepAwakeSessionModelTests.swift
    - Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift
key-decisions:
  - "Keep `KeepAwakeSessionModel` as the only owner of pre-expiry reminder truth so scheduling/cancellation follows confirmed timed-session state rather than menu clicks."
  - "Treat all non-authorized notification states as reminder-unavailable and surface them through the existing keep-awake message/status row instead of blocking timed keep-awake."
patterns-established:
  - "Pattern: launch-time OS permission requests can be routed through a small injected app-lifetime service while tests force the same path through a fake implementation."
  - "Pattern: same-duration timed-session replacements require a private session-scoped reminder identifier, not a duration-scoped identifier."
requirements-completed: [NOTF-01, NOTF-02, NOTF-04]
duration: 10min
completed: 2026-05-09
---

# Phase 24 Plan 01: Timed Reminder Scheduling Summary

**Timed keep-awake now requests notification authorization at launch and schedules one session-scoped pre-expiry reminder that is skipped for short sessions and canceled on confirmed session changes**

## Performance

- **Duration:** 10 min
- **Started:** 2026-05-09T15:25:30Z
- **Completed:** 2026-05-09T15:35:27Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Added a native `UserNotifications` reminder scheduling seam plus launch-time authorization wiring in `AppDelegate`, with XCTest-safe fake injection so tests never trigger the real system prompt.
- Extended `KeepAwakeSessionModel` to own pre-expiry reminder scheduling and cancellation from confirmed timed-session transitions only, including same-duration replacement protection via session-scoped identifiers.
- Added focused launch, lifecycle, and controller regressions proving long timed sessions schedule exactly one reminder, short sessions skip it, stale reminders are canceled on confirmed mode changes, and reminder-unavailable copy reuses the existing keep-awake status row.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the reminder scheduling contract and request authorization during normal app launch** - `9c084c3` (`test`), `fda625b` (`feat`)
2. **Task 2: Make pre-expiry reminders session-scoped, skippable under two minutes, and cancellable only on confirmed session changes** - `438f245` (`test`), `8e226b1` (`feat`)

**Plan metadata:** pending final docs commit

_Note: both tasks followed the repo's TDD-style split of failing tests before implementation, so each task produced a `test` commit and a `feat` commit._

## Files Created/Modified

- `Tools Cat/KeepAwakeReminderScheduling.swift` - defines the reminder scheduler protocol, schedule result enum, production `UserNotifications` adapter, and noop fallback.
- `Tools Cat/AppDelegate.swift` - injects one shared reminder scheduler, requests authorization at launch, and exposes a testable bootstrap seam.
- `Tools Cat/KeepAwakeSessionModel.swift` - owns session-scoped reminder identifiers, skip rules, cancellation behavior, and non-blocking unavailable-state messaging.
- `Tools CatTests/AppDelegateNotificationTests.swift` - proves launch-time authorization goes through the injected fake scheduler exactly once with no real prompt dependency.
- `Tools CatTests/KeepAwakeSessionModelTests.swift` - covers long-session scheduling, short-session skip, same-duration replacement, failure rollback preservation, stop/indefinite cancellation, and reminder-unavailable behavior.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` - proves reminder-unavailable text reuses the existing keep-awake status row while the timed session remains active.
- `.planning/phases/24-timed-reminder-scheduling/24-01-SUMMARY.md` - records the implementation, verification evidence, and execution decisions for downstream phases.

## Decisions Made

- Kept reminder authorization and scheduling in one dedicated seam (`KeepAwakeReminderScheduling`) rather than calling `UNUserNotificationCenter.current()` directly from `AppDelegate` or `KeepAwakeSessionModel`.
- Preserved the existing `message -> KeepAwakePresentation.statusText -> StatusBarController` rendering chain instead of adding a new notification-specific menu row.
- Scoped reminder identity to a private per-session UUID so back-to-back `15 分钟` sessions cannot reuse the same pending reminder identifier.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Suppressed real launch-time authorization prompts during XCTest while still exercising the authorization path**
- **Found during:** Task 1 (launch-time authorization wiring)
- **Issue:** Requesting authorization unconditionally from `applicationDidFinishLaunching(_:)` would make unit tests depend on a real system prompt and become flaky.
- **Fix:** Added `bootstrapLaunchServices()`, `launchConfigurationOverride`, and `forcesReminderAuthorizationRequestDuringTests` so tests explicitly drive the launch-time authorization path through an injected fake scheduler while ordinary XCTest runs still skip the real OS prompt.
- **Files modified:** `Tools Cat/AppDelegate.swift`, `Tools CatTests/AppDelegateNotificationTests.swift`
- **Verification:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests'`
- **Committed in:** `fda625b`

---

**Total deviations:** 1 auto-fixed (1 bug)  
**Impact on plan:** The fix was necessary to keep the launch-time permission decision testable without introducing flaky OS-prompt coupling. No scope creep.

## Issues Encountered

- The executor runtime did not return its normal completion signal or write the final `24-01-SUMMARY.md`, even though all four task commits were present and the focused Phase 24 test slice passed. The summary and final execution metadata were reconstructed from the committed code, git history, and successful verification output without changing the shipped implementation.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 24 now provides a stable launch-time authorization seam and one truthful pre-expiry reminder path that Phase 25 can extend with the actual end-of-session reminder.
- Reminder-unavailable outcomes already reuse the existing keep-awake status row, so Phase 25 can focus on expiry delivery and any remaining visibility polish without rebuilding the core notification ownership model.

## Self-Check: PASSED

- FOUND: `Tools Cat/KeepAwakeReminderScheduling.swift`
- FOUND: `Tools CatTests/AppDelegateNotificationTests.swift`
- FOUND: `9c084c3`
- FOUND: `fda625b`
- FOUND: `438f245`
- FOUND: `8e226b1`

---
*Phase: 24-timed-reminder-scheduling*
*Completed: 2026-05-09*
