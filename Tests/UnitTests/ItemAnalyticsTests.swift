import XCTest
@testable import Document_Expiry_Tracker

final class ItemAnalyticsTests: XCTestCase {
    func testExpiredAndDueSoonGrouping() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let expired = TrackedItem(title: "Old Passport", category: .document, dueDate: Calendar.current.date(byAdding: .day, value: -1, to: now)!)
        let soon = TrackedItem(title: "Netflix", category: .subscription, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: now)!, recurringInterval: .monthly, amount: 12)
        let future = TrackedItem(title: "Warranty", category: .warranty, dueDate: Calendar.current.date(byAdding: .day, value: 70, to: now)!)
        let archived = TrackedItem(title: "Archived", category: .other, dueDate: now, archivedAt: now)

        XCTAssertEqual(ItemAnalytics.status(for: expired, now: now), .expired)
        XCTAssertEqual(ItemAnalytics.status(for: soon, now: now), .dueSoon)
        XCTAssertEqual(ItemAnalytics.status(for: archived, now: now), .archived)
        XCTAssertEqual(ItemAnalytics.expiredItems(from: [expired, soon, future, archived], now: now).count, 1)
        XCTAssertEqual(ItemAnalytics.dueSoonItems(from: [expired, soon, future, archived], now: now).count, 1)
    }

    func testRecurringTotalsExcludeOneTimeAndArchived() {
        let activeMonthly = TrackedItem(title: "Music", category: .subscription, dueDate: .now, recurringInterval: .monthly, amount: 10)
        let activeYearly = TrackedItem(title: "Insurance", category: .insurance, dueDate: .now, recurringInterval: .yearly, amount: 1200)
        let oneTime = TrackedItem(title: "Passport", category: .document, dueDate: .now, amount: 100)
        let archived = TrackedItem(title: "Old Plan", category: .subscription, dueDate: .now, recurringInterval: .monthly, amount: 99, archivedAt: .now)

        XCTAssertEqual(ItemAnalytics.monthlyRecurringTotal(from: [activeMonthly, activeYearly, oneTime, archived]), 10)
        XCTAssertEqual(ItemAnalytics.yearlyRecurringTotal(from: [activeMonthly, activeYearly, oneTime, archived]), 1200)
        XCTAssertEqual(ItemAnalytics.annualRecurringEstimate(from: [activeMonthly, activeYearly]), 1320)
    }

    func testDueInNextDaysCountsTodayThroughWindow() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let today = TrackedItem(title: "Today", category: .document, dueDate: now)
        let inSeven = TrackedItem(title: "In 7", category: .document, dueDate: Calendar.current.date(byAdding: .day, value: 7, to: now)!)
        let later = TrackedItem(title: "Later", category: .document, dueDate: Calendar.current.date(byAdding: .day, value: 20, to: now)!)

        XCTAssertEqual(ItemAnalytics.dueInNext(days: 7, items: [today, inSeven, later], now: now), 2)
        XCTAssertEqual(ItemAnalytics.dueInNext(days: 30, items: [today, inSeven, later], now: now), 3)
    }

    func testRecurringItemsRollForwardToNextOccurrence() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let oldMonthly = TrackedItem(
            title: "Netflix",
            category: .subscription,
            dueDate: Calendar.current.date(byAdding: .day, value: -40, to: now)!,
            recurringInterval: .monthly,
            amount: 15
        )

        let nextDueDate = ItemAnalytics.effectiveDueDate(for: oldMonthly, now: now)
        XCTAssertGreaterThanOrEqual(nextDueDate, Calendar.current.startOfDay(for: now))
        XCTAssertNotEqual(ItemAnalytics.status(for: oldMonthly, now: now), .expired)
    }
}
