import XCTest
@testable import Document_Expiry_Tracker

final class FormatterTests: XCTestCase {

    // MARK: - Currency String

    func testCurrencyString_USD() {
        let result = AppFormatters.currencyString(amount: 9.99, currencyCode: "USD")
        XCTAssertTrue(result.contains("9.99") || result.contains("9,99"), "Should contain amount: \(result)")
        XCTAssertFalse(result.isEmpty)
    }

    func testCurrencyString_EUR() {
        let result = AppFormatters.currencyString(amount: 9.99, currencyCode: "EUR")
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("9") && result.contains("99"))
    }

    func testCurrencyString_zero() {
        let result = AppFormatters.currencyString(amount: 0, currencyCode: "USD")
        XCTAssertFalse(result.isEmpty)
    }

    func testCurrencyString_largeAmount() {
        let result = AppFormatters.currencyString(amount: 1_234_567.89, currencyCode: "USD")
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - Compact Currency String

    func testCompactCurrencyString_noDecimals() {
        let full = AppFormatters.currencyString(amount: 15.99, currencyCode: "USD")
        let compact = AppFormatters.compactCurrencyString(amount: 15.99, currencyCode: "USD")
        XCTAssertTrue(compact.count <= full.count, "Compact should be same or shorter than full")
    }

    // MARK: - Multi-Currency Formatting

    func testFormatMultiCurrency_empty_showsZero() {
        let result = AppFormatters.formatMultiCurrency(totals: [:])
        XCTAssertFalse(result.isEmpty)
    }

    func testFormatMultiCurrency_singleCurrency() {
        let result = AppFormatters.formatMultiCurrency(totals: ["USD": 29.99])
        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(result.contains("+"), "Single currency should not have + separator")
    }

    func testFormatMultiCurrency_multipleCurrencies_hasSeparator() {
        let result = AppFormatters.formatMultiCurrency(totals: ["USD": 10.0, "EUR": 9.0])
        XCTAssertTrue(result.contains("+"), "Multiple currencies should be joined with +")
    }

    func testFormatMultiCurrency_compact_noDecimals() {
        let full = AppFormatters.formatMultiCurrency(totals: ["USD": 15.99], compact: false)
        let compact = AppFormatters.formatMultiCurrency(totals: ["USD": 15.99], compact: true)
        XCTAssertTrue(compact.count <= full.count)
    }

    // MARK: - Date Formatter

    func testShortDate_isNotEmpty() {
        let result = AppFormatters.shortDate.string(from: Date())
        XCTAssertFalse(result.isEmpty)
    }

    func testShortDate_containsYear() {
        let result = AppFormatters.shortDate.string(from: Date(timeIntervalSince1970: 1_700_000_000))
        // Date is around Nov 2023 - should contain year
        XCTAssertTrue(result.contains("2023"), "Expected year 2023 in: \(result)")
    }
}
