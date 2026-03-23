import Foundation

enum ItemSortOption: String, CaseIterable, Identifiable {
    case soonest
    case latest
    case title
    case recentlyUpdated

    var id: String { rawValue }

    var title: String {
        switch self {
        case .soonest: "Due Soonest"
        case .latest: "Due Latest"
        case .title: "Title"
        case .recentlyUpdated: "Recently Updated"
        }
    }
}
