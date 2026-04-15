import Combine
import Foundation

enum KeepAwakeDurationStoreError: Error, Equatable {
    case invalidDuration
    case duplicateDuration
}

@MainActor
final class KeepAwakeDurationStore: ObservableObject {
    @Published private(set) var durations: [ManagedKeepAwakeDuration] = []

    private let repository: KeepAwakeDurationRepository

    init(repository: KeepAwakeDurationRepository? = nil) {
        let resolvedRepository = repository ?? UserDefaultsKeepAwakeDurationRepository()
        self.repository = resolvedRepository
        durations = (try? resolvedRepository.loadDurations()) ?? []
    }

    nonisolated deinit {}

    func reload() throws {
        durations = try repository.loadDurations()
    }

    func addDuration(seconds: Int) throws {
        try validate(seconds: seconds)
        var nextDurations = durations
        nextDurations.append(ManagedKeepAwakeDuration(durationSeconds: seconds))
        try persist(nextDurations)
    }

    func updateDuration(id: UUID, seconds: Int) throws {
        try validate(seconds: seconds, ignoringID: id)
        let nextDurations = durations.map { duration in
            guard duration.id == id else { return duration }
            return ManagedKeepAwakeDuration(id: duration.id, durationSeconds: seconds)
        }
        try persist(nextDurations)
    }

    func deleteDuration(id: UUID) throws {
        try persist(durations.filter { $0.id != id })
    }

    func duration(matchingSeconds durationSeconds: Int) -> ManagedKeepAwakeDuration? {
        durations.first { $0.durationSeconds == durationSeconds }
    }

    private func validate(seconds: Int, ignoringID: UUID? = nil) throws {
        guard seconds > 0 else {
            throw KeepAwakeDurationStoreError.invalidDuration
        }

        let duplicateExists = durations.contains { duration in
            duration.durationSeconds == seconds && duration.id != ignoringID
        }
        if duplicateExists {
            throw KeepAwakeDurationStoreError.duplicateDuration
        }
    }

    private func persist(_ nextDurations: [ManagedKeepAwakeDuration]) throws {
        try repository.saveDurations(nextDurations)
        durations = try repository.loadDurations()
    }
}
