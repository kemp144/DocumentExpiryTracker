import Foundation

struct QuickTemplate: Identifiable, Hashable {
    let title: String
    let category: ItemCategory
    let provider: String
    let recurringInterval: RecurringInterval
    let defaultReminders: Set<ReminderOffset>

    var id: String { title }

    static let all: [QuickTemplate] = [
        QuickTemplate(title: "Passport", category: .document, provider: "", recurringInterval: .none, defaultReminders: [.thirtyDays, .sevenDays]),
        QuickTemplate(title: "ID Card", category: .document, provider: "", recurringInterval: .none, defaultReminders: [.thirtyDays, .sevenDays]),
        QuickTemplate(title: "Driver License", category: .document, provider: "", recurringInterval: .none, defaultReminders: [.thirtyDays, .sevenDays]),
        QuickTemplate(title: "Health Insurance", category: .insurance, provider: "", recurringInterval: .yearly, defaultReminders: [.thirtyDays, .sevenDays]),
        QuickTemplate(title: "Car Insurance", category: .insurance, provider: "", recurringInterval: .yearly, defaultReminders: [.thirtyDays, .sevenDays]),
        QuickTemplate(title: "Netflix", category: .subscription, provider: "Netflix", recurringInterval: .monthly, defaultReminders: [.oneDay]),
        QuickTemplate(title: "Spotify", category: .subscription, provider: "Spotify", recurringInterval: .monthly, defaultReminders: [.oneDay]),
        QuickTemplate(title: "Gym Membership", category: .subscription, provider: "", recurringInterval: .monthly, defaultReminders: [.oneDay]),
        QuickTemplate(title: "Internet Contract", category: .contract, provider: "", recurringInterval: .monthly, defaultReminders: [.threeDays]),
        QuickTemplate(title: "Apartment Lease", category: .contract, provider: "", recurringInterval: .yearly, defaultReminders: [.thirtyDays]),
        QuickTemplate(title: "Appliance Warranty", category: .warranty, provider: "", recurringInterval: .none, defaultReminders: [.thirtyDays, .sevenDays])
    ]
}
