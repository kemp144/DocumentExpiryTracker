import XCTest
@testable import Document_Expiry_Tracker

final class FeatureGateTests: XCTestCase {
    func testFreeItemCap() {
        XCTAssertTrue(FeatureGate.canAddItem(existingItemCount: 4, isPro: false))
        XCTAssertFalse(FeatureGate.canAddItem(existingItemCount: 5, isPro: false))
        XCTAssertTrue(FeatureGate.canAddItem(existingItemCount: 50, isPro: true))
    }

    func testFreeSingleReminderRestriction() {
        XCTAssertTrue(FeatureGate.canUseReminderCount(1, isPro: false))
        XCTAssertFalse(FeatureGate.canUseReminderCount(2, isPro: false))
        XCTAssertTrue(FeatureGate.canUseReminderCount(5, isPro: true))
    }

    func testCurrencyAvailabilityExpandsForPro() {
        XCTAssertEqual(FeatureGate.availableCurrencies(isPro: false, locale: Locale(identifier: "en_US")), ["USD"])
        XCTAssertTrue(FeatureGate.availableCurrencies(isPro: true).contains("EUR"))
    }
}
