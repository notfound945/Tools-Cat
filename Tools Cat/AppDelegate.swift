import Cocoa
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusController: StatusBarController?
    private var wolWindow: WOLWindow?
    private var savedDeviceLibrary: SavedDeviceLibraryStore!
    private var wolSession: WOLSessionModel!
    private var keepAwakeSession: KeepAwakeSessionModel!
    private var keepAwakeReminderScheduler: KeepAwakeReminderScheduling!
    private var keepAwakeDurationStore: KeepAwakeDurationStore!
    private var keepAwakeDurationManagementSession: KeepAwakeDurationManagementSessionModel!
    private var keepAwakeDurationManagementWindow: KeepAwakeDurationManagementWindow?
    private var deviceLibrarySession: DeviceLibrarySessionModel!
    private var deviceLibraryWindow: DeviceLibraryWindow?
    var makeKeepAwakeReminderScheduler: () -> KeepAwakeReminderScheduling = {
        UserNotificationKeepAwakeReminderScheduler()
    }
    var launchConfigurationOverride: LaunchConfiguration?
    var forcesReminderAuthorizationRequestDuringTests = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        bootstrapLaunchServices()

        if launchConfiguration.shouldOpenUtilityWindow {
            NSApp.setActivationPolicy(.regular)
        }

        let status = StatusBarController(
            deviceLibrary: savedDeviceLibrary,
            wolSession: wolSession,
            keepAwakeSession: keepAwakeSession,
            keepAwakeDurationStore: keepAwakeDurationStore
        )
        status.onOpenWOL = { [weak self] in
            self?.openWOLWindow()
        }
        status.onOpenDeviceLibrary = { [weak self] in
            self?.openDeviceLibraryWindow()
        }
        status.onOpenKeepAwakeDurationManagement = { [weak self] in
            self?.openKeepAwakeDurationManagementWindow()
        }
        statusController = status

        if launchConfiguration.shouldOpenWOLWindow {
            openWOLWindow()
        }

        if launchConfiguration.shouldOpenDeviceLibrary {
            openDeviceLibraryWindow()
        }

        if launchConfiguration.shouldOpenKeepAwakeDurationManagement {
            openKeepAwakeDurationManagementWindow()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        _ = PowerAssertionManager.shared.disable()
    }

    func bootstrapLaunchServices() {
        configureSharedStores()
        keepAwakeReminderScheduler.installForegroundPresentationDelegate()
        guard shouldRequestReminderAuthorizationAtLaunch else { return }
        keepAwakeReminderScheduler.requestAuthorizationAtLaunch()
    }

    private func openWOLWindow() {
        if wolWindow == nil {
            wolWindow = WOLWindow(session: wolSession, deviceLibrary: savedDeviceLibrary)
        }
        wolWindow?.show()
    }

    private func openDeviceLibraryWindow() {
        if deviceLibraryWindow == nil {
            deviceLibraryWindow = DeviceLibraryWindow(session: deviceLibrarySession)
        }
        deviceLibraryWindow?.show()
    }

    private func openKeepAwakeDurationManagementWindow() {
        if keepAwakeDurationManagementWindow == nil {
            keepAwakeDurationManagementWindow = KeepAwakeDurationManagementWindow(
                session: keepAwakeDurationManagementSession
            )
        }
        keepAwakeDurationManagementWindow?.show()
    }

    private func configureSharedStores() {
        let defaults = launchConfiguration.userDefaults ?? .standard
        if launchConfiguration.userDefaults == nil,
           !isRunningUnderXCTest,
           let legacyDefaults = UserDefaults(suiteName: UserDefaultsSavedDeviceRepository.legacySuiteName) {
            UserDefaultsSavedDeviceRepository.migrateLegacySavedDeviceDefaultsIfNeeded(
                into: defaults,
                legacyDefaults: legacyDefaults
            )
        }
        if let seededDeviceLibraryData = launchConfiguration.seededDeviceLibraryData {
            defaults.set(seededDeviceLibraryData, forKey: "saved_devices")
            defaults.synchronize()
        }
        let repository = UserDefaultsSavedDeviceRepository(defaults: defaults)
        let keepAwakeDurationRepository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)
        savedDeviceLibrary = SavedDeviceLibraryStore(repository: repository)
        wolSession = WOLSessionModel(deviceLibrary: savedDeviceLibrary)
        keepAwakeReminderScheduler = makeKeepAwakeReminderScheduler()
        keepAwakeSession = KeepAwakeSessionModel(
            powerController: SystemKeepAwakePowerController(manager: .shared),
            scheduler: TimerKeepAwakeCountdownScheduler(),
            reminderScheduler: keepAwakeReminderScheduler
        )
        keepAwakeDurationStore = KeepAwakeDurationStore(repository: keepAwakeDurationRepository)
        keepAwakeDurationManagementSession = KeepAwakeDurationManagementSessionModel(
            durationStore: keepAwakeDurationStore,
            keepAwakeSession: keepAwakeSession
        )
        deviceLibrarySession = DeviceLibrarySessionModel(libraryStore: savedDeviceLibrary)
    }

    private var launchConfiguration: LaunchConfiguration {
        launchConfigurationOverride ?? LaunchConfiguration(arguments: ProcessInfo.processInfo.arguments)
    }

    private var isRunningUnderXCTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private var shouldRequestReminderAuthorizationAtLaunch: Bool {
        !isRunningUnderXCTest || forcesReminderAuthorizationRequestDuringTests
    }
}

struct LaunchConfiguration {
    let shouldOpenWOLWindow: Bool
    let shouldOpenDeviceLibrary: Bool
    let shouldOpenKeepAwakeDurationManagement: Bool
    let userDefaults: UserDefaults?
    let seededDeviceLibraryData: Data?

    var shouldOpenUtilityWindow: Bool {
        shouldOpenWOLWindow || shouldOpenDeviceLibrary || shouldOpenKeepAwakeDurationManagement
    }

    init(arguments: [String]) {
        shouldOpenWOLWindow = arguments.contains("--ui-test-open-wol-window")
        shouldOpenDeviceLibrary = arguments.contains("--ui-test-open-device-library")
        shouldOpenKeepAwakeDurationManagement = arguments.contains("--ui-test-open-keep-awake-duration-management")

        if let suiteFlagIndex = arguments.firstIndex(of: "--ui-test-user-defaults-suite"),
           arguments.indices.contains(arguments.index(after: suiteFlagIndex)) {
            let suiteName = arguments[arguments.index(after: suiteFlagIndex)]
            userDefaults = UserDefaults(suiteName: suiteName)
        } else {
            userDefaults = nil
        }

        if let seededDevicesFlagIndex = arguments.firstIndex(of: "--ui-test-seeded-device-library"),
           arguments.indices.contains(arguments.index(after: seededDevicesFlagIndex)) {
            let encodedSeed = arguments[arguments.index(after: seededDevicesFlagIndex)]
            seededDeviceLibraryData = Data(base64Encoded: encodedSeed)
        } else {
            seededDeviceLibraryData = nil
        }
    }
}
