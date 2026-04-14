import Cocoa
import SwiftUI

final class DeviceLibraryWindow: NSWindowController {
    private let session: DeviceLibrarySessionModel

    init(session: DeviceLibrarySessionModel) {
        self.session = session
        let hosting = NSHostingView(rootView: DeviceLibraryView(session: session))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = DeviceLibraryManagementPresentation.windowTitle
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        window.collectionBehavior.insert(.moveToActiveSpace)
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window = window else { return }

        session.reloadDevices()
        if window.isMiniaturized { window.deminiaturize(nil) }
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }
}
