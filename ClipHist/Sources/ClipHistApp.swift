import SwiftUI

@main
struct ClipHistApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                store: appDelegate.store,
                onShowHistory: { appDelegate.panelController.togglePanel() },
                onQuit: { NSApplication.shared.terminate(nil) }
            )
        } label: {
            Image(systemName: "clipboard")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = ClipboardStore()
    private(set) lazy var panelController = ClipboardHistoryPanelController(store: store)
    private var clipboardMonitor: ClipboardMonitor?
    private var hotKeyManager: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        clipboardMonitor = ClipboardMonitor(store: store)
        clipboardMonitor?.start()

        hotKeyManager = HotKeyManager { [weak self] in
            self?.panelController.togglePanel()
        }
        hotKeyManager?.register()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !Accessibility.isTrusted {
                Accessibility.showPermissionAlert()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor?.stop()
        hotKeyManager?.unregister()
    }
}
