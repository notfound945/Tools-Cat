# Phase 22: WOL Result Timeout - Research

**Researched:** 2026-05-06
**Domain:** Native macOS WOL feedback lifecycle in shared session state
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Result visibility lifetime
- **D-01:** A completed WOL result, whether success or failure, should remain visible for approximately 3 seconds and then disappear automatically.
- **D-02:** The same 3-second lifetime applies in both result surfaces that already reflect WOL session state: the dedicated WOL window status text and the menu-bar wake status row.
- **D-03:** The timeout starts from when the final result is available to render, not from when packet sending begins.

### Consecutive wake behavior
- **D-04:** Starting a new wake action must cancel any previous pending clear so an older timer never removes newer feedback.
- **D-05:** Beginning a new wake action should replace stale completed-result UI with the in-progress sending state immediately, using the session model as the single source of truth.

### Scope and regression guardrails
- **D-06:** Keep the existing success and failure copy unchanged; this phase only changes feedback lifetime.
- **D-07:** Keep the current `快速 WOL` and `发送 WOL …` wake surfaces unchanged; only the transient status behavior is in scope.
- **D-08:** Keep the existing delayed validation reveal and saved-device form behavior untouched; save-button affordance work belongs to Phase 23.

### Claude's Discretion
- Choose the exact scheduling mechanism and timer abstraction as long as result expiry remains deterministic and cancellable in tests.
- Decide whether any hidden-window edge handling needs small session-model cleanup details, as long as the 3-second timeout still governs the same completed result and no stale feedback survives indefinitely.

### Deferred Ideas (OUT OF SCOPE)
- Saved-device `保存设备` button enable/disable affordance based on required-field completeness — Phase 23.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| WOLF-01 | User sees a WOL send result in the WOL window for `3 秒`, after which it disappears automatically | Use `WOLSessionModel` as the only timeout owner, schedule clear when the final result is published, and keep `WOLView` passive. |
| WOLF-02 | User sees the same WOL send result in the menu-bar wake section for `3 秒`, after which it disappears automatically | Keep `StatusBarController.updateWakeStatusItem()` derived only from `sendState` and `lastCompletedWake`; once the shared session clears, the menu row hides automatically. |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

- Stay native to the existing AppKit/SwiftUI macOS menu-bar architecture.
- Preserve the small, restrained native macOS UX; no feature expansion or menu restructuring in this phase.
- Keep reliability as the top constraint: menu state must reflect real session state.
- Keep new behavior in maintainable seams that reduce coupling rather than duplicating UI state.
- Respect the existing repo conventions: Swift source, 4-space indentation, small focused functions, sparse comments, Chinese user-facing strings, and no doc-comment/TODO churn.
- Use the existing XCTest/XCUITest setup in `Tools Cat.xcodeproj`; no new external test framework is needed.
- Deployment target remains macOS 14.0; do not plan anything that requires a newer runtime contract.

## Summary

This phase should be implemented entirely in the shared WOL session layer, not in the view layer. `WOLView` already renders the window status from `session.sendState`, and `StatusBarController` already renders the menu-bar wake status row from `wolSession.sendState` plus `lastCompletedWake`. That means one deterministic timeout in `WOLSessionModel` can satisfy both WOLF-01 and WOLF-02 without adding per-surface timers.

The current worktree already contains partial Phase 22 edits: `WOLSessionModel.swift` has an injected `WakeResultClearing` seam and `WOLSessionModelTests.swift` has new timeout tests. That is the right implementation direction. However, a focused validation run on 2026-05-06 crashed in `WOLSessionModelTests.testHiddenWindowReceivesFinalResult`, so planning must treat baseline stabilization as part of execution rather than assuming the current dirty state is safe to extend blindly.

**Primary recommendation:** Keep the timeout owned by `WOLSessionModel`, implemented as one cancellable delayed clear token that starts when the completed result is published and is canceled before any new wake action begins.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Swift language mode | 5.0 in project settings | App and tests | Existing repo contract; no migration work is needed for this phase. |
| Swift Concurrency (`Task`, `MainActor`) | Swift 6.2.3 toolchain installed locally | Non-blocking delayed clear, main-actor UI publication | Apple-standard way to schedule cancellable async work without blocking threads. |
| SwiftUI + Combine | macOS SDK from Xcode 26.2, deployment target macOS 14.0 | Window rendering from `@ObservedObject` / `@Published` state | Already drives `WOLView` and window resizing reactions. |
| AppKit | macOS SDK from Xcode 26.2, deployment target macOS 14.0 | Menu-bar wake status row | Existing menu architecture is already AppKit-owned. |
| XCTest | Xcode 26.2 | Deterministic unit/controller verification | Existing suite already covers `WOLSessionModel` and `StatusBarController`. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `DispatchQueue` | System framework | Background send work queue | Keep existing send path unchanged; only the result-clear path needs coordination. |
| XCUITest | Xcode 26.2 | Existing direct-launch smoke coverage | Use only if execution adds or depends on a new visible UI contract beyond controller seams. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Session-owned cancellable clear abstraction | `DispatchQueue.main.asyncAfter` directly in a view/controller | Simpler initially, but breaks single-source-of-truth and is hard to cancel/test safely. |
| `Task.sleep`-backed token | `Timer` / `DispatchSourceTimer` | Both can work, but `Task.sleep` is already cancellable, non-blocking, and fits the current async/test style better. |

**Installation:**
```bash
# None. This phase uses only system frameworks already present in the Xcode project.
```

**Version verification:** Verified locally on 2026-05-06 with `xcodebuild -version` (`Xcode 26.2`, build `17C52`) and `swift --version` (`Apple Swift version 6.2.3`). No external package registry is involved.

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── WOLSessionModel.swift      # Owns send lifecycle, published state, and timeout scheduling
├── WOLView.swift              # Renders window status from session state only
├── StatusBarController.swift  # Renders wake status row from session state only
└── WOLWindow.swift            # Window shell and layout observer, not timeout owner

Tools CatTests/
├── WOLSessionModelTests.swift         # Result-clear timing and cancellation truth
└── StatusBarControllerWakeMenuTests.swift  # Menu-bar wake row behavior from shared session state
```

### Pattern 1: Session-Owned Transient Result Lifecycle
**What:** Treat `WOLSessionModel` as the only owner of result visibility lifetime.
**When to use:** Any state transition that must stay identical in the WOL window and the menu bar.
**Example:**
```swift
// Source: Tools Cat/WOLSessionModel.swift
Task { @MainActor [weak self] in
    guard let self else { return }
    self.lastCompletedWake = outcome
    self.sendState = outcome.wasSuccessful ? .success(message: outcome.message) : .failure(message: outcome.message)
    self.scheduleWakeResultClear()
}
```

### Pattern 2: Cancellable Delayed Clear Token
**What:** Schedule result expiry with a token that can be canceled before the next send starts.
**When to use:** Any transient UI feedback that must never let an old timer mutate newer state.
**Example:**
```swift
// Source: https://developer.apple.com/documentation/swift/task/sleep%28nanoseconds%3A%29/
let task = Task {
    try? await Task.sleep(nanoseconds: 3_000_000_000)
    guard !Task.isCancelled else { return }
    await action()
}
```

### Pattern 3: Passive Surface Rendering
**What:** Keep `WOLView` and `StatusBarController` as renderers of published session state.
**When to use:** This entire phase.
**Example:**
```swift
// Source: Tools Cat/StatusBarController.swift
switch wolSession.sendState {
case .sending:
    wakeStatusItem.title = WakeSendMessage.sending.text ?? ""
    wakeStatusItem.isHidden = false
case .idle, .success, .failure:
    if let message = wolSession.lastCompletedWake?.message {
        wakeStatusItem.title = message
        wakeStatusItem.isHidden = false
    } else {
        wakeStatusItem.title = ""
        wakeStatusItem.isHidden = true
    }
}
```

### Anti-Patterns to Avoid
- **View-local timers:** Do not add a timeout in `WOLView` or `StatusBarController`; that would split lifetime truth across surfaces.
- **Untracked delayed callbacks:** Avoid bare `asyncAfter` or `Timer.scheduledTimer` calls without a cancellation token.
- **Publishing off the main actor:** `@Published` updates for `sendState` and `lastCompletedWake` should remain main-actor serialized.
- **Clearing `lastCompletedWake` on send start:** The menu row already switches to `.sending` based on `sendState`; clearing the completion record early creates unnecessary state churn and complicates hidden-window behavior.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Shared 3-second expiry | Separate timers in the window and menu bar | One scheduler/token seam in `WOLSessionModel` | Prevents drift between surfaces and keeps one cancellation point. |
| Timer cancellation tracking | Ad-hoc booleans or timestamp comparisons | `WakeResultClearToken.cancel()` | Explicit cancellation is simpler to reason about and test. |
| Async verification | Real 3-second sleeps in tests | Fake `WakeResultClearing` plus XCTest async expectations | Keeps tests fast and deterministic. |
| UI state duplication | A second “wake status” model in `StatusBarController` | Existing `sendState` + `lastCompletedWake` | The controller already derives the row from shared session state. |

**Key insight:** This phase is not a UI problem. It is a lifecycle/coherency problem, and the repo already has the correct abstraction boundary for solving it in one place.

## Common Pitfalls

### Pitfall 1: Older Timer Clears Newer Feedback
**What goes wrong:** A result from send A schedules a clear, send B starts, and send A's timer later clears send B's state.
**Why it happens:** The old timeout is not canceled before the new send begins.
**How to avoid:** Cancel and nil out the existing clear token at the very start of `send(targetMACAddress:savedDeviceID:)`.
**Warning signs:** A second successful wake briefly shows success, then disappears too early.

### Pitfall 2: Window/Menu Surfaces Drift Apart
**What goes wrong:** The WOL window hides the result but the menu row still shows it, or vice versa.
**Why it happens:** Timeout or clear logic is added outside `WOLSessionModel`.
**How to avoid:** Keep both surfaces derived from `sendState` and `lastCompletedWake` only.
**Warning signs:** A test can pass for one surface while the other keeps stale text.

### Pitfall 3: Hidden-Window Preservation Fights Timeout
**What goes wrong:** `preservesHiddenCompletionResult` keeps stale feedback alive longer than intended, or a reopen unexpectedly restarts the lifetime.
**Why it happens:** Hidden-window reopening is treated as a new result event instead of a view of the existing result.
**How to avoid:** Start the timer when the completed result is published, not when the window reopens.
**Warning signs:** Reopening the WOL window extends the visible lifetime beyond roughly 3 seconds from completion.

### Pitfall 4: Async Test Flakiness or Crashes
**What goes wrong:** Timer tests block or crash under concurrency pressure.
**Why it happens:** Real sleeps, non-main-thread publication, or worktree-local regressions in hidden-window flows.
**How to avoid:** Prefer fake schedulers in unit tests and keep one focused green run for `WOLSessionModelTests` before widening the slice.
**Warning signs:** `xcodebuild test -only-testing:'Tools CatTests/WOLSessionModelTests'` is non-deterministic or crashes during hidden-window tests.

## Code Examples

Verified patterns from official sources:

### Cancellable Delayed Clear
```swift
// Source: https://developer.apple.com/documentation/swift/task/sleep%28nanoseconds%3A%29/
let task = Task {
    try? await Task.sleep(nanoseconds: 3_000_000_000)
    guard !Task.isCancelled else { return }
    await action()
}
```

### Main-Actor State Publication
```swift
// Source: https://developer.apple.com/documentation/Swift/MainActor
Task { @MainActor in
    sendState = .idle
    lastCompletedWake = nil
}
```

### Deterministic Async XCTest Pattern
```swift
// Source: https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations
let expectation = expectation(description: "send state matched")
cancellable = model.$sendState.sink { state in
    if predicate(state) {
        expectation.fulfill()
    }
}
await fulfillment(of: [expectation], timeout: 1.0)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Persistent result until manual or incidental cleanup | Transient result scheduled from the shared session after completion | Current v1.8 milestone direction, researched 2026-05-06 | Reduces stale trust-damaging feedback while preserving confirmation time. |
| Surface-local status handling | Shared observable session consumed by both SwiftUI and AppKit | Already established before Phase 22 | Lets one state transition update both result surfaces automatically. |
| Blocking or timer-heavy async tests | Async XCTest plus fake scheduler seams | Current Apple/XCTest guidance and existing repo test style | Keeps regression tests fast and deterministic. |

**Deprecated/outdated:**
- Manual cleanup as the only way to dismiss WOL send feedback: no longer aligned with v1.8 requirements.
- Per-surface timer ownership: architecturally outdated for this repo because the session model already exists.

## Open Questions

1. **Should a hidden result still disappear on absolute completion time even if the window is reopened late?**
   - What we know: D-03 says the timeout starts when the final result is available, not when rendering begins.
   - What's unclear: Whether product intent wants a late reopen to show a result that is almost expired or already expired.
   - Recommendation: Keep the timer absolute from completion. Do not restart lifetime on reopen unless the user explicitly redefines D-03.

2. **What is causing the current `malloc` crash in the dirty worktree's focused WOL model test run?**
   - What we know: `xcodebuild test -only-testing:'Tools CatTests/WOLSessionModelTests'` crashed on 2026-05-06 during `testHiddenWindowReceivesFinalResult`.
   - What's unclear: Whether the regression is in the new timeout code, an interaction with existing hidden-window logic, or a transient worktree-only issue.
   - Recommendation: Make “stabilize WOLSessionModelTests green” an explicit early execution task before broadening validation.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `xcodebuild` | All automated build/test commands | ✓ | Xcode 26.2 (`17C52`) | — |
| `swift` | Toolchain/runtime validation | ✓ | Apple Swift 6.2.3 | — |
| macOS AppKit/SwiftUI SDK | Production code | ✓ | macOS SDK 26.2 installed, app deploys to 14.0 | — |
| XCTest/XCUITest | Unit/controller/UI smoke tests | ✓ | Bundled with Xcode 26.2 | — |
| Bash | Existing verification scripts | ✓ | System shell | — |

**Missing dependencies with no fallback:**
- None found.

**Missing dependencies with fallback:**
- None found.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest / XCUITest (bundled with Xcode 26.2) |
| Config file | none — Xcode project target configuration in `Tools Cat.xcodeproj/project.pbxproj` |
| Quick run command | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests'` |
| Full suite command | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -parallel-testing-enabled NO` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| WOLF-01 | Completed result stays visible in the WOL window for about 3 seconds, then clears | unit | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests/testCompletedWakeResultClearsAfterThreeSeconds'` | ✅ |
| WOLF-01 | New wake cancels stale timeout so newer result is not cleared by the old timer | unit | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests/testNewSendCancelsPreviousWakeResultClear'` | ✅ |
| WOLF-02 | Menu-bar wake status row shows the same completed result and then disappears after the shared clear | controller | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests'` | ✅, but missing timeout-hide assertion |

### Sampling Rate
- **Per task commit:** `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests'`
- **Per wave merge:** `bash scripts/run_menu_bar_verification_slice.sh`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `Tools CatTests/StatusBarControllerWakeMenuTests.swift` — add an assertion that the wake status row hides after the shared timeout clear, not just that it shows success/failure.
- [ ] `Tools CatTests/WOLSessionModelTests.swift` — stabilize the hidden-window regression path so the focused model suite is green before relying on it as the phase safety net.
- [ ] Optional: add a hidden-window expiry test proving reopen does not restart the 3-second lifetime if that edge behavior is implemented explicitly.

## Sources

### Primary (HIGH confidence)
- Local repo: [WOLSessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/WOLSessionModel.swift), [WOLView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/WOLView.swift), [StatusBarController.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/StatusBarController.swift), [WOLSessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/WOLSessionModelTests.swift), [StatusBarControllerWakeMenuTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/StatusBarControllerWakeMenuTests.swift) - existing implementation seam and current validation baseline
- Apple Developer: https://developer.apple.com/documentation/swift/task/sleep%28nanoseconds%3A%29/ - cancellable, non-blocking delayed execution
- Apple Developer: https://developer.apple.com/documentation/Swift/MainActor - main-actor publication model for UI state
- Apple Developer: https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations - recommended async XCTest expectation patterns

### Secondary (MEDIUM confidence)
- Local repo: [scripts/run_menu_bar_verification_slice.sh](/Users/hailinpan/Documents/GitHub/Tools-Cat/scripts/run_menu_bar_verification_slice.sh), [scripts/release/verify-distribution-closure.sh](/Users/hailinpan/Documents/GitHub/Tools-Cat/scripts/release/verify-distribution-closure.sh) - existing verification command boundaries
- Local repo: [CLAUDE.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/CLAUDE.md), [ROADMAP.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md), [22-CONTEXT.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/22-wol-result-timeout/22-CONTEXT.md) - project and phase constraints

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - This phase uses only repo-established Apple frameworks and locally verified tooling.
- Architecture: HIGH - The current code already centralizes WOL state in `WOLSessionModel`, and both result surfaces already subscribe to it.
- Pitfalls: MEDIUM - The failure modes are clear, but the current dirty worktree crash means one hidden-window interaction still needs execution-time confirmation.

**Research date:** 2026-05-06
**Valid until:** 2026-06-05
