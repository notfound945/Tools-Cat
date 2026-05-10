# Phase 25: Expiry Reminder Truth - Research

**Researched:** 2026-05-10
**Domain:** macOS local-notification truth for timed keep-awake expiry
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### End-of-session reminder boundary
- **D-01:** The end reminder must fire only after the underlying keep-awake session has actually turned off and `confirmedMode` has returned to `.off`; reaching the planned `endDate` alone is not sufficient.
- **D-02:** If timed expiry reaches the stop path but the underlying disable attempt fails or keep-awake remains on, the app must not send an end reminder that falsely claims the session ended.
- **D-03:** End-reminder ownership stays tied to the active confirmed timed session lifecycle, so an older replaced session or a manually stopped session can never later produce an end reminder.

### Reminder-unavailable visibility
- **D-04:** Reminder-unavailable feedback must remain non-blocking: timed keep-awake still starts, counts down, replaces, and ends normally even when local notifications are denied or otherwise unavailable.
- **D-05:** Continue reusing the existing keep-awake status feedback surface instead of adding a notification-specific banner, window, settings page, or separate management UI.
- **D-06:** Reminder-unavailable truth and countdown truth must both remain visible during an active timed session; do not collapse them into one long single-line string that hides scanability.
- **D-07:** The unavailable state should therefore display as two lines within the existing keep-awake status area: one line for the timed countdown truth and one line for reminder-unavailable truth.

### Which sessions surface unavailable reminder state
- **D-08:** All timed keep-awake sessions should surface reminder-unavailable truth when reminder delivery is unavailable, not only sessions longer than `2 分钟`.
- **D-09:** Sessions at `2 分钟` or less still need unavailable feedback because they skip the pre-expiry reminder but still depend on the end reminder delivered by this phase.

### Scope and milestone guardrails
- **D-10:** Do not expand this phase into notification preferences, custom reminder lead times, notification troubleshooting/history, WOL notifications, or any broader notification center feature set.
- **D-11:** Preserve the shipped timed keep-awake menu structure and truth boundary from earlier phases; this phase only extends reminder truth around the existing timed session lifecycle.

### the agent's Discretion
- Choose the exact production path for the end reminder, as long as it fires only after confirmed transition to `.off` and remains session-scoped.
- Choose the exact Chinese copy for the end reminder and the reminder-unavailable line, as long as both stay concise and truthful.
- Choose the concrete two-line status implementation inside the existing keep-awake status surface, as long as countdown truth and unavailable truth are both visible without creating a new notification UI surface.
- Choose the exact test seam and regression coverage strategy, as long as it proves truthful end-reminder delivery, stale-reminder suppression, and two-line unavailable-state presentation.

### Deferred Ideas (OUT OF SCOPE)
- Notification preferences UI, configurable reminder lead time, reminder history, or troubleshooting surfaces remain out of scope for this phase.
- Any expansion of notifications beyond timed keep-awake, including WOL notifications or app-wide notification features, remains deferred.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| NOTF-03 | User receives one local notification when a timed keep-awake session actually ends | Deliver the expiry notification only from the confirmed expiry stop-success path, using the active timed session UUID and an immediate `UNNotificationRequest` |
| NOTF-05 | If local notification permission is unavailable, timed keep-awake still works and the app surfaces a truthful reminder-unavailable state instead of implying reminders will arrive | Add a proactive reminder-availability check for every confirmed timed session and render countdown truth plus unavailable truth as two lines in the existing keep-awake status item |
</phase_requirements>

## Summary

Phase 25 should stay on the same architectural rail Phase 24 established: keep `KeepAwakeSessionModel` as the single truth owner for timed-session lifecycle, keep `KeepAwakeReminderScheduling` as the only notification side-effect seam, and keep `StatusBarController` as a renderer. The phase does not need a second notification service, a new UI surface, or a broader settings story. It needs one truthful new delivery point and one better status-presentation shape.

The central implementation fact is that the end reminder cannot be truthfully pre-scheduled at timed-session start. A reminder scheduled for the planned `endDate` would be wrong for manual stops, replacements, or failed disables. Apple’s current `UNNotificationRequest` API supports immediate delivery with a `nil` trigger, so the right production path is: when expiry-driven stop succeeds and `confirmedMode` actually becomes `.off`, enqueue one local notification at that moment. That preserves D-01 through D-03 without hand-rolled timers or speculative cancellation logic.

The second planning fact is that the current single `message` override is no longer enough. NOTF-05 and D-06 through D-09 require countdown truth and reminder-unavailable truth to remain visible together, including for `<= 2 分钟` sessions that never call the pre-expiry scheduling path. The planner should therefore introduce dedicated reminder-availability state in the model, expose structured keep-awake status lines from presentation, and render the existing disabled menu row as an attributed two-line item using the same native AppKit pattern the repo already uses for multi-line WOL device rows.

**Primary recommendation:** Extend the existing reminder scheduler with explicit availability-check and immediate-delivery support, send the expiry reminder only from the confirmed expiry stop-success path, and replace the single keep-awake status string with structured two-line presentation for timed countdown plus reminder-unavailable truth.

## Project Constraints (from AGENTS.md)

- Stay native to the existing macOS AppKit and SwiftUI stack.
- Preserve truthful UI and side effects: visible state must follow confirmed underlying keep-awake outcomes, not optimistic intent.
- Keep scope small and polished; do not turn this phase into a broader notification center or preferences project.
- Prefer narrow seams around side effects instead of deepening controller or view coupling.
- Preserve the macOS 14.0 deployment target.
- Keep identifiers in English and user-facing strings in Chinese, following current repo style.
- Prefer focused XCTest model and controller coverage over new broad UI automation.
- Keep work aligned with the existing GSD planning workflow.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `UserNotifications` | macOS SDK 26.2, available on macOS 10.14+ | Local notification authorization, availability checks, immediate delivery, and pending-reminder cancellation | Apple-native notification system; already used in Phase 24 |
| `AppKit` | macOS SDK 26.2 | Disabled menu-row rendering and status-item composition | Existing menu-bar surface owner; already supports multi-line `NSMenuItem` rendering |
| `Foundation` | macOS SDK 26.2 | UUID ownership, dates, trigger math, and async callback plumbing | Existing model baseline |
| `XCTest` | Xcode 26.2 | Deterministic regression coverage for session truth and status-row rendering | Existing repo test framework and seam style |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `Combine` | macOS SDK 26.2 | Existing `ObservableObject` propagation from session model into controller rendering | Re-render keep-awake status row when reminder availability or expiry-delivery state changes |
| `UNUserNotificationCenterDelegate` | UserNotifications API in macOS SDK 26.2 | Foreground notification presentation | Use if Phase 25 must present the expiry notification while the app is active/frontmost |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Immediate expiry delivery after confirmed `.off` | Pre-schedule an end reminder at timed-session start | Pre-scheduling is false for manual stop, replacement, and disable failure paths |
| Extending `KeepAwakeReminderScheduling` | Calling `UNUserNotificationCenter` directly from `KeepAwakeSessionModel` and `AppDelegate` | Direct calls weaken testability and create a second side-effect path |
| `NSMenuItem.attributedTitle` for two-line status | `NSMenuItem.subtitle` | `subtitle` is only available from macOS 14.4, and Apple notes subtitle does not show on macOS 14 when the item has an attributed title; `attributedTitle` matches the repo’s existing multi-line pattern and macOS 14.0 target |

**Installation:**
```bash
# None. This phase uses Apple system frameworks already present in Xcode/macOS SDK.
```

**Version verification:** Verified locally on 2026-05-10 with `xcodebuild -version` (`Xcode 26.2`), `swift --version` (`Swift 6.2.3`), `xcrun --show-sdk-version` (`26.2`), and current SDK headers under `UserNotifications.framework` and `AppKit.framework`. Apple system frameworks do not publish npm-style registry dates.

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── AppDelegate.swift                    # shared notification center delegate wiring, if foreground presentation is included
├── KeepAwakeReminderScheduling.swift    # authorization check + scheduled + immediate reminder delivery seam
├── KeepAwakeSessionModel.swift          # confirmed timed-session UUID ownership and expiry stop truth
├── KeepAwakePresentation.swift          # structured keep-awake status lines instead of one overloaded string
└── StatusBarController.swift            # render-only two-line keep-awake status item

Tools CatTests/
├── AppDelegateNotificationTests.swift   # launch and delegate wiring seam
├── KeepAwakeSessionModelTests.swift     # truthful expiry reminder and unavailable-state ownership
└── StatusBarControllerKeepAwakeMenuTests.swift  # two-line menu-row rendering and no-new-surface regressions
```

### Pattern 1: Expiry Notification Fires From Confirmed Stop Outcome
**What:** Treat the expiry reminder as a post-condition of a successful expiry-driven stop, not as a timed request scheduled at session start.
**When to use:** Only after `handleStopOutcome(_:)` confirms `.success(false)` or `.unchanged(false)` for a stop that originated from timed expiry of the active timed session.
**Example:**
```swift
private enum KeepAwakeStopReason: Equatable {
    case manual
    case timedExpiry(sessionID: UUID)
}

private func beginStop(
    reason: KeepAwakeStopReason,
    completion: (() -> Void)? = nil
) {
    pendingStopReason = reason
    pendingAction = .stopping
    message = nil
    cancelCountdown()
    powerController.setKeepAwakeEnabled(false) { [weak self] outcome in
        guard let self else { return }
        performKeepAwakeSessionUpdate {
            self.handleStopOutcome(outcome)
            completion?()
        }
    }
}
```
Source: Apple `UNNotificationRequest` immediate-delivery support and existing repo truth boundary in `KeepAwakeSessionModel.swift`

### Pattern 2: Timed Session UUID Must Exist Even When No Pre-Expiry Reminder Exists
**What:** Separate active timed-session identity from pre-expiry pending reminder identity.
**When to use:** Always for confirmed timed sessions, especially `<= 2 分钟` sessions that still need end-reminder truth and unavailable-state visibility.
**Example:**
```swift
private var activeTimedSessionID: UUID?
private var activePreExpiryReminderIdentifier: String?

private func preExpiryReminderIdentifier(for sessionID: UUID) -> String {
    "keep-awake.session.\(sessionID.uuidString).pre-expiry"
}

private func expiryReminderIdentifier(for sessionID: UUID) -> String {
    "keep-awake.session.\(sessionID.uuidString).expiry"
}
```
Source: Phase 25 decisions D-03, D-08, D-09 plus current Phase 24 session-scoped identifier pattern

### Pattern 3: Dedicated Reminder Availability State, Not Reused Error Message State
**What:** Model reminder availability separately from generic keep-awake failure `message`.
**When to use:** Any time a confirmed timed session is active and the app needs to show countdown truth and reminder-unavailable truth together.
**Example:**
```swift
enum KeepAwakeReminderVisibility: Equatable {
    case available
    case unavailable(String)
}

struct KeepAwakeStatusLines: Equatable {
    let primary: String
    let secondary: String?
}
```
Source: local repo presentation constraints in `KeepAwakePresentation.swift` plus Phase 25 D-06 and D-07

### Pattern 4: Existing Status Row Renders Two Lines Via `attributedTitle`
**What:** Continue using one disabled keep-awake status item, but render it as a styled two-line attributed string when timed countdown and reminder-unavailable truth must both be visible.
**When to use:** Confirmed timed sessions with reminder-unavailable state.
**Example:**
```swift
private func makeKeepAwakeStatusTitle(
    primary: String,
    secondary: String?
) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 1

    let title = NSMutableAttributedString(
        string: primary,
        attributes: [
            .font: NSFont.menuFont(ofSize: 0),
            .paragraphStyle: paragraphStyle,
        ]
    )

    if let secondary {
        title.append(
            NSAttributedString(
                string: "\n\(secondary)",
                attributes: [
                    .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .paragraphStyle: paragraphStyle,
                ]
            )
        )
    }

    return title
}
```
Source: existing repo pattern in `StatusBarController.makeWakeMenuTitle(for:)` and AppKit `NSMenuItem.attributedTitle`

### Pattern 5: Foreground Presentation Requires Notification Center Delegate
**What:** If the app must visibly present its own expiry notification while active, wire `UNUserNotificationCenterDelegate` in `AppDelegate` before launch ends and return foreground presentation options for keep-awake reminder identifiers.
**When to use:** If planner interprets NOTF-03 as visible delivery even while the app is frontmost or a utility window is active.
**Example:**
```swift
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        guard notification.request.identifier.hasPrefix("keep-awake.session.") else {
            return []
        }
        return [.list, .banner, .sound]
    }
}
```
Source: Apple `UNUserNotificationCenterDelegate` docs and current absence of delegate wiring in `AppDelegate.swift`

### Anti-Patterns to Avoid
- **Pre-scheduling the expiry reminder at timed-session start:** This violates D-01 through D-03 as soon as the user manually stops, replaces, or the disable call fails.
- **Using only `activeTimedReminderSessionID` from Phase 24:** `<= 2 分钟` sessions have no pre-expiry reminder, so Phase 25 needs timed-session identity even when no pending reminder exists.
- **Reusing `message` for reminder-unavailable state:** A single message string forces countdown truth and unavailable truth to compete, which directly violates D-06.
- **Adding a second menu row or new notification section:** D-05 explicitly keeps this work inside the existing keep-awake status surface.
- **Relying on `NSMenuItem.subtitle` as the primary two-line plan:** The repo ships to macOS 14.0, but `subtitle` is macOS 14.4+ and has a documented interaction with attributed titles on macOS 14.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Truthful expiry delivery | A timer or pre-scheduled “session ended” reminder from start time | Immediate `UNNotificationRequest` after confirmed expiry-driven `.off` | Truth depends on real stop outcome, not planned end time |
| Authorization truth for all timed sessions | Local booleans inferred from previous schedule attempts | `getNotificationSettings` through the scheduler seam | `<= 2 分钟` sessions still need unavailable-state truth before they end |
| Foreground notification presentation | Ad hoc app-active polling or custom in-app banner | `UNUserNotificationCenterDelegate.willPresent` | Apple already defines the foreground presentation hook |
| Two-line keep-awake status UI | A custom `NSView` menu item or new notification section | Existing disabled `NSMenuItem` with `attributedTitle` | The repo already has a native multi-line pattern; custom view rows add complexity for no benefit |
| Session ownership | Duration-based or endDate-only heuristics | Explicit timed-session UUID plus explicit stop reason | Same-duration replacements and manual stops otherwise leak false expiry notifications |

**Key insight:** The app should own only three truths in this phase: which timed session is active, why a stop is happening, and whether reminders are currently deliverable. Apple should own actual notification persistence and presentation.

## Common Pitfalls

### Pitfall 1: Sending the End Reminder From `handleCountdownTick`
**What goes wrong:** The app notifies at the planned `endDate` even if the disable call later fails.
**Why it happens:** Countdown logic knows the plan, not the confirmed stop outcome.
**How to avoid:** Only enqueue the expiry reminder from the stop-success path after `confirmedMode` becomes `.off`.
**Warning signs:** Tests pass when `endDate` is reached but still notify after `.failure(current: true, ...)`.

### Pitfall 2: No Session UUID For `<= 2 分钟` Timed Sessions
**What goes wrong:** Short sessions cannot prove ownership for expiry delivery or unavailable-state truth.
**Why it happens:** Phase 24 only needed reminder ownership when a pre-expiry request existed.
**How to avoid:** Make active timed-session UUID first-class and independent from pending pre-expiry identifiers.
**Warning signs:** End-reminder logic depends on a pre-expiry identifier that is `nil` for two-minute sessions.

### Pitfall 3: Manual Stop and Expiry Stop Share the Same Success Path Without Reason Tracking
**What goes wrong:** A user-triggered stop can wrongly produce a “session ended” reminder.
**Why it happens:** `handleStopOutcome(_:)` currently does not know why stop started.
**How to avoid:** Carry an explicit stop reason across the async power-controller boundary.
**Warning signs:** `stop()` success on a timed session produces the same reminder behavior as natural expiry.

### Pitfall 4: Unavailable-State Truth Only Exists For Long Sessions
**What goes wrong:** Sessions that skip pre-expiry scheduling hide unavailable reminder delivery until after they have already ended.
**Why it happens:** Availability is inferred only from `schedulePreExpiryReminder(...)` completion.
**How to avoid:** Add an explicit availability check for every confirmed timed session, regardless of duration.
**Warning signs:** A `120` second session shows countdown only and never surfaces denied notifications.

### Pitfall 5: Foreground Notifications Never Appear
**What goes wrong:** The end reminder is enqueued, but nothing visible appears while the app is active.
**Why it happens:** Apple suppresses foreground presentation unless the notification center delegate handles `willPresent`.
**How to avoid:** If foreground visibility matters for this requirement, set the shared notification center delegate before launch completion and return presentation options for keep-awake notifications.
**Warning signs:** Unit tests prove scheduler calls happened, but manual frontmost-app runs show no banner or list entry at delivery time.

### Pitfall 6: Choosing `NSMenuItem.subtitle` As The Only Two-Line Strategy
**What goes wrong:** Runtime availability checks and macOS 14 title/subtitle quirks complicate a simple phase.
**Why it happens:** `subtitle` looks convenient, but the repo ships to 14.0 and Apple documents a macOS 14 interaction with attributed titles.
**How to avoid:** Use the repo’s existing attributed multi-line pattern for the keep-awake status item.
**Warning signs:** The implementation starts branching on `#available(macOS 14.4, *)` for a row that already has a stable attributed-string precedent.

### Pitfall 7: Clearing Reminder-Unavailable State Too Aggressively
**What goes wrong:** The status briefly shows “提醒不可用” and then reverts to countdown-only while the timed session is still active.
**Why it happens:** The state is stored in transient callback-local data or reset on each countdown tick.
**How to avoid:** Keep reminder availability as durable timed-session state until authorization or scheduling truth changes.
**Warning signs:** The message disappears after the next timer tick even though notification settings did not change.

## Code Examples

Verified patterns from official sources and current repo seams:

### Immediate Expiry Reminder After Confirmed Off
```swift
private func maybeDeliverExpiryReminder(for stopReason: KeepAwakeStopReason) {
    guard case let .timedExpiry(sessionID) = stopReason else { return }
    guard activeTimedSessionID == sessionID else { return }

    reminderScheduler.deliverEndOfSessionReminder(
        identifier: expiryReminderIdentifier(for: sessionID),
        title: "常亮已结束",
        body: "已按计划关闭常亮"
    ) { [weak self] result in
        guard let self else { return }
        self.applyReminderResult(result)
    }
}
```
Source: `UNNotificationRequest(identifier:content:trigger:)` with a `nil` trigger for immediate delivery, plus the current confirmed stop boundary in `KeepAwakeSessionModel.swift`

### Proactive Reminder Availability Check For Every Timed Session
```swift
private func refreshReminderAvailabilityForTimedSession() {
    reminderScheduler.checkReminderAvailability { [weak self] result in
        guard let self else { return }
        switch result {
        case .available:
            self.reminderVisibility = .available
        case .unavailable(let message):
            self.reminderVisibility = .unavailable(message)
        }
    }
}
```
Source: Apple `getNotificationSettings(...)` and Phase 25 D-08 through D-09

### Foreground Notification Presentation
```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
) async -> UNNotificationPresentationOptions {
    guard notification.request.identifier.hasPrefix("keep-awake.session.") else {
        return []
    }
    return [.list, .banner, .sound]
}
```
Source: Apple `UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:)`

### Two-Line Keep-Awake Status Rendering
```swift
let lines = KeepAwakeStatusLines(
    primary: "还剩 14 分钟",
    secondary: "提醒不可用：通知权限未开启"
)

keepAwakeStatusItem.attributedTitle = makeKeepAwakeStatusTitle(
    primary: lines.primary,
    secondary: lines.secondary
)
keepAwakeStatusItem.title = lines.primary
keepAwakeStatusItem.isHidden = false
keepAwakeStatusItem.isEnabled = false
```
Source: existing `StatusBarController.makeWakeMenuTitle(for:)` pattern and AppKit `NSMenuItem.attributedTitle`

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Plan-time `endDate` used as enough truth for notification timing | Confirmed stop outcome used as the only truth boundary for expiry notification | Current Apple UserNotifications APIs plus this phase’s locked decisions | Eliminates false “session ended” reminders on failed disable, manual stop, and replacement |
| One overloaded keep-awake status string | Structured status lines rendered into one existing menu row | Needed by Phase 25 D-06 and D-07 | Preserves countdown truth while also surfacing reminder-unavailable truth |
| `UNNotificationPresentationOptionAlert` | `.list` and `.banner` presentation options | Apple API evolution since macOS 11 | If foreground delivery is included, use modern options rather than deprecated alert-only semantics |
| `NSMenuItem.subtitle` as a tempting modern API | `attributedTitle` for macOS 14.0-safe multi-line rows | `subtitle` added in macOS 14.4 and documented with macOS 14 caveat | Avoids availability branching and preserves current deployment-target compatibility |

**Deprecated/outdated:**
- Scheduling the expiry reminder at session start: outdated for this repo because it cannot stay truthful through stop failure and replacement edges.
- Treating every keep-awake status as one string: outdated for this phase because it cannot satisfy the two-line visibility requirement.
- Using foreground presentation default behavior: outdated if visible delivery is required while the app is active, because Apple documents that unhandled foreground notifications default to no presentation.

## Open Questions

1. **Should Phase 25 include foreground presentation delegate wiring, or is background/Notification Center delivery enough for v1.9?**
   - What we know: Apple documents that if `willPresent` is not implemented, a foreground notification behaves as `UNNotificationPresentationOptionNone`.
   - What's unclear: Whether the maintainer wants end reminders visibly banner while a `Tools Cat` utility window is active.
   - Recommendation: Plan the delegate wiring now unless the user explicitly accepts “visible only when the app is not foreground” as the shipped boundary.

2. **How distinct should reminder-unavailable copy be for denied permission versus generic scheduling failure?**
   - What we know: Both are within NOTF-05’s “denied or otherwise unavailable” surface, and copy is discretionary.
   - What's unclear: Whether the product wants one generic secondary line or two specific strings.
   - Recommendation: Keep the state typed and the presentation copy short; decide exact Chinese strings during implementation, not in the model architecture.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `xcodebuild` | Build and run focused XCTest slices | ✓ | Xcode 26.2 | — |
| Swift toolchain | Compile app and tests | ✓ | Swift 6.2.3 | — |
| macOS SDK | `UserNotifications`, AppKit, XCTest APIs | ✓ | 26.2 | — |
| Host macOS runtime | Manual Notification Center smoke and status-menu behavior | ✓ | macOS 15.7.4 | Real-user desktop run only |
| Notification Center permission UI | Human verification of denied/allowed delivery states | ✓ | Host OS service | No automated fallback |

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
| Quick run command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| NOTF-03 | Expiry-driven stop sends one end reminder only after confirmed `.off`, never for manual stop or replaced session | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'` | ✅ |
| NOTF-03 | Foreground end reminder is visibly presented when the app is active, if delegate wiring is included | manual-only | none — Notification Center UI boundary | ✅ |
| NOTF-05 | Timed keep-awake still starts, counts down, and ends while reminder-unavailable truth stays visible for all timed sessions | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'` | ✅ |
| NOTF-05 | Countdown truth plus unavailable truth render as two lines in the existing keep-awake status row with no new menu surface | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ |
| NOTF-03 | Notification launch/delegate seam stays injected and testable if foreground presentation is added | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests'` | ✅ |

### Sampling Rate
- **Per task commit:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'`
- **Per wave merge:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'`
- **Phase gate:** Full suite green plus one manual Notification Center smoke with notifications allowed and one with notifications denied before `/gsd:verify-work`

### Wave 0 Gaps
- None — existing XCTest infrastructure, fakes, and focused slices already exist. Phase 25 should add new cases to `AppDelegateNotificationTests.swift`, `KeepAwakeSessionModelTests.swift`, and `StatusBarControllerKeepAwakeMenuTests.swift` rather than introducing new test targets or helpers.

## Sources

### Primary (HIGH confidence)
- Apple Developer: `UNUserNotificationCenter` — authorization, settings, delegate, and pending-request APIs checked: https://developer.apple.com/documentation/usernotifications/unusernotificationcenter
- Apple Developer: `UNNotificationRequest` — verified immediate delivery via `trigger: nil`: https://developer.apple.com/documentation/usernotifications/unnotificationrequest
- Apple Developer: `UNUserNotificationCenterDelegate` — verified foreground delivery hook and launch-time delegate timing: https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate
- Apple Developer: `userNotificationCenter(_:willPresent:withCompletionHandler:)` — verified no-presentation default when unimplemented: https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/usernotificationcenter%28_%3Awillpresent%3Awithcompletionhandler%3A%29
- Apple Developer: `NSMenuItem.subtitle` — verified macOS 14 caveat with attributed titles: https://developer.apple.com/documentation/appkit/nsmenuitem/subtitle
- Local SDK headers inspected on 2026-05-10:
  - `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/UserNotifications.framework/Versions/A/Headers/UNUserNotificationCenter.h`
  - `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/UserNotifications.framework/Versions/A/Headers/UNNotificationSettings.h`
  - `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/UserNotifications.framework/Versions/A/Headers/UNNotificationRequest.h`
  - `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/UserNotifications.framework/Versions/A/Headers/UNNotificationTrigger.h`
  - `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/AppKit.framework/Headers/NSMenuItem.h`
- Repo implementation seams checked:
  - `Tools Cat/KeepAwakeReminderScheduling.swift`
  - `Tools Cat/KeepAwakeSessionModel.swift`
  - `Tools Cat/KeepAwakePresentation.swift`
  - `Tools Cat/StatusBarController.swift`
  - `Tools Cat/AppDelegate.swift`
  - `Tools CatTests/AppDelegateNotificationTests.swift`
  - `Tools CatTests/KeepAwakeSessionModelTests.swift`
  - `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift`
- Prior phase references checked:
  - `.planning/phases/24-timed-reminder-scheduling/24-CONTEXT.md`
  - `.planning/phases/24-timed-reminder-scheduling/24-01-PLAN.md`
  - `.planning/phases/24-timed-reminder-scheduling/24-RESEARCH.md`

### Secondary (MEDIUM confidence)
- Apple Developer: Handling notifications and notification-related actions — lifecycle overview for delegate callbacks: https://developer.apple.com/documentation/UserNotifications/handling-notifications-and-notification-related-actions

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - current Apple APIs and local SDK headers were verified directly, and the repo already uses these frameworks.
- Architecture: HIGH - the recommended path extends current repo seams and is constrained by explicit phase decisions.
- Pitfalls: HIGH - each pitfall comes from verified Apple behavior or observed current repo state.

**Research date:** 2026-05-10
**Valid until:** 2026-06-09
