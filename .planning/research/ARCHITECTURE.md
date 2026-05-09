# Architecture Research

**Domain:** Timed keep-awake reminder architecture for `Tools Cat`
**Researched:** 2026-05-09
**Confidence:** HIGH

## Current Architecture

Today’s timed keep-awake flow is already centralized:

1. `KeepAwakeSessionModel` owns `confirmedMode`, `pendingAction`, `countdownNow`, and the timed session `endDate`
2. A countdown scheduler ticks every second and stops the session when the active timed session reaches expiry
3. `StatusBarController` renders the keep-awake presentation from that shared model
4. `AppDelegate` builds the shared session once and hands it to the status/menu surfaces

That structure is the correct foundation for reminder notifications.

## Target Architecture

The target reminder path should be:

1. Timed session start/replace/stop still flows through `KeepAwakeSessionModel`
2. `KeepAwakeSessionModel` calls a reminder-scheduling seam whenever the active timed-session truth changes
3. The production scheduler implementation uses `UNUserNotificationCenter` to request permission, schedule reminder requests, and cancel stale ones
4. The model exposes a reminder-unavailable message/state when permission or scheduling fails
5. Existing menu/status presentation renders that state without changing the keep-awake lifecycle truth

## Recommended Component Layout

| Component | Responsibility | Repo Fit |
|-----------|----------------|----------|
| `KeepAwakeSessionModel` | Own active timed-session truth and tell reminder scheduling when that truth changes | Best place to keep reminder behavior synchronized with countdown/expiry state |
| `KeepAwakeNotificationScheduling` seam | Request authorization, schedule pre-expiry and expiry notifications, cancel stale requests | Keeps production notification APIs out of model tests |
| `UNUserNotificationCenter` implementation | Real macOS permission and local-notification operations | AppKit-native production implementation |
| `KeepAwakePresentation` / menu status rendering | Show reminder-unavailable truth if notifications cannot be delivered | Reuses existing presentation architecture |

## Architectural Choices

### Prefer: schedule from session-state transitions, not from ad hoc UI callbacks

The app already trusts the session model instead of menu clicks for countdown truth. Reminder scheduling should follow that same rule so replacement, stop, and expiry remain correct no matter which UI surface triggered the state change.

### Prefer: explicit identifiers for the active timed session

Pre-expiry and expiry requests should be cancelable as a pair. Identifier derivation should make it impossible for an older session’s reminders to survive after a replacement.

### Prefer: non-blocking failure handling

Notification permission denial should not prevent keep-awake from starting. Instead, the reminder feature should report “unavailable” while keep-awake itself remains truthful and functional.

## Integration Points With Current Repo

| File | Change Pressure | Why |
|------|-----------------|-----|
| `Tools Cat/KeepAwakeSessionModel.swift` | HIGH | Timed-session lifecycle and reminder synchronization belong here |
| `Tools Cat/AppDelegate.swift` | MEDIUM | The shared session likely needs the production notification scheduler injected at creation time |
| `Tools Cat/KeepAwakePresentation.swift` | MEDIUM | Reminder-unavailable state may need visible presentation text |
| `Tools Cat/StatusBarController.swift` | LOW to MEDIUM | Renders the shared keep-awake presentation and should inherit any new truthful message state |
| `Tools CatTests/KeepAwakeSessionModelTests.swift` | HIGH | Best place to prove scheduling, cancellation, and expiry behavior without real system notifications |

## Sources

- Local repo: `KeepAwakeSessionModel.swift`, `StatusBarController.swift`, `AppDelegate.swift`, `KeepAwakeSessionModelTests.swift`
- Apple Developer Documentation — local notification scheduling and authorization flow

---
*Architecture research for: v1.9 Timed Keep-Awake Notifications*
