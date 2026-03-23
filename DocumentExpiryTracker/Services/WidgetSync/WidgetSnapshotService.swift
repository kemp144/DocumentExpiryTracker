import Foundation
import SwiftData
import WidgetKit

enum WidgetSnapshotService {
    static func sync(context: ModelContext, isProUnlocked: Bool) {
        let descriptor = FetchDescriptor<TrackedItem>(
            sortBy: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]
        )

        guard let items = try? context.fetch(descriptor) else { return }
        let payload = WidgetSnapshotPayload(
            generatedAt: .now,
            isProUnlocked: isProUnlocked,
            items: items
                .filter { !$0.isArchived }
                .map {
                    WidgetItemSnapshot(
                        id: $0.id,
                        title: $0.title,
                        categoryRaw: $0.category.rawValue,
                        dueDate: ItemAnalytics.effectiveDueDate(for: $0),
                        provider: $0.provider,
                        recurringLabel: $0.isRecurring ? $0.recurringInterval.title : nil,
                        monthlyAmount: $0.recurringInterval == .monthly ? $0.amount : nil
                    )
                }
                .sorted { $0.dueDate < $1.dueDate },
            dueSoonCount: ItemAnalytics.dueSoonItems(from: items).count,
            monthlyRecurringTotal: ItemAnalytics.monthlyRecurringTotal(from: items)
        )

        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetSnapshotStore.appGroupIdentifier) else {
            return
        }

        let fileURL = containerURL.appendingPathComponent(WidgetSnapshotStore.fileName)
        do {
            let data = try JSONEncoder().encode(payload)
            try data.write(to: fileURL, options: [.atomic])
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            return
        }
    }
}
