import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class KeepAwakeSessionModelTests: XCTestCase {
    func testStartIndefiniteWaitsForConfirmedEnableBeforeSwitchingModes() async {
        let powerController = FakeKeepAwakePowerController(isEnabled: false)
        let scheduler = FakeKeepAwakeCountdownScheduler()
        let initialNow = Date(timeIntervalSinceReferenceDate: 10_000)
        let model = KeepAwakeSessionModel(
            powerController: powerController,
            scheduler: scheduler,
            nowProvider: { initialNow }
        )

        XCTAssertEqual(model.confirmedMode, .off)
        XCTAssertNil(model.pendingAction)

        model.startIndefinite()

        XCTAssertEqual(model.confirmedMode, .off)
        XCTAssertEqual(model.pendingAction, .startingIndefinite)
        XCTAssertEqual(powerController.requestedStates, [true])

        powerController.complete(with: .success(true))
        await flushSessionModelUpdates()

        XCTAssertEqual(model.confirmedMode, .indefinite)
        XCTAssertNil(model.pendingAction)
        XCTAssertNil(model.message)
        XCTAssertTrue(scheduler.startedTokens.isEmpty)
    }

    func testStartTimedSessionStoresManagedDurationAndEndDateAfterConfirmedEnable() async {
        let powerController = FakeKeepAwakePowerController(isEnabled: false)
        let scheduler = FakeKeepAwakeCountdownScheduler()
        let startNow = Date(timeIntervalSinceReferenceDate: 20_000)
        var currentNow = startNow
        let minutes15 = makeDuration(900)
        let model = KeepAwakeSessionModel(
            powerController: powerController,
            scheduler: scheduler,
            nowProvider: { currentNow }
        )

        model.startTimed(minutes15)

        XCTAssertEqual(model.confirmedMode, .off)
        XCTAssertEqual(model.pendingAction, .startingTimed(minutes15))
        XCTAssertEqual(powerController.requestedStates, [true])

        powerController.complete(with: .success(true))
        await flushSessionModelUpdates()

        XCTAssertEqual(
            model.confirmedMode,
            .timed(
                duration: minutes15,
                endDate: startNow.addingTimeInterval(TimeInterval(minutes15.durationSeconds))
            )
        )
        XCTAssertNil(model.pendingAction)
        XCTAssertEqual(model.countdownNow, startNow)
        XCTAssertEqual(scheduler.startedTokens.count, 1)
        XCTAssertEqual(scheduler.startCalls.count, 1)
        XCTAssertEqual(scheduler.startCalls.first?.interval, 1)
        XCTAssertEqual(scheduler.startCalls.first?.tolerance, 0.1)

        currentNow = startNow.addingTimeInterval(30)
        scheduler.startedTokens[0].fire()
        await flushSessionModelUpdates()

        XCTAssertEqual(model.countdownNow, currentNow)
    }

    func testReplacingTimedSessionCancelsThePreviousCountdownToken() async {
        let powerController = FakeKeepAwakePowerController(isEnabled: true)
        let scheduler = FakeKeepAwakeCountdownScheduler()
        let initialNow = Date(timeIntervalSinceReferenceDate: 30_000)
        let replacementNow = initialNow.addingTimeInterval(120)
        var nowValues = [initialNow, initialNow, replacementNow]
        let minutes15 = makeDuration(900)
        let hours2 = makeDuration(7200)
        let model = KeepAwakeSessionModel(
            powerController: powerController,
            scheduler: scheduler,
            nowProvider: { nowValues.removeFirst() }
        )

        model.startTimed(minutes15)
        powerController.complete(with: .unchanged(true))
        await flushSessionModelUpdates()

        let firstToken = scheduler.startedTokens[0]
        XCTAssertFalse(firstToken.didCancel)

        model.startTimed(hours2)

        XCTAssertEqual(model.pendingAction, .startingTimed(hours2))
        XCTAssertEqual(powerController.requestedStates, [true, true])

        powerController.complete(with: .unchanged(true))
        await flushSessionModelUpdates()

        XCTAssertTrue(firstToken.didCancel)
        XCTAssertEqual(scheduler.startedTokens.count, 2)
        XCTAssertEqual(
            model.confirmedMode,
            .timed(
                duration: hours2,
                endDate: replacementNow.addingTimeInterval(TimeInterval(hours2.durationSeconds))
            )
        )
    }

    func testTimedExpiryReturnsToOffOnlyAfterConfirmedDisable() async {
        let powerController = FakeKeepAwakePowerController(isEnabled: false)
        let scheduler = FakeKeepAwakeCountdownScheduler()
        let startNow = Date(timeIntervalSinceReferenceDate: 40_000)
        let minutes30 = makeDuration(1800)
        let expiryNow = startNow.addingTimeInterval(TimeInterval(minutes30.durationSeconds))
        var currentNow = startNow
        let model = KeepAwakeSessionModel(
            powerController: powerController,
            scheduler: scheduler,
            nowProvider: { currentNow }
        )

        model.startTimed(minutes30)
        powerController.complete(with: .success(true))
        await flushSessionModelUpdates()

        currentNow = expiryNow
        scheduler.startedTokens[0].fire()
        await flushSessionModelUpdates()

        XCTAssertEqual(powerController.requestedStates, [true, false])
        XCTAssertEqual(
            model.confirmedMode,
            .timed(duration: minutes30, endDate: expiryNow)
        )
        XCTAssertEqual(model.pendingAction, .stopping)

        powerController.complete(with: .success(false))
        await flushSessionModelUpdates()

        XCTAssertEqual(model.confirmedMode, .off)
        XCTAssertNil(model.pendingAction)
        XCTAssertNil(model.message)
    }

    func testDisableFailureAfterExpiryKeepsLastConfirmedModeAndMessage() async {
        let powerController = FakeKeepAwakePowerController(isEnabled: false)
        let scheduler = FakeKeepAwakeCountdownScheduler()
        let startNow = Date(timeIntervalSinceReferenceDate: 50_000)
        let minutes15 = makeDuration(900)
        let expiryNow = startNow.addingTimeInterval(TimeInterval(minutes15.durationSeconds))
        var currentNow = startNow
        let model = KeepAwakeSessionModel(
            powerController: powerController,
            scheduler: scheduler,
            nowProvider: { currentNow }
        )

        model.startTimed(minutes15)
        powerController.complete(with: .success(true))
        await flushSessionModelUpdates()

        currentNow = expiryNow
        scheduler.startedTokens[0].fire()
        await flushSessionModelUpdates()

        powerController.complete(with: .failure(current: true, message: "关闭失败"))
        await flushSessionModelUpdates()

        XCTAssertEqual(
            model.confirmedMode,
            .timed(duration: minutes15, endDate: expiryNow)
        )
        XCTAssertNil(model.pendingAction)
        XCTAssertEqual(model.message, "关闭失败")
    }

    private func makeDuration(_ seconds: Int) -> ManagedKeepAwakeDuration {
        ManagedKeepAwakeDuration(id: UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", seconds))")!, durationSeconds: seconds)
    }

    private func flushSessionModelUpdates() async {
        await Task.yield()
        await Task.yield()
    }
}

@MainActor
private final class FakeKeepAwakePowerController: KeepAwakePowerControlling {
    private(set) var isEnabled: Bool
    private(set) var requestedStates: [Bool] = []
    private var pendingCompletions: [(KeepAwakeToggleOutcome) -> Void] = []

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    ) {
        requestedStates.append(enabled)
        pendingCompletions.append(completion)
    }

    func complete(with outcome: KeepAwakeToggleOutcome) {
        switch outcome {
        case .success(let enabled), .unchanged(let enabled):
            isEnabled = enabled
        case .failure(let current, _):
            isEnabled = current
        }

        let completion = pendingCompletions.removeFirst()
        completion(outcome)
    }
}

private final class FakeKeepAwakeCountdownScheduler: KeepAwakeCountdownScheduling {
    struct StartCall: Equatable {
        let interval: TimeInterval
        let tolerance: TimeInterval
    }

    private(set) var startCalls: [StartCall] = []
    private(set) var startedTokens: [FakeKeepAwakeCountdownToken] = []

    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        startCalls.append(StartCall(interval: interval, tolerance: tolerance))
        let token = FakeKeepAwakeCountdownToken(handler: handler)
        startedTokens.append(token)
        return token
    }
}

private final class FakeKeepAwakeCountdownToken: KeepAwakeCountdownToken {
    private let handler: () -> Void
    private(set) var didCancel = false

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func cancel() {
        didCancel = true
    }

    func fire() {
        handler()
    }
}
