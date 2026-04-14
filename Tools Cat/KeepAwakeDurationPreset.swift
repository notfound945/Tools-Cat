import Foundation

enum KeepAwakeDurationPreset: CaseIterable, Equatable {
    case minutes15
    case minutes30
    case hour1
    case hours2

    var menuTitle: String {
        switch self {
        case .minutes15:
            return "15 分钟"
        case .minutes30:
            return "30 分钟"
        case .hour1:
            return "1 小时"
        case .hours2:
            return "2 小时"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .minutes15:
            return 900
        case .minutes30:
            return 1800
        case .hour1:
            return 3600
        case .hours2:
            return 7200
        }
    }
}
