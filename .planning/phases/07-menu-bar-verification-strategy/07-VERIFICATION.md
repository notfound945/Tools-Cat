---
phase: 07-menu-bar-verification-strategy
verified: 2026-04-13T09:14:35Z
status: passed
score: 4/4 must-haves verified
prior_verdict: gaps_found
---

# Phase 7: Menu-Bar Verification Strategy Verification Report

**Phase Goal:** Maintainers can see and run one clear verification strategy for the tray-triggered wake and management entry flows.
**Verified:** 2026-04-13T09:14:35Z
**Status:** passed
**Re-verification:** Yes - prior regression-slice stability gap closed

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Maintainers can identify explicit automated coverage for the root `发送 WOL …` and `管理 WOL 设备…` entry rows at the controller seam. | ✓ VERIFIED | `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift` covers wake dispatch, management dispatch, and the shared in-flight disable rule. |
| 2 | Current docs explicitly distinguish controller automation, direct-launch utility-window smoke, and manual tray-entry coverage. | ✓ VERIFIED | `.planning/phases/07-menu-bar-verification-strategy/07-VALIDATION.md`, `.planning/PROJECT.md`, and `.planning/phases/05-native-menu-polish/05-VERIFICATION.md` all describe the same layered boundary and explicitly say automation does not prove live tray clicks. |
| 3 | Maintainers have one canonical command and one phase-owned contract that explain what the Phase 7 slice proves and what it does not prove. | ✓ VERIFIED | `scripts/run_menu_bar_verification_slice.sh` remains the named command, and `07-VALIDATION.md` maps `AUTO-01` to `AUTO-03` to concrete controller suites, direct-launch smoke tests, and the manual tray-entry checklist. |
| 4 | The canonical Phase 7 regression slice is stable enough to trust as the advertised rerun path. | ✓ VERIFIED | `bash scripts/run_menu_bar_verification_slice.sh` completed successfully on 2026-04-13 with exit code 0 after the empty-state smoke was narrowed to stable list-empty surface assertions and the device-library helper stopped depending on a flaky macOS window lookup. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift` | Dedicated controller-seam wake and management entry coverage | ✓ VERIFIED | Exists, is substantive, and exercises the real menu item actions plus the shared `WOLSessionModel` in-flight state. |
| `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | Stable direct-launch smoke coverage for WOL, seeded manager, and empty manager surfaces | ✓ VERIFIED | Exists, adds surface-first waits, explicit teardown, a narrower seeded-manager smoke, and a more stable empty-state assertion path. |
| `scripts/run_menu_bar_verification_slice.sh` | Canonical Phase 7 regression command | ✓ VERIFIED | Exists, is substantive, runs each slice in its own non-parallel `xcodebuild` invocation, and completed successfully in verifier re-run. |
| `.planning/phases/07-menu-bar-verification-strategy/07-VALIDATION.md` | Canonical strategy and requirement contract | ✓ VERIFIED | Exists, is substantive, and names the canonical command, coverage map, and manual tray-entry checklist. |
| `.planning/phases/05-native-menu-polish/05-VERIFICATION.md` | Current-facing verification report aligned to the layered strategy | ✓ VERIFIED | Exists and explicitly distinguishes controller seam, launch-argument UI smoke, and manual tray-entry coverage. |
| `.planning/PROJECT.md` | Current milestone context aligned to the layered strategy | ✓ VERIFIED | Exists and describes controller tests, direct-launch UI smoke, and manual tray-entry in the active hardening context. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift` | `Mac OS Swiss Knife/StatusBarController.swift` | Menu item actions trigger real controller callbacks | WIRED | Verified by the test methods invoking `perform(action, with:)` against real `NSMenuItem` targets. |
| `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift` | `Mac OS Swiss Knife/WOLSessionModel.swift` | In-flight disable rule uses shared send state | WIRED | Verified by the blocking wake-sender test around `session.sendSavedDevice(id:)`. |
| `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | `Mac OS Swiss Knife/AppDelegate.swift` | UI smoke uses retained utility-window launch seams instead of live tray clicks | WIRED | Verified by the `--ui-test-open-wol-window` and `--ui-test-open-device-library` launch arguments used by the smoke tests. |
| `scripts/run_menu_bar_verification_slice.sh` | `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | Canonical script includes the stable direct-launch smoke set | WIRED | The script runs the WOL smoke, the seeded manager list-surface smoke, and the empty manager smoke in separate invocations. |
| `.planning/phases/07-menu-bar-verification-strategy/07-VALIDATION.md` | `scripts/run_menu_bar_verification_slice.sh` | Validation contract points to one canonical command | WIRED | The contract names the bash wrapper as the only advertised regression command and enumerates the exact suites inside it. |
| `.planning/phases/05-native-menu-polish/05-VERIFICATION.md` | `.planning/phases/07-menu-bar-verification-strategy/07-VALIDATION.md` | Current-facing report points to the same layered strategy | WIRED | `05-VERIFICATION.md` uses the same controller seam / launch-argument UI smoke / manual tray-entry framing. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests.swift` | `openCount`, `wakeItem.isEnabled`, `managementItem.isEnabled` | Real `StatusBarController` menu items plus shared `WOLSessionModel.sendState` | Yes | ✓ FLOWING |
| `Mac OS Swiss Knife/AppDelegate.swift` | Utility-window open path under UI-test launch arguments | `LaunchConfiguration` parses `--ui-test-open-wol-window` / `--ui-test-open-device-library` and calls `openWOLWindow()` / `openDeviceLibraryWindow()` | Yes | ✓ FLOWING |
| `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | Window and accessibility assertions | The launched app opens retained windows through the AppDelegate launch seam and renders real WOL/device-library surfaces | Yes | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Canonical Phase 7 regression slice | `bash scripts/run_menu_bar_verification_slice.sh` | Passed end-to-end on 2026-04-13 with controller seams, WOL smoke, seeded manager smoke, and empty manager smoke all succeeding in one run | ✓ PASS |
| Empty device-library smoke in isolation | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` | `** TEST SUCCEEDED **` after the smoke was reduced to stable empty-list-surface assertions | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `AUTO-01` | `07-01-PLAN.md`, `07-02-PLAN.md` | Maintainer can identify exactly which wake and management entry flows are covered by automated regression tests | ✓ SATISFIED | `StatusBarControllerEntryFlowTests.swift` proves root wake dispatch, management dispatch, and the in-flight disable rule, while `07-VALIDATION.md` maps that coverage explicitly. |
| `AUTO-02` | `07-03-PLAN.md` | Maintainer can see one explicit verification strategy for real menu-bar entry paths, whether via automation or documented non-automation coverage | ✓ SATISFIED | `07-VALIDATION.md`, `PROJECT.md`, and `05-VERIFICATION.md` all distinguish controller seams, direct-launch UI smoke, and manual tray-entry coverage without claiming live tray-click automation. |
| `AUTO-03` | `07-02-PLAN.md`, `07-03-PLAN.md` | Maintainer can run a stable regression slice for polished wake and management surfaces without ambiguous assumptions about tray-click coverage | ✓ SATISFIED | `scripts/run_menu_bar_verification_slice.sh` now completes successfully in one pass and uses the narrower seeded-list smoke plus stable empty-state smoke to avoid the earlier flaky path. |

Phase-7 orphaned requirements check: none. The Phase 7 plans collectively declare `AUTO-01`, `AUTO-02`, and `AUTO-03`, and `.planning/REQUIREMENTS.md` maps only those three IDs to Phase 7.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No TODO/FIXME/placeholder markers or stub implementations were found in the phase-owned code and documentation artifacts. | - | No static blocker anti-patterns found. |

### Human Verification Required

The phase-owned strategy still intentionally includes manual tray-entry checks for the live `NSStatusItem` path:

1. Launch the app normally, click the live tray icon, and choose `发送 WOL …`.
2. Confirm the retained `WOL 发送器` window opens and remains usable.
3. Click the live tray icon again and choose `管理 WOL 设备…`.
4. Confirm the retained `设备库` window opens and remains usable.
5. If a wake send is already in flight, reopen the live tray menu and confirm the root `发送 WOL …` row is disabled while `管理 WOL 设备…` remains available.

### Gaps Summary

No gaps remain against the Phase 7 success criteria. The controller seam coverage is explicit, the layered verification boundary is consistent across the validation contract and current-facing docs, and the canonical one-command regression slice now passes cleanly without relying on implied live tray-click automation.

---

_Verified: 2026-04-13T09:14:35Z_
_Verifier: Codex (gsd-verifier)_
