# Stack Research

**Domain:** macOS local notifications for timed keep-awake reminders in `Tools Cat`
**Researched:** 2026-05-09
**Confidence:** HIGH

## Recommended Stack

This milestone should stay fully Apple-native. The repo already uses AppKit, SwiftUI, and a retained `KeepAwakeSessionModel`; reminder delivery should extend that baseline rather than introducing any cross-platform notification abstraction.

### Core Technologies

| Technology | Purpose | Why Recommended |
|------------|---------|-----------------|
| `UserNotifications` (`UNUserNotificationCenter`) | Request local-notification permission and schedule/cancel reminder requests | Apple’s native notification API is the correct seam for macOS local reminders and matches the project’s native-only constraints. |
| Existing `KeepAwakeSessionModel` timed-session state | Supplies the authoritative `endDate`, replacement, stop, and expiry transitions | The reminder feature depends on the same truth source that already owns countdown and shutdown behavior. |
| Existing timer/countdown scheduler seam | Keeps countdown progress and expiry transitions testable without waiting on real time | The repo already models timed keep-awake with fake schedulers in tests, which is the right place to verify reminder timing rules too. |

### Supporting Libraries

| Library | Purpose | When to Use |
|---------|---------|-------------|
| None | No external library is needed for this milestone | Avoid third-party wrappers; the built-in Apple framework covers permission, scheduling, and cancellation. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| XCTest + existing fake seams | Verify reminder scheduling, cancellation, and expiry behavior deterministically | Prefer fake notification clients and fake countdown time over waiting for real Notification Center delivery. |
| Existing menu/controller tests | Verify reminder-unavailable state reaches the menu/status presentation truthfully | Reuse the repo’s current menu-truth verification style instead of inventing a separate UI harness. |

## Recommended Additions

| Addition | Purpose | Notes |
|----------|---------|-------|
| `KeepAwakeNotificationScheduling` protocol seam | Abstract permission checks and request scheduling/cancellation | Keeps `KeepAwakeSessionModel` testable and avoids hardcoding `UNUserNotificationCenter` into model tests. |
| Session-scoped notification identifiers | Tie scheduled notifications to the active timed keep-awake session only | Required so replacement and manual stop can cancel exactly the stale reminder requests. |
| Reminder-unavailable presentation path | Surface permission-denied or scheduling-failed states without blocking keep-awake | Matches the project’s “state must stay truthful” rule. |

## What NOT to Add

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Third-party notification wrappers | Unnecessary abstraction for one native macOS app and one reminder flow | `UserNotifications` directly |
| General notification preferences storage in this milestone | Adds settings and persistence scope without validating the core reminder value first | Fixed `2 分钟` + expiry behavior |
| Real-time waiting tests for system notification delivery | Slow and flaky | Fake scheduling seams plus focused model/controller assertions |

## Sources

- Apple Developer Documentation — `UserNotifications`: local notification authorization and scheduling APIs
- Local repo: `Tools Cat/KeepAwakeSessionModel.swift`, `Tools Cat/AppDelegate.swift`, `Tools CatTests/KeepAwakeSessionModelTests.swift`

---
*Stack research for: v1.9 Timed Keep-Awake Notifications*
