---
phase: 25-expiry-reminder-truth
verified: 2026-05-10T03:43:35Z
status: passed
score: 4/4 must-haves verified
human_verification:
  - test: "Real timed expiry end reminder"
    expected: "With notifications allowed, one `常亮已结束` reminder arrives only after the timed session has actually turned off."
    why_human: "Notification Center delivery timing and visible presentation are controlled by macOS."
  - test: "Denied-permission timed sessions"
    expected: "With notifications denied, both >2 minute and 2 minute timed sessions still start, count down, and end, while the keep-awake status row shows countdown first and `提醒不可用：通知权限未开启` second."
    why_human: "Real macOS authorization denial state and live status-item rendering are OS/UI behaviors beyond static verification."
  - test: "Foreground reminder presentation"
    expected: "While the app is active/frontmost near expiry, the end reminder still presents through the native Apple notification surface."
    why_human: "Foreground notification presentation depends on `UNUserNotificationCenterDelegate` behavior under live OS policy."
---

# Phase 25: Expiry Reminder Truth Verification Report

**Phase Goal:** Timed keep-awake ending now produces one truthful local notification, and reminder-unavailable states stay visible to the user without breaking keep-awake behavior.
**Verified:** 2026-05-10T03:43:35Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | When a timed keep-awake session naturally expires and the underlying keep-awake state actually turns off, the app delivers exactly one local notification that the session ended. | ✓ VERIFIED | [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:193>) only calls `deliverExpiryReminder` after `.success(false)` or `.unchanged(false)` and a matching `.timedExpiry(sessionID:)`; [`KeepAwakeReminderScheduling`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeReminderScheduling.swift:111>) sends an immediate `UNNotificationRequest` with `trigger: nil`; `testTimedExpirySuccessfulStopDeliversOneExpiryReminder` passed in [`KeepAwakeSessionModelTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/KeepAwakeSessionModelTests.swift:391>). |
| 2 | Replacing a timed session, stopping it manually, or failing to turn keep-awake off never produces a stale or false expiry notification. | ✓ VERIFIED | Countdown expiry is gated by current confirmed `endDate` and `activeTimedSessionID` in [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:258>), old timed countdowns are canceled on replacement and timed state is cleared on mode changes in [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:276>); `testTimedExpiryDisableFailureDoesNotDeliverExpiryReminder` and `testManualStopDoesNotDeliverExpiryReminder` passed in [`KeepAwakeSessionModelTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/KeepAwakeSessionModelTests.swift:430>) and [`KeepAwakeSessionModelTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/KeepAwakeSessionModelTests.swift:459>). |
| 3 | Timed keep-awake still starts, counts down, and ends correctly when local notifications are denied or unavailable. | ✓ VERIFIED | Timed enable confirmation and countdown installation happen before reminder-side availability is surfaced, and stop/countdown logic does not depend on reminder availability in [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:133>) and [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:175>); unavailable-state tests keep the model in timed mode and confirm auth checks still run for short sessions in [`KeepAwakeSessionModelTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/KeepAwakeSessionModelTests.swift:362>) and [`KeepAwakeSessionModelTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/KeepAwakeSessionModelTests.swift:483>). |
| 4 | During an active timed keep-awake session with unavailable reminders, the existing keep-awake status area shows the countdown on one line and the reminder-unavailable truth on a second line. | ✓ VERIFIED | [`KeepAwakePresentation`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakePresentation.swift:37>) produces structured `statusLines` with countdown as primary and reminder-unavailable copy as secondary; [`StatusBarController`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/StatusBarController.swift:178>) renders the existing disabled status row as an attributed two-line title; controller tests passed in [`StatusBarControllerKeepAwakeMenuTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift:219>) and [`StatusBarControllerKeepAwakeMenuTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift:243>). |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Tools Cat/KeepAwakeReminderScheduling.swift` | Scheduler seam owns auth checks, immediate expiry delivery, and foreground presentation. | ✓ VERIFIED | Protocol and production adapter implement `installForegroundPresentationDelegate`, `fetchAuthorizationState`, `deliverExpiryReminder`, and foreground presentation filtering. |
| `Tools Cat/KeepAwakeSessionModel.swift` | Session owns timed-session identity, stop reason truth, reminder availability, and expiry delivery. | ✓ VERIFIED | Timed-session UUID, stop-reason guard, availability state, and cleanup/delivery flow are all implemented and compiled into the app path. |
| `Tools Cat/KeepAwakePresentation.swift` | Structured status lines can carry countdown truth plus reminder-unavailable truth. | ✓ VERIFIED | `KeepAwakeStatusLines` drives one-line or two-line keep-awake status output. |
| `Tools Cat/StatusBarController.swift` | Existing keep-awake status row renders single-line or two-line output without new menu surface. | ✓ VERIFIED | `renderKeepAwakePresentation()` switches between hidden, plain title, and attributed multiline title. |
| `Tools Cat/AppDelegate.swift` | Launch installs foreground presentation before authorization request. | ✓ VERIFIED | `bootstrapLaunchServices()` installs the delegate, then conditionally requests authorization; [`Tools_CatApp`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/Tools_CatApp.swift:10>) wires `AppDelegate` into the app entry point. |
| `Tools CatTests/KeepAwakeSessionModelTests.swift` | Regression coverage for truthful expiry delivery, stale-reminder suppression, and unavailable-state ownership. | ✓ VERIFIED | Contains direct tests for expiry delivery, manual-stop suppression, disable-failure suppression, and short-session unavailable state. |
| `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` | Controller coverage for two-line status rendering in the existing row. | ✓ VERIFIED | Covers both >2 minute and 2 minute unavailable-reminder rendering without menu expansion. |
| `Tools CatTests/AppDelegateNotificationTests.swift` | Launch bootstrap coverage through injected scheduler seam. | ✓ VERIFIED | Verifies install-before-request ordering and scheduler injection without direct `UNUserNotificationCenter.current()` use in `AppDelegate`. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `Tools Cat/KeepAwakeSessionModel.swift` | `Tools Cat/KeepAwakeReminderScheduling.swift` | authorization checks, pre-expiry scheduling, and expiry delivery guarded by active timed-session UUID plus stop reason | ✓ WIRED | `activateTimedSession` fetches auth and schedules pre-expiry reminders; `handleStopOutcome` gates `deliverExpiryReminder` on confirmed `.off` plus matching timed-expiry session ID. |
| `Tools Cat/KeepAwakeSessionModel.swift` | `Tools Cat/KeepAwakePresentation.swift` | dedicated reminder-availability state passed into structured status-line presentation | ✓ WIRED | `StatusBarController` constructs `KeepAwakePresentation` from `confirmedMode`, `message`, `reminderAvailability`, and `countdownNow`. |
| `Tools Cat/KeepAwakePresentation.swift` | `Tools Cat/StatusBarController.swift` | status lines rendered through the existing keep-awake status row via `attributedTitle` | ✓ WIRED | `renderKeepAwakePresentation()` reads `statusLines` and sends two-line output through `makeKeepAwakeStatusTitle`. |
| `Tools Cat/AppDelegate.swift` | `Tools Cat/KeepAwakeReminderScheduling.swift` | launch-time foreground presentation install followed by the existing authorization request | ✓ WIRED | `bootstrapLaunchServices()` calls `installForegroundPresentationDelegate()` before `requestAuthorizationAtLaunch()` in [`AppDelegate`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/AppDelegate.swift:63>); `testBootstrapLaunchServicesInstallsForegroundPresentationBeforeAuthorizationRequest` passed in [`AppDelegateNotificationTests`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools CatTests/AppDelegateNotificationTests.swift:8>). `gsd-tools verify key-links` reported a false negative here, but manual source inspection and the launch-order test confirm the wiring. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `Tools Cat/KeepAwakeSessionModel.swift` | `pendingStopReason`, `activeTimedSessionID`, `reminderAvailability` | `powerController` enable/disable outcomes, countdown timer ticks, and `reminderScheduler.fetchAuthorizationState(...)` / schedule results | Yes | ✓ FLOWING |
| `Tools Cat/KeepAwakePresentation.swift` | `statusLines` | `confirmedMode`, `pendingAction`, `message`, `reminderAvailability`, `countdownNow` from `KeepAwakeSessionModel` | Yes | ✓ FLOWING |
| `Tools Cat/StatusBarController.swift` | `keepAwakeStatusItem.title` / `attributedTitle` | Live `KeepAwakePresentation.statusLines` rebuilt from `keepAwakeSession.objectWillChange` | Yes | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Truthful timed-expiry end reminder | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests/testTimedExpirySuccessfulStopDeliversOneExpiryReminder' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests/testManualStopDoesNotDeliverExpiryReminder' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests/testReminderPermissionUnavailableShowsCountdownAndUnavailableTextInExistingStatusRow' -only-testing:'Tools CatTests/AppDelegateNotificationTests/testBootstrapLaunchServicesInstallsForegroundPresentationBeforeAuthorizationRequest'` | `testTimedExpirySuccessfulStopDeliversOneExpiryReminder()` passed | ✓ PASS |
| Manual stop suppresses stale expiry reminder | Same targeted `xcodebuild test` command | `testManualStopDoesNotDeliverExpiryReminder()` passed | ✓ PASS |
| Existing status row keeps countdown + unavailable truth visible | Same targeted `xcodebuild test` command | `testReminderPermissionUnavailableShowsCountdownAndUnavailableTextInExistingStatusRow()` passed | ✓ PASS |
| Launch bootstrap installs delegate before auth request | Same targeted `xcodebuild test` command | `testBootstrapLaunchServicesInstallsForegroundPresentationBeforeAuthorizationRequest()` passed | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `NOTF-03` | `25-01-PLAN.md` | User receives one local notification when a timed keep-awake session actually ends | ✓ SATISFIED | Confirmed-off-only expiry delivery is implemented in [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:193>) and immediate reminder delivery is implemented in [`KeepAwakeReminderScheduling`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeReminderScheduling.swift:111>); targeted expiry-delivery and bootstrap tests passed. |
| `NOTF-05` | `25-01-PLAN.md` | If local notification permission is unavailable, timed keep-awake still works and the app surfaces a truthful reminder-unavailable state instead of implying reminders will arrive | ✓ SATISFIED | All timed sessions fetch auth state and preserve unavailable truth in [`KeepAwakeSessionModel`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakeSessionModel.swift:276>); two-line rendering is implemented in [`KeepAwakePresentation`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/KeepAwakePresentation.swift:49>) and [`StatusBarController`](</Users/hailinpan/Documents/GitHub/Tools-Cat/Tools Cat/StatusBarController.swift:198>); unavailable-state tests for long and short sessions passed. |

No orphaned Phase 25 requirements were found in `.planning/REQUIREMENTS.md`; the phase mapping only lists `NOTF-03` and `NOTF-05`, and both appear in the plan frontmatter.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No TODO/FIXME/placeholder/hollow data-path pattern detected in phase files scanned | ℹ️ Info | No blocker stubs or orphaned reminder/UI paths were found during verification. |

### Human Verification

### 1. Real Timed Expiry End Reminder

**Test:** Allow notifications for `Tools Cat`, start a timed keep-awake session, wait for natural expiry, and watch both the menu state and Notification Center.
**Expected:** The keep-awake state returns to off first, then one `常亮已结束` reminder appears. No duplicate end reminder should appear.
**Why human:** macOS owns actual local notification delivery timing and visible presentation.

### 2. Denied-Permission Timed Sessions

**Test:** Deny notifications for `Tools Cat`, then start one timed session longer than `2 分钟` and one timed session of exactly `2 分钟`.
**Expected:** Both sessions still start, count down, and end. The existing keep-awake status row shows countdown on line one and `提醒不可用：通知权限未开启` on line two while the session is active.
**Why human:** Real notification denial state and live status-item rendering are OS/UI behaviors beyond source and unit/controller verification.

### 3. Foreground Reminder Presentation

**Test:** Keep `Tools Cat` active/frontmost near timed expiry.
**Expected:** The end reminder still presents through the native Apple foreground notification surface.
**Why human:** Foreground presentation depends on the live `UNUserNotificationCenterDelegate` + system UI policy boundary.

### Gaps Summary

No automated code or wiring gaps were found against the phase must-haves. The required live macOS notification checks were subsequently approved by human verification, so the phase is now marked `passed`.

---

_Verified: 2026-05-10T03:43:35Z_  
_Verifier: Claude (gsd-verifier)_
