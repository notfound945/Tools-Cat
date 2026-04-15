import Foundation
import XCTest
@testable import Tools_Cat

final class KeepAwakeDurationRepositoryTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var repository: UserDefaultsKeepAwakeDurationRepository!

    override func setUp() {
        super.setUp()

        suiteName = "KeepAwakeDurationRepositoryTests.\(UUID().uuidString)"
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

    func testFirstLoadSeedsDefaultDurationsExactlyOnce() throws {
        let durations = try repository.loadDurations()

        XCTAssertEqual(durations.map(\.durationSeconds), [900, 1800, 3600, 7200])
        XCTAssertEqual(try repository.loadDurations().map(\.durationSeconds), [900, 1800, 3600, 7200])
        XCTAssertNotNil(defaults.object(forKey: "managed_keep_awake_durations"))
    }

    func testExistingStorageDoesNotReseedDeletedDefaults() throws {
        try repository.saveDurations([
            ManagedKeepAwakeDuration(durationSeconds: 1800),
            ManagedKeepAwakeDuration(durationSeconds: 7200),
        ])

        XCTAssertEqual(try repository.loadDurations().map(\.durationSeconds), [1800, 7200])

        try repository.saveDurations([])
        XCTAssertEqual(try repository.loadDurations(), [])
    }

    func testSaveReloadNormalizesAscendingOrderAndDuplicateSeconds() throws {
        let preservedID = UUID()
        let duplicateID = UUID()
        let longerID = UUID()

        try repository.saveDurations([
            ManagedKeepAwakeDuration(id: longerID, durationSeconds: 7200),
            ManagedKeepAwakeDuration(id: duplicateID, durationSeconds: 1800),
            ManagedKeepAwakeDuration(id: preservedID, durationSeconds: 1800),
            ManagedKeepAwakeDuration(durationSeconds: 900),
        ])

        let durations = try repository.loadDurations()
        XCTAssertEqual(durations.map(\.durationSeconds), [900, 1800, 7200])
        XCTAssertEqual(durations[1].id, duplicateID)
    }

    func testPersistedJSONStoresOnlyIDAndDurationSecondsWhileTitlesStayDerived() throws {
        try repository.saveDurations([
            ManagedKeepAwakeDuration(durationSeconds: 5400),
        ])

        let rawData = try XCTUnwrap(defaults.data(forKey: "managed_keep_awake_durations"))
        let rawJSON = try XCTUnwrap(String(data: rawData, encoding: .utf8))
        XCTAssertFalse(rawJSON.contains("menuTitle"))
        XCTAssertEqual(try repository.loadDurations().first?.menuTitle, "1 小时 30 分钟")
    }
}
