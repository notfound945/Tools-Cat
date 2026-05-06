import XCTest
import Combine
@testable import Tools_Cat

final class WOLSessionModelTests: XCTestCase {
    func testModelStoresPublishedContracts() async {
        await MainActor.run {
            let model = WOLSessionModel(deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()))

            XCTAssertEqual(model.inputMode, .preset)
            XCTAssertNil(model.selectedSavedDeviceID)
            XCTAssertEqual(model.customMac, "")
            XCTAssertEqual(model.validation, .empty)
            XCTAssertEqual(model.sendState, .idle)
            XCTAssertFalse(model.isWindowVisible)
        }
    }

    func testInvalidCustomInputBlocksSend() async {
        let sender = RecordingWakeSender()
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()),
                wakeSender: sender
            )
        }

        await MainActor.run {
            model.inputMode = .custom
            model.updateCustomMac("AA:BB:CC")

            XCTAssertFalse(model.canSend)

            model.sendCurrentSelection()

            XCTAssertEqual(model.sendState, .idle)
        }

        XCTAssertEqual(sender.sentMacs, [])
    }

    func testValidCustomInputEnablesSend() async {
        let started = expectation(description: "send started")
        let sender = BlockingWakeSender(started: started)
        let target = "AA:BB:CC:DD:EE:FF"
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()),
                wakeSender: sender
            )
        }

        await MainActor.run {
            model.inputMode = .custom
            model.updateCustomMac("aa:bb:cc:dd:ee:ff")

            XCTAssertTrue(model.canSend)

            model.sendCurrentSelection()

            XCTAssertEqual(model.sendState, .sending(macAddress: target))
        }

        await fulfillment(of: [started], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: target))
        }

        XCTAssertEqual(sender.sentMacs, [target])
    }

    func testNewSendClearsPreviousResult() async {
        let started = expectation(description: "replacement send started")
        let sender = BlockingWakeSender(started: started)
        let target = "AA:BB:CC:DD:EE:FF"
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()),
                inputMode: .custom,
                customMac: target,
                validation: .valid(target),
                sendState: .success(message: "旧结果"),
                wakeSender: sender
            )
        }

        await MainActor.run {
            model.sendCurrentSelection()

            XCTAssertEqual(model.sendState, .sending(macAddress: target))
        }

        await fulfillment(of: [started], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: target))
        }
    }

    func testHiddenWindowReceivesFinalResult() async {
        let started = expectation(description: "hidden send started")
        let sender = BlockingWakeSender(started: started)
        let target = "AA:BB:CC:DD:EE:FF"
        let clearScheduler = FakeWakeResultClearing()
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()),
                inputMode: .custom,
                customMac: target,
                validation: .valid(target),
                wakeSender: sender,
                wakeResultClearing: clearScheduler
            )
        }

        await MainActor.run {
            model.handleWindowWillShow()
            model.sendCurrentSelection()
            model.handleWindowWillClose()

            XCTAssertFalse(model.isWindowVisible)
            XCTAssertEqual(model.sendState, .sending(macAddress: target))
        }

        await fulfillment(of: [started], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: target))
        }

        XCTAssertEqual(clearScheduler.scheduledDelays, [3])

        await MainActor.run {
            model.handleWindowWillShow()

            XCTAssertTrue(model.isWindowVisible)
            XCTAssertEqual(
                model.sendState,
                .success(message: WakeSendPresentation.successMessage(for: target))
            )
            XCTAssertEqual(clearScheduler.scheduledDelays, [3])

            clearScheduler.fireLatest()

            XCTAssertEqual(model.sendState, .idle)
            XCTAssertNil(model.lastCompletedWake)
        }
    }

    func testReopenPreservesDraftAndClearsStaleResult() async {
        let failure = WOLSenderError.sendFailed.userMessage
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()),
                inputMode: .custom,
                customMac: "AA:BB:CC",
                sendState: .failure(message: failure)
            )
        }

        await MainActor.run {
            model.handleWindowWillShow()
            model.handleWindowWillClose()
            model.handleWindowWillShow()

            XCTAssertEqual(model.inputMode, .custom)
            XCTAssertNil(model.selectedSavedDeviceID)
            XCTAssertEqual(model.customMac, "AA:BB:CC")
            XCTAssertEqual(model.validation, .wrongGroupCount)
            XCTAssertEqual(model.sendState, .idle)
        }
    }

    func testWindowReopenPreselectsLastUsedSavedDevice() async {
        let first = SavedDevice(
            id: UUID(),
            name: "书房",
            macAddress: "AA:BB:CC:DD:EE:01",
            note: "",
            sortOrder: 0
        )
        let second = SavedDevice(
            id: UUID(),
            name: "客厅",
            macAddress: "AA:BB:CC:DD:EE:02",
            note: "",
            sortOrder: 1
        )
        let store = await MainActor.run {
            SavedDeviceLibraryStore(
                repository: InMemorySavedDeviceRepository(
                    devices: [first, second],
                    wakeMetadata: SavedDeviceWakeMetadata(
                        recentDeviceIDs: [second.id, first.id],
                        lastUsedDeviceID: second.id
                    )
                )
            )
        }
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                inputMode: .preset,
                selectedSavedDeviceID: first.id
            )
        }

        await MainActor.run {
            model.handleWindowWillShow()

            XCTAssertEqual(model.inputMode, .preset)
            XCTAssertEqual(model.selectedSavedDeviceID, second.id)
        }
    }

    func testWindowReopenPreservesManualDraftInsteadOfForcingPresetMode() async {
        let first = SavedDevice(
            id: UUID(),
            name: "书房",
            macAddress: "AA:BB:CC:DD:EE:01",
            note: "",
            sortOrder: 0
        )
        let second = SavedDevice(
            id: UUID(),
            name: "客厅",
            macAddress: "AA:BB:CC:DD:EE:02",
            note: "",
            sortOrder: 1
        )
        let store = await MainActor.run {
            SavedDeviceLibraryStore(
                repository: InMemorySavedDeviceRepository(
                    devices: [first, second],
                    wakeMetadata: SavedDeviceWakeMetadata(
                        recentDeviceIDs: [first.id],
                        lastUsedDeviceID: first.id
                    )
                )
            )
        }
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                inputMode: .custom,
                selectedSavedDeviceID: second.id,
                customMac: "AA:BB:CC",
                validation: .wrongGroupCount
            )
        }

        await MainActor.run {
            model.handleWindowWillShow()

            XCTAssertEqual(model.inputMode, .custom)
            XCTAssertEqual(model.selectedSavedDeviceID, second.id)
            XCTAssertEqual(model.customMac, "AA:BB:CC")
        }
    }

    func testWindowReopenFallsBackWhenLastUsedDeviceWasDeleted() async {
        let first = SavedDevice(
            id: UUID(),
            name: "书房",
            macAddress: "AA:BB:CC:DD:EE:01",
            note: "",
            sortOrder: 0
        )
        let second = SavedDevice(
            id: UUID(),
            name: "客厅",
            macAddress: "AA:BB:CC:DD:EE:02",
            note: "",
            sortOrder: 1
        )
        let missingID = UUID()
        let store = await MainActor.run {
            SavedDeviceLibraryStore(
                repository: InMemorySavedDeviceRepository(
                    devices: [first, second],
                    wakeMetadata: SavedDeviceWakeMetadata(
                        recentDeviceIDs: [missingID, second.id],
                        lastUsedDeviceID: missingID
                    )
                )
            )
        }
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                inputMode: .custom,
                selectedSavedDeviceID: nil
            )
        }

        await MainActor.run {
            model.handleWindowWillShow()

            XCTAssertEqual(model.inputMode, .preset)
            XCTAssertEqual(model.selectedSavedDeviceID, first.id)
        }
    }

    func testPresetModeUsesSelectedSavedDeviceMAC() async {
        let started = expectation(description: "preset send started")
        let sender = BlockingWakeSender(started: started)
        let device = SavedDevice(
            id: UUID(),
            name: "NAS",
            macAddress: "6C:1F:F7:75:C7:0E",
            note: "机柜",
            sortOrder: 0
        )
        let expectedMAC = device.macAddress
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [device]))
        }
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                selectedSavedDeviceID: device.id,
                wakeSender: sender
            )
        }

        await MainActor.run {
            XCTAssertTrue(model.canSend)
            model.sendCurrentSelection()
            XCTAssertEqual(model.sendState, .sending(macAddress: expectedMAC))
        }

        await fulfillment(of: [started], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: expectedMAC))
        }

        XCTAssertEqual(sender.sentMacs, [expectedMAC])
    }

    func testSendSavedDeviceUsesSelectedSavedDeviceMAC() async {
        let started = expectation(description: "saved device send started")
        let sender = BlockingWakeSender(started: started)
        let device = SavedDevice(
            id: UUID(),
            name: "NAS",
            macAddress: "6C:1F:F7:75:C7:0E",
            note: "机柜",
            sortOrder: 0
        )
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [device]))
        }
        let model = await MainActor.run {
            WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        }

        await MainActor.run {
            model.sendSavedDevice(id: device.id)
            model.sendSavedDevice(id: device.id)

            XCTAssertEqual(model.sendState, .sending(macAddress: device.macAddress))
        }

        await fulfillment(of: [started], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: device.macAddress))
        }

        XCTAssertEqual(sender.sentMacs, [device.macAddress])
    }

    func testSavedDeviceSuccessUpdatesLastCompletedWakeAndStoreMetadata() async {
        let device = SavedDevice(
            id: UUID(),
            name: "书房 Mac mini",
            macAddress: "AA:BB:CC:DD:EE:FF",
            note: "",
            sortOrder: 0
        )
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [device]))
        }
        let model = await MainActor.run {
            WOLSessionModel(deviceLibrary: store, wakeSender: RecordingWakeSender())
        }

        await MainActor.run {
            model.sendSavedDevice(id: device.id)
        }

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: device.macAddress))
        }

        await MainActor.run {
            XCTAssertEqual(
                model.lastCompletedWake,
                CompletedWakeAttempt(
                    deviceID: device.id,
                    message: WakeSendPresentation.successMessage(for: device.macAddress),
                    wasSuccessful: true
                )
            )
            XCTAssertEqual(store.recentDeviceIDs, [device.id])
            XCTAssertEqual(store.lastUsedDeviceID, device.id)
        }
    }

    func testCompletedWakeResultClearsAfterThreeSeconds() async {
        let device = SavedDevice(
            id: UUID(),
            name: "NAS",
            macAddress: "6C:1F:F7:75:C7:0E",
            note: "",
            sortOrder: 0
        )
        let clearScheduler = FakeWakeResultClearing()
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [device]))
        }
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                wakeSender: RecordingWakeSender(),
                wakeResultClearing: clearScheduler
            )
        }

        await MainActor.run {
            model.sendSavedDevice(id: device.id)
        }

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: device.macAddress))
        }

        XCTAssertEqual(clearScheduler.scheduledDelays, [3])

        await MainActor.run {
            clearScheduler.fireLatest()
            XCTAssertEqual(model.sendState, .idle)
            XCTAssertNil(model.lastCompletedWake)
        }
    }

    func testNewSendCancelsPreviousWakeResultClear() async {
        let clearScheduler = FakeWakeResultClearing()
        let target = "AA:BB:CC:DD:EE:FF"
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository())
        }
        let firstStarted = expectation(description: "first replacement send started")
        let firstSender = BlockingWakeSender(started: firstStarted)
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                inputMode: .custom,
                customMac: target,
                validation: .valid(target),
                wakeSender: firstSender,
                wakeResultClearing: clearScheduler
            )
        }

        await MainActor.run {
            model.sendState = .success(message: "旧结果")
            model.sendCurrentSelection()
        }

        await fulfillment(of: [firstStarted], timeout: 1.0)
        firstSender.finish(with: .success(()))

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: target))
        }

        let secondStarted = expectation(description: "second replacement send started")
        let secondSender = BlockingWakeSender(started: secondStarted)

        await MainActor.run {
            model.sendState = .success(message: WakeSendPresentation.successMessage(for: target))
            model.setWakeSenderForTesting(secondSender)
            model.sendCurrentSelection()
        }

        await fulfillment(of: [secondStarted], timeout: 1.0)
        XCTAssertEqual(clearScheduler.cancelCount, 1)
        secondSender.finish(with: .success(()))
    }

    func testFailedSendKeepsLastCompletedWakeButDoesNotUpdateRecents() async {
        let first = SavedDevice(
            id: UUID(),
            name: "书房",
            macAddress: "AA:BB:CC:DD:EE:01",
            note: "",
            sortOrder: 0
        )
        let second = SavedDevice(
            id: UUID(),
            name: "客厅",
            macAddress: "AA:BB:CC:DD:EE:02",
            note: "",
            sortOrder: 1
        )
        let sender = SequencedWakeSender(results: [.success(()), .failure(WOLSenderError.sendFailed)])
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [first, second]))
        }
        let model = await MainActor.run {
            WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        }

        await MainActor.run {
            model.sendSavedDevice(id: first.id)
        }

        await expectSendState(of: model) { state in
            state == .success(message: WakeSendPresentation.successMessage(for: first.macAddress))
        }

        await MainActor.run {
            model.sendSavedDevice(id: second.id)
        }

        await expectSendState(of: model) { state in
            state == .failure(message: WOLSenderError.sendFailed.userMessage)
        }

        await MainActor.run {
            XCTAssertEqual(
                model.lastCompletedWake,
                CompletedWakeAttempt(
                    deviceID: second.id,
                    message: WOLSenderError.sendFailed.userMessage,
                    wasSuccessful: false
                )
            )
            XCTAssertEqual(store.recentDeviceIDs, [first.id])
            XCTAssertEqual(store.lastUsedDeviceID, first.id)
        }
    }

    func testStartingNewSendDoesNotClearLastCompletedWakeUntilCompletion() async {
        let firstStarted = expectation(description: "first send started")
        let secondStarted = expectation(description: "second send started")
        let sender = MultiSendBlockingWakeSender()
        sender.onSend = { sendCount in
            if sendCount == 1 {
                firstStarted.fulfill()
            } else if sendCount == 2 {
                secondStarted.fulfill()
            }
        }

        let first = SavedDevice(
            id: UUID(),
            name: "书房",
            macAddress: "AA:BB:CC:DD:EE:01",
            note: "",
            sortOrder: 0
        )
        let second = SavedDevice(
            id: UUID(),
            name: "客厅",
            macAddress: "AA:BB:CC:DD:EE:02",
            note: "",
            sortOrder: 1
        )
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [first, second]))
        }
        let model = await MainActor.run {
            WOLSessionModel(deviceLibrary: store, wakeSender: sender)
        }

        await MainActor.run {
            model.sendSavedDevice(id: first.id)
        }

        await fulfillment(of: [firstStarted], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectLastCompletedWake(of: model) { attempt in
            attempt?.deviceID == first.id && attempt?.wasSuccessful == true
        }

        let previousWake = await MainActor.run { model.lastCompletedWake }

        await MainActor.run {
            model.sendSavedDevice(id: second.id)
            XCTAssertEqual(model.sendState, .sending(macAddress: second.macAddress))
            XCTAssertEqual(model.lastCompletedWake, previousWake)
        }

        await fulfillment(of: [secondStarted], timeout: 1.0)
        sender.finish(with: .success(()))

        await expectLastCompletedWake(of: model) { attempt in
            attempt?.deviceID == second.id && attempt?.wasSuccessful == true
        }
    }

    func testPresetSendDisablesWhenSelectedSavedDeviceDisappears() async {
        let sender = RecordingWakeSender()
        let device = SavedDevice(
            id: UUID(),
            name: "Mini",
            macAddress: "AA:BB:CC:DD:EE:FF",
            note: "",
            sortOrder: 0
        )
        let store = await MainActor.run {
            SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository(devices: [device]))
        }
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: store,
                selectedSavedDeviceID: device.id,
                wakeSender: sender
            )
        }

        await MainActor.run {
            XCTAssertTrue(model.canSend)
        }

        await MainActor.run {
            try? store.deleteDevice(id: device.id)
            XCTAssertFalse(model.canSend)
            model.sendCurrentSelection()
            XCTAssertEqual(model.sendState, .idle)
        }

        XCTAssertEqual(sender.sentMacs, [])
    }

    func testSendCompletionPublishesOnMainThread() async {
        let started = expectation(description: "send started")
        let publishedOnMain = expectation(description: "completion published on main thread")
        let sender = BlockingWakeSender(started: started)
        let target = "AA:BB:CC:DD:EE:FF"
        let model = await MainActor.run {
            WOLSessionModel(
                deviceLibrary: SavedDeviceLibraryStore(repository: InMemorySavedDeviceRepository()),
                inputMode: .custom,
                customMac: target,
                validation: .valid(target),
                wakeSender: sender
            )
        }

        var cancellable: AnyCancellable?
        await MainActor.run {
            cancellable = model.$sendState.sink { state in
                guard case .success = state else { return }

                XCTAssertTrue(Thread.isMainThread)
                publishedOnMain.fulfill()
            }
        }

        await MainActor.run {
            model.sendCurrentSelection()
        }

        await fulfillment(of: [started], timeout: 1.0)
        sender.finish(with: .success(()))
        await fulfillment(of: [publishedOnMain], timeout: 1.0)
        withExtendedLifetime(cancellable) {}
    }

    private func expectSendState(
        of model: WOLSessionModel,
        matching predicate: @escaping (WakeSendState) -> Bool,
        timeout: TimeInterval = 1.0
    ) async {
        let expectation = expectation(description: "send state matched")
        var cancellable: AnyCancellable?

        await MainActor.run {
            if predicate(model.sendState) {
                expectation.fulfill()
                return
            }

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

        await MainActor.run {
            if predicate(model.lastCompletedWake) {
                expectation.fulfill()
                return
            }

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

private final class FakeWakeResultClearing: WakeResultClearing {
    private(set) var scheduledDelays: [TimeInterval] = []
    private(set) var cancelCount = 0
    private var latestAction: (@MainActor () -> Void)?

    func schedule(after delay: TimeInterval, _ action: @escaping @MainActor () -> Void) -> WakeResultClearToken {
        scheduledDelays.append(delay)
        latestAction = action
        return FakeWakeResultClearToken { [weak self] in
            self?.cancelCount += 1
        }
    }

    @MainActor
    func fireLatest() {
        latestAction?()
        latestAction = nil
    }
}

private final class FakeWakeResultClearToken: WakeResultClearToken {
    private let onCancel: () -> Void

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    func cancel() {
        onCancel()
    }
}

private final class InMemorySavedDeviceRepository: SavedDeviceRepository {
    private var devices: [SavedDevice]
    private var wakeMetadata: SavedDeviceWakeMetadata

    init(
        devices: [SavedDevice] = [],
        wakeMetadata: SavedDeviceWakeMetadata = SavedDeviceWakeMetadata(
            recentDeviceIDs: [],
            lastUsedDeviceID: nil
        )
    ) {
        self.devices = devices
        self.wakeMetadata = wakeMetadata
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

private final class RecordingWakeSender: WakeSending {
    private(set) var sentMacs: [String] = []
    var result: Result<Void, Error> = .success(())

    func send(to macAddress: String) throws {
        sentMacs.append(macAddress)
        try result.get()
    }
}

private final class SequencedWakeSender: WakeSending {
    private(set) var sentMacs: [String] = []
    private var results: [Result<Void, Error>]

    init(results: [Result<Void, Error>]) {
        self.results = results
    }

    func send(to macAddress: String) throws {
        sentMacs.append(macAddress)
        let result = results.isEmpty ? .success(()) : results.removeFirst()
        try result.get()
    }
}

private final class BlockingWakeSender: WakeSending {
    private(set) var sentMacs: [String] = []

    private let started: XCTestExpectation
    private let semaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var result: Result<Void, Error> = .success(())

    init(started: XCTestExpectation) {
        self.started = started
    }

    func send(to macAddress: String) throws {
        lock.lock()
        sentMacs.append(macAddress)
        lock.unlock()

        started.fulfill()
        semaphore.wait()

        lock.lock()
        let result = self.result
        lock.unlock()

        try result.get()
    }

    func finish(with result: Result<Void, Error>) {
        lock.lock()
        self.result = result
        lock.unlock()
        semaphore.signal()
    }
}

private final class MultiSendBlockingWakeSender: WakeSending {
    private(set) var sentMacs: [String] = []
    var onSend: ((Int) -> Void)?

    private let semaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var sendCount = 0
    private var result: Result<Void, Error> = .success(())

    func send(to macAddress: String) throws {
        lock.lock()
        sentMacs.append(macAddress)
        sendCount += 1
        let sendCount = sendCount
        lock.unlock()

        onSend?(sendCount)
        semaphore.wait()

        lock.lock()
        let result = self.result
        lock.unlock()

        try result.get()
    }

    func finish(with result: Result<Void, Error>) {
        lock.lock()
        self.result = result
        lock.unlock()
        semaphore.signal()
    }
}
