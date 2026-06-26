import AppKit
import ApplicationServices

enum Accessibility {
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    static func requestIfNeeded() {
        guard !isTrusted else { return }

        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    static func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Permissao de Acessibilidade Necessaria"
        alert.informativeText = """
            Para colar automaticamente ao selecionar um item, o ClipHist precisa \
            de permissao de Acessibilidade.

            Clique em "Abrir Preferencias" e habilite o ClipHist na lista.

            Depois de habilitar, reinicie o ClipHist.
            """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Abrir Preferencias")
        alert.addButton(withTitle: "Cancelar")

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }
}
