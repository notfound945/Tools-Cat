import Cocoa
import SwiftUI

final class KeepAwakeDurationManagementWindow: NSWindowController {
    private let session: KeepAwakeDurationManagementSessionModel

    init(session: KeepAwakeDurationManagementSessionModel) {
        self.session = session
        let hosting = NSHostingView(rootView: KeepAwakeDurationManagementView(session: session))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = KeepAwakeDurationManagementPresentation.windowTitle
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

        session.reloadDurations()
        if window.isMiniaturized { window.deminiaturize(nil) }
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }
}
