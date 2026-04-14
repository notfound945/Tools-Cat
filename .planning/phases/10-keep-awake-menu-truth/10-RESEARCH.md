# Phase 10: Keep-Awake Menu Truth - Research

**Researched:** 2026-04-14
**Domain:** AppKit menu-state truth for keep-awake controls in a macOS menu-bar utility
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** When `confirmedMode` is `.off` and `pendingAction` is `nil`, the root menu must omit `关闭常亮`.
- **D-02:** Hiding the idle stop row must not add a placeholder row or new idle explanatory copy.
- **D-03:** The shipped start-row set and order remain `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`.
- **D-04:** Active `.indefinite` and `.timed` sessions must still expose exactly one direct `关闭常亮` row.
- **D-05:** While `.stopping` is pending, the stop row should remain visible but disabled with the rest of the keep-awake action group.
- **D-06:** Starting from `.off` must not surface `关闭常亮` early; startup feedback stays in the status row until an active mode is confirmed.
- **D-07:** Countdown, checkmark, icon, and failure-message semantics from earlier keep-awake phases remain locked.
- **D-08:** This phase should prefer focused controller/presentation regression updates over a broad new menu test surface.
- **D-09:** Validation and verification docs for this phase must state the idle-versus-active stop-row contract explicitly.

### the agent's Discretion
- Whether the visibility rule lives in `KeepAwakePresentation` or `StatusBarController`, as long as it derives from confirmed state plus pending action.
- Whether to extend the existing keep-awake test files or add one narrow new regression file.
- Exact wording and evidence layout in the Phase 10 validation contract.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MENU-01 | Idle menu omits `关闭常亮` when keep-awake is off and no transition is pending | Requires a visibility rule keyed off confirmed keep-awake state rather than a permanently inserted stop row |
| MENU-02 | Active or currently stopping keep-awake still exposes a direct `关闭常亮` action | Requires preserving one direct stop row for active and stopping states |
| MENU-03 | Visible keep-awake rows stay truthful without losing the existing start rows or truthful status feedback | Requires a low-blast-radius change that preserves row order, countdown status behavior, and compact root-menu structure |

</phase_requirements>

## Summary

The current implementation already has the correct state signals; the problem is only how the menu renders them. `KeepAwakeSessionModel` distinguishes `.off`, `.indefinite`, `.timed`, startup transitions, and `.stopping`. `KeepAwakePresentation` already centralizes the keep-awake UI contract for icon state, active-selection state, pending status copy, and tooltip copy. `StatusBarController` then renders that presentation into one fixed menu group. The only misleading part is that `keepAwakeOffItem` is created once in `configure()` and never hidden, so the idle menu always advertises a stop action even when there is nothing to stop.

The lowest-risk implementation is not to restructure the menu. Instead, keep the existing six-item group in memory and toggle the stop row’s `isHidden` flag from the same render pass that already updates checkmarks, enablement, tooltip, and status text. This preserves menu ordering, avoids insert/remove churn around separators, and leaves the broader Phase 5 compact-menu structure untouched. It also means the state machine does not need to change at all; Phase 10 is a presentation fix, not a new session-mode feature.

The planning-critical nuance is startup versus replacement. When keep-awake is starting from `.off`, `关闭常亮` should remain hidden because no active session exists yet and the whole group is pending anyway. But when a new mode is starting while a timed or indefinite session is already active, the confirmed mode is still active until the power-controller result lands, so the direct stop row should remain visible (though disabled during the pending transition). That gives a precise visibility rule:

`show stop row if confirmedMode != .off OR pendingAction == .stopping`

Everything else can stay as-is.

**Primary recommendation:** implement stop-row visibility as a presentation-level boolean and let `StatusBarController` apply it with `keepAwakeOffItem.isHidden`. Then expand the existing keep-awake controller/presentation tests and create a Phase 10 validation contract that names the new visibility states explicitly.

## Current Implementation Inventory

| Area | Current File | What Exists Today | Impact On Phase 10 |
|------|--------------|-------------------|--------------------|
| Authoritative keep-awake state | `Tools Cat/KeepAwakeSessionModel.swift` | `.off`, `.indefinite`, `.timed`, `pendingAction`, failure messages, countdown clock | No session-model redesign needed |
| Presentation contract | `Tools Cat/KeepAwakePresentation.swift` | Active preset, status text, icon, tooltip, pending detection | Natural home for a `showsStopAction` rule |
| Menu render path | `Tools Cat/StatusBarController.swift` | One centralized `renderKeepAwakePresentation()` method updates row state, enablement, status row, and icon | Best place to apply `keepAwakeOffItem.isHidden` |
| Existing keep-awake menu tests | `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` | Locks today’s six-item action array and status-row behavior | Must be updated because Phase 10 intentionally changes idle visible rows |
| Existing presentation tests | `Tools CatTests/KeepAwakeMenuStateTests.swift` | Locks pending, countdown, and failure semantics | Best place to lock `showsStopAction` semantics |
| Existing compact-menu tests | `Tools CatTests/StatusBarControllerMenuPolishTests.swift` | Locks idle status-row collapse and menu grouping | Good safety net to prove the broader root menu stays compact |

## Option Comparison

| Option | What Changes | Pros | Cons | Recommendation |
|--------|--------------|------|------|----------------|
| A. Physically insert/remove the stop row | Rebuild the menu structure depending on state | User-visible row count is exact | Higher blast radius around menu ordering, indices, and separators | Reject |
| B. Keep the row but toggle `isHidden` from the render path | Existing menu structure stays in place; only visibility changes | Lowest churn, preserves grouping, easy to test, no separator changes | Tests must stop assuming every action item is always visible | Recommended |
| C. Leave the row visible and only disable it when idle | Minimal code change | Stable index positions | Fails `MENU-01` because the idle menu still advertises a meaningless action | Reject |

## Recommended Planning Shape

### Plan 10-01: Rework runtime visibility
- Add a presentation-level visibility signal for the stop row.
- Update `StatusBarController.renderKeepAwakePresentation()` to hide `keepAwakeOffItem` when the new signal is false.
- Preserve row order, countdown/status-row semantics, and the existing pending-action disable behavior.

### Plan 10-02: Lock regressions and validation
- Update the keep-awake controller tests so they assert visible rows by state instead of assuming the stop row is always visible.
- Add presentation tests that prove the visibility rule for idle, startup-from-off, replacement-while-active, and stopping.
- Publish `10-VALIDATION.md` as the phase-specific validation contract for the new truth rule.

## Architecture Patterns

### Pattern 1: Presentation-Derived Visibility
The repo already treats `KeepAwakePresentation` as the view-facing contract. Extending it with `showsStopAction` keeps the truth rule close to the existing status/icon logic and lets tests assert state semantics without spinning up the full controller.

### Pattern 2: Render-Path Toggle Instead Of Menu Rebuild
`StatusBarController.renderKeepAwakePresentation()` already owns state, enablement, status text, and button icon updates. Applying `keepAwakeOffItem.isHidden = !presentation.showsStopAction` there keeps the change local and avoids churn in `configure()`, separator placement, or WOL menu wiring.

### Pattern 3: Visible-Title Assertions Instead Of Raw Item Arrays
Several current controller tests assume the keep-awake action array is always six visible rows. Phase 10 coverage should shift to one of:
- explicit `keepAwakeOffItem.isHidden` assertions, or
- visible-title lists that filter hidden items

That keeps tests aligned with the user-visible contract instead of the private in-memory menu inventory.

## Common Pitfalls

### Pitfall 1: Treating startup-from-off and replacement-while-active as the same case
If the implementation hides the stop row for every `starting*` pending action, replacement while active will incorrectly lose the direct stop path. The rule should key off `confirmedMode`, not only `pendingAction`.

### Pitfall 2: Rebuilding the menu instead of hiding one row
Insert/remove logic creates unnecessary churn around indices, separators, and test helpers. The menu already has the right structure.

### Pitfall 3: Breaking compact-menu expectations by adding new idle explanatory rows
The milestone is a truth fix, not a copywriting pass. Idle state should simply omit the stop row.

### Pitfall 4: Updating only controller tests and forgetting the presentation seam
Without a presentation-level regression, future refactors can accidentally reintroduce false stop-row visibility even if the controller stays mostly unchanged.

## Code Examples

### Recommended visibility rule
```swift
var showsStopAction: Bool {
    if pendingAction == .stopping {
        return true
    }

    switch confirmedMode {
    case .off:
        return false
    case .indefinite, .timed:
        return true
    }
}
```

### Recommended controller application
```swift
keepAwakeOffItem.isHidden = !presentation.showsStopAction
keepAwakeActionItems.forEach { $0.isEnabled = !presentation.isPending }
```

### Recommended visible-row assertion pattern
```swift
let visibleTitles = keepAwakeActionItems(of: controller)
    .filter { !$0.isHidden }
    .map(\\.title)
```

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest on macOS |
| Config file | `Tools Cat.xcodeproj/project.pbxproj` |
| Quick run command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MENU-01 | Idle `.off` with no pending action omits `关闭常亮` | unit/controller | targeted `StatusBarControllerKeepAwakeMenuTests` idle-visibility test | ✅ existing file to extend |
| MENU-02 | Active or `.stopping` states keep one direct stop row | unit/controller | targeted `StatusBarControllerKeepAwakeMenuTests` active/stopping visibility tests | ✅ existing file to extend |
| MENU-03 | Start rows remain available and truthful, and status/countdown behavior does not regress | unit/controller | `KeepAwakeMenuStateTests`, `StatusBarControllerKeepAwakeMenuTests`, `StatusBarControllerMenuPolishTests` slice above | ✅ existing files to extend |

### Concrete Verification Checkpoints
1. `Tools Cat/KeepAwakePresentation.swift` contains a stop-row visibility property derived from `confirmedMode` plus `pendingAction`.
2. `Tools Cat/StatusBarController.swift` sets `keepAwakeOffItem.isHidden` from the presentation contract.
3. `Tools CatTests/KeepAwakeMenuStateTests.swift` proves idle-off and stopping/startup visibility semantics.
4. `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` proves:
   - idle menus hide `关闭常亮`
   - active menus show `关闭常亮`
   - stopping keeps it visible but disabled
   - countdown/status copy stays truthful
5. `Tools CatTests/StatusBarControllerMenuPolishTests.swift` still proves the compact menu grouping and idle status-row collapse.

## Research Verdict

Phase 10 is a presentation-truth correction, not a menu redesign. The existing keep-awake state machine already has the information needed to render truthful stop-row visibility. The best plan is to add one presentation-level visibility signal, apply it by hiding the existing stop row in the controller render path, then lock the rule with the repo’s current keep-awake test seams and a dedicated Phase 10 validation contract.
