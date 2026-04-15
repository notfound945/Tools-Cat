import Foundation

protocol KeepAwakeDurationRepository: AnyObject {
    func loadDurations() throws -> [ManagedKeepAwakeDuration]
    func saveDurations(_ durations: [ManagedKeepAwakeDuration]) throws
}

final class UserDefaultsKeepAwakeDurationRepository: KeepAwakeDurationRepository {
    private static let storageKey = "managed_keep_awake_durations"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDurations() throws -> [ManagedKeepAwakeDuration] {
        if defaults.object(forKey: Self.storageKey) == nil {
            let seededDurations = Self.defaultDurations
            try saveDurations(seededDurations)
            return seededDurations
        }

        guard let data = defaults.data(forKey: Self.storageKey) else {
            return []
        }

        let durations = try decoder.decode([ManagedKeepAwakeDuration].self, from: data)
        return Self.normalized(durations)
    }

    func saveDurations(_ durations: [ManagedKeepAwakeDuration]) throws {
        let normalizedDurations = Self.normalized(durations)
        let data = try encoder.encode(normalizedDurations)
        defaults.set(data, forKey: Self.storageKey)
    }

    private static var defaultDurations: [ManagedKeepAwakeDuration] {
        [900, 1800, 3600, 7200].map { ManagedKeepAwakeDuration(durationSeconds: $0) }
    }

    private static func normalized(_ durations: [ManagedKeepAwakeDuration]) -> [ManagedKeepAwakeDuration] {
        var seenSeconds: Set<Int> = []
        let deduplicated = durations.filter { duration in
            seenSeconds.insert(duration.durationSeconds).inserted
        }

        return deduplicated.sorted { lhs, rhs in
            if lhs.durationSeconds == rhs.durationSeconds {
                return lhs.id.uuidString < rhs.id.uuidString
            }

            return lhs.durationSeconds < rhs.durationSeconds
        }
    }
}
