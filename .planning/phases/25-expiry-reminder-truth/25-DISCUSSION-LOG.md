# Phase 25: Expiry Reminder Truth - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-10
**Phase:** 25-Expiry Reminder Truth
**Areas discussed:** End-of-session reminder boundary, reminder-unavailable visibility, timed-session eligibility for unavailable-state feedback

---

## End-of-session reminder boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Fire only after confirmed shutdown | Send the end reminder only after the underlying keep-awake session has actually turned off and the confirmed session returns to `.off` | ✓ |
| Fire at planned end time | Send the end reminder as soon as the countdown reaches `endDate`, even before confirmed shutdown completes | |
| Other | Custom trigger rule | |

**User's choice:** Fire only after confirmed shutdown
**Notes:** User selected `1A`. The reminder must describe real session end, not merely expected expiry timing, so disable failures or unchanged-on outcomes must not emit a false “已结束” reminder.

---

## Reminder-unavailable visibility

| Option | Description | Selected |
|--------|-------------|----------|
| Same surface, merged single line | Reuse the current keep-awake status surface and combine countdown plus unavailable truth into one line | |
| Same surface, two lines | Reuse the current keep-awake status surface but show countdown truth and unavailable truth on separate lines | ✓ |
| Unavailable message overrides countdown | Show only the unavailable message while the session remains active | |
| Temporary unavailable message, then back to countdown | Briefly show unavailable truth and then return to countdown-only status | |

**User's choice:** Same surface, two lines
**Notes:** User selected `2A` with one clarification: the two truths should not be forced into a single long string like `还剩 14 分钟 · 提醒不可用`. The existing keep-awake status area should carry both truths, but in two-line form for readability.

---

## Timed-session eligibility for unavailable-state feedback

| Option | Description | Selected |
|--------|-------------|----------|
| All timed sessions | Every timed session should surface reminder-unavailable truth when notifications are unavailable | ✓ |
| Only sessions longer than two minutes | Show unavailable truth only when the session would normally schedule the pre-expiry reminder | |
| Only when both reminder attempts fail | Delay unavailable truth until all reminder paths have concretely failed | |
| Other | Custom eligibility rule | |

**User's choice:** All timed sessions
**Notes:** User selected `3A`. Short timed sessions still rely on the end reminder even though they skip the pre-expiry reminder, so unavailable reminder truth should remain visible for them as well.

---

## the agent's Discretion

- Exact end-reminder copy.
- Exact unavailable-state copy for the second status line.
- Exact implementation strategy for rendering two lines inside the existing keep-awake status surface.

## Deferred Ideas

- Notification settings, configurable reminder lead times, reminder history, and broader notification management remain out of scope.
- WOL or other non-keep-awake notifications remain out of scope.
