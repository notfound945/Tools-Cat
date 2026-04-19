import Combine
import Cocoa
import SwiftUI

final class WOLWindow: NSWindowController, NSWindowDelegate {
    private let session: WOLSessionModel
    private let hosting: NSHostingView<WOLView>
    private let measurementHosting: NSHostingView<WOLView>
    private var cancellables = Set<AnyCancellable>()
    private let contentWidth: CGFloat = 480
    private let fallbackContentHeight: CGFloat = 240
    private let contentHeightPadding: CGFloat = 12
    private let resizeAnimationDuration: TimeInterval = 0.18
    private var settleResizeWorkItem: DispatchWorkItem?

    init(session: WOLSessionModel, deviceLibrary: SavedDeviceLibraryStore) {
        self.session = session
        let rootView = WOLView(session: session, deviceLibrary: deviceLibrary)
        self.hosting = NSHostingView(rootView: rootView)
        self.measurementHosting = NSHostingView(rootView: rootView)
        let contentSize = NSSize(width: contentWidth, height: fallbackContentHeight)
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: contentSize),
                              styleMask: [.titled, .closable],
                              backing: .buffered,
                              defer: false)
        window.center()
        window.title = "WOL 发送器"
        window.contentView = hosting
        window.setContentSize(contentSize)
        window.contentMinSize = NSSize(width: contentWidth, height: 1)
        window.isReleasedWhenClosed = false
        window.collectionBehavior.insert(.moveToActiveSpace)
        super.init(window: window)
        window.delegate = self
        setupNotificationListener()
        setupLayoutObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window = window else { return }
        session.handleWindowWillShow()
        resizeWindowToFitContent(animated: false)
        if window.isMiniaturized { window.deminiaturize(nil) }
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloseRequest),
            name: .WOLWindowRequestClose,
            object: nil
        )
    }

    private func setupLayoutObserver() {
        Publishers.Merge3(
            session.$inputMode.dropFirst().map { _ in () },
            session.$sendState.dropFirst().map { _ in () },
            session.$validation.dropFirst().map { _ in () }
        )
        .sink { [weak self] _ in
            self?.scheduleResizeWindowToFitContent()
        }
        .store(in: &cancellables)
    }

    private func scheduleResizeWindowToFitContent() {
        settleResizeWorkItem?.cancel()

        DispatchQueue.main.async { [weak self] in
            self?.resizeWindowToFitContent(animated: true)
        }

        let settleWorkItem = DispatchWorkItem { [weak self] in
            self?.resizeWindowToFitContent(animated: false)
        }
        settleResizeWorkItem = settleWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + resizeAnimationDuration + 0.02, execute: settleWorkItem)
    }

    private func resizeWindowToFitContent(animated: Bool) {
        guard let window = window else { return }

        let measurementHeight = max(window.contentLayoutRect.height, fallbackContentHeight, 1000)
        measurementHosting.setFrameSize(NSSize(width: contentWidth, height: measurementHeight))
        measurementHosting.layoutSubtreeIfNeeded()
        window.contentView?.layoutSubtreeIfNeeded()

        let targetContentHeight = max(ceil(measurementHosting.fittingSize.height + contentHeightPadding), 1)
        let targetContentRect = NSRect(origin: .zero, size: NSSize(width: contentWidth, height: targetContentHeight))
        let targetFrame = window.frameRect(forContentRect: targetContentRect)
        var nextFrame = window.frame

        guard abs(nextFrame.height - targetFrame.height) > 0.5 else { return }

        nextFrame.origin.y += nextFrame.height - targetFrame.height
        nextFrame.size = targetFrame.size

        let shouldAnimate = animated && window.isVisible
        guard shouldAnimate else {
            window.setFrame(nextFrame, display: true)
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = resizeAnimationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(nextFrame, display: true)
        } completionHandler: { [weak self] in
            self?.resizeWindowToFitContent(animated: false)
        }
    }

    @objc private func handleCloseRequest() {
        window?.close()
    }

    func windowWillClose(_ notification: Notification) {
        session.handleWindowWillClose()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension Notification.Name {
    static let WOLWindowRequestClose = Notification.Name("WOLWindowRequestClose")
}
