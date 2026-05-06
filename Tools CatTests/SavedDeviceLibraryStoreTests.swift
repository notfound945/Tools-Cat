import XCTest
@testable import Tools_Cat

@MainActor
final class SavedDeviceLibraryStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var repository: UserDefaultsSavedDeviceRepository!

    override func setUp() {
        super.setUp()

        suiteName = "SavedDeviceLibraryStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        repository = UserDefaultsSavedDeviceRepository(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        repository = nil
        defaults = nil
        suiteName = nil

        super.tearDown()
    }

    func testMarkWakeSucceededMovesDeviceToFrontAndTrimsRecents() throws {
        let first = makeDevice(name: "一号机", macAddress: "AA:AA:AA:AA:AA:AA", sortOrder: 0)
        let second = makeDevice(name: "二号机", macAddress: "BB:BB:BB:BB:BB:BB", sortOrder: 1)
        let third = makeDevice(name: "三号机", macAddress: "CC:CC:CC:CC:CC:CC", sortOrder: 2)
        let fourth = makeDevice(name: "四号机", macAddress: "DD:DD:DD:DD:DD:DD", sortOrder: 3)
        let store = makeStore(devices: [first, second, third, fourth])

        try store.markWakeSucceeded(deviceID: second.id)
        try store.markWakeSucceeded(deviceID: fourth.id)
        try store.markWakeSucceeded(deviceID: first.id)
        try store.markWakeSucceeded(deviceID: second.id)

        XCTAssertEqual(store.recentDeviceIDs, [second.id, first.id, fourth.id])
        XCTAssertEqual(store.recentDevices().map(\.id), [second.id, first.id, fourth.id])
        XCTAssertEqual(makeStore().recentDeviceIDs, [second.id, first.id, fourth.id])
    }

    func testFreshStoreSeedsDefaultDeviceExactlyOnce() throws {
        let store = makeStore()

        XCTAssertEqual(store.devices.count, 1)
        XCTAssertEqual(store.devices[0].name, "UGREEN NAS")
        XCTAssertEqual(store.devices[0].macAddress, "6C:1F:F7:75:C7:0E")
        XCTAssertEqual(store.devices[0].note, "")
        XCTAssertEqual(store.devices[0].sortOrder, 0)

        let reloadedStore = makeStore()
        XCTAssertEqual(reloadedStore.devices, store.devices)
    }

    func testMarkWakeSucceededSetsLastUsedDeviceID() throws {
        let first = makeDevice(name: "书房 Mac mini", macAddress: "AA:BB:CC:DD:EE:01", sortOrder: 0)
        let second = makeDevice(name: "客厅 NAS", macAddress: "AA:BB:CC:DD:EE:02", sortOrder: 1)
        let store = makeStore(devices: [first, second])

        XCTAssertNil(store.lastUsedDeviceID)

        try store.markWakeSucceeded(deviceID: first.id)
        XCTAssertEqual(store.lastUsedDeviceID, first.id)

        try store.markWakeSucceeded(deviceID: second.id)
        XCTAssertEqual(store.lastUsedDeviceID, second.id)
        XCTAssertEqual(makeStore().lastUsedDeviceID, second.id)
    }

    func testDeletingDevicePrunesRecentAndLastUsedMetadata() throws {
        let first = makeDevice(name: "书房", macAddress: "AA:BB:CC:DD:EE:01", sortOrder: 0)
        let second = makeDevice(name: "客厅", macAddress: "AA:BB:CC:DD:EE:02", sortOrder: 1)
        let third = makeDevice(name: "阁楼", macAddress: "AA:BB:CC:DD:EE:03", sortOrder: 2)
        let replacement = makeDevice(name: "备用", macAddress: "AA:BB:CC:DD:EE:09", sortOrder: 0)
        let store = makeStore(devices: [first, second, third])

        try store.markWakeSucceeded(deviceID: third.id)
        try store.markWakeSucceeded(deviceID: second.id)
        try store.markWakeSucceeded(deviceID: first.id)

        try store.deleteDevice(id: second.id)

        XCTAssertEqual(store.recentDeviceIDs, [first.id, third.id])
        XCTAssertEqual(store.lastUsedDeviceID, first.id)

        try store.replaceAll([replacement, third])

        XCTAssertEqual(store.recentDeviceIDs, [third.id])
        XCTAssertNil(store.lastUsedDeviceID)
        XCTAssertEqual(makeStore().recentDeviceIDs, [third.id])
        XCTAssertNil(makeStore().lastUsedDeviceID)
    }

    private func makeStore(devices: [SavedDevice] = []) -> SavedDeviceLibraryStore {
        if !devices.isEmpty {
            try? repository.saveDevices(devices)
        }

        return SavedDeviceLibraryStore(repository: repository)
    }

    private func makeDevice(name: String, macAddress: String, sortOrder: Int) -> SavedDevice {
        SavedDevice(
            id: UUID(),
            name: name,
            macAddress: macAddress,
            note: "",
            sortOrder: sortOrder
        )
    }
}
