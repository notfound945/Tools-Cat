import Foundation

struct SavedDevice: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var macAddress: String
    var note: String
    var sortOrder: Int
}
