---
phase: 01-truthful-foundations
plan: 02
subsystem: ui
tags: [swift, swiftui, appkit, wol, xctest, macos]
requires:
  - phase: 01-01
    provides: "Validator, wake-copy, and session contract types"
provides:
  - "Retained WOL session owner with real-time validation and background send continuity"
  - "SwiftUI WOL form and AppKit window wired to shared session state"
affects: [01-03, phase-verification, wol-flow]
tech-stack:
  added: []
  patterns:
    - "Observable session owner injected from AppDelegate into AppKit and SwiftUI surfaces"
    - "Background work reports completion back onto main-thread published state"
key-files:
  created:
    - .planning/phases/01-truthful-foundations/01-02-SUMMARY.md
  modified:
    - Mac OS Swiss Knife/WOLSessionModel.swift
    - Mac OS Swiss Knife/WOLView.swift
    - Mac OS Swiss Knife/WOLWindow.swift
    - Mac OS Swiss Knife/AppDelegate.swift
    - Mac OS Swiss KnifeTests/WOLSessionModelTests.swift
key-decisions:
  - "Keep the WOL draft and result lifecycle in one retained session model instead of splitting ownership across notifications and view-local state."
  - "Treat hidden-window send completion as durable session state so reopen shows the final result instead of resetting blindly."
patterns-established:
  - "AppDelegate owns long-lived session state and injects it into reusable AppKit controllers"
  - "SwiftUI view rendering derives directly from typed session and validation state, not string inspection"
requirements-completed: [WOL-02, RELY-02, RELY-03]
duration: 6 min
completed: 2026-04-11
---

# Phase 01: Truthful Foundations Summary

**Retained WOL session ownership with truthful send-state rendering across close, reopen, and background completion**

## Performance

- **Duration:** 6 min
- **Started:** 2026-04-11T04:31:00Z
- **Completed:** 2026-04-11T04:37:00Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Turned `WOLSessionModel` into the lifecycle owner for validation, send state, window visibility, and background send completion.
- Rewired `WOLView`, `WOLWindow`, and `AppDelegate` so the WOL form resumes the same session instead of rebuilding local state on every reopen.
- Added async XCTest coverage for invalid-send blocking, result clearing, hidden-window completion, reopen semantics, and main-thread publication.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement WOLSessionModel as the lifecycle owner and prove its background-send semantics** - `b496c41` (feat)
2. **Task 2: Rewire the WOL window and SwiftUI form to the shared session model** - `c2acd85` (feat)

**Plan metadata:** committed with this summary file

## Files Created/Modified
- `Mac OS Swiss Knife/WOLSessionModel.swift` - adds the retained draft/send owner, validation updates, background send queue, and hidden-window completion handling.
- `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` - verifies custom validation gating, reopen behavior, background completion, and main-thread publication.
- `Mac OS Swiss Knife/WOLView.swift` - binds the form to `@ObservedObject var session`, drives status from typed state, and gates the send CTA with `session.isSending || !session.canSend`.
- `Mac OS Swiss Knife/WOLWindow.swift` - injects the shared session into the hosting view and routes show/close lifecycle directly to the model.
- `Mac OS Swiss Knife/AppDelegate.swift` - retains one app-session `WOLSessionModel` and injects it into the reusable WOL window.

## Decisions Made
- The shared WOL session model owns both draft state and lifecycle events so closing the window no longer implies clearing unfinished work.
- Reopen only clears stale completed results when nothing finished while hidden, preserving the final result of background sends after the window returns.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Prevent duplicate close observers on repeated WOL window opens**
- **Found during:** Task 2 (Rewire the WOL window and SwiftUI form to the shared session model)
- **Issue:** The old `show()` path re-registered the close-request observer on every reopen, which would multiply handlers over time once the shared window was retained.
- **Fix:** Moved close-request observer setup into the designated initializer and removed the repeated registration from `show()`.
- **Files modified:** Mac OS Swiss Knife/WOLWindow.swift
- **Verification:** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'`
- **Committed in:** c2acd85

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix tightened window lifecycle correctness without changing the intended user-facing flow or widening scope.

## Issues Encountered
- None beyond the duplicated observer risk caught during the retained-window refactor.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- The WOL lane is ready for full Phase 1 verification once the keep-awake lane finishes and the shared Wave 2 unit sweep runs.
- No blockers remain inside the WOL window/session flow.

## Self-Check: PASSED

---
*Phase: 01-truthful-foundations*
*Completed: 2026-04-11*
