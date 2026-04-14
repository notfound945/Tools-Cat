import Cocoa
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusController: StatusBarController?
    private var wolWindow: WOLWindow?
    private var savedDeviceLibrary: SavedDeviceLibraryStore!
    private var wolSession: WOLSessionModel!
    private var keepAwakeSession: KeepAwakeSessionModel!
    private var deviceLibrarySession: DeviceLibrarySessionModel!
    private var deviceLibraryWindow: DeviceLibraryWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureSharedStores()

        if launchConfiguration.shouldOpenUtilityWindow {
            NSApp.setActivationPolicy(.regular)
        }

        let status = StatusBarController(
            deviceLibrary: savedDeviceLibrary,
            wolSession: wolSession,
            keepAwakeSession: keepAwakeSession
        )
        status.onOpenWOL = { [weak self] in
            self?.openWOLWindow()
        }
        status.onOpenDeviceLibrary = { [weak self] in
            self?.openDeviceLibraryWindow()
        }
        statusController = status

        if launchConfiguration.shouldOpenWOLWindow {
            openWOLWindow()
        }

        if launchConfiguration.shouldOpenDeviceLibrary {
            openDeviceLibraryWindow()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        _ = PowerAssertionManager.shared.disable()
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
        savedDeviceLibrary = SavedDeviceLibraryStore(repository: repository)
        wolSession = WOLSessionModel(deviceLibrary: savedDeviceLibrary)
        keepAwakeSession = KeepAwakeSessionModel(
            powerController: SystemKeepAwakePowerController(manager: .shared),
            scheduler: TimerKeepAwakeCountdownScheduler()
        )
        deviceLibrarySession = DeviceLibrarySessionModel(libraryStore: savedDeviceLibrary)
    }

    private var launchConfiguration: LaunchConfiguration {
        LaunchConfiguration(arguments: ProcessInfo.processInfo.arguments)
    }

    private var isRunningUnderXCTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

private struct LaunchConfiguration {
    let shouldOpenWOLWindow: Bool
    let shouldOpenDeviceLibrary: Bool
    let userDefaults: UserDefaults?
    let seededDeviceLibraryData: Data?

    var shouldOpenUtilityWindow: Bool {
        shouldOpenWOLWindow || shouldOpenDeviceLibrary
    }

    init(arguments: [String]) {
        shouldOpenWOLWindow = arguments.contains("--ui-test-open-wol-window")
        shouldOpenDeviceLibrary = arguments.contains("--ui-test-open-device-library")

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
