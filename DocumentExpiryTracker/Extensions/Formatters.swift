import Foundation

enum AppFormatters {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func currencyString(amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencyCode) \(String(format: "%.2f", amount))"
    }

    static func compactCurrencyString(amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? currencyString(amount: amount, currencyCode: currencyCode)
    }

    static func formatMultiCurrency(totals: [String: Double], compact: Bool = false) -> String {
        if totals.isEmpty {
            let defaultCurrency = Locale.current.currency?.identifier ?? "USD"
            return compact ? compactCurrencyString(amount: 0, currencyCode: defaultCurrency) : currencyString(amount: 0, currencyCode: defaultCurrency)
        }
        let sortedKeys = totals.keys.sorted()
        let parts = sortedKeys.map { code in
            compact ? compactCurrencyString(amount: totals[code]!, currencyCode: code) : currencyString(amount: totals[code]!, currencyCode: code)
        }
        return parts.joined(separator: " + ")
    }
}
