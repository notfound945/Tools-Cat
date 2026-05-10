import Foundation
import UserNotifications

protocol KeepAwakeReminderScheduling {
    func installForegroundPresentationDelegate()
    func requestAuthorizationAtLaunch()
    func fetchAuthorizationState(
        completion: @escaping @MainActor (KeepAwakeReminderAuthorizationState) -> Void
    )
    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    )
    func deliverExpiryReminder(
        identifier: String,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderDeliveryResult) -> Void
    )
    func cancelPendingReminder(identifier: String)
}

enum KeepAwakeReminderAuthorizationState: Equatable {
    case authorized
    case unavailable
}

enum KeepAwakeReminderScheduleResult: Equatable {
    case scheduled
    case permissionUnavailable
    case failed
}

enum KeepAwakeReminderDeliveryResult: Equatable {
    case delivered
    case permissionUnavailable
    case failed
}

final class UserNotificationKeepAwakeReminderScheduler: NSObject, KeepAwakeReminderScheduling, UNUserNotificationCenterDelegate {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func installForegroundPresentationDelegate() {
        center.delegate = self
    }

    func requestAuthorizationAtLaunch() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func fetchAuthorizationState(
        completion: @escaping @MainActor (KeepAwakeReminderAuthorizationState) -> Void
    ) {
        center.getNotificationSettings { settings in
            let state: KeepAwakeReminderAuthorizationState
            switch settings.authorizationStatus {
            case .authorized:
                state = .authorized
            case .notDetermined, .denied, .provisional, .ephemeral:
                state = .unavailable
            @unknown default:
                state = .unavailable
            }

            Task { @MainActor in
                completion(state)
            }
        }
    }

    func schedulePreExpiryReminder(
        identifier: String,
        fireAfter: TimeInterval,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderScheduleResult) -> Void
    ) {
        fetchAuthorizationState { [center] state in
            guard state == .authorized else {
                completion(.permissionUnavailable)
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

    func deliverExpiryReminder(
        identifier: String,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderDeliveryResult) -> Void
    ) {
        fetchAuthorizationState { [center] state in
            guard state == .authorized else {
                completion(.permissionUnavailable)
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil
            )

            center.add(request) { error in
                Task { @MainActor in
                    completion(error == nil ? .delivered : .failed)
                }
            }
        }
    }

    func cancelPendingReminder(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let identifier = notification.request.identifier
        guard identifier.hasPrefix("keep-awake.session."),
              identifier.hasSuffix(".pre-expiry") || identifier.hasSuffix(".expiry") else {
            completionHandler([])
            return
        }

        completionHandler([.banner, .list, .sound])
    }
}

struct NoopKeepAwakeReminderScheduler: KeepAwakeReminderScheduling {
    func installForegroundPresentationDelegate() {}

    func requestAuthorizationAtLaunch() {}

    func fetchAuthorizationState(
        completion: @escaping @MainActor (KeepAwakeReminderAuthorizationState) -> Void
    ) {
        Task { @MainActor in
            completion(.unavailable)
        }
    }

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

    func deliverExpiryReminder(
        identifier: String,
        title: String,
        body: String,
        completion: @escaping @MainActor (KeepAwakeReminderDeliveryResult) -> Void
    ) {
        Task { @MainActor in
            completion(.failed)
        }
    }

    func cancelPendingReminder(identifier: String) {}
}
