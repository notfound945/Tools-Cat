# Coding Conventions

**Analysis Date:** 2026-04-11

## Naming Patterns

**Files:**
- App source files use `PascalCase.swift` and usually map 1:1 to the main type in the file, for example `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/PowerAssertionManager.swift`.
- SwiftUI view files also use `PascalCase.swift`, with view-oriented suffixes such as `Tools Cat/WOLView.swift` and `Tools Cat/ContentView.swift`.
- Underscores appear only in Xcode-generated target entrypoint and test filenames derived from the target name: `Tools Cat/Tools_CatApp.swift`, `Tools CatTests/Tools_CatTests.swift`, `Tools CatUITests/Tools_CatUITests.swift`, and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.

**Functions:**
- Methods and helpers use lowerCamelCase with verb-led names: `applicationDidFinishLaunching`, `openWOLWindow`, `updateIcon`, `toggleKeepAwake`, `performSend`, `parseMAC`, and `enumerateIPv4Broadcasts` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/WOLSender.swift`.
- Event handlers follow Cocoa/XCTest conventions instead of a custom prefix: `applicationWillTerminate` in `Tools Cat/AppDelegate.swift`, `windowWillClose` in `Tools Cat/WOLWindow.swift`, and `testLaunchPerformance` in `Tools CatUITests/Tools_CatUITests.swift`.
- Boolean state and predicates use `is*` names, for example `isEnabled` in `Tools Cat/PowerAssertionManager.swift` and `isSending` in `Tools Cat/WOLView.swift`.

**Variables:**
- Stored properties, locals, and parameters use lowerCamelCase throughout, for example `statusController`, `wolWindow`, `statusItem`, `selectedMac`, `customMac`, `statusText`, and `macString` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/WOLSender.swift`.
- Immutable values are usually `let` and keep lowerCamelCase rather than UPPER_SNAKE_CASE, including `options` in `Tools Cat/WOLView.swift`, `status` in `Tools Cat/AppDelegate.swift`, and `broadcasts` and `allTargets` in `Tools Cat/WOLSender.swift`.
- Access control is preferred over naming markers. Private state is marked with `private` or `private(set)` instead of underscore prefixes, as shown by `private var assertionID`, `private(set) var isEnabled`, and `private var keepAwakeItem` in `Tools Cat/PowerAssertionManager.swift` and `Tools Cat/StatusBarController.swift`.

**Types:**
- Concrete types use PascalCase with role-oriented suffixes: `AppDelegate`, `StatusBarController`, `WOLWindow`, `WOLView`, and `PowerAssertionManager` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/PowerAssertionManager.swift`.
- Supporting enums and structs also use PascalCase, while cases stay lowerCamelCase: `InputMode.custom`, `InputMode.preset`, `DeviceOption`, and `WOLSenderError.invalidMAC` in `Tools Cat/WOLView.swift` and `Tools Cat/WOLSender.swift`.
- Error types are named with an `Error` suffix, as in `WOLSenderError` in `Tools Cat/WOLSender.swift`.

## Code Style

**Formatting:**
- No repo-local formatter config is present at the project root; there is no `.swiftlint.yml`, `.swiftformat`, or `.editorconfig`. Formatting is inferred from `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLView.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/WOLSender.swift`.
- Indentation follows Xcode-style 4 spaces with opening braces on the same line as declarations and control statements, as seen across `Tools Cat/StatusBarController.swift` and `Tools Cat/WOLSender.swift`.
- Semicolons are omitted. Multi-argument calls break one argument per line when they become long, for example `IOPMAssertionCreateWithName` in `Tools Cat/PowerAssertionManager.swift` and `NotificationCenter.default.addObserver` in `Tools Cat/WOLWindow.swift`.
- User-facing strings and many inline comments are Chinese, while APIs and identifiers remain English. See menu labels in `Tools Cat/StatusBarController.swift` and validation/status strings in `Tools Cat/WOLView.swift`.

**Linting:**
- No lint tool configuration is committed. There is no `SwiftLint` or `SwiftFormat` config file in the repository root, and no lint script is referenced from `README.md` or `Tools Cat.xcodeproj/project.pbxproj`.
- Style consistency is enforced manually through the Xcode project and small-file conventions visible in `Tools Cat.xcodeproj/project.pbxproj` and the source files under `Tools Cat/`.

## Import Organization

**Order:**
1. Apple UI frameworks needed by the file (`SwiftUI` or `Cocoa`), for example `Tools Cat/Tools_CatApp.swift`, `Tools Cat/AppDelegate.swift`, and `Tools Cat/WOLWindow.swift`.
2. Foundation or system frameworks that support the implementation, for example `Foundation` and `IOKit.pwr_mgt` in `Tools Cat/PowerAssertionManager.swift` and `Foundation` plus `Darwin` in `Tools Cat/WOLSender.swift`.
3. No internal module imports beyond the app target itself are used in production code; the only module import is the test-only `@testable import Tools_Cat` in `Tools CatTests/Tools_CatTests.swift`.

**Grouping:**
- Imports are kept as a single contiguous block at the top of each file with no blank lines between groups. See `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLView.swift`, and `Tools Cat/WOLSender.swift`.
- Import order is practical rather than strictly alphabetical. Bridge files usually list AppKit/Cocoa before SwiftUI (`Tools Cat/AppDelegate.swift`, `Tools Cat/WOLWindow.swift`), while pure SwiftUI files start with `SwiftUI` and add helpers such as `Combine` afterward (`Tools Cat/WOLView.swift`).

**Path Aliases:**
- Not applicable. The project uses direct same-target type references inside the Xcode app target defined in `Tools Cat.xcodeproj/project.pbxproj`.

## Error Handling

**Patterns:**
- Use `guard` for fast exits on invalid state or idempotent operations, for example `guard !isEnabled else { return }` and `guard isEnabled else { return }` in `Tools Cat/PowerAssertionManager.swift`, plus `guard !isSending else { return }` in `Tools Cat/WOLView.swift`.
- Throw typed errors from low-level operations and catch them at the UI boundary. `Tools Cat/WOLSender.swift` throws `WOLSenderError`, and `Tools Cat/WOLView.swift` catches `error` inside `performSend(mac:)` to update `statusText`.
- Recoverable validation failures in UI code usually return early with a status message instead of throwing, as shown by the empty-input and invalid-length branches in `Tools Cat/WOLView.swift`.

**Error Types:**
- Throw when parsing or socket operations fail in `Tools Cat/WOLSender.swift`.
- Return early without logging for expected UI control flow in `Tools Cat/WOLView.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/StatusBarController.swift`.
- No custom `Result` types, no NSError wrapping, and no centralized error presenter are present in the repo.

## Logging

**Framework:**
- Logging uses plain `print` statements only, all in `Tools Cat/WOLSender.swift`.
- Prefixes encode severity and subsystem inline, such as `[WOL]`, `[WOL][Warn]`, and `[WOL][Error]` in `Tools Cat/WOLSender.swift`.

**Patterns:**
- Log external/network boundary details, including socket setup, interface discovery, destination broadcast address, and send result in `Tools Cat/WOLSender.swift`.
- UI, menu bar, and power-assertion code in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/PowerAssertionManager.swift` avoid logging unless they surface state directly through UI.
- There is no structured logger, log level abstraction, or shared logging helper module.

## Comments

**When to Comment:**
- Comments are used sparingly and mostly to label UI sections or explain edge-case behavior. Examples include the UI block comments in `Tools Cat/WOLView.swift` and the broadcast-interface notes in `Tools Cat/WOLSender.swift`.
- When comments appear in hand-written source, they explain intent or fallback behavior rather than restating the code. See the interface filtering and dedup comments in `Tools Cat/WOLSender.swift` and the window-reset comments in `Tools Cat/WOLView.swift`.
- `MARK:` sections are not used in the committed source files under `Tools Cat/`.

**JSDoc/TSDoc:**
- Not applicable. No Swift doc comments (`///`) are present in production code or tests. This is visible in `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLView.swift`, `Tools Cat/WOLSender.swift`, and the test files under `Tools CatTests/` and `Tools CatUITests/`.

**TODO Comments:**
- No `TODO` or `FIXME` comments are present in the app or test source directories `Tools Cat/`, `Tools CatTests/`, and `Tools CatUITests/`.

## Function Design

**Size:**
- Keep files small and functions focused. Most helpers handle one responsibility, such as `updateIcon()` and `configure()` in `Tools Cat/StatusBarController.swift`, `openWOLWindow()` in `Tools Cat/AppDelegate.swift`, and `ipv4ToString(_:)` in `Tools Cat/WOLSender.swift`.
- The largest function bodies are concentrated in validation/networking code, notably `send()`, `performSend(mac:)`, and `enumerateIPv4Broadcasts()` in `Tools Cat/WOLView.swift` and `Tools Cat/WOLSender.swift`.

**Parameters:**
- Parameter counts stay low and are labeled for clarity, for example `send(to:)` in `Tools Cat/WOLSender.swift`, `performSend(mac:)` in `Tools Cat/WOLView.swift`, and `windowWillClose(_:)` in `Tools Cat/WOLWindow.swift`.
- UI callbacks often capture state from properties instead of passing many arguments, as shown by `toggleKeepAwake(_:)`, `openWOL()`, and `quitApp()` in `Tools Cat/StatusBarController.swift`.

**Return Values:**
- Guard clauses and early returns are preferred over nested `if` pyramids in `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLWindow.swift`, and `Tools Cat/WOLView.swift`.
- Side-effecting helpers usually return `Void`; only the low-level parser and enumerator helpers in `Tools Cat/WOLSender.swift` return values for further processing.

## Module Design

**Exports:**
- The app uses one top-level type per file and relies on Swift's default internal visibility inside the target. See `Tools Cat/AppDelegate.swift`, `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/WOLWindow.swift`.
- Narrower implementation details are `private` or `private(set)`, such as `assertionID` and `isEnabled` in `Tools Cat/PowerAssertionManager.swift`, plus `keepAwakeItem` and `updateIcon()` in `Tools Cat/StatusBarController.swift`.

**Barrel Files:**
- Not used. There are no index-style re-export files; types are referenced directly from their defining files in the `Tools Cat` target declared by `Tools Cat.xcodeproj/project.pbxproj`.

---

*Convention analysis: 2026-04-11*
*Update when patterns change*
