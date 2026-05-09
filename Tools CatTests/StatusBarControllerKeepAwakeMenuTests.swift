import AppKit
import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class StatusBarControllerKeepAwakeMenuTests: XCTestCase {
    func testKeepAwakeMenuOrderMatchesTheFixedActionGroup() async throws {
        let fixture = makeFixture()
        let keepAwakeItems = keepAwakeActionItems(of: fixture.controller)
        let keepAwakeTitles = keepAwakeItems.map(\.title)
        let keepAwakeIndexes = keepAwakeItems.map { fixture.controller.menuIndexForTesting(of: $0) }
        let statusIndex = fixture.controller.menuIndexForTesting(of: fixture.controller.keepAwakeStatusItem)
        let manageIndex = fixture.controller.menuItemsForTesting.firstIndex(where: { $0.title == "管理常亮时长…" })

        XCTAssertEqual(
            keepAwakeTitles,
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertEqual(keepAwakeIndexes, [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(statusIndex, 6)
        XCTAssertEqual(manageIndex, 7)
        XCTAssertEqual(fixture.controller.wolMenuIndexForTesting, 9)
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.title, "")
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.isEnabled, false)
        XCTAssertTrue(fixture.controller.keepAwakeStatusItem.isHidden)

        await flushControllerUpdates()
        withExtendedLifetime(fixture) {}
    }

    func testKeepAwakeActionItemsDispatchThroughSharedSession() throws {
        let startCases: [(String, Int?, [Bool])] = [
            ("无限常亮", nil, [true]),
            ("15 分钟", 900, [true]),
            ("30 分钟", 1800, [true]),
            ("1 小时", 3600, [true]),
            ("2 小时", 7200, [true]),
        ]

        for (title, expectedSeconds, expectedRequests) in startCases {
            let fixture = makeFixture()
            let actionItem = try actionItemMatching(title, in: fixture.controller)

            trigger(actionItem)

            switch (fixture.session.pendingAction, expectedSeconds) {
            case (.startingIndefinite, nil):
                break
            case let (.startingTimed(duration), .some(seconds)):
                XCTAssertEqual(duration.durationSeconds, seconds)
            default:
                XCTFail("Unexpected pending action for \(title)")
            }
            XCTAssertEqual(fixture.powerController.requestedStates, expectedRequests)
        }

        let stopFixture = makeFixture(initiallyEnabled: true)
        trigger(stopFixture.controller.keepAwakeOffItem)

        XCTAssertEqual(stopFixture.session.pendingAction, .stopping)
        XCTAssertEqual(stopFixture.powerController.requestedStates, [false])
    }

    func testConfirmedTimedModeChecksOnlyTheSelectedPresetRow() async throws {
        let fixture = makeFixture()

        trigger(fixture.controller.keepAwake30MinutesItem)
        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        XCTAssertEqual(fixture.controller.keepAwakeIndefiniteItem.state, .off)
        XCTAssertEqual(fixture.controller.keepAwake15MinutesItem.state, .off)
        XCTAssertEqual(fixture.controller.keepAwake30MinutesItem.state, .on)
        XCTAssertEqual(fixture.controller.keepAwake1HourItem.state, .off)
        XCTAssertEqual(fixture.controller.keepAwake2HoursItem.state, .off)
        XCTAssertEqual(fixture.controller.keepAwakeOffItem.state, .off)
    }

    func testPendingTransitionDisablesAllKeepAwakeActionRows() {
        let fixture = makeFixture()

        trigger(fixture.controller.keepAwake1HourItem)

        XCTAssertEqual(
            keepAwakeActionItems(of: fixture.controller).map(\.title),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertTrue(keepAwakeActionItems(of: fixture.controller).allSatisfy { !$0.isEnabled })
    }

    func testIdleMenuHidesStopRowWhenKeepAwakeIsOff() async {
        let fixture = makeFixture()

        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时"]
        )
        XCTAssertTrue(fixture.controller.keepAwakeOffItem.isHidden)

        await flushControllerUpdates()
        withExtendedLifetime(fixture) {}
    }

    func testStartupFromOffKeepsStopRowHiddenUntilActivationSucceeds() async {
        let fixture = makeFixture()

        trigger(fixture.controller.keepAwake15MinutesItem)

        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时"]
        )
        XCTAssertTrue(fixture.controller.keepAwakeOffItem.isHidden)
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.title, "正在切换为 15 分钟常亮...")
        XCTAssertTrue(keepAwakeActionItems(of: fixture.controller).allSatisfy { !$0.isEnabled })

        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertFalse(fixture.controller.keepAwakeOffItem.isHidden)
        XCTAssertEqual(fixture.controller.keepAwake15MinutesItem.state, .on)
    }

    func testConfirmedActiveSessionShowsStopRow() async {
        let fixture = makeFixture()

        trigger(fixture.controller.keepAwakeIndefiniteItem)
        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertFalse(fixture.controller.keepAwakeOffItem.isHidden)
    }

    func testReplacementWhileAlreadyActiveKeepsStopRowVisibleDuringPendingStart() {
        let fixture = makeFixture(initiallyEnabled: true)

        trigger(fixture.controller.keepAwake30MinutesItem)

        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertFalse(fixture.controller.keepAwakeOffItem.isHidden)
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.title, "正在切换为 30 分钟常亮...")
        XCTAssertTrue(keepAwakeActionItems(of: fixture.controller).allSatisfy { !$0.isEnabled })
    }

    func testStoppingStateKeepsStopRowVisibleButDisabled() {
        let fixture = makeFixture(initiallyEnabled: true)

        trigger(fixture.controller.keepAwakeOffItem)

        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertFalse(fixture.controller.keepAwakeOffItem.isHidden)
        XCTAssertTrue(keepAwakeActionItems(of: fixture.controller).allSatisfy { !$0.isEnabled })
    }

    func testCountdownNeverAppearsInAnyActionTitle() async {
        let fixture = makeFixture()

        trigger(fixture.controller.keepAwake30MinutesItem)
        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        fixture.now.value = fixture.startNow.addingTimeInterval(120)
        fixture.scheduler.startedTokens[0].fire()
        await flushControllerUpdates()

        XCTAssertEqual(
            keepAwakeActionItems(of: fixture.controller).map(\.title),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.title, "还剩 28 分钟")
    }

    func testKeepAwakeStatusRowRendersPresentationStatusText() async {
        let fixture = makeFixture()

        trigger(fixture.controller.keepAwakeIndefiniteItem)
        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.title, "当前：无限常亮")
        XCTAssertFalse(fixture.controller.keepAwakeStatusItem.isHidden)
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.isEnabled, false)
    }

    func testStatusItemToolTipAndSymbolFollowPresentationState() async throws {
        let fixture = makeFixture()
        let button = try XCTUnwrap(fixture.controller.statusButtonForTesting)

        XCTAssertEqual(button.toolTip, "常亮已关闭")
        assertStatusItemSymbol(button.image, equals: "bolt.slash")

        trigger(fixture.controller.keepAwakeIndefiniteItem)

        XCTAssertEqual(button.toolTip, "常亮状态更新中")
        assertStatusItemSymbol(button.image, equals: "bolt.slash")

        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        XCTAssertEqual(button.toolTip, "常亮已开启：无限常亮")
        assertStatusItemSymbol(button.image, equals: "bolt.fill")
    }

    func testReminderPermissionUnavailableReusesKeepAwakeStatusRow() async throws {
        let reminderScheduler = FakeKeepAwakeReminderScheduler()
        let fixture = makeFixture(reminderScheduler: reminderScheduler)

        trigger(fixture.controller.keepAwake15MinutesItem)
        fixture.powerController.complete(with: .success(true))
        await flushControllerUpdates()

        reminderScheduler.completeRequest(at: 0, with: .permissionUnavailable)
        await flushControllerUpdates()

        XCTAssertEqual(fixture.controller.keepAwake15MinutesItem.state, .on)
        XCTAssertEqual(fixture.controller.keepAwakeOffItem.isHidden, false)
        XCTAssertEqual(fixture.controller.keepAwakeStatusItem.title, "提醒不可用：通知权限未开启")
        XCTAssertEqual(
            visibleKeepAwakeActionTitles(of: fixture.controller),
            ["无限常亮", "15 分钟", "30 分钟", "1 小时", "2 小时", "关闭常亮"]
        )
    }

    private func makeFixture(
        initiallyEnabled: Bool = false,
        reminderScheduler: FakeKeepAwakeReminderScheduler = FakeKeepAwakeReminderScheduler()
    ) -> KeepAwakeMenuFixture {
        let deviceLibrary = SavedDeviceLibraryStore(repository: KeepAwakeMenuSavedDeviceRepository())
        let wolSession = WOLSessionModel(deviceLibrary: deviceLibrary, wakeSender: NoopWakeSender())
        let powerController = RecordingKeepAwakePowerController(isEnabled: initiallyEnabled)
        let scheduler = RecordingKeepAwakeCountdownScheduler()
        let now = MutableNowBox(value: Date(timeIntervalSinceReferenceDate: 80_000))
        let durationSuiteName = "StatusBarControllerKeepAwakeMenuTests.\(UUID().uuidString)"
        let durationDefaults = UserDefaults(suiteName: durationSuiteName)!
        durationDefaults.removePersistentDomain(forName: durationSuiteName)
        let durationStore = KeepAwakeDurationStore(
            repository: UserDefaultsKeepAwakeDurationRepository(defaults: durationDefaults)
        )
        let session = KeepAwakeSessionModel(
            powerController: powerController,
            scheduler: scheduler,
            reminderScheduler: reminderScheduler,
            nowProvider: { now.value }
        )
        let controller = StatusBarController(
            deviceLibrary: deviceLibrary,
            wolSession: wolSession,
            keepAwakeSession: session,
            keepAwakeDurationStore: durationStore
        )

        return KeepAwakeMenuFixture(
            controller: controller,
            session: session,
            powerController: powerController,
            scheduler: scheduler,
            reminderScheduler: reminderScheduler,
            durationStore: durationStore,
            durationDefaults: durationDefaults,
            now: now,
            startNow: now.value
        )
    }

    private func actionItemMatching(_ title: String, in controller: StatusBarController) throws -> NSMenuItem {
        try XCTUnwrap(keepAwakeActionItems(of: controller).first { $0.title == title })
    }

    private func keepAwakeActionItems(of controller: StatusBarController) -> [NSMenuItem] {
        [controller.keepAwakeIndefiniteItem] + controller.keepAwakeTimedItemsForTesting + [controller.keepAwakeOffItem]
    }

    private func visibleKeepAwakeActionTitles(of controller: StatusBarController) -> [String] {
        keepAwakeActionItems(of: controller)
            .filter { !$0.isHidden }
            .map(\.title)
    }

    private func trigger(_ item: NSMenuItem) {
        guard let action = item.action else {
            XCTFail("Expected keep-awake menu action")
            return
        }

        _ = (item.target as AnyObject).perform(action, with: item)
    }

    private func flushControllerUpdates() async {
        await Task.yield()
        await Task.yield()
        try? await Task.sleep(nanoseconds: 50_000_000)
    }

    private func assertStatusItemSymbol(_ image: NSImage?, equals symbolName: String, file: StaticString = #filePath, line: UInt = #line) {
        let expectedImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
        XCTAssertEqual(image?.tiffRepresentation, expectedImage?.tiffRepresentation, file: file, line: line)
    }
}

private struct KeepAwakeMenuFixture {
    let controller: StatusBarController
    let session: KeepAwakeSessionModel
    let powerController: RecordingKeepAwakePowerController
    let scheduler: RecordingKeepAwakeCountdownScheduler
    let reminderScheduler: FakeKeepAwakeReminderScheduler
    let durationStore: KeepAwakeDurationStore
    let durationDefaults: UserDefaults
    let now: MutableNowBox
    let startNow: Date
}

private final class MutableNowBox {
    var value: Date

    init(value: Date) {
        self.value = value
    }
}

private final class KeepAwakeMenuSavedDeviceRepository: SavedDeviceRepository {
    func loadDevices() throws -> [SavedDevice] { [] }
    func saveDevices(_ devices: [SavedDevice]) throws {}
    func loadWakeMetadata() throws -> SavedDeviceWakeMetadata {
        SavedDeviceWakeMetadata(recentDeviceIDs: [], lastUsedDeviceID: nil)
    }
    func saveWakeMetadata(_ metadata: SavedDeviceWakeMetadata) throws {}
}

private final class NoopWakeSender: WakeSending {
    func send(to macAddress: String) throws {}
}

@MainActor
private final class RecordingKeepAwakePowerController: KeepAwakePowerControlling {
    private(set) var isEnabled: Bool
    private(set) var requestedStates: [Bool] = []
    private var pendingCompletions: [(KeepAwakeToggleOutcome) -> Void] = []

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    ) {
        requestedStates.append(enabled)
        pendingCompletions.append(completion)
    }

    func complete(with outcome: KeepAwakeToggleOutcome) {
        switch outcome {
        case .success(let enabled), .unchanged(let enabled):
            isEnabled = enabled
        case .failure(let current, _):
            isEnabled = current
        }

        let completion = pendingCompletions.removeFirst()
        completion(outcome)
    }
}

private final class RecordingKeepAwakeCountdownScheduler: KeepAwakeCountdownScheduling {
    private(set) var startedTokens: [RecordingKeepAwakeCountdownToken] = []

    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        let token = RecordingKeepAwakeCountdownToken(handler: handler)
        startedTokens.append(token)
        return token
    }
}

private final class RecordingKeepAwakeCountdownToken: KeepAwakeCountdownToken {
    private let handler: () -> Void
    private(set) var didCancel = false

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func cancel() {
        didCancel = true
    }

    func fire() {
        handler()
    }
}
