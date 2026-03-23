import Foundation

enum FeatureGate {
    static let freeItemLimit = 5

    static func canAddItem(existingItemCount: Int, isPro: Bool) -> Bool {
        isPro || existingItemCount < freeItemLimit
    }

    static func canUseReminderCount(_ count: Int, isPro: Bool) -> Bool {
        isPro || count <= 1
    }

    static func availableCurrencies(isPro: Bool, locale: Locale = .current) -> [String] {
        let localeCurrency = locale.currency?.identifier ?? "USD"
        let all = ["USD", "EUR", "GBP", "CHF", "CAD", "AUD", "JPY"]
        return isPro ? all : [localeCurrency]
    }
}
