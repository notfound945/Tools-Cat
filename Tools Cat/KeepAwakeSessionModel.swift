import Combine
import Foundation

enum KeepAwakeMode: Equatable {
    case off
    case indefinite
    case timed(duration: ManagedKeepAwakeDuration, endDate: Date)
}

enum KeepAwakePendingAction: Equatable {
    case startingIndefinite
    case startingTimed(ManagedKeepAwakeDuration)
    case stopping
}

enum KeepAwakeReminderAvailability: Equatable {
    case available
    case unavailable(String)
}

@MainActor
final class KeepAwakeSessionModel: ObservableObject {
    @Published private(set) var confirmedMode: KeepAwakeMode
    @Published private(set) var pendingAction: KeepAwakePendingAction?
    @Published private(set) var message: String?
    @Published private(set) var countdownNow: Date
    @Published private(set) var reminderAvailability: KeepAwakeReminderAvailability

    private enum KeepAwakeStopReason: Equatable {
        case manual
        case timedExpiry(sessionID: UUID)
    }

    private let powerController: KeepAwakePowerControlling
    private let scheduler: KeepAwakeCountdownScheduling
    private let reminderScheduler: KeepAwakeReminderScheduling
    private let nowProvider: () -> Date
    private let preExpiryReminderLeadTime: TimeInterval = 120
    private var countdownToken: KeepAwakeCountdownToken?
    private var activeTimedSessionID: UUID?
    private var activePreExpiryReminderIdentifier: String?
    private var pendingStopReason: KeepAwakeStopReason?

    init(
        powerController: KeepAwakePowerControlling,
        scheduler: KeepAwakeCountdownScheduling,
        reminderScheduler: KeepAwakeReminderScheduling,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.powerController = powerController
        self.scheduler = scheduler
        self.reminderScheduler = reminderScheduler
        self.nowProvider = nowProvider
        let initialNow = nowProvider()
        self.confirmedMode = powerController.isEnabled ? .indefinite : .off
        self.pendingAction = nil
        self.message = nil
        self.countdownNow = initialNow
        self.reminderAvailability = .available
    }

    convenience init(
        powerController: KeepAwakePowerControlling,
        scheduler: KeepAwakeCountdownScheduling,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.init(
            powerController: powerController,
            scheduler: scheduler,
            reminderScheduler: NoopKeepAwakeReminderScheduler(),
            nowProvider: nowProvider
        )
    }

    convenience init(nowProvider: @escaping () -> Date = Date.init) {
        self.init(
            powerController: SystemKeepAwakePowerController(manager: .shared),
            scheduler: TimerKeepAwakeCountdownScheduler(),
            reminderScheduler: NoopKeepAwakeReminderScheduler(),
            nowProvider: nowProvider
        )
    }

    func startIndefinite() {
        guard pendingAction == nil else { return }

        pendingAction = .startingIndefinite
        message = nil

        powerController.setKeepAwakeEnabled(true) { [weak self] outcome in
            guard let self else { return }
            performKeepAwakeSessionUpdate {
                self.handleEnableOutcome(outcome, requestedMode: .indefinite)
            }
        }
    }

    func startTimed(_ duration: ManagedKeepAwakeDuration) {
        guard pendingAction == nil else { return }

        pendingAction = .startingTimed(duration)
        message = nil

        powerController.setKeepAwakeEnabled(true) { [weak self] outcome in
            guard let self else { return }
            performKeepAwakeSessionUpdate {
                let now = self.nowProvider()
                let endDate = now.addingTimeInterval(TimeInterval(duration.durationSeconds))
                self.handleEnableOutcome(
                    outcome,
                    requestedMode: .timed(duration: duration, endDate: endDate),
                    countdownNow: now
                )
            }
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        guard pendingAction == nil else {
            completion?()
            return
        }

        switch confirmedMode {
        case .off:
            message = nil
            completion?()
        case .indefinite, .timed:
            beginStop(reason: .manual, completion: completion)
        }
    }

    private func handleEnableOutcome(
        _ outcome: KeepAwakeToggleOutcome,
        requestedMode: KeepAwakeMode,
        countdownNow requestedCountdownNow: Date? = nil
    ) {
        switch outcome {
        case .success(true), .unchanged(true):
            message = nil
            pendingStopReason = nil
            confirmedMode = requestedMode

            switch requestedMode {
            case .off:
                cancelCountdown()
                clearTimedSessionState()
            case .indefinite:
                cancelCountdown()
                countdownNow = requestedCountdownNow ?? nowProvider()
                clearTimedSessionState()
            case .timed(_, let endDate):
                let nextNow = requestedCountdownNow ?? nowProvider()
                countdownNow = nextNow
                installCountdown(endDate: endDate)
                activateTimedSession(endDate: endDate, now: nextNow)
            }
        case .success(false), .unchanged(false):
            cancelCountdown()
            confirmedMode = .off
            message = nil
            clearTimedSessionState()
        case .failure(let current, let failureMessage):
            restoreConfirmedMode(currentEnabled: current)
            if !current {
                clearTimedSessionState()
            }
            message = failureMessage
            pendingStopReason = nil
        }

        pendingAction = nil
    }

    private func beginStop(
        reason: KeepAwakeStopReason,
        completion: (() -> Void)? = nil
    ) {
        pendingStopReason = reason
        pendingAction = .stopping
        message = nil
        cancelCountdown()

        powerController.setKeepAwakeEnabled(false) { [weak self] outcome in
            guard let self else { return }
            performKeepAwakeSessionUpdate {
                self.handleStopOutcome(outcome)
                completion?()
            }
        }
    }

    private func handleStopOutcome(_ outcome: KeepAwakeToggleOutcome) {
        switch outcome {
        case .success(false), .unchanged(false):
            let stopReason = pendingStopReason
            let activeSessionID = activeTimedSessionID
            confirmedMode = .off
            message = nil
            clearTimedSessionState()

            if case let .timedExpiry(sessionID) = stopReason,
               activeSessionID == sessionID {
                deliverExpiryReminder(for: sessionID)
            }
        case .success(true), .unchanged(true):
            restoreConfirmedMode(currentEnabled: true)
            message = nil
            pendingStopReason = nil
        case .failure(let current, let failureMessage):
            restoreConfirmedMode(currentEnabled: current)
            if !current {
                clearTimedSessionState()
            } else {
                pendingStopReason = nil
            }
            message = failureMessage
        }

        pendingAction = nil
    }

    private func restoreConfirmedMode(currentEnabled: Bool) {
        guard currentEnabled else {
            cancelCountdown()
            confirmedMode = .off
            return
        }

        switch confirmedMode {
        case .off:
            confirmedMode = .indefinite
        case .indefinite:
            cancelCountdown()
        case .timed(_, let endDate):
            resumeCountdownIfNeeded(endDate: endDate)
        }
    }

    private func installCountdown(endDate: Date) {
        cancelCountdown()
        countdownToken = scheduler.startRepeating(interval: 1, tolerance: 0.1) { [weak self] in
            guard let self else { return }
            performKeepAwakeSessionUpdate {
                self.handleCountdownTick(endDate: endDate)
            }
        }
    }

    private func resumeCountdownIfNeeded(endDate: Date) {
        let now = nowProvider()
        countdownNow = now

        guard endDate.timeIntervalSince(now) > 0 else { return }
        installCountdown(endDate: endDate)
    }

    private func handleCountdownTick(endDate: Date) {
        countdownNow = nowProvider()

        guard pendingAction == nil else { return }
        guard case .timed(_, let currentEndDate) = confirmedMode, currentEndDate == endDate else {
            return
        }
        guard currentEndDate.timeIntervalSince(countdownNow) <= 0 else { return }
        guard let sessionID = activeTimedSessionID else { return }

        beginStop(reason: .timedExpiry(sessionID: sessionID), completion: nil)
    }

    private func cancelCountdown() {
        countdownToken?.cancel()
        countdownToken = nil
    }

    private func activateTimedSession(endDate: Date, now: Date) {
        let previousIdentifier = activePreExpiryReminderIdentifier
        let sessionID = UUID()

        activeTimedSessionID = sessionID
        activePreExpiryReminderIdentifier = nil
        pendingStopReason = nil
        reminderAvailability = .available

        if let previousIdentifier {
            reminderScheduler.cancelPendingReminder(identifier: previousIdentifier)
        }

        reminderScheduler.fetchAuthorizationState { [weak self] state in
            guard let self else { return }
            guard self.activeTimedSessionID == sessionID else { return }

            switch state {
            case .authorized:
                self.reminderAvailability = .available
                let fireAfter = endDate.timeIntervalSince(now) - self.preExpiryReminderLeadTime
                guard fireAfter > 120 || fireAfter > 0 else {
                    if endDate.timeIntervalSince(now) <= self.preExpiryReminderLeadTime {
                        self.activePreExpiryReminderIdentifier = nil
                    }
                    return
                }

                let identifier = self.preExpiryReminderIdentifier(for: sessionID)
                self.activePreExpiryReminderIdentifier = identifier
                self.reminderScheduler.schedulePreExpiryReminder(
                    identifier: identifier,
                    fireAfter: fireAfter,
                    title: "常亮即将结束",
                    body: "2 分钟后将关闭常亮"
                ) { [weak self] result in
                    guard let self else { return }
                    guard self.activeTimedSessionID == sessionID else { return }

                    switch result {
                    case .scheduled:
                        self.reminderAvailability = .available
                    case .permissionUnavailable:
                        self.activePreExpiryReminderIdentifier = nil
                        self.reminderAvailability = .unavailable("提醒不可用：通知权限未开启")
                    case .failed:
                        self.activePreExpiryReminderIdentifier = nil
                        self.reminderAvailability = .unavailable("提醒不可用：无法安排提醒")
                    }
                }
            case .unavailable:
                self.reminderAvailability = .unavailable("提醒不可用：通知权限未开启")
            }
        }
    }

    private func clearTimedSessionState() {
        if let activePreExpiryReminderIdentifier {
            reminderScheduler.cancelPendingReminder(identifier: activePreExpiryReminderIdentifier)
        }
        activeTimedSessionID = nil
        activePreExpiryReminderIdentifier = nil
        pendingStopReason = nil
        reminderAvailability = .available
    }

    private func deliverExpiryReminder(for sessionID: UUID) {
        reminderScheduler.deliverExpiryReminder(
            identifier: expiryReminderIdentifier(for: sessionID),
            title: "常亮已结束",
            body: "已按时关闭常亮"
        ) { _ in }
    }

    private func preExpiryReminderIdentifier(for sessionID: UUID) -> String {
        "keep-awake.session.\(sessionID.uuidString).pre-expiry"
    }

    private func expiryReminderIdentifier(for sessionID: UUID) -> String {
        "keep-awake.session.\(sessionID.uuidString).expiry"
    }
}

private func performKeepAwakeSessionUpdate(_ body: @escaping @MainActor () -> Void) {
    Task { @MainActor in
        body()
    }
}
