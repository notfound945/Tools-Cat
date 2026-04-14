# Phase 7: Menu-Bar Verification Strategy - Context

**Gathered:** 2026-04-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the current menu-bar verification story explicit and durable. This phase should state exactly which wake and management entry flows are covered by controller tests, which are covered by direct-launch UI smoke, and which still require human tray interaction. It may add targeted test coverage, a stable regression command, and planning/verification docs that remove any implied end-to-end tray-click coverage.

It does not redesign the shipped menu structure, restore removed wake shortcuts, migrate away from `NSStatusItem`, or absorb the broader Phase 8 validation-debt cleanup.

</domain>

<decisions>
## Implementation Decisions

### Coverage boundary truth
- **D-01:** Phase 7 must make the current automation boundary explicit: the repo already has controller-level menu tests and direct-launch utility-window UI smoke, but those do not prove a real click on the live `NSStatusItem` tray icon.
- **D-02:** Phase 7 should remove any planning or verification ambiguity that lets maintainers mistake launch-argument window smoke for real tray-entry automation.
- **D-03:** Real tray-entry coverage may remain manual if the docs and UAT contract say so clearly; this phase is allowed to choose documented non-automation coverage over brittle or misleading fake end-to-end automation.

### Strategy shape
- **D-04:** The phase should leave one stable regression slice that a maintainer can run repeatedly to cover the polished wake and management surfaces without having to infer which tests matter.
- **D-05:** If new automation is added, it should strengthen lower-level seams that already exist in the codebase, such as `StatusBarController` callback dispatch and direct utility-window launch seams, rather than pretending to prove a live tray click when it does not.
- **D-06:** Any new documentation should use the shipped wake-surface truth from Phase 6: `快速 WOL` plus the dedicated `发送 WOL …` row, with management still exposed as `管理 WOL 设备…`.

### Phase boundary discipline
- **D-07:** Keep the app as an `LSUIElement` menu-bar utility; no `MenuBarExtra` migration, shell rewrite, or product-surface redesign belongs in this phase.
- **D-08:** Phase 7 may touch tests, test runners/scripts, validation docs, verification docs, and current project context where needed to explain the verification boundary.
- **D-09:** Phase 7 must not absorb Phase 8's broader `wave_0_complete` and validation-owner cleanup beyond the exact notes needed to keep the tray-entry strategy coherent.

### the agent's Discretion
- Whether to add a dedicated controller test file or extend an existing menu test file, as long as the tray entry callbacks and their coverage boundaries become explicit.
- Whether the stable regression slice is best exposed through a shell script, a dedicated phase validation doc, or both.
- Exact wording for manual tray-entry UAT guidance, as long as it distinguishes live tray interaction from lower-level automated seams.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and current milestone goals
- `.planning/ROADMAP.md` — Defines the Phase 7 goal, requirements `AUTO-01` through `AUTO-03`, and the boundary against Phase 8 validation-debt cleanup.
- `.planning/REQUIREMENTS.md` — Defines the automation-strategy requirements and confirms they are the only Phase 7 requirement IDs.
- `.planning/PROJECT.md` — Captures the current shipped wake surface and the v1.1 hardening goals after Phase 6 completion.
- `.planning/STATE.md` — Confirms Phase 6 is complete and Phase 7 is now the active planning target.

### Existing evidence that shapes the strategy
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md` — Records the current automation seam gap: UI smoke opens utility windows through launch arguments instead of proving live tray clicks.
- `.planning/phases/05-native-menu-polish/05-VERIFICATION.md` — Current polished-menu verification, including controller tests, direct-launch UI smoke, and manual visual approval.
- `.planning/phases/05-native-menu-polish/05-VALIDATION.md` — Current validation contract and test-slice commands for the polished menu/window surfaces.
- `.planning/phases/05-native-menu-polish/05-HUMAN-UAT.md` — Approved human checks for live visual menu/window behavior.
- `.planning/phases/03-saved-device-wake-flows/03-VALIDATION.md` — Older validation language that still shows how menu-flow claims and manual tray checks were previously framed.

### Code and tests that define the current coverage boundary
- `Mac OS Swiss Knife/AppDelegate.swift` — Contains the current launch-argument seams that open the WOL and device-library windows directly for XCUITest.
- `Mac OS Swiss Knife/StatusBarController.swift` — Defines the real tray-entry rows (`快速 WOL`, `发送 WOL …`, `管理 WOL 设备…`) and callback dispatch points.
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` — Current direct-launch UI smoke coverage for the WOL and device-library windows.
- `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift` — Current controller tests for menu grouping and compact wake-section structure.
- `Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests.swift` — Current controller tests for saved-device wake dispatch and wake-status behavior.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` — Confirms the app remains an `LSUIElement` menu-bar utility.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppDelegate.LaunchConfiguration` already supports `--ui-test-open-wol-window` and `--ui-test-open-device-library`, giving the phase a stable lower-level automation seam without touching the live tray icon.
- `StatusBarControllerMenuPolishTests` already lock the compact wake group ordering and management-row placement.
- `StatusBarControllerWakeMenuTests` already prove saved-device dispatch, disabled wake actions while sending, and persistent wake-status behavior.
- `05-HUMAN-UAT.md` already contains approved live checks for the polished tray/menu/window surfaces.

### Established Patterns
- The repo prefers controller/unit tests for `NSMenu` wiring and state rules, then uses XCUITest only for deterministic utility-window seams.
- Phase 6 established a current-truth-first documentation standard, so Phase 7 docs must explicitly label lower-level seam coverage versus manual tray coverage.
- Planning and validation artifacts under `.planning/` are the right place to explain current verification truth without implying broader automation than the code really has.

### Integration Points
- Any strategy doc or validation contract should line up with `StatusBarController.swift`, `AppDelegate.swift`, and the current UI test launch seams.
- If a stable regression script is added, it should run the menu controller suites and the direct-launch WOL/device-library UI smoke as one named slice.
- If manual tray coverage remains, it should connect back to a concrete UAT checklist rather than a vague “human testing” note.

</code_context>

<specifics>
## Specific Ideas

- Add explicit automated tests for the root `发送 WOL …` and `管理 WOL 设备…` callback paths so maintainers can see that entry dispatch is covered at the controller seam.
- Add one stable regression command or script that runs the controller menu suites plus the current direct-launch UI smoke tests together.
- Update current verification/validation docs so they say, in plain language, that launch-argument UI smoke covers retained windows and lower-level seams, while the live tray click path is either manual-only or separately automated if Phase 7 adds that proof.

</specifics>

<deferred>
## Deferred Ideas

- True end-to-end tray-click automation if it requires a fragile external harness or a shell rewrite.
- Any `MenuBarExtra` migration or AppKit-to-SwiftUI menu-shell replacement.
- Broader validation debt cleanup for Phases 01-04, including `wave_0_complete` repair and ownership cleanup, which belongs to Phase 8.

</deferred>

---

*Phase: 07-menu-bar-verification-strategy*
*Context gathered: 2026-04-13*
