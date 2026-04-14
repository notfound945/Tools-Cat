import Combine
import XCTest
@testable import Tools_Cat

@MainActor
final class StatusBarControllerMenuPolishTests: XCTestCase {
    private static var retainedControllers: [StatusBarController] = []

    func testRootMenuUsesThreeSectionOrderWithTwoNativeSeparators() async throws {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuPolishSavedDeviceRepository(devices: devices))
        try? store.markWakeSucceeded(deviceID: devices[0].id)
        let controller = makeController(deviceLibrary: store)

        let separators = controller.menuItemsForTesting.enumerated().filter { $0.element.isSeparatorItem }
        let firstSeparatorIndex = try XCTUnwrap(separators.first?.offset)
        let secondSeparatorIndex = try XCTUnwrap(separators.last?.offset)

        XCTAssertEqual(separators.count, 2)
        XCTAssertEqual(firstSeparatorIndex, controller.menuIndexForTesting(of: controller.keepAwakeStatusItem) + 1)
        XCTAssertLessThan(firstSeparatorIndex, controller.wolMenuIndexForTesting)
        XCTAssertLessThan(controller.wolMenuIndexForTesting, secondSeparatorIndex)

        let wakeTitles = controller.menuItemsForTesting[(firstSeparatorIndex + 1)..<secondSeparatorIndex]
            .filter { !$0.isSeparatorItem }
            .map(\.title)
        XCTAssertEqual(wakeTitles, ["快速 WOL", "发送 WOL …", "", "管理 WOL 设备…"])
    }

    func testIdleMenuCollapsesBothStatusRows() {
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuPolishSavedDeviceRepository(devices: makeDevices()))
        let controller = makeController(deviceLibrary: store)

        XCTAssertTrue(controller.keepAwakeStatusItem.isHidden)
        XCTAssertEqual(controller.keepAwakeStatusItem.title, "")

        XCTAssertNotNil(controller.wakeStatusItem)
        XCTAssertEqual(controller.wakeStatusItem?.title, "")
        XCTAssertEqual(controller.wakeStatusItem?.isEnabled, false)
        XCTAssertEqual(controller.wakeStatusItem?.isHidden, true)
    }

    func testWakeSectionKeepsManualSendRowWhenLibraryIsEmpty() async throws {
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuPolishSavedDeviceRepository(devices: []))
        let sender = RecordingMenuPolishWakeSender()
        let session = WOLSessionModel(
            deviceLibrary: store,
            inputMode: .custom,
            customMac: "AA:BB:CC:DD:EE:FF",
            wakeSender: sender
        )
        let controller = makeController(deviceLibrary: store, wolSession: session)

        let separators = controller.menuItemsForTesting.enumerated().filter { $0.element.isSeparatorItem }
        let firstSeparatorIndex = try XCTUnwrap(separators.first?.offset)
        let secondSeparatorIndex = try XCTUnwrap(separators.last?.offset)

        XCTAssertEqual(
            controller.menuItemsForTesting[(firstSeparatorIndex + 1)..<secondSeparatorIndex]
                .filter { !$0.isSeparatorItem }
                .map(\.title),
            ["发送 WOL …", "", "管理 WOL 设备…"]
        )
        XCTAssertEqual(controller.wolMenuIndexForTesting, firstSeparatorIndex + 1)

        session.sendCurrentSelection()
        await expectLastCompletedWake(of: session) { $0?.message == WakeSendPresentation.successMessage(for: "AA:BB:CC:DD:EE:FF") }

        XCTAssertEqual(sender.sentMacs, ["AA:BB:CC:DD:EE:FF"])
        XCTAssertEqual(controller.wakeStatusItem?.title, WakeSendPresentation.successMessage(for: "AA:BB:CC:DD:EE:FF"))
        XCTAssertEqual(controller.wakeStatusItem?.isHidden, false)
    }

    func testManageWOLDevicesStaysAtEndOfWakeGroupAndQuitRemainsLastRow() {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuPolishSavedDeviceRepository(devices: devices))
        try? store.markWakeSucceeded(deviceID: devices[0].id)
        let controller = makeController(deviceLibrary: store)

        let titles = controller.menuItemsForTesting.map(\.title)
        let separators = controller.menuItemsForTesting.enumerated().filter { $0.element.isSeparatorItem }
        let secondSeparatorIndex = try! XCTUnwrap(separators.last?.offset)

        XCTAssertEqual(titles.last, "退出 Tools Cat")
        XCTAssertEqual(titles[secondSeparatorIndex - 1], "管理 WOL 设备…")
        XCTAssertEqual(controller.menuItemsForTesting[secondSeparatorIndex].isSeparatorItem, true)
    }

    private func makeController(
        deviceLibrary: SavedDeviceLibraryStore,
        wolSession: WOLSessionModel? = nil
    ) -> StatusBarController {
        let session = wolSession ?? WOLSessionModel(deviceLibrary: deviceLibrary, wakeSender: RecordingMenuPolishWakeSender())
        let controller = StatusBarController(
            deviceLibrary: deviceLibrary,
            wolSession: session,
            keepAwakeSession: KeepAwakeSessionModel(
                powerController: FakeMenuPolishPowerController(),
                scheduler: FakeMenuPolishCountdownScheduler(),
                nowProvider: { Date(timeIntervalSinceReferenceDate: 0) }
            )
        )
        Self.retainedControllers.append(controller)
        return controller
    }

    private func makeDevices() -> [SavedDevice] {
        [
            SavedDevice(id: UUID(), name: "书房 Mac", macAddress: "AA:BB:CC:DD:EE:01", note: "", sortOrder: 0),
            SavedDevice(id: UUID(), name: "客厅 NAS", macAddress: "AA:BB:CC:DD:EE:02", note: "", sortOrder: 1),
        ]
    }

    private func expectLastCompletedWake(
        of model: WOLSessionModel,
        matching predicate: @escaping (CompletedWakeAttempt?) -> Bool,
        timeout: TimeInterval = 1.0
    ) async {
        let expectation = expectation(description: "last completed wake matched")
        var cancellable: AnyCancellable?

        if predicate(model.lastCompletedWake) {
            expectation.fulfill()
        } else {
            cancellable = model.$lastCompletedWake.sink { attempt in
                if predicate(attempt) {
                    expectation.fulfill()
                }
            }
        }

        await fulfillment(of: [expectation], timeout: timeout)
        withExtendedLifetime(cancellable) {}
    }
}

private final class InMemoryMenuPolishSavedDeviceRepository: SavedDeviceRepository {
    private var devices: [SavedDevice]
    private var wakeMetadata = SavedDeviceWakeMetadata(recentDeviceIDs: [], lastUsedDeviceID: nil)

    init(devices: [SavedDevice]) {
        self.devices = devices
    }

    func loadDevices() throws -> [SavedDevice] {
        devices
    }

    func saveDevices(_ devices: [SavedDevice]) throws {
        self.devices = devices
    }

    func loadWakeMetadata() throws -> SavedDeviceWakeMetadata {
        wakeMetadata
    }

    func saveWakeMetadata(_ metadata: SavedDeviceWakeMetadata) throws {
        wakeMetadata = metadata
    }
}

private final class RecordingMenuPolishWakeSender: WakeSending {
    private(set) var sentMacs: [String] = []
    var result: Result<Void, Error> = .success(())

    func send(to macAddress: String) throws {
        sentMacs.append(macAddress)
        try result.get()
    }
}

private final class FakeMenuPolishCountdownScheduler: KeepAwakeCountdownScheduling {
    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        FakeMenuPolishCountdownToken()
    }
}

private final class FakeMenuPolishCountdownToken: KeepAwakeCountdownToken {
    func cancel() {}
}

@MainActor
private final class FakeMenuPolishPowerController: KeepAwakePowerControlling {
    let isEnabled = false

    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    ) {
        completion(.success(enabled))
    }
}
