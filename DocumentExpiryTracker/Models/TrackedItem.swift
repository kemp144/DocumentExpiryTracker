import Foundation
import SwiftData

@Model
final class TrackedItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryRaw: String
    var provider: String
    var dueDate: Date
    var recurringIntervalRaw: String
    var amount: Double?
    var currencyCode: String
    var notesText: String
    var ownerName: String
    var reminderOffsetsRaw: String
    var archivedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: ItemCategory,
        provider: String = "",
        dueDate: Date,
        recurringInterval: RecurringInterval = .none,
        amount: Double? = nil,
        currencyCode: String = "USD",
        notesText: String = "",
        ownerName: String = "",
        reminders: [ReminderOffset] = [.sevenDays],
        archivedAt: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.categoryRaw = category.rawValue
        self.provider = provider
        self.dueDate = dueDate
        self.recurringIntervalRaw = recurringInterval.rawValue
        self.amount = amount
        self.currencyCode = currencyCode
        self.notesText = notesText
        self.ownerName = ownerName
        self.reminderOffsetsRaw = reminders.map(\.rawValue).sorted().map(String.init).joined(separator: ",")
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var category: ItemCategory {
        get { ItemCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var recurringInterval: RecurringInterval {
        get { RecurringInterval(rawValue: recurringIntervalRaw) ?? .none }
        set { recurringIntervalRaw = newValue.rawValue }
    }

    var reminders: [ReminderOffset] {
        get {
            reminderOffsetsRaw
                .split(separator: ",")
                .compactMap { Int($0) }
                .compactMap(ReminderOffset.init(rawValue:))
                .sorted { $0.rawValue < $1.rawValue }
        }
        set {
            reminderOffsetsRaw = newValue
                .map(\.rawValue)
                .sorted()
                .map(String.init)
                .joined(separator: ",")
        }
    }

    var isRecurring: Bool { recurringInterval != .none }
    var isArchived: Bool { archivedAt != nil }
}
