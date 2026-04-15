import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class KeepAwakeDurationStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var repository: UserDefaultsKeepAwakeDurationRepository!

    override func setUp() {
        super.setUp()

        suiteName = "KeepAwakeDurationStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        repository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        repository = nil
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testAddDurationRejectsInvalidAndDuplicateSeconds() throws {
        let store = KeepAwakeDurationStore(repository: repository)

        XCTAssertThrowsError(try store.addDuration(seconds: 0)) { error in
            XCTAssertEqual(error as? KeepAwakeDurationStoreError, .invalidDuration)
        }
        XCTAssertThrowsError(try store.addDuration(seconds: -1)) { error in
            XCTAssertEqual(error as? KeepAwakeDurationStoreError, .invalidDuration)
        }
        XCTAssertThrowsError(try store.addDuration(seconds: 900)) { error in
            XCTAssertEqual(error as? KeepAwakeDurationStoreError, .duplicateDuration)
        }
    }

    func testUpdateDurationResortsAndPreservesIdentity() throws {
        let store = KeepAwakeDurationStore(repository: repository)
        let duration = try XCTUnwrap(store.duration(matchingSeconds: 1800))

        try store.updateDuration(id: duration.id, seconds: 5400)

        XCTAssertEqual(store.durations.map(\.durationSeconds), [900, 3600, 5400, 7200])
        XCTAssertEqual(store.durations.first(where: { $0.durationSeconds == 5400 })?.id, duration.id)

        let conflicting = try XCTUnwrap(store.duration(matchingSeconds: 7200))
        XCTAssertThrowsError(try store.updateDuration(id: conflicting.id, seconds: 5400)) { error in
            XCTAssertEqual(error as? KeepAwakeDurationStoreError, .duplicateDuration)
        }
    }

    func testDeleteAndReloadPersistManagedDurations() throws {
        let store = KeepAwakeDurationStore(repository: repository)
        let duration = try XCTUnwrap(store.duration(matchingSeconds: 1800))

        try store.deleteDuration(id: duration.id)
        try store.addDuration(seconds: 5400)
        try store.reload()

        XCTAssertEqual(store.durations.map(\.durationSeconds), [900, 3600, 5400, 7200])

        let reloadedStore = KeepAwakeDurationStore(repository: repository)
        XCTAssertEqual(reloadedStore.durations.map(\.durationSeconds), [900, 3600, 5400, 7200])
    }
}
