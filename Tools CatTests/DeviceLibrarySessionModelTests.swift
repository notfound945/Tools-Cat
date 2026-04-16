import XCTest
@testable import Tools_Cat

@MainActor
final class DeviceLibrarySessionModelTests: XCTestCase {
    func testInvalidDraftBlocksSave() {
        let session = makeSession()

        session.beginAdd()
        session.draftName = "   "
        session.draftMACAddress = "AA:BB:CC:DD:EE:FF"
        session.saveDraft()

        XCTAssertEqual(session.devices, [])
        XCTAssertEqual(session.currentFormMode, .add)
        XCTAssertEqual(session.validationMessage, "请填写设备名称")

        session.draftName = "书房主机"
        session.draftMACAddress = "AA:BB:CC"
        session.saveDraft()

        XCTAssertEqual(session.devices, [])
        XCTAssertEqual(session.currentFormMode, .add)
        XCTAssertEqual(session.validationMessage, ManualMACValidation.wrongGroupCount.userMessage)
    }

    func testAddNormalizesMACAndPersistsOptionalNote() {
        let repository = InMemorySavedDeviceRepository()
        let session = makeSession(repository: repository)

        session.beginAdd()
        session.draftName = " 家用 NAS "
        session.draftMACAddress = "aa:bb:cc:dd:ee:ff"
        session.draftNote = "备份机"
        session.saveDraft()

        XCTAssertNil(session.currentFormMode)
        XCTAssertEqual(session.devices.count, 1)
        XCTAssertEqual(session.devices[0].name, "家用 NAS")
        XCTAssertEqual(session.devices[0].macAddress, "AA:BB:CC:DD:EE:FF")
        XCTAssertEqual(session.devices[0].note, "备份机")
        XCTAssertEqual(session.devices[0].sortOrder, 0)

        let reloadedSession = makeSession(repository: repository)
        XCTAssertEqual(reloadedSession.devices, session.devices)
    }

    func testEditPreservesIdentityAndPersistsChanges() {
        let device = SavedDevice(
            id: UUID(),
            name: "旧名称",
            macAddress: "AA:BB:CC:DD:EE:FF",
            note: "旧备注",
            sortOrder: 0
        )
        let session = makeSession(seedDevices: [device])

        session.beginEdit(deviceID: device.id)

        XCTAssertEqual(session.currentFormMode, .edit(deviceID: device.id))
        XCTAssertEqual(session.draftName, "旧名称")
        XCTAssertEqual(session.draftMACAddress, "AA:BB:CC:DD:EE:FF")
        XCTAssertEqual(session.draftNote, "旧备注")

        session.draftName = "新名称"
        session.draftMACAddress = "11:22:33:44:55:66"
        session.draftNote = ""
        session.saveDraft()

        XCTAssertEqual(session.devices.count, 1)
        XCTAssertEqual(session.devices[0].id, device.id)
        XCTAssertEqual(session.devices[0].name, "新名称")
        XCTAssertEqual(session.devices[0].macAddress, "11:22:33:44:55:66")
        XCTAssertEqual(session.devices[0].note, "")
    }

    func testBeginAddAndEditExitReorderMode() {
        let device = SavedDevice(
            id: UUID(),
            name: "书房主机",
            macAddress: "AA:BB:CC:DD:EE:FF",
            note: "",
            sortOrder: 0
        )
        let session = makeSession(seedDevices: [device])

        session.isReordering = true
        session.beginAdd()

        XCTAssertFalse(session.isReordering)
        XCTAssertEqual(session.currentFormMode, .add)

        session.cancelForm()
        session.isReordering = true
        session.beginEdit(deviceID: device.id)

        XCTAssertFalse(session.isReordering)
        XCTAssertEqual(session.currentFormMode, .edit(deviceID: device.id))
    }

    func testDeleteRequiresConfirmation() {
        let device = SavedDevice(
            id: UUID(),
            name: "待删设备",
            macAddress: "AA:BB:CC:DD:EE:FF",
            note: "",
            sortOrder: 0
        )
        let session = makeSession(seedDevices: [device])

        session.confirmDelete()
        XCTAssertEqual(session.devices.map(\.id), [device.id])

        session.requestDelete(deviceID: device.id)
        XCTAssertEqual(session.pendingDeleteDevice?.id, device.id)

        session.confirmDelete()
        XCTAssertEqual(session.devices, [])
        XCTAssertNil(session.pendingDeleteDevice)
    }

    func testReorderPersistsCanonicalOrder() {
        let first = SavedDevice(id: UUID(), name: "一号机", macAddress: "AA:AA:AA:AA:AA:AA", note: "", sortOrder: 0)
        let second = SavedDevice(id: UUID(), name: "二号机", macAddress: "BB:BB:BB:BB:BB:BB", note: "", sortOrder: 1)
        let third = SavedDevice(id: UUID(), name: "三号机", macAddress: "CC:CC:CC:CC:CC:CC", note: "", sortOrder: 2)
        let repository = InMemorySavedDeviceRepository(seedDevices: [first, second, third])
        let session = makeSession(repository: repository)

        session.moveDevices(fromOffsets: IndexSet(integer: 0), toOffset: 3)

        XCTAssertEqual(session.devices.map(\.id), [second.id, third.id, first.id])
        XCTAssertEqual(session.devices.map(\.sortOrder), [0, 1, 2])

        let reloadedSession = makeSession(repository: repository)
        XCTAssertEqual(reloadedSession.devices.map(\.id), [second.id, third.id, first.id])
        XCTAssertEqual(reloadedSession.devices.map(\.sortOrder), [0, 1, 2])
    }

    private func makeSession(
        repository: InMemorySavedDeviceRepository? = nil,
        seedDevices: [SavedDevice] = []
    ) -> DeviceLibrarySessionModel {
        let repository = repository ?? InMemorySavedDeviceRepository()

        if !seedDevices.isEmpty {
            repository.seed(seedDevices)
        }

        let store = SavedDeviceLibraryStore(repository: repository)
        return DeviceLibrarySessionModel(libraryStore: store)
    }
}

private final class InMemorySavedDeviceRepository: SavedDeviceRepository {
    private var storedDevices: [SavedDevice]
    private var wakeMetadata = SavedDeviceWakeMetadata(recentDeviceIDs: [], lastUsedDeviceID: nil)

    init(seedDevices: [SavedDevice] = []) {
        storedDevices = seedDevices.enumerated().map { index, device in
            var normalizedDevice = device
            normalizedDevice.sortOrder = index
            return normalizedDevice
        }
    }

    func seed(_ devices: [SavedDevice]) {
        storedDevices = devices.enumerated().map { index, device in
            var normalizedDevice = device
            normalizedDevice.sortOrder = index
            return normalizedDevice
        }
    }

    func loadDevices() throws -> [SavedDevice] {
        storedDevices
    }

    func saveDevices(_ devices: [SavedDevice]) throws {
        storedDevices = devices.enumerated().map { index, device in
            var normalizedDevice = device
            normalizedDevice.sortOrder = index
            return normalizedDevice
        }
    }

    func loadWakeMetadata() throws -> SavedDeviceWakeMetadata {
        wakeMetadata
    }

    func saveWakeMetadata(_ metadata: SavedDeviceWakeMetadata) throws {
        wakeMetadata = metadata
    }
}
