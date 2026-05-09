# Phase 24: Timed Reminder Scheduling - Context

**Gathered:** 2026-05-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Add the scheduling layer for truthful local reminders around the already-shipped timed keep-awake flow. This phase covers when notification permission is requested, when a pre-expiry reminder is scheduled or skipped, and how stale scheduled reminders are canceled when the active timed session changes. It does not deliver the end-of-session notification itself, does not add notification settings UI, and does not reopen the existing keep-awake duration/menu model.

</domain>

<decisions>
## Implementation Decisions

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

### the agent's Discretion
- Choose the concrete notification service abstraction and test seam, as long as permission state, scheduling, and cancellation remain deterministic and unit-testable.
- Decide the exact launch-time request trigger point inside app startup, as long as it happens during normal app launch and does not create a second source of keep-awake truth.
- Decide the exact reminder copy and request identifier format, as long as copy stays concise and the identifier strategy supports strict stale-reminder cancellation.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 24 goal, dependency, and the three success criteria for pre-expiry reminder scheduling and stale-reminder cancellation.
- `.planning/REQUIREMENTS.md` — Defines `NOTF-01`, `NOTF-02`, and `NOTF-04`, which are the full requirement surface for this phase.
- `.planning/PROJECT.md` — Captures the durable product direction that v1.9 stays narrowly focused on truthful local timed keep-awake reminders, not a broader notification/settings project.
- `.planning/STATE.md` — Confirms v1.9 is the active milestone and that Phase 24 is the current planning target.

### Prior decisions that constrain this phase
- `.planning/phases/04-timed-keep-awake/04-CONTEXT.md` — Defines the shipped timed keep-awake menu structure, replacement semantics, countdown truth, and the shared session-model boundary this phase must preserve.
- `.planning/phases/22-wol-result-timeout/22-CONTEXT.md` — Reinforces the pattern that transient user feedback should stay tied to one shared session truth and that stale scheduled behavior must be cancellable.
- `.planning/phases/23-device-form-save-guard/23-CONTEXT.md` — Reinforces the current milestone preference for narrow interaction guardrails rather than broader UI expansion.

### Existing implementation surfaces
- `Tools Cat/AppDelegate.swift` — App startup composition point and likely place to trigger launch-time notification authorization setup.
- `Tools Cat/KeepAwakeSessionModel.swift` — Owns confirmed timed keep-awake lifecycle, replacement, countdown, and expiry behavior; the main truth boundary for reminder scheduling.
- `Tools Cat/KeepAwakePresentation.swift` — Owns keep-awake status-line rendering priority and is the likely reminder-unavailable presentation seam.
- `Tools Cat/StatusBarController.swift` — Renders keep-awake status entirely from shared presentation/session state and should remain presentation-only.
- `Tools CatTests/KeepAwakeSessionModelTests.swift` — Existing deterministic timed-session seam and the primary regression suite to extend for reminder scheduling/cancellation behavior.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/KeepAwakeSessionModel.swift`: already owns timed keep-awake start/replace/stop/expiry transitions plus a testable countdown scheduler seam, making it the natural source of truth for reminder scheduling and cancellation.
- `Tools Cat/KeepAwakePresentation.swift`: already prioritizes pending-action text, then `message`, then steady-state status, which gives this phase an existing place to surface reminder-unavailable feedback without inventing a new UI surface.
- `Tools Cat/StatusBarController.swift`: already renders keep-awake menu rows and status text from one presentation object, so notification availability feedback can remain centralized rather than view-local.
- `Tools Cat/AppDelegate.swift`: already wires shared app-lifetime objects and is the natural startup seam for a launch-time notification authorization request.
- `Tools CatTests/KeepAwakeSessionModelTests.swift`: already proves replacement cancels stale countdown timers and should guide an equivalent seam for canceling stale scheduled reminders.

### Established Patterns
- Timed keep-awake truth lives in one retained session model shared across the menu bar and any related presentation surfaces.
- Stable UI only reflects confirmed underlying state; side-effect failures surface as status text instead of optimistic state flips.
- Narrow behavior phases in this repo prefer small injected scheduler/service seams and focused unit tests over broad UI harness expansion.

### Integration Points
- The main behavior seam is timed keep-awake lifecycle inside `KeepAwakeSessionModel`: successful timed start, replacement, manual stop, switch to indefinite, and natural expiry.
- Notification authorization setup must connect during app launch without creating an alternate keep-awake state owner beside the shared session model.
- Reminder-unavailable feedback should flow through existing `message` / presentation state so `StatusBarController` stays a renderer, not a new state machine.

</code_context>

<specifics>
## Specific Ideas

- User explicitly wants permission requested at app launch, not lazily at first timed keep-awake use.
- User explicitly wants notification-unavailable feedback to reuse the existing keep-awake surface rather than adding new UI.
- User explicitly wants old reminders canceled whenever the active timed session is replaced, stopped, or switched to `无限常亮`, with only the current timed session remaining eligible to notify.
- Product direction already includes an end-of-session reminder, but that delivery stays Phase 25 work rather than expanding Phase 24 scope.

</specifics>

<deferred>
## Deferred Ideas

- Actual end-of-session reminder delivery (`NOTF-03`) remains Phase 25 work even though the reminder should exist in the shipped milestone.
- Reminder-unavailable state wording/visibility rules beyond reusing the current keep-awake surface remain Phase 25 work because that is where `NOTF-05` is formally scoped.

</deferred>

---

*Phase: 24-timed-reminder-scheduling*
*Context gathered: 2026-05-09*
