import Foundation

enum KeepAwakeToggleOutcome: Equatable {
    case unchanged(Bool)
    case success(Bool)
    case failure(current: Bool, message: String)
}

struct KeepAwakePresentation: Equatable {
    let confirmedMode: KeepAwakeMode
    let pendingAction: KeepAwakePendingAction?
    let message: String?
    let now: Date

    var isIndefiniteActive: Bool {
        if case .indefinite = confirmedMode {
            return true
        }

        return false
    }

    var activeTimedPreset: KeepAwakeDurationPreset? {
        if case let .timed(preset, _) = confirmedMode {
            return preset
        }

        return nil
    }

    var statusText: String? {
        if let pendingAction {
            return pendingStatusText(for: pendingAction)
        }

        if let message, !message.isEmpty {
            return message
        }

        switch confirmedMode {
        case .off:
            return nil
        case .indefinite:
            return "当前：无限常亮"
        case .timed(_, let endDate):
            return "还剩 \(formattedDuration(until: endDate))"
        }
    }

    var iconSymbol: String {
        if pendingAction != nil {
            return "bolt.slash"
        }

        switch confirmedMode {
        case .off:
            return "bolt.slash"
        case .indefinite, .timed:
            return "bolt.fill"
        }
    }

    var buttonToolTip: String {
        if pendingAction != nil {
            return "常亮状态更新中"
        }

        switch confirmedMode {
        case .off:
            return "常亮已关闭"
        case .indefinite:
            return "常亮已开启：无限常亮"
        case .timed(_, let endDate):
            return "常亮已开启：剩余 \(formattedDuration(until: endDate))"
        }
    }

    var isPending: Bool {
        pendingAction != nil
    }

    private func pendingStatusText(for action: KeepAwakePendingAction) -> String {
        switch action {
        case .startingIndefinite:
            return "正在切换为无限常亮..."
        case .startingTimed(let preset):
            return "正在切换为 \(preset.menuTitle)常亮..."
        case .stopping:
            return "正在关闭常亮..."
        }
    }

    private func formattedDuration(until endDate: Date) -> String {
        let remaining = max(0, endDate.timeIntervalSince(now))
        if remaining == 0 {
            return "0 秒"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = remaining >= 3600 ? 2 : 1

        if remaining >= 3600 {
            formatter.allowedUnits = [.hour, .minute]
        } else if remaining >= 60 {
            formatter.allowedUnits = [.minute]
        } else {
            formatter.allowedUnits = [.second]
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_Hans_CN")
        formatter.calendar = calendar

        let rawValue = formatter.string(from: remaining) ?? "0秒"
        let normalized = rawValue
            .replacingOccurrences(of: "秒钟", with: "秒")
            .replacingOccurrences(of: "小时", with: " 小时 ")
            .replacingOccurrences(of: "分钟", with: " 分钟 ")
            .replacingOccurrences(of: "秒", with: " 秒 ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)

        return normalized
    }
}
