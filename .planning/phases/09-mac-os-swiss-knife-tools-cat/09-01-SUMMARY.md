---
phase: 09-mac-os-swiss-knife-tools-cat
plan: 01
subsystem: app-identity
tags: [rename, xcode, bundle-id, migration, xctest]
requires:
  - phase: 08-validation-debt-closure
    provides: "Current trustworthy validation baseline before the rename"
provides:
  - "The Xcode project, targets, module name, generated files, and quit-row copy now use the Tools Cat identity"
  - "Saved-device and wake-metadata defaults migrate once from the legacy bundle-ID family without overwriting existing Tools Cat data"
affects: [project-identity, defaults-migration, unit-tests]
tech-stack:
  added: []
  patterns: ["One-time legacy defaults migration", "Hosted XCTest lifecycle stabilization during suite-based defaults tests"]
key-files:
  created: [".planning/phases/09-mac-os-swiss-knife-tools-cat/09-01-SUMMARY.md"]
  modified:
    - "Tools Cat.xcodeproj/project.pbxproj"
    - "Tools Cat/AppDelegate.swift"
    - "Tools Cat/SavedDeviceRepository.swift"
    - "Tools Cat/StatusBarController.swift"
    - "Tools CatTests/SavedDeviceRepositoryTests.swift"
    - "Tools CatTests/StatusBarControllerMenuPolishTests.swift"
key-decisions:
  - "Keep runtime storage on UserDefaults.standard and use the legacy suite only as a migration source"
  - "Retain the legacy repository as XCTestCase-owned state so suite teardown does not crash after migration tests"
patterns-established:
  - "Bundle-ID renames must carry explicit persisted-defaults migration tests, not just string replacements"
requirements-completed: [RENAME-01, RENAME-04]
duration: 35min
completed: 2026-04-13
---

# Phase 9 Plan 1: Tools Cat Identity Summary

**The repo now builds and runs as `Tools Cat`, and the legacy `saved_devices` / `saved_device_wake_metadata` keys migrate safely into the new bundle-ID family exactly once.**

## Performance

- **Duration:** 35min
- **Completed:** 2026-04-13
- **Tasks:** 1
- **Files modified:** 10+

## Accomplishments
- Renamed the Xcode project, targets, module wiring, bundle IDs, generated entry files, test files, and entitlements path to the `Tools Cat` identity stack.
- Updated the live quit row to `退出 Tools Cat`.
- Added a one-time legacy defaults migration path for saved devices and wake metadata with explicit protection against overwriting existing `Tools Cat` data.
- Added migration regression tests and stabilized their lifecycle so hosted XCTest teardown stays reliable.

## Verification

- `xcodebuild -list -project "Tools Cat.xcodeproj"`
- `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'`

## Issues Encountered

- A hosted XCTest crash appeared after migration tests returned because the temporary legacy repository deallocated at the wrong moment.
- Release-mode startup could not use `UserDefaults(suiteName: "cn.notfound945.Tools-Cat")` as the app's primary store; the implementation was corrected to keep `.standard` as runtime storage and use the legacy suite only as a migration source.

## Next Phase Readiness

The identity rename is stable, so automation and packaging can now be retargeted to the renamed project without carrying compatibility hacks.

## Self-Check: PASSED
