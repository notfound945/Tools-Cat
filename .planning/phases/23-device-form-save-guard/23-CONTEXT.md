# Phase 23: Device Form Save Guard - Context

**Gathered:** 2026-05-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Tighten the saved-device add/edit sheet so `保存设备` is only actionable after the user has entered the two required fields, while preserving the shipped v1.7 validation-truth and delayed validation-reveal behavior. This phase does not change the underlying MAC/name validation rules, save-time truth boundary, device-library structure, or WOL menu behavior.

</domain>

<decisions>
## Implementation Decisions

### Save-button enablement
- **D-01:** `保存设备` must stay disabled while the device name field is empty or whitespace-only.
- **D-02:** `保存设备` must stay disabled while the MAC address field is empty or whitespace-only.
- **D-03:** Once both required fields contain some input, `保存设备` becomes enabled even if deeper validation may still fail at submit time.

### Validation timing preservation
- **D-04:** Existing delayed validation-message reveal timing from v1.7 remains unchanged: validation text only appears on blur or explicit submit, not during ordinary typing.
- **D-05:** Save-time validation truth remains unchanged: tapping enabled `保存设备` with malformed data must still run the existing validation path and block invalid persistence.

### Scope and regression guardrails
- **D-06:** Do not rewrite MAC validation rules, normalization, or save error messaging.
- **D-07:** Do not reopen first-use device seeding, WOL result timing, or menu structure; this phase only changes the add/edit form affordance.
- **D-08:** Keep parity with the keep-awake duration form pattern where the primary save action is gated by required-field presence, not by broader validation-message visibility timing.

### the agent's Discretion
- Choose whether the button-enable predicate lives as a computed session-model property or another equally local session-owned seam, as long as the view remains presentation-only and save-time truth still belongs to `saveDraft()`.
- Decide the exact trimming rule reuse for "has input" checks as long as whitespace-only values keep the button disabled.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 23 goal, dependency on Phase 22, and the success criteria for save-button gating without reopening validation timing.
- `.planning/REQUIREMENTS.md` — Defines `DEVS-15` and `DEVS-16`, which are the full requirement surface for this phase.
- `.planning/PROJECT.md` — Captures the durable product direction that v1.8 is limited to small interaction guardrails rather than broader feature changes.
- `.planning/STATE.md` — Confirms Phase 23 is now the active focus after Phase 22 completion.

### Prior decisions that constrain this phase
- `.planning/phases/19-deferred-device-form-validation/19-RESEARCH.md` — Documents why validation visibility and validation truth were separated and why invalid-save blocking must remain explicit at submit time.
- `.planning/phases/19-deferred-device-form-validation/19-VERIFICATION.md` — Confirms the shipped delayed validation-reveal contract that this phase must preserve.
- `.planning/phases/21-device-entry-verification-closure/21-VERIFICATION.md` — Confirms the current v1.7 device-entry baseline and closes the prior validation/seed evidence chain.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/DeviceLibrarySessionModel.swift`: already owns `canSaveDraft`, validation messages, reveal state, and `saveDraft()`; this is the primary seam for Phase 23.
- `Tools Cat/DeviceLibraryView.swift`: already binds the `保存设备` button to the session and handles blur-triggered reveal through `@FocusState`, so the enablement change should stay minimal and presentation-only.
- `Tools Cat/KeepAwakeDurationManagementSessionModel.swift`: already exposes a simpler save-button gating pattern based on required-field presence and can serve as the parity reference mentioned by the user.
- `Tools CatTests/DeviceLibrarySessionModelTests.swift`: already covers validation reveal, invalid-save blocking, and successful add/edit persistence, so it is the main regression suite to extend.

### Established Patterns
- Validation truth lives in the session model, not in the SwiftUI view.
- The view owns focus/blur detection and presentation timing, but persistence truth still funnels through one explicit `saveDraft()` submit boundary.
- The app prefers small affordance changes that reuse existing native form structure instead of introducing extra intermediate states or helper controllers.

### Integration Points
- The key behavior seam is `DeviceLibrarySessionModel.canSaveDraft`; Phase 23 should redefine that predicate from "fully valid draft" to "required fields contain input" while leaving `saveDraft()` validation intact.
- `DeviceLibraryView.swift` needs to actually apply the updated session predicate to the `保存设备` button disabled state.
- Regression coverage should prove both button gating and preserved delayed validation behavior, primarily in `DeviceLibrarySessionModelTests.swift` and only in UI smoke if the button-state seam is not already sufficiently locked.

</code_context>

<specifics>
## Specific Ideas

- User intent is explicit: `保存设备` should only be clickable once both `名称` and `MAC 地址` have been filled.
- The logic should mirror the current keep-awake duration form affordance pattern rather than introducing a new interaction model.
- This is intentionally not a validator rewrite: malformed-but-non-empty MAC input may enable the button, but save must still reject it with the existing delayed reveal path.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 23-device-form-save-guard*
*Context gathered: 2026-05-06*
