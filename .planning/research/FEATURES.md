# Feature Research

**Domain:** Timed keep-awake reminder notifications for `Tools Cat`
**Researched:** 2026-05-09
**Confidence:** HIGH

## Feature Landscape

This milestone is a narrow extension of an existing timed session flow. The “feature” is not a broad notification center; it is truthful reminder delivery around a single countdown-driven behavior.

### Table Stakes

| Feature | Why Required | Complexity | Notes |
|---------|--------------|------------|-------|
| Permission request when reminder delivery is first needed | Notifications cannot arrive without user authorization | LOW | Request only when the timed reminder feature is actually invoked. |
| Pre-expiry reminder for longer timed sessions | This is the main user-requested convenience outcome | LOW to MEDIUM | Must skip short sessions to avoid misleading “2 分钟前” timing. |
| End-of-session reminder | Confirms the timed keep-awake session has actually ended | LOW to MEDIUM | Should follow the real session end, not just the original scheduled end date. |
| Stale reminder cancellation | Users lose trust immediately if an old session still notifies later | MEDIUM | Replacement, manual stop, and mode switches all need explicit cancellation truth. |
| Visible permission-unavailable state | Silent failure would violate the project’s truth rules | MEDIUM | Keep reminder failure visible while leaving keep-awake itself usable. |

### Differentiators

| Feature | Value | Complexity | Notes |
|---------|-------|------------|-------|
| Reminder behavior tied to the same session truth as the menu countdown | Makes the app feel dependable rather than “best effort” | MEDIUM | Stronger than a fire-and-forget notification schedule. |
| Fixed, narrow reminder scope | Keeps the milestone shippable and testable | LOW | Avoids turning one request into a settings/product-surface rewrite. |

### Anti-Features

| Feature | Why It’s Tempting | Why It’s Out of Scope | Alternative |
|---------|-------------------|----------------------|-------------|
| Configurable reminder lead times | Sounds flexible | Adds settings UI, persistence, and more edge cases before validating the core behavior | Ship fixed `2 分钟` first |
| Notification history or inbox | Feels “complete” | Not needed for a personal menu bar utility validating one reminder flow | Let the system Notification Center own history |
| WOL/device notifications in the same milestone | Reuses the same API surface | Reopens a broader product area and weakens milestone focus | Keep reminders scoped to timed keep-awake only |

## Dependency Map

```text
[Timed keep-awake session starts]
    ├──requires──> [Notification permission truth]
    ├──enables──> [Pre-expiry reminder scheduling]
    └──enables──> [Expiry reminder scheduling]

[Session replaced / stopped / switched]
    └──requires──> [Stale reminder cancellation]

[Permission denied / unavailable]
    └──requires──> [Visible reminder-unavailable state]
```

## MVP Definition

### Must Ship in v1.9

- [ ] Request notification permission when reminder delivery is needed
- [ ] Pre-expiry reminder at about `2 分钟` before end for eligible timed sessions
- [ ] End reminder when the timed session actually ends
- [ ] Stale reminder cancellation on stop, replacement, and mode switch
- [ ] Truthful permission-unavailable feedback without blocking keep-awake

### Defer

- [ ] Notification preferences UI
- [ ] Configurable lead times
- [ ] WOL notifications
- [ ] Reminder history or analytics

## Sources

- User request from current milestone discussion
- Local repo: `KeepAwakeSessionModel`, keep-awake menu/status presentation, keep-awake tests

---
*Feature research for: v1.9 Timed Keep-Awake Notifications*
