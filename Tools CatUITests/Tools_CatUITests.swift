//
//  Tools_CatUITests.swift
//  Tools CatUITests
//
//  Created by hailinpan on 2025/10/19.
//

import XCTest

final class Tools_CatUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testLaunchWithSeededDeviceLibraryShowsManagementWindow() throws {
        let seededDevices = [
            SeededSavedDevice(
                id: UUID(),
                name: "Ugreen NAS",
                macAddress: "6C:1F:F7:75:C7:0E",
                note: "书房机柜",
                sortOrder: 0
            ),
            SeededSavedDevice(
                id: UUID(),
                name: "Mac mini",
                macAddress: "AA:BB:CC:DD:EE:FF",
                note: "工作台",
                sortOrder: 1
            )
        ]
        let launchContext = try makeLaunchContext(seededDevices: seededDevices)
        defer {
            launchContext.defaults.removePersistentDomain(forName: launchContext.suiteName)
        }

        let app = makeApplication(
            launchContext: launchContext,
            additionalArguments: ["--ui-test-open-device-library"]
        )
        app.launch()
        defer { terminateIfRunning(app) }

        let window = waitForDeviceLibraryWindow(in: app)

        let populatedList = window.descendants(matching: .any)["device-library-list"]
        XCTAssertTrue(populatedList.waitForExistence(timeout: 2.0))
        XCTAssertTrue(populatedList.descendants(matching: .any)["device-row-\(seededDevices[0].id.uuidString)"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(populatedList.descendants(matching: .any)["device-row-\(seededDevices[1].id.uuidString)"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(window.descendants(matching: .any)["device-library-empty-state"].exists)
        XCTAssertFalse(window.staticTexts["还没有已保存设备"].exists)

        let addButton = window.buttons["添加设备"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2.0))

        let formActions = window.descendants(matching: .any)["device-library-form-actions"]
        clickElementAfterActivatingApp(addButton, in: app)
        if !formActions.waitForExistence(timeout: 2.0) {
            clickElementAfterActivatingApp(addButton, in: app)
        }
        XCTAssertTrue(formActions.waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["名称"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.textFields["请输入设备名称"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["请填写设备名称"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["MAC 地址"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.textFields["AA:BB:CC:DD:EE:FF"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["请填写 MAC 地址"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testLaunchWithSeededDeviceLibraryShowsManagementListSurface() throws {
        let seededDevices = [
            SeededSavedDevice(
                id: UUID(),
                name: "Ugreen NAS",
                macAddress: "6C:1F:F7:75:C7:0E",
                note: "书房机柜",
                sortOrder: 0
            ),
            SeededSavedDevice(
                id: UUID(),
                name: "Mac mini",
                macAddress: "AA:BB:CC:DD:EE:FF",
                note: "工作台",
                sortOrder: 1
            )
        ]
        let launchContext = try makeLaunchContext(seededDevices: seededDevices)
        defer {
            launchContext.defaults.removePersistentDomain(forName: launchContext.suiteName)
        }

        let app = makeApplication(
            launchContext: launchContext,
            additionalArguments: ["--ui-test-open-device-library"]
        )
        app.launch()
        defer { terminateIfRunning(app) }

        let window = waitForDeviceLibraryWindow(in: app)
        let populatedList = window.descendants(matching: .any)["device-library-list"]
        XCTAssertTrue(populatedList.waitForExistence(timeout: 2.0))
        XCTAssertTrue(populatedList.descendants(matching: .any)["device-row-\(seededDevices[0].id.uuidString)"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(populatedList.descendants(matching: .any)["device-row-\(seededDevices[1].id.uuidString)"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(window.descendants(matching: .any)["device-library-empty-state"].exists)
        XCTAssertFalse(window.staticTexts["还没有已保存设备"].exists)
        XCTAssertTrue(window.buttons["添加设备"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState() throws {
        let launchContext = try makeLaunchContext()
        defer {
            launchContext.defaults.removePersistentDomain(forName: launchContext.suiteName)
        }

        let app = makeApplication(
            launchContext: launchContext,
            additionalArguments: ["--ui-test-open-device-library"]
        )
        app.launch()
        defer { terminateIfRunning(app) }

        let window = waitForDeviceLibraryWindow(in: app)
        XCTAssertTrue(
            window.buttons["device-library-empty-add-button"].waitForExistence(timeout: 2.0)
        )
        XCTAssertFalse(window.descendants(matching: .any)["device-library-list"].exists)
        XCTAssertFalse(window.textFields["请输入设备名称"].exists)
    }

    @MainActor
    func testLaunchWithWOLWindowShowsPolishedSections() throws {
        let launchContext = try makeLaunchContext()
        defer {
            launchContext.defaults.removePersistentDomain(forName: launchContext.suiteName)
        }

        let app = makeApplication(
            launchContext: launchContext,
            additionalArguments: ["--ui-test-open-wol-window"]
        )
        app.launch()
        defer { terminateIfRunning(app) }

        let window = waitForWOLWindow(in: app)
        XCTAssertTrue(window.descendants(matching: .any)["wol-mode-group"].waitForExistence(timeout: 2.0))

        let customMACField = window.textFields["wol-custom-mac-field"]
        let savedDevicePicker = window.popUpButtons["wol-saved-device-picker"]
        XCTAssertTrue(
            customMACField.waitForExistence(timeout: 1.0)
                || window.textFields["请输入 MAC 地址"].waitForExistence(timeout: 1.0)
                || savedDevicePicker.waitForExistence(timeout: 1.0),
            "Expected the WOL window to show either the custom MAC field or the saved-device picker."
        )

        XCTAssertTrue(window.descendants(matching: .any)["wol-action-row"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(
            window.buttons["wol-send-button"].waitForExistence(timeout: 1.0)
                || window.buttons["发送唤醒包"].waitForExistence(timeout: 1.0)
        )
    }

    @MainActor
    func testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface() throws {
        let launchContext = try makeLaunchContext()
        defer {
            launchContext.defaults.removePersistentDomain(forName: launchContext.suiteName)
        }

        let app = makeApplication(
            launchContext: launchContext,
            additionalArguments: ["--ui-test-open-keep-awake-duration-management"]
        )
        app.launch()
        defer { terminateIfRunning(app) }

        let window = waitForKeepAwakeDurationManagementWindow(in: app)
        let durationList = window.descendants(matching: .any)["keep-awake-duration-list"]
        XCTAssertTrue(durationList.waitForExistence(timeout: 2.0))

        XCTAssertTrue(window.staticTexts["15 分钟"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["30 分钟"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["1 小时"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["2 小时"].waitForExistence(timeout: 2.0))

        let addButton = window.buttons["添加时长"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2.0))

        clickElementAfterActivatingApp(addButton, in: app)

        XCTAssertTrue(window.staticTexts["时长（分钟）"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(
            window.textFields["keep-awake-duration-minutes-field"].waitForExistence(timeout: 2.0)
                || window.textFields["请输入分钟数"].waitForExistence(timeout: 2.0)
        )
        XCTAssertTrue(window.buttons["保存时长"].waitForExistence(timeout: 2.0))
    }
}

private func waitForDeviceLibraryWindow(in app: XCUIApplication) -> XCUIElement {
    XCTAssertTrue(
        waitForAnyElement(
            [
                app.descendants(matching: .any)["device-library-top-actions"],
                app.descendants(matching: .any)["device-library-empty-state"],
                app.buttons["添加设备"]
            ],
            timeout: 5.0
        ),
        "Expected the device library surface to appear after direct launch."
    )

    let titledWindow = app.windows["设备库"]
    if titledWindow.waitForExistence(timeout: 2.0) {
        return titledWindow
    }

    let fallbackWindow = app.windows.firstMatch
    if fallbackWindow.exists || fallbackWindow.waitForExistence(timeout: 2.0) {
        return fallbackWindow
    }

    return app
}

private func waitForWOLWindow(in app: XCUIApplication) -> XCUIElement {
    XCTAssertTrue(
        waitForAnyElement(
            [
                app.descendants(matching: .any)["wol-mode-group"],
                app.descendants(matching: .any)["wol-action-row"],
                app.buttons["wol-send-button"]
            ],
            timeout: 5.0
        ),
        "Expected the WOL window surface to appear after direct launch."
    )

    let titledWindow = app.windows["WOL 发送器"]
    if titledWindow.waitForExistence(timeout: 2.0) {
        return titledWindow
    }

    let fallbackWindow = app.windows.firstMatch
    XCTAssertTrue(fallbackWindow.waitForExistence(timeout: 2.0), "Expected a WOL window after the surface appeared.")
    return fallbackWindow
}

private func waitForKeepAwakeDurationManagementWindow(in app: XCUIApplication) -> XCUIElement {
    XCTAssertTrue(
        waitForAnyElement(
            [
                app.descendants(matching: .any)["keep-awake-duration-top-actions"],
                app.descendants(matching: .any)["keep-awake-duration-list"],
                app.buttons["添加时长"]
            ],
            timeout: 5.0
        ),
        "Expected the keep-awake duration management surface to appear after direct launch."
    )

    let titledWindow = app.windows["常亮时长"]
    if titledWindow.waitForExistence(timeout: 2.0) {
        return titledWindow
    }

    let fallbackWindow = app.windows.firstMatch
    if fallbackWindow.exists || fallbackWindow.waitForExistence(timeout: 2.0) {
        return fallbackWindow
    }

    return app
}

private func waitForAnyElement(_ elements: [XCUIElement], timeout: TimeInterval) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)

    repeat {
        if elements.contains(where: \.exists) {
            return true
        }
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
    } while Date() < deadline

    return elements.contains(where: \.exists)
}

private func terminateIfRunning(_ app: XCUIApplication) {
    if app.state != .notRunning {
        app.terminate()
    }
}

private func clickElementAfterActivatingApp(_ element: XCUIElement, in app: XCUIApplication) {
    app.activate()
    XCTAssertTrue(element.waitForExistence(timeout: 2.0), "Expected the element to exist before clicking it.")
    element.click()
}

private struct LaunchContext {
    let suiteName: String
    let defaults: UserDefaults
    let seededDeviceLibraryData: Data?
}

private struct SeededSavedDevice: Codable {
    let id: UUID
    let name: String
    let macAddress: String
    let note: String
    let sortOrder: Int
}

private func makeLaunchContext(seededDevices: [SeededSavedDevice] = []) throws -> LaunchContext {
    let suiteName = "Tools-Cat-UITests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)

    let seededDeviceLibraryData: Data?
    if seededDevices.isEmpty {
        seededDeviceLibraryData = nil
    } else {
        let encodedData = try JSONEncoder().encode(seededDevices)
        defaults.set(encodedData, forKey: "saved_devices")
        defaults.synchronize()
        seededDeviceLibraryData = encodedData
    }

    return LaunchContext(
        suiteName: suiteName,
        defaults: defaults,
        seededDeviceLibraryData: seededDeviceLibraryData
    )
}

private func makeApplication(
    launchContext: LaunchContext,
    additionalArguments: [String]
) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments.append(contentsOf: additionalArguments)
    app.launchArguments.append("--ui-test-user-defaults-suite")
    app.launchArguments.append(launchContext.suiteName)

    if let seededDeviceLibraryData = launchContext.seededDeviceLibraryData {
        app.launchArguments.append("--ui-test-seeded-device-library")
        app.launchArguments.append(seededDeviceLibraryData.base64EncodedString())
    }

    return app
}
