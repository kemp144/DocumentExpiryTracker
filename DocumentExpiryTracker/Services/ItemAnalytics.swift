import Foundation

enum ItemAnalytics {
    static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func daysUntilDue(for item: TrackedItem, now: Date = .now, calendar: Calendar = .current) -> Int {
        let today = startOfDay(now, calendar: calendar)
        let due = startOfDay(item.dueDate, calendar: calendar)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    static func status(for item: TrackedItem, now: Date = .now, calendar: Calendar = .current) -> ItemStatus {
        if item.isArchived { return .archived }
        let days = daysUntilDue(for: item, now: now, calendar: calendar)
        if days < 0 { return .expired }
        if days == 0 { return .dueToday }
        if days <= 14 { return .dueSoon }
        if days <= 30 { return .upcoming }
        return .active
    }

    static func countdownText(for item: TrackedItem, now: Date = .now, calendar: Calendar = .current) -> String {
        let days = daysUntilDue(for: item, now: now, calendar: calendar)
        if item.isArchived { return "archived" }
        if days < 0 {
            let expiredDays = abs(days)
            return expiredDays == 1 ? "expired 1 day ago" : "expired \(expiredDays) days ago"
        }
        if days == 0 { return "due today" }
        if days == 1 { return "due tomorrow" }
        if days <= 30 { return "in \(days) days" }
        let months = max(1, Int(round(Double(days) / 30)))
        return months == 1 ? "in 1 month" : "in \(months) months"
    }

    static func activeItems(from items: [TrackedItem]) -> [TrackedItem] {
        items.filter { !$0.isArchived }
    }

    static func expiredItems(from items: [TrackedItem], now: Date = .now) -> [TrackedItem] {
        activeItems(from: items).filter { status(for: $0, now: now) == .expired }
    }

    static func dueSoonItems(from items: [TrackedItem], now: Date = .now) -> [TrackedItem] {
        activeItems(from: items).filter {
            let status = status(for: $0, now: now)
            return status == .dueToday || status == .dueSoon
        }
    }

    static func upcomingWithinThirtyDays(from items: [TrackedItem], now: Date = .now) -> [TrackedItem] {
        activeItems(from: items).filter {
            let days = daysUntilDue(for: $0, now: now)
            return days >= 0 && days <= 30
        }
        .sorted { $0.dueDate < $1.dueDate }
    }

    static func nextDueItem(from items: [TrackedItem], now: Date = .now) -> TrackedItem? {
        upcomingWithinThirtyDays(from: items, now: now).first
    }

    static func monthlyRecurringTotal(from items: [TrackedItem]) -> Double {
        activeItems(from: items)
            .filter { $0.recurringInterval == .monthly }
            .compactMap(\.amount)
            .reduce(0, +)
    }

    static func yearlyRecurringTotal(from items: [TrackedItem]) -> Double {
        activeItems(from: items)
            .filter { $0.recurringInterval == .yearly }
            .compactMap(\.amount)
            .reduce(0, +)
    }

    static func annualRecurringEstimate(from items: [TrackedItem]) -> Double {
        monthlyRecurringTotal(from: items) * 12 + yearlyRecurringTotal(from: items)
    }

    static func dueInNext(days: Int, items: [TrackedItem], now: Date = .now) -> Int {
        activeItems(from: items).filter {
            let delta = daysUntilDue(for: $0, now: now)
            return delta >= 0 && delta <= days
        }.count
    }

    static func categoryBreakdown(from items: [TrackedItem]) -> [(ItemCategory, Int)] {
        let grouped = Dictionary(grouping: activeItems(from: items), by: \.category)
        return ItemCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items.count)
        }
    }

    static func sort(items: [TrackedItem], by option: ItemSortOption) -> [TrackedItem] {
        switch option {
        case .soonest:
            items.sorted { $0.dueDate < $1.dueDate }
        case .latest:
            items.sorted { $0.dueDate > $1.dueDate }
        case .title:
            items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .recentlyUpdated:
            items.sorted { $0.updatedAt > $1.updatedAt }
        }
    }
}
