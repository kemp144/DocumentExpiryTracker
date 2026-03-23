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
    var attachmentRecordsRaw: String
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
        attachments: [StoredAttachment] = [],
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
        self.attachmentRecordsRaw = Self.encodeAttachments(attachments)
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

    var attachments: [StoredAttachment] {
        get { Self.decodeAttachments(attachmentRecordsRaw) }
        set { attachmentRecordsRaw = Self.encodeAttachments(newValue) }
    }

    var isRecurring: Bool { recurringInterval != .none }
    var isArchived: Bool { archivedAt != nil }

    private static func decodeAttachments(_ rawValue: String) -> [StoredAttachment] {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([StoredAttachment].self, from: data)
        else {
            return []
        }
        return decoded.sorted { $0.createdAt < $1.createdAt }
    }

    private static func encodeAttachments(_ attachments: [StoredAttachment]) -> String {
        guard let data = try? JSONEncoder().encode(attachments),
              let value = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return value
    }
}
