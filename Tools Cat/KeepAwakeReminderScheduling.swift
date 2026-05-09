import Foundation
import UserNotifications

protocol KeepAwakeReminderScheduling {
    func requestAuthorizationAtLaunch()
    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    )
    func cancelPendingReminder(identifier: String)
}

enum KeepAwakeReminderScheduleResult: Equatable {
    case scheduled
    case permissionUnavailable
    case failed
}

struct UserNotificationKeepAwakeReminderScheduler: KeepAwakeReminderScheduling {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorizationAtLaunch() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    ) {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                Task { @MainActor in
                    completion(.permissionUnavailable)
                }
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireAfter, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                Task { @MainActor in
                    completion(error == nil ? .scheduled : .failed)
                }
            }
        }
    }

    func cancelPendingReminder(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

struct NoopKeepAwakeReminderScheduler: KeepAwakeReminderScheduling {
    func requestAuthorizationAtLaunch() {}

    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    ) {
        Task { @MainActor in
            completion(.failed)
        }
    }

    func cancelPendingReminder(identifier: String) {}
}
