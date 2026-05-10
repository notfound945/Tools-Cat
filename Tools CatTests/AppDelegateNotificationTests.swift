import XCTest
@testable import Tools_Cat

@MainActor
final class AppDelegateNotificationTests: XCTestCase {
    private static var retainedDelegates: [AppDelegate] = []

    func testBootstrapLaunchServicesInstallsForegroundPresentationBeforeAuthorizationRequest() {
        let suiteName = "AppDelegateNotificationTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected isolated test defaults")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)

        let scheduler = LaunchFakeKeepAwakeReminderScheduler()
        let subject = AppDelegate()
        subject.makeKeepAwakeReminderScheduler = { scheduler }
        subject.launchConfigurationOverride = LaunchConfiguration(
            arguments: ["Tools Cat", "--ui-test-user-defaults-suite", suiteName]
        )
        subject.forcesReminderAuthorizationRequestDuringTests = true

        subject.bootstrapLaunchServices()
        Self.retainedDelegates.append(subject)

        XCTAssertEqual(
            scheduler.events,
            ["installForegroundPresentationDelegate", "requestAuthorizationAtLaunch"]
        )
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testApplicationDidFinishLaunchingUsesInjectedReminderSchedulerWithoutRealSystemPrompt() {
        let suiteName = "AppDelegateNotificationTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected isolated test defaults")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)

        let scheduler = LaunchFakeKeepAwakeReminderScheduler()
        let subject = AppDelegate()
        subject.makeKeepAwakeReminderScheduler = {
            scheduler.wasFactoryUsed = true
            return scheduler
        }
        subject.launchConfigurationOverride = LaunchConfiguration(
            arguments: ["Tools Cat", "--ui-test-user-defaults-suite", suiteName]
        )
        subject.forcesReminderAuthorizationRequestDuringTests = true

        subject.bootstrapLaunchServices()
        Self.retainedDelegates.append(subject)

        XCTAssertTrue(scheduler.wasFactoryUsed)
        XCTAssertEqual(scheduler.requestedAuthorizationCount, 1)
        XCTAssertEqual(scheduler.scheduledRequests.count, 0)
        XCTAssertEqual(scheduler.canceledIdentifiers, [])
        defaults.removePersistentDomain(forName: suiteName)
    }
}

private final class LaunchFakeKeepAwakeReminderScheduler: KeepAwakeReminderScheduling {
    var requestedAuthorizationCount = 0
    var wasFactoryUsed = false
    var events: [String] = []
    var scheduledRequests: [ScheduledRequest] = []
    var canceledIdentifiers: [String] = []

    struct ScheduledRequest: Equatable {
        let identifier: String
        let fireAfter: TimeInterval
        let title: String
        let body: String
    }

    func requestAuthorizationAtLaunch() {
        events.append("requestAuthorizationAtLaunch")
        requestedAuthorizationCount += 1
    }

    func installForegroundPresentationDelegate() {
        events.append("installForegroundPresentationDelegate")
    }

    func fetchAuthorizationState(
        completion: @escaping @MainActor (KeepAwakeReminderAuthorizationState) -> Void
    ) {
        Task { @MainActor in
            completion(.authorized)
        }
    }

    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    ) {
        scheduledRequests.append(
            ScheduledRequest(
                identifier: identifier,
                fireAfter: fireAfter,
                title: title,
                body: body
            )
        )
        Task { @MainActor in
            completion(.scheduled)
        }
    }

    func deliverExpiryReminder(
        identifier: String,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderDeliveryResult) -> Void
    ) {
        Task { @MainActor in
            completion(.delivered)
        }
    }

    func cancelPendingReminder(identifier: String) {
        canceledIdentifiers.append(identifier)
    }
}
