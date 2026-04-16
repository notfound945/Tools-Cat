import Combine
import Foundation

enum DeviceLibraryFormMode: Equatable {
    case add
    case edit(deviceID: UUID)
}

@MainActor
final class DeviceLibrarySessionModel: ObservableObject {
    @Published var devices: [SavedDevice]
    @Published var currentFormMode: DeviceLibraryFormMode?
    @Published var draftName: String
    @Published var draftMACAddress: String
    @Published var draftNote: String
    @Published var isReordering: Bool
    @Published var pendingDeleteDevice: SavedDevice?
    @Published var validationMessage: String?
    @Published var saveErrorMessage: String?

    private let libraryStore: SavedDeviceLibraryStore

    var isPresentingForm: Bool {
        currentFormMode != nil
    }

    var nameValidationMessage: String? {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "请填写设备名称" : nil
    }

    var macAddressValidation: ManualMACValidation {
        ManualMACValidator.validate(draftMACAddress)
    }

    var macAddressValidationMessage: String? {
        macAddressValidation.userMessage
    }

    var canSaveDraft: Bool {
        currentFormMode != nil && nameValidationMessage == nil && macAddressValidation.isValid
    }

    init(libraryStore: SavedDeviceLibraryStore? = nil) {
        let resolvedStore = libraryStore ?? SavedDeviceLibraryStore()
        self.libraryStore = resolvedStore
        devices = resolvedStore.devices
        currentFormMode = nil
        draftName = ""
        draftMACAddress = ""
        draftNote = ""
        isReordering = false
        pendingDeleteDevice = nil
        validationMessage = nil
        saveErrorMessage = nil
    }

    nonisolated deinit {}

    func reloadDevices() {
        do {
            try libraryStore.reload()
            syncDevicesFromStore()
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "无法加载设备，请稍后重试"
        }
    }

    func beginAdd() {
        clearErrors()
        clearDraft()
        pendingDeleteDevice = nil
        isReordering = false
        currentFormMode = .add
    }

    func beginEdit(deviceID: UUID) {
        guard let device = devices.first(where: { $0.id == deviceID }) else { return }

        clearErrors()
        draftName = device.name
        draftMACAddress = device.macAddress
        draftNote = device.note
        pendingDeleteDevice = nil
        isReordering = false
        currentFormMode = .edit(deviceID: device.id)
    }

    func cancelForm() {
        clearErrors()
        clearDraft()
        currentFormMode = nil
    }

    func saveDraft() {
        guard let activeFormMode = currentFormMode else { return }

        let trimmedName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let nameValidationMessage {
            validationMessage = nameValidationMessage
            saveErrorMessage = nil
            return
        }

        let macValidation = macAddressValidation
        guard case let .valid(normalizedMACAddress) = macValidation else {
            validationMessage = macValidation.userMessage
            saveErrorMessage = nil
            return
        }

        let normalizedNote = draftNote.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            switch activeFormMode {
            case .add:
                let newDevice = SavedDevice(
                    id: UUID(),
                    name: trimmedName,
                    macAddress: normalizedMACAddress,
                    note: normalizedNote,
                    sortOrder: devices.count
                )
                try libraryStore.upsert(newDevice)
            case .edit(let deviceID):
                guard let existingDevice = devices.first(where: { $0.id == deviceID }) else { return }

                let updatedDevice = SavedDevice(
                    id: existingDevice.id,
                    name: trimmedName,
                    macAddress: normalizedMACAddress,
                    note: normalizedNote,
                    sortOrder: existingDevice.sortOrder
                )
                try libraryStore.upsert(updatedDevice)
            }

            syncDevicesFromStore()
            clearErrors()
            clearDraft()
            currentFormMode = nil
        } catch {
            saveErrorMessage = "无法保存设备，请稍后重试"
        }
    }

    func requestDelete(deviceID: UUID) {
        guard let device = devices.first(where: { $0.id == deviceID }) else { return }

        pendingDeleteDevice = device
        saveErrorMessage = nil
    }

    func cancelDelete() {
        pendingDeleteDevice = nil
    }

    func confirmDelete() {
        guard let pendingDeleteDevice else { return }

        do {
            try libraryStore.deleteDevice(id: pendingDeleteDevice.id)
            syncDevicesFromStore()
            self.pendingDeleteDevice = nil
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "无法删除设备，请稍后重试"
        }
    }

    func moveDevices(fromOffsets: IndexSet, toOffset: Int) {
        do {
            try libraryStore.moveDevices(fromOffsets: fromOffsets, toOffset: toOffset)
            syncDevicesFromStore()
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "无法保存排序，请稍后重试"
        }
    }

    private func clearDraft() {
        draftName = ""
        draftMACAddress = ""
        draftNote = ""
    }

    private func clearErrors() {
        validationMessage = nil
        saveErrorMessage = nil
    }

    private func syncDevicesFromStore() {
        devices = libraryStore.devices
    }
}
