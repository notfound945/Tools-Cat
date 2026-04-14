import Foundation

enum WakeSendMessage: Equatable {
    case idle
    case sending
    case success(String)
    case failure(String)
}

extension WakeSendMessage {
    var text: String? {
        switch self {
        case .idle:
            return nil
        case .sending:
            return "正在发送唤醒包..."
        case let .success(message), let .failure(message):
            return message
        }
    }
}

extension WOLSenderError {
    var userMessage: String {
        switch self {
        case .invalidMAC:
            return "MAC 地址格式无效，请输入 AA:BB:CC:DD:EE:FF"
        case .socketFailed:
            return "无法创建本地网络发送通道"
        case .setsockoptFailed:
            return "无法启用局域网广播发送"
        case .sendFailed:
            return "未能从这台 Mac 发出唤醒包，请确认这台 Mac 已连接局域网后重试"
        }
    }
}

enum WakeSendPresentation {
    static func successMessage(for macAddress: String) -> String {
        _ = macAddress
        return "已从这台 Mac 发出唤醒包"
    }
}
