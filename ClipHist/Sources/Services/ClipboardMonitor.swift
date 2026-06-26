import AppKit
import Foundation

final class ClipboardMonitor {
    private let store: ClipboardStore
    private var timer: Timer?
    private var lastChangeCount: Int

    private let pollInterval: TimeInterval = 0.5

    init(store: ClipboardStore) {
        self.store = store
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(
            withTimeInterval: pollInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkForChanges()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkForChanges() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard let content = pasteboard.string(forType: .string),
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        let frontApp = NSWorkspace.shared.frontmostApplication
        let item = ClipboardItem(
            content: content,
            sourceAppName: frontApp?.localizedName,
            sourceAppBundleID: frontApp?.bundleIdentifier
        )

        DispatchQueue.main.async { [weak self] in
            self?.store.add(item)
        }
    }

    deinit {
        stop()
    }
}
