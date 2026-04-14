<!-- GSD:project-start source:PROJECT.md -->
## Project

**Tools Cat**

Tools Cat is a personal macOS menu bar utility for two everyday jobs: keeping the display awake and waking devices on the local network with Wake-on-LAN. The next iteration focuses on turning the current single-purpose implementation into a stable, polished native tool for daily self-use, with better device management, clearer status feedback, and a more maintainable code structure.

**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

### Constraints

- **Platform**: macOS menu bar app — the product should stay native to the existing AppKit/SwiftUI environment
- **Use case**: Personal daily-use utility — scope should optimize for one user's repeated workflows, not multi-tenant generalization
- **UX direction**: Small, restrained, polished — UI changes should feel native macOS rather than flashy or cross-platform
- **Reliability**: Core menu state must reflect real system/network state — false success is unacceptable for keep-awake and WOL actions
- **Maintainability**: New functionality should reduce coupling, not deepen it — architecture work must create clearer seams around UI state and side effects
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Swift 5.0 - All application, unit test, and UI test code in `Tools Cat/*.swift`, `Tools CatTests/*.swift`, and `Tools CatUITests/*.swift`; the target build settings set `SWIFT_VERSION = 5.0` in `Tools Cat.xcodeproj/project.pbxproj`.
- Bash - Local build and packaging automation in `release.sh` and `build_dmg.sh`.
- Objective-C/C system APIs via Swift imports - The app bridges into Apple frameworks and POSIX APIs through `import Cocoa`, `import IOKit.pwr_mgt`, and `import Darwin` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/PowerAssertionManager.swift`, and `Tools Cat/WOLSender.swift`.
## Runtime
- Native macOS app runtime - The main target is an app bundle (`Tools Cat.app`) in `Tools Cat.xcodeproj/project.pbxproj`.
- macOS 15.6 minimum deployment target - Set as `MACOSX_DEPLOYMENT_TARGET = 15.6` for the project and test targets in `Tools Cat.xcodeproj/project.pbxproj`.
- Menu bar app configuration - `INFOPLIST_KEY_LSUIElement = 1` in `Tools Cat.xcodeproj/project.pbxproj` makes the app run without a standard dock/main window flow.
- None detected - No `Package.swift`, `Package.resolved`, `Podfile`, `Cartfile`, or other dependency manager manifests are present at the project root.
- Lockfile: missing
## Frameworks
- SwiftUI - App entry point and the WOL window content live in `Tools Cat/Tools_CatApp.swift` and `Tools Cat/WOLView.swift`.
- AppKit/Cocoa - Menu bar lifecycle, `NSStatusItem`, and custom `NSWindow` handling are implemented in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/WOLWindow.swift`.
- IOKit Power Management - Display sleep suppression uses `IOPMAssertionCreateWithName` and `IOPMAssertionRelease` in `Tools Cat/PowerAssertionManager.swift`.
- Darwin/POSIX sockets - Wake-on-LAN UDP broadcasting is implemented directly with `socket`, `setsockopt`, `sendto`, `getifaddrs`, and `if_nametoindex` in `Tools Cat/WOLSender.swift`.
- XCTest - Unit test target scaffolding exists in `Tools CatTests/Tools_CatTests.swift`.
- XCUITest - UI test and launch performance scaffolding exist in `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- Xcode project build system - The repo is driven by `Tools Cat.xcodeproj/project.pbxproj`; README instructions point developers to open the Xcode project in `README.md`.
- `xcodebuild` - Local Release builds are scripted in `release.sh` and documented in `README.md`.
- `hdiutil` and `/usr/bin/ditto` - DMG packaging is handled in `build_dmg.sh`.
## Key Dependencies
- SwiftUI (macOS SDK) - Provides the app entry point and WOL form UI in `Tools Cat/Tools_CatApp.swift` and `Tools Cat/WOLView.swift`.
- AppKit/Cocoa (macOS SDK) - Provides status bar, menu, application delegate, and window management in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/WOLWindow.swift`.
- IOKit Power Management (macOS SDK) - Core to the “keep display awake” feature in `Tools Cat/PowerAssertionManager.swift`.
- Darwin / BSD sockets (system libc) - Core to sending Wake-on-LAN magic packets in `Tools Cat/WOLSender.swift`.
- XCTest / XCUITest (Xcode toolchain) - Native Apple test frameworks configured by the `Tools CatTests` and `Tools CatUITests` targets in `Tools Cat.xcodeproj/project.pbxproj`.
- App Sandbox entitlements - The app depends on `Tools Cat/Tools_Cat.entitlements` and corresponding `CODE_SIGN_ENTITLEMENTS` settings in `Tools Cat.xcodeproj/project.pbxproj`.
## Configuration
- No runtime `.env` or secret-based configuration is detected in the repo.
- Build/packaging scripts accept optional shell environment overrides: `SCHEME`, `CONFIG`, `DERIVED`, `DMG_NAME`, `VOL_NAME`, and `OUT_DIR` in `release.sh`, plus `OUT_DIR` in `build_dmg.sh`.
- Networking capability is configured through the App Sandbox entitlement `com.apple.security.network.client` in `Tools Cat/Tools_Cat.entitlements`.
- `Tools Cat.xcodeproj/project.pbxproj` - Target definitions, bundle identifiers, deployment target, entitlements, and generated Info.plist keys.
- `release.sh` - Release build orchestration with `xcodebuild`.
- `build_dmg.sh` - DMG packaging without notarization.
- `README.md` - Developer workflow and release packaging instructions.
## Platform Requirements
- macOS with Xcode - The documented workflow is “use Xcode to open the project and run the `Tools Cat` scheme” in `README.md`.
- Apple command-line build tools - `xcodebuild`, `hdiutil`, and `/usr/bin/ditto` are required by `release.sh` and `build_dmg.sh`.
- Distributed as a signed macOS `.app` bundled into a DMG - Packaging outputs to `dist/Tools-Cat.dmg` via `build_dmg.sh` and `release.sh`.
- Not notarized - `README.md` and `build_dmg.sh` both state the DMG is produced without notarization, so first-run installation requires a manual security approval flow on macOS.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- App source files use `PascalCase.swift` and usually map 1:1 to the main type in the file, for example `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/PowerAssertionManager.swift`.
- SwiftUI view files also use `PascalCase.swift`, with view-oriented suffixes such as `Tools Cat/WOLView.swift` and `Tools Cat/ContentView.swift`.
- Underscores appear only in Xcode-generated target entrypoint and test filenames derived from the target name: `Tools Cat/Tools_CatApp.swift`, `Tools CatTests/Tools_CatTests.swift`, `Tools CatUITests/Tools_CatUITests.swift`, and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- Methods and helpers use lowerCamelCase with verb-led names: `applicationDidFinishLaunching`, `openWOLWindow`, `updateIcon`, `toggleKeepAwake`, `performSend`, `parseMAC`, and `enumerateIPv4Broadcasts` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/WOLSender.swift`.
- Event handlers follow Cocoa/XCTest conventions instead of a custom prefix: `applicationWillTerminate` in `Tools Cat/AppDelegate.swift`, `windowWillClose` in `Tools Cat/WOLWindow.swift`, and `testLaunchPerformance` in `Tools CatUITests/Tools_CatUITests.swift`.
- Boolean state and predicates use `is*` names, for example `isEnabled` in `Tools Cat/PowerAssertionManager.swift` and `isSending` in `Tools Cat/WOLView.swift`.
- Stored properties, locals, and parameters use lowerCamelCase throughout, for example `statusController`, `wolWindow`, `statusItem`, `selectedMac`, `customMac`, `statusText`, and `macString` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/WOLSender.swift`.
- Immutable values are usually `let` and keep lowerCamelCase rather than UPPER_SNAKE_CASE, including `options` in `Tools Cat/WOLView.swift`, `status` in `Tools Cat/AppDelegate.swift`, and `broadcasts` and `allTargets` in `Tools Cat/WOLSender.swift`.
- Access control is preferred over naming markers. Private state is marked with `private` or `private(set)` instead of underscore prefixes, as shown by `private var assertionID`, `private(set) var isEnabled`, and `private var keepAwakeItem` in `Tools Cat/PowerAssertionManager.swift` and `Tools Cat/StatusBarController.swift`.
- Concrete types use PascalCase with role-oriented suffixes: `AppDelegate`, `StatusBarController`, `WOLWindow`, `WOLView`, and `PowerAssertionManager` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/PowerAssertionManager.swift`.
- Supporting enums and structs also use PascalCase, while cases stay lowerCamelCase: `InputMode.custom`, `InputMode.preset`, `DeviceOption`, and `WOLSenderError.invalidMAC` in `Tools Cat/WOLView.swift` and `Tools Cat/WOLSender.swift`.
- Error types are named with an `Error` suffix, as in `WOLSenderError` in `Tools Cat/WOLSender.swift`.
## Code Style
- No repo-local formatter config is present at the project root; there is no `.swiftlint.yml`, `.swiftformat`, or `.editorconfig`. Formatting is inferred from `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLView.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/WOLSender.swift`.
- Indentation follows Xcode-style 4 spaces with opening braces on the same line as declarations and control statements, as seen across `Tools Cat/StatusBarController.swift` and `Tools Cat/WOLSender.swift`.
- Semicolons are omitted. Multi-argument calls break one argument per line when they become long, for example `IOPMAssertionCreateWithName` in `Tools Cat/PowerAssertionManager.swift` and `NotificationCenter.default.addObserver` in `Tools Cat/WOLWindow.swift`.
- User-facing strings and many inline comments are Chinese, while APIs and identifiers remain English. See menu labels in `Tools Cat/StatusBarController.swift` and validation/status strings in `Tools Cat/WOLView.swift`.
- No lint tool configuration is committed. There is no `SwiftLint` or `SwiftFormat` config file in the repository root, and no lint script is referenced from `README.md` or `Tools Cat.xcodeproj/project.pbxproj`.
- Style consistency is enforced manually through the Xcode project and small-file conventions visible in `Tools Cat.xcodeproj/project.pbxproj` and the source files under `Tools Cat/`.
## Import Organization
- Imports are kept as a single contiguous block at the top of each file with no blank lines between groups. See `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/WOLSender.swift`.
- Import order is practical rather than strictly alphabetical. Bridge files usually list AppKit/Cocoa before SwiftUI (`Tools Cat/AppDelegate.swift`, `Tools Cat/WOLWindow.swift`), while pure SwiftUI files start with `SwiftUI` and add helpers such as `Combine` afterward (`Tools Cat/WOLView.swift`).
- Not applicable. The project uses direct same-target type references inside the Xcode app target defined in `Tools Cat.xcodeproj/project.pbxproj`.
## Error Handling
- Use `guard` for fast exits on invalid state or idempotent operations, for example `guard !isEnabled else { return }` and `guard isEnabled else { return }` in `Tools Cat/PowerAssertionManager.swift`, plus `guard !isSending else { return }` in `Tools Cat/WOLView.swift`.
- Throw typed errors from low-level operations and catch them at the UI boundary. `Tools Cat/WOLSender.swift` throws `WOLSenderError`, and `Tools Cat/WOLView.swift` catches `error` inside `performSend(mac:)` to update `statusText`.
- Recoverable validation failures in UI code usually return early with a status message instead of throwing, as shown by the empty-input and invalid-length branches in `Tools Cat/WOLView.swift`.
- Throw when parsing or socket operations fail in `Tools Cat/WOLSender.swift`.
- Return early without logging for expected UI control flow in `Tools Cat/WOLView.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/StatusBarController.swift`.
- No custom `Result` types, no NSError wrapping, and no centralized error presenter are present in the repo.
## Logging
- Logging uses plain `print` statements only, all in `Tools Cat/WOLSender.swift`.
- Prefixes encode severity and subsystem inline, such as `[WOL]`, `[WOL][Warn]`, and `[WOL][Error]` in `Tools Cat/WOLSender.swift`.
- Log external/network boundary details, including socket setup, interface discovery, destination broadcast address, and send result in `Tools Cat/WOLSender.swift`.
- UI, menu bar, and power-assertion code in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/PowerAssertionManager.swift` avoid logging unless they surface state directly through UI.
- There is no structured logger, log level abstraction, or shared logging helper module.
## Comments
- Comments are used sparingly and mostly to label UI sections or explain edge-case behavior. Examples include the UI block comments in `Tools Cat/WOLView.swift` and the broadcast-interface notes in `Tools Cat/WOLSender.swift`.
- When comments appear in hand-written source, they explain intent or fallback behavior rather than restating the code. See the interface filtering and dedup comments in `Tools Cat/WOLSender.swift` and the window-reset comments in `Tools Cat/WOLView.swift`.
- `MARK:` sections are not used in the committed source files under `Tools Cat/`.
- Not applicable. No Swift doc comments (`///`) are present in production code or tests. This is visible in `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLView.swift`, `Tools Cat/WOLSender.swift`, and the test files under `Tools CatTests/` and `Tools CatUITests/`.
- No `TODO` or `FIXME` comments are present in the app or test source directories `Tools Cat/`, `Tools CatTests/`, and `Tools CatUITests/`.
## Function Design
- Keep files small and functions focused. Most helpers handle one responsibility, such as `updateIcon()` and `configure()` in `Tools Cat/StatusBarController.swift`, `openWOLWindow()` in `Tools Cat/AppDelegate.swift`, and `ipv4ToString(_:)` in `Tools Cat/WOLSender.swift`.
- The largest function bodies are concentrated in validation/networking code, notably `send()`, `performSend(mac:)`, and `enumerateIPv4Broadcasts()` in `Tools Cat/WOLView.swift` and `Tools Cat/WOLSender.swift`.
- Parameter counts stay low and are labeled for clarity, for example `send(to:)` in `Tools Cat/WOLSender.swift`, `performSend(mac:)` in `Tools Cat/WOLView.swift`, and `windowWillClose(_:)` in `Tools Cat/WOLWindow.swift`.
- UI callbacks often capture state from properties instead of passing many arguments, as shown by `toggleKeepAwake(_:)`, `openWOL()`, and `quitApp()` in `Tools Cat/StatusBarController.swift`.
- Guard clauses and early returns are preferred over nested `if` pyramids in `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/WOLView.swift`.
- Side-effecting helpers usually return `Void`; only the low-level parser and enumerator helpers in `Tools Cat/WOLSender.swift` return values for further processing.
## Module Design
- The app uses one top-level type per file and relies on Swift's default internal visibility inside the target. See `Tools Cat/AppDelegate.swift`, `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/WOLWindow.swift`.
- Narrower implementation details are `private` or `private(set)`, such as `assertionID` and `isEnabled` in `Tools Cat/PowerAssertionManager.swift`, plus `keepAwakeItem` and `updateIcon()` in `Tools Cat/StatusBarController.swift`.
- Not used. There are no index-style re-export files; types are referenced directly from their defining files in the `Tools Cat` target declared by `Tools Cat.xcodeproj/project.pbxproj`.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- `Tools Cat/Tools_CatApp.swift` is the process entry point, but it exposes only `Settings { EmptyView() }`, so the app does not use a document/window scene as its primary UI.
- `Tools Cat/AppDelegate.swift` owns startup and shutdown orchestration, making the runtime flow AppKit-driven even though the target is declared as a SwiftUI app.
- User interactions split into two side-effect paths: display-sleep prevention via `Tools Cat/PowerAssertionManager.swift` and Wake-on-LAN packet sending via `Tools Cat/WOLSender.swift`.
- The secondary WOL UI is an AppKit `NSWindow` hosting a SwiftUI form (`Tools Cat/WOLWindow.swift` + `Tools Cat/WOLView.swift`).
## Layers
- Purpose: Start the app, register the menu bar controller, and clean up system resources at termination.
- Location: `Tools Cat/Tools_CatApp.swift`, `Tools Cat/AppDelegate.swift`
- Contains: SwiftUI `@main` entry, `NSApplicationDelegate`, retained controller references.
- Depends on: `AppKit`, `SwiftUI`, `StatusBarController`, `WOLWindow`, `PowerAssertionManager`.
- Used by: macOS application launch lifecycle.
- Purpose: Present the status item, build the menu, and translate menu clicks into power-control or WOL actions.
- Location: `Tools Cat/StatusBarController.swift`
- Contains: `NSStatusItem`, `NSMenu`, menu item action handlers, icon state updates.
- Depends on: `AppKit`, `PowerAssertionManager`, callback into `AppDelegate`.
- Used by: `AppDelegate` during `applicationDidFinishLaunching`.
- Purpose: Manage the WOL pop-up window and bridge AppKit window lifecycle with SwiftUI view state.
- Location: `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`
- Contains: `NSWindowController`, `NSHostingView`, SwiftUI form state, device selection UI, send/cancel actions.
- Depends on: `AppKit`, `SwiftUI`, `Combine`, `NotificationCenter`, `WOLSender`.
- Used by: `AppDelegate.openWOLWindow()` and the user-facing WOL workflow.
- Purpose: Encapsulate side effects that touch macOS power management and UDP networking.
- Location: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLSender.swift`
- Contains: singleton state for the IOKit power assertion and a static WOL sender with socket/interface handling.
- Depends on: `Foundation`, `IOKit.pwr_mgt`, `Darwin`.
- Used by: `StatusBarController` and `WOLView`.
- Purpose: Define target boundaries, menu bar packaging, entitlements, and build behavior.
- Location: `Tools Cat.xcodeproj/project.pbxproj`, `Tools Cat/Tools_Cat.entitlements`
- Contains: app/unit-test/UI-test targets, generated Info.plist settings, `LSUIElement = 1`, sandbox/network client entitlement.
- Depends on: Xcode build system.
- Used by: local Xcode runs, `xcodebuild`, `release.sh`, and `build_dmg.sh`.
## Data Flow
- `Tools Cat/WOLWindow.swift` publishes `.WOLWindowWillShow`, `.WOLWindowWillClose`, and `.WOLWindowRequestClose` notifications.
- `Tools Cat/WOLView.swift` listens for those notifications to reset transient status and input state without recreating the window controller.
- Global process state is minimal and in-memory only.
- `Tools Cat/PowerAssertionManager.swift` uses a singleton to hold the active assertion ID and enabled flag.
- `Tools Cat/AppDelegate.swift` retains `StatusBarController` and `WOLWindow` so they survive beyond local scope.
- `Tools Cat/WOLView.swift` stores form state in local `@State` properties (`inputMode`, `selectedMac`, `customMac`, `statusText`, `isSending`).
- There is no persistence layer, database, preferences store, or background daemon.
## Key Abstractions
- Purpose: Keep long-lived Cocoa objects alive for the app lifecycle and menu/window ownership.
- Examples: `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLWindow.swift`
- Pattern: NSObject/NSWindowController instances retained by the delegate instead of recreated per interaction.
- Purpose: Model the WOL input mode, current MAC value, progress state, and user-visible result text.
- Examples: `Tools Cat/WOLView.swift`, `InputMode`, `DeviceOption`, `RadioButton`
- Pattern: Value types and local `@State` within a single view tree hosted by AppKit.
- Purpose: Isolate operating-system and network operations from menu/view code.
- Examples: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLSender.swift`
- Pattern: Singleton service for power management and static utility-style API for WOL transmission.
- Purpose: Decouple the AppKit window controller from the SwiftUI form’s reset/close behavior.
- Examples: `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`
- Pattern: Custom `Notification.Name` events routed through `NotificationCenter.default`.
## Entry Points
- Location: `Tools Cat/Tools_CatApp.swift`
- Triggers: macOS launching the app bundle.
- Responsibilities: Register the application delegate and suppress a normal root window by exposing only an empty Settings scene.
- Location: `Tools Cat/AppDelegate.swift`
- Triggers: `NSApplicationDelegate` lifecycle callbacks.
- Responsibilities: Create the status bar UI, lazily manage the WOL window, and release the power assertion on termination.
- Location: `release.sh`, `build_dmg.sh`
- Triggers: local shell execution for release packaging.
- Responsibilities: Run `xcodebuild`, locate the built `.app`, and create a DMG in `dist/`.
## Error Handling
- `Tools Cat/WOLView.swift` validates empty input and MAC length before calling the network layer.
- `Tools Cat/WOLSender.swift` throws `WOLSenderError` for invalid MACs, socket setup failures, and cases where no broadcast send succeeds.
- `Tools Cat/PowerAssertionManager.swift` uses guard clauses and only mutates state when the underlying IOKit call succeeds.
- `Tools Cat/AppDelegate.swift` and `Tools Cat/StatusBarController.swift` clean up the power assertion explicitly on quit/terminate instead of relying on implicit teardown.
## Cross-Cutting Concerns
- Diagnostic logging is limited to `print(...)` statements in `Tools Cat/WOLSender.swift` for socket creation, interface discovery, binding, and send outcomes.
- UI-level sanitization and length checks live in `Tools Cat/WOLView.swift`.
- Structural MAC parsing is enforced again in `Tools Cat/WOLSender.swift` via `parseMAC(from:)`.
- Not applicable. The app has no user accounts, remote authenticated APIs, or authorization flow.
- `Tools Cat/Tools_Cat.entitlements` enables App Sandbox and `com.apple.security.network.client`.
- `Tools Cat.xcodeproj/project.pbxproj` keeps the app a menu bar utility with `LSUIElement` instead of a docked app.
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
