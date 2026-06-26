import SwiftUI

struct ClipboardRowView: View {
    let item: ClipboardItem
    let index: Int
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            shortcutBadge
            contentPreview
            Spacer(minLength: 4)
            metadata
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button("Colar") { onSelect() }
            Button("Copiar") { PasteService.copyOnly(item) }
            Divider()
            Button("Remover", role: .destructive) { onDelete() }
        }
    }

    @ViewBuilder
    private var shortcutBadge: some View {
        if index < 9 {
            Text("\(index + 1)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .frame(width: 18, height: 18)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private var contentPreview: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.preview)
                .font(.callout)
                .lineLimit(2)
                .truncationMode(.tail)

            if item.content.count > 80 {
                Text("\(item.characterCount) caracteres")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var metadata: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(item.relativeTimestamp)
                .font(.caption2)
                .foregroundStyle(.tertiary)

            if let appName = item.sourceAppName {
                Text(appName)
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }
        }
    }
}
