import Foundation
import IOKit.pwr_mgt

protocol KeepAwakePowerControlling {
    var isEnabled: Bool { get }
    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    )
}

final class PowerAssertionManager {
    static let shared = PowerAssertionManager()
    private init() {}

    private var assertionID: IOPMAssertionID = 0
    private(set) var isEnabled: Bool = false

    func enable() -> KeepAwakeToggleOutcome {
        guard !isEnabled else { return .unchanged(true) }

        var newID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Keep Display Awake" as CFString,
            &newID
        )

        if result == kIOReturnSuccess {
            assertionID = newID
            isEnabled = true
            return .success(true)
        }

        isEnabled = false
        return .failure(current: false, message: "未能开启保持屏幕常亮，当前状态未改变")
    }

    func disable() -> KeepAwakeToggleOutcome {
        guard isEnabled else { return .unchanged(false) }

        let result = IOPMAssertionRelease(assertionID)
        guard result == kIOReturnSuccess else {
            return .failure(current: true, message: "未能关闭保持屏幕常亮，当前状态未改变")
        }

        assertionID = 0
        isEnabled = false
        return .success(false)
    }
}

struct SystemKeepAwakePowerController: KeepAwakePowerControlling {
    private let manager: PowerAssertionManager
    private let queue: DispatchQueue

    init(
        manager: PowerAssertionManager,
        queue: DispatchQueue = DispatchQueue(label: "MacOSSwissKnife.keepAwakePower")
    ) {
        self.manager = manager
        self.queue = queue
    }

    var isEnabled: Bool {
        manager.isEnabled
    }

    func setKeepAwakeEnabled(
        _ enabled: Bool,
        completion: @escaping (KeepAwakeToggleOutcome) -> Void
    ) {
        queue.async {
            let outcome = enabled ? manager.enable() : manager.disable()
            DispatchQueue.main.async {
                completion(outcome)
            }
        }
    }
}
