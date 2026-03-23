import Foundation

enum ItemCategory: String, CaseIterable, Codable, Identifiable {
    case document
    case subscription
    case contract
    case warranty
    case insurance
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .document: "Document"
        case .subscription: "Subscription"
        case .contract: "Contract"
        case .warranty: "Warranty"
        case .insurance: "Insurance"
        case .other: "Other"
        }
    }

    var pluralTitle: String {
        switch self {
        case .document: "Documents"
        case .subscription: "Subscriptions"
        case .contract: "Contracts"
        case .warranty: "Warranties"
        case .insurance: "Insurance"
        case .other: "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .document: "doc.text.fill"
        case .subscription: "creditcard.fill"
        case .contract: "doc.badge.gearshape"
        case .warranty: "shippingbox.fill"
        case .insurance: "shield.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}
