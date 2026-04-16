# Phase 14: Duration Management UI Polish - Research

**Researched:** 2026-04-16
**Domain:** native macOS list semantics and semantic action styling for the shipped keep-awake duration manager
**Confidence:** HIGH

<user_constraints>
## User Constraints

Planning boundaries come from [`14-CONTEXT.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/14-duration-management-ui-polish/14-CONTEXT.md), [`ROADMAP.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md), [`REQUIREMENTS.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md), and the Phase 13 shipped artifacts that already closed duration CRUD and root-menu truth.

### Locked Constraints For Planning
- Phase 14 is UI polish only. It must not reopen duration persistence, validation rules, sorting, add/edit/delete workflow, or live root-menu synchronization.
- The work should stay inside the existing `常亮时长` manager surface rather than expanding into broader WOL or menu redesign.
- The timed-duration area should lean harder on clearly native macOS list or table semantics instead of the current custom stacked `ScrollView` treatment.
- Edit actions should communicate safe modification intent through the app accent/theme color.
- Delete actions should continue to communicate destructive intent through red semantic styling.
- The result must stay compact, restrained, and obviously native to the rest of the app.

### Planning Discretion
- Whether the best native presentation is `List`, a table-like single-column list configuration, or another AppKit-backed list surface. The recommended starting point is `List`, not `Table`.
- The exact way tint is applied to edit affordances: button tint, foreground style, or a restrained combination that remains legible in both light and dark appearances.
- The exact verification additions needed beyond the existing manager-window smoke and session/controller regressions.

### Out Of Scope
- Reworking `KeepAwakeDurationStore`, `ManagedKeepAwakeDuration`, or duration sorting rules
- Reopening root keep-awake menu structure or dynamic menu behavior
- Changing the shared add/edit sheet flow introduced in Phase 13
- Introducing a third-party component library just to restyle the duration manager

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AWAKE-14 | User sees managed keep-awake durations inside a clearly native macOS list or table presentation | Replace the custom `ScrollView` + `LazyVStack` surface in `KeepAwakeDurationManagementView` with a native list-first presentation while preserving the manager layout and accessibility seams |
| AWAKE-15 | User sees the edit action styled with the app accent/theme color and the delete action styled with destructive red semantics | Reuse the existing AccentColor asset for edit affordances and keep delete on destructive red semantics through native SwiftUI button styling |
| AWAKE-16 | User can use the polished duration list without regressing existing add/edit/delete/sort/root-menu sync behavior | Keep behavior ownership in the existing session/store/controller seams and verify the polish through the existing regression slice plus the direct-launch manager smoke |
</phase_requirements>

## Summary

The phase should stay centered on [`KeepAwakeDurationManagementView.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationManagementView.swift). Phase 13 already delivered the correct behavior split: the view owns only presentation, [`KeepAwakeDurationManagementSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationManagementSessionModel.swift) owns CRUD state and validation, and [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/StatusBarController.swift) owns root-menu synchronization. Phase 14 should not move or duplicate any of those responsibilities.

The current timed-duration area still uses a custom `ScrollView` + `LazyVStack` with manually drawn rounded row surfaces. That shipped acceptably in v1.3, but it does not satisfy the new locked preference for unmistakably native list semantics. The most direct refinement is to replace `populatedListContent` with a native single-column `List` presentation first, not `Table`, because this manager is compact, action-oriented, and not truly tabular.

Action styling can stay native without adding bespoke chrome. The app already has a shared accent color in [`Assets.xcassets/AccentColor.colorset/Contents.json`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/Assets.xcassets/AccentColor.colorset/Contents.json), so the edit action can adopt standard SwiftUI accent/tint semantics. Delete should remain a `role: .destructive` action or equivalent native red semantic button treatment. The important constraint is that the two actions become distinguishable at a glance without making the manager feel noisy.

Verification is already close to complete. The existing direct-launch smoke for `testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface` and the session/controller regression slice already prove most behavioral truth. Phase 14 should extend that evidence only enough to lock the new list semantics and action styling rather than building a new harness.

**Primary recommendation:** plan one focused implementation pass in `KeepAwakeDurationManagementView.swift` that converts the timed-duration area to a native `List`, adds semantic tinting for edit/delete affordances, preserves accessibility seams, and updates the existing manager-window smoke plus any minimal helper assertions needed for the new native list surface.

## Project Constraints

- Stay inside the existing AppKit + SwiftUI stack and native macOS visual language.
- Keep runtime copy Chinese and implementation types/APIs English.
- Preserve the existing compact single-window manager structure.
- Prefer native control semantics over custom-drawn ornament.
- Keep planning and execution scoped to UI polish; do not reopen shipped data or controller behavior.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS SDK 26.2 via Xcode 26.2 | native list presentation and semantic button styling | already used across the shipped duration manager and existing utility windows |
| AppKit `NSWindowController` | macOS SDK 26.2 via Xcode 26.2 | retained ownership of the duration manager window | already shipped in Phase 13 and should remain unchanged |
| XCTest + XCUITest | Xcode 26.2 | session/controller regressions and direct-launch manager smoke | already present and already proving the current duration manager behavior |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `KeepAwakeDurationManagementSessionModel` | local repo seam | preserve behavior ownership while the view changes | always; do not migrate CRUD logic into the view layer |
| `KeepAwakeDurationManagementPresentation` | local repo seam | reuse existing copy and form labels | when keeping polish changes text-light and consistent |
| `AccentColor.colorset` | local repo asset | edit-action theme tint | when expressing safe primary modification intent |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| native `List` | native `Table` | more obviously tabular, but heavier than necessary for a compact single-column manager with inline actions |
| semantic tinting on current custom row stack | keep current `ScrollView` and only recolor buttons | would improve actions, but still miss the locked list-semantics goal |
| stronger custom cards/panels | more bespoke chrome and ornament | increases visual weight and maintenance cost while moving away from the app’s restrained native direction |

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── KeepAwakeDurationManagementView.swift
├── KeepAwakeDurationManagementSessionModel.swift
├── KeepAwakeDurationManagementPresentation.swift
└── StatusBarController.swift
```

### Pattern 1: Native List Presentation Inside Existing Manager Shell
Keep the current title row, add button, empty state, and shared form sheet, but swap the populated timed-duration body to a native list-oriented view rather than a custom stacked scroll region.

### Pattern 2: Behavior Stays In Existing Session/Controller Seams
The view can change list/container structure and button styling, but all add/edit/delete/sort/menu-sync behavior should stay in the session model and status controller as already shipped.

### Pattern 3: Semantic Styling Through Native Control APIs
Use native tint/accent semantics for edit and destructive semantics for delete. This keeps intent clear while remaining visually aligned with other macOS controls.

## Existing Code Insights

### Reusable Assets
- [`KeepAwakeDurationManagementView.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationManagementView.swift): already owns `populatedListContent`, the row type, the shared sheet, and the existing accessibility markers.
- [`KeepAwakeDurationManagementSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationManagementSessionModel.swift): already owns add, edit, delete, validation, and reload behavior; no behavior changes should be planned here unless a view wiring seam requires it.
- [`Tools_CatUITests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift): already contains the seeded manager-window smoke that can lock the updated list/action semantics.
- [`AccentColor.colorset/Contents.json`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/Assets.xcassets/AccentColor.colorset/Contents.json): already defines the app accent colors and should be reused rather than inventing a new edit tint.

### Integration Points
- `populatedListContent` and `KeepAwakeDurationRow` are the primary implementation seam for native list semantics and action styling.
- Accessibility identifiers like `keep-awake-duration-list-surface`, `keep-awake-duration-list`, and row-level identifiers should be preserved or replaced with equally stable seams.
- The existing direct-launch manager smoke is the lightest-weight place to prove the polished list still renders and the add flow still overlays correctly.

## Risks And Guardrails

- **Risk:** swapping to a native list disturbs the compact manager layout or hides the shared sheet context.
  - **Guardrail:** keep the current outer layout and constrain the list change to the populated timed-duration region.
- **Risk:** semantic button tinting becomes too flashy or inconsistent with macOS defaults.
  - **Guardrail:** prefer restrained native button styling and rely on tint/role semantics instead of custom decorations.
- **Risk:** UI polish accidentally reopens CRUD truth or root-menu synchronization.
  - **Guardrail:** keep behavior logic out of scope and preserve the already-passing session/controller regression slice.

## Validation Architecture

Phase 14 does not need a new verification harness. It should reuse the existing manager/session/menu truth layers and tighten only the assertions needed for native list semantics and semantic actions.

Recommended validation stack:
- Direct-launch manager smoke: `Tools_CatUITests.testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface`
- Session behavior regression: `KeepAwakeDurationManagementSessionModelTests`
- Keep-awake menu truth regressions: `StatusBarControllerKeepAwakeMenuTests` and `StatusBarControllerMenuPolishTests`

Recommended quick regression command:
`xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'`

Observed baseline:
- The focused regression slice passed on 2026-04-16 with 24 tests and 0 failures.

## Recommended Phase Split

1. `14-01`: Convert the populated timed-duration area to a native macOS list presentation while preserving the manager shell and accessibility seams.
2. `14-02`: Add semantic edit/delete styling and tighten the existing regression coverage for the polished manager surface.

---

*Phase: 14-duration-management-ui-polish*
*Research completed: 2026-04-16*
