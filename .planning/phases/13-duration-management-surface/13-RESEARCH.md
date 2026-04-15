# Phase 13: Duration Management Surface - Research

**Researched:** 2026-04-15
**Domain:** native management surface for persisted keep-awake durations in a local-first macOS menu bar app
**Confidence:** HIGH

<user_constraints>
## User Constraints

No `13-CONTEXT.md` exists. Planning boundaries come from [`ROADMAP.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md), [`REQUIREMENTS.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md), [`STATE.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/STATE.md), the shipped keep-awake decisions in [`04-CONTEXT.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/04-timed-keep-awake/04-CONTEXT.md), and the Phase 12 persistence decisions in [`12-RESEARCH.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/12-duration-preset-persistence/12-RESEARCH.md) plus [`12-VERIFICATION.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/12-duration-preset-persistence/12-VERIFICATION.md).

### Locked Constraints For Planning
- Phase 13 must ship a real management surface for timed keep-awake durations; this is where `AWAKE-06` actually closes.
- The management surface must allow add, edit, and delete for timed durations only.
- `无限常亮` is not managed data. It stays fixed, always available, undeletable, and outside the management list.
- The timed duration list is already persisted and validated by `KeepAwakeDurationStore`; Phase 13 must consume that seam instead of inventing a second storage path.
- Timed durations remain sorted by canonical duration, not by manual drag order.
- The product stays native AppKit plus SwiftUI, local-first, and small in scope.
- Phase 13 must not pull Phase 14’s dynamic root-menu rendering forward. The existing fixed keep-awake rows stay in place for now.

### Planning Discretion
- Whether the management surface is a dedicated window or another native container. The repo’s existing pattern strongly favors a small dedicated window.
- The exact form input shape for custom durations, as long as it stays native and small. A single minutes field is the simplest truthful choice.
- The exact placement and copy of the menu item that opens the management surface.
- Whether to test the surface through direct app launch, status-menu entry dispatch, or both. Existing repo patterns support both and Phase 13 should use both at light weight.

### Out Of Scope
- Dynamic keep-awake root-menu rendering from the managed duration list
- Editing or deleting `无限常亮`
- One-off unsaved durations
- Custom labels or notes for timed durations
- Manual drag ordering of timed durations
- Cloud sync, import/export, or profile-specific duration lists
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AWAKE-06 | User can open a duration-management surface seeded with `15 分钟`, `30 分钟`, `1 小时`, and `2 小时` | Open a dedicated management window backed directly by the shared store; first-load seed behavior is already supplied by Phase 12 |
| AWAKE-07 | User can add a custom managed keep-awake duration | Use a small add form that accepts whole minutes, converts to canonical seconds, and persists through `KeepAwakeDurationStore.addDuration(seconds:)` |
| AWAKE-08 | User can edit an existing managed keep-awake duration | Reuse the same form in edit mode while preserving row identity via `updateDuration(id:seconds:)` |
| AWAKE-09 | User can delete a managed keep-awake duration while `无限常亮` remains fixed and undeletable | Only timed rows appear in the manager, and deletion requires explicit confirmation before calling `deleteDuration(id:)` |
</phase_requirements>

## Summary

The repo already contains the right implementation pattern for Phase 13. [`DeviceLibrarySessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift), [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift), and [`DeviceLibraryWindow.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryWindow.swift) form a clean native template: a shared store-backed `ObservableObject` session model, a SwiftUI list/form surface, and an `NSWindowController` that owns presentation lifetime. Phase 13 should copy that shape instead of inventing a menu-embedded form or a second persistence owner.

The key scope guard is keeping Phase 14 out of this phase. The duration manager should mutate the shared timed-duration list and reflect sorted CRUD results inside its own list immediately, but it should not attempt to render root keep-awake menu rows from that list yet. The existing fixed root rows can remain as a transitional bridge until Phase 14 swaps in dynamic rendering.

The simplest truthful input model is whole minutes in the UI, converted once to canonical seconds before store mutation. That keeps the form human-readable, still allows `90` minutes to become `1 小时 30 分钟`, and avoids exposing seconds-level precision the user never asked for. Validation should stay layered: blank or non-numeric draft input is blocked in the session model, and canonical duplicate or non-positive checks remain enforced by `KeepAwakeDurationStore`.

**Primary recommendation:** Build `KeepAwakeDurationManagementSessionModel` plus a small `KeepAwakeDurationManagementWindow` and `KeepAwakeDurationManagementView`, wire the window into `AppDelegate` and `StatusBarController` through one new menu item, and cover the result with session-model unit tests, menu-entry tests, and one direct-launch UI smoke on the management window.

## Project Constraints

- Stay inside the existing native AppKit/SwiftUI shell.
- Keep runtime copy Chinese and APIs/type names English.
- Prefer one main type per file and small focused methods.
- Reuse the shared `KeepAwakeDurationStore`; do not add another repository or defaults key.
- Preserve truthful state and avoid optimistic UI claims that bypass the store.
- `workflow.nyquist_validation` is enabled, so planning must include both automated coverage and any explicit manual-only boundary.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS SDK 26.2 via Xcode 26.2 | render the duration management list and form | already used for WOL and device-library surfaces |
| AppKit `NSWindowController` | macOS SDK 26.2 via Xcode 26.2 | own a reusable management window outside the menu | matches existing `DeviceLibraryWindow` pattern |
| Combine `ObservableObject` / `@Published` | macOS SDK 26.2 via Xcode 26.2 | session state for list, form, and delete confirmation | matches existing session-model architecture |
| Existing `KeepAwakeDurationStore` | local repo seam | canonical persistence, sort order, duplicate rejection | Phase 12 already established this as the only timed-duration mutation boundary |
| XCTest + XCUITest | Xcode 26.2 | session behavior, menu entry, and direct-launch UI smoke | repo already ships both unit and UI test harnesses |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Existing launch-argument defaults-suite seam in [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift#L68) | local repo seam | deterministic store contents during UI tests | use for direct window-launch smoke without special test-only production code |
| Existing status-menu entry pattern in [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/StatusBarController.swift#L43) and [`StatusBarControllerEntryFlowTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/StatusBarControllerEntryFlowTests.swift#L6) | local repo seam | wiring a new management menu row through an `onOpen...` callback | copy for the duration-management entry |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| dedicated management window | `NSAlert` or inline menu editing | smaller code footprint, but poor CRUD ergonomics and inconsistent with repo patterns |
| one minutes field | separate hours and minutes controls | more explicit, but more UI state and parsing complexity for little user benefit |
| hiding `无限常亮` entirely from the manager | showing it as a disabled first row | could reinforce the rule visually, but risks implying it participates in managed data; omission is cleaner |
| full root-menu update in Phase 13 | leave fixed rows until Phase 14 | dynamic rendering would reduce temporary mismatch but would reopen the next phase’s scope prematurely |

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── KeepAwakeDurationManagementPresentation.swift
├── KeepAwakeDurationManagementSessionModel.swift
├── KeepAwakeDurationManagementView.swift
├── KeepAwakeDurationManagementWindow.swift
├── AppDelegate.swift
├── StatusBarController.swift
└── KeepAwakeDurationStore.swift
```

### Pattern 1: Session-Owned List/Form/Delete Flow
Use the same screen-state pattern as the device library: list state, add/edit form state, pending delete state, and store-backed reload/save/delete methods all owned by one `ObservableObject`.

Recommended state shape:
- `durations: [ManagedKeepAwakeDuration]`
- `screen: list | form(add|edit)`
- `draftMinutesText: String`
- `pendingDeleteDuration: ManagedKeepAwakeDuration?`
- `validationMessage: String?`
- `saveErrorMessage: String?`

### Pattern 2: Minutes In, Seconds Out
The UI should accept whole minutes, trim whitespace, parse a positive integer, then convert to `seconds = minutes * 60` exactly once before calling the store. This keeps the form small while preserving the store’s canonical `durationSeconds` identity.

### Pattern 3: Direct Launch For UI Smoke
The repo’s UI tests already open windows directly with launch arguments and a temporary defaults suite. Phase 13 should add one new launch argument that opens the duration manager so XCUITest can prove the seeded list and form controls render without depending on menu bar automation.

### Pattern 4: Status Menu Entry Mirrors Device-Library Entry
`StatusBarController` already dispatches menu entry clicks via lightweight callbacks (`onOpenWOL`, `onOpenDeviceLibrary`). Phase 13 should add one sibling callback and one native menu row instead of teaching the controller to own another window directly.

## Existing Code Insights

### Reusable Assets
- [`KeepAwakeDurationStore.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationStore.swift): already provides sorted load, add, edit, delete, and duplicate validation.
- [`ManagedKeepAwakeDuration.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/ManagedKeepAwakeDuration.swift): already provides stable identity plus derived Chinese menu titles.
- [`DeviceLibrarySessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift): direct template for list/form/delete state and error handling.
- [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift): direct template for a compact CRUD surface with empty state, form state, and delete confirmation.
- [`DeviceLibraryWindow.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryWindow.swift): reusable window ownership pattern.
- [`Tools_CatUITests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift): existing direct-launch UI smoke harness.

### Integration Points
- `AppDelegate` must own one shared duration-management session and one reusable management window.
- `StatusBarController` needs a new menu item and callback to open the window.
- UI tests can prime `managed_keep_awake_durations` directly in the per-test defaults suite when custom seeded rows are needed.
- Phase 14 will later consume the same store for dynamic root-menu rendering, so Phase 13 should avoid duplicating sort or formatting logic in the view layer.

## Risks And Guardrails

- **Risk:** deleting a timed duration in the manager does not immediately remove the fixed root row.
  - **Guardrail:** document this explicitly as future Phase 14 behavior and avoid claiming the root menu is managed yet.
- **Risk:** user-facing validation diverges from store truth.
  - **Guardrail:** map store errors into Chinese messages, but keep the final duplicate/non-positive decision inside `KeepAwakeDurationStore`.
- **Risk:** adding a new window path without launch-argument coverage causes UI regressions.
  - **Guardrail:** add one direct-launch XCUITest smoke for the duration manager window.

## Recommended Phase Split

1. `13-01`: Build the duration-management session model and validation contract on top of the shared store.
2. `13-02`: Add the native duration-management window, status-menu entry, and direct-launch/UI/controller integration coverage.

---

*Phase: 13-duration-management-surface*
*Research completed: 2026-04-15*
