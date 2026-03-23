import Foundation

enum WidgetSnapshotStore {
    static let appGroupIdentifier = "group.com.expiryvault.shared"
    static let fileName = "widget-snapshot.json"
}

struct WidgetItemSnapshot: Codable, Identifiable {
    let id: UUID
    let title: String
    let categoryRaw: String
    let dueDate: Date
    let provider: String

    var category: ItemCategory {
        ItemCategory(rawValue: categoryRaw) ?? .other
    }
}

struct WidgetSnapshotPayload: Codable {
    let generatedAt: Date
    let isProUnlocked: Bool
    let items: [WidgetItemSnapshot]
}

enum WidgetCountdownFormatter {
    static func text(for dueDate: Date, now: Date = .now, calendar: Calendar = .current) -> String {
        let today = calendar.startOfDay(for: now)
        let due = calendar.startOfDay(for: dueDate)
        let delta = calendar.dateComponents([.day], from: today, to: due).day ?? 0
        if delta < 0 { return "Expired" }
        if delta == 0 { return "Due today" }
        if delta == 1 { return "Tomorrow" }
        return "In \(delta) days"
    }
}
