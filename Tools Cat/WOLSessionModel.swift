import Combine
import Foundation

protocol WakeSending {
    func send(to macAddress: String) throws
}

protocol WakeResultClearing {
    func schedule(after delay: TimeInterval, _ action: @escaping @MainActor () -> Void) -> WakeResultClearToken
}

protocol WakeResultClearToken {
    func cancel()
}

enum WakeSendState: Equatable {
    case idle
    case sending(macAddress: String)
    case success(message: String)
    case failure(message: String)
}

struct CompletedWakeAttempt: Equatable {
    let deviceID: UUID?
    let message: String
    let wasSuccessful: Bool
}

final class WOLSessionModel: ObservableObject {
    @Published var inputMode: InputMode
    @Published var selectedSavedDeviceID: UUID?
    @Published var customMac: String
    @Published var validation: ManualMACValidation
    @Published var sendState: WakeSendState
    @Published private(set) var lastCompletedWake: CompletedWakeAttempt?
    @Published var isWindowVisible: Bool
    private let deviceLibrary: SavedDeviceLibraryStore
    private var wakeSender: WakeSending
    private let sendQueue: DispatchQueue
    private let wakeResultClearing: WakeResultClearing
    private var preservesHiddenCompletionResult = false
    private var clearWakeResultToken: WakeResultClearToken?

    init(
        deviceLibrary: SavedDeviceLibraryStore,
        inputMode: InputMode = .preset,
        selectedSavedDeviceID: UUID? = nil,
        customMac: String = "",
        validation: ManualMACValidation? = nil,
        sendState: WakeSendState = .idle,
        lastCompletedWake: CompletedWakeAttempt? = nil,
        isWindowVisible: Bool = false,
        wakeSender: WakeSending = SystemWakeSender(),
        sendQueue: DispatchQueue = DispatchQueue(label: "WOLSessionModel.send", qos: .userInitiated),
        wakeResultClearing: WakeResultClearing = DispatchQueueWakeResultClearing()
    ) {
        self.deviceLibrary = deviceLibrary
        self.inputMode = inputMode
        self.selectedSavedDeviceID = selectedSavedDeviceID
        self.customMac = customMac
        self.validation = validation ?? ManualMACValidator.validate(customMac)
        self.sendState = sendState
        self.lastCompletedWake = lastCompletedWake
        self.isWindowVisible = isWindowVisible
        self.wakeSender = wakeSender
        self.sendQueue = sendQueue
        self.wakeResultClearing = wakeResultClearing
    }

    var canSend: Bool {
        switch inputMode {
        case .preset:
            guard let selectedSavedDeviceID else { return false }
            return deviceLibrary.device(id: selectedSavedDeviceID) != nil
        case .custom:
            if case .valid = validation {
                return true
            }

            return false
        }
    }

    var isSending: Bool {
        if case .sending = sendState {
            return true
        }

        return false
    }

    func updateCustomMac(_ newValue: String) {
        customMac = newValue
        validation = ManualMACValidator.validate(newValue)
    }

    func sendCurrentSelection() {
        switch inputMode {
        case .preset:
            guard let selectedSavedDeviceID else { return }
            guard let selectedDevice = deviceLibrary.device(id: selectedSavedDeviceID) else { return }
            send(targetMACAddress: selectedDevice.macAddress, savedDeviceID: selectedSavedDeviceID)
        case .custom:
            guard case let .valid(validMac) = validation else { return }
            send(targetMACAddress: validMac, savedDeviceID: nil)
        }
    }

    func sendSavedDevice(id: UUID) {
        guard let device = deviceLibrary.device(id: id) else { return }
        send(targetMACAddress: device.macAddress, savedDeviceID: id)
    }

    func handleWindowWillShow() {
        isWindowVisible = true

        guard !isSending else { return }

        if preservesHiddenCompletionResult {
            preservesHiddenCompletionResult = false
            return
        }

        if inputMode == .custom && customMac.isEmpty == false {
            if sendState.isCompletedResult {
                updateSendStateOnMain(.idle)
            }
            return
        }

        if let rememberedID = deviceLibrary.lastUsedDeviceID,
           deviceLibrary.device(id: rememberedID) != nil {
            inputMode = .preset
            selectedSavedDeviceID = rememberedID
        } else {
            selectedSavedDeviceID = deviceLibrary.devices.first?.id

            if selectedSavedDeviceID != nil {
                inputMode = .preset
            }
        }

        if sendState.isCompletedResult {
            updateSendStateOnMain(.idle)
        }
    }

    func handleWindowWillClose() {
        isWindowVisible = false
    }

    #if DEBUG
    @MainActor
    func setWakeSenderForTesting(_ wakeSender: WakeSending) {
        self.wakeSender = wakeSender
    }
    #endif

    private func updateSendStateOnMain(_ nextState: WakeSendState) {
        if Thread.isMainThread {
            sendState = nextState
            return
        }

        DispatchQueue.main.sync {
            sendState = nextState
        }
    }

    private func send(targetMACAddress: String, savedDeviceID: UUID?) {
        guard !isSending else { return }

        clearWakeResultToken?.cancel()
        clearWakeResultToken = nil
        preservesHiddenCompletionResult = false
        updateSendStateOnMain(.sending(macAddress: targetMACAddress))

        sendQueue.async { [wakeSender] in
            let outcome: CompletedWakeAttempt

            do {
                try wakeSender.send(to: targetMACAddress)
                let successMessage = WakeSendPresentation.successMessage(for: targetMACAddress)
                outcome = CompletedWakeAttempt(
                    deviceID: savedDeviceID,
                    message: successMessage,
                    wasSuccessful: true
                )
            } catch {
                let failureMessage = error.userMessage
                outcome = CompletedWakeAttempt(
                    deviceID: savedDeviceID,
                    message: failureMessage,
                    wasSuccessful: false
                )
            }

            Task { @MainActor [weak self] in
                guard let self else { return }
                if !self.isWindowVisible {
                    self.preservesHiddenCompletionResult = true
                }
                self.lastCompletedWake = outcome

                if outcome.wasSuccessful {
                    self.sendState = .success(message: outcome.message)

                    if let savedDeviceID {
                        try? self.deviceLibrary.markWakeSucceeded(deviceID: savedDeviceID)
                    }
                } else {
                    self.sendState = .failure(message: outcome.message)
                }

                self.scheduleWakeResultClear()
            }
        }
    }

    @MainActor
    private func scheduleWakeResultClear() {
        clearWakeResultToken?.cancel()
        clearWakeResultToken = wakeResultClearing.schedule(after: 3) { [weak self] in
            guard let self else { return }
            self.clearWakeResultToken = nil
            self.lastCompletedWake = nil
            if self.sendState.isCompletedResult {
                self.sendState = .idle
            }
            self.preservesHiddenCompletionResult = false
        }
    }
}

struct SystemWakeSender: WakeSending {
    func send(to macAddress: String) throws {
        try WOLSender.send(to: macAddress)
    }
}

struct DispatchQueueWakeResultClearing: WakeResultClearing {
    func schedule(after delay: TimeInterval, _ action: @escaping @MainActor () -> Void) -> WakeResultClearToken {
        let task = Task {
            let nanoseconds = UInt64(delay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await action()
        }
        return TaskWakeResultClearToken(task: task)
    }
}

private final class TaskWakeResultClearToken: WakeResultClearToken {
    private let task: Task<Void, Never>

    init(task: Task<Void, Never>) {
        self.task = task
    }

    func cancel() {
        task.cancel()
    }
}

private extension WakeSendState {
    var isCompletedResult: Bool {
        switch self {
        case .success, .failure:
            return true
        case .idle, .sending:
            return false
        }
    }
}

private extension Error {
    var userMessage: String {
        if let error = self as? WOLSenderError {
            return error.userMessage
        }

        return "未能从这台 Mac 发出唤醒包，请稍后重试"
    }
}
