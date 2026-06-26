import Foundation
import Observation

@Observable
final class ClipboardStore {
    private(set) var items: [ClipboardItem] = []
    var maxItems: Int = 100

    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }

    func add(_ item: ClipboardItem) {
        if let last = items.first, last.content == item.content {
            return
        }

        items.removeAll { $0.content == item.content }
        items.insert(item, at: 0)

        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
    }

    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
    }

    func removeAt(_ index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    func clear() {
        items.removeAll()
    }

    func item(at index: Int) -> ClipboardItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    func filteredItems(searchText: String) -> [ClipboardItem] {
        if searchText.isEmpty { return items }
        return items.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
}
