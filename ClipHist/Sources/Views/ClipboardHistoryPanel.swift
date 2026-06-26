import AppKit
import SwiftUI

final class ClipboardHistoryPanelController {
    private var panel: NSPanel?
    private let store: ClipboardStore
    private var isVisible = false
    private var panelDelegate: PanelDelegate?
    private var previousApp: NSRunningApplication?
    private var keyMonitor: Any?

    init(store: ClipboardStore) {
        self.store = store
    }

    func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        previousApp = NSWorkspace.shared.frontmostApplication

        if panel == nil {
            createPanel()
        }

        guard let panel else { return }

        positionPanel(panel)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        isVisible = true
        installKeyMonitor()
    }

    func hideAndPaste(_ item: ClipboardItem) {
        let appToRestore = previousApp

        removeKeyMonitor()
        panel?.orderOut(nil)
        isVisible = false

        PasteService.copyOnly(item)

        guard Accessibility.isTrusted else {
            appToRestore?.activate()
            Accessibility.showPermissionAlert()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            appToRestore?.activate()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                PasteService.simulatePaste()
            }
        }
    }

    func hidePanel() {
        removeKeyMonitor()
        panel?.orderOut(nil)
        isVisible = false

        if let app = previousApp {
            app.activate()
        }
    }

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.isVisible else { return event }

            if event.keyCode == 53 { // Esc
                self.hidePanel()
                return nil
            }

            guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty,
                  let chars = event.characters,
                  let digit = Int(chars),
                  digit >= 1, digit <= 9
            else { return event }

            let index = digit - 1
            guard let item = self.store.item(at: index) else { return event }
            self.hideAndPaste(item)
            return nil
        }
    }

    private func removeKeyMonitor() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }

    private func createPanel() {
        let contentView = ClipboardListView(store: store) { [weak self] item in
            if let item {
                self?.hideAndPaste(item)
            } else {
                self?.hidePanel()
            }
        }

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 380, height: 500)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 500),
            styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.animationBehavior = .utilityWindow
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isReleasedWhenClosed = false

        let delegate = PanelDelegate(onResignKey: { [weak self] in
            self?.isVisible = false
            self?.previousApp?.activate()
        })
        panel.delegate = delegate
        self.panelDelegate = delegate
        self.panel = panel
    }

    private func positionPanel(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }

        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size

        var x = mouseLocation.x - panelSize.width / 2
        var y = mouseLocation.y - panelSize.height / 2

        x = max(screenFrame.minX, min(x, screenFrame.maxX - panelSize.width))
        y = max(screenFrame.minY, min(y, screenFrame.maxY - panelSize.height))

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

private final class PanelDelegate: NSObject, NSWindowDelegate {
    let onResignKey: () -> Void

    init(onResignKey: @escaping () -> Void) {
        self.onResignKey = onResignKey
    }

    func windowDidResignKey(_ notification: Notification) {
        guard let panel = notification.object as? NSPanel else { return }
        panel.orderOut(nil)
        onResignKey()
    }
}
