# Project Research Summary

**Project:** Tools Cat
**Milestone:** v1.9 Timed Keep-Awake Notifications
**Researched:** 2026-05-09
**Confidence:** HIGH

## Executive Summary

`Tools Cat` does not need a new notification platform for this milestone. It already has the hard part: one shared timed keep-awake session model with a real `endDate`, replacement behavior, and expiry truth. The right move is to extend that existing lifecycle with Apple-native local notifications, not to build a broad notification settings system.

The key risk is reminder truth drift. If reminders are scheduled from menu actions instead of the active timed session, or if permission failures stay silent, the app will say one thing and do another. The milestone should therefore keep all reminder scheduling and cancellation aligned with `KeepAwakeSessionModel`, and surface permission-unavailable states while leaving keep-awake itself usable.

## Key Findings

### Stack Additions

- Add a `UNUserNotificationCenter`-backed scheduling seam for local reminders
- Keep session lifecycle truth in `KeepAwakeSessionModel`
- Use fake reminder schedulers in tests instead of real notification waiting

### Feature Table Stakes

- Permission request when reminders are first needed
- `2 分钟` pre-expiry reminder for eligible timed sessions
- End-of-session reminder when timed keep-awake actually ends
- Stale reminder cancellation on replacement, stop, and mode switch
- Visible reminder-unavailable truth when permission is denied

### Watch Out For

- Do not schedule from UI taps instead of active session truth
- Do not emit pre-expiry reminders for sessions with `<= 2 分钟` total remaining time
- Do not let permission denial fail silently
- Do not leave expiry reminders armed after manual stop or session replacement

## Repo-Specific Implications

### Good News

- `KeepAwakeSessionModel` already owns timed-session `endDate` and expiry behavior
- `AppDelegate` already constructs one shared keep-awake session for the whole app
- The repo already has fake scheduler-based tests around timed keep-awake lifecycle behavior

### Gaps To Close

- No notification authorization or scheduling seam exists yet
- No user-visible reminder-unavailable state exists today
- The current tests do not yet cover pre-expiry reminder timing or stale reminder cancellation

## Recommended Roadmap Shape

The milestone should break into:

1. reminder authorization, pre-expiry scheduling, and stale-reminder cancellation
2. expiry reminder delivery and truthful permission-unavailable presentation

That ordering keeps session-truth infrastructure first and presentation/edge-case closure second.

## Sources

- Apple Developer Documentation — local notification authorization and scheduling
- Local repo: `KeepAwakeSessionModel.swift`, `StatusBarController.swift`, `AppDelegate.swift`, `KeepAwakeSessionModelTests.swift`

---
*Research completed: 2026-05-09*
*Ready for roadmap: yes*
