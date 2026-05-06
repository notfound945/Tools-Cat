//
//  Tools_CatUITests.swift
//  Tools CatUITests
//
//  Created by hailinpan on 2025/10/19.
//

import AppKit
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

        let formSheet = app.descendants(matching: .any)["device-library-form-sheet"]
        let formActions = app.descendants(matching: .any)["device-library-form-actions"]
        clickElementAfterActivatingApp(addButton, in: app)
        if !formSheet.waitForExistence(timeout: 2.0) && !formActions.exists {
            clickElementAfterActivatingApp(addButton, in: app)
        }
        XCTAssertTrue(
            formSheet.waitForExistence(timeout: 2.0) || formActions.waitForExistence(timeout: 2.0)
        )
        XCTAssertTrue(populatedList.exists)
        let saveButton = formActions.descendants(matching: .button)["保存设备"]
        let cancelButton = formActions.descendants(matching: .button)["取消"]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 2.0)
                || app.descendants(matching: .button)["保存设备"].waitForExistence(timeout: 2.0)
        )
        XCTAssertTrue(
            cancelButton.waitForExistence(timeout: 2.0)
                || app.descendants(matching: .button)["取消"].waitForExistence(timeout: 2.0)
        )
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
    func testLaunchWithFreshDeviceLibrarySeedsDefaultDevice() throws {
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
        let populatedList = window.descendants(matching: .any)["device-library-list"]

        XCTAssertTrue(populatedList.waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["UGREEN NAS"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["6C:1F:F7:75:C7:0E"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(window.descendants(matching: .any)["device-library-empty-state"].exists)
    }

    @MainActor
    func testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState() throws {
        let launchContext = try makeLaunchContext(seededDevices: [])
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
    func testDeviceLibraryNameValidationRevealsAfterSubmit() throws {
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
        openDeviceLibraryAddForm(in: app, window: window)

        let nameField = deviceLibraryNameField(in: app)
        let macField = deviceLibraryMACField(in: app)
        let nameValidationMessage = deviceLibraryNameValidationMessage(in: app)

        XCTAssertTrue(nameField.waitForExistence(timeout: 5.0))
        XCTAssertTrue(macField.waitForExistence(timeout: 5.0))
        XCTAssertFalse(nameValidationMessage.exists)

        clickElementAfterActivatingApp(nameField, in: app)
        app.typeKey(XCUIKeyboardKey.return.rawValue, modifierFlags: [])

        XCTAssertTrue(nameValidationMessage.waitForExistence(timeout: 2.0))
        XCTAssertEqual(visibleText(of: nameValidationMessage), "请填写设备名称")
    }

    @MainActor
    func testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit() throws {
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
        let formActions = openDeviceLibraryAddForm(in: app, window: window)

        let nameField = deviceLibraryNameField(in: app)
        let macField = deviceLibraryMACField(in: app)
        let macValidationMessage = deviceLibraryMACValidationMessage(in: app)
        let saveButton = deviceLibrarySaveButton(in: app, formActions: formActions)

        XCTAssertTrue(nameField.waitForExistence(timeout: 5.0))
        XCTAssertTrue(macField.waitForExistence(timeout: 5.0))
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5.0))
        XCTAssertFalse(macValidationMessage.exists)

        replaceText(in: nameField, with: "书房 NAS")
        replaceText(in: macField, with: "AA:BB:CC")
        XCTAssertFalse(macValidationMessage.exists)

        clickElementAfterActivatingApp(saveButton, in: app)

        XCTAssertTrue(macValidationMessage.waitForExistence(timeout: 2.0))
        XCTAssertEqual(visibleText(of: macValidationMessage), "MAC 地址必须是 6 组两位十六进制字符")
        XCTAssertTrue(app.descendants(matching: .any)["device-library-form-sheet"].exists)
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
    func testCustomMACModeKeepsContentWithinWOLWindow() throws {
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
        let customModeButton = window.buttons["手动填写 MAC"]
        let presetModeButton = window.buttons["保存设备列表"]
        XCTAssertTrue(customModeButton.waitForExistence(timeout: 2.0))
        XCTAssertTrue(presetModeButton.waitForExistence(timeout: 2.0))

        let savedDevicePicker = window.popUpButtons["wol-saved-device-picker"]
        for _ in 0..<4 {
            clickElementAfterActivatingApp(customModeButton, in: app)
            XCTAssertTrue(
                window.textFields["wol-custom-mac-field"].waitForExistence(timeout: 2.0)
                    || window.textFields["请输入 MAC 地址"].waitForExistence(timeout: 2.0)
            )

            clickElementAfterActivatingApp(presetModeButton, in: app)
            XCTAssertTrue(savedDevicePicker.waitForExistence(timeout: 2.0))
        }

        clickElementAfterActivatingApp(customModeButton, in: app)
        RunLoop.current.run(until: Date().addingTimeInterval(0.35))

        let identifiedCustomMACField = window.textFields["wol-custom-mac-field"]
        let placeholderCustomMACField = window.textFields["请输入 MAC 地址"]
        XCTAssertTrue(
            identifiedCustomMACField.waitForExistence(timeout: 2.0)
                || placeholderCustomMACField.waitForExistence(timeout: 2.0)
        )
        let customMACField = identifiedCustomMACField.exists ? identifiedCustomMACField : placeholderCustomMACField

        let statusBlock = window.descendants(matching: .any)["wol-status-block"]
        XCTAssertTrue(statusBlock.waitForExistence(timeout: 2.0))

        let actionRow = window.descendants(matching: .any)["wol-action-row"].firstMatch
        XCTAssertTrue(actionRow.waitForExistence(timeout: 2.0))
        let cancelButton = window.buttons["wol-cancel-button"].firstMatch
        let sendButton = window.buttons["wol-send-button"].firstMatch
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2.0) || window.buttons["取消"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(sendButton.waitForExistence(timeout: 2.0) || window.buttons["发送唤醒包"].waitForExistence(timeout: 2.0))

        assertElementFrameIsContained(customMACField, within: window)
        assertElementFrameIsContained(statusBlock, within: window)
        assertElementFrameIsContained(cancelButton.exists ? cancelButton : window.buttons["取消"], within: window, padding: 4)
        assertElementFrameIsContained(sendButton.exists ? sendButton : window.buttons["发送唤醒包"], within: window, padding: 4)
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
        XCTAssertTrue(
            window.descendants(matching: .any)["keep-awake-duration-list-surface"].waitForExistence(timeout: 2.0)
        )
        let durationList = window.descendants(matching: .any)["keep-awake-duration-list"]
        XCTAssertTrue(durationList.waitForExistence(timeout: 2.0))

        XCTAssertTrue(window.staticTexts["15 分钟"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["30 分钟"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["1 小时"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(window.staticTexts["2 小时"].waitForExistence(timeout: 2.0))

        let addButton = window.buttons["添加时长"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2.0))

        clickElementAfterActivatingApp(addButton, in: app)

        XCTAssertTrue(durationList.exists)
        let formSheet = app.descendants(matching: .any)["keep-awake-duration-form-sheet"]
        let formActions = app.descendants(matching: .any)["keep-awake-duration-form-actions"]
        if !formSheet.waitForExistence(timeout: 2.0) && !formActions.exists {
            clickElementAfterActivatingApp(addButton, in: app)
        }
        XCTAssertTrue(
            formSheet.waitForExistence(timeout: 2.0) || formActions.waitForExistence(timeout: 2.0)
        )
        XCTAssertTrue(app.staticTexts["时长（分钟）"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(
            app.textFields["keep-awake-duration-minutes-field"].waitForExistence(timeout: 2.0)
                || app.textFields["请输入分钟数"].waitForExistence(timeout: 2.0)
        )
        let saveButton = formActions.descendants(matching: .button)["保存时长"]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 2.0)
                || app.descendants(matching: .button)["保存时长"].waitForExistence(timeout: 2.0)
        )

        let cancelButton = formActions.descendants(matching: .button)["取消"]
        if cancelButton.waitForExistence(timeout: 2.0) {
            clickElementAfterActivatingApp(cancelButton, in: app)
        } else {
            let fallbackCancelButton = app.descendants(matching: .button)["取消"]
            if fallbackCancelButton.waitForExistence(timeout: 2.0) {
                clickElementAfterActivatingApp(fallbackCancelButton, in: app)
            }
        }
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
    let titledWindow = app.windows["WOL 发送器"]
    if titledWindow.waitForExistence(timeout: 5.0) {
        return titledWindow
    }

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

private func deviceLibraryNameField(in app: XCUIApplication) -> XCUIElement {
    let identifiedField = app.descendants(matching: .any)["device-library-name-field"].firstMatch
    return identifiedField.exists ? identifiedField : app.textFields["请输入设备名称"].firstMatch
}

private func deviceLibraryMACField(in app: XCUIApplication) -> XCUIElement {
    let identifiedField = app.descendants(matching: .any)["device-library-mac-field"].firstMatch
    return identifiedField.exists ? identifiedField : app.textFields["AA:BB:CC:DD:EE:FF"].firstMatch
}

private func deviceLibraryNameValidationMessage(in app: XCUIApplication) -> XCUIElement {
    let identifiedMessage = app.descendants(matching: .any)["device-library-name-validation-message"].firstMatch
    return identifiedMessage.exists ? identifiedMessage : app.staticTexts["请填写设备名称"].firstMatch
}

private func deviceLibraryMACValidationMessage(in app: XCUIApplication) -> XCUIElement {
    let identifiedMessage = app.descendants(matching: .any)["device-library-mac-validation-message"].firstMatch
    return identifiedMessage.exists ? identifiedMessage : app.staticTexts["MAC 地址必须是 6 组两位十六进制字符"].firstMatch
}

private func deviceLibrarySaveButton(in app: XCUIApplication, formActions: XCUIElement) -> XCUIElement {
    let scopedButton = formActions.descendants(matching: .button)["保存设备"].firstMatch
    return scopedButton.exists ? scopedButton : app.buttons["保存设备"].firstMatch
}

@discardableResult
private func openDeviceLibraryAddForm(in app: XCUIApplication, window: XCUIElement) -> XCUIElement {
    let addButton = window.buttons["添加设备"].firstMatch
    XCTAssertTrue(addButton.waitForExistence(timeout: 2.0))

    let formSheet = app.descendants(matching: .any)["device-library-form-sheet"]
    let formActions = app.descendants(matching: .any)["device-library-form-actions"]
    clickElementAfterActivatingApp(addButton, in: app)
    if !formSheet.waitForExistence(timeout: 2.0) && !formActions.exists {
        clickElementAfterActivatingApp(addButton, in: app)
    }

    XCTAssertTrue(
        formSheet.waitForExistence(timeout: 2.0) || formActions.waitForExistence(timeout: 2.0),
        "Expected the device-library form sheet to appear."
    )

    return formActions
}

private func assertElementFrameIsContained(
    _ element: XCUIElement,
    within window: XCUIElement,
    padding: CGFloat = 8
) {
    let windowFrame = window.frame
    let elementFrame = element.frame
    let description = "Expected \(element.debugDescription) frame \(NSStringFromRect(elementFrame)) to stay within \(NSStringFromRect(windowFrame))"

    XCTAssertGreaterThanOrEqual(elementFrame.minX, windowFrame.minX + padding, description)
    XCTAssertGreaterThanOrEqual(elementFrame.minY, windowFrame.minY + padding, description)
    XCTAssertLessThanOrEqual(elementFrame.maxX, windowFrame.maxX - padding, description)
    XCTAssertLessThanOrEqual(elementFrame.maxY, windowFrame.maxY - padding, description)
}

private func terminateIfRunning(_ app: XCUIApplication) {
    _ = app
    forceTerminateApplications(matchingBundleIdentifier: toolsCatBundleIdentifier)
}

private func clickElementAfterActivatingApp(_ element: XCUIElement, in app: XCUIApplication) {
    app.activate()
    XCTAssertTrue(element.waitForExistence(timeout: 2.0), "Expected the element to exist before clicking it.")
    element.click()
}

private func replaceText(in element: XCUIElement, with text: String) {
    XCTAssertTrue(element.waitForExistence(timeout: 2.0), "Expected the text field to exist before typing.")
    element.click()
    element.typeText(text)
}

private func visibleText(of element: XCUIElement) -> String {
    if !element.label.isEmpty {
        return element.label
    }

    if let value = element.value as? String {
        return value
    }

    return ""
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

private func makeLaunchContext(seededDevices: [SeededSavedDevice]? = nil) throws -> LaunchContext {
    let suiteName = "Tools-Cat-UITests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)

    let seededDeviceLibraryData: Data?
    if let seededDevices {
        let encodedData = try JSONEncoder().encode(seededDevices)
        defaults.set(encodedData, forKey: "saved_devices")
        defaults.synchronize()
        seededDeviceLibraryData = encodedData
    } else {
        seededDeviceLibraryData = nil
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
    forceTerminateApplications(matchingBundleIdentifier: toolsCatBundleIdentifier)

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

private let toolsCatBundleIdentifier = "cn.notfound945.Tools-Cat"

private func forceTerminateApplications(matchingBundleIdentifier bundleIdentifier: String) {
    let deadline = Date().addingTimeInterval(5.0)

    repeat {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        guard !runningApps.isEmpty else { return }

        runningApps.forEach { app in
            _ = app.forceTerminate()
        }

        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
    } while Date() < deadline
}
