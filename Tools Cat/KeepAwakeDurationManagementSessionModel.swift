import Combine
import Foundation

enum KeepAwakeDurationManagementScreen: Equatable {
    case list
    case form(KeepAwakeDurationManagementFormMode)
}

enum KeepAwakeDurationManagementFormMode: Equatable {
    case add
    case edit(durationID: UUID)
}

@MainActor
final class KeepAwakeDurationManagementSessionModel: ObservableObject {
    @Published var durations: [ManagedKeepAwakeDuration]
    @Published var screen: KeepAwakeDurationManagementScreen
    @Published var draftMinutesText: String
    @Published var pendingDeleteDuration: ManagedKeepAwakeDuration?
    @Published var validationMessage: String?
    @Published var saveErrorMessage: String?

    private let durationStore: KeepAwakeDurationStore

    var currentFormMode: KeepAwakeDurationManagementFormMode? {
        guard case .form(let mode) = screen else { return nil }
        return mode
    }

    var canSaveDraft: Bool {
        currentFormMode != nil && parsedDraftMinutes != nil
    }

    init(durationStore: KeepAwakeDurationStore? = nil) {
        let resolvedStore = durationStore ?? KeepAwakeDurationStore()
        self.durationStore = resolvedStore
        durations = resolvedStore.durations
        screen = .list
        draftMinutesText = ""
        pendingDeleteDuration = nil
        validationMessage = nil
        saveErrorMessage = nil
    }

    nonisolated deinit {}

    func reloadDurations() {
        do {
            try durationStore.reload()
            syncDurationsFromStore()
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = KeepAwakeDurationManagementPresentation.loadErrorMessage
        }
    }

    func beginAdd() {
        clearErrors()
        clearDraft()
        pendingDeleteDuration = nil
        screen = .form(.add)
    }

    func beginEdit(durationID: UUID) {
        guard let duration = durations.first(where: { $0.id == durationID }) else { return }

        clearErrors()
        draftMinutesText = minutesText(for: duration)
        pendingDeleteDuration = nil
        screen = .form(.edit(durationID: duration.id))
    }

    func cancelForm() {
        clearErrors()
        clearDraft()
        screen = .list
    }

    func saveDraft() {
        guard let currentFormMode else { return }
        guard let draftMinutes = validatedDraftMinutes() else { return }

        let seconds = draftMinutes * 60

        do {
            switch currentFormMode {
            case .add:
                try durationStore.addDuration(seconds: seconds)
            case .edit(let durationID):
                try durationStore.updateDuration(id: durationID, seconds: seconds)
            }

            syncDurationsFromStore()
            clearErrors()
            clearDraft()
            screen = .list
        } catch let error as KeepAwakeDurationStoreError {
            validationMessage = validationMessage(for: error)
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = KeepAwakeDurationManagementPresentation.saveErrorMessage
        }
    }

    func requestDelete(durationID: UUID) {
        guard let duration = durations.first(where: { $0.id == durationID }) else { return }

        pendingDeleteDuration = duration
        saveErrorMessage = nil
    }

    func cancelDelete() {
        pendingDeleteDuration = nil
    }

    func confirmDelete() {
        guard let pendingDeleteDuration else { return }

        do {
            try durationStore.deleteDuration(id: pendingDeleteDuration.id)
            syncDurationsFromStore()
            self.pendingDeleteDuration = nil
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = KeepAwakeDurationManagementPresentation.deleteErrorMessage
        }
    }

    private var parsedDraftMinutes: Int? {
        let trimmedValue = draftMinutesText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return nil }
        guard let parsedValue = Int(trimmedValue), parsedValue > 0 else { return nil }
        return parsedValue
    }

    private func validatedDraftMinutes() -> Int? {
        let trimmedValue = draftMinutesText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            validationMessage = KeepAwakeDurationManagementPresentation.missingMinutesMessage
            saveErrorMessage = nil
            return nil
        }

        guard let parsedValue = Int(trimmedValue), parsedValue > 0 else {
            validationMessage = KeepAwakeDurationManagementPresentation.invalidMinutesMessage
            saveErrorMessage = nil
            return nil
        }

        validationMessage = nil
        return parsedValue
    }

    private func validationMessage(for error: KeepAwakeDurationStoreError) -> String {
        switch error {
        case .invalidDuration:
            KeepAwakeDurationManagementPresentation.invalidMinutesMessage
        case .duplicateDuration:
            KeepAwakeDurationManagementPresentation.duplicateDurationMessage
        }
    }

    private func minutesText(for duration: ManagedKeepAwakeDuration) -> String {
        String(max(1, duration.durationSeconds / 60))
    }

    private func clearDraft() {
        draftMinutesText = ""
    }

    private func clearErrors() {
        validationMessage = nil
        saveErrorMessage = nil
    }

    private func syncDurationsFromStore() {
        durations = durationStore.durations
    }
}
