# Phase 25: Expiry Reminder Truth - Context

**Gathered:** 2026-05-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Complete the truthful local-reminder story for timed keep-awake by delivering one end-of-session notification only when the timed session has actually ended, while keeping reminder-unavailable truth visible without blocking timed keep-awake itself. This phase does not add notification settings, configurable lead times, WOL notifications, reminder history, or any new notification management surface beyond the existing keep-awake feedback area.

</domain>

<decisions>
## Implementation Decisions

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 25 goal, dependency on Phase 24, and the three success criteria for truthful end reminders and visible unavailable states.
- `.planning/REQUIREMENTS.md` — Defines `NOTF-03` and `NOTF-05`, which are the full requirement surface for this phase.
- `.planning/PROJECT.md` — Captures the durable v1.9 constraint that notifications stay narrow, truthful, and non-blocking for timed keep-awake.
- `.planning/STATE.md` — Confirms Phase 25 is the current planning target after Phase 24 completion.

### Prior decisions that constrain this phase
- `.planning/phases/04-timed-keep-awake/04-CONTEXT.md` — Defines the shipped timed keep-awake lifecycle, replacement semantics, countdown truth, and “no extra ended banner” baseline this phase must respect while adding notifications.
- `.planning/phases/24-timed-reminder-scheduling/24-CONTEXT.md` — Defines launch-time permission requests, pre-expiry reminder ownership, stale-cancellation semantics, and reuse of the existing keep-awake feedback surface.
- `.planning/phases/24-timed-reminder-scheduling/24-01-PLAN.md` — Captures the current reminder scheduling seam and test boundaries that Phase 25 should extend rather than bypass.

### Existing implementation surfaces
- `Tools Cat/KeepAwakeReminderScheduling.swift` — Current reminder abstraction and production `UNUserNotificationCenter` adapter; Phase 25 should extend this seam instead of introducing a second notification path.
- `Tools Cat/KeepAwakeSessionModel.swift` — Owns confirmed timed-session lifecycle, natural expiry, manual stop, replacement, and current pre-expiry reminder state.
- `Tools Cat/KeepAwakePresentation.swift` — Owns keep-awake status text priority and is the key presentation seam affected by the need to show countdown truth plus unavailable truth together.
- `Tools Cat/StatusBarController.swift` — Renders the keep-awake status area from presentation/session state and must remain a renderer rather than a second keep-awake state owner.
- `Tools CatTests/KeepAwakeSessionModelTests.swift` — Current deterministic reminder and timed-session regression suite that should expand to cover truthful end-reminder delivery and unavailable-state semantics.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` — Current controller regression seam for keep-awake status-row behavior and reminder-unavailable rendering.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/KeepAwakeSessionModel.swift`: already owns the only truthful timed-session end path through `handleCountdownTick -> beginStop() -> handleStopOutcome(_:)`, making it the natural owner of end-reminder truth.
- `Tools Cat/KeepAwakeReminderScheduling.swift`: already centralizes launch-time authorization, pre-expiry scheduling, and pending-reminder cancellation behind a testable seam.
- `Tools Cat/KeepAwakePresentation.swift`: already arbitrates keep-awake status text priority, which is the main place where countdown truth and reminder-unavailable truth currently conflict.
- `Tools Cat/StatusBarController.swift`: already renders a non-actionable keep-awake status item from shared presentation/session state, which should remain the only menu-surface outlet for unavailable reminder feedback.
- `Tools CatTests/KeepAwakeSessionModelTests.swift` and `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift`: already cover session confirmation boundaries, stale reminder cancellation, and unavailable-state reuse of the existing keep-awake status surface.

### Established Patterns
- Keep-awake UI truth must follow confirmed underlying power-controller outcomes; planned time alone is never enough to claim a state change happened.
- Reminder ownership is session-scoped and cancellable, so replacements, manual stops, and mode switches only mutate reminder state after the real keep-awake transition outcome is known.
- This repo prefers narrow service seams and focused controller/model tests over adding broad new UI harnesses or secondary state owners.
- User-facing keep-awake messaging is concise Chinese copy rendered through shared presentation state rather than separate notification-specific UI components.

### Integration Points
- The truthful end-reminder hook belongs in the confirmed timed-session shutdown path inside `KeepAwakeSessionModel`, specifically where expiry-driven stop outcomes become real `.off` state.
- Reminder-unavailable visibility likely requires a presentation/state shape that can expose countdown truth and unavailable truth at the same time instead of the current single `message` override path.
- `StatusBarController` will need to render the existing keep-awake status area in a way that can show two lines of non-actionable truth without inventing a new notification menu section.

</code_context>

<specifics>
## Specific Ideas

- User explicitly wants “到点也再提醒一次”, but only when the timed keep-awake session has actually ended rather than merely reaching the expected end timestamp.
- User explicitly rejected collapsing countdown truth and unavailable truth into one long line such as `还剩 14 分钟 · 提醒不可用`; the status area needs two-line presentation instead.
- User explicitly wants reminder-unavailable truth for all timed sessions, including `<= 2 分钟` sessions that skip pre-expiry scheduling but still rely on the end reminder.

</specifics>

<deferred>
## Deferred Ideas

- Notification preferences UI, configurable reminder lead time, reminder history, or troubleshooting surfaces remain out of scope for this phase.
- Any expansion of notifications beyond timed keep-awake, including WOL notifications or app-wide notification features, remains deferred.

</deferred>

---

*Phase: 25-expiry-reminder-truth*
*Context gathered: 2026-05-10*
