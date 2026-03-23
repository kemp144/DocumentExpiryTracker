import Foundation

enum ReminderOffset: Int, CaseIterable, Codable, Identifiable {
    case sameDay = 0
    case oneDay = 1
    case threeDays = 3
    case sevenDays = 7
    case thirtyDays = 30

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .sameDay: "Same day"
        case .oneDay: "1 day before"
        case .threeDays: "3 days before"
        case .sevenDays: "7 days before"
        case .thirtyDays: "30 days before"
        }
    }
}
