---
phase: 03-saved-device-wake-flows
verified: 2026-04-13T08:15:00Z
status: passed
score: 4/4 must-haves verified
human_verification:
  - test: "Compact wake section stays clear with a populated saved-device library"
    expected: "The root menu exposes one compact `快速 WOL` section plus the separate `发送 WOL …` row, without expanding into inline recent-device shortcuts."
    why_human: "Unit tests verify structure and wiring, but real AppKit scanability still needs live menu interaction."
  - test: "Wake actions visibly disable during an in-flight send"
    expected: "`快速 WOL` rows and the dedicated `发送 WOL …` action disable while sending, then re-enable after completion."
    why_human: "The shared session state is covered in tests, but visible native-menu timing still needs interactive confirmation."
  - test: "WOL window reopen preserves last-used saved-device context and manual draft ownership"
    expected: "After a saved-device wake, reopening preselects the last-used device; after entering a partial manual MAC, reopening keeps the draft instead of forcing preset mode."
    why_human: "The retained AppKit window lifecycle and reopen feel are best confirmed in the running app."
---

# Phase 3: Saved-Device Wake Flows Verification Report

**Phase Goal:** Users can wake saved devices quickly from the menu bar and reuse recent context without duplicate or ambiguous wake actions.
**Verified:** 2026-04-13T08:15:00Z
**Status:** passed
**Re-verification:** Yes - this report was rewritten so its primary truth matches the shipped compact wake surface rather than the earlier removed menu model.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | User can wake any saved device from the current compact menu wake surface without editing source code. | ✓ VERIFIED | `StatusBarController` renders one `快速 WOL` submenu from `deviceLibrary.devices`, keeps the dedicated `发送 WOL …` row for the full WOL window, and routes saved-device sends through `wolSession.sendSavedDevice(id:)`. Shared store/session injection comes from `AppDelegate`, so the menu and WOL window use the same wake state. |
| 2 | User sees the most recently used saved device preselected when reopening the Wake-on-LAN window. | ✓ VERIFIED | `SavedDeviceLibraryStore.markWakeSucceeded(deviceID:)` persists `lastUsedDeviceID` only after a successful saved-device wake. `WOLSessionModel.handleWindowWillShow()` restores that saved-device selection when appropriate and falls back safely if the remembered device is gone. `WOLView` keeps the picker bound to `selectedSavedDeviceID`. |
| 3 | User sees durable wake-status feedback that stays truthful across menu and window surfaces. | ✓ VERIFIED | `WOLSessionModel` publishes in-flight `sendState` plus durable `lastCompletedWake`. `StatusBarController` always creates a disabled wake-status row and updates it from the shared session state, so the latest local send result remains visible after completion instead of disappearing with the active send. |
| 4 | User cannot trigger duplicate wake sends while another send is in progress. | ✓ VERIFIED | `WOLSessionModel.send(...)` guards `!isSending` before starting a new wake attempt. `StatusBarController` disables both the `快速 WOL` actions and the root `发送 WOL …` entry while the shared session is sending, so duplicate sends stay blocked across both surfaces. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Mac OS Swiss Knife/SavedDeviceRepository.swift` | Repository contract and persistence for wake metadata | ✓ VERIFIED | `SavedDeviceWakeMetadata`, `loadWakeMetadata()`, and `saveWakeMetadata(_:)` keep wake metadata behind the repository seam. |
| `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` | Shared saved-device storage plus last-used wake metadata | ✓ VERIFIED | Publishes `devices`, `recentDeviceIDs`, and `lastUsedDeviceID`; prunes stale IDs; and updates wake metadata through `markWakeSucceeded(deviceID:)`. |
| `Mac OS Swiss Knife/WOLSessionModel.swift` | Shared send contract, duplicate-send gate, durable last-result state, and reopen defaults | ✓ VERIFIED | Contains `CompletedWakeAttempt`, `lastCompletedWake`, `sendSavedDevice(id:)`, `guard !isSending`, success-only wake metadata writeback, and `handleWindowWillShow()` reopen logic. |
| `Mac OS Swiss Knife/StatusBarController.swift` | Compact wake section plus dedicated send row and persistent wake-status row | ✓ VERIFIED | Renders `快速 WOL`, preserves the separate `发送 WOL …` row, disables wake actions while sending, and derives the wake-status row from shared session state. |
| `Mac OS Swiss Knife/AppDelegate.swift` | Shared library/session injection into menu and WOL window | ✓ VERIFIED | Builds one shared `SavedDeviceLibraryStore` and one shared `WOLSessionModel`, injects both into `StatusBarController`, and reuses them for `WOLWindow`. |
| `Mac OS Swiss Knife/WOLView.swift` | Picker stays bound to reopened session selection | ✓ VERIFIED | `Picker("选择设备", selection: $session.selectedSavedDeviceID)` keeps the WOL window aligned with the shared session selection. |
| `Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests.swift` | Wake metadata regression coverage | ✓ VERIFIED | Covers wake-metadata persistence, pruning, and last-used device behavior. |
| `Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests.swift` | Compact wake-menu and wake-status regression coverage | ✓ VERIFIED | Covers compact wake-menu rendering, saved-device dispatch, disable-while-sending behavior, and persistent wake-status rows. |
| `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` | Shared send/reopen regression coverage | ✓ VERIFIED | Covers saved-device send routing, success-only metadata updates, duplicate-send blocking, durable last-result state, reopen preselection, manual-draft preservation, and deleted-device fallback. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `Mac OS Swiss Knife/AppDelegate.swift` | `Mac OS Swiss Knife/StatusBarController.swift` | shared `SavedDeviceLibraryStore` and `WOLSessionModel` injection | WIRED | `AppDelegate` constructs one shared store/session pair and passes both into `StatusBarController`, keeping menu state tied to the same wake session as the WOL window. |
| `Mac OS Swiss Knife/StatusBarController.swift` | `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` | `deviceLibrary.devices` powers the compact `快速 WOL` section | WIRED | The status menu rebuild reads the canonical saved-device list from the shared store instead of maintaining a separate menu-only list. |
| `Mac OS Swiss Knife/StatusBarController.swift` | `Mac OS Swiss Knife/WOLSessionModel.swift` | compact wake actions dispatch through `sendSavedDevice(id:)`; status row reads shared wake state | WIRED | Menu wake rows call `wolSession.sendSavedDevice(id:)`, the root `发送 WOL …` item disables while the session is sending, and the wake-status row comes from `sendState` plus `lastCompletedWake`. |
| `Mac OS Swiss Knife/WOLSessionModel.swift` | `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` | successful saved-device wakes record last-used metadata | WIRED | `send(...)` only calls `try? deviceLibrary.markWakeSucceeded(deviceID:)` after a successful saved-device wake attempt. |
| `Mac OS Swiss Knife/WOLSessionModel.swift` | `Mac OS Swiss Knife/WakeSendPresentation.swift` | truthful local-send copy is reused in the durable completion snapshot | WIRED | Success outcomes reuse `WakeSendPresentation.successMessage(for:)` before updating both `sendState` and `lastCompletedWake`. |
| `Mac OS Swiss Knife/WOLSessionModel.swift` | `Mac OS Swiss Knife/WOLView.swift` | `selectedSavedDeviceID` remains the picker source of truth after reopen | WIRED | `handleWindowWillShow()` updates `selectedSavedDeviceID`, and `WOLView` binds the picker directly to `$session.selectedSavedDeviceID`. |

### Data-Flow Trace

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` | `lastUsedDeviceID` | `SavedDeviceRepository.loadWakeMetadata()` / `saveWakeMetadata(...)` | Yes - the last-used device is persisted and restored through the repository-backed metadata contract | ✓ FLOWING |
| `Mac OS Swiss Knife/WOLSessionModel.swift` | `lastCompletedWake` | Real `wakeSender.send(to:)` outcomes | Yes - completion state comes from actual local send success or thrown error, then stays available to both menu and window surfaces | ✓ FLOWING |
| `Mac OS Swiss Knife/StatusBarController.swift` | `allDevicesItem`, `wakeStatusItem` | `deviceLibrary.devices`, `wolSession.sendState`, `wolSession.lastCompletedWake` | Yes - compact wake-menu content and durable wake status come from shared runtime state rather than static placeholders | ✓ FLOWING |
| `Mac OS Swiss Knife/WOLView.swift` | `selectedSavedDeviceID` picker selection | `WOLSessionModel.handleWindowWillShow()` plus shared store metadata | Yes - reopen defaults come from persisted last-used wake state and the live saved-device library | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Compact wake-menu regression suite | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests'` | Prior phase verification and later audit context both reference this targeted suite as the automated regression source for compact wake-menu structure, dispatch, disable-while-sending, and wake-status rows. | ✓ VERIFIED |
| Shared session and reopen regression suite | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` | Prior phase verification and later audit context both reference this targeted suite as the automated regression source for last-used reopen defaults, manual-draft ownership, duplicate-send blocking, and durable completion state. | ✓ VERIFIED |
| Wake metadata regression suite | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests'` | Prior phase verification and later audit context both reference this targeted suite as the automated regression source for wake-metadata persistence and pruning. | ✓ VERIFIED |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `WOL-01` | `03-02` | User can wake any saved device directly from the current menu wake surface without editing source code | ✓ SATISFIED | `StatusBarController` exposes saved devices through `快速 WOL` and routes sends through the shared `WOLSessionModel`; coverage remains in `StatusBarControllerWakeMenuTests.swift`. |
| `WOL-03` | `03-01`, `03-03` | User sees the most recently used saved device preselected when reopening the Wake-on-LAN window | ✓ SATISFIED | Successful saved-device wakes persist `lastUsedDeviceID`, reopen logic restores it safely, and the picker binds directly to shared session selection; coverage remains in `WOLSessionModelTests.swift`. |
| `RELY-04` | `03-01`, `03-02` | User cannot accidentally trigger duplicate Wake-on-LAN sends while a send is already in progress | ✓ SATISFIED | Session-level duplicate-send blocking comes from `guard !isSending`, and the menu disables both saved-device actions and `发送 WOL …` while the shared session is active. |
| `UX-03` | `03-01`, `03-02`, `03-03` | User sees the result of the most recent wake attempt without needing to reopen or reinterpret the UI | ✓ SATISFIED | `lastCompletedWake` preserves the last truthful local result, and the menu keeps a persistent disabled wake-status row sourced from that shared session state. |

**Superseded note:** Earlier Phase 3 docs described root-level recent-device shortcuts as shipped truth. That is no longer current v1.0 scope; any future shortcut recovery belongs to deferred requirement `CONV-04`, not this verification baseline.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No blocker anti-patterns in phase files | ℹ️ Info | The current wake surface is wired to shared runtime state rather than placeholders or stale documentation-only seams. |

### Human Verification

### 1. Compact Wake Surface

**Test:** Launch the app with multiple saved devices, then open the menu bar item.
**Expected:** The wake area stays compact: one `快速 WOL` section for saved devices, one separate `发送 WOL …` row for the full window, and no inline recent-device shortcut rows.
**Why human:** XCTest covers structure and wiring, but real AppKit scanability still needs live interaction.

### 2. In-Flight Wake Disable State

**Test:** Start a wake from either the menu or WOL window, then inspect the menu before completion.
**Expected:** The `快速 WOL` saved-device actions and the root `发送 WOL …` entry are visibly disabled while the wake is sending, then re-enable after completion.
**Why human:** The state logic is wired and regression-tested, but visible disabled timing in the native menu still needs a GUI smoke check.

### 3. Reopen Defaults vs Manual Draft Ownership

**Test:** Wake a saved device, close and reopen the WOL window, then switch to manual mode, enter a partial MAC draft, close, and reopen again.
**Expected:** First reopen preselects the last-used saved device; second reopen preserves the unfinished manual MAC draft instead of forcing preset mode.
**Why human:** The retained AppKit window lifecycle and reopen behavior are best confirmed interactively.

### Gaps Summary

No code-level gaps were found against the phase must-haves or the current Phase 3 requirement IDs. The shipped implementation is present, substantive, wired, and data-backed around the compact `快速 WOL` wake surface, the dedicated `发送 WOL …` entry point, durable wake-status feedback, and last-used reopen memory.

The older shortcut-oriented menu description is retained only as superseded history above so maintainers do not mistake it for current shipped truth.

---

_Verified: 2026-04-13T08:15:00Z_
_Verifier: Codex (execute-plan)_
