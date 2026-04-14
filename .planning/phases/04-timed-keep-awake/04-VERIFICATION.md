---
phase: 04-timed-keep-awake
verified: 2026-04-12T07:14:31Z
status: passed
score: 3/3 must-haves verified
human_verification:
  - test: "Fixed keep-awake rows stay compact and ordered on the live menu surface"
    expected: "The root menu shows `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`, `关闭常亮`, then one disabled status row before `发送 WOL …`."
    why_human: "Controller tests prove ordering, but live AppKit scanability and row visibility still require direct menu-bar interaction."
  - test: "Timed replacement updates live countdown without mutating action titles"
    expected: "Switching from `15 分钟` to `30 分钟` replaces immediately without confirmation and countdown text remains confined to the disabled status row."
    why_human: "The native menu refresh feel and live countdown readability cannot be fully judged from XCTest alone."
  - test: "Manual stop and natural expiry return directly to the off presentation"
    expected: "The explicit `关闭常亮` row remains visible throughout and both manual stop and expiry return to the normal off state with no extra completion banner."
    why_human: "Native menu-bar lifecycle timing around expiry and redraw still benefits from a live smoke."
---

# Phase 4: Timed Keep-Awake Verification Report

**Phase Goal:** Users can control keep-awake as either an indefinite or timed session with explicit duration choices and countdown feedback.
**Verified:** 2026-04-12T07:14:31Z
**Status:** passed
**Re-verification:** Yes - approved manual menu-bar validation recorded after automated verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | A live build lets the user start indefinite keep-awake, switch to a timed preset, watch the countdown update in the status row, and stop manually with `关闭常亮`. | ✓ VERIFIED | `AppDelegate` retains and injects one shared `KeepAwakeSessionModel` (`AppDelegate.swift:9`, `AppDelegate.swift:23`, `AppDelegate.swift:65`), `StatusBarController` exposes the six fixed keep-awake rows plus status row and routes each action through the shared session (`StatusBarController.swift:59`, `StatusBarController.swift:103`, `StatusBarController.swift:304`, `StatusBarController.swift:309`, `StatusBarController.swift:329`), and `StatusBarControllerKeepAwakeMenuTests` covers ordering, dispatch, status-row copy, and manual stop availability (`StatusBarControllerKeepAwakeMenuTests.swift:8`, `StatusBarControllerKeepAwakeMenuTests.swift:30`, `StatusBarControllerKeepAwakeMenuTests.swift:100`). |
| 2 | Timed replacement works without confirmation, and a naturally expiring timed session returns to the normal off presentation. | ✓ VERIFIED | Timed replacement is handled by `KeepAwakeSessionModel.startTimed(_:)` while cancelling/replacing the previous countdown token (`KeepAwakeSessionModel.swift:65`, `KeepAwakeSessionModel.swift:86`, `KeepAwakeSessionModelTests.swift:64`), expiry disables through the truthful power-control seam and returns only after confirmed disable (`KeepAwakeSessionModel.swift:130`, `KeepAwakeSessionModelTests.swift:114`), and the approved live smoke confirmed replacement plus natural expiry on the real menu surface (`04-HUMAN-UAT.md`). |
| 3 | No action title flickers with countdown text, and the live menu keeps the explicit manual-off row visible throughout. | ✓ VERIFIED | `StatusBarController` keeps fixed action titles and renders countdown only via `keepAwakeStatusItem.title = presentation.statusText ?? ""` while preserving `keepAwakeOffItem` in the action list (`StatusBarController.swift:181`, `StatusBarController.swift:185`, `StatusBarController.swift:204`); `KeepAwakeMenuStateTests` and `StatusBarControllerKeepAwakeMenuTests` lock countdown confinement and stable action titles (`KeepAwakeMenuStateTests.swift:23`, `StatusBarControllerKeepAwakeMenuTests.swift:83`). |

**Score:** 3/3 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Mac OS Swiss Knife/KeepAwakeSessionModel.swift` | Timed session lifecycle, replacement, and expiry behavior | ✓ VERIFIED | Provides `startIndefinite()`, `startTimed(_:)`, `stop(completion:)`, confirmed mode, pending action, countdown state, replacement handling, and expiry disable flow (`KeepAwakeSessionModel.swift:8`, `KeepAwakeSessionModel.swift:51`, `KeepAwakeSessionModel.swift:65`, `KeepAwakeSessionModel.swift:104`, `KeepAwakeSessionModel.swift:130`). |
| `Mac OS Swiss Knife/KeepAwakePresentation.swift` | Shared menu status, icon, and tooltip contract | ✓ VERIFIED | Encodes off, pending, infinite, timed, and failure presentation state including status-row copy and tooltip/icon selection (`KeepAwakePresentation.swift:3`, `KeepAwakePresentation.swift:20`, `KeepAwakePresentation.swift:39`, `KeepAwakePresentation.swift:63`). |
| `Mac OS Swiss Knife/AppDelegate.swift` | Lifecycle-owned shared keep-awake session injection | ✓ VERIFIED | Retains `keepAwakeSession` and passes it into `StatusBarController(keepAwakeSession:)` at launch (`AppDelegate.swift:9`, `AppDelegate.swift:20`, `AppDelegate.swift:23`, `AppDelegate.swift:65`). |
| `Mac OS Swiss Knife/StatusBarController.swift` | Fixed root keep-awake rows and presentation-driven rendering | ✓ VERIFIED | Declares the exact fixed keep-awake menu items, subscribes to `keepAwakeSession.objectWillChange`, builds `KeepAwakePresentation`, updates the status row, icon, and tooltip, and keeps quit truthful by stopping active keep-awake before terminate (`StatusBarController.swift:14`, `StatusBarController.swift:59`, `StatusBarController.swift:159`, `StatusBarController.swift:168`, `StatusBarController.swift:194`, `StatusBarController.swift:353`). |
| `Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests.swift` | Timed session replacement and expiry regression coverage | ✓ VERIFIED | Covers confirmed enable before mode change, timed preset persistence, token replacement, expiry disable, and expiry-failure retention (`KeepAwakeSessionModelTests.swift:34`, `KeepAwakeSessionModelTests.swift:48`, `KeepAwakeSessionModelTests.swift:64`, `KeepAwakeSessionModelTests.swift:114`, `KeepAwakeSessionModelTests.swift:136`). |
| `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` | Presentation-copy regression coverage | ✓ VERIFIED | Covers pending copy, infinite copy, countdown-only status row, and no ended banner on failure (`KeepAwakeMenuStateTests.swift:7`, `KeepAwakeMenuStateTests.swift:15`, `KeepAwakeMenuStateTests.swift:23`, `KeepAwakeMenuStateTests.swift:31`). |
| `Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift` | Controller wiring and menu behavior regression coverage | ✓ VERIFIED | Covers exact row order, shared-session dispatch, checkmarks, pending disablement, stable action titles, status-row copy, and symbol/tooltip behavior (`StatusBarControllerKeepAwakeMenuTests.swift:8`, `StatusBarControllerKeepAwakeMenuTests.swift:30`, `StatusBarControllerKeepAwakeMenuTests.swift:52`, `StatusBarControllerKeepAwakeMenuTests.swift:71`, `StatusBarControllerKeepAwakeMenuTests.swift:83`, `StatusBarControllerKeepAwakeMenuTests.swift:100`, `StatusBarControllerKeepAwakeMenuTests.swift:113`). |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `Mac OS Swiss Knife/AppDelegate.swift` | `Mac OS Swiss Knife/StatusBarController.swift` | shared `KeepAwakeSessionModel` injection at app launch | WIRED | `AppDelegate` constructs one `KeepAwakeSessionModel` and passes it into `StatusBarController(keepAwakeSession:)` (`AppDelegate.swift:20`, `AppDelegate.swift:23`, `AppDelegate.swift:65`). |
| `Mac OS Swiss Knife/StatusBarController.swift` | `Mac OS Swiss Knife/KeepAwakeSessionModel.swift` | fixed keep-awake rows dispatch through shared session entry points | WIRED | The six root rows call `startIndefinite()`, `startTimed(...)`, and `stop()` on the injected session (`StatusBarController.swift:304`, `StatusBarController.swift:309`, `StatusBarController.swift:314`, `StatusBarController.swift:319`, `StatusBarController.swift:324`, `StatusBarController.swift:329`). |
| `Mac OS Swiss Knife/StatusBarController.swift` | `Mac OS Swiss Knife/KeepAwakePresentation.swift` | one presentation object drives checkmarks, status row, icon, and tooltip | WIRED | `renderKeepAwakePresentation()` builds `KeepAwakePresentation(...)`, updates action row state/enablement, writes `keepAwakeStatusItem.title`, and sets `button.toolTip`/symbol from presentation fields (`StatusBarController.swift:168`, `StatusBarController.swift:175`, `StatusBarController.swift:184`, `StatusBarController.swift:194`). |
| `Mac OS Swiss Knife/KeepAwakeSessionModel.swift` | `Mac OS Swiss Knife/PowerAssertionManager.swift` | natural expiry disables through the truthful power-control seam | WIRED | `handleTimedExpiry()` calls `powerController.setKeepAwakeEnabled(false, ...)` and only returns to `.off` after confirmed outcome (`KeepAwakeSessionModel.swift:130`, `KeepAwakeSessionModel.swift:136`). |

### Data-Flow Trace

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `Mac OS Swiss Knife/KeepAwakeSessionModel.swift` | `confirmedMode`, `pendingAction`, `countdownNow` | Real keep-awake power-controller outcomes plus countdown scheduler ticks | Yes - state changes only after confirmed enable/disable outcomes and timer callbacks | ✓ FLOWING |
| `Mac OS Swiss Knife/KeepAwakePresentation.swift` | `statusText`, `iconSymbol`, `buttonToolTip` | Shared session state from `confirmedMode`, `pendingAction`, `message`, and `now` | Yes - derived strings and symbols are deterministic functions of the live session state | ✓ FLOWING |
| `Mac OS Swiss Knife/StatusBarController.swift` | keep-awake menu rows, status row, and menu-bar icon | Shared `KeepAwakeSessionModel` via `KeepAwakePresentation` | Yes - menu state is rebuilt from shared session data rather than controller-local booleans | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Targeted keep-awake regression suites | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests'` | Passed on 2026-04-12 before the live menu smoke. | ✓ PASS |
| Full unit-test regression gate | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'` | Passed on 2026-04-12 after live approval with no cross-phase regressions. | ✓ PASS |
| Live menu-bar smoke | Running Debug app plus manual timed keep-awake smoke | Approved: fixed row order, immediate timed replacement, countdown confined to status row, explicit manual stop, and clean expiry all matched the contract. | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `AWAKE-01` | `04-01`, `04-02`, `04-03` | User can enable keep-awake in either indefinite mode or timed mode from native menu controls | ✓ SATISFIED | Fixed root rows route through `keepAwakeSession.startIndefinite()` and `startTimed(...)` (`StatusBarController.swift:304`, `StatusBarController.swift:309`, `StatusBarController.swift:314`, `StatusBarControllerKeepAwakeMenuTests.swift:30`); live smoke approved (`04-HUMAN-UAT.md`). |
| `AWAKE-02` | `04-01`, `04-02` | User can choose from a small set of preset keep-awake durations for timed mode | ✓ SATISFIED | Presets are defined in `KeepAwakeDurationPreset.swift` and surfaced as the exact menu rows `15 分钟`, `30 分钟`, `1 小时`, `2 小时` in the root menu (`KeepAwakeDurationPreset.swift:3`, `StatusBarController.swift:67`, `StatusBarController.swift:76`, `StatusBarController.swift:85`, `StatusBarController.swift:94`, `StatusBarControllerKeepAwakeMenuTests.swift:8`). |
| `AWAKE-03` | `04-01`, `04-02`, `04-03` | User sees a live countdown while a timed keep-awake session is active | ✓ SATISFIED | `KeepAwakePresentation` formats countdown status text from live `now` values (`KeepAwakePresentation.swift:24`, `KeepAwakePresentation.swift:51`), controller renders it only in the disabled status row (`StatusBarController.swift:184`), and tests plus manual smoke confirm the countdown updates without changing action titles (`KeepAwakeMenuStateTests.swift:23`, `StatusBarControllerKeepAwakeMenuTests.swift:83`, `04-HUMAN-UAT.md`). |
| `AWAKE-04` | `04-01`, `04-02`, `04-03` | Keep-awake turns off automatically when the selected timed session expires | ✓ SATISFIED | `handleTimedExpiry()` disables through the power-control seam and confirms off state after success (`KeepAwakeSessionModel.swift:130`), expiry behavior is covered by `KeepAwakeSessionModelTests.testTimedExpiryReturnsToOffOnlyAfterConfirmedDisable()` (`KeepAwakeSessionModelTests.swift:114`), and the live smoke approved clean return to off with no ended banner (`04-HUMAN-UAT.md`). |

All requirement IDs declared in phase 04 plan frontmatter are present in `REQUIREMENTS.md`, and Phase 4 fully satisfies `AWAKE-01` through `AWAKE-04`.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No blocker anti-patterns found in the Phase 4 code paths | ℹ️ Info | Implementation is substantive, wired, and covered by both targeted and full-suite tests |

### Human Verification

### 1. Fixed Keep-Awake Root Menu Order

**Test:** Launch the app, open the menu-bar item, and inspect the keep-awake section before `发送 WOL …`.
**Expected:** The rows appear in the exact order `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`, `关闭常亮`, then one disabled status row.
**Why human:** The real AppKit menu surface and scanability still need live inspection.

### 2. Timed Replacement and Countdown Placement

**Test:** Start `15 分钟`, then replace it with `30 分钟` while the session is active.
**Expected:** Replacement is immediate with no confirmation dialog, the countdown resets, and no action title shows remaining time.
**Why human:** Native redraw feel and countdown readability are better judged in the running app.

### 3. Manual Stop and Natural Expiry

**Test:** Use `关闭常亮` during an active session, then run a short timed session to natural expiry.
**Expected:** Both paths return directly to off, keep `关闭常亮` visible, and show no `已结束` banner.
**Why human:** Live menu expiry behavior is the last native-only behavior not fully captured by unit tests.

### Gaps Summary

No code-level gaps were found against the phase must-haves or the Phase 4 requirement IDs. The implementation is present, substantive, wired, and data-backed.

The targeted keep-awake suites and the full `Mac OS Swiss KnifeTests` target both passed on 2026-04-12, and the live menu smoke was approved the same day and recorded in `04-HUMAN-UAT.md`, so the phase status is `passed`.

---

_Verified: 2026-04-12T07:14:31Z_
_Verifier: Codex_
