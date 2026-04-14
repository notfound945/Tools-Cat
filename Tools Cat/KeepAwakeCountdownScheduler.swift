import Foundation

protocol KeepAwakeCountdownToken {
    func cancel()
}

protocol KeepAwakeCountdownScheduling {
    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken
}

final class TimerKeepAwakeCountdownScheduler: KeepAwakeCountdownScheduling {
    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            handler()
        }
        timer.tolerance = tolerance
        return TimerKeepAwakeCountdownToken(timer: timer)
    }
}

private final class TimerKeepAwakeCountdownToken: KeepAwakeCountdownToken {
    private var timer: Timer?

    init(timer: Timer) {
        self.timer = timer
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
