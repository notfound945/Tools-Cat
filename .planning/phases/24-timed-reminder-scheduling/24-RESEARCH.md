# Phase 24: Timed Reminder Scheduling - Research

**Researched:** 2026-05-09
**Domain:** macOS local notifications for timed keep-awake session truth
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Reminder availability feedback
- **D-01:** If local notification permission is unavailable, reminder-unavailable feedback should reuse the existing keep-awake status surface instead of adding a new window, banner, or settings UI in this phase.
- **D-02:** Reminder-unavailable visibility must stay aligned with the existing keep-awake truth model: reminder failure can be shown, but it must not block timed keep-awake start, countdown, replacement, or stop behavior.

### Permission request timing
- **D-03:** The app should request local notification permission on app launch rather than waiting until the first timed keep-awake session starts.
- **D-04:** Requesting permission at launch is only about preparing reminder capability; it does not make notification permission a prerequisite for using timed keep-awake.

### Timed reminder scheduling and replacement
- **D-05:** Starting a timed keep-awake session with more than `2 分钟` remaining must schedule exactly one pre-expiry reminder for about two minutes before the active session end.
- **D-06:** Starting a timed keep-awake session with `2 分钟` or less remaining must skip the pre-expiry reminder rather than delivering an immediate or misleading reminder.
- **D-07:** Replacing a timed session with another timed session, stopping it early, or switching to `无限常亮` must cancel the old timed session's scheduled reminder so only the currently active timed session can still notify.
- **D-08:** Reminder identity and cancellation semantics should stay session-scoped to the active timed keep-awake session, not just duration-scoped, so two sessions with the same duration cannot leak stale reminders.

### Scope and milestone guardrails
- **D-09:** Phase 24 only covers the pre-expiry reminder scheduling path; the actual “到点提醒一次” delivery remains Phase 25 work even though the product direction is already confirmed.
- **D-10:** Do not add notification preference toggles, configurable lead times, reminder history, WOL notifications, or any broader app-wide notification surface in this phase.
- **D-11:** Keep the shipped timed keep-awake countdown/menu structure unchanged; this phase only adds notification-side behavior around the existing session truth.

### Claude's Discretion
- Choose the concrete notification service abstraction and test seam, as long as permission state, scheduling, and cancellation remain deterministic and unit-testable.
- Decide the exact launch-time request trigger point inside app startup, as long as it happens during normal app launch and does not create a second source of keep-awake truth.
- Decide the exact reminder copy and request identifier format, as long as copy stays concise and the identifier strategy supports strict stale-reminder cancellation.

### Deferred Ideas (OUT OF SCOPE)
- Actual end-of-session reminder delivery (`NOTF-03`) remains Phase 25 work even though the reminder should exist in the shipped milestone.
- Reminder-unavailable state wording/visibility rules beyond reusing the current keep-awake surface remain Phase 25 work because that is where `NOTF-05` is formally scoped.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| NOTF-01 | User can allow local notification permission the first time timed keep-awake reminder delivery is needed | Launch-time authorization request in `AppDelegate`, using `UNUserNotificationCenter.requestAuthorization(...)` before any scheduling |
| NOTF-02 | User receives one local notification about `2 分钟` before a timed keep-awake session ends when the session duration leaves at least two minutes remaining | Schedule exactly one nonrepeating `UNTimeIntervalNotificationTrigger` after confirmed timed-session activation when remaining time is `> 120` seconds |
| NOTF-04 | Replacing, stopping, or switching away from a timed keep-awake session cancels stale scheduled reminders so old notifications never describe the wrong active session | Keep reminder identity private to the active timed session and cancel pending requests on confirmed mode changes away from that session |
</phase_requirements>

## Summary

Phase 24 should reuse the app's existing pattern from timed keep-awake and WOL timeout work: keep one shared truth owner, inject a narrow side-effect seam, and make the session model decide when reminder scheduling or cancellation happens. The right owner is still `KeepAwakeSessionModel`, because it already owns the confirmed timed lifecycle, replacement semantics, countdown end date, and failure rollback behavior. The new side-effect seam should wrap `UNUserNotificationCenter`.

Technically, the standard stack is Apple `UserNotifications` with one nonrepeating `UNTimeIntervalNotificationTrigger`. Apple requires calling `requestAuthorization` before relying on local-notification delivery, and `UNAuthorizationStatus.denied` should be treated as reminder-unavailable for planning because delivery cannot be trusted. Apple also recommends asking in context instead of at first launch, but the user explicitly locked launch-time requesting for this repo. Implement that in `AppDelegate`, keep it non-blocking, and keep actual pre-expiry scheduling tied to confirmed timed-session transitions only.

The main planning risk is not the API surface; it is preserving truth during failure and replacement edges. Do not schedule on menu click. Do not cancel the old timed reminder when a replacement start is merely pending. Do cancel or restore reminders in the same places the model already confirms or rolls back timed state. The planner should optimize for a private session identifier inside `KeepAwakeSessionModel`, one injected reminder scheduler service, and focused XCTest coverage in the existing keep-awake suite plus one narrow app-start authorization test.

**Primary recommendation:** Add a `UNUserNotificationCenter`-backed reminder service, request authorization once during normal app launch, and let `KeepAwakeSessionModel` schedule or cancel one session-scoped pre-expiry notification only after confirmed timed-session state changes.

## Project Constraints (from CLAUDE.md)

- Stay native to the existing macOS AppKit/SwiftUI stack; do not introduce cross-platform abstractions or third-party notification wrappers.
- Keep scope small, restrained, and polished; do not turn this phase into general notification settings UI.
- Preserve truthful state: stable UI and notifications must reflect confirmed underlying state, not optimistic intent.
- Keep new code maintainable by creating explicit seams around side effects instead of deepening controller/view coupling.
- Preserve the current minimum deployment target of macOS 14.0.
- Follow existing repo style: Swift source, English identifiers, Chinese user-facing strings, 4-space Xcode formatting, contiguous import blocks, guard-led early exits.
- Prefer focused XCTest coverage around models/controllers over broad new UI automation.
- Avoid introducing new lint/format/build systems; the repo is Xcode-project-driven.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `UserNotifications` | macOS SDK 26.2, available since macOS 10.14 | Authorization, scheduling, and cancellation of local reminders | Apple-native notification framework for local notifications on macOS |
| `Foundation` | macOS SDK 26.2 | Date math, identifiers, callback plumbing | Already the repo baseline for model logic and scheduling math |
| `XCTest` | Xcode 26.2 | Deterministic unit/controller regression coverage | Existing repo test framework and current phase's best verification seam |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `AppKit` | macOS SDK 26.2 | Launch lifecycle via `AppDelegate` | Request launch-time notification authorization without adding new UI |
| `Combine` | macOS SDK 26.2 | Existing published-state propagation into `StatusBarController` | Keep status rendering model-driven if reminder-unavailable messages surface later |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `UNTimeIntervalNotificationTrigger` | `UNCalendarNotificationTrigger` | Calendar trigger is valid, but interval scheduling better matches the current model's confirmed `endDate` and simplifies deterministic tests |
| Completion-handler `UNUserNotificationCenter` API | `async/await` wrappers | Async API is current, but the repo already uses callback seams and production/test code will integrate more cleanly with completion handlers |
| App-owned timer to fire reminders | System local notifications | Hand-rolled timers fail when the app is backgrounded or not active; `UNUserNotificationCenter` is the correct system boundary |

**Installation:**
```bash
# None. Phase 24 uses macOS system frameworks already present in Xcode/macOS SDK.
```

**Version verification:** Verified locally on 2026-05-09 with `xcodebuild -version` (`Xcode 26.2`), `xcrun --show-sdk-version` (`26.2`), and SDK headers under `UserNotifications.framework/Headers`.

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── AppDelegate.swift                    # launch-time authorization request trigger
├── KeepAwakeSessionModel.swift          # confirmed timed session truth + reminder orchestration
├── KeepAwakePresentation.swift          # existing status/message surface
├── KeepAwakeReminderScheduling.swift    # new protocol + production UNUserNotificationCenter adapter
└── StatusBarController.swift            # render-only consumer of keep-awake presentation

Tools CatTests/
├── KeepAwakeSessionModelTests.swift     # schedule / skip / cancel / restore behavior
└── AppDelegateNotificationTests.swift   # launch-time authorization request seam
```

### Pattern 1: Session-Owned Reminder Orchestration
**What:** Keep reminder schedule/cancel calls inside `KeepAwakeSessionModel`, next to the already-confirmed timed lifecycle.
**When to use:** Every time timed keep-awake state becomes confirmed, restored, or canceled.
**Example:**
```swift
protocol KeepAwakeReminderScheduling {
    func requestAuthorizationAtLaunch()
    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    )
    func cancelPendingReminder(identifier: String)
}
```
Source: Apple `UNUserNotificationCenter` API and existing repo seam pattern in `WOLSessionModel`

### Pattern 2: Private Session Identity, Not Public UI Identity
**What:** Add a private timed-session UUID inside `KeepAwakeSessionModel` instead of widening `KeepAwakeMode` with notification-only identity.
**When to use:** When scheduling/canceling reminders for timed sessions, especially same-duration replacements.
**Example:**
```swift
private var activeTimedReminderSessionID: UUID?

private func nextReminderIdentifier(for sessionID: UUID) -> String {
    "keep-awake.session.\(sessionID.uuidString).pre-expiry"
}
```
Source: Phase 24 locked decision D-08 and existing repo preference for keeping presentation-only data out of public mode enums

### Pattern 3: Launch-Time Authorization in Composition Layer Only
**What:** Request notification authorization from `AppDelegate` during normal launch, but keep the reminder service itself injected into the session model.
**When to use:** Once per app launch, after shared objects are built and before user interactions depend on reminders.
**Example:**
```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    configureSharedStores()
    keepAwakeReminderScheduler.requestAuthorizationAtLaunch()
    // existing status/window setup continues here
}
```
Source: Apple docs for `requestAuthorization(...)`; repo startup composition in `AppDelegate.swift`

### Anti-Patterns to Avoid
- **Scheduling on menu click:** A timed session can still fail to start or get replaced; only confirmed model transitions are truthful.
- **Duration-based identifiers:** Two `15 分钟` sessions in a row can leak stale reminders if the identifier is reused by duration alone.
- **Canceling replacement reminders too early:** During a pending replacement, the old timed session is still the confirmed truth until the enable outcome returns.
- **Treating denied permission as a keep-awake failure:** `NOTF-01` and locked decisions require reminder failure to stay visible but non-blocking.
- **Adding notification UI settings now:** Fixed lead time, no toggle surface, no history, no wider notifications project in this phase.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pre-expiry delivery while app is backgrounded | Custom `Timer` or countdown observer for reminders | `UNUserNotificationCenter` + `UNNotificationRequest` | The system owns delivery when the app is backgrounded or inactive |
| Permission state tracking | Ad hoc booleans in views/controllers | `getNotificationSettings` + authorization status mapping | Apple already defines the source of truth for authorization |
| Stale reminder cancellation | Global "last duration" heuristic | Session-scoped identifier strings | Same-duration replacements must not leak reminders |
| Reminder persistence | UserDefaults or custom queue of pending reminders | Pending request storage inside Notification Center | The OS already persists and manages pending local notifications |

**Key insight:** The app should own only session truth and identifier selection. Apple should own reminder persistence, delivery timing, and pending-request lifecycle.

## Common Pitfalls

### Pitfall 1: Scheduling Before Keep-Awake Is Actually Confirmed
**What goes wrong:** A reminder gets scheduled for a session that never successfully started.
**Why it happens:** Scheduling runs in `startTimed(...)` before `handleEnableOutcome(...)` confirms success.
**How to avoid:** Schedule only inside the success/unchanged-true path that sets `confirmedMode = .timed(...)`.
**Warning signs:** Tests show a pending reminder even after a `.failure(current: false, ...)` enable outcome.

### Pitfall 2: Canceling the Old Reminder During a Pending Replacement
**What goes wrong:** The current session loses its valid reminder if the replacement start fails.
**Why it happens:** Cancellation happens at action start instead of confirmed state transition.
**How to avoid:** Keep the old reminder alive until the new timed or indefinite mode is confirmed; only then cancel the old identifier and schedule the new one if needed.
**Warning signs:** Replacement failure leaves the old timed session active but no longer able to notify.

### Pitfall 3: Not Restoring a Reminder After Stop Failure
**What goes wrong:** The user asks to stop, disable fails, timed keep-awake remains active, but its reminder is gone.
**Why it happens:** Stop begins by canceling pending side effects, but failure rollback restores countdown only.
**How to avoid:** Mirror the countdown pattern: cancel on stop begin, then restore the timed reminder if `handleStopOutcome(...)` rolls back to the previous timed session.
**Warning signs:** `pendingAction == nil`, `confirmedMode == .timed`, but no pending reminder exists after a disable failure.

### Pitfall 4: Using a Zero-or-Negative Trigger Interval
**What goes wrong:** The reminder fires immediately, fails validation, or becomes misleading.
**Why it happens:** Code computes `remaining - 120` without guarding for `remaining <= 120`.
**How to avoid:** Gate scheduling on `remaining > 120`. Apple's `UNTimeIntervalNotificationTrigger` requires a nonrepeating interval greater than zero.
**Warning signs:** A session with `2 分钟` or less remaining still calls the scheduler.

### Pitfall 5: Real Launch-Time Permission Prompts Breaking Tests
**What goes wrong:** UI or unit tests trigger system permission UI and become flaky.
**Why it happens:** `AppDelegate` directly talks to `UNUserNotificationCenter.current()` in tests.
**How to avoid:** Inject the authorization requester and use a fake or no-op service in tests; reserve one manual smoke for the real system prompt.
**Warning signs:** CI/local test runs hang or show macOS notification authorization alerts.

### Pitfall 6: Overreaching Into Delivered-Notification Cleanup
**What goes wrong:** The phase takes on extra complexity removing already delivered notifications or building history semantics.
**Why it happens:** Interpreting "stale reminders" as retroactively erasing previously truthful delivered alerts.
**How to avoid:** Phase 24 only needs pending-request truth so only the currently active timed session can still notify later.
**Warning signs:** Implementation starts calling `removeDeliveredNotifications(...)` without a clear phase requirement.

## Code Examples

Verified patterns from official sources:

### Launch-Time Authorization Request
```swift
import UserNotifications

final class UserNotificationKeepAwakeReminderScheduler: KeepAwakeReminderScheduling {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorizationAtLaunch() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // scheduling methods omitted
}
```
Source: https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/requestauthorization%28options%3Acompletionhandler%3A%29

### Schedule Exactly One Pre-Expiry Reminder
```swift
func schedulePreExpiryReminder(
    identifier: String,
    fireAfter: TimeInterval,
    title: String,
    body: String,
    completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireAfter, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    center.add(request) { error in
        Task { @MainActor in
            completion(error == nil ? .scheduled : .failed(error))
        }
    }
}
```
Source: https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app

### Cancel the Old Session's Pending Reminder
```swift
func cancelPendingReminder(identifier: String) {
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
}
```
Source: https://developer.apple.com/documentation/usernotifications/unusernotificationcenter

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `UILocalNotification` and older notification APIs | `UNUserNotificationCenter` + `UNNotificationRequest` | Deprecated older API; modern UserNotifications framework is current Apple standard | Use `UserNotifications`; do not design a new abstraction around deprecated notification APIs |
| Global, one-size-fits-all prompt at first launch by default | Apple now recommends asking in context | Current Apple guidance as of 2026 docs | This repo intentionally overrides the UX recommendation because launch-time asking is a locked user decision |
| Foreground presentation `.alert` option | `.list` and `.banner` are the modern foreground presentation options on newer macOS if a delegate is added later | macOS 11+ API evolution | Relevant for Phase 25 or later if foreground delivery behavior must be customized |

**Deprecated/outdated:**
- `UILocalNotification`: deprecated; use `UNNotificationRequest` and `UNUserNotificationCenter`.
- Custom reminder timers for OS-level notifications: outdated for this use case because they do not give background delivery truth.

## Open Questions

1. **Does Phase 24 need foreground presentation delegate wiring now, or can it wait for Phase 25?**
   - What we know: Scheduling and cancellation do not require a `UNUserNotificationCenterDelegate`, but foreground presentation customization does.
   - What's unclear: Whether the maintainer expects pre-expiry reminders to banner while Tools Cat is frontmost in common use.
   - Recommendation: Keep Phase 24 focused on authorization plus pending-request truth; design the scheduler so a delegate can be added in Phase 25 without refactoring the session model.

2. **Should denied/unavailable reminder feedback remain transient in Phase 24 or only be plumbed as internal state for Phase 25?**
   - What we know: Locked decisions require the existing keep-awake status surface if feedback is shown, but `NOTF-05` is formally Phase 25 scope.
   - What's unclear: Whether this phase should already set `message` text on schedule failure or merely expose a minimal internal outcome for later presentation work.
   - Recommendation: Add the minimal state needed for deterministic tests and future presentation reuse, but avoid broadening the visible UX contract beyond what the current phase requires.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `xcodebuild` | Build and test the app target and XCTest suites | ✓ | Xcode 26.2 | — |
| Swift toolchain | Compile app and tests | ✓ | Swift 6.2.3 | — |
| macOS SDK | `UserNotifications`, AppKit, XCTest APIs | ✓ | macOS SDK 26.2 | — |
| macOS runtime | Manual smoke of real notification behavior | ✓ | macOS 15.7.4 | Ship target remains macOS 14.0 |

**Missing dependencies with no fallback:**
- None.

**Missing dependencies with fallback:**
- None.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest via Xcode 26.2 |
| Config file | none — Xcode project target configuration only |
| Quick run command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| NOTF-01 | App launch requests notification authorization without blocking keep-awake startup | unit + manual smoke | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests'` | ❌ Wave 0 |
| NOTF-02 | Confirmed timed session with `> 120` seconds remaining schedules exactly one pre-expiry reminder; `<= 120` skips | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'` | ✅ |
| NOTF-04 | Replacing, stopping, or switching to `无限常亮` cancels stale pending reminders and failure rollback restores the truthful one | unit + controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ |

### Sampling Rate
- **Per task commit:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'`
- **Per wave merge:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `Tools CatTests/AppDelegateNotificationTests.swift` — verify launch-time authorization request goes through an injected service and stays non-blocking
- [ ] Fake reminder scheduler test double — record scheduled identifiers, delays, cancellations, and restore behavior for `KeepAwakeSessionModelTests`
- [ ] Manual smoke note — validate real launch-time macOS permission prompt and one real pre-expiry delivery on a clean authorization state

## Sources

### Primary (HIGH confidence)
- Local repo: `Tools Cat/AppDelegate.swift`, `Tools Cat/KeepAwakeSessionModel.swift`, `Tools Cat/KeepAwakePresentation.swift`, `Tools Cat/StatusBarController.swift`, `Tools CatTests/KeepAwakeSessionModelTests.swift`, `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift`
- Local macOS SDK headers:
  - `UserNotifications.framework/Headers/UNUserNotificationCenter.h`
  - `UserNotifications.framework/Headers/UNNotificationSettings.h`
  - `UserNotifications.framework/Headers/UNNotificationRequest.h`
  - `UserNotifications.framework/Headers/UNNotificationTrigger.h`
- Apple Developer Documentation:
  - https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/requestauthorization%28options%3Acompletionhandler%3A%29
  - https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications
  - https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app
  - https://developer.apple.com/documentation/usernotifications/unnotificationsettings/authorizationstatus
  - https://developer.apple.com/documentation/usernotifications/untimeintervalnotificationtrigger/init%28timeinterval%3Arepeats%3A%29

### Secondary (MEDIUM confidence)
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/managing-notifications
- Apple archived entitlement reference for push notifications only: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingLocalAndPushNotifications.html

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Verified against the local macOS 26.2 SDK headers and current Apple documentation.
- Architecture: HIGH - Strong repo precedent exists in `KeepAwakeSessionModel` and `WOLSessionModel` for injected, cancellable side-effect seams.
- Pitfalls: MEDIUM - The failure/rollback cases are clear from repo behavior, but real-world notification UX still needs manual validation on macOS.

**Research date:** 2026-05-09
**Valid until:** 2026-06-08
