import Foundation

enum ItemStatus: String, CaseIterable, Identifiable {
    case expired
    case dueToday
    case dueSoon
    case upcoming
    case active
    case archived

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expired: "Expired"
        case .dueToday: "Due Today"
        case .dueSoon: "Due Soon"
        case .upcoming: "Upcoming"
        case .active: "Active"
        case .archived: "Archived"
        }
    }
}
