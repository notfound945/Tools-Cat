import Foundation

enum ManualMACValidation: Equatable {
    case empty
    case invalidCharacters
    case missingSeparators
    case wrongGroupCount
    case wrongByteLength
    case valid(String)

    var userMessage: String? {
        switch self {
        case .empty:
            return "请填写 MAC 地址"
        case .invalidCharacters:
            return "MAC 地址只能包含 0-9、A-F 和冒号"
        case .missingSeparators:
            return "请输入冒号分隔格式，例如 AA:BB:CC:DD:EE:FF"
        case .wrongGroupCount, .wrongByteLength:
            return "MAC 地址必须是 6 组两位十六进制字符"
        case .valid:
            return nil
        }
    }

    var isValid: Bool {
        if case .valid = self {
            return true
        }

        return false
    }
}

enum ManualMACValidator {
    static func validate(_ input: String) -> ManualMACValidation {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .empty
        }

        if trimmed.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789abcdefABCDEF:").inverted) != nil {
            return .invalidCharacters
        }

        if !trimmed.contains(":") {
            return trimmed.count == 12 ? .missingSeparators : .wrongGroupCount
        }

        let groups = trimmed.split(separator: ":", omittingEmptySubsequences: false)
        guard groups.count == 6 else {
            return .wrongGroupCount
        }

        guard groups.allSatisfy({ $0.count == 2 }) else {
            return .wrongByteLength
        }

        let normalizedGroups = groups.map { String($0).uppercased() }
        return .valid(normalizedGroups.joined(separator: ":"))
    }
}
