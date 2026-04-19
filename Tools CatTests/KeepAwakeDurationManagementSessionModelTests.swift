import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class KeepAwakeDurationManagementSessionModelTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var repository: UserDefaultsKeepAwakeDurationRepository!
    private var store: KeepAwakeDurationStore!
    private var keepAwakePowerController: FakeKeepAwakePowerController!
    private var keepAwakeScheduler: FakeKeepAwakeCountdownScheduler!
    private var keepAwakeSession: KeepAwakeSessionModel!

    override func setUp() {
        super.setUp()

        suiteName = "KeepAwakeDurationManagementSessionModelTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        repository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)
        store = KeepAwakeDurationStore(repository: repository)
        keepAwakePowerController = FakeKeepAwakePowerController(isEnabled: false)
        keepAwakeScheduler = FakeKeepAwakeCountdownScheduler()
        keepAwakeSession = KeepAwakeSessionModel(
            powerController: keepAwakePowerController,
            scheduler: keepAwakeScheduler,
            nowProvider: { Date(timeIntervalSinceReferenceDate: 10_000) }
        )
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        keepAwakeSession = nil
        keepAwakeScheduler = nil
        keepAwakePowerController = nil
        store = nil
        repository = nil
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testReloadSeedsSortedManagedDurations() {
        let session = makeSession()

        session.reloadDurations()

        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 7200])
        XCTAssertEqual(session.durations.map(\.menuTitle), ["15 分钟", "30 分钟", "1 小时", "2 小时"])
        XCTAssertNil(session.currentFormMode)
        XCTAssertNil(session.pendingDeleteDuration)
    }

    func testInvalidDraftBlocksSave() {
        let session = makeSession()

        session.beginAdd()
        session.draftMinutesText = "   "
        session.saveDraft()

        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 7200])
        XCTAssertEqual(session.currentFormMode, .add)
        XCTAssertEqual(
            session.validationMessage,
            KeepAwakeDurationManagementPresentation.missingMinutesMessage
        )

        session.draftMinutesText = "abc"
        session.saveDraft()
        XCTAssertEqual(
            session.validationMessage,
            KeepAwakeDurationManagementPresentation.invalidMinutesMessage
        )

        session.draftMinutesText = "-1"
        session.saveDraft()
        XCTAssertEqual(
            session.validationMessage,
            KeepAwakeDurationManagementPresentation.invalidMinutesMessage
        )
    }

    func testAddDurationPersistsAndSortsBySeconds() {
        let session = makeSession()

        session.beginAdd()
        session.draftMinutesText = "90"
        session.saveDraft()

        XCTAssertNil(session.currentFormMode)
        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 5400, 7200])
        XCTAssertEqual(session.durations.first(where: { $0.durationSeconds == 5400 })?.menuTitle, "1 小时 30 分钟")

        let reloadedSession = makeSession()
        XCTAssertEqual(reloadedSession.durations.map(\.durationSeconds), [900, 1800, 3600, 5400, 7200])
    }

    func testEditDurationPreservesIdentityAndResorts() {
        let session = makeSession()
        let editedDuration = try! XCTUnwrap(session.durations.first(where: { $0.durationSeconds == 1800 }))

        session.beginEdit(durationID: editedDuration.id)
        XCTAssertEqual(session.currentFormMode, .edit(durationID: editedDuration.id))
        XCTAssertEqual(session.draftMinutesText, "30")

        session.draftMinutesText = "90"
        session.saveDraft()

        XCTAssertNil(session.currentFormMode)
        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 3600, 5400, 7200])
        XCTAssertEqual(session.durations.first(where: { $0.durationSeconds == 5400 })?.id, editedDuration.id)

        let conflictingDuration = try! XCTUnwrap(session.durations.first(where: { $0.durationSeconds == 7200 }))
        session.beginEdit(durationID: conflictingDuration.id)
        session.draftMinutesText = "90"
        session.saveDraft()

        XCTAssertEqual(
            session.validationMessage,
            KeepAwakeDurationManagementPresentation.duplicateDurationMessage
        )
        XCTAssertEqual(session.currentFormMode, .edit(durationID: conflictingDuration.id))
    }

    func testDeleteRequiresConfirmationAndPersists() {
        let session = makeSession()
        let deletedDuration = try! XCTUnwrap(session.durations.first(where: { $0.durationSeconds == 1800 }))

        session.confirmDelete()
        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 7200])

        session.requestDelete(durationID: deletedDuration.id)
        XCTAssertEqual(session.pendingDeleteDuration?.id, deletedDuration.id)

        session.confirmDelete()

        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 3600, 7200])
        XCTAssertNil(session.pendingDeleteDuration)

        let reloadedSession = makeSession()
        XCTAssertEqual(reloadedSession.durations.map(\.durationSeconds), [900, 3600, 7200])
    }

    func testDeleteBlocksCurrentlyActiveTimedDuration() async {
        let session = makeSession()
        let activeDuration = try! XCTUnwrap(session.durations.first(where: { $0.durationSeconds == 1800 }))

        keepAwakeSession.startTimed(activeDuration)
        keepAwakePowerController.complete(with: .success(true))
        await flushSessionModelUpdates()

        session.requestDelete(durationID: activeDuration.id)

        XCTAssertNil(session.pendingDeleteDuration)
        XCTAssertEqual(session.blockedDeleteDuration?.id, activeDuration.id)
        XCTAssertNil(session.saveErrorMessage)

        session.confirmDelete()
        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 7200])

        session.dismissBlockedDeleteAlert()
        XCTAssertNil(session.blockedDeleteDuration)
    }

    private func makeSession() -> KeepAwakeDurationManagementSessionModel {
        KeepAwakeDurationManagementSessionModel(
            durationStore: store,
            keepAwakeSession: keepAwakeSession
        )
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
    func startRepeating(
        interval: TimeInterval,
        tolerance: TimeInterval,
        handler: @escaping () -> Void
    ) -> KeepAwakeCountdownToken {
        FakeKeepAwakeCountdownToken(handler: handler)
    }
}

private final class FakeKeepAwakeCountdownToken: KeepAwakeCountdownToken {
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func cancel() {}

    func fire() {
        handler()
    }
}
