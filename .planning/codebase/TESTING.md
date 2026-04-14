# Testing Patterns

**Analysis Date:** 2026-04-11

## Test Framework

**Runner:**
- XCTest is the active test framework. The project defines a unit-test target and a UI-test target in `Tools Cat.xcodeproj/project.pbxproj` with product types `com.apple.product-type.bundle.unit-test` and `com.apple.product-type.bundle.ui-testing`.
- No `.xctestplan` file is committed. Test configuration lives in `Tools Cat.xcodeproj/project.pbxproj`.

**Assertion Library:**
- XCTest built-in assertions are the intended assertion library via `import XCTest` in `Tools CatTests/Tools_CatTests.swift`, `Tools CatUITests/Tools_CatUITests.swift`, and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- Current committed tests do not contain real `XCTAssert*` calls yet. The only concrete test APIs exercised are `measure(metrics:)`, `XCUIApplication().launch()`, and `XCTAttachment(screenshot:)` in the UI test files under `Tools CatUITests/`.

**Run Commands:**
```bash
xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'                                           # Run all unit and UI tests
xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:"Tools CatTests"    # Run the unit-test target
xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:"Tools CatUITests"  # Run the UI-test target
# No watch-mode or dedicated coverage command is configured in-repo
```

## Test File Organization

**Location:**
- Tests live in separate Xcode target directories rather than next to source files: `Tools CatTests/` for unit tests and `Tools CatUITests/` for UI tests.
- Production code remains under `Tools Cat/`.

**Naming:**
- Unit tests follow the target name: `Tools CatTests/Tools_CatTests.swift`.
- UI tests follow the target name plus a special launch test file: `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- Test methods use XCTest naming with a `test` prefix, for example `testExample`, `testPerformanceExample`, `testLaunchPerformance`, and `testLaunch`.

**Structure:**
```text
Tools Cat/
  AppDelegate.swift
  PowerAssertionManager.swift
  StatusBarController.swift
  WOLSender.swift
  WOLView.swift
  WOLWindow.swift
Tools CatTests/
  Tools_CatTests.swift
Tools CatUITests/
  Tools_CatUITests.swift
  Tools_CatUITestsLaunchTests.swift
```

## Test Structure

**Suite Organization:**
```swift
import XCTest
@testable import Tools_Cat

final class Tools_CatTests: XCTestCase {
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func testExample() throws {}

    func testPerformanceExample() throws {
        measure {
            // code under test
        }
    }
}
```

**Patterns:**
- Each file declares one `final` `XCTestCase` subclass, matching `Tools CatTests/Tools_CatTests.swift`, `Tools CatUITests/Tools_CatUITests.swift`, and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- `setUpWithError()` and `tearDownWithError()` are overridden even when empty. This is the only established lifecycle pattern in the current suite.
- UI tests set `continueAfterFailure = false` in `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`, then create a fresh `XCUIApplication()` inside each test method before calling `launch()`.

## Mocking

**Framework:**
- No mocking framework is in use. There are no mocks, stubs, fakes, or helper doubles in `Tools CatTests/` or `Tools CatUITests/`.
- Unit tests import the app module directly with `@testable import Tools_Cat` in `Tools CatTests/Tools_CatTests.swift`.

**Patterns:**
```swift
// No mock pattern is established in the current repository.
// Existing tests either import the app module directly:
@testable import Tools_Cat

// or launch the real application process:
let app = XCUIApplication()
app.launch()
```

**What to Mock:**
- No repo-specific mocking guidance is established because no test currently isolates collaborators in `Tools CatTests/`.

**What NOT to Mock:**
- Current UI tests in `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift` exercise the real app launch path through `XCUIApplication()` instead of mocking the app process.

## Fixtures and Factories

**Test Data:**
```swift
// No shared fixtures, factory helpers, or sample-data builders are committed.
// Future tests currently need to create data inline inside each test file.
```

**Location:**
- Not detected. There is no `Fixtures`, `Factories`, or helper-test-support directory under `Tools CatTests/` or `Tools CatUITests/`.

## Coverage

**Requirements:**
- No coverage target or threshold is configured in `README.md` or `Tools Cat.xcodeproj/project.pbxproj`.
- The committed suite is still template-level, so coverage is effectively minimal even though both unit and UI test targets exist.

**Configuration:**
- No dedicated coverage config file or committed scheme setting is present in the repo.
- There is no CI pipeline in the repository that enforces test or coverage gates.

**View Coverage:**
```bash
# Not configured in-repo.
# Enable code coverage in the Xcode scheme or pass Xcode build settings manually when invoking xcodebuild.
```

## Test Types

**Unit Tests:**
- A hosted unit-test target exists in `Tools Cat.xcodeproj/project.pbxproj`; it sets `TEST_HOST` and `BUNDLE_LOADER` so tests run against the built app bundle.
- The only committed unit test file is `Tools CatTests/Tools_CatTests.swift`, which still contains template placeholders and a `measure {}` performance stub rather than behavioral assertions.

**Integration Tests:**
- No separate integration-test target, folder, or naming convention is present.
- The hosted unit-test setup in `Tools Cat.xcodeproj/project.pbxproj` means future tests can exercise app-linked code, but no multi-module integration scenarios are currently committed.

**E2E Tests:**
- The repo uses XCUITest for app-launch coverage via `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- Current end-to-end scope is limited to launching the app, measuring launch time, and capturing a launch screenshot attachment. There are no menu-bar interaction or WOL workflow assertions yet.

## Common Patterns

**Async Testing:**
```swift
@MainActor
func testExample() throws {
    let app = XCUIApplication()
    app.launch()
}
```
- `@MainActor` is used on UI test methods in `Tools CatUITests/Tools_CatUITests.swift` and `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.
- No `async`/`await` XCTest methods are committed yet.

**Error Testing:**
```swift
// No error-assertion pattern is present in the current test suite.
// There are no committed uses of XCTAssertThrowsError, XCTFail, or async rejection checks.
```

**Snapshot Testing:**
- Dedicated snapshot-testing frameworks are not used.
- The nearest existing pattern is an `XCTAttachment` screenshot kept with `.keepAlways` in `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`.

---

*Testing analysis: 2026-04-11*
*Update when test patterns change*
