---
phase: 05-native-menu-polish
verified: 2026-04-12T09:42:55Z
status: passed
score: 3/3 must-haves verified
human_verification:
  - test: "Visually confirm the root menu reads keep-awake -> wake -> management in idle and active states"
    expected: "Only native separators divide the three groups, idle hides both status rows, timed keep-awake shows one keep-awake status row, and a wake action shows one truthful wake-status row"
    why_human: "Menu scanability, density, and restrained native feel are only partially automatable"
  - test: "Open the WOL window and review its hierarchy"
    expected: "One heading, one visible input area, optional status block only when meaningful, and one clear primary action in a compact single-column utility window"
    why_human: "Spacing, prominence, and overall native polish are visual qualities not fully captured by structure assertions"
  - test: "Open the device-library window in list, reorder, form, and empty states"
    expected: "List stays primary, reorder mode shows drag affordances without edit/delete mixing, form labels stay above controls with validation directly under fields, and the empty state remains centered and restrained"
    why_human: "List-first emphasis and restrained hierarchy still require human judgment beyond XCUITest structure checks"
---

# Phase 5: Native Menu Polish Verification Report

**Phase Goal:** Users experience a compact, clearly grouped, and visually restrained native macOS utility across the menu bar and management surfaces.
**Verified:** 2026-04-12T09:42:55Z
**Status:** passed
**Re-verification:** Yes - approved manual visual validation recorded after the final Phase 5 polish pass

## Verification Strategy

Phase 5 now reads as one layered verification story instead of implied live tray automation:

- `controller seam`: `StatusBarController` tests prove menu grouping, saved-device wake behavior, and root entry dispatch rules without claiming the live tray icon was clicked.
- `launch-argument UI smoke`: the retained `WOL 发送器` and `设备库` windows are opened through `AppDelegate` launch arguments so XCUITest can prove downstream utility-window polish deterministically.
- `manual tray-entry`: the real `NSStatusItem` click path, including opening the live tray and selecting `发送 WOL …` or `管理 WOL 设备…`, remains covered by human verification rather than automated live tray clicks.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | User sees wake actions, keep-awake state, status feedback, and management actions grouped in a compact native macOS menu structure. | ✓ VERIFIED | [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L64) fixes the menu anchors and separators, hides idle status rows, and keeps management actions last; [`StatusBarControllerMenuPolishTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/StatusBarControllerMenuPolishTests.swift#L9) verifies separator order, idle collapse, empty-library wake feedback, and trailing management rows at the controller seam; the targeted controller XCTest slice passed. |
| 2 | User experiences restrained, polished wake and management surfaces with clear hierarchy and status cues consistent with native macOS expectations. | ✓ VERIFIED | [`WOLView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift#L12), [`WOLWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLWindow.swift#L7), [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryView.swift#L33), and [`DeviceLibraryWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryWindow.swift#L7) implement the intended hierarchy and identifiers; the launch-argument UI smoke slice passed and the approved live review confirmed the tightened WOL spacing, preserved list-first manager hierarchy, and native visual restraint (`05-HUMAN-UAT.md`). |
| 3 | The app stays small and scannable while still exposing saved devices through a compact wake section and timed-session feedback. | ✓ VERIFIED | [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L214) keeps saved devices behind the `快速WOL` submenu, preserves a manual-send row plus trailing `管理 WOL 设备…`, removes wake-history clutter from the root tray, and renders timed keep-awake status from [`KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/KeepAwakePresentation.swift#L31); the approved live review also confirmed the two-line device name + MAC presentation (`05-HUMAN-UAT.md`). |

**Score:** 3/3 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Mac OS Swiss Knife/StatusBarController.swift` | Fixed three-section menu anchors, contextual status collapse, truthful wake feedback with or without saved devices | ✓ VERIFIED | Two fixed separators, hidden idle status rows, compact wake grouping, `快速WOL` submenu presentation, and wake status independent of library size are implemented at [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L64). |
| `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift` | Controller regression coverage for Phase 5 menu contract | ✓ VERIFIED | Dedicated tests exist at [`StatusBarControllerMenuPolishTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/StatusBarControllerMenuPolishTests.swift#L9) and passed in the targeted controller slice. |
| `Mac OS Swiss Knife.xcodeproj/project.pbxproj` | Registers Phase 5 controller regression file | ✓ VERIFIED | Test file is registered at [`project.pbxproj`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife.xcodeproj/project.pbxproj#L68). |
| `Mac OS Swiss Knife/WOLView.swift` | Compact WOL hierarchy with stable mode/input/status/action identifiers | ✓ VERIFIED | Heading, mutually exclusive input areas, optional status block, action row, and automation hooks are implemented at [`WOLView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift#L12). |
| `Mac OS Swiss Knife/WOLWindow.swift` | Retained AppKit WOL shell hosting the refined SwiftUI view | ✓ VERIFIED | Retained hosting shell remains wired at [`WOLWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLWindow.swift#L7). |
| `Mac OS Swiss Knife/DeviceLibraryView.swift` | List-first manager hierarchy with top-actions, empty-state CTA, and form-action hooks | ✓ VERIFIED | List, empty, reorder, and form states with stable identifiers are implemented at [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryView.swift#L33). |
| `Mac OS Swiss Knife/DeviceLibraryWindow.swift` | Retained AppKit manager shell hosting the list-first view | ✓ VERIFIED | The manager shell remains wired and compact at [`DeviceLibraryWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryWindow.swift#L7). |
| `Mac OS Swiss Knife/AppDelegate.swift` | Launch-argument seam for direct WOL/device-library window UI smoke | ✓ VERIFIED | Both utility-window launch flags are wired in [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/AppDelegate.swift#L13). |
| `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | UI smoke coverage for WOL, seeded manager, and empty manager states | ✓ VERIFIED | The UI smoke tests exist at [`Mac_OS_Swiss_KnifeUITests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift#L42) and passed in the targeted UI slice. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `StatusBarController.swift` | `KeepAwakePresentation.swift` | `presentation.statusText` drives keep-awake status visibility | WIRED | [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L174) reads `presentation.statusText`; [`KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/KeepAwakePresentation.swift#L31) returns `nil` only when no meaningful status should render. |
| `StatusBarController.swift` | `WOLSessionModel.swift` | Wake status row renders from `sendState` and `lastCompletedWake` | WIRED | [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L271) uses `wolSession.sendState` and `wolSession.lastCompletedWake`; [`WOLSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLSessionModel.swift#L151) updates those values from real send outcomes. |
| `StatusBarController.swift` | `StatusBarControllerMenuPolishTests.swift` | Controller tests lock separator and hidden-state rules | WIRED | The dedicated tests at [`StatusBarControllerMenuPolishTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/StatusBarControllerMenuPolishTests.swift#L9) passed in the targeted controller XCTest slice. |
| `WOLWindow.swift` | `WOLView.swift` | Retained AppKit shell hosts refined WOL SwiftUI view | WIRED | [`WOLWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLWindow.swift#L7) creates `NSHostingView(rootView: WOLView(...))`. |
| `DeviceLibraryWindow.swift` | `DeviceLibraryView.swift` | Retained manager shell hosts list-first management view | WIRED | [`DeviceLibraryWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryWindow.swift#L7) creates `NSHostingView(rootView: DeviceLibraryView(...))`. |
| `DeviceLibraryView.swift` | `DeviceLibrarySessionModel.swift` | View hierarchy binds to `session.screen`, `session.devices`, and `session.isReordering` | WIRED | [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryView.swift#L7) switches on `session.screen` and drives list/reorder/form behavior from session state; [`DeviceLibrarySessionModel.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibrarySessionModel.swift#L65) loads and mutates real library state. |
| `AppDelegate.swift` | `WOLWindow.swift` | Launch arguments open the retained WOL window for automation | WIRED | [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/AppDelegate.swift#L33) calls `openWOLWindow()` when `--ui-test-open-wol-window` is present. |
| `Mac_OS_Swiss_KnifeUITests.swift` | `WOLView.swift` | XCUITest queries polished WOL hierarchy identifiers | WIRED | [`Mac_OS_Swiss_KnifeUITests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift#L128) asserts `wol-mode-group`, an input seam, `wol-action-row`, and the send button. |
| `Mac_OS_Swiss_KnifeUITests.swift` | `DeviceLibraryView.swift` | XCUITest queries polished manager hierarchy identifiers | WIRED | [`Mac_OS_Swiss_KnifeUITests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift#L42) asserts list and form seams; [`Mac_OS_Swiss_KnifeUITests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift#L100) asserts the empty-state container. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `StatusBarController.swift` | `keepAwakeStatusItem.title`, `wakeStatusItem.title`, `recentWakeItems` | `KeepAwakePresentation.statusText`, `WOLSessionModel.sendState/lastCompletedWake`, `SavedDeviceLibraryStore.recentDevices()` | Yes | ✓ FLOWING |
| `WOLView.swift` | `session.inputMode`, `session.validation`, `session.sendState`, `deviceLibrary.devices` | `WOLSessionModel` updates validation and send results at [`WOLSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLSessionModel.swift#L80) and loads remembered devices from [`SavedDeviceLibraryStore.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/SavedDeviceLibraryStore.swift#L12) | Yes | ✓ FLOWING |
| `DeviceLibraryView.swift` | `session.screen`, `session.devices`, `session.isReordering`, validation/save errors | `DeviceLibrarySessionModel` reloads, saves, deletes, and reorders through [`SavedDeviceLibraryStore.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/SavedDeviceLibraryStore.swift#L25) and mirrors state at [`DeviceLibrarySessionModel.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibrarySessionModel.swift#L65) | Yes | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Phase 5 controller seam contract | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` | `** TEST SUCCEEDED **` | ✓ PASS |
| Phase 5 launch-argument UI smoke | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` | `** TEST SUCCEEDED **` | ✓ PASS |
| Final manual tray-entry review | Running Debug app plus tray/menu/window polish pass | Approved: root menu grouping remained compact, `快速WOL` naming read clearly, wake-history rows stayed removed, the live tray menu still opened the retained WOL/device-library windows as expected, and saved-device entries showed name over smaller MAC text without crowding. | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `UX-01` | `05-01-PLAN.md`, `05-03-PLAN.md` | User sees wake actions, keep-awake state, status feedback, and management actions grouped in a compact native macOS menu structure | ✓ SATISFIED | The menu grouping, idle collapse, truthful wake-status behavior, wake-group copy refinements, and launch seams are implemented and passing in [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L64), [`StatusBarControllerMenuPolishTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/StatusBarControllerMenuPolishTests.swift#L9), and [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/AppDelegate.swift#L13); the final native menu read was approved in [`05-HUMAN-UAT.md`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/phases/05-native-menu-polish/05-HUMAN-UAT.md). |
| `UX-04` | `05-02-PLAN.md`, `05-03-PLAN.md` | User experiences a visually restrained, polished interface with clear hierarchy and status cues consistent with native macOS expectations | ✓ SATISFIED | The WOL and manager hierarchies, identifiers, UI smoke coverage, tightened spacing, and saved-device typography refinements are implemented in [`WOLView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift#L12), [`WOLWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLWindow.swift#L7), [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryView.swift#L33), and [`Mac_OS_Swiss_KnifeUITests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift#L42); visual restraint and hierarchy quality were approved in [`05-HUMAN-UAT.md`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/phases/05-native-menu-polish/05-HUMAN-UAT.md). |

Phase-5 orphaned requirements check: none. The only Phase 5 requirement IDs in [`REQUIREMENTS.md`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/REQUIREMENTS.md#L102) are `UX-01` and `UX-04`, and both appear in Phase 5 plan frontmatter.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No TODO/FIXME/placeholder markers or stub returns detected in the phase-owned product and test files. | - | No blocker anti-patterns found. |

### Human Verification Required

### 1. Manual tray-entry root menu grouping

**Test:** Launch the app, use the live tray icon to open the menu in idle state, then trigger timed keep-awake and a wake action.
**Expected:** The menu reads keep-awake → wake → management, idle hides both status rows, timed keep-awake shows only the keep-awake status row, and wake feedback appears as one truthful wake-status row.
**Why human:** Controller seam tests prove ordering and visibility rules, not the actual live tray interaction, visual scanability, or native restraint.

### 2. Manual tray-entry WOL utility window

**Test:** From the live tray menu, click `发送 WOL …`, then inspect the hierarchy and spacing in the retained WOL window.
**Expected:** One heading, one visible input area, the status block appears only when meaningful, and the primary action remains visually clear in a compact single-column window.
**Why human:** The launch-argument UI smoke proves identifiers and control presence after direct launch, but manual tray-entry still owns the real root row click path, prominence, breathing room, and perceived polish.

### 3. Manual tray-entry device-library window

**Test:** From the live tray menu, click `管理 WOL 设备…`, then inspect the manager with devices, enter reorder mode, enter add/edit form mode, and inspect the empty state if safe.
**Expected:** The list remains primary, reorder mode shows drag affordances without edit/delete actions, form labels stay above controls with validation directly under fields, and the empty state stays centered and restrained with `添加设备` as the main CTA.
**Why human:** The current launch-argument UI smoke proves structure and field placement after direct launch, but live tray-entry and restrained visual hierarchy remain human-only judgments.

### Gaps Summary

No code or wiring gaps were found in the Phase 5 implementation. The targeted controller seam slice, targeted launch-argument UI smoke slice, and final manual tray-entry approval are now all recorded, so Phase 5 is fully passed without claiming automated live tray clicks.

---

_Verified: 2026-04-12T09:42:55Z_
_Verifier: Codex_
