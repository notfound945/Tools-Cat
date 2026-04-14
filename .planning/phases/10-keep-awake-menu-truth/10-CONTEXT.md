# Phase 10: Keep-Awake Menu Truth - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Tighten the keep-awake action group so the root menu only shows actions that are truthful for the real current state. This phase only fixes the misleading idle `关闭常亮` row, preserves the existing start rows and direct stop path for active sessions, and updates focused regression coverage plus validation docs around that visibility contract. It does not redesign the broader root menu, add new keep-awake capabilities, or reopen timed-session semantics beyond the visibility rule.

</domain>

<decisions>
## Implementation Decisions

### Idle visibility rule
- **D-01:** When `confirmedMode` is `.off` and `pendingAction` is `nil`, the root menu must omit `关闭常亮`.
- **D-02:** Hiding the idle stop row must not add a replacement placeholder or explanatory idle copy; the keep-awake section should stay compact and simply show the existing start rows plus any truthful status row.
- **D-03:** Existing keep-awake start rows remain in the shipped order `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`; this phase only changes whether the stop row appears.

### Active and transition behavior
- **D-04:** When keep-awake is actively `.indefinite` or `.timed`, the root menu must still expose exactly one direct `关闭常亮` row.
- **D-05:** While `pendingAction` is `.stopping`, keep `关闭常亮` visible but disabled with the rest of the keep-awake action group so the menu still truthfully shows the in-flight stop path.
- **D-06:** While keep-awake is starting from `.off`, do not surface `关闭常亮` early; transitional feedback should continue to come from the existing status row until an active session is actually confirmed.
- **D-07:** Existing checkmark/highlight behavior, countdown semantics, and truthful failure messaging from earlier phases remain locked; this phase only tightens stop-row visibility.

### Regression and validation anchor
- **D-08:** Focused regression coverage should update the existing keep-awake controller/menu tests and presentation-state tests that currently lock an always-visible `关闭常亮` row, instead of introducing a broad new menu test surface.
- **D-09:** Phase verification and validation artifacts should explicitly describe the idle-versus-active stop-row contract so docs match the shipped menu truth after implementation.

### the agent's Discretion
- Whether the stop-row visibility rule lives in `KeepAwakePresentation`, `StatusBarController`, or a small helper, as long as it derives from the confirmed keep-awake state plus pending action.
- Whether to extend the current keep-awake test files or add one narrowly scoped visibility test file, as long as the regression contract stays focused.
- Exact validation-doc wording and evidence layout, as long as the final docs state clearly that idle menus omit `关闭常亮` and active/stopping menus keep it.

</decisions>

<specifics>
## Specific Ideas

- Keep the shipped Chinese menu labels and root grouping intact; Phase 10 is a truth correction, not a menu redesign.
- Preserve the direct manual stop path for confirmed infinite and timed sessions.
- Reuse the existing status row for `正在切换...` / `正在关闭...` messaging rather than introducing extra idle explanatory rows.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and milestone constraints
- `.planning/ROADMAP.md` — Defines Phase 10 goal, success criteria, and the narrow milestone boundary around keep-awake menu truth.
- `.planning/REQUIREMENTS.md` — Defines `MENU-01`, `MENU-02`, and `MENU-03`, plus the explicit out-of-scope exclusions for broader menu redesign and new keep-awake capabilities.
- `.planning/PROJECT.md` — Captures the v1.2 milestone intent, core value, and the explicit goal of hiding `关闭常亮` when no keep-awake session exists.
- `.planning/STATE.md` — Confirms Phase 10 is the active focus and that the phase is beginning from a not-started state.

### Prior decisions that remain locked
- `.planning/phases/04-timed-keep-awake/04-CONTEXT.md` — Carries forward the fixed start-row set, direct `关闭常亮` stop path, countdown-on-status-row rule, and truthful confirmed-state semantics.
- `.planning/phases/05-native-menu-polish/05-CONTEXT.md` — Carries forward the compact three-section root-menu structure and the rule that idle menus should collapse unnecessary status noise.
- `.planning/phases/07-menu-bar-verification-strategy/07-CONTEXT.md` — Carries forward the preference for focused controller seams plus explicit verification/validation truth instead of inflated automation claims.

### Existing behavior and evidence that this phase will update
- `.planning/phases/04-timed-keep-awake/04-VERIFICATION.md` — Records the shipped keep-awake action order and the previous expectation that `关闭常亮` was always present.
- `Tools Cat/StatusBarController.swift` — Owns keep-awake menu rows, `renderKeepAwakePresentation()`, and the current always-present `keepAwakeOffItem`.
- `Tools Cat/KeepAwakePresentation.swift` — Defines the current confirmed-mode, pending-action, and status-text presentation model that can drive truthful visibility rules.
- `Tools Cat/KeepAwakeSessionModel.swift` — Defines the authoritative keep-awake state machine (`.off`, `.indefinite`, `.timed`, and pending transitions) that the visibility contract must reflect.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` — Currently locks the fixed keep-awake action array including the always-visible stop row.
- `Tools CatTests/KeepAwakeMenuStateTests.swift` — Locks pending and active keep-awake presentation semantics that Phase 10 should preserve.
- `Tools CatTests/StatusBarControllerMenuPolishTests.swift` — Locks the compact root-menu grouping and status-row behavior that the visibility change must not regress.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Tools Cat/StatusBarController.swift` already has explicit references for every keep-awake row and one centralized `renderKeepAwakePresentation()` path, so visibility changes can stay localized.
- `Tools Cat/KeepAwakePresentation.swift` already computes truthful status text, icon state, pending-state detection, and active-mode checks from `confirmedMode` plus `pendingAction`.
- `Tools Cat/KeepAwakeSessionModel.swift` already exposes the exact state distinctions this phase cares about: idle off, confirmed active modes, starting transitions, and stopping transitions.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` and `Tools CatTests/KeepAwakeMenuStateTests.swift` already give focused seams for controller visibility assertions and presentation-state assertions.

### Established Patterns
- Steady-state keep-awake UI only changes after the underlying power-controller outcome is confirmed.
- Transitional keep-awake feedback belongs in the disabled status row rather than in constantly changing action titles.
- Root-menu regressions are usually locked with controller-level XCTest coverage instead of heavy UI automation.
- The shipped menu stays compact and native; idle states collapse meaningless rows instead of explaining absence with extra chrome.

### Integration Points
- `renderKeepAwakePresentation()` is the main place where row state, enablement, and hidden/visible behavior can be updated together.
- `keepAwakeActionItems` currently assumes `keepAwakeOffItem` is always present, so planning should account for any helper or array changes needed when the stop row becomes conditional.
- Existing verification and validation docs for the timed keep-awake phase will need a small truth update because they currently encode the always-visible stop-row contract.

</code_context>

<deferred>
## Deferred Ideas

- Broader keep-awake section redesign or root-menu reordering.
- New keep-awake presets, shortcuts, notifications, or other convenience features.
- Any expansion of menu-bar automation scope beyond the focused regression and documentation updates needed to lock this visibility rule.

</deferred>

---

*Phase: 10-keep-awake-menu-truth*
*Context gathered: 2026-04-14*
