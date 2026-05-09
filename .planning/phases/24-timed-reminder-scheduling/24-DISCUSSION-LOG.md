# Phase 24: Timed Reminder Scheduling - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-09
**Phase:** 24-Timed Reminder Scheduling
**Areas discussed:** Reminder availability feedback, permission request timing, timed reminder replacement semantics

---

## Reminder availability feedback

| Option | Description | Selected |
|--------|-------------|----------|
| Add a new notification-specific UI surface | Introduce a separate settings, banner, or window-level reminder state for unavailable notifications | |
| Reuse existing keep-awake feedback surface | Show reminder-unavailable state through the already-shipped keep-awake status/message path | ✓ |
| Hide the failure entirely | Let keep-awake continue but provide no visible reminder-unavailable feedback | |

**User's choice:** Reuse existing keep-awake feedback surface
**Notes:** User explicitly chose to复用现有反馈 surface when notification permission is unavailable. This preserves the existing menu-truth model and avoids broadening UI scope in Phase 24.

---

## Permission request timing

| Option | Description | Selected |
|--------|-------------|----------|
| Request on app launch | Ask for local notification permission during normal app startup so reminder capability is decided early | ✓ |
| Request when first timed reminder is needed | Delay the system prompt until the first timed keep-awake session that could schedule a reminder | |
| Never prompt automatically | Keep reminders disabled until the user manually enables permission elsewhere | |

**User's choice:** Request on app launch
**Notes:** User explicitly wants permission requested at app launch rather than lazily at first timed session. Keep-awake itself still must remain usable if permission is denied.

---

## Timed reminder replacement semantics

| Option | Description | Selected |
|--------|-------------|----------|
| Let old reminder remain scheduled | A previous timed session's pre-expiry reminder may still fire even after replacement or stop | |
| Cancel stale reminders and keep only current session | Replacing a timed session, stopping it, or switching to `无限常亮` cancels the old reminder so only the active timed session can notify | ✓ |
| Cancel only on manual stop | Preserve replacement reminders but remove them only when the user explicitly turns keep-awake off | |

**User's choice:** Cancel stale reminders and keep only current session
**Notes:** User explicitly wants switching to a new timed duration, stopping early, or moving to `无限常亮` to cancel the old timed reminder and keep only the current session eligible to notify.

---

## the agent's Discretion

- Exact notification abstraction, scheduler seam, and identifier format.
- Exact launch-time integration point inside app startup.
- Exact reminder copy, as long as scope stays on timed keep-awake and cancellation semantics remain strict.

## Deferred Ideas

- “到点也再提醒一次” is confirmed product direction but remains Phase 25 implementation scope, not Phase 24.
- Broader reminder-unavailable UX or settings work remains out of scope for this phase.
