import Combine
import Foundation

enum KeepAwakeMode: Equatable {
    case off
    case indefinite
    case timed(preset: KeepAwakeDurationPreset, endDate: Date)
}

enum KeepAwakePendingAction: Equatable {
    case startingIndefinite
    case startingTimed(KeepAwakeDurationPreset)
    case stopping
}

@MainActor
final class KeepAwakeSessionModel: ObservableObject {
    @Published private(set) var confirmedMode: KeepAwakeMode
    @Published private(set) var pendingAction: KeepAwakePendingAction?
    @Published private(set) var message: String?
    @Published private(set) var countdownNow: Date

    private let powerController: KeepAwakePowerControlling
    private let scheduler: KeepAwakeCountdownScheduling
    private let nowProvider: () -> Date
    private var countdownToken: KeepAwakeCountdownToken?

    init(
        powerController: KeepAwakePowerControlling,
        scheduler: KeepAwakeCountdownScheduling,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.powerController = powerController
        self.scheduler = scheduler
        self.nowProvider = nowProvider
        let initialNow = nowProvider()
        self.confirmedMode = powerController.isEnabled ? .indefinite : .off
        self.pendingAction = nil
        self.message = nil
        self.countdownNow = initialNow
    }

    convenience init(nowProvider: @escaping () -> Date = Date.init) {
        self.init(
            powerController: SystemKeepAwakePowerController(manager: .shared),
            scheduler: TimerKeepAwakeCountdownScheduler(),
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

    func startTimed(_ preset: KeepAwakeDurationPreset) {
        guard pendingAction == nil else { return }

        pendingAction = .startingTimed(preset)
        message = nil

        powerController.setKeepAwakeEnabled(true) { [weak self] outcome in
            guard let self else { return }
            performKeepAwakeSessionUpdate {
                let now = self.nowProvider()
                let endDate = now.addingTimeInterval(preset.duration)
                self.handleEnableOutcome(
                    outcome,
                    requestedMode: .timed(preset: preset, endDate: endDate),
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
            beginStop(completion: completion)
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
            confirmedMode = requestedMode

            switch requestedMode {
            case .off:
                cancelCountdown()
            case .indefinite:
                cancelCountdown()
                countdownNow = requestedCountdownNow ?? nowProvider()
            case .timed(_, let endDate):
                let nextNow = requestedCountdownNow ?? nowProvider()
                countdownNow = nextNow
                installCountdown(endDate: endDate)
            }
        case .success(false), .unchanged(false):
            cancelCountdown()
            confirmedMode = .off
            message = nil
        case .failure(let current, let failureMessage):
            restoreConfirmedMode(currentEnabled: current)
            message = failureMessage
        }

        pendingAction = nil
    }

    private func beginStop(completion: (() -> Void)? = nil) {
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
            confirmedMode = .off
            message = nil
        case .success(true), .unchanged(true):
            restoreConfirmedMode(currentEnabled: true)
            message = nil
        case .failure(let current, let failureMessage):
            restoreConfirmedMode(currentEnabled: current)
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
        beginStop()
    }

    private func cancelCountdown() {
        countdownToken?.cancel()
        countdownToken = nil
    }
}

private func performKeepAwakeSessionUpdate(_ body: @escaping @MainActor () -> Void) {
    Task { @MainActor in
        body()
    }
}
