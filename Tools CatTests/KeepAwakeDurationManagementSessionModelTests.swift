import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class KeepAwakeDurationManagementSessionModelTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var repository: UserDefaultsKeepAwakeDurationRepository!
    private var store: KeepAwakeDurationStore!

    override func setUp() {
        super.setUp()

        suiteName = "KeepAwakeDurationManagementSessionModelTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        repository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)
        store = KeepAwakeDurationStore(repository: repository)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
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
        XCTAssertEqual(session.screen, .list)
        XCTAssertNil(session.pendingDeleteDuration)
    }

    func testInvalidDraftBlocksSave() {
        let session = makeSession()

        session.beginAdd()
        session.draftMinutesText = "   "
        session.saveDraft()

        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 7200])
        XCTAssertEqual(session.screen, .form(.add))
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

        XCTAssertEqual(session.screen, .list)
        XCTAssertEqual(session.durations.map(\.durationSeconds), [900, 1800, 3600, 5400, 7200])
        XCTAssertEqual(session.durations.first(where: { $0.durationSeconds == 5400 })?.menuTitle, "1 小时 30 分钟")

        let reloadedSession = makeSession()
        XCTAssertEqual(reloadedSession.durations.map(\.durationSeconds), [900, 1800, 3600, 5400, 7200])
    }

    func testEditDurationPreservesIdentityAndResorts() {
        let session = makeSession()
        let editedDuration = try! XCTUnwrap(session.durations.first(where: { $0.durationSeconds == 1800 }))

        session.beginEdit(durationID: editedDuration.id)
        XCTAssertEqual(session.screen, .form(.edit(durationID: editedDuration.id)))
        XCTAssertEqual(session.draftMinutesText, "30")

        session.draftMinutesText = "90"
        session.saveDraft()

        XCTAssertEqual(session.screen, .list)
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
        XCTAssertEqual(session.screen, .form(.edit(durationID: conflictingDuration.id)))
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

    private func makeSession() -> KeepAwakeDurationManagementSessionModel {
        KeepAwakeDurationManagementSessionModel(durationStore: store)
    }
}
