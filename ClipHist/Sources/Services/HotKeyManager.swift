import AppKit
import Carbon

final class HotKeyManager {
    private let onToggle: () -> Void
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    fileprivate static var shared: HotKeyManager?

    init(onToggle: @escaping () -> Void) {
        self.onToggle = onToggle
    }

    func register() {
        unregister()
        HotKeyManager.shared = self

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyHandler,
            1,
            &eventType,
            nil,
            &eventHandler
        )
        guard status == noErr else { return }

        // Cmd+Shift+V: keyCode 0x09 = V
        let hotKeyID = EventHotKeyID(
            signature: OSType(0x434C4950), // "CLIP"
            id: 1
        )

        RegisterEventHotKey(
            UInt32(0x09),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    fileprivate func handleHotKey() {
        DispatchQueue.main.async { [weak self] in
            self?.onToggle()
        }
    }

    deinit {
        unregister()
        if HotKeyManager.shared === self {
            HotKeyManager.shared = nil
        }
    }
}

private func hotKeyHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    HotKeyManager.shared?.handleHotKey()
    return noErr
}
