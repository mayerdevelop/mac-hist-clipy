import SwiftUI

struct ClipboardListView: View {
    let store: ClipboardStore
    // nil = dismiss only, non-nil = paste this item
    let onAction: (ClipboardItem?) -> Void

    @State private var searchText = ""
    @State private var selectedID: UUID?

    private var filteredItems: [ClipboardItem] {
        store.filteredItems(searchText: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchField
            Divider()
            listContent
            footerView
        }
        .frame(width: 380, height: 500)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onExitCommand {
            onAction(nil)
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "clipboard")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Historico da Area de Transferencia")
                .font(.headline)
            Spacer()
            Text("\(store.count) itens")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.caption)
            TextField("Buscar...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.body)
        }
        .padding(8)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var listContent: some View {
        if filteredItems.isEmpty {
            emptyState
        } else {
            ScrollViewReader { proxy in
                List(selection: $selectedID) {
                    ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                        ClipboardRowView(
                            item: item,
                            index: index,
                            onSelect: { onAction(item) },
                            onDelete: { store.remove(item) }
                        )
                        .tag(item.id)
                        .id(item.id)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clipboard")
                .font(.system(size: 40))
                .foregroundStyle(.quaternary)
            Text(searchText.isEmpty
                ? "Nenhum item copiado ainda"
                : "Nenhum resultado encontrado")
                .font(.callout)
                .foregroundStyle(.secondary)
            if searchText.isEmpty {
                Text("Copie algo com Cmd+C para comecar")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var footerView: some View {
        HStack {
            Text("⌘⇧V para abrir")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Spacer()
            if !store.isEmpty {
                Button("Limpar Tudo") {
                    store.clear()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.red.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
