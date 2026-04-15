import Combine
import XCTest
@testable import Tools_Cat

@MainActor
final class StatusBarControllerEntryFlowTests: XCTestCase {
    private static var retainedControllers: [StatusBarController] = []

    func testWakeMenuEntryDispatchesThroughOnOpenWOL() async throws {
        let controller = makeController(deviceLibrary: makeStore())
        let wakeItem = try findMenuItem(titled: "发送 WOL …", in: controller.menuItemsForTesting)
        let callbackExpectation = expectation(description: "wake entry dispatched")
        var openCount = 0

        controller.onOpenWOL = {
            openCount += 1
            callbackExpectation.fulfill()
        }

        trigger(wakeItem)

        await fulfillment(of: [callbackExpectation], timeout: 1.0)
        XCTAssertEqual(openCount, 1)
    }

    func testManagementMenuEntryDispatchesThroughOnOpenDeviceLibrary() async throws {
        let controller = makeController(deviceLibrary: makeStore())
        let managementItem = try findMenuItem(titled: "管理 WOL 设备…", in: controller.menuItemsForTesting)
        let callbackExpectation = expectation(description: "management entry dispatched")
        var openCount = 0

        controller.onOpenDeviceLibrary = {
            openCount += 1
            callbackExpectation.fulfill()
        }

        trigger(managementItem)

        await fulfillment(of: [callbackExpectation], timeout: 1.0)
        XCTAssertEqual(openCount, 1)
    }

    func testKeepAwakeDurationManagementEntryDispatchesThroughCallback() async throws {
        let controller = makeController(deviceLibrary: makeStore())
        let managementItem = try findMenuItem(titled: "管理常亮时长…", in: controller.menuItemsForTesting)
        let callbackExpectation = expectation(description: "keep awake duration management entry dispatched")
        var openCount = 0

        controller.onOpenKeepAwakeDurationManagement = {
            openCount += 1
            callbackExpectation.fulfill()
        }

        trigger(managementItem)

        await fulfillment(of: [callbackExpectation], timeout: 1.0)
        XCTAssertEqual(openCount, 1)
    }

    func testWakeMenuEntryDisablesDuringInFlightSendWhileManagementEntryRemainsEnabled() async throws {
        let devices = makeDevices()
        let store = makeStore(devices: devices)
        let sender = BlockingEntryFlowWakeSender()
        let session = WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        let controller = makeController(deviceLibrary: store, wolSession: session)
        let wakeItem = try findMenuItem(titled: "发送 WOL …", in: controller.menuItemsForTesting)
        let managementItem = try findMenuItem(titled: "管理 WOL 设备…", in: controller.menuItemsForTesting)

        session.sendSavedDevice(id: devices[0].id)

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(wakeItem.isEnabled)
        XCTAssertTrue(managementItem.isEnabled)

        sender.finish()
        await expectSendState(of: session) { state in
            if case .success = state {
                return true
            }
            return false
        }
    }

    private func makeController(
        deviceLibrary: SavedDeviceLibraryStore,
        wolSession: WOLSessionModel? = nil
    ) -> StatusBarController {
        let session = wolSession ?? WOLSessionModel(
            deviceLibrary: deviceLibrary,
            wakeSender: RecordingEntryFlowWakeSender()
        )
        let controller = StatusBarController(
            deviceLibrary: deviceLibrary,
            wolSession: session,
            keepAwakeSession: KeepAwakeSessionModel(
                powerController: FakeEntryFlowPowerController(),
                scheduler: FakeEntryFlowCountdownScheduler(),
                nowProvider: { Date(timeIntervalSinceReferenceDate: 0) }
            )
        )
        Self.retainedControllers.append(controller)
        return controller
    }

    private func makeStore(devices: [SavedDevice]? = nil) -> SavedDeviceLibraryStore {
        SavedDeviceLibraryStore(
            repository: InMemoryEntryFlowSavedDeviceRepository(devices: devices ?? makeDevices())
        )
    }

    private func makeDevices() -> [SavedDevice] {
        [
            SavedDevice(id: UUID(), name: "书房 Mac", macAddress: "AA:BB:CC:DD:EE:01", note: "", sortOrder: 0),
            SavedDevice(id: UUID(), name: "客厅 NAS", macAddress: "AA:BB:CC:DD:EE:02", note: "", sortOrder: 1),
        ]
    }

    private func findMenuItem(titled title: String, in items: [NSMenuItem]) throws -> NSMenuItem {
        try XCTUnwrap(items.first(where: { $0.title == title }))
    }

    private func trigger(_ item: NSMenuItem) {
        guard let action = item.action else {
            XCTFail("Expected menu item action")
            return
        }

        _ = (item.target as AnyObject).perform(action, with: item)
    }

    private func expectSendState(
        of model: WOLSessionModel,
        matching predicate: @escaping (WakeSendState) -> Bool,
        timeout: TimeInterval = 1.0
    ) async {
        let expectation = expectation(description: "send state matched")
        var cancellable: AnyCancellable?

        if predicate(model.sendState) {
            expectation.fulfill()
        } else {
            cancellable = model.$sendState.sink { state in
                if predicate(state) {
                    expectation.fulfill()
                }
            }
        }

        await fulfillment(of: [expectation], timeout: timeout)
        withExtendedLifetime(cancellable) {}
    }
}

private final class InMemoryEntryFlowSavedDeviceRepository: SavedDeviceRepository {
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

private final class RecordingEntryFlowWakeSender: WakeSending {
    func send(to macAddress: String) throws {}
}

private final class BlockingEntryFlowWakeSender: WakeSending {
    private let semaphore = DispatchSemaphore(value: 0)

    func send(to macAddress: String) throws {
        semaphore.wait()
    }

    func finish() {
        semaphore.signal()
    }
}

private final class FakeEntryFlowCountdownScheduler: KeepAwakeCountdownScheduling {
    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        FakeEntryFlowCountdownToken()
    }
}

private final class FakeEntryFlowCountdownToken: KeepAwakeCountdownToken {
    func cancel() {}
}

@MainActor
private final class FakeEntryFlowPowerController: KeepAwakePowerControlling {
    let isEnabled = false

    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    ) {
        completion(.success(enabled))
    }
}
