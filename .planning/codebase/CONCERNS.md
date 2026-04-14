# Codebase Concerns

**Analysis Date:** 2026-04-11

## Tech Debt

**Hardcoded WOL device data in UI code:**
- Issue: The only preset device is embedded directly in source as a literal label and MAC address instead of coming from user settings.
- Files: `Tools Cat/WOLView.swift`
- Why: The current app is optimized for a single personal device and skips any persistence or settings model.
- Impact: Adding or changing a device requires a code edit and rebuild, and the repo now carries a real device identifier.
- Fix approach: Move presets into `UserDefaults` or another local store, add an edit flow, and keep repo defaults generic.

**Feature logic is mixed into view and menu classes:**
- Issue: Validation, async sending, status messaging, and window-close coordination all live inside `WOLView`, while menu state and system power assertions are coordinated directly in `StatusBarController`.
- Files: `Tools Cat/WOLView.swift`, `Tools Cat/WOLWindow.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/WOLSender.swift`, `Tools Cat/PowerAssertionManager.swift`
- Why: The app is small and was built as a thin end-to-end implementation without service or view-model boundaries.
- Impact: The main feature flows are hard to test, hard to mock, and easy to break when changing lifecycle or threading behavior.
- Fix approach: Extract a small WOL view model plus protocol-backed power/network adapters so UI state and system side effects can evolve independently.

**Distribution workflow is still a local script path:**
- Issue: Release packaging is handled by shell scripts that build locally and create an unnotarized DMG.
- Files: `release.sh`, `build_dmg.sh`, `README.md`
- Why: Local scripting is the fastest way to produce a distributable bundle for personal use.
- Impact: Distribution quality depends on the local machine, there is no repeatable release pipeline, and install friction remains part of the product experience.
- Fix approach: Replace the ad-hoc flow with an `xcodebuild archive` + notarization path and document one supported release process.

## Known Bugs

**Keep-awake menu state can claim success when assertion creation fails:**
- Symptoms: The checkmark can flip on even when the display-sleep assertion was not created; the icon then remains out of sync with the menu state.
- Files: `Tools Cat/StatusBarController.swift`, `Tools Cat/PowerAssertionManager.swift`
- Trigger: Any failure from `IOPMAssertionCreateWithName`, including OS-level or environment-specific power-management failures.
- Workaround: Compare the menu checkmark with the status bar icon and Console output; there is no in-app error surface.
- Root cause: `PowerAssertionManager.enable()` does not return success/failure, and `StatusBarController.toggleKeepAwake(_:)` sets `sender.state = .on` unconditionally after calling it.
- Blocked by: No blocker; this can be fixed locally by returning or throwing on failure.

**WOL window registers duplicate close observers over time:**
- Symptoms: The same `WOLWindow` instance can accumulate multiple observers for the close notification, making close handling increasingly opaque and repetitive.
- Files: `Tools Cat/WOLWindow.swift`
- Trigger: Open the WOL window repeatedly; `show()` calls `setupNotificationListener()` every time while `window.isReleasedWhenClosed = false` keeps the controller alive.
- Workaround: Relaunching the app resets the observer list.
- Root cause: `NotificationCenter.default.addObserver` is called on each show, but observers are only removed in `deinit`.
- Blocked by: No blocker; the listener needs one-time registration or token-based lifecycle management.

## Security Considerations

**The repo and logs expose local-network identifiers:**
- Risk: The source embeds a real MAC address, and runtime `print` calls log target MACs, interface names, and broadcast addresses.
- Files: `Tools Cat/WOLView.swift`, `Tools Cat/WOLSender.swift`
- Current mitigation: None beyond the repo being local and the app being sandboxed for outbound networking only in `Tools Cat/Tools_Cat.entitlements`.
- Recommendations: Remove personal device data from source, store presets locally, and replace raw `print` calls with gated debug logging or privacy-aware `Logger`.

**Release artifacts are intentionally unnotarized:**
- Risk: Users must bypass normal Gatekeeper trust flow to install the app, which weakens provenance and raises support risk for shared distribution.
- Files: `build_dmg.sh`, `README.md`, `release.sh`
- Current mitigation: The app enables App Sandbox in `Tools Cat/Tools_Cat.entitlements`, and the README warns that users must manually allow the app.
- Recommendations: Sign with Developer ID, notarize the DMG/app, and treat the current scripts as local-dev tooling rather than the final release path.

## Performance Bottlenecks

**Every WOL send re-enumerates interfaces and fans out to all IPv4 broadcasts:**
- Problem: A single wake request walks all network interfaces and then attempts a UDP send to every discovered broadcast target.
- Files: `Tools Cat/WOLSender.swift`
- Measurement: Not instrumented in the repo; the work scales with the number of active broadcast-capable interfaces on the host.
- Cause: `send(to:)` always calls `enumerateIPv4Broadcasts()` and loops over the full result set before returning.
- Improvement path: Cache interface discovery, allow user-selected target interfaces, or short-circuit once the intended network path is known.

**Release packaging always discards incremental build output:**
- Problem: The release script always runs `xcodebuild clean build` before DMG packaging.
- Files: `release.sh`, `build_dmg.sh`
- Measurement: Not instrumented in the repo; every release rebuild starts from a clean DerivedData path.
- Cause: The script favors a deterministic local rebuild over reuse of an existing archive or `.app`.
- Improvement path: Support a prebuilt archive/app input or move to `archive`/`export` steps that separate build and packaging costs.

## Fragile Areas

**WOL window lifecycle and NotificationCenter coordination:**
- Files: `Tools Cat/AppDelegate.swift`, `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`
- Why fragile: Showing, closing, resetting fields, and clearing status all depend on custom notifications and a persistent `NSWindowController`.
- Common failures: Duplicate observers, stale state after close/reopen, and subtle regressions when changing when the view is recreated.
- Safe modification: Change the window lifecycle, notification wiring, and field-reset behavior together; do not tweak only one side of the flow.
- Test coverage: No automated tests cover this path; `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift` are still Xcode templates.

**Direct system API usage for the core features:**
- Files: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLSender.swift`, `Tools Cat/StatusBarController.swift`
- Why fragile: The app talks straight to IOKit power assertions and BSD sockets with almost no abstraction, no retries, and limited error reporting.
- Common failures: Silent keep-awake failure, interface-specific WOL behavior differences, and environment-specific regressions that are hard to reproduce deterministically.
- Safe modification: Introduce thin wrappers and injectable seams before changing behavior; otherwise each change has to be validated manually on a real Mac and real LAN.
- Test coverage: No targeted unit tests exist; `Tools CatTests/Tools_CatTests.swift` is still placeholder scaffolding.

## Scaling Limits

**OS compatibility range:**
- Files: `Tools Cat.xcodeproj/project.pbxproj`
- Current capacity: The app and both test targets target macOS 15.6 and newer.
- Limit: Any machine or CI environment below macOS 15.6 is excluded outright.
- Symptoms at limit: Builds, test runs, and distribution are limited to a narrow slice of current macOS systems.
- Scaling path: Audit API usage, then lower `MACOSX_DEPLOYMENT_TARGET` if the app is intended for wider adoption.

**Preset/device management capacity:**
- Files: `Tools Cat/WOLView.swift`
- Current capacity: One hardcoded preset plus manual MAC entry.
- Limit: Supporting more devices or different users requires source edits and rebuilds instead of in-app configuration.
- Symptoms at limit: The binary is not broadly reusable, and personal device data tends to leak into the repo.
- Scaling path: Add editable persistent presets and separate shipped defaults from user-owned configuration.

## Dependencies at Risk

**Core features depend directly on Apple low-level APIs:**
- Files: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLSender.swift`
- Risk: The keep-awake and WOL features rely on `IOKit.pwr_mgt`, raw BSD sockets, and `IP_BOUND_IF` behavior without any compatibility layer.
- Impact: Any macOS SDK, entitlement, or network-policy change lands directly on the app's primary features.
- Migration plan: Add adapters around power assertions and socket operations so future platform-specific changes are isolated and testable.

## Missing Critical Features

**Persistent user settings for WOL devices:**
- Problem: Device presets are not user-editable or persistent, and the close flow explicitly clears entered values.
- Files: `Tools Cat/WOLView.swift`
- Current workaround: Re-enter MAC addresses each time or edit the source code to change presets.
- Blocks: Multi-device everyday use and distribution to anyone other than the developer.
- Implementation complexity: Low to medium; this mostly needs a settings model plus local persistence.

**Production-grade release trust flow:**
- Problem: The documented shipping path ends at a locally built, unnotarized DMG.
- Files: `README.md`, `release.sh`, `build_dmg.sh`
- Current workaround: Users manually allow the app in macOS Privacy & Security or right-click to open it.
- Blocks: Smooth external distribution and a trustworthy install experience.
- Implementation complexity: Medium; requires signing/notarization setup and a release process update.

## Test Coverage Gaps

**Keep-awake state management is effectively untested:**
- What's not tested: Success and failure paths around `IOPMAssertionCreateWithName`, menu-item state updates, and teardown behavior on quit.
- Files: `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/StatusBarController.swift`, `Tools CatTests/Tools_CatTests.swift`
- Risk: UI state mismatches and lifecycle regressions can ship unnoticed because there is no assertion-level verification.
- Priority: High
- Difficulty to test: Medium; the code needs small protocol seams or wrappers to replace IOKit in tests.

**WOL validation, window lifecycle, and notification flow are untested:**
- What's not tested: MAC validation, send error handling, repeated open/close behavior, and the `NotificationCenter`-driven window reset path.
- Files: `Tools Cat/WOLView.swift`, `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLSender.swift`, `Tools CatUITests/Tools_CatUITests.swift`, `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`
- Risk: Regressions in the app's only visible feature flow will be caught only by manual testing on a real machine.
- Priority: High
- Difficulty to test: Medium to high; system/network interactions should be injected, and the menu-bar UI needs dedicated UI automation rather than the default launch tests.

---

*Concerns audit: 2026-04-11*
