# Phase 15: Device Library UI Parity - Context

**Gathered:** 2026-04-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Align the shipped `设备库` manager with the visual and interaction language of the shipped `常亮时长` manager. This phase is presentation-only: it upgrades the populated device list to a more obviously native macOS list surface, moves add/edit into a compact list-local presentation, and makes edit/delete semantics visually match the duration manager without reopening saved-device truth.

</domain>

<decisions>
## Implementation Decisions

### Management surface parity
- **D-01:** The normal populated device-library surface should move from the current custom `ScrollView` + stacked rows to a clearly native macOS list presentation that matches the duration manager's current feel.
- **D-02:** Device add and edit must use a shared sheet presented over the retained list surface, matching the duration manager, instead of the current full-view list/form screen swap.
- **D-03:** This phase explicitly supersedes Phase 2 decision `D-08` for this surface only: device add/edit no longer needs a dedicated replacement view; list-local sheet presentation is now the canonical pattern for the manager.

### Reorder boundary
- **D-04:** Keep the existing explicit reorder mode as-is. This phase only aligns the normal browse/add/edit/delete presentation and does not redesign how sorting mode works.
- **D-05:** Entering add or edit should still exit reorder mode before presenting the form, preserving the current behavioral guardrail against accidental moves.

### Row action semantics
- **D-06:** The device-row `编辑` action should use the same accent/theme color semantics as the duration manager so it reads as the safe primary modification action.
- **D-07:** The device-row `删除` action should continue to use destructive red semantics so risk is obvious before confirmation.
- **D-08:** Action styling should remain restrained and native to macOS rather than introducing extra custom chrome.

### Regression boundary
- **D-09:** Preserve the dedicated native `设备库` window, direct-launch entry point, saved-device persistence truth, validation-before-save behavior, delete confirmation, and wake/menu integration established in earlier phases.
- **D-10:** Preserve existing accessibility/test seams where possible and extend them only as needed to lock the new list-local sheet and native list semantics.

### the agent's Discretion
- Choose the exact native list implementation and surrounding section chrome as long as the populated surface clearly reads like the shipped duration manager's list-first presentation.
- Decide whether the populated device list needs a lightweight section caption, count label, row insets, or similar small framing details to feel aligned with the duration manager while keeping the utility window compact.
- Tune the exact sheet width, field spacing, and error-message placement so the shared add/edit form feels compact and native without weakening the existing validation flow.

</decisions>

<specifics>
## Specific Ideas

- User intent: `WOL设备管理那边的添加、编辑、删除风格和管理时长这边的风格一致`.
- Add/edit parity should be literal, not approximate: the list remains visible and the form appears as a shared sheet over it.
- Reorder is intentionally not part of the parity redesign; keep that mode isolated so this milestone stays presentation-only.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope
- `.planning/ROADMAP.md` — Defines Phase 15 goal, dependency on Phase 14, and the success criteria for list parity, sheet-based add/edit, semantic actions, and regression safety.
- `.planning/REQUIREMENTS.md` — Defines `DEVS-06` through `DEVS-09`, which are the full requirement surface for this milestone.
- `.planning/PROJECT.md` — Captures the active v1.5 milestone goals and the durable native-macOS product direction that this phase must preserve.
- `.planning/STATE.md` — Confirms Phase 15 is the active focus and that no plan or execution artifacts exist yet.

### Prior decisions that constrain this phase
- `.planning/phases/14-duration-management-ui-polish/14-CONTEXT.md` — Defines the parity reference pattern: native list semantics, compact retained manager shell, accent edit, destructive delete, and restrained macOS styling.
- `.planning/phases/02-device-library-management/02-CONTEXT.md` — Defines the durable dedicated-window, validation, reorder, and delete-confirmation rules that remain in force, while also recording the older full-view add/edit decision that this phase now intentionally overrides.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/KeepAwakeDurationManagementView.swift`: the direct UI reference for the target shell, shared sheet presentation, native `List`, and semantic edit/delete styling that Phase 15 should mirror where appropriate.
- `Tools Cat/DeviceLibraryView.swift`: already owns the `设备库` manager shell, empty state, row layout, delete confirmation, and accessibility identifiers; this is the primary UI seam for the parity work.
- `Tools Cat/DeviceLibrarySessionModel.swift`: currently drives a `screen`-based list/form swap and exits reorder mode on add/edit; this state model is the main seam that must shift from full-screen form navigation to sheet presentation without changing CRUD truth.
- `Tools Cat/DeviceLibraryManagementPresentation.swift`: centralizes list/form copy and should remain the source of truth for user-facing device-management strings.
- `Tools CatUITests/Tools_CatUITests.swift`: already has direct-launch device-library smoke coverage for seeded list, empty state, and add flow; these tests can be extended to lock the new list-local sheet semantics.
- `Tools CatTests/DeviceLibraryManagementPresentationTests.swift`: already locks core presentation strings that should survive the parity refactor.

### Established Patterns
- The shipped duration manager keeps CRUD inside one retained utility window with a shared list-local sheet instead of replacing the whole view hierarchy.
- The app prefers native SwiftUI/AppKit patterns, semantic button roles/colors, and focused regression smoke over introducing custom UI abstractions for visual polish.
- Existing device-library behavior already treats reorder as an explicit mode rather than always-on drag editing, and this phase should preserve that separation.

### Integration Points
- The main implementation seam is the `switch session.screen` split in `Tools Cat/DeviceLibraryView.swift` and the corresponding `DeviceLibrarySessionModel.screen/currentFormMode` state flow.
- The populated normal-mode device surface in `DeviceLibraryView.swift` should be brought into parity with the duration manager while leaving the reorder `List` path behaviorally intact.
- UI verification should extend the existing `--ui-test-open-device-library` launch path so the new sheet/list semantics are covered without creating a separate harness.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 15-device-library-ui-parity*
*Context gathered: 2026-04-16*
