import Combine
import XCTest
@testable import Tools_Cat

@MainActor
final class StatusBarControllerWakeMenuTests: XCTestCase {
    func testRootMenuDoesNotSurfaceWakeHistory() async {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        try? store.markWakeSucceeded(deviceID: devices[1].id)
        try? store.markWakeSucceeded(deviceID: devices[3].id)
        try? store.markWakeSucceeded(deviceID: devices[0].id)
        try? store.markWakeSucceeded(deviceID: devices[2].id)

        let controller = makeController(deviceLibrary: store)

        XCTAssertTrue(controller.recentWakeItems.isEmpty)
        XCTAssertEqual(controller.allDevicesItem?.title, "快速 WOL")
        XCTAssertFalse(controller.menuItemsForTesting.contains(where: { $0.title == "阁楼 Mac" }))
        XCTAssertFalse(controller.menuItemsForTesting.contains(where: { $0.title == "书房 Mac" }))
    }

    func testAllSavedDevicesRemainReachableUnderAllDevicesSubmenu() async throws {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        try? store.markWakeSucceeded(deviceID: devices[0].id)

        let controller = makeController(deviceLibrary: store)
        let allDevicesItem = try XCTUnwrap(controller.allDevicesItem)
        let submenuItems = try XCTUnwrap(allDevicesItem.submenu?.items)

        XCTAssertEqual(submenuItems.count, devices.count)
        XCTAssertEqual(submenuItems.map { $0.representedObject as? UUID }, devices.map(\.id))
        XCTAssertTrue(submenuItems.allSatisfy { $0.action != nil })
    }

    func testAllDevicesSubmenuShowsMACAddressesInSmallerSecondaryText() async throws {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        let controller = makeController(deviceLibrary: store)
        let allDevicesItem = try XCTUnwrap(controller.allDevicesItem)
        let firstItem = try XCTUnwrap(allDevicesItem.submenu?.items.first)
        let attributedTitle = try XCTUnwrap(firstItem.attributedTitle)
        let titleString = attributedTitle.string as NSString
        let nameRange = titleString.range(of: devices[0].name)
        let macRange = titleString.range(of: devices[0].macAddress)
        let nameFont = try XCTUnwrap(attributedTitle.attribute(.font, at: nameRange.location, effectiveRange: nil) as? NSFont)
        let macFont = try XCTUnwrap(attributedTitle.attribute(.font, at: macRange.location, effectiveRange: nil) as? NSFont)

        XCTAssertEqual(attributedTitle.string, "\(devices[0].name)\n\(devices[0].macAddress)")
        XCTAssertLessThan(macFont.pointSize, nameFont.pointSize)
    }

    func testMenuWakeRowsDispatchThroughSharedSession() async throws {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        try? store.markWakeSucceeded(deviceID: devices[0].id)
        let sender = RecordingMenuWakeSender()
        let session = WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        let controller = makeController(deviceLibrary: store, wolSession: session)

        let allDevicesItem = try XCTUnwrap(controller.allDevicesItem)
        let firstDeviceItem = try XCTUnwrap(allDevicesItem.submenu?.items.first)
        trigger(firstDeviceItem)

        await expectLastCompletedWake(of: session) { attempt in
            attempt?.deviceID == devices[0].id && attempt?.wasSuccessful == true
        }

        XCTAssertEqual(sender.sentMacs, [devices[0].macAddress])
        XCTAssertEqual(store.recentDeviceIDs, [devices[0].id])
    }

    func testWakeMenuActionsDisableWhileSendIsInFlight() async {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        try? store.markWakeSucceeded(deviceID: devices[0].id)
        let sender = BlockingMenuWakeSender()
        let session = WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        let controller = makeController(deviceLibrary: store, wolSession: session)

        session.sendSavedDevice(id: devices[0].id)

        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(
            controller.allDevicesItem?.submenu?.items.allSatisfy { !$0.isEnabled } == true,
            "All devices rows enabled states: \(controller.allDevicesItem?.submenu?.items.map { $0.isEnabled } ?? [])"
        )

        sender.finish()
        await expectSendState(of: session) { state in
            if case .success = state {
                return true
            }
            return false
        }
    }

    func testWakeStatusRowShowsSendingState() async {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        let sender = BlockingMenuWakeSender()
        let session = WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        let controller = makeController(deviceLibrary: store, wolSession: session)

        session.sendSavedDevice(id: devices[0].id)

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(controller.wakeStatusItem?.title, WakeSendMessage.sending.text)
        XCTAssertEqual(controller.wakeStatusItem?.isEnabled, false)
        XCTAssertEqual(controller.wakeStatusItem?.isHidden, false)

        sender.finish()
    }

    func testWakeStatusRowPersistsLastSuccessMessage() async {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        let sender = RecordingMenuWakeSender()
        let session = WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        let controller = makeController(deviceLibrary: store, wolSession: session)

        session.sendSavedDevice(id: devices[0].id)

        await expectLastCompletedWake(of: session) { attempt in
            attempt?.deviceID == devices[0].id && attempt?.wasSuccessful == true
        }

        XCTAssertEqual(
            controller.wakeStatusItem?.title,
            WakeSendPresentation.successMessage(for: devices[0].macAddress)
        )
        XCTAssertEqual(controller.wakeStatusItem?.isEnabled, false)
        XCTAssertEqual(controller.wakeStatusItem?.isHidden, false)
    }

    func testWakeStatusRowPersistsLastFailureMessage() async {
        let devices = makeDevices()
        let store = SavedDeviceLibraryStore(repository: InMemoryMenuSavedDeviceRepository(devices: devices))
        let sender = RecordingMenuWakeSender()
        sender.result = .failure(WOLSenderError.sendFailed)
        let session = WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        let controller = makeController(deviceLibrary: store, wolSession: session)

        session.sendSavedDevice(id: devices[0].id)

        await expectLastCompletedWake(of: session) { attempt in
            attempt?.deviceID == devices[0].id && attempt?.wasSuccessful == false
        }

        XCTAssertEqual(controller.wakeStatusItem?.title, WOLSenderError.sendFailed.userMessage)
        XCTAssertEqual(controller.wakeStatusItem?.isEnabled, false)
        XCTAssertEqual(controller.wakeStatusItem?.isHidden, false)
    }

    private func makeController(
        deviceLibrary: SavedDeviceLibraryStore,
        wolSession: WOLSessionModel? = nil
    ) -> StatusBarController {
        let session = wolSession ?? WOLSessionModel(deviceLibrary: deviceLibrary, wakeSender: RecordingMenuWakeSender())
        return StatusBarController(
            deviceLibrary: deviceLibrary,
            wolSession: session,
            keepAwakeSession: KeepAwakeSessionModel(
                powerController: FakeMenuWakePowerController(),
                scheduler: FakeMenuWakeCountdownScheduler(),
                nowProvider: { Date(timeIntervalSinceReferenceDate: 0) }
            )
        )
    }

    private func makeDevices() -> [SavedDevice] {
        [
            SavedDevice(id: UUID(), name: "书房 Mac", macAddress: "AA:BB:CC:DD:EE:01", note: "", sortOrder: 0),
            SavedDevice(id: UUID(), name: "客厅 NAS", macAddress: "AA:BB:CC:DD:EE:02", note: "", sortOrder: 1),
            SavedDevice(id: UUID(), name: "阁楼 Mac", macAddress: "AA:BB:CC:DD:EE:03", note: "", sortOrder: 2),
            SavedDevice(id: UUID(), name: "备用主机", macAddress: "AA:BB:CC:DD:EE:04", note: "", sortOrder: 3),
        ]
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

private final class InMemoryMenuSavedDeviceRepository: SavedDeviceRepository {
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

private final class RecordingMenuWakeSender: WakeSending {
    private(set) var sentMacs: [String] = []
    var result: Result<Void, Error> = .success(())

    func send(to macAddress: String) throws {
        sentMacs.append(macAddress)
        try result.get()
    }
}

private final class BlockingMenuWakeSender: WakeSending {
    private let semaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private(set) var sentMacs: [String] = []

    func send(to macAddress: String) throws {
        lock.lock()
        sentMacs.append(macAddress)
        lock.unlock()
        semaphore.wait()
    }

    func finish() {
        semaphore.signal()
    }
}

private final class FakeMenuWakeCountdownScheduler: KeepAwakeCountdownScheduling {
    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        FakeMenuWakeCountdownToken()
    }
}

private final class FakeMenuWakeCountdownToken: KeepAwakeCountdownToken {
    func cancel() {}
}

@MainActor
private final class FakeMenuWakePowerController: KeepAwakePowerControlling {
    let isEnabled = false

    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    ) {
        completion(.success(enabled))
    }
}
