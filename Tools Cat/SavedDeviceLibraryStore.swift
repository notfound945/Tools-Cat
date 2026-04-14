import Combine
import Foundation

@MainActor
final class SavedDeviceLibraryStore: ObservableObject {
    @Published private(set) var devices: [SavedDevice] = []
    @Published private(set) var recentDeviceIDs: [UUID] = []
    @Published private(set) var lastUsedDeviceID: UUID?

    private let repository: SavedDeviceRepository

    init(repository: SavedDeviceRepository? = nil) {
        let resolvedRepository = repository ?? UserDefaultsSavedDeviceRepository()
        self.repository = resolvedRepository
        devices = (try? resolvedRepository.loadDevices()) ?? []
        let wakeMetadata = (try? resolvedRepository.loadWakeMetadata())
            ?? SavedDeviceWakeMetadata(recentDeviceIDs: [], lastUsedDeviceID: nil)
        let prunedMetadata = Self.prunedMetadata(wakeMetadata, for: devices)
        recentDeviceIDs = prunedMetadata.recentDeviceIDs
        lastUsedDeviceID = prunedMetadata.lastUsedDeviceID
    }

    nonisolated deinit {}

    func reload() throws {
        devices = try repository.loadDevices()
        let metadata = try repository.loadWakeMetadata()
        let prunedMetadata = Self.prunedMetadata(metadata, for: devices)
        recentDeviceIDs = prunedMetadata.recentDeviceIDs
        lastUsedDeviceID = prunedMetadata.lastUsedDeviceID
    }

    func replaceAll(_ devices: [SavedDevice]) throws {
        let normalizedDevices = Self.normalized(devices)
        let metadata = Self.prunedMetadata(currentWakeMetadata, for: normalizedDevices)
        try repository.saveDevices(normalizedDevices)
        try repository.saveWakeMetadata(metadata)
        self.devices = normalizedDevices
        recentDeviceIDs = metadata.recentDeviceIDs
        lastUsedDeviceID = metadata.lastUsedDeviceID
    }

    func upsert(_ device: SavedDevice) throws {
        var nextDevices = devices

        if let existingIndex = nextDevices.firstIndex(where: { $0.id == device.id }) {
            nextDevices[existingIndex] = device
        } else {
            nextDevices.append(device)
        }

        try replaceAll(nextDevices)
    }

    func deleteDevice(id: UUID) throws {
        try replaceAll(devices.filter { $0.id != id })
    }

    func recentDevices(limit: Int = 3) -> [SavedDevice] {
        Array(recentDeviceIDs.prefix(limit)).compactMap(device(id:))
    }

    func markWakeSucceeded(deviceID: UUID) throws {
        guard device(id: deviceID) != nil else { return }

        var metadata = currentWakeMetadata
        metadata.recentDeviceIDs.removeAll { $0 == deviceID }
        metadata.recentDeviceIDs.insert(deviceID, at: 0)
        metadata.recentDeviceIDs = Array(metadata.recentDeviceIDs.prefix(3))
        metadata.lastUsedDeviceID = deviceID
        try repository.saveWakeMetadata(metadata)
        recentDeviceIDs = metadata.recentDeviceIDs
        lastUsedDeviceID = metadata.lastUsedDeviceID
    }

    func device(id: UUID) -> SavedDevice? {
        devices.first { $0.id == id }
    }

    func moveDevices(fromOffsets: IndexSet, toOffset: Int) throws {
        var nextDevices = devices
        move(&nextDevices, fromOffsets: fromOffsets, toOffset: toOffset)
        try replaceAll(nextDevices)
    }

    private static func normalized(_ devices: [SavedDevice]) -> [SavedDevice] {
        devices.enumerated().map { index, device in
            var normalizedDevice = device
            normalizedDevice.sortOrder = index
            return normalizedDevice
        }
    }

    private var currentWakeMetadata: SavedDeviceWakeMetadata {
        SavedDeviceWakeMetadata(
            recentDeviceIDs: recentDeviceIDs,
            lastUsedDeviceID: lastUsedDeviceID
        )
    }

    private static func prunedMetadata(
        _ metadata: SavedDeviceWakeMetadata,
        for devices: [SavedDevice]
    ) -> SavedDeviceWakeMetadata {
        let validIDs = Set(devices.map(\.id))
        let recentDeviceIDs = metadata.recentDeviceIDs.filter { validIDs.contains($0) }
        let lastUsedDeviceID = metadata.lastUsedDeviceID.flatMap { validIDs.contains($0) ? $0 : nil }

        return SavedDeviceWakeMetadata(
            recentDeviceIDs: recentDeviceIDs,
            lastUsedDeviceID: lastUsedDeviceID
        )
    }

    private func move(_ devices: inout [SavedDevice], fromOffsets: IndexSet, toOffset: Int) {
        let movingDevices = fromOffsets.map { devices[$0] }

        for index in fromOffsets.sorted(by: >) {
            devices.remove(at: index)
        }

        var destination = toOffset
        for index in fromOffsets where index < toOffset {
            destination -= 1
        }

        devices.insert(contentsOf: movingDevices, at: destination)
    }
}
