# Stack Research

**Domain:** Native macOS menu bar Wake-on-LAN utility evolution
**Researched:** 2026-04-11
**Confidence:** HIGH

## Recommended Stack

This milestone should stay fully Apple-native and intentionally small. The right move is not a new app stack; it is a cleanup of the existing one so persistence, status, and device management stop fighting the menu bar architecture.

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| SwiftUI app scenes: `MenuBarExtra`, `Settings`, optional `Window` | macOS 15.6+ target already in repo | Primary app UI, menu bar presentation, preferences UI | `MenuBarExtra` is now the native SwiftUI scene for persistent menu bar controls, and the repo already targets a modern macOS where it is available. Moving the status item and WOL surface to scenes removes custom `NSStatusItem` and `NSWindowController` plumbing, which is the current source of lifecycle fragility. Use `.window` style only if the menu surface needs richer grouped content; otherwise keep it menu-like. |
| Observation framework: `@Observable`, `@Bindable`, environment-driven model injection | macOS 15.6+ | App state for saved devices, recent devices, send status, and keep-awake state | The current target is well above the Observation baseline, so there is no reason to keep adding `ObservableObject`/Combine-style glue for new state. Observation gives a smaller, more direct model for a utility app: a few shared models, bound directly into SwiftUI, with less ceremony and fewer publisher edge cases. |
| Foundation persistence: `UserDefaults` + `@AppStorage` for scalars, `Codable` + `Data` in `UserDefaults` for device arrays | macOS 15.6+ | Persistent device list, recent-device memory, preferences, last-used device ID | This app stores a small amount of local configuration, not relational data. `@AppStorage` and `defaultAppStorage(_:)` fit booleans and small preference values, while a tiny `Codable` store in `UserDefaults` is enough for `[SavedDevice]`, notes, and recents. This keeps persistence simple, synchronous, migration-light, and fully native. |
| Existing low-level services kept, but wrapped: `IOKit.pwr_mgt` and `Darwin` sockets behind protocols | Existing repo implementation | Keep-awake assertions and WOL packet sending | The current core side effects are already on the right OS APIs. The problem is direct coupling, not wrong technology. Keep the transport and power-management primitives, but hide them behind `PowerService` and `WakeService` protocols so view state, logging, and tests do not depend on raw system calls. Confidence: MEDIUM-HIGH, because this is an implementation recommendation derived from repo evidence plus current Apple-native app patterns. |
| `OSLog` / `Logger` | Current Apple logging stack | Privacy-aware diagnostics and operational feedback | Replace raw `print` calls with categorized `Logger` instances. This gives privacy controls for MAC addresses and broadcast details, makes Console output usable during debugging, and avoids leaking local-network identifiers in normal logs. |

### Supporting Libraries

No third-party runtime libraries are recommended for this milestone. The app is too small to justify dependency churn.

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Swift Concurrency (`Task`, `async` boundaries) | Built into current Swift toolchain | Replace ad hoc `DispatchQueue` hops in send/status flows | Use for the WOL send path and status reset timing so cancellation and main-actor updates are explicit. Do not rewrite every service as heavily async if the underlying operation stays synchronous. |
| XCTest | Current Xcode toolchain | Unit-test persistence, validation, and service-boundary behavior | Use once `DeviceStore`, `WakeService`, and `PowerService` are protocol-backed. This is the lowest-cost path to regression coverage. |
| XCUITest | Current Xcode toolchain | Verify menu bar interactions, settings edits, and status feedback | Use sparingly for end-to-end checks around the menu bar surface and settings flow. Keep most logic testing in XCTest. |
| AppKit interop | macOS SDK | Escape hatch for menu bar behavior gaps or activation quirks | Keep only where SwiftUI scenes still need bridging. Do not keep AppKit as the primary UI architecture for new work. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Xcode project + Swift Package Manager-free repo | Build and edit the native app | Keep it this way for now. Adding package management without external dependencies adds ceremony with no payoff. |
| `xcodebuild` | Local build and test automation | Use it for repeatable validation of the new persistence and settings flows; no new build tooling is needed. |
| Console.app / Instruments as needed | Inspect `Logger` output and diagnose runtime behavior | Useful after switching from `print` to structured logging, especially for networking failures and menu scene lifecycle checks. |

## Recommended Architecture Shape

Use a small scene-first architecture:

1. `App`
   - Owns `MenuBarExtra`
   - Owns `Settings`
   - Injects shared models/services
2. `AppModel` (`@Observable`)
   - Holds keep-awake status, last action result, current UI state
3. `DeviceStore` (`@Observable`)
   - Loads/saves `[SavedDevice]`
   - Tracks `recentDeviceIDs`
   - Exposes simple CRUD and recents APIs
4. `WakeService`
   - Wraps existing `WOLSender`
   - Returns typed success/failure for UI status
5. `PowerService`
   - Wraps existing `PowerAssertionManager`
   - Returns real success/failure instead of mutating menu state optimistically

This is the lowest-complexity way to fix the current codebase problems:
- Hardcoded device data moves into one local store.
- Recent-device memory becomes a store concern, not view-local state.
- Status feedback becomes model state, not `NotificationCenter` side effects.
- AppKit lifecycle code shrinks to the minimum needed for any remaining bridge points.

## Installation

```bash
# No new third-party runtime packages recommended for this milestone.

# Open in Xcode
open "Mac OS Swiss Knife.xcodeproj"

# Build locally
xcodebuild -scheme "Mac OS Swiss Knife" -configuration Debug build
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `UserDefaults` + `Codable` device store | SwiftData | Use SwiftData only if device data becomes substantially richer: many related entities, filtering/search across larger datasets, sync, or future cross-window editing complexity. For a small personal device list, SwiftData adds migration and model-container overhead without solving the real problem. |
| `MenuBarExtra` scene | Existing `NSStatusItem` + custom `NSMenu`/`NSWindowController` | Keep the AppKit path only if a required menu bar behavior is impossible in SwiftUI scenes. The repo's current pain points come from this custom lifecycle code, so it should not remain the default architecture. |
| Observation (`@Observable`) | `ObservableObject` + Combine for new state | Use the older pattern only if the deployment target drops below macOS 14 or if a specific integration already depends on Combine publishers. Neither is true for this milestone. |
| `Settings` scene for device management | Dedicated editor window first | Add a separate `Window` scene only if device editing genuinely outgrows settings layout. The current scope fits a restrained settings screen better than another custom window controller. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| SwiftData or Core Data for this milestone | Overbuilt for a short local device list and recent-device memory; adds model container, migration, and more moving parts than the app needs | `UserDefaults` + `Codable` device store |
| `NotificationCenter` as the primary UI coordination mechanism | The current duplicate-observer and window-reset issues come from lifecycle state living outside typed models | Scene state + `@Observable` models + direct bindings |
| New third-party persistence, DI, or logging frameworks | Adds maintenance surface and packaging complexity to a personal utility without meaningfully improving the result | Apple frameworks already in the SDK |
| Leaving raw `print` logging in networking code | It leaks local identifiers and makes runtime diagnostics noisy and unstructured | `Logger` with privacy annotations |
| Rewriting WOL networking onto a new transport stack just for modernity | The current issue is architecture and feedback, not that BSD UDP broadcast is inherently the wrong primitive | Keep the sender logic, wrap it cleanly, and improve results/errors |

## Stack Patterns by Variant

**If the menu bar surface stays compact:**
- Use `MenuBarExtra` with the default menu presentation.
- Put device CRUD in `Settings`.
- Keep the menu focused on: keep-awake toggle, recent devices, send action, last status.

**If the menu bar surface needs richer inline status and grouped controls:**
- Use `MenuBarExtra` with `.window` style.
- Still keep full device management in `Settings`.
- Do not reintroduce a custom `NSWindowController` unless SwiftUI scene behavior proves insufficient.

**If future milestones add many devices, tags, or sync:**
- Re-evaluate SwiftData in that milestone.
- Do not introduce it preemptively now.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Repo deployment target: `macOS 15.6+` | `MenuBarExtra`, `Settings`, `@AppStorage`, `defaultAppStorage(_:)`, `Logger` | Strong fit. No compatibility shim needed for the scene and logging recommendations. |
| `@Observable` (Observation) | `macOS 14+` | Safe on the current repo target. If the deployment target is later lowered below macOS 14, fall back to `ObservableObject` for shared models. |
| `UserDefaults` + `@AppStorage` | `Settings` scene bindings | Best for scalar preferences and small local state. Device arrays should still be encoded explicitly instead of trying to force complex data directly through `@AppStorage`. |
| Existing `IOKit` + `Darwin` code | Protocol-wrapped services + XCTest mocks | Keeps system-specific code isolated while preserving behavior already proven in the repo. |

## Confidence Notes

- HIGH: `MenuBarExtra` + `Settings` as the primary UI direction for this repo's target OS.
- HIGH: `UserDefaults`/`@AppStorage` + a tiny `Codable` store as the right persistence level for saved devices and recents.
- HIGH: `Logger` should replace raw `print` for runtime diagnostics.
- MEDIUM-HIGH: Keep the current WOL transport and improve seams instead of rewriting it; this is strongly supported by repo evidence, but still depends on real-network validation once refactored.

## Sources

- Repo evidence: [.planning/PROJECT.md](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/PROJECT.md), [.planning/codebase/STACK.md](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/codebase/STACK.md), [.planning/codebase/ARCHITECTURE.md](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/codebase/ARCHITECTURE.md), [.planning/codebase/CONCERNS.md](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/.planning/codebase/CONCERNS.md)
- Repo evidence: [Mac_OS_Swiss_KnifeApp.swift](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/Mac_OS_Swiss_KnifeApp.swift), [StatusBarController.swift](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift), [WOLView.swift](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift), [WOLWindow.swift](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLWindow.swift), [WOLSender.swift](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLSender.swift), [PowerAssertionManager.swift](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/PowerAssertionManager.swift)
- Apple Developer Documentation: https://developer.apple.com/documentation/swiftui/menubarextra
- Apple Developer Documentation: https://developer.apple.com/documentation/swiftui/appstorage
- Apple Developer Documentation: https://developer.apple.com/documentation/swiftui/view/defaultappstorage(_:)
- Apple Developer Documentation: https://developer.apple.com/documentation/swiftui/settings
- Apple Developer Documentation: https://developer.apple.com/documentation/observation
- Apple Developer Documentation: https://developer.apple.com/documentation/foundation/userdefaults
- Apple Developer Documentation: https://developer.apple.com/documentation/os/logger
- Apple Developer Documentation: https://developer.apple.com/documentation/swift/task
- Apple Developer Documentation: https://developer.apple.com/documentation/swiftdata

---
*Stack research for: Native macOS menu bar Wake-on-LAN utility evolution*
*Researched: 2026-04-11*
