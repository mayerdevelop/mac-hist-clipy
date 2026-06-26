import Foundation

struct ClipboardItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let content: String
    let timestamp: Date
    let sourceAppName: String?
    let sourceAppBundleID: String?

    init(
        id: UUID = UUID(),
        content: String,
        timestamp: Date = Date(),
        sourceAppName: String? = nil,
        sourceAppBundleID: String? = nil
    ) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.sourceAppName = sourceAppName
        self.sourceAppBundleID = sourceAppBundleID
    }

    var preview: String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 80 {
            return trimmed
        }
        return String(trimmed.prefix(80)) + "..."
    }

    var characterCount: Int {
        content.count
    }

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
