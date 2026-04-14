import XCTest
@testable import Tools_Cat

final class SavedDeviceRepositoryTests: XCTestCase {
    private let devicesKey = "saved_devices"
    private let wakeMetadataKey = "saved_device_wake_metadata"

    private var suiteName: String!
    private var defaults: UserDefaults!
    private var legacyDefaults: UserDefaults!
    private var repository: UserDefaultsSavedDeviceRepository!
    private var legacyRepository: UserDefaultsSavedDeviceRepository!

    override func setUp() {
        super.setUp()

        suiteName = "SavedDeviceRepositoryTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        legacyDefaults = UserDefaults(suiteName: "\(suiteName!).legacy")!
        defaults.removePersistentDomain(forName: suiteName)
        legacyDefaults.removePersistentDomain(forName: "\(suiteName!).legacy")
        repository = UserDefaultsSavedDeviceRepository(defaults: defaults)
        legacyRepository = UserDefaultsSavedDeviceRepository(defaults: legacyDefaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        legacyDefaults.removePersistentDomain(forName: "\(suiteName!).legacy")
        legacyRepository = nil
        repository = nil
        legacyDefaults = nil
        defaults = nil
        suiteName = nil

        super.tearDown()
    }

    func testEmptySuiteLoadsNoDevices() throws {
        XCTAssertEqual(try repository.loadDevices(), [])
    }

    func testSaveAndReloadPreservesNameMACNoteAndOrder() throws {
        let devices = [
            SavedDevice(
                id: UUID(),
                name: "书房 Mac mini",
                macAddress: "AA:BB:CC:DD:EE:FF",
                note: "主机",
                sortOrder: 8
            ),
            SavedDevice(
                id: UUID(),
                name: "客厅 NAS",
                macAddress: "11:22:33:44:55:66",
                note: "",
                sortOrder: 3
            )
        ]

        try repository.saveDevices(devices)

        XCTAssertEqual(try repository.loadDevices(), [
            SavedDevice(
                id: devices[0].id,
                name: "书房 Mac mini",
                macAddress: "AA:BB:CC:DD:EE:FF",
                note: "主机",
                sortOrder: 0
            ),
            SavedDevice(
                id: devices[1].id,
                name: "客厅 NAS",
                macAddress: "11:22:33:44:55:66",
                note: "",
                sortOrder: 1
            )
        ])
    }

    func testReorderedSaveReloadsInUserDefinedOrder() throws {
        let first = SavedDevice(
            id: UUID(),
            name: "一号机",
            macAddress: "AA:AA:AA:AA:AA:AA",
            note: "",
            sortOrder: 0
        )
        let second = SavedDevice(
            id: UUID(),
            name: "二号机",
            macAddress: "BB:BB:BB:BB:BB:BB",
            note: "常用",
            sortOrder: 1
        )
        let third = SavedDevice(
            id: UUID(),
            name: "三号机",
            macAddress: "CC:CC:CC:CC:CC:CC",
            note: "",
            sortOrder: 2
        )

        try repository.saveDevices([first, second, third])
        try repository.saveDevices([third, first, second])

        XCTAssertEqual(try repository.loadDevices().map(\.id), [third.id, first.id, second.id])
        XCTAssertEqual(try repository.loadDevices().map(\.sortOrder), [0, 1, 2])
    }

    func testDeletePersistsAcrossReload() throws {
        let retained = SavedDevice(
            id: UUID(),
            name: "保留设备",
            macAddress: "10:20:30:40:50:60",
            note: "",
            sortOrder: 0
        )
        let removed = SavedDevice(
            id: UUID(),
            name: "待删除设备",
            macAddress: "AA:10:20:30:40:50",
            note: "旧设备",
            sortOrder: 1
        )

        try repository.saveDevices([retained, removed])
        try repository.saveDevices([retained])

        XCTAssertEqual(try repository.loadDevices(), [
            SavedDevice(
                id: retained.id,
                name: "保留设备",
                macAddress: "10:20:30:40:50:60",
                note: "",
                sortOrder: 0
            )
        ])
    }

    func testMigratesSavedDeviceLibraryFromLegacyBundleIdentifierOnce() throws {
        let legacyDevices = [
            SavedDevice(id: UUID(), name: "旧 NAS", macAddress: "AA:BB:CC:DD:EE:10", note: "legacy", sortOrder: 4),
            SavedDevice(id: UUID(), name: "旧 Mac mini", macAddress: "AA:BB:CC:DD:EE:11", note: "", sortOrder: 1),
        ]
        let legacyWakeMetadata = SavedDeviceWakeMetadata(
            recentDeviceIDs: [legacyDevices[1].id, legacyDevices[0].id],
            lastUsedDeviceID: legacyDevices[1].id
        )

        let encoder = JSONEncoder()
        legacyDefaults.set(try encoder.encode(legacyDevices), forKey: devicesKey)
        try legacyRepository.saveWakeMetadata(legacyWakeMetadata)

        UserDefaultsSavedDeviceRepository.migrateLegacySavedDeviceDefaultsIfNeeded(
            into: defaults,
            legacyDefaults: legacyDefaults
        )

        let migratedDeviceIDs = try repository.loadDevices().map(\.id)
        XCTAssertTrue(
            migratedDeviceIDs.elementsEqual([legacyDevices[1].id, legacyDevices[0].id]),
            "Expected migrated devices to preserve the legacy normalized order."
        )
        let migratedWakeMetadata = try repository.loadWakeMetadata()
        XCTAssertTrue(
            migratedWakeMetadata.recentDeviceIDs.elementsEqual(legacyWakeMetadata.recentDeviceIDs),
            "Expected migrated recent-device IDs to match the legacy metadata."
        )
        XCTAssertTrue(
            migratedWakeMetadata.lastUsedDeviceID == legacyWakeMetadata.lastUsedDeviceID,
            "Expected migrated last-used device to match the legacy metadata."
        )
        XCTAssertTrue(
            defaults.bool(forKey: "did_migrate_legacy_saved_device_defaults"),
            "Expected migration marker to be written after migration."
        )

        try legacyRepository.saveDevices([
            SavedDevice(id: UUID(), name: "later change", macAddress: "FF:EE:DD:CC:BB:AA", note: "", sortOrder: 0),
        ])

        UserDefaultsSavedDeviceRepository.migrateLegacySavedDeviceDefaultsIfNeeded(
            into: defaults,
            legacyDefaults: legacyDefaults
        )

        XCTAssertTrue(
            try repository.loadDevices().map(\.id).elementsEqual([legacyDevices[1].id, legacyDevices[0].id]),
            "Expected repeated migration to keep the first migrated device order."
        )
    }

    func testDoesNotOverwriteExistingToolsCatLibraryDuringMigration() throws {
        let currentDevice = SavedDevice(
            id: UUID(),
            name: "现有 Tools Cat 设备",
            macAddress: "10:10:10:10:10:10",
            note: "current",
            sortOrder: 0
        )
        let legacyDevice = SavedDevice(
            id: UUID(),
            name: "旧 Swiss Knife 设备",
            macAddress: "20:20:20:20:20:20",
            note: "legacy",
            sortOrder: 0
        )
        let currentWakeMetadata = SavedDeviceWakeMetadata(
            recentDeviceIDs: [currentDevice.id],
            lastUsedDeviceID: currentDevice.id
        )
        let legacyWakeMetadata = SavedDeviceWakeMetadata(
            recentDeviceIDs: [legacyDevice.id],
            lastUsedDeviceID: legacyDevice.id
        )

        try repository.saveDevices([currentDevice])
        try repository.saveWakeMetadata(currentWakeMetadata)

        try legacyRepository.saveDevices([legacyDevice])
        try legacyRepository.saveWakeMetadata(legacyWakeMetadata)

        UserDefaultsSavedDeviceRepository.migrateLegacySavedDeviceDefaultsIfNeeded(
            into: defaults,
            legacyDefaults: legacyDefaults
        )

        let currentDevices = try repository.loadDevices()
        XCTAssertTrue(currentDevices.count == 1, "Expected the existing Tools Cat library to keep exactly one device.")
        XCTAssertTrue(currentDevices[0].id == currentDevice.id, "Expected migration not to overwrite the current Tools Cat device.")
        let migratedWakeMetadata = try repository.loadWakeMetadata()
        XCTAssertTrue(
            migratedWakeMetadata.recentDeviceIDs.elementsEqual(currentWakeMetadata.recentDeviceIDs),
            "Expected migration to preserve existing Tools Cat recent-device metadata."
        )
        XCTAssertTrue(
            migratedWakeMetadata.lastUsedDeviceID == currentWakeMetadata.lastUsedDeviceID,
            "Expected migration to preserve the existing Tools Cat last-used device."
        )
        XCTAssertTrue(
            defaults.bool(forKey: "did_migrate_legacy_saved_device_defaults"),
            "Expected migration marker to be written after the non-overwriting migration path."
        )
    }
}
