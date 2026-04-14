# Phase 1: Truthful Foundations - Context

**Gathered:** 2026-04-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the existing manual Wake-on-LAN flow and keep-awake menu state trustworthy. This phase covers truthful MAC validation, truthful local-send feedback, and lifecycle-owned keep-awake/menu state so visible UI only reflects real local outcomes. Saved devices, recents, timed sessions, and broader menu polish remain out of scope for this phase.

</domain>

<decisions>
## Implementation Decisions

### Manual MAC Validation
- **D-01:** Manual MAC input must validate in real time rather than only on submit.
- **D-02:** The send action must stay disabled until the entered MAC is fully valid.
- **D-03:** Manual entry accepts only colon-delimited format: `AA:BB:CC:DD:EE:FF`.
- **D-04:** The field should allow free typing and must not auto-rewrite the user's input into a forced format.
- **D-05:** Validation feedback should be specific by error type rather than a single generic error message.

### Wake Result Feedback
- **D-06:** Success messaging must explicitly mean local send only, for example "wake packet sent from this Mac", and must not imply that the target device is already awake.
- **D-07:** Failure messaging must be written in user-understandable language instead of exposing raw technical error strings.
- **D-08:** Starting a new send clears the previous result immediately; once the send completes, only the current attempt's result should be shown.
- **D-09:** Wake results should continue to appear in the existing in-window status area rather than through heavier alerts or extra surfaces.

### Keep-Awake Toggle Semantics
- **D-10:** Keep-awake menu state and menu bar icon must change only after the underlying display-sleep assertion change succeeds.
- **D-11:** While a keep-awake change is in progress, the UI should show an explicit transitional state such as "Turning on..." or "Turning off...".
- **D-12:** Transitional feedback should appear directly in the menu item label.
- **D-13:** If the keep-awake state change fails, the UI must remain on the prior confirmed state and surface a clear failure message.

### Window State Lifecycle
- **D-14:** Closing and reopening the WOL window should preserve unfinished input.
- **D-15:** Reopening the WOL window should clear the previous result message so stale results are not mistaken for current state.
- **D-16:** If the window closes while a send is in progress, the send should continue in the background.
- **D-17:** After reopening following an in-flight send, the user should see the final result of that background send.

### the agent's Discretion
- Exact validation copy for each MAC input error state, as long as error messages stay specific and user-readable.
- Exact success/failure phrasing in Chinese vs English, as long as success is clearly "local send succeeded" rather than "device woke up".
- Exact menu implementation for transitional keep-awake feedback, as long as only confirmed underlying state drives the steady-state menu checkmark and icon.
- Exact persistence mechanism for retaining unfinished WOL input across window close/reopen within the app session.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 1 goal, success criteria, and phase boundary.
- `.planning/REQUIREMENTS.md` — Defines `WOL-02`, `RELY-02`, `RELY-03`, and `RELY-05`, plus related milestone scope constraints.

### Project-level constraints
- `.planning/PROJECT.md` — Defines the core value, reliability expectations, native macOS direction, and out-of-scope guardrails for this milestone.
- `.planning/STATE.md` — Confirms current focus is Phase 1 and captures milestone sequencing decisions affecting this work.

### Existing product behavior
- `README.md` — Describes the current app capabilities and user-facing runtime model for the menu bar utility.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Mac OS Swiss Knife/WOLView.swift`: Existing SwiftUI form with manual MAC input, status text area, send button state, and notification-based lifecycle hooks.
- `Mac OS Swiss Knife/WOLSender.swift`: Existing WOL send boundary with MAC parsing, local socket/broadcast handling, and typed failure cases that can back truthful UI messaging.
- `Mac OS Swiss Knife/PowerAssertionManager.swift`: Existing ownership point for display-sleep assertion state; already mutates `isEnabled` only when the enable path succeeds.
- `Mac OS Swiss Knife/StatusBarController.swift`: Existing menu/controller seam that currently owns keep-awake item state, icon updates, and menu actions.
- `Mac OS Swiss Knife/WOLWindow.swift`: Existing reusable AppKit window controller that already posts show/close notifications and can carry lifecycle behavior changes.
- `Mac OS Swiss Knife/AppDelegate.swift`: Existing coordinator for menu actions, window opening, and app shutdown cleanup.

### Established Patterns
- Flat app-target file structure with one main type per file; new phase work should fit that style instead of introducing a large subsystem layout.
- SwiftUI view state is currently local to `WOLView`, while side effects live in separate service/controller types.
- NotificationCenter is already used to coordinate WOL window lifecycle between AppKit and SwiftUI.
- User-facing strings in runtime code are currently Chinese, while type/API naming stays English.
- Low-level side effects use typed errors and guard-based early returns rather than generalized state frameworks.

### Integration Points
- Manual MAC validation changes will land primarily in `Mac OS Swiss Knife/WOLView.swift`, potentially with a small extracted validator/helper if needed.
- Truthful wake result mapping will connect `Mac OS Swiss Knife/WOLSender.swift` error/outcome information to `Mac OS Swiss Knife/WOLView.swift` presentation state.
- Truthful keep-awake state ownership will require a cleaner state flow between `Mac OS Swiss Knife/PowerAssertionManager.swift` and `Mac OS Swiss Knife/StatusBarController.swift`.
- Window lifecycle decisions will connect `Mac OS Swiss Knife/WOLWindow.swift`, `Mac OS Swiss Knife/WOLView.swift`, and possibly a shared session state holder if view-local state is no longer sufficient.

</code_context>

<specifics>
## Specific Ideas

- The user wants success feedback to mean "the wake packet was sent locally from this Mac", not "the target machine definitely woke up".
- The user explicitly prefers colon-delimited MAC entry only, with no auto-formatting takeover by the UI.
- The keep-awake menu item should visibly communicate transitional states such as "Turning on..." / "Turning off..." before confirmed completion.
- Reopening the WOL window should feel like resuming unfinished work, not starting from scratch, while stale result text must still be cleared.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-truthful-foundations*
*Context gathered: 2026-04-11*
