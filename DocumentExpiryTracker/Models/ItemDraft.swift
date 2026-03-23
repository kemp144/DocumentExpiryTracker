import Foundation

struct ItemDraft {
    var title = ""
    var category: ItemCategory = .document
    var provider = ""
    var dueDate = Calendar.current.startOfDay(for: .now)
    var recurringInterval: RecurringInterval = .none
    var amountText = ""
    var currencyCode = Locale.current.currency?.identifier ?? "USD"
    var notes = ""
    var owner = ""
    var isArchived = false
    var reminders: Set<ReminderOffset> = [.sevenDays]

    init() {}

    init(item: TrackedItem) {
        title = item.title
        category = item.category
        provider = item.provider
        dueDate = item.dueDate
        recurringInterval = item.recurringInterval
        amountText = item.amount.map { String(format: "%.2f", $0) } ?? ""
        currencyCode = item.currencyCode
        notes = item.notesText
        owner = item.ownerName
        isArchived = item.isArchived
        reminders = Set(item.reminders)
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedAmount: Double? {
        let text = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        return Double(text)
    }

    var isValid: Bool {
        guard !trimmedTitle.isEmpty else { return false }
        guard recurringInterval == .none || recurringInterval == .monthly || recurringInterval == .yearly else { return false }
        if let amount = normalizedAmount, amount < 0 { return false }
        return true
    }

    var validationMessage: String? {
        if trimmedTitle.isEmpty { return "Title is required." }
        if recurringInterval != .none && recurringInterval != .monthly && recurringInterval != .yearly {
            return "Recurring items must be monthly or yearly."
        }
        if let amount = normalizedAmount, amount < 0 {
            return "Amount cannot be negative."
        }
        return nil
    }

    func makeItem() -> TrackedItem {
        TrackedItem(
            title: trimmedTitle,
            category: category,
            provider: provider.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate,
            recurringInterval: recurringInterval,
            amount: normalizedAmount,
            currencyCode: currencyCode,
            notesText: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            ownerName: owner.trimmingCharacters(in: .whitespacesAndNewlines),
            reminders: reminders.sorted { $0.rawValue < $1.rawValue }
        )
    }

    func apply(to item: TrackedItem) {
        item.title = trimmedTitle
        item.category = category
        item.provider = provider.trimmingCharacters(in: .whitespacesAndNewlines)
        item.dueDate = dueDate
        item.recurringInterval = recurringInterval
        item.amount = normalizedAmount
        item.currencyCode = currencyCode
        item.notesText = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        item.ownerName = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        item.reminders = reminders.sorted { $0.rawValue < $1.rawValue }
        item.archivedAt = isArchived ? (item.archivedAt ?? .now) : nil
        item.updatedAt = .now
    }
}
