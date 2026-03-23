import Foundation

enum RecurringInterval: String, CaseIterable, Codable, Identifiable {
    case none
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "None"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }

    var shortTitle: String {
        switch self {
        case .none: ""
        case .monthly: "mo"
        case .yearly: "yr"
        }
    }
}
