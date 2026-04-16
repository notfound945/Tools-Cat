# Phase 15: Device Library UI Parity - Research

**Researched:** 2026-04-16
**Domain:** native macOS device-library parity with the shipped duration-management surface
**Confidence:** HIGH

<user_constraints>
## User Constraints

Planning boundaries come from [15-CONTEXT.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/15-device-library-ui-parity/15-CONTEXT.md), [ROADMAP.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md), [REQUIREMENTS.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md), and the shipped Phase 2 plus Phase 14 outcomes.

### Locked Constraints For Planning
- Phase 15 is presentation-only. It must not reopen saved-device persistence, validation rules, delete confirmation, reorder truth, or wake/menu behavior.
- The device-library manager must remain a dedicated native utility window.
- The normal populated device-library surface should move from the current `ScrollView` + `LazyVStack` treatment to a clearly native macOS list-first presentation.
- Add and edit must be presented through the same list-local shared sheet pattern already shipped in the duration manager.
- Edit must use accent semantics and delete must use destructive red semantics, matching the duration manager at a glance.
- The existing explicit reorder mode remains in scope only as a preserved behavior, not as a redesign target.

### Planning Discretion
- Whether the best normal-mode native presentation is `List` plus a lightweight heading/count shell or a slightly different single-column list wrapper. `List` is the recommended baseline because the duration manager already uses it successfully.
- Whether the device list should add a lightweight section caption or count label to mirror the duration manager more directly.
- The minimum set of test and accessibility seam adjustments needed to keep the device-library smoke deterministic after the list/sheet refactor.

### Out Of Scope
- Reworking `SavedDeviceLibraryStore`, `SavedDevice`, or device validation rules
- Redesigning reorder mode beyond keeping it intact
- Changing the WOL sender window or root wake menu
- Adding new device metadata, discovery, import/export, or search/filtering
- Introducing a third-party UI library for the manager surface

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEVS-06 | User sees saved WOL devices inside a clearly native macOS list surface | Replace the normal-mode custom stacked surface in `DeviceLibraryView` with a native `List` while preserving row identity seams and the dedicated manager shell |
| DEVS-07 | User can add or edit a saved WOL device through a compact in-place presentation matching duration manager | Replace the `screen`-driven full-view swap with a shared sheet over the list and keep add/edit on one retained manager surface |
| DEVS-08 | User sees accent/destructive semantics for edit/delete matching duration manager | Reuse the same accent-color foreground semantics for `编辑` and keep `删除` destructive through native SwiftUI roles/styles |
| DEVS-09 | User can use the polished device-library manager without regressing add/edit/delete/reorder/direct-launch behavior | Preserve CRUD ownership in `DeviceLibrarySessionModel`, preserve the existing direct-launch UI smoke seams, and keep the dedicated reorder path behaviorally intact |
</phase_requirements>

## Summary

The phase should stay centered on [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift) and [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift). The current view still uses a hard `switch session.screen` split between list and form, so the list disappears entirely during add/edit. That is the main parity gap relative to the duration manager and the main reason this phase needs to touch both the view and session model.

The strongest reference is [KeepAwakeDurationManagementView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationManagementView.swift). It already demonstrates the exact retained-shell pattern the user wants: one compact manager surface, native `List` for populated rows, shared `.sheet(...)` for add/edit, and restrained semantic styling where `编辑` uses accent semantics and `删除` stays destructive.

The current device-library reorder path already uses `List` and `.onMove`, so the parity work should avoid destabilizing that branch. The normal browse branch is the part that needs to move to `List`. A good target shape is:
- keep the outer title/action row and empty state intact
- use the duration manager's `List`-first feel for normal populated browsing
- keep reorder as a separate `List` path with move handling
- present add/edit via `sheet(isPresented:)` driven by a form-mode property rather than a full-screen route enum

Existing verification seams are already strong. [Tools_CatUITests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift) covers seeded direct-launch, empty state, and add flow. [DeviceLibrarySessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/DeviceLibrarySessionModelTests.swift) already proves add/edit/delete/reorder truth. Phase 15 should reuse those seams instead of creating a new test harness.

**Primary recommendation:** split execution into two plans. First, refactor the device-library manager to use a native normal-mode `List` plus a shared sheet without regressing session truth. Second, add semantic action styling and tighten the focused regression slice so the polished surface remains trustworthy.

## Project Constraints

- Stay inside the existing AppKit + SwiftUI stack and native macOS visual language.
- Keep runtime copy Chinese and implementation types/APIs English.
- Preserve the compact utility-window feel of the device-library manager.
- Prefer native control semantics and existing app accent color over custom visual chrome.
- Keep execution narrowly scoped to UI parity, not device-management feature expansion.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS SDK 26.2 via Xcode 26.2 | native list presentation, sheet presentation, and semantic action styling | already used across the shipped manager surfaces |
| AppKit `NSWindowController` | macOS SDK 26.2 via Xcode 26.2 | retained ownership of the device-library utility window | already shipped in Phase 2 and should remain unchanged |
| XCTest + XCUITest | Xcode 26.2 | session regressions and direct-launch manager smoke | already present and already proving device-library truth |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `DeviceLibrarySessionModel` | local repo seam | preserve CRUD, validation, delete, and reorder truth while the UI changes | always; do not move state logic into the view |
| `DeviceLibraryManagementPresentation` | local repo seam | keep user-facing copy stable through the parity refactor | when reusing the existing strings for titles, buttons, and delete confirmation |
| `AccentColor.colorset` | local repo asset | semantic edit-action accent color | when making the `编辑` affordance visually match the duration manager |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| native `List` for normal browse mode | keep the current `ScrollView` and only recolor buttons | would miss the locked list-parity goal |
| shared list-local sheet | keep the `screen` route and full-view form | directly contradicts the user decision and the duration-manager reference |
| redesign reorder together with browse mode | merge reorder into always-editable list | reopens shipped behavior and adds unnecessary risk for a presentation-only phase |

## Architecture Patterns

### Pattern 1: Retained Manager Shell With List-Local Sheet
Keep one compact `设备库` manager surface alive at all times. Add and edit should be transient sheet content above the list, not a separate route that replaces the list.

### Pattern 2: Session Owns Truth, View Owns Presentation
`DeviceLibrarySessionModel` should continue to own draft fields, validation, save/delete/reorder calls, and mode transitions. The view should only reinterpret that state as a sheet-backed presentation.

### Pattern 3: Separate Browse And Reorder Paths
Normal browsing can move to a native `List` styled like the duration manager, while reorder remains its own explicit `List` + `.onMove` path. This preserves the deliberate sorting-mode guardrail established in Phase 2.

## Existing Code Insights

### Reusable Assets
- [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift): already owns the manager shell, empty state, delete alert, row layout, and accessibility identifiers.
- [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift): already owns add, edit, delete, validation, and reorder truth; it only needs a presentation-shape refactor.
- [KeepAwakeDurationManagementView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationManagementView.swift): direct parity reference for shared-sheet presentation, native `List`, and semantic edit/delete styling.
- [DeviceLibrarySessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/DeviceLibrarySessionModelTests.swift): current truth guard for invalid save, add, edit, delete confirmation, and reorder persistence.
- [Tools_CatUITests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift): direct-launch device-library smoke that can lock the sheet-over-list behavior and native list surface.

### Integration Points
- `DeviceLibraryView.body` currently branches on `switch session.screen`; that route split is the primary seam to remove.
- `DeviceLibrarySessionModel.currentFormMode` already exists and can be reused as the logical source of truth for sheet content after the route refactor.
- `populatedListContent` is the view seam for replacing the custom normal-mode stack while leaving the reorder path intact.
- The existing direct-launch test paths already activate the manager through `--ui-test-open-device-library`, so verification can stay focused and cheap.

## Risks And Guardrails

- **Risk:** moving to a sheet-backed form breaks validation state or save/cancel flow.
  - **Guardrail:** preserve `currentFormMode`, draft fields, and `cancelForm`/`saveDraft` ownership inside `DeviceLibrarySessionModel`; only change how the view presents them.
- **Risk:** list parity work accidentally destabilizes reorder mode.
  - **Guardrail:** keep reorder as its own branch and avoid rewriting `moveDevices` behavior or `.onMove` wiring.
- **Risk:** native list styling or accent semantics become louder than the app's utility-window design.
  - **Guardrail:** mirror the shipped duration manager's restrained list and button styling instead of inventing a new visual language.
- **Risk:** the UI refactor regresses direct-launch management flows.
  - **Guardrail:** extend the existing direct-launch smoke rather than relying on manual visual inspection alone.

## Validation Architecture

Phase 15 can reuse the existing device-library regression stack. It needs structural UI assertions for the new list/sheet presentation and the current session tests to prove truth remains intact.

Recommended validation stack:
- Direct-launch manager smoke: `Tools_CatUITests.testLaunchWithSeededDeviceLibraryShowsManagementWindow`
- Direct-launch populated-list smoke: `Tools_CatUITests.testLaunchWithSeededDeviceLibraryShowsManagementListSurface`
- Empty-state smoke: `Tools_CatUITests.testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState`
- Session truth regressions: `DeviceLibrarySessionModelTests`
- Presentation string seam: `DeviceLibraryManagementPresentationTests`

Recommended quick regression command:
`xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'`

Recommended full regression command:
`xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'`

Observed baseline:
- The direct-launch device-library smoke and session tests already exist in the repo before Phase 15 planning, so no new harness bootstrap is required.

## Recommended Phase Split

1. `15-01`: Refactor the device-library manager to use a native normal-mode list and a shared sheet over the retained list surface while preserving session truth and reorder mode.
2. `15-02`: Apply semantic edit/delete styling and tighten focused UI/session regressions around the polished surface.

---

*Phase: 15-device-library-ui-parity*
*Research completed: 2026-04-16*
