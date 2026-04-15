import Cocoa
import Combine

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let menu: NSMenu
    private let deviceLibrary: SavedDeviceLibraryStore
    private let wolSession: WOLSessionModel
    private let keepAwakeSession: KeepAwakeSessionModel
    private let keepAwakeDurationStore: KeepAwakeDurationStore
    private var cancellables: Set<AnyCancellable> = []
    private var dynamicWakeItems: [NSMenuItem] = []
    private var dynamicKeepAwakeTimedItems: [NSMenuItem] = []
    private var wolItem: NSMenuItem!
    private var keepAwakeWakeSeparatorItem: NSMenuItem!
    private var wakeQuitSeparatorItem: NSMenuItem!
    private var manageDevicesItem: NSMenuItem!
    private var manageKeepAwakeDurationsItem: NSMenuItem!
    private var quitItem: NSMenuItem!

    private(set) var keepAwakeIndefiniteItem: NSMenuItem!
    private(set) var keepAwakeOffItem: NSMenuItem!
    private(set) var keepAwakeStatusItem: NSMenuItem!
    private(set) var recentWakeItems: [NSMenuItem] = []
    private(set) var allDevicesItem: NSMenuItem?
    private(set) var wakeStatusItem: NSMenuItem?

    var keepAwake15MinutesItem: NSMenuItem {
        forceTimedKeepAwakeItem(seconds: 900)
    }

    var keepAwake30MinutesItem: NSMenuItem {
        forceTimedKeepAwakeItem(seconds: 1800)
    }

    var keepAwake1HourItem: NSMenuItem {
        forceTimedKeepAwakeItem(seconds: 3600)
    }

    var keepAwake2HoursItem: NSMenuItem {
        forceTimedKeepAwakeItem(seconds: 7200)
    }

    var menuItemsForTesting: [NSMenuItem] {
        menu.items
    }

    var keepAwakeTimedItemsForTesting: [NSMenuItem] {
        dynamicKeepAwakeTimedItems
    }

    var statusButtonForTesting: NSStatusBarButton? {
        statusItem.button
    }

    func menuIndexForTesting(of item: NSMenuItem) -> Int {
        menu.index(of: item)
    }

    var wolMenuIndexForTesting: Int {
        menu.index(of: wolItem)
    }

    var onOpenWOL: (() -> Void)?
    var onOpenDeviceLibrary: (() -> Void)?
    var onOpenKeepAwakeDurationManagement: (() -> Void)?

    init(
        deviceLibrary: SavedDeviceLibraryStore? = nil,
        wolSession: WOLSessionModel? = nil,
        keepAwakeSession: KeepAwakeSessionModel? = nil,
        keepAwakeDurationStore: KeepAwakeDurationStore? = nil
    ) {
        let resolvedDeviceLibrary = deviceLibrary ?? SavedDeviceLibraryStore()
        self.deviceLibrary = resolvedDeviceLibrary
        self.wolSession = wolSession ?? WOLSessionModel(deviceLibrary: resolvedDeviceLibrary)
        self.keepAwakeSession = keepAwakeSession ?? KeepAwakeSessionModel()
        self.keepAwakeDurationStore = keepAwakeDurationStore ?? KeepAwakeDurationStore()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        menu.autoenablesItems = false
        super.init()
        configure()
    }

    private func configure() {
        keepAwakeIndefiniteItem = NSMenuItem(
            title: "无限常亮",
            action: #selector(startKeepAwakeIndefinite(_:)),
            keyEquivalent: ""
        )
        keepAwakeIndefiniteItem.target = self
        menu.addItem(keepAwakeIndefiniteItem)

        keepAwakeOffItem = NSMenuItem(
            title: "关闭常亮",
            action: #selector(stopKeepAwake(_:)),
            keyEquivalent: ""
        )
        keepAwakeOffItem.target = self
        menu.addItem(keepAwakeOffItem)

        keepAwakeStatusItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        keepAwakeStatusItem.isEnabled = false
        keepAwakeStatusItem.isHidden = true
        menu.addItem(keepAwakeStatusItem)

        manageKeepAwakeDurationsItem = NSMenuItem(
            title: "管理常亮时长…",
            action: #selector(openKeepAwakeDurationManagement),
            keyEquivalent: ""
        )
        manageKeepAwakeDurationsItem.target = self
        menu.addItem(manageKeepAwakeDurationsItem)

        keepAwakeWakeSeparatorItem = NSMenuItem.separator()
        menu.addItem(keepAwakeWakeSeparatorItem)

        wolItem = NSMenuItem(title: "发送 WOL …", action: #selector(openWOL), keyEquivalent: "")
        wolItem.target = self
        menu.addItem(wolItem)

        manageDevicesItem = NSMenuItem(title: "管理 WOL 设备…", action: #selector(openDeviceLibrary), keyEquivalent: "")
        manageDevicesItem.target = self
        menu.addItem(manageDevicesItem)

        wakeQuitSeparatorItem = NSMenuItem.separator()
        menu.addItem(wakeQuitSeparatorItem)

        quitItem = NSMenuItem(title: "退出 Tools Cat", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        rebuildKeepAwakeMenu()
        rebuildWakeMenu()
        bindWakeMenuState()
        renderKeepAwakePresentation()
    }

    private func bindWakeMenuState() {
        deviceLibrary.$devices
            .dropFirst()
            .sink { [weak self] _ in
                self?.rebuildWakeMenu()
            }
            .store(in: &cancellables)

        wolSession.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.refreshWakeMenuState()
                }
            }
            .store(in: &cancellables)

        keepAwakeSession.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.renderKeepAwakePresentation()
                }
            }
            .store(in: &cancellables)

        keepAwakeDurationStore.$durations
            .dropFirst()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.rebuildKeepAwakeMenu()
                    self?.renderKeepAwakePresentation()
                }
            }
            .store(in: &cancellables)
    }

    private func renderKeepAwakePresentation() {
        let presentation = KeepAwakePresentation(
            confirmedMode: keepAwakeSession.confirmedMode,
            pendingAction: keepAwakeSession.pendingAction,
            message: keepAwakeSession.message,
            now: keepAwakeSession.countdownNow
        )

        keepAwakeIndefiniteItem.state = presentation.isIndefiniteActive ? .on : .off
        let activeTimedSeconds = presentation.activeTimedDuration?.durationSeconds
        dynamicKeepAwakeTimedItems.forEach { item in
            let duration = item.representedObject as? ManagedKeepAwakeDuration
            item.state = duration?.durationSeconds == activeTimedSeconds ? .on : .off
        }
        keepAwakeOffItem.state = .off
        keepAwakeOffItem.isHidden = !presentation.showsStopAction

        keepAwakeActionItems.forEach { $0.isEnabled = !presentation.isPending }
        keepAwakeStatusItem.isEnabled = false
        keepAwakeStatusItem.title = presentation.statusText ?? ""
        keepAwakeStatusItem.isHidden = presentation.statusText == nil

        guard let button = statusItem.button else { return }
        button.image = NSImage(
            systemSymbolName: presentation.iconSymbol,
            accessibilityDescription: presentation.buttonToolTip
        )
        button.image?.isTemplate = true
        button.toolTip = presentation.buttonToolTip
    }

    private var keepAwakeActionItems: [NSMenuItem] {
        [keepAwakeIndefiniteItem] + dynamicKeepAwakeTimedItems + [keepAwakeOffItem]
    }

    private func rebuildKeepAwakeMenu() {
        for item in dynamicKeepAwakeTimedItems {
            menu.removeItem(item)
        }

        dynamicKeepAwakeTimedItems.removeAll()

        let insertIndex = menu.index(of: keepAwakeOffItem)
        guard insertIndex >= 0 else { return }

        let items = keepAwakeDurationStore.durations.map(makeKeepAwakeTimedMenuItem(for:))
        dynamicKeepAwakeTimedItems = items

        for (offset, item) in items.enumerated() {
            menu.insertItem(item, at: insertIndex + offset)
        }
    }

    private func makeKeepAwakeTimedMenuItem(for duration: ManagedKeepAwakeDuration) -> NSMenuItem {
        let item = NSMenuItem(
            title: duration.menuTitle,
            action: #selector(startKeepAwakeTimedDuration(_:)),
            keyEquivalent: ""
        )
        item.target = self
        item.representedObject = duration
        return item
    }

    private func keepAwakeTimedItem(matchingSeconds seconds: Int) -> NSMenuItem? {
        dynamicKeepAwakeTimedItems.first { item in
            (item.representedObject as? ManagedKeepAwakeDuration)?.durationSeconds == seconds
        }
    }

    private func forceTimedKeepAwakeItem(seconds: Int) -> NSMenuItem {
        guard let item = keepAwakeTimedItem(matchingSeconds: seconds) else {
            fatalError("Expected timed keep-awake item for \(seconds) seconds")
        }

        return item
    }

    private func rebuildWakeMenu() {
        for item in dynamicWakeItems {
            menu.removeItem(item)
        }

        dynamicWakeItems.removeAll()
        recentWakeItems = []
        allDevicesItem = nil
        wakeStatusItem = nil

        let isWakeDisabled = wolSession.isSending
        wolItem.isEnabled = !isWakeDisabled

        let wolIndex = menu.index(of: wolItem)
        let separatorIndex = menu.index(of: wakeQuitSeparatorItem)
        guard wolIndex >= 0, separatorIndex >= 0, wolIndex < separatorIndex else { return }

        var itemsBeforeWOL: [NSMenuItem] = []

        if !deviceLibrary.devices.isEmpty {
            let allDevicesItem = NSMenuItem(title: "快速 WOL", action: nil, keyEquivalent: "")
            let allDevicesMenu = NSMenu(title: "快速 WOL")
            allDevicesMenu.autoenablesItems = false

            for device in deviceLibrary.devices {
                let item = makeWakeMenuItem(for: device)
                item.isEnabled = !isWakeDisabled
                allDevicesMenu.addItem(item)
            }

            allDevicesItem.submenu = allDevicesMenu
            self.allDevicesItem = allDevicesItem
            itemsBeforeWOL.append(allDevicesItem)
        }

        let wakeStatusItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        wakeStatusItem.isEnabled = false
        self.wakeStatusItem = wakeStatusItem
        updateWakeStatusItem()

        dynamicWakeItems = itemsBeforeWOL + [wakeStatusItem]

        for (offset, item) in itemsBeforeWOL.enumerated() {
            menu.insertItem(item, at: wolIndex + offset)
        }

        menu.insertItem(wakeStatusItem, at: menu.index(of: manageDevicesItem))
    }

    private func refreshWakeMenuState() {
        updateWakeMenuEnabledState()
        updateWakeStatusItem()
    }

    private func updateWakeMenuEnabledState() {
        let isWakeDisabled = wolSession.isSending
        wolItem.isEnabled = !isWakeDisabled
        recentWakeItems.forEach { $0.isEnabled = !isWakeDisabled }
        allDevicesItem?.submenu?.items.forEach { $0.isEnabled = !isWakeDisabled }
    }

    private func updateWakeStatusItem() {
        guard let wakeStatusItem else { return }

        wakeStatusItem.isEnabled = false

        switch wolSession.sendState {
        case .sending:
            wakeStatusItem.title = WakeSendMessage.sending.text ?? ""
            wakeStatusItem.isHidden = false
        case .idle, .success, .failure:
            if let message = wolSession.lastCompletedWake?.message {
                wakeStatusItem.title = message
                wakeStatusItem.isHidden = false
            } else {
                wakeStatusItem.title = ""
                wakeStatusItem.isHidden = true
            }
        }
    }

    private func makeWakeMenuItem(for device: SavedDevice) -> NSMenuItem {
        let item = NSMenuItem(title: device.name, action: #selector(wakeSavedDevice(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = device.id
        item.attributedTitle = makeWakeMenuTitle(for: device)
        return item
    }

    private func makeWakeMenuTitle(for device: SavedDevice) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1

        let title = NSMutableAttributedString(
            string: device.name,
            attributes: [
                .font: NSFont.menuFont(ofSize: 0),
                .paragraphStyle: paragraphStyle,
            ]
        )
        title.append(
            NSAttributedString(
                string: "\n\(device.macAddress)",
                attributes: [
                    .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .paragraphStyle: paragraphStyle,
                ]
            )
        )
        return title
    }

    @objc private func startKeepAwakeIndefinite(_ sender: NSMenuItem) {
        keepAwakeSession.startIndefinite()
        renderKeepAwakePresentation()
    }

    @objc private func startKeepAwakeTimedDuration(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? ManagedKeepAwakeDuration else { return }
        keepAwakeSession.startTimed(duration)
        renderKeepAwakePresentation()
    }

    @objc private func stopKeepAwake(_ sender: NSMenuItem) {
        keepAwakeSession.stop()
        renderKeepAwakePresentation()
    }

    @objc private func openWOL() {
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { [weak self] in
            self?.onOpenWOL?()
        }
    }

    @objc private func openDeviceLibrary() {
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { [weak self] in
            self?.onOpenDeviceLibrary?()
        }
    }

    @objc private func openKeepAwakeDurationManagement() {
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { [weak self] in
            self?.onOpenKeepAwakeDurationManagement?()
        }
    }

    @objc private func wakeSavedDevice(_ sender: NSMenuItem) {
        guard let deviceID = sender.representedObject as? UUID else { return }
        wolSession.sendSavedDevice(id: deviceID)
    }

    @objc private func quitApp() {
        guard keepAwakeSession.confirmedMode != .off || keepAwakeSession.pendingAction != nil else {
            NSApp.terminate(nil)
            return
        }

        keepAwakeSession.stop {
            NSApp.terminate(nil)
        }
    }
}
