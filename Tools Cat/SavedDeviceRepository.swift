import Foundation

struct SavedDeviceWakeMetadata: Codable, Equatable {
    var recentDeviceIDs: [UUID]
    var lastUsedDeviceID: UUID?
}

protocol SavedDeviceRepository: AnyObject {
    func loadDevices() throws -> [SavedDevice]
    func saveDevices(_ devices: [SavedDevice]) throws
    func loadWakeMetadata() throws -> SavedDeviceWakeMetadata
    func saveWakeMetadata(_ metadata: SavedDeviceWakeMetadata) throws
}

final class UserDefaultsSavedDeviceRepository: SavedDeviceRepository {
    static let toolsCatSuiteName = "cn.notfound945.Tools-Cat"
    static let legacySuiteName = "cn.notfound945.Mac-OS-Swiss-Knife"

    private static let devicesKey = "saved_devices"
    private static let wakeMetadataStorageKey = "saved_device_wake_metadata"
    private static let legacyMigrationKey = "did_migrate_legacy_saved_device_defaults"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDevices() throws -> [SavedDevice] {
        guard let data = defaults.data(forKey: Self.devicesKey) else {
            return []
        }

        let devices = try decoder.decode([SavedDevice].self, from: data)
        return Self.normalized(devices.sorted { $0.sortOrder < $1.sortOrder })
    }

    func saveDevices(_ devices: [SavedDevice]) throws {
        let normalizedDevices = Self.normalized(devices)
        let data = try encoder.encode(normalizedDevices)
        defaults.set(data, forKey: Self.devicesKey)
    }

    func loadWakeMetadata() throws -> SavedDeviceWakeMetadata {
        guard let data = defaults.data(forKey: Self.wakeMetadataStorageKey) else {
            return SavedDeviceWakeMetadata(recentDeviceIDs: [], lastUsedDeviceID: nil)
        }

        return try decoder.decode(SavedDeviceWakeMetadata.self, from: data)
    }

    func saveWakeMetadata(_ metadata: SavedDeviceWakeMetadata) throws {
        let data = try encoder.encode(metadata)
        defaults.set(data, forKey: Self.wakeMetadataStorageKey)
    }

    static func migrateLegacySavedDeviceDefaultsIfNeeded(
        into defaults: UserDefaults,
        legacyDefaults: UserDefaults
    ) {
        guard defaults.object(forKey: legacyMigrationKey) as? Bool != true else {
            return
        }

        let hasLegacyDevices = legacyDefaults.object(forKey: devicesKey) != nil
        let hasLegacyWakeMetadata = legacyDefaults.object(forKey: wakeMetadataStorageKey) != nil
        let hasCurrentDevices = defaults.object(forKey: devicesKey) != nil
        let hasCurrentWakeMetadata = defaults.object(forKey: wakeMetadataStorageKey) != nil

        if !hasCurrentDevices, let legacyDevices = legacyDefaults.data(forKey: devicesKey) {
            defaults.set(Data(legacyDevices), forKey: devicesKey)
        }

        if !hasCurrentWakeMetadata, let legacyWakeMetadata = legacyDefaults.data(forKey: wakeMetadataStorageKey) {
            defaults.set(Data(legacyWakeMetadata), forKey: wakeMetadataStorageKey)
        }

        if hasLegacyDevices || hasLegacyWakeMetadata || hasCurrentDevices || hasCurrentWakeMetadata {
            defaults.set(true, forKey: legacyMigrationKey)
        }
    }

    private static func normalized(_ devices: [SavedDevice]) -> [SavedDevice] {
        devices.enumerated().map { index, device in
            var normalizedDevice = device
            normalizedDevice.sortOrder = index
            return normalizedDevice
        }
    }
}
