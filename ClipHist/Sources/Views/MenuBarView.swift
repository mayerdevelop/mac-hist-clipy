import SwiftUI

struct MenuBarView: View {
    let store: ClipboardStore
    let onShowHistory: () -> Void
    let onQuit: () -> Void

    var body: some View {
        Button("Mostrar Historico (⌘⇧V)") {
            onShowHistory()
        }

        Divider()

        if !store.isEmpty {
            Menu("Itens Recentes") {
                ForEach(Array(store.items.prefix(10).enumerated()), id: \.element.id) { _, item in
                    Button(item.preview) {
                        PasteService.copyOnly(item)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            PasteService.simulatePaste()
                        }
                    }
                }
            }

            Divider()

            Button("Limpar Historico") {
                store.clear()
            }

            Divider()
        }

        Button("Sair") {
            onQuit()
        }
        .keyboardShortcut("q")
    }
}
