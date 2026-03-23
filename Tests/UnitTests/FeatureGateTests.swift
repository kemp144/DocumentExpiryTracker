import XCTest
@testable import Document_Expiry_Tracker

final class FeatureGateTests: XCTestCase {

    // MARK: - Item Cap

    func testFreeUser_zeroItems_canAdd() {
        XCTAssertTrue(FeatureGate.canAddItem(existingItemCount: 0, isPro: false))
    }

    func testFreeUser_oneBeforeCap_canAdd() {
        XCTAssertTrue(FeatureGate.canAddItem(existingItemCount: 4, isPro: false))
    }

    func testFreeUser_atCap_cannotAdd() {
        XCTAssertFalse(FeatureGate.canAddItem(existingItemCount: 5, isPro: false))
    }

    func testFreeUser_overCap_cannotAdd() {
        XCTAssertFalse(FeatureGate.canAddItem(existingItemCount: 10, isPro: false))
    }

    func testProUser_atCap_canAdd() {
        XCTAssertTrue(FeatureGate.canAddItem(existingItemCount: 5, isPro: true))
    }

    func testProUser_manyItems_canAdd() {
        XCTAssertTrue(FeatureGate.canAddItem(existingItemCount: 1000, isPro: true))
    }

    // MARK: - Reminder Cap

    func testFreeUser_zeroReminders_allowed() {
        XCTAssertTrue(FeatureGate.canUseReminderCount(0, isPro: false))
    }

    func testFreeUser_oneReminder_allowed() {
        XCTAssertTrue(FeatureGate.canUseReminderCount(1, isPro: false))
    }

    func testFreeUser_twoReminders_blocked() {
        XCTAssertFalse(FeatureGate.canUseReminderCount(2, isPro: false))
    }

    func testProUser_allReminderOffsets_allowed() {
        XCTAssertTrue(FeatureGate.canUseReminderCount(ReminderOffset.allCases.count, isPro: true))
    }

    // MARK: - Currency Availability

    func testFreeUser_usLocale_getsUSD() {
        let result = FeatureGate.availableCurrencies(isPro: false, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(result, ["USD"])
    }

    func testFreeUser_deLocale_getsEUR() {
        let result = FeatureGate.availableCurrencies(isPro: false, locale: Locale(identifier: "de_DE"))
        XCTAssertEqual(result, ["EUR"])
    }

    func testProUser_getsMultipleCurrencies() {
        let result = FeatureGate.availableCurrencies(isPro: true)
        XCTAssertTrue(result.count > 1)
        XCTAssertTrue(result.contains("USD"))
        XCTAssertTrue(result.contains("EUR"))
        XCTAssertTrue(result.contains("GBP"))
    }

    // MARK: - Feature Gating

    func testAllPremiumFeatures_blockedForFreeUser() {
        for feature in PremiumFeature.allCases {
            XCTAssertFalse(FeatureGate.canUse(feature, isPro: false), "\(feature) should be blocked for free users")
        }
    }

    func testAllPremiumFeatures_allowedForProUser() {
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(FeatureGate.canUse(feature, isPro: true), "\(feature) should be allowed for pro users")
        }
    }

    // MARK: - Constants

    func testFreeItemLimit_isFive() {
        XCTAssertEqual(FeatureGate.freeItemLimit, 5)
    }

    func testFreeReminderLimit_isOne() {
        XCTAssertEqual(FeatureGate.freeReminderLimit, 1)
    }
}
