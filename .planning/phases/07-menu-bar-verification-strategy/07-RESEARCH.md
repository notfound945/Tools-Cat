# Phase 07: Menu-Bar Verification Strategy - Research

**Researched:** 2026-04-13
**Domain:** Verification strategy for a macOS `LSUIElement` menu-bar app with AppKit menu ownership and direct-launch utility-window UI smoke
**Confidence:** HIGH

<user_constraints>
## User Constraints (inferred from current milestone context)

### Locked Decisions
- **D-01:** The phase must make the current menu-bar verification boundary explicit instead of implying live tray-click automation where none exists.
- **D-02:** The shipped wake surface remains `快速 WOL` plus `发送 WOL …`, with `管理 WOL 设备…` as the management entry point.
- **D-03:** The app remains an AppKit `NSStatusItem` utility with `LSUIElement = 1`; shell rewrites are out of scope.
- **D-04:** The phase should leave one durable regression slice maintainers can run without rediscovering which tests matter.
- **D-05:** Phase 8 owns the broader validation-debt cleanup; Phase 7 should only clarify tray-entry strategy and coverage boundaries.

### the agent's Discretion
- Whether to strengthen controller coverage with a dedicated test file or an extension of existing menu tests.
- Whether the stable regression slice should live in a script, a validation doc, or both.
- Exact wording for manual tray-entry UAT guidance.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AUTO-01 | Maintainer can identify exactly which wake and management entry flows are covered by automated regression tests | Requires an explicit coverage inventory tied to concrete test files and callback seams |
| AUTO-02 | Maintainer can see one explicit verification strategy for real menu-bar entry paths, whether via automation or documented non-automation coverage | Requires a plain-language statement of what is and is not proven automatically, plus an explicit manual tray checklist if live tray clicks stay manual |
| AUTO-03 | Maintainer can run a stable regression slice for polished wake and management surfaces without ambiguous assumptions about tray-click coverage | Requires one named command or script that runs the intended controller and UI smoke slice together |

</phase_requirements>

## Summary

The repo already has the right ingredients for a credible layered verification strategy, but they are currently spread across multiple files and still easy to over-read as stronger end-to-end coverage than they really provide. `StatusBarControllerMenuPolishTests.swift` and `StatusBarControllerWakeMenuTests.swift` prove menu structure, saved-device dispatch, and wake-state behavior at the controller seam. `Mac_OS_Swiss_KnifeUITests.swift` proves the WOL and device-library utility windows through launch arguments. `05-HUMAN-UAT.md` proves the live tray/menu/window feel by human inspection. What is missing is not raw test infrastructure; it is one explicit statement that these layers are different and one stable way to run the intended automated slice.

The planning-critical technical fact is that the app is still an `LSUIElement` status-bar utility and the current XCUITest path does not click the live tray icon. Instead, `AppDelegate.LaunchConfiguration` switches activation policy and opens retained utility windows directly from `--ui-test-open-wol-window` and `--ui-test-open-device-library`. That seam is useful and stable, but it only proves downstream surfaces after entry dispatch, not the tray click itself. Phase 7 therefore should not chase fake certainty. The clean solution is to strengthen lower-level callback coverage, keep live tray interaction explicit as manual if needed, and publish one stable regression slice that names those boundaries clearly.

**Primary recommendation:** choose a layered strategy instead of brittle fake end-to-end automation:

1. Add explicit controller tests for the root `发送 WOL …` and `管理 WOL 设备…` callback paths.
2. Publish one stable regression slice command or script that runs the controller suites plus the existing direct-launch UI smoke tests.
3. Update planning/verification docs so they say plainly that live tray clicking is manual coverage unless and until a separate automation harness exists.

## Current Coverage Inventory

| Layer | Current Artifact | What It Proves | What It Does Not Prove |
|------|------------------|----------------|-------------------------|
| Controller/menu logic | `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift` | Group ordering, idle collapse, wake-group structure, management-row placement | Live tray icon click and real AppKit menu interaction |
| Controller wake behavior | `Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests.swift` | Saved-device dispatch, wake disable states, persistent wake status | Real click on `NSStatusItem` and real window-opening rows |
| Utility-window UI smoke | `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | WOL and device-library windows render correctly when opened directly via launch seams | That those windows were reached by clicking the live tray rows |
| Human tray validation | `.planning/phases/05-native-menu-polish/05-HUMAN-UAT.md` | Real menu grouping and utility-window feel in the running app | Automated repeatability |

## Option Comparison

| Option | What Changes | Pros | Cons | Recommendation |
|--------|--------------|------|------|----------------|
| A. Try to automate real tray clicks end-to-end | Add a new live menu-bar harness around `NSStatusItem` interaction | Highest theoretical fidelity | No such harness exists in repo, likely brittle under `LSUIElement`, and easy to turn Phase 7 into infrastructure churn | Reject for this phase |
| B. Make the layered strategy explicit | Add entry-point controller tests, one regression script, and clear docs/UAT boundaries | Durable, truthful, matches current repo architecture, satisfies all three AUTO requirements | Live tray clicks remain manual | Recommended |
| C. Add synthetic launch-argument entry automation and call it tray coverage | Extend launch args to simulate entry dispatch | Easy to build | Misleading if presented as real tray-click proof | Reject unless it is clearly labeled as a lower-level seam |

## Recommended Planning Shape

### Plan Track 1: Lock Entry Dispatch Coverage
- Add explicit tests for `发送 WOL …` and `管理 WOL 设备…` callback dispatch.
- Keep this at the controller seam so it is fast and deterministic.

### Plan Track 2: Publish One Stable Regression Slice
- Add a shell script that runs the controller menu suites plus the direct-launch WOL/device-library UI smoke slice.
- Reference that script from a phase validation doc so maintainers see one canonical command.

### Plan Track 3: Rewrite Strategy Docs Around the Layered Truth
- Update current verification/validation docs to name the automation boundary explicitly.
- Make manual tray-entry checks concrete instead of implied.

## Architecture Patterns

### Pattern 1: Controller-Seam Entry Testing
Use `StatusBarController` with injected callbacks and in-memory stores/sessions, then trigger the menu item action directly. This proves entry dispatch without pretending the test clicked the live status-bar item.

### Pattern 2: Stable Slice Script
Run one deterministic test slice that combines:
- `StatusBarControllerMenuPolishTests`
- `StatusBarControllerWakeMenuTests`
- `StatusBarControllerKeepAwakeMenuTests`
- the new entry-flow tests
- the three existing direct-launch UI smoke tests

This should be a dedicated shell script rather than a long command buried in validation prose.

### Pattern 3: Manual Tray UAT as a First-Class Layer
If the live tray path remains manual, give it an explicit checklist tied to the exact root rows:
- open the tray
- click `发送 WOL …`
- click `管理 WOL 设备…`
- confirm the expected retained windows and grouping

## Common Pitfalls

### Pitfall 1: Conflating direct-launch UI smoke with tray-click coverage
The current UI tests open windows from launch arguments. They are useful, but they do not prove the live tray icon path.

### Pitfall 2: Adding fake automation terminology
Terms like “end-to-end menu-bar coverage” become misleading if the implementation only triggers lower-level seams.

### Pitfall 3: Letting the regression slice drift into the full suite
The phase needs one stable, fast, intention-revealing slice. If it becomes “run all tests,” maintainers lose the explicit strategy benefit.

### Pitfall 4: Reopening Phase 8 under the Phase 7 label
Wave-0 cleanup and validation-owner repair are real work, but they belong to Phase 8. Phase 7 should reference that debt, not absorb it.

## Research Verdict

Phase 7 should be planned as a layered-verification hardening phase, not an automation moonshot. The codebase already supports a truthful strategy if the plan does three things: add missing entry-callback tests, publish one stable regression runner, and update current docs so real tray interaction is described honestly as manual or lower-level seam coverage.

