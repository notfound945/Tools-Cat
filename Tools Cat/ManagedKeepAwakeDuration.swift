import Foundation

struct ManagedKeepAwakeDuration: Codable, Equatable, Identifiable {
    let id: UUID
    let durationSeconds: Int

    init(id: UUID = UUID(), durationSeconds: Int) {
        self.id = id
        self.durationSeconds = durationSeconds
    }

    var menuTitle: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = durationSeconds % 60

        var parts: [String] = []
        if hours > 0 {
            parts.append("\(hours) 小时")
        }
        if minutes > 0 {
            parts.append("\(minutes) 分钟")
        }
        if seconds > 0 || parts.isEmpty {
            parts.append("\(seconds) 秒")
        }

        return parts.joined(separator: " ")
    }
}
