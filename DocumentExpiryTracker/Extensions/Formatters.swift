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
        formatter.locale = canonicalLocale(for: currencyCode)
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencyCode) \(String(format: "%.2f", amount))"
    }

    static func compactCurrencyString(amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = canonicalLocale(for: currencyCode)
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

    // Use a canonical locale per currency so formatting always looks natural
    // (e.g. USD always shows "$9.99", EUR always shows "9,99 €", regardless of device locale).
    private static func canonicalLocale(for currencyCode: String) -> Locale {
        switch currencyCode {
        case "USD": return Locale(identifier: "en_US")
        case "EUR": return Locale(identifier: "fr_FR")
        case "GBP": return Locale(identifier: "en_GB")
        case "CHF": return Locale(identifier: "de_CH")
        case "CAD": return Locale(identifier: "en_CA")
        case "AUD": return Locale(identifier: "en_AU")
        case "JPY": return Locale(identifier: "ja_JP")
        default:    return Locale.current
        }
    }
}
