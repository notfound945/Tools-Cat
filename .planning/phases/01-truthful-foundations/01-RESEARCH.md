# Phase 1: Truthful Foundations - Research

**Researched:** 2026-04-11
**Domain:** Native macOS menu bar reliability hardening for WOL validation, truthful send feedback, and keep-awake state ownership
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Manual MAC Validation
- **D-01:** Manual MAC input must validate in real time rather than only on submit.
- **D-02:** The send action must stay disabled until the entered MAC is fully valid.
- **D-03:** Manual entry accepts only colon-delimited format: `AA:BB:CC:DD:EE:FF`.
- **D-04:** The field should allow free typing and must not auto-rewrite the user's input into a forced format.
- **D-05:** Validation feedback should be specific by error type rather than a single generic error message.

### Wake Result Feedback
- **D-06:** Success messaging must explicitly mean local send only, for example "wake packet sent from this Mac", and must not imply that the target device is already awake.
- **D-07:** Failure messaging must be written in user-understandable language instead of exposing raw technical error strings.
- **D-08:** Starting a new send clears the previous result immediately; once the send completes, only the current attempt's result should be shown.
- **D-09:** Wake results should continue to appear in the existing in-window status area rather than through heavier alerts or extra surfaces.

### Keep-Awake Toggle Semantics
- **D-10:** Keep-awake menu state and menu bar icon must change only after the underlying display-sleep assertion change succeeds.
- **D-11:** While a keep-awake change is in progress, the UI should show an explicit transitional state such as "Turning on..." or "Turning off...".
- **D-12:** Transitional feedback should appear directly in the menu item label.
- **D-13:** If the keep-awake state change fails, the UI must remain on the prior confirmed state and surface a clear failure message.

### Window State Lifecycle
- **D-14:** Closing and reopening the WOL window should preserve unfinished input.
- **D-15:** Reopening the WOL window should clear the previous result message so stale results are not mistaken for current state.
- **D-16:** If the window closes while a send is in progress, the send should continue in the background.
- **D-17:** After reopening following an in-flight send, the user should see the final result of that background send.

### Claude's Discretion
- Exact validation copy for each MAC input error state, as long as error messages stay specific and user-readable.
- Exact success/failure phrasing in Chinese vs English, as long as success is clearly "local send succeeded" rather than "device woke up".
- Exact menu implementation for transitional keep-awake feedback, as long as only confirmed underlying state drives the steady-state menu checkmark and icon.
- Exact persistence mechanism for retaining unfinished WOL input across window close/reopen within the app session.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| WOL-02 | User can still send a Wake-on-LAN packet by manually entering a MAC address when needed | Real-time colon-only validator, draft-preserving WOL session model, and manual-send path staying in the current window |
| RELY-02 | User sees validation errors before an invalid Wake-on-LAN send is attempted | Structured validation result type, disabled send button until valid, and per-error copy mapping |
| RELY-03 | User sees whether the app successfully sent the Wake-on-LAN packet locally or why the local send failed | Typed mapping from `WOLSender` outcomes to user-facing local-send messages in the existing status area |
| RELY-05 | User sees keep-awake menu state only when the underlying display-sleep assertion state actually changed | Outcome-returning power assertion API plus controller-owned pending state so menu/icon update only on confirmed success |
</phase_requirements>

## Summary

This phase is primarily a truth-contract cleanup, not a feature expansion. The current repo already has the right native boundaries: AppKit owns the menu bar and secondary window, SwiftUI owns the WOL form, `WOLSender` owns UDP broadcast work, and `PowerAssertionManager` owns the IOKit assertion. The planning priority is to make those boundaries return truthful results and move lifecycle-sensitive UI state to an owner that outlives transient window visibility.

The current code reveals three concrete trust failures. `WOLView` accepts any 12 hex characters after stripping punctuation even though the user decision is colon-only manual entry; it also interpolates raw errors into the UI and clears state on close/show in ways that conflict with the lifecycle decisions. `StatusBarController` flips the menu item and icon immediately, while `PowerAssertionManager.disable()` drops state without checking whether `IOPMAssertionRelease` actually succeeded. The installed macOS 26.2 SDK also marks the assertion constant currently used by the app as deprecated, so the plan should avoid deepening that surface while touching the manager anyway.

**Primary recommendation:** Keep the existing AppKit + SwiftUI architecture, add a small AppKit-owned WOL session model plus a dedicated MAC validator, and make keep-awake UI derive from typed `PowerAssertionManager` outcomes instead of optimistic toggles.

## Project Constraints (from CLAUDE.md)

- Stay in the native macOS AppKit/SwiftUI environment already used by the project.
- Optimize for a personal daily-use utility; do not generalize into a multi-user or automation-heavy design.
- Keep the UI restrained and native to macOS rather than adding heavier surfaces or flashy interaction patterns.
- False success is unacceptable for both WOL and keep-awake state; visible UI must reflect real local outcomes only.
- Architecture changes should reduce coupling and create clearer seams around side effects and UI state.
- Follow the existing repo conventions: one main type per file, flat target structure, English identifiers, and Chinese runtime strings.
- Preserve the current GSD workflow discipline for later implementation work; planner recommendations should assume phase execution happens inside GSD, not via ad hoc edits.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS SDK 26.2, deployment target 15.6 | WOL form, bindings, status area | Already in the app, integrates cleanly with `NSHostingView`, and is sufficient for real-time validation feedback without adding dependencies |
| AppKit/Cocoa | macOS SDK 26.2 | `NSStatusItem`, `NSMenu`, `NSWindowController`, window lifecycle | Required for truthful menu state and the current menu bar shell; no reason to replace it in Phase 1 |
| IOKit Power Management | macOS SDK 26.2 | Display-sleep assertion creation and release | Official system API for keep-awake behavior; planner should keep this as the single source of truth |
| Darwin / BSD sockets | macOS SDK 26.2 | Wake-on-LAN packet broadcast | Existing `WOLSender` already uses the correct system-level transport boundary for local WOL sends |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine `ObservableObject` | macOS SDK 26.2 | Reference-type session state shared between AppKit owner and SwiftUI view | Use for WOL draft/send/result state that must survive window close/reopen inside the same app session |
| XCTest | Xcode 26.2 | Unit testing validator, message mapping, and controller state transitions | Use for all new Phase 1 behavioral tests |
| XCUITest | Xcode 26.2 | Existing launch/smoke coverage | Keep for full-suite regression coverage; do not rely on it as the primary Phase 1 verification mechanism |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Notification-driven view-local WOL state | AppKit-owned `ObservableObject` session injected into `WOLView` | Adds one small type, but removes close/show reset bugs and makes background-send semantics explicit |
| Raw `Error` interpolation in the status text | Typed user-facing result mapping | Slightly more code, but required for truthful and understandable feedback |
| Deprecated `kIOPMAssertionTypeNoDisplaySleep` | `kIOPMAssertPreventUserIdleDisplaySleep` | Low-risk cleanup while touching the manager; keeps the phase aligned with the current SDK guidance |

**Installation:**
```bash
# No package installation is required for this phase.
# Verified local toolchain:
xcodebuild -version
swiftc --version
```

**Version verification:** No third-party packages are used by this repo. Verified locally on 2026-04-11:
- `xcodebuild`: Xcode 26.2 (Build 17C52)
- `swiftc`: Apple Swift 6.2.3
- macOS SDK: `MacOSX26.2.sdk`
- Host OS: macOS 15.7.4
- Project deployment target: macOS 15.6 in `Mac OS Swiss Knife.xcodeproj/project.pbxproj`

## Architecture Patterns

### Recommended Project Structure
```text
Mac OS Swiss Knife/
├── WOLSessionModel.swift        # AppKit-owned WOL draft/send/result state
├── WOLView.swift                # SwiftUI form bound to the session model
├── WOLSender.swift              # UDP send boundary + typed transport errors
├── PowerAssertionManager.swift  # IOKit assertion boundary returning outcomes
├── StatusBarController.swift    # Menu/controller deriving UI from confirmed state
└── WOLWindow.swift              # Window owner that injects the session model
```

Keep the existing flat app-target layout. Do not introduce a new subsystem or dependency container just for this phase.

### Pattern 1: AppKit-Owned WOL Session State
**What:** Put draft input, validation result, send progress, and visible wake-result state in one reference-type model owned by `WOLWindow` or `AppDelegate`, then inject it into `WOLView`.
**When to use:** Any WOL state that must survive window close/reopen or background send completion.
**Example:**
```swift
// Source: https://developer.apple.com/documentation/swiftui/observedobject
// Source: https://developer.apple.com/documentation/swiftui/stateobject
final class WOLSessionModel: ObservableObject {
    @Published var customMac = ""
    @Published private(set) var validation: ManualMACValidation = .empty
    @Published private(set) var sendState: WakeSendState = .idle

    func updateCustomMAC(_ newValue: String) {
        customMac = newValue
        validation = ManualMACValidator.validate(newValue)
    }
}

struct WOLView: View {
    @ObservedObject var session: WOLSessionModel

    var body: some View {
        TextField("请输入 MAC 地址", text: Binding(
            get: { session.customMac },
            set: session.updateCustomMAC
        ))
    }
}
```

### Pattern 2: Separate Validation Contract from Transport Contract
**What:** Use a dedicated manual-input validator for the colon-delimited UI contract, while keeping `WOLSender` as a defensive transport boundary.
**When to use:** Manual MAC entry and button enablement logic.
**Example:**
```swift
// Source: https://developer.apple.com/documentation/swiftui/textfield
enum ManualMACValidation {
    case empty
    case invalidCharacters
    case missingSeparators
    case wrongGroupCount
    case wrongByteLength
    case valid(String)

    var userMessage: String? {
        switch self {
        case .empty:
            return "请填写 MAC 地址"
        case .invalidCharacters:
            return "MAC 地址只能包含 0-9、A-F 和冒号"
        case .missingSeparators:
            return "请输入冒号分隔格式，例如 AA:BB:CC:DD:EE:FF"
        case .wrongGroupCount, .wrongByteLength:
            return "MAC 地址必须是 6 组两位十六进制字符"
        case .valid:
            return nil
        }
    }
}
```

### Pattern 3: Confirmed State and Transitional State Must Be Separate
**What:** Keep one confirmed keep-awake state derived from the IOKit boundary and one pending transition used only for temporary menu copy and disabled interaction.
**When to use:** Keep-awake toggle handling in `StatusBarController`.
**Example:**
```swift
// Source: https://developer.apple.com/documentation/appkit/nsmenuitem
enum KeepAwakeTransition {
    case turningOn
    case turningOff
}

struct KeepAwakePresentation {
    var confirmedEnabled: Bool
    var pending: KeepAwakeTransition?

    var title: String {
        switch pending {
        case .turningOn:
            return "保持屏幕常亮（正在开启...）"
        case .turningOff:
            return "保持屏幕常亮（正在关闭...）"
        case nil:
            return "保持屏幕常亮"
        }
    }
}
```

### Pattern 4: Service Outcomes First, User Copy Second
**What:** Low-level boundaries return typed failures or success; UI layers map those to user-readable copy in Chinese.
**When to use:** `WOLSender` send results and `PowerAssertionManager` enable/disable results.
**Example:**
```swift
// Source: local repo pattern in WOLSender.swift + PowerAssertionManager.swift
enum WakeSendMessage {
    case idle
    case sending
    case success(String)
    case failure(String)
}

extension WOLSenderError {
    var userMessage: String {
        switch self {
        case .invalidMAC:
            return "MAC 地址格式无效"
        case .socketFailed:
            return "无法创建本地网络发送通道"
        case .setsockoptFailed:
            return "无法启用局域网广播发送"
        case .sendFailed:
            return "未能从这台 Mac 发出唤醒数据包"
        }
    }
}
```

### Anti-Patterns to Avoid
- **Notification-only lifecycle ownership:** Do not keep piling more `NotificationCenter` resets into `WOLView`; the phase needs a true owner for session state.
- **Copy-dependent styling:** Do not infer success/failure color from whether the text contains `"成功"`; presentation should depend on explicit state.
- **Optimistic keep-awake toggles:** Do not set menu checkmarks or icons before the IOKit call reports success.
- **Input auto-reformatting:** Do not rewrite the user's typing into a forced MAC format; validation is required, masking is not.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Wake verification | Ping/reachability logic to claim the target machine actually woke up | Truthful local-send messaging only | WOL cannot prove remote wake; adding verification in this phase would create new false negatives, network complexity, and scope creep |
| Manual MAC formatting | Aggressive input mask or auto-inserted separators | Plain `TextField` plus validator and disabled send button | The user explicitly rejected forced reformatting, and input masks make edit/delete edge cases worse |
| Cross-window state orchestration | A custom event bus or more ad hoc notifications | One small AppKit-owned `ObservableObject` session model | This phase needs persistent truth, not a second state system |
| Keep-awake success tracking | UI-only booleans that pretend the assertion changed | `PowerAssertionManager` returning typed enable/disable outcomes | Only the IOKit boundary knows whether the assertion actually changed |

**Key insight:** The planner should treat this phase as a source-of-truth correction. The correct answer is not "more status UI"; it is "fewer lies between the boundary and the UI."

## Common Pitfalls

### Pitfall 1: UI Validation and Sender Parsing Drift
**What goes wrong:** Manual entry accepts input that the user contract says is invalid, or errors appear only after tapping send.
**Why it happens:** `WOLSender.parseMAC` currently strips all non-hex characters, while Phase 1 requires colon-delimited manual entry only.
**How to avoid:** Add a dedicated manual validator with structured error states and use it for button enablement plus inline feedback.
**Warning signs:** Non-colon input such as `AABBCCDDEEFF` reaches `performSend(mac:)`, or the send button is enabled while a validation message is visible.

### Pitfall 2: False-Positive Wake Messaging
**What goes wrong:** Success text implies the target device is already awake, or failure text leaks raw technical errors.
**Why it happens:** The current view shows `"发送成功"` on `try` and `"发送失败：\(error)"` on catch, which conflates transport truth with user outcome messaging.
**How to avoid:** Map transport results to explicit "packet sent from this Mac" and user-readable local failure messages in the existing status area.
**Warning signs:** Status copy mentions the target booting, waking, or being online; or the UI shows enum/debug text.

### Pitfall 3: Premature Keep-Awake UI Mutation
**What goes wrong:** The checkmark and menu bar icon change even when the underlying assertion did not.
**Why it happens:** `StatusBarController.toggleKeepAwake(_:)` mutates UI immediately, and `PowerAssertionManager.disable()` currently ignores the `IOPMAssertionRelease` return value.
**How to avoid:** Make enable/disable return explicit outcomes, hold a temporary pending state in the controller, and commit steady-state UI only after success.
**Warning signs:** The menu flips instantly before any boundary result exists, or disable failures are impossible to detect.

### Pitfall 4: Lifecycle Resets Erasing the Wrong State
**What goes wrong:** Closing the WOL window clears unfinished input, or reopening clears the result from a background send that finished while the window was closed.
**Why it happens:** `WOLView` currently clears inputs on close and clears result/progress state on show via notifications.
**How to avoid:** Move persistent WOL state to a session owner and clear stale results deliberately based on whether a send was still in flight at close time.
**Warning signs:** Reopening always shows a blank form and blank status, regardless of what happened before close.

### Pitfall 5: Notification Observer Duplication
**What goes wrong:** Repeated window shows register duplicate close observers, making future lifecycle behavior harder to reason about.
**Why it happens:** `WOLWindow.show()` calls `setupNotificationListener()` every time.
**How to avoid:** Register once during controller setup, or reduce the notification surface after moving to an owned session model.
**Warning signs:** Multiple close callbacks or lifecycle code that becomes increasingly hard to trace.

## Code Examples

Verified patterns from official sources and current repo seams:

### Inject AppKit-Owned Truth into SwiftUI
```swift
// Source: https://developer.apple.com/documentation/swiftui/observedobject
final class WOLWindow: NSWindowController {
    private let session = WOLSessionModel()

    init() {
        let hosting = NSHostingView(rootView: WOLView(session: session))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
```

### Keep-Awake Boundary Returning a Real Outcome
```swift
// Source: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/IOKit.framework/Headers/pwr_mgt/IOPMLib.h
enum PowerAssertionError: Error {
    case enableFailed(IOReturn)
    case disableFailed(IOReturn)
}

func disable() -> Result<Void, PowerAssertionError> {
    guard isEnabled else { return .success(()) }
    let result = IOPMAssertionRelease(assertionID)
    guard result == kIOReturnSuccess else {
        return .failure(.disableFailed(result))
    }
    assertionID = 0
    isEnabled = false
    return .success(())
}
```

### Send Button Enablement Driven by Validation
```swift
// Source: https://developer.apple.com/documentation/swiftui/textfield
Button("发送魔术包") {
    session.send()
}
.disabled(session.sendState == .sending || !session.validation.isValid)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| View-local state plus notification resets | External source of truth injected into SwiftUI via observable model | Current SwiftUI guidance | Better fit when AppKit owns the lifecycle and the view must reflect external state truthfully |
| Raw transport errors shown directly in UI | Typed failures mapped to user-facing copy | Current app-quality expectation | Keeps status truthful and understandable without exposing implementation details |
| `kIOPMAssertionTypeNoDisplaySleep` | `kIOPMAssertPreventUserIdleDisplaySleep` | Deprecated in macOS 10.7 per the installed SDK header | Planner should avoid adding more code around a deprecated assertion type while touching the manager |

**Deprecated/outdated:**
- `kIOPMAssertionTypeNoDisplaySleep`: Deprecated in the installed `IOPMLib.h`; the header directs callers to `kIOPMAssertPreventUserIdleDisplaySleep` instead.
- Success-by-copy heuristics: Styling or state inferred from message text is fragile; presentation should follow explicit state enums.

## Open Questions

1. **Where should keep-awake failure copy appear after a failed toggle?**
   - What we know: The user wants transitional copy in the menu item label and a clear failure message if the assertion change fails.
   - What's unclear: Whether failure should stay in that same menu label briefly or appear as a second disabled status row.
   - Recommendation: Keep the failure surface inside the menu for Phase 1 so the feature remains small and native.

2. **Should the deprecated display-sleep assertion constant be replaced inside this phase?**
   - What we know: The current SDK marks the constant in use as deprecated and points to a replacement.
   - What's unclear: Whether any product-level behavior differs on current macOS for this app's simple use case.
   - Recommendation: Treat the constant replacement as part of the manager hardening work, not as a separate future cleanup.

3. **How much NotificationCenter lifecycle code should remain after adding a WOL session model?**
   - What we know: The current notification path causes state-reset bugs and observer duplication risk.
   - What's unclear: Whether window close requests still justify one notification for the cancel button.
   - Recommendation: Keep only the close-request notification if it still reduces coupling; remove state-reset notifications from the planning path.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| macOS host runtime | Running the app and macOS UI tests | ✓ | 15.7.4 | — |
| Xcode / `xcodebuild` | Build, unit tests, UI tests | ✓ | 26.2 | — |
| Apple Swift compiler | App and test compilation | ✓ | 6.2.3 | — |
| macOS SDK | AppKit, SwiftUI, IOKit, Darwin APIs | ✓ | 26.2 SDK | — |

**Missing dependencies with no fallback:**
- None.

**Missing dependencies with fallback:**
- None.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest and XCUITest via Xcode 26.2 |
| Config file | none — test targets are configured in `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| Quick run command | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'` |
| Full suite command | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'` |

Current verification status on 2026-04-11: the full suite ran successfully on this machine (`** TEST SUCCEEDED **`), but the existing tests are boilerplate and do not cover Phase 1 behavior.

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| WOL-02 | Manual entry remains available through the WOL window and accepts only the allowed colon-delimited format | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests'` | ❌ Wave 0 |
| RELY-02 | Validation errors appear before send and the send button stays disabled while invalid | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` | ❌ Wave 0 |
| RELY-03 | UI shows local-send success or user-readable local failure in the status area | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests'` | ❌ Wave 0 |
| RELY-05 | Keep-awake menu state changes only after the assertion boundary reports success | unit + manual smoke | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'`
- **Per wave merge:** `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'`
- **Phase gate:** Full suite green plus one manual smoke of actual keep-awake toggle behavior before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `Mac OS Swiss KnifeTests/MACAddressValidatorTests.swift` — covers WOL-02 and RELY-02
- [ ] `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` — covers RELY-02, D-14, D-15, D-16, and D-17
- [ ] `Mac OS Swiss KnifeTests/WOLSendPresentationTests.swift` — covers RELY-03
- [ ] `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` — covers RELY-05
- [ ] A fake-able seam for WOL sending and power assertion outcomes — required so tests can assert truthful UI transitions without performing real network or IOKit calls

## Sources

### Primary (HIGH confidence)
- Local repo files:
  - `Mac OS Swiss Knife/WOLView.swift`
  - `Mac OS Swiss Knife/WOLSender.swift`
  - `Mac OS Swiss Knife/PowerAssertionManager.swift`
  - `Mac OS Swiss Knife/StatusBarController.swift`
  - `Mac OS Swiss Knife/WOLWindow.swift`
  - `Mac OS Swiss Knife/AppDelegate.swift`
  - `Mac OS Swiss Knife.xcodeproj/project.pbxproj`
- Installed SDK header: `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.2.sdk/System/Library/Frameworks/IOKit.framework/Headers/pwr_mgt/IOPMLib.h` - checked `IOPMAssertionCreateWithName`, success semantics, and deprecation of `kIOPMAssertionTypeNoDisplaySleep`
- Official Apple documentation:
  - https://developer.apple.com/documentation/swiftui/observedobject
  - https://developer.apple.com/documentation/swiftui/stateobject
  - https://developer.apple.com/documentation/swiftui/textfield
  - https://developer.apple.com/documentation/foundation/observableobject
  - https://developer.apple.com/documentation/appkit/nsmenuitem
  - https://developer.apple.com/documentation/appkit/nswindowcontroller
  - https://developer.apple.com/documentation/appkit/nsmenuvalidation

### Secondary (MEDIUM confidence)
- README.md and planning artifacts:
  - `.planning/phases/01-truthful-foundations/01-CONTEXT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/ROADMAP.md`
  - `.planning/STATE.md`
  - `README.md`

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - verified directly from the repo, local toolchain, and official Apple SDK/header sources
- Architecture: MEDIUM - the recommended session-owner split is strongly supported by repo behavior and Apple SwiftUI object-ownership guidance, but the exact seam remains a planning choice
- Pitfalls: HIGH - they are visible in the current code and, for the power API, confirmed by the installed SDK header

**Research date:** 2026-04-11
**Valid until:** 2026-05-11
