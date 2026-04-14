# Architecture

**Analysis Date:** 2026-04-11

## Pattern Overview

**Overall:** Hybrid SwiftUI/AppKit menu bar utility with controller-style lifecycle management

**Key Characteristics:**
- `Tools Cat/Tools_CatApp.swift` is the process entry point, but it exposes only `Settings { EmptyView() }`, so the app does not use a document/window scene as its primary UI.
- `Tools Cat/AppDelegate.swift` owns startup and shutdown orchestration, making the runtime flow AppKit-driven even though the target is declared as a SwiftUI app.
- User interactions split into two side-effect paths: display-sleep prevention via `Tools Cat/PowerAssertionManager.swift` and Wake-on-LAN packet sending via `Tools Cat/WOLSender.swift`.
- The secondary WOL UI is an AppKit `NSWindow` hosting a SwiftUI form (`Tools Cat/WOLWindow.swift` + `Tools Cat/WOLView.swift`).

## Layers

**Application Bootstrap Layer:**
- Purpose: Start the app, register the menu bar controller, and clean up system resources at termination.
- Location: `Tools Cat/Tools_CatApp.swift`, `Tools Cat/AppDelegate.swift`
- Contains: SwiftUI `@main` entry, `NSApplicationDelegate`, retained controller references.
- Depends on: `AppKit`, `SwiftUI`, `StatusBarController`, `WOLWindow`, `PowerAssertionManager`.
- Used by: macOS application launch lifecycle.

**Menu Bar Interaction Layer:**
- Purpose: Present the status item, build the menu, and translate menu clicks into power-control or WOL actions.
- Location: `Tools Cat/StatusBarController.swift`
- Contains: `NSStatusItem`, `NSMenu`, menu item action handlers, icon state updates.
- Depends on: `AppKit`, `PowerAssertionManager`, callback into `AppDelegate`.
- Used by: `AppDelegate` during `applicationDidFinishLaunching`.

**Window Presentation Layer:**
- Purpose: Manage the WOL pop-up window and bridge AppKit window lifecycle with SwiftUI view state.
- Location: `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`
- Contains: `NSWindowController`, `NSHostingView`, SwiftUI form state, device selection UI, send/cancel actions.
- Depends on: `AppKit`, `SwiftUI`, `Combine`, `NotificationCenter`, `WOLSender`.
- Used by: `AppDelegate.openWOLWindow()` and the user-facing WOL workflow.

**System and Network Service Layer:**
- Purpose: Encapsulate side effects that touch macOS power management and UDP networking.
- Location: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLSender.swift`
- Contains: singleton state for the IOKit power assertion and a static WOL sender with socket/interface handling.
- Depends on: `Foundation`, `IOKit.pwr_mgt`, `Darwin`.
- Used by: `StatusBarController` and `WOLView`.

**Project Configuration Layer:**
- Purpose: Define target boundaries, menu bar packaging, entitlements, and build behavior.
- Location: `Tools Cat.xcodeproj/project.pbxproj`, `Tools Cat/Tools_Cat.entitlements`
- Contains: app/unit-test/UI-test targets, generated Info.plist settings, `LSUIElement = 1`, sandbox/network client entitlement.
- Depends on: Xcode build system.
- Used by: local Xcode runs, `xcodebuild`, `release.sh`, and `build_dmg.sh`.

## Data Flow

**App Launch and Menu Setup:**

1. macOS launches `Tools Cat/Tools_CatApp.swift`.
2. `@NSApplicationDelegateAdaptor` instantiates `AppDelegate` from `Tools Cat/AppDelegate.swift`.
3. `AppDelegate.applicationDidFinishLaunching` creates `StatusBarController` and assigns `onOpenWOL`.
4. `StatusBarController` builds the `NSStatusItem` menu and chooses the initial symbol from `PowerAssertionManager.shared.isEnabled`.
5. The running app stays resident as a menu bar utility because `Tools Cat.xcodeproj/project.pbxproj` sets `INFOPLIST_KEY_LSUIElement = 1`.

**Keep Display Awake Toggle:**

1. The user clicks the status item and selects the keep-awake menu item in `Tools Cat/StatusBarController.swift`.
2. `toggleKeepAwake(_:)` checks `PowerAssertionManager.shared.isEnabled`.
3. `PowerAssertionManager.enable()` or `PowerAssertionManager.disable()` creates/releases the `kIOPMAssertionTypeNoDisplaySleep` assertion in `Tools Cat/PowerAssertionManager.swift`.
4. `StatusBarController` updates the menu checkmark and status bar icon to reflect the new in-memory state.

**Wake-on-LAN Send Flow:**

1. The user selects "发送 WOL …" in `Tools Cat/StatusBarController.swift`.
2. `StatusBarController.openWOL()` activates the app and calls the `onOpenWOL` closure.
3. `AppDelegate.openWOLWindow()` lazily creates `WOLWindow` from `Tools Cat/WOLWindow.swift` and shows it.
4. `WOLWindow` hosts `WOLView` from `Tools Cat/WOLView.swift` inside an `NSHostingView`.
5. `WOLView.send()` validates the selected or typed MAC address and dispatches `performSend(mac:)` onto a background queue.
6. `WOLSender.send(to:)` in `Tools Cat/WOLSender.swift` parses the MAC, builds the magic packet, enumerates IPv4 broadcast-capable interfaces, optionally binds `IP_BOUND_IF`, and sends UDP broadcasts on port 9.
7. `WOLView` marshals success or failure back to the main queue and updates `statusText`.

**Window State Synchronization:**
- `Tools Cat/WOLWindow.swift` publishes `.WOLWindowWillShow`, `.WOLWindowWillClose`, and `.WOLWindowRequestClose` notifications.
- `Tools Cat/WOLView.swift` listens for those notifications to reset transient status and input state without recreating the window controller.

**State Management:**
- Global process state is minimal and in-memory only.
- `Tools Cat/PowerAssertionManager.swift` uses a singleton to hold the active assertion ID and enabled flag.
- `Tools Cat/AppDelegate.swift` retains `StatusBarController` and `WOLWindow` so they survive beyond local scope.
- `Tools Cat/WOLView.swift` stores form state in local `@State` properties (`inputMode`, `selectedMac`, `customMac`, `statusText`, `isSending`).
- There is no persistence layer, database, preferences store, or background daemon.

## Key Abstractions

**Retained AppKit Controllers:**
- Purpose: Keep long-lived Cocoa objects alive for the app lifecycle and menu/window ownership.
- Examples: `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLWindow.swift`
- Pattern: NSObject/NSWindowController instances retained by the delegate instead of recreated per interaction.

**SwiftUI Form State:**
- Purpose: Model the WOL input mode, current MAC value, progress state, and user-visible result text.
- Examples: `Tools Cat/WOLView.swift`, `InputMode`, `DeviceOption`, `RadioButton`
- Pattern: Value types and local `@State` within a single view tree hosted by AppKit.

**Side-Effect Services:**
- Purpose: Isolate operating-system and network operations from menu/view code.
- Examples: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLSender.swift`
- Pattern: Singleton service for power management and static utility-style API for WOL transmission.

**Notification-Based Window Coordination:**
- Purpose: Decouple the AppKit window controller from the SwiftUI form’s reset/close behavior.
- Examples: `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`
- Pattern: Custom `Notification.Name` events routed through `NotificationCenter.default`.

## Entry Points

**Application Entry:**
- Location: `Tools Cat/Tools_CatApp.swift`
- Triggers: macOS launching the app bundle.
- Responsibilities: Register the application delegate and suppress a normal root window by exposing only an empty Settings scene.

**Lifecycle Coordinator:**
- Location: `Tools Cat/AppDelegate.swift`
- Triggers: `NSApplicationDelegate` lifecycle callbacks.
- Responsibilities: Create the status bar UI, lazily manage the WOL window, and release the power assertion on termination.

**Build/Packaging Entry:**
- Location: `release.sh`, `build_dmg.sh`
- Triggers: local shell execution for release packaging.
- Responsibilities: Run `xcodebuild`, locate the built `.app`, and create a DMG in `dist/`.

## Error Handling

**Strategy:** Fail softly at the UI boundary, throw typed errors from the WOL service, and keep the process alive for subsequent menu interactions.

**Patterns:**
- `Tools Cat/WOLView.swift` validates empty input and MAC length before calling the network layer.
- `Tools Cat/WOLSender.swift` throws `WOLSenderError` for invalid MACs, socket setup failures, and cases where no broadcast send succeeds.
- `Tools Cat/PowerAssertionManager.swift` uses guard clauses and only mutates state when the underlying IOKit call succeeds.
- `Tools Cat/AppDelegate.swift` and `Tools Cat/StatusBarController.swift` clean up the power assertion explicitly on quit/terminate instead of relying on implicit teardown.

## Cross-Cutting Concerns

**Logging:**
- Diagnostic logging is limited to `print(...)` statements in `Tools Cat/WOLSender.swift` for socket creation, interface discovery, binding, and send outcomes.

**Validation:**
- UI-level sanitization and length checks live in `Tools Cat/WOLView.swift`.
- Structural MAC parsing is enforced again in `Tools Cat/WOLSender.swift` via `parseMAC(from:)`.

**Authentication:**
- Not applicable. The app has no user accounts, remote authenticated APIs, or authorization flow.

**Sandboxing and Capabilities:**
- `Tools Cat/Tools_Cat.entitlements` enables App Sandbox and `com.apple.security.network.client`.
- `Tools Cat.xcodeproj/project.pbxproj` keeps the app a menu bar utility with `LSUIElement` instead of a docked app.

---

*Architecture analysis: 2026-04-11*
*Update when major patterns change*
