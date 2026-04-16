# Phase 14: Duration Management UI Polish - Context

**Gathered:** 2026-04-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Refine the existing `常亮时长` manager so the timed-duration area uses more obviously native macOS list semantics and clearer semantic action styling, without reopening any shipped duration CRUD, sorting, or root-menu synchronization behavior.

</domain>

<decisions>
## Implementation Decisions

### List presentation semantics
- **D-01:** Replace the custom `ScrollView` + stacked row surface treatment with a more native macOS list or table presentation for the timed-duration area.
- **D-02:** Keep the current compact single-window structure: title row, `添加时长` action, populated timed list, empty state, and shared add/edit sheet all stay in the same manager surface.
- **D-03:** Treat this as visual semantics polish only, not a data-model or workflow rewrite. Existing row ordering, list-local sheet behavior, delete confirmation, and root-menu sync stay unchanged.

### Row action semantics
- **D-04:** Edit affordances should use the app accent/theme color so they read as the safe primary modification action.
- **D-05:** Delete affordances should use destructive red semantics so their risk is obvious before confirmation.
- **D-06:** Action styling should remain restrained and native to macOS rather than introducing custom chrome or flashy emphasis.

### Regression boundary
- **D-07:** Preserve the accessibility seams already added for the duration manager and extend them only where needed to lock the new native list semantics.
- **D-08:** Keep this phase scoped to the `常亮时长` manager only; do not reopen the root keep-awake menu, duration persistence rules, or validation contract.

### the agent's Discretion
- Choose the exact native list implementation (`List`, table-like list configuration, or equivalent AppKit-backed presentation) as long as it reads clearly as a macOS list.
- Decide the exact balance of text labels, tinting, spacing, and separators for edit/delete affordances while honoring the semantic color decisions above.
- Tune padding, row density, and supplementary captions as needed to keep the manager compact and scannable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and scope
- `.planning/ROADMAP.md` — Defines the v1.4 milestone, Phase 14 goal, and the narrow UI-polish-only boundary.
- `.planning/PROJECT.md` — Captures the durable product direction, the current v1.4 milestone goals, and the decision to prefer native macOS list components plus semantic button colors.
- `.planning/REQUIREMENTS.md` — Defines `AWAKE-14`, `AWAKE-15`, and `AWAKE-16`, which are the complete requirement surface for this phase.

### Prior phase outcomes that constrain this work
- `.planning/phases/13-duration-management-surface/13-03-SUMMARY.md` — Documents the shared add/edit sheet, live root-menu synchronization, and the explicit rule that Phase 14 must not reopen already-shipped CRUD truth.
- `.planning/phases/13-duration-management-surface/13-04-SUMMARY.md` — Documents the grouped list-surface fix that shipped in v1.3 and what still felt insufficiently native.
- `.planning/phases/13-duration-management-surface/13-VERIFICATION.md` — Records the final verification boundary and confirms Phase 13 behavior is already complete.
- `.planning/phases/13-duration-management-surface/13-HUMAN-UAT.md` — Records visual approval of the shipped v1.3 cosmetic fix; this phase is refinement beyond that accepted baseline, not a defect repair.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/KeepAwakeDurationManagementView.swift`: already owns the manager surface, empty state, populated timed-duration area, shared add/edit sheet, and current list/accessibility seams.
- `Tools Cat/KeepAwakeDurationManagementSessionModel.swift`: already owns all add/edit/delete/sort behavior and should remain untouched except where UI wiring demands it.
- `Tools Cat/KeepAwakeDurationManagementPresentation.swift`: already centralizes list copy and form labels, so polish should reuse that presentation seam rather than hardcoding new strings.
- `Tools CatUITests/Tools_CatUITests.swift`: already provides a focused seeded-duration smoke path for the manager surface and can lock the new native list semantics.

### Established Patterns
- The duration manager keeps CRUD inside one retained native window with a shared list-local sheet rather than swapping entire screens.
- The project prefers direct-launch macOS UI smoke plus targeted controller/session tests over inventing deeper UI harnesses for visual polish.
- Phase 13 already established that only timed durations belong in the managed list and that `无限常亮` stays outside the CRUD surface.

### Integration Points
- The primary implementation seam is `populatedListContent` and `KeepAwakeDurationRow` inside `Tools Cat/KeepAwakeDurationManagementView.swift`.
- Any action-color polish must attach to the existing row edit/delete controls without changing the session callbacks.
- Any automated verification additions should extend the existing manager-window smoke and avoid reopening unrelated keep-awake menu tests.

</code_context>

<specifics>
## Specific Ideas

- Prefer the built-in macOS list feel over a lightly skinned custom stack.
- Make the edit versus delete choice readable at a glance through semantic tint, not just button labels.
- Keep the final result restrained, compact, and obviously native to the rest of the app.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 14-duration-management-ui-polish*
*Context gathered: 2026-04-16*
