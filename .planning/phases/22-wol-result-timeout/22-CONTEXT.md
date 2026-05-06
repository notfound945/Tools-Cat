# Phase 22: WOL Result Timeout - Context

**Gathered:** 2026-05-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the existing WOL send result feedback transient again. This phase only governs how long the already-shipped success or failure result remains visible in the WOL window and the menu-bar wake status row, plus how that timeout interacts with consecutive wake attempts. It does not change WOL copy, menu structure, validation, or any saved-device management behavior.

</domain>

<decisions>
## Implementation Decisions

### Result visibility lifetime
- **D-01:** A completed WOL result, whether success or failure, should remain visible for approximately 3 seconds and then disappear automatically.
- **D-02:** The same 3-second lifetime applies in both result surfaces that already reflect WOL session state: the dedicated WOL window status text and the menu-bar wake status row.
- **D-03:** The timeout starts from when the final result is available to render, not from when packet sending begins.

### Consecutive wake behavior
- **D-04:** Starting a new wake action must cancel any previous pending clear so an older timer never removes newer feedback.
- **D-05:** Beginning a new wake action should replace stale completed-result UI with the in-progress sending state immediately, using the session model as the single source of truth.

### Scope and regression guardrails
- **D-06:** Keep the existing success and failure copy unchanged; this phase only changes feedback lifetime.
- **D-07:** Keep the current `快速 WOL` and `发送 WOL …` wake surfaces unchanged; only the transient status behavior is in scope.
- **D-08:** Keep the existing delayed validation reveal and saved-device form behavior untouched; save-button affordance work belongs to Phase 23.

### the agent's Discretion
- Choose the exact scheduling mechanism and timer abstraction as long as result expiry remains deterministic and cancellable in tests.
- Decide whether any hidden-window edge handling needs small session-model cleanup details, as long as the 3-second timeout still governs the same completed result and no stale feedback survives indefinitely.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 22 goal, dependency, and the three success criteria for 3-second result expiry and timeout cancellation on new sends.
- `.planning/REQUIREMENTS.md` — Defines `WOLF-01` and `WOLF-02`, which are the full requirement surface for this phase.
- `.planning/PROJECT.md` — Captures the durable product direction that wake status should feel trustworthy and low-friction from the menu bar.
- `.planning/STATE.md` — Confirms v1.8 is the active milestone and that Phase 22 is the current planning target.

### Prior decisions that constrain this phase
- `.planning/phases/19-deferred-device-form-validation/19-VERIFICATION.md` — Confirms the delayed validation-reveal contract that must remain untouched while Phase 22 stays focused on WOL result timing only.
- `.planning/phases/20-first-use-device-seed/20-VERIFICATION.md` — Confirms the seeded saved-device flow already shipped and should not be reopened by this timing-only phase.
- `.planning/phases/21-device-entry-verification-closure/21-VERIFICATION.md` — Confirms the latest WOL/device-entry behavior baseline that Phase 22 should preserve aside from transient result lifetime.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/WOLSessionModel.swift`: already owns `sendState` and `lastCompletedWake`, making it the natural single source of truth for both window and menu-bar result visibility.
- `Tools Cat/WOLView.swift`: already renders the window-local result text directly from `session.sendState`, so timeout behavior can stay model-driven instead of view-local.
- `Tools Cat/StatusBarController.swift`: already renders the wake status row from `wolSession.sendState` plus `lastCompletedWake`, so menu-bar expiry can piggyback on the same session state transition.
- `Tools Cat/WakeSendPresentation.swift`: already centralizes success copy generation and should remain untouched because copy changes are out of scope.
- `Tools CatTests/WOLSessionModelTests.swift`: already contains focused session-model coverage and a fake clear scheduler seam for deterministic timeout tests.

### Established Patterns
- The app prefers one retained session model to drive both the dedicated window and menu-bar surfaces rather than duplicating state per surface.
- Focused unit tests around session/controller seams are the established way to lock small interaction behavior without adding new UI harnesses.
- User-facing WOL strings are already treated as presentation truth in dedicated helpers/models; behavior-only phases should avoid rewriting them.

### Integration Points
- The main implementation seam is `WOLSessionModel.send(...)`, its completed-result state transitions, and the published `lastCompletedWake`/`sendState` values consumed by both UI surfaces.
- Any timeout logic should be testable through the existing injected clear-scheduler seam instead of relying only on wall-clock async behavior.
- Regression coverage should primarily extend `Tools CatTests/WOLSessionModelTests.swift`, with any additional menu-surface assertions only if the shared session-state contract needs explicit locking.

</code_context>

<specifics>
## Specific Ideas

- User intent is explicit: both the window prompt and the menu-bar prompt should disappear after 3 seconds.
- The desired behavior is transient confirmation, not persistent history and not a copy rewrite.
- New wake attempts should feel authoritative: newer feedback replaces older timers immediately.

</specifics>

<deferred>
## Deferred Ideas

- Saved-device `保存设备` button enable/disable affordance based on required-field completeness — Phase 23.

</deferred>

---

*Phase: 22-wol-result-timeout*
*Context gathered: 2026-05-06*
