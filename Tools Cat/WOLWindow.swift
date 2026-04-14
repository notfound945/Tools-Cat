import Cocoa
import SwiftUI

final class WOLWindow: NSWindowController, NSWindowDelegate {
    private let session: WOLSessionModel

    init(session: WOLSessionModel, deviceLibrary: SavedDeviceLibraryStore) {
        self.session = session
        let hosting = NSHostingView(rootView: WOLView(session: session, deviceLibrary: deviceLibrary))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 460, height: 268),
                              styleMask: [.titled, .closable],
                              backing: .buffered,
                              defer: false)
        window.center()
        window.title = "WOL 发送器"
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        window.collectionBehavior.insert(.moveToActiveSpace)
        super.init(window: window)
        window.delegate = self
        setupNotificationListener()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window = window else { return }
        session.handleWindowWillShow()
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
