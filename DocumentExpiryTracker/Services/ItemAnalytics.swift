import Foundation

enum ItemAnalytics {
    static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func effectiveDueDate(for item: TrackedItem, now: Date = .now, calendar: Calendar = .current) -> Date {
        guard item.isRecurring else { return item.dueDate }

        let today = startOfDay(now, calendar: calendar)
        var nextDate = item.dueDate

        while startOfDay(nextDate, calendar: calendar) < today {
            switch item.recurringInterval {
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
            case .yearly:
                nextDate = calendar.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            case .none:
                return item.dueDate
            }
        }

        return nextDate
    }

    static func daysUntilDue(for item: TrackedItem, now: Date = .now, calendar: Calendar = .current) -> Int {
        let today = startOfDay(now, calendar: calendar)
        let due = startOfDay(effectiveDueDate(for: item, now: now, calendar: calendar), calendar: calendar)
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

    static func actionLabel(for item: TrackedItem) -> String {
        if item.isRecurring || item.category == .subscription || item.category == .contract || item.category == .insurance {
            return "Renews"
        }
        return "Expires"
    }

    static func urgencyTitle(for item: TrackedItem, now: Date = .now, calendar: Calendar = .current) -> String {
        let label = actionLabel(for: item)
        let days = daysUntilDue(for: item, now: now, calendar: calendar)
        if days < 0 {
            return "\(label) overdue"
        }
        if days == 0 {
            return "\(label) today"
        }
        if days == 1 {
            return "\(label) tomorrow"
        }
        return "\(label) in \(days) days"
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
        .sorted { effectiveDueDate(for: $0, now: now) < effectiveDueDate(for: $1, now: now) }
    }

    static func nextDueItem(from items: [TrackedItem], now: Date = .now) -> TrackedItem? {
        upcomingWithinThirtyDays(from: items, now: now).first
    }

    static func criticalItem(from items: [TrackedItem], now: Date = .now) -> TrackedItem? {
        if let expired = expiredItems(from: items, now: now).sorted(by: { effectiveDueDate(for: $0, now: now) < effectiveDueDate(for: $1, now: now) }).first {
            return expired
        }
        if let urgent = dueSoonItems(from: items, now: now).sorted(by: { effectiveDueDate(for: $0, now: now) < effectiveDueDate(for: $1, now: now) }).first {
            return urgent
        }
        return activeItems(from: items).sorted { effectiveDueDate(for: $0, now: now) < effectiveDueDate(for: $1, now: now) }.first
    }

    static func monthlyRecurringItems(from items: [TrackedItem]) -> [TrackedItem] {
        activeItems(from: items).filter { $0.recurringInterval == .monthly && $0.amount != nil }
    }

    static func yearlyRecurringItems(from items: [TrackedItem]) -> [TrackedItem] {
        activeItems(from: items).filter { $0.recurringInterval == .yearly && $0.amount != nil }
    }

    static func recurringDueInNextThirtyDaysItems(from items: [TrackedItem], now: Date = .now) -> [TrackedItem] {
        activeItems(from: items)
            .filter { $0.isRecurring && $0.amount != nil }
            .filter {
                let days = daysUntilDue(for: $0, now: now)
                return days >= 0 && days <= 30
            }
    }

    static func monthlyRecurringTotal(from items: [TrackedItem]) -> [String: Double] {
        let active = monthlyRecurringItems(from: items)
        var totals: [String: Double] = [:]
        for item in active {
            totals[item.currencyCode, default: 0] += item.amount!
        }
        return totals
    }

    static func yearlyRecurringTotal(from items: [TrackedItem]) -> [String: Double] {
        let active = yearlyRecurringItems(from: items)
        var totals: [String: Double] = [:]
        for item in active {
            totals[item.currencyCode, default: 0] += item.amount!
        }
        return totals
    }

    static func annualRecurringEstimate(from items: [TrackedItem]) -> [String: Double] {
        var totals: [String: Double] = [:]
        for (currency, amount) in monthlyRecurringTotal(from: items) {
            totals[currency, default: 0] += amount * 12
        }
        for (currency, amount) in yearlyRecurringTotal(from: items) {
            totals[currency, default: 0] += amount
        }
        return totals
    }

    static func recurringDueInNextThirtyDaysTotal(from items: [TrackedItem], now: Date = .now) -> [String: Double] {
        let active = recurringDueInNextThirtyDaysItems(from: items, now: now)
        var totals: [String: Double] = [:]
        for item in active {
            totals[item.currencyCode, default: 0] += item.amount!
        }
        return totals
    }

    static func dueInNext(days: Int, items: [TrackedItem], now: Date = .now) -> Int {
        activeItems(from: items).filter {
            let delta = daysUntilDue(for: $0, now: now)
            return delta >= 0 && delta <= days
        }.count
    }

    static func renewalLoadThisMonth(from items: [TrackedItem], now: Date = .now, calendar: Calendar = .current) -> Int {
        let interval = calendar.dateInterval(of: .month, for: now)
        return activeItems(from: items).filter {
            guard let interval else { return false }
            let due = effectiveDueDate(for: $0, now: now, calendar: calendar)
            return interval.contains(due)
        }.count
    }

    static func expiringDocumentsCount(from items: [TrackedItem], now: Date = .now) -> Int {
        activeItems(from: items).filter {
            $0.category == .document && daysUntilDue(for: $0, now: now) <= 30
        }.count
    }

    static func highestRecurringCostItem(from items: [TrackedItem]) -> TrackedItem? {
        activeItems(from: items)
            .filter { $0.isRecurring }
            .max { ($0.amount ?? 0) < ($1.amount ?? 0) }
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
