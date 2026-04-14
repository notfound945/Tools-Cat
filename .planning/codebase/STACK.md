# Technology Stack

**Analysis Date:** 2026-04-11

## Languages

**Primary:**
- Swift 5.0 - All application, unit test, and UI test code in `Tools Cat/*.swift`, `Tools CatTests/*.swift`, and `Tools CatUITests/*.swift`; the target build settings set `SWIFT_VERSION = 5.0` in `Tools Cat.xcodeproj/project.pbxproj`.

**Secondary:**
- Bash - Local build and packaging automation in `release.sh` and `build_dmg.sh`.
- Objective-C/C system APIs via Swift imports - The app bridges into Apple frameworks and POSIX APIs through `import Cocoa`, `import IOKit.pwr_mgt`, and `import Darwin` in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/PowerAssertionManager.swift`, and `Tools Cat/WOLSender.swift`.

## Runtime

**Environment:**
- Native macOS app runtime - The main target is an app bundle (`Tools Cat.app`) in `Tools Cat.xcodeproj/project.pbxproj`.
- macOS 15.6 minimum deployment target - Set as `MACOSX_DEPLOYMENT_TARGET = 15.6` for the project and test targets in `Tools Cat.xcodeproj/project.pbxproj`.
- Menu bar app configuration - `INFOPLIST_KEY_LSUIElement = 1` in `Tools Cat.xcodeproj/project.pbxproj` makes the app run without a standard dock/main window flow.

**Package Manager:**
- None detected - No `Package.swift`, `Package.resolved`, `Podfile`, `Cartfile`, or other dependency manager manifests are present at the project root.
- Lockfile: missing

## Frameworks

**Core:**
- SwiftUI - App entry point and the WOL window content live in `Tools Cat/Tools_CatApp.swift` and `Tools Cat/WOLView.swift`.
- AppKit/Cocoa - Menu bar lifecycle, `NSStatusItem`, and custom `NSWindow` handling are implemented in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/WOLWindow.swift`.
- IOKit Power Management - Display sleep suppression uses `IOPMAssertionCreateWithName` and `IOPMAssertionRelease` in `Tools Cat/PowerAssertionManager.swift`.
- Darwin/POSIX sockets - Wake-on-LAN UDP broadcasting is implemented directly with `socket`, `setsockopt`, `sendto`, `getifaddrs`, and `if_nametoindex` in `Tools Cat/WOLSender.swift`.

**Testing:**
- XCTest - Unit test target scaffolding exists in `Tools CatTests/Tools_CatTests.swift`.
- XCUITest - UI test and launch performance scaffolding exist in `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.

**Build/Dev:**
- Xcode project build system - The repo is driven by `Tools Cat.xcodeproj/project.pbxproj`; README instructions point developers to open the Xcode project in `README.md`.
- `xcodebuild` - Local Release builds are scripted in `release.sh` and documented in `README.md`.
- `hdiutil` and `/usr/bin/ditto` - DMG packaging is handled in `build_dmg.sh`.

## Key Dependencies

**Critical:**
- SwiftUI (macOS SDK) - Provides the app entry point and WOL form UI in `Tools Cat/Tools_CatApp.swift` and `Tools Cat/WOLView.swift`.
- AppKit/Cocoa (macOS SDK) - Provides status bar, menu, application delegate, and window management in `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, and `Tools Cat/WOLWindow.swift`.
- IOKit Power Management (macOS SDK) - Core to the “keep display awake” feature in `Tools Cat/PowerAssertionManager.swift`.
- Darwin / BSD sockets (system libc) - Core to sending Wake-on-LAN magic packets in `Tools Cat/WOLSender.swift`.

**Infrastructure:**
- XCTest / XCUITest (Xcode toolchain) - Native Apple test frameworks configured by the `Tools CatTests` and `Tools CatUITests` targets in `Tools Cat.xcodeproj/project.pbxproj`.
- App Sandbox entitlements - The app depends on `Tools Cat/Tools_Cat.entitlements` and corresponding `CODE_SIGN_ENTITLEMENTS` settings in `Tools Cat.xcodeproj/project.pbxproj`.

## Configuration

**Environment:**
- No runtime `.env` or secret-based configuration is detected in the repo.
- Build/packaging scripts accept optional shell environment overrides: `SCHEME`, `CONFIG`, `DERIVED`, `DMG_NAME`, `VOL_NAME`, and `OUT_DIR` in `release.sh`, plus `OUT_DIR` in `build_dmg.sh`.
- Networking capability is configured through the App Sandbox entitlement `com.apple.security.network.client` in `Tools Cat/Tools_Cat.entitlements`.

**Build:**
- `Tools Cat.xcodeproj/project.pbxproj` - Target definitions, bundle identifiers, deployment target, entitlements, and generated Info.plist keys.
- `release.sh` - Release build orchestration with `xcodebuild`.
- `build_dmg.sh` - DMG packaging without notarization.
- `README.md` - Developer workflow and release packaging instructions.

## Platform Requirements

**Development:**
- macOS with Xcode - The documented workflow is “use Xcode to open the project and run the `Tools Cat` scheme” in `README.md`.
- Apple command-line build tools - `xcodebuild`, `hdiutil`, and `/usr/bin/ditto` are required by `release.sh` and `build_dmg.sh`.

**Production:**
- Distributed as a signed macOS `.app` bundled into a DMG - Packaging outputs to `dist/Tools-Cat.dmg` via `build_dmg.sh` and `release.sh`.
- Not notarized - `README.md` and `build_dmg.sh` both state the DMG is produced without notarization, so first-run installation requires a manual security approval flow on macOS.

---

*Stack analysis: 2026-04-11*
