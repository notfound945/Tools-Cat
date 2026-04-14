---
phase: 01-truthful-foundations
plan: 01
subsystem: ui
tags: [swift, xctest, wol, macos, appkit, swiftui]
requires: []
provides:
  - "Manual MAC validation contract with exact error taxonomy and uppercase normalization"
  - "Truthful local-send wake presentation copy decoupled from transport internals"
  - "Shared WOL session and keep-awake seam types for later lifecycle rewiring"
affects: [01-02, 01-03, wol-flow, keep-awake]
tech-stack:
  added: []
  patterns:
    - "Contract-first validator and presentation helpers"
    - "Exact-copy XCTest coverage for user-facing runtime strings"
key-files:
  created:
    - Mac OS Swiss Knife/KeepAwakePresentation.swift
    - Mac OS Swiss Knife/ManualMACValidator.swift
    - Mac OS Swiss Knife/WOLSessionModel.swift
    - Mac OS Swiss Knife/WakeSendPresentation.swift
    - Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift
    - Mac OS Swiss KnifeTests/MACAddressValidatorTests.swift
    - Mac OS Swiss KnifeTests/WOLSendPresentationTests.swift
    - Mac OS Swiss KnifeTests/WOLSessionModelTests.swift
  modified:
    - Mac OS Swiss Knife.xcodeproj/project.pbxproj
key-decisions:
  - "Normalize valid MAC values in the validator result only, leaving raw field text untouched for later UI binding."
  - "Keep wake success copy strictly local-send scoped so the UI never implies the destination device actually woke."
patterns-established:
  - "Validation contract: enum state + exact user copy + reusable validator entry point"
  - "Presentation contract: transport errors mapped to user-facing copy in a dedicated helper"
requirements-completed: [WOL-02, RELY-02, RELY-03, RELY-05]
duration: 6 min
completed: 2026-04-11
---

# Phase 01: Truthful Foundations Summary

**Contract-first MAC validation, local-send wake copy, and session/keep-awake seam files with XCTest coverage for Phase 1 truth rules**

## Performance

- **Duration:** 6 min
- **Started:** 2026-04-11T04:20:00Z
- **Completed:** 2026-04-11T04:26:17Z
- **Tasks:** 3
- **Files modified:** 9

## Accomplishments
- Added the Phase 1 validator, wake-copy, WOL session, and keep-awake presentation seam files to the app and test targets.
- Implemented colon-delimited MAC validation with exact error buckets and uppercase normalized send-ready output.
- Locked the wake-result copy contract with focused XCTest coverage so later UI work cannot regress into optimistic or technical messaging.

## Task Commits

Each task was committed atomically:

1. **Task 1: Register Phase 1 contract files and declare the shared interfaces** - `9288f7d` (feat)
2. **Task 2: Implement the colon-delimited manual MAC validator and prove its error taxonomy** - `85d77f1` (feat)
3. **Task 3: Implement truthful local-send presentation mapping for WOL outcomes** - `00984c4` (test)

**Plan metadata:** committed with this summary file

## Files Created/Modified
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - registers the new Phase 1 source and XCTest files with the Xcode project.
- `Mac OS Swiss Knife/ManualMACValidator.swift` - defines the MAC validation enum, exact error copy, and uppercase normalization logic.
- `Mac OS Swiss Knife/WakeSendPresentation.swift` - maps wake send states and transport errors to truthful user-facing strings.
- `Mac OS Swiss Knife/WOLSessionModel.swift` - introduces the shared WOL session contracts and system wake-sender seam for Wave 2.
- `Mac OS Swiss Knife/KeepAwakePresentation.swift` - introduces the keep-awake confirmed/pending/failure presentation types for Wave 2.
- `Mac OS Swiss KnifeTests/MACAddressValidatorTests.swift` - covers empty, malformed, and valid MAC inputs with exact-copy assertions.
- `Mac OS Swiss KnifeTests/WOLSendPresentationTests.swift` - covers local-send success, sending, and failure presentation strings.
- `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` - provides a safe main-thread contract harness for later session lifecycle tests.
- `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` - provides the initial keep-awake presentation test anchor for later controller behavior.

## Decisions Made
- Valid MAC normalization lives in the validator result instead of in the text field so later SwiftUI bindings can preserve raw user input while still getting a send-ready value.
- Wake-result copy is centralized in `WakeSendPresentation` and `WOLSenderError.userMessage` so later UI rewiring cannot reintroduce raw socket/debug output.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Main-thread crash in the session scaffold test**
- **Found during:** Task 1 (Register Phase 1 contract files and declare the shared interfaces)
- **Issue:** The initial `WOLSessionModelTests` stub instantiated the observable session model off the main actor and crashed under the project's default actor-isolation settings.
- **Fix:** Moved the stub assertion body into `MainActor.run` so the contract harness matches the runtime ownership model.
- **Files modified:** Mac OS Swiss KnifeTests/WOLSessionModelTests.swift
- **Verification:** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests/testModelStoresPublishedContracts'`
- **Committed in:** 9288f7d

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix stayed within the intended test harness scope and removed a runtime crash without changing the planned feature surface.

## Issues Encountered
- The first task-level XCTest run exposed an actor-isolation crash in the `WOLSessionModel` stub test. After moving that assertion onto the main actor, all targeted and plan-level tests passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `01-02` can now build the long-lived WOL session model against concrete validation and wake-copy contracts instead of inventing new state semantics.
- `01-03` can now implement keep-awake pending/confirmed rendering against dedicated presentation types.
- No blockers remain for Wave 2.

## Self-Check: PASSED

---
*Phase: 01-truthful-foundations*
*Completed: 2026-04-11*
