---
phase: 24-timed-reminder-scheduling
verified: 2026-05-09T23:51:43+08:00
status: human_needed
score: 5/5 must-haves verified
human_verification:
  - test: "Launch the app from a clean notification-permission state and observe the first authorization prompt"
    expected: "The menu bar item appears immediately, the macOS notification permission prompt appears once, and the app remains responsive while the prompt is shown or answered"
    why_human: "The real macOS authorization prompt is OS-managed and intentionally replaced with a fake in XCTest"
  - test: "Run one timed keep-awake session longer than 2 minutes and one at 2 minutes or less"
    expected: "Only the longer session produces one pre-expiry local notification near endDate minus 120 seconds, and the shorter session produces none"
    why_human: "Actual local-notification delivery timing and banner presentation are managed by macOS rather than by deterministic unit tests"
---

# Phase 24: Timed Reminder Scheduling Verification Report

**Phase Goal:** The app can request local-notification permission when needed and keep pre-expiry reminder scheduling tied to the currently active timed keep-awake session.  
**Verified:** 2026-05-09T23:51:43+08:00  
**Status:** human_needed  
**Re-verification:** No - this is the initial Phase 24 verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Normal app launch requests local-notification authorization for timed keep-awake reminders without blocking menu-bar startup or becoming a prerequisite for keep-awake use. | ✓ VERIFIED | [`Tools Cat/AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift:22) calls `bootstrapLaunchServices()` before status-bar construction; [`bootstrapLaunchServices()`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift:63) creates the shared scheduler and fires `requestAuthorizationAtLaunch()` without awaiting a result; [`Tools Cat/KeepAwakeReminderScheduling.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeReminderScheduling.swift:29) uses `requestAuthorization(options: [.alert, .sound])` fire-and-forget; focused launch tests pass in [`Tools CatTests/AppDelegateNotificationTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/AppDelegateNotificationTests.swift:8). |
| 2 | Starting a timed keep-awake session with more than `2 分钟` remaining schedules exactly one pending local reminder for about two minutes before that confirmed session ends. | ✓ VERIFIED | [`Tools Cat/KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:246) computes `fireAfter = endDate.timeIntervalSince(now) - 120` and schedules one reminder with a session-scoped identifier; [`Tools CatTests/KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:185) verifies one request with title/body and a `780` second lead for a `15 分钟` session. |
| 3 | Starting a timed keep-awake session with `2 分钟` or less remaining leaves no pending pre-expiry reminder. | ✓ VERIFIED | [`Tools Cat/KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:256) clears active reminder state and returns when `fireAfter <= 0`; [`Tools CatTests/KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:213) verifies a `120` second session schedules nothing and cancels nothing. |
| 4 | Replacing a timed session, stopping it successfully, or switching to `无限常亮` leaves only the current confirmed session eligible to notify later. | ✓ VERIFIED | [`Tools Cat/KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:247) cancels the previous reminder identifier only after the replacement becomes the confirmed mode, and [`cancelActiveTimedReminder()`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:285) runs on confirmed stop/indefinite transitions; regression coverage exists in [`Tools CatTests/KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:238) and [`Tools CatTests/KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:304). |
| 5 | If reminder scheduling is unavailable, timed keep-awake still enters the confirmed timed state and the existing keep-awake status row carries the reminder-unavailable message instead of a new UI surface. | ✓ VERIFIED | [`Tools Cat/KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:274) keeps the timed mode while mapping `.permissionUnavailable` and `.failed` into `message`; [`Tools Cat/KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakePresentation.swift:31) prioritizes `message` in `statusText`; [`Tools Cat/StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/StatusBarController.swift:178) renders that into `keepAwakeStatusItem`; tests cover the model path in [`Tools CatTests/KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:362) and the menu-row reuse in [`Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/StatusBarControllerKeepAwakeMenuTests.swift:219). |

**Score:** 5/5 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Tools Cat/KeepAwakeReminderScheduling.swift` | Launch-time authorization plus pending reminder schedule/cancel adapter around `UNUserNotificationCenter` | ✓ VERIFIED | Exists, is substantive, and implements the full contract with authorization request, settings gate, one-shot request creation, and pending-request cancellation in [Tools Cat/KeepAwakeReminderScheduling.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeReminderScheduling.swift:4). |
| `Tools Cat/AppDelegate.swift` | Shared reminder scheduler creation, launch-time authorization wiring, and session injection | ✓ VERIFIED | Exists, builds one scheduler in `configureSharedStores()`, injects it into `KeepAwakeSessionModel`, and requests authorization from `bootstrapLaunchServices()` in [Tools Cat/AppDelegate.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift:92). |
| `Tools Cat/KeepAwakeSessionModel.swift` | Session-owned schedule/skip/cancel truth and non-blocking unavailable messaging | ✓ VERIFIED | Exists, owns `activeTimedReminderSessionID` plus `activeTimedReminderIdentifier`, computes eligibility from real session timing, and keeps reminder failures non-blocking in [Tools Cat/KeepAwakeSessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:17). |
| `Tools CatTests/AppDelegateNotificationTests.swift` | Focused launch authorization regression coverage through a fake scheduler | ✓ VERIFIED | Exists and proves authorization request count and factory injection without touching the real system prompt in [Tools CatTests/AppDelegateNotificationTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/AppDelegateNotificationTests.swift:8). |
| `Tools CatTests/KeepAwakeSessionModelTests.swift` | Deterministic coverage for scheduling, skipping, replacement, cancelation, and permission-unavailable behavior | ✓ VERIFIED | Exists and contains focused reminders coverage including schedule, skip, replacement success/failure, stop, switch, and unavailable-message behavior in [Tools CatTests/KeepAwakeSessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:185). |
| `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` | Controller regression proving reminder-unavailable copy stays on the existing keep-awake status row | ✓ VERIFIED | Exists and proves the active timed item stays selected while the status row shows `提醒不可用：通知权限未开启` in [Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/StatusBarControllerKeepAwakeMenuTests.swift:219). |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `Tools Cat/AppDelegate.swift` | `Tools Cat/KeepAwakeReminderScheduling.swift` | launch-time request plus shared service injection | ✓ WIRED | `gsd-tools verify key-links` passed, and `AppDelegate` both constructs the scheduler and calls `requestAuthorizationAtLaunch()` before building the menu-bar controller. |
| `Tools Cat/KeepAwakeSessionModel.swift` | `Tools Cat/KeepAwakeReminderScheduling.swift` | `schedulePreExpiryReminder` and `cancelPendingReminder` with one session-scoped identifier | ✓ WIRED | `gsd-tools verify key-links` passed, and the model routes all reminder scheduling and cancellation through the injected scheduler seam rather than direct `UNUserNotificationCenter` calls. |
| `Tools Cat/KeepAwakeSessionModel.swift` | `Tools Cat/StatusBarController.swift` | `message -> KeepAwakePresentation.statusText -> keepAwakeStatusItem` | ✓ WIRED | `gsd-tools verify key-links` passed, and the existing keep-awake message path remains the only UI surface for reminder-unavailable state. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `Tools Cat/KeepAwakeSessionModel.swift` | `activeTimedReminderIdentifier`, `message` | `startTimed(...)` confirms power-enable, derives `endDate` from the selected managed duration, computes `fireAfter`, then consumes real scheduler completion results in `installTimedReminder(...)` | Yes - the reminder state is derived from the active timed session and async scheduler callbacks, not static placeholders | ✓ FLOWING |
| `Tools Cat/StatusBarController.swift` | `keepAwakeStatusItem.title` | `renderKeepAwakePresentation()` reads `keepAwakeSession.confirmedMode`, `pendingAction`, `message`, and `countdownNow` through `KeepAwakePresentation.statusText` | Yes - the rendered row comes from the live shared session model and changes with real state transitions | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Focused Phase 24 automated slice | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | Re-run during verification on 2026-05-09: 26 tests executed, 0 failures | ✓ PASS |
| Full unit suite regression signal | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO` | User-provided execution evidence reports 130/130 unit tests green; one UI test `testDeviceLibraryNameValidationRevealsAfterSubmit` failed once in the mixed full-suite run and passed immediately when rerun alone | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `NOTF-01` | `24-01-PLAN.md` | User can allow local notification permission the first time timed keep-awake reminder delivery is needed | ✓ SATISFIED | Launch-time authorization is wired through one shared scheduler in [Tools Cat/AppDelegate.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift:63), the production scheduler requests macOS notification permission in [Tools Cat/KeepAwakeReminderScheduling.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeReminderScheduling.swift:29), and focused launch tests prove the path is invoked exactly once. |
| `NOTF-02` | `24-01-PLAN.md` | User receives one local notification about `2 分钟` before a timed keep-awake session ends when the session duration leaves at least two minutes remaining | ✓ SATISFIED | The session model computes one pre-expiry reminder at `endDate - 120s` only when `fireAfter > 0` in [Tools Cat/KeepAwakeSessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:246), and the focused unit tests prove both the schedule and skip cases in [Tools CatTests/KeepAwakeSessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:185). |
| `NOTF-04` | `24-01-PLAN.md` | Replacing, stopping, or switching away from a timed keep-awake session cancels stale scheduled reminders so old notifications never describe the wrong active session | ✓ SATISFIED | Previous identifiers are canceled on confirmed replacement and cleared on confirmed stop/indefinite transitions in [Tools Cat/KeepAwakeSessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift:247), with regressions covering replacement, stop, and switch paths in [Tools CatTests/KeepAwakeSessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift:238). |

All requirement IDs declared in PLAN frontmatter are accounted for in `.planning/REQUIREMENTS.md`. No orphaned Phase 24 requirements were found.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No placeholder reminder path, no direct `UNUserNotificationCenter` calls from the session model, and no stale-reminder TODO/FIXME patterns were found in the phase artifacts | ℹ️ Info | No blocker or warning anti-patterns detected in the verified Phase 24 implementation |

### Human Verification Required

### 1. Launch-Time Authorization Prompt

**Test:** Reset `Tools Cat` notification permission to a clean state, launch the app normally, and observe startup.  
**Expected:** The menu bar item appears immediately, the macOS notification authorization prompt appears once, and answering it does not freeze startup.  
**Why human:** The real system permission prompt is OS-managed and intentionally replaced with an injected fake in XCTest.

**Current manual evidence:** On 2026-05-10, the live app did issue `UNUserNotificationCenter.requestAuthorization(options: [.alert, .sound])` during startup, but the local machine contains multiple registered `cn.notfound945.Tools-Cat` app paths in LaunchServices (`/Applications`, multiple repo build outputs, and the current DerivedData Debug app). In this environment the production launch returned `Requested authorization [ didGrant: 0 hasError: 1 ]` before a clean, deterministic first-prompt path could be proven, so the final prompt acceptance still needs one explicit human pass on the intended shipped app path.

### 2. Real Pre-Expiry Notification Delivery

**Test:** Run one timed keep-awake session longer than `2 分钟` and one at `2 分钟` or less, then wait for the notification window.  
**Expected:** Only the longer session produces one pre-expiry local notification near `endDate - 120s`; the shorter session produces none.  
**Why human:** Notification delivery timing, system presentation, and permission-state interaction are controlled by macOS rather than deterministic unit tests.

**Current manual evidence:** The code path, focused tests, and live menu behavior all agree that authorized sessions longer than `2 分钟` should schedule exactly one pending reminder and `<= 2 分钟` sessions should skip it, but the same local authorization-state ambiguity above prevented a trustworthy end-to-end desktop-delivery proof on 2026-05-10. This remains a real macOS manual check, not an automated gap in the phase implementation itself.

### Gaps Summary

No code, wiring, or automated behavior gaps were found against the Phase 24 must-haves. The remaining verification work is limited to macOS-managed behavior outside deterministic XCTest coverage: the real permission prompt path and actual local-notification delivery timing. On this machine, duplicate LaunchServices registrations for the same bundle identifier made that manual proof nondeterministic, so the phase remains `human_needed` rather than `passed`.

---

_Verified: 2026-05-09T23:51:43+08:00_  
_Verifier: Codex_
