import Combine
import Foundation

enum KeepAwakeDurationManagementFormMode: Equatable {
    case add
    case edit(durationID: UUID)
}

@MainActor
final class KeepAwakeDurationManagementSessionModel: ObservableObject {
    @Published var durations: [ManagedKeepAwakeDuration]
    @Published var currentFormMode: KeepAwakeDurationManagementFormMode?
    @Published var draftMinutesText: String
    @Published var pendingDeleteDuration: ManagedKeepAwakeDuration?
    @Published var blockedDeleteDuration: ManagedKeepAwakeDuration?
    @Published var validationMessage: String?
    @Published var saveErrorMessage: String?

    private let durationStore: KeepAwakeDurationStore
    private let keepAwakeSession: KeepAwakeSessionModel?

    var isPresentingForm: Bool {
        currentFormMode != nil
    }

    var canSaveDraft: Bool {
        currentFormMode != nil && parsedDraftMinutes != nil
    }

    init(
        durationStore: KeepAwakeDurationStore? = nil,
        keepAwakeSession: KeepAwakeSessionModel? = nil
    ) {
        let resolvedStore = durationStore ?? KeepAwakeDurationStore()
        self.durationStore = resolvedStore
        self.keepAwakeSession = keepAwakeSession
        durations = resolvedStore.durations
        currentFormMode = nil
        draftMinutesText = ""
        pendingDeleteDuration = nil
        blockedDeleteDuration = nil
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
        clearDeleteState()
        currentFormMode = .add
    }

    func beginEdit(durationID: UUID) {
        guard let duration = durations.first(where: { $0.id == durationID }) else { return }

        clearErrors()
        draftMinutesText = minutesText(for: duration)
        clearDeleteState()
        currentFormMode = .edit(durationID: duration.id)
    }

    func cancelForm() {
        clearErrors()
        clearDraft()
        currentFormMode = nil
    }

    func saveDraft() {
        guard let activeFormMode = currentFormMode else { return }
        guard let draftMinutes = validatedDraftMinutes() else { return }

        let seconds = draftMinutes * 60

        do {
            switch activeFormMode {
            case .add:
                try durationStore.addDuration(seconds: seconds)
            case .edit(let durationID):
                try durationStore.updateDuration(id: durationID, seconds: seconds)
            }

            syncDurationsFromStore()
            clearErrors()
            clearDraft()
            currentFormMode = nil
        } catch let error as KeepAwakeDurationStoreError {
            validationMessage = validationMessage(for: error)
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = KeepAwakeDurationManagementPresentation.saveErrorMessage
        }
    }

    func requestDelete(durationID: UUID) {
        guard let duration = durations.first(where: { $0.id == durationID }) else { return }
        guard !isDeleteBlocked(durationID: durationID) else {
            pendingDeleteDuration = nil
            blockedDeleteDuration = duration
            saveErrorMessage = nil
            return
        }

        blockedDeleteDuration = nil
        pendingDeleteDuration = duration
        saveErrorMessage = nil
    }

    func cancelDelete() {
        pendingDeleteDuration = nil
    }

    func dismissBlockedDeleteAlert() {
        blockedDeleteDuration = nil
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

    private func clearDeleteState() {
        pendingDeleteDuration = nil
        blockedDeleteDuration = nil
    }

    private func clearErrors() {
        validationMessage = nil
        saveErrorMessage = nil
    }

    func isDeleteBlocked(durationID: UUID) -> Bool {
        guard case let .timed(duration, _) = keepAwakeSession?.confirmedMode else { return false }
        return duration.id == durationID
    }

    private func syncDurationsFromStore() {
        durations = durationStore.durations
    }
}
