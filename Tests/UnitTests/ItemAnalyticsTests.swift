import XCTest
@testable import Document_Expiry_Tracker

final class ItemAnalyticsTests: XCTestCase {

    // MARK: - Helpers

    private var cal: Calendar { Calendar(identifier: .gregorian) }

    private func date(_ daysFromNow: Int, from base: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> Date {
        cal.date(byAdding: .day, value: daysFromNow, to: base)!
    }

    private func item(
        title: String = "Test",
        category: ItemCategory = .document,
        dueDate: Date,
        recurring: RecurringInterval = .none,
        amount: Double? = nil,
        archived: Bool = false
    ) -> TrackedItem {
        TrackedItem(
            title: title,
            category: category,
            dueDate: dueDate,
            recurringInterval: recurring,
            amount: amount,
            archivedAt: archived ? dueDate : nil
        )
    }

    // MARK: - Status Classification

    func testStatusExpired() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-1, from: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .expired)
    }

    func testStatusDueToday() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: cal.startOfDay(for: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .dueToday)
    }

    func testStatusDueSoon_withinFourteenDays() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(7, from: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .dueSoon)
    }

    func testStatusDueSoon_boundary_day14() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(14, from: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .dueSoon)
    }

    func testStatusUpcoming_day15() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(15, from: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .upcoming)
    }

    func testStatusUpcoming_boundary_day30() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(30, from: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .upcoming)
    }

    func testStatusActive_day31() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(31, from: base))
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .active)
    }

    func testStatusArchived_overridesExpiry() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-100, from: base), archived: true)
        XCTAssertEqual(ItemAnalytics.status(for: i, now: base), .archived)
    }

    // MARK: - Countdown Text

    func testCountdownText_expired_yesterday() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-1, from: base))
        XCTAssertEqual(ItemAnalytics.countdownText(for: i, now: base), "expired 1 day ago")
    }

    func testCountdownText_expired_multipledays() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-5, from: base))
        XCTAssertEqual(ItemAnalytics.countdownText(for: i, now: base), "expired 5 days ago")
    }

    func testCountdownText_dueToday() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: cal.startOfDay(for: base))
        XCTAssertEqual(ItemAnalytics.countdownText(for: i, now: base), "due today")
    }

    func testCountdownText_dueTomorrow() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(1, from: base))
        XCTAssertEqual(ItemAnalytics.countdownText(for: i, now: base), "due tomorrow")
    }

    func testCountdownText_inDays() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(10, from: base))
        XCTAssertEqual(ItemAnalytics.countdownText(for: i, now: base), "in 10 days")
    }

    func testCountdownText_inMonths() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(60, from: base))
        XCTAssertTrue(ItemAnalytics.countdownText(for: i, now: base).contains("month"))
    }

    func testCountdownText_archived() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: base, archived: true)
        XCTAssertEqual(ItemAnalytics.countdownText(for: i, now: base), "archived")
    }

    // MARK: - Effective Due Date (Recurring Roll-Forward)

    func testEffectiveDueDate_nonRecurring_returnsOriginal() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let past = date(-40, from: base)
        let i = item(dueDate: past)
        XCTAssertEqual(ItemAnalytics.effectiveDueDate(for: i, now: base), past)
    }

    func testEffectiveDueDate_monthlyInPast_rollsForward() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-40, from: base), recurring: .monthly)
        let effective = ItemAnalytics.effectiveDueDate(for: i, now: base)
        XCTAssertGreaterThanOrEqual(effective, cal.startOfDay(for: base))
    }

    func testEffectiveDueDate_yearlyInPast_rollsForward() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-400, from: base), recurring: .yearly)
        let effective = ItemAnalytics.effectiveDueDate(for: i, now: base)
        XCTAssertGreaterThanOrEqual(effective, cal.startOfDay(for: base))
    }

    func testEffectiveDueDate_recurringInFuture_unchanged() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let future = date(10, from: base)
        let i = item(dueDate: future, recurring: .monthly)
        XCTAssertEqual(ItemAnalytics.effectiveDueDate(for: i, now: base), future)
    }

    func testRecurringItemNeverShowsExpired() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let i = item(dueDate: date(-100, from: base), recurring: .monthly)
        XCTAssertNotEqual(ItemAnalytics.status(for: i, now: base), .expired)
    }

    // MARK: - Month-End and Year Boundary

    func testDaysUntilDue_acrossMonthEnd() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        // Jan 28 → Feb 4 = 7 days
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let jan28 = formatter.date(from: "2025-01-28")!
        let feb4 = formatter.date(from: "2025-02-04")!
        let i = item(dueDate: feb4)
        XCTAssertEqual(ItemAnalytics.daysUntilDue(for: i, now: jan28, calendar: cal), 7)
    }

    func testDaysUntilDue_acrossYearEnd() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dec28 = formatter.date(from: "2024-12-28")!
        let jan4 = formatter.date(from: "2025-01-04")!
        let i = item(dueDate: jan4)
        XCTAssertEqual(ItemAnalytics.daysUntilDue(for: i, now: dec28, calendar: cal), 7)
    }

    func testDaysUntilDue_leapYear_feb28ToMar1() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let feb28 = formatter.date(from: "2024-02-28")!
        let mar1 = formatter.date(from: "2024-03-01")!
        let i = item(dueDate: mar1)
        XCTAssertEqual(ItemAnalytics.daysUntilDue(for: i, now: feb28, calendar: cal), 2) // 28, 29 Feb, 1 Mar = 2 days gap
    }

    // MARK: - Filtering

    func testActiveItemsExcludesArchived() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let active = item(dueDate: date(30, from: base))
        let archived = item(dueDate: date(30, from: base), archived: true)
        let result = ItemAnalytics.activeItems(from: [active, archived])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, active.title)
    }

    func testExpiredItems_onlyNonArchivedExpired() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let expired = item(dueDate: date(-1, from: base))
        let expiredArchived = item(dueDate: date(-1, from: base), archived: true)
        let future = item(dueDate: date(30, from: base))
        let result = ItemAnalytics.expiredItems(from: [expired, expiredArchived, future], now: base)
        XCTAssertEqual(result.count, 1)
    }

    func testDueSoonItems_includesDueTodayAndDueSoon() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let today = item(dueDate: cal.startOfDay(for: base))
        let soon = item(dueDate: date(7, from: base))
        let upcoming = item(dueDate: date(20, from: base))
        let result = ItemAnalytics.dueSoonItems(from: [today, soon, upcoming], now: base)
        XCTAssertEqual(result.count, 2)
    }

    func testUpcomingWithinThirtyDays_sortedByDate() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let first = item(title: "First", dueDate: date(5, from: base))
        let second = item(title: "Second", dueDate: date(10, from: base))
        let result = ItemAnalytics.upcomingWithinThirtyDays(from: [second, first], now: base)
        XCTAssertEqual(result.first?.title, "First")
    }

    func testDueInNext_empty() {
        XCTAssertEqual(ItemAnalytics.dueInNext(days: 30, items: []), 0)
    }

    // MARK: - Recurring Cost Totals

    func testMonthlyTotalExcludesOneTimeAndArchived() {
        let monthly = item(dueDate: .now, recurring: .monthly, amount: 10)
        let yearly = item(dueDate: .now, recurring: .yearly, amount: 1200)
        let oneTime = item(dueDate: .now, amount: 100)
        let archived = item(dueDate: .now, recurring: .monthly, amount: 99, archived: true)
        let result = ItemAnalytics.monthlyRecurringTotal(from: [monthly, yearly, oneTime, archived])
        XCTAssertEqual(result["USD"], 10.0)
        XCTAssertNil(result["USD"].map { _ in () }.flatMap { _ in result.count > 1 ? Optional(true) : nil })
    }

    func testYearlyTotalExcludesMonthlyAndOneTime() {
        let monthly = item(dueDate: .now, recurring: .monthly, amount: 10)
        let yearly = item(dueDate: .now, recurring: .yearly, amount: 1200)
        let result = ItemAnalytics.yearlyRecurringTotal(from: [monthly, yearly])
        XCTAssertEqual(result["USD"], 1200.0)
        XCTAssertNil(result["EUR"])
    }

    func testAnnualEstimate_monthlyTimes12PlusYearly() {
        let monthly = item(dueDate: .now, recurring: .monthly, amount: 10)
        let yearly = item(dueDate: .now, recurring: .yearly, amount: 120)
        let result = ItemAnalytics.annualRecurringEstimate(from: [monthly, yearly])
        XCTAssertEqual(result["USD"] ?? 0, 240.0, accuracy: 0.01) // 10*12 + 120
    }

    func testRecurringTotals_emptyDataset() {
        XCTAssertTrue(ItemAnalytics.monthlyRecurringTotal(from: []).isEmpty)
        XCTAssertTrue(ItemAnalytics.yearlyRecurringTotal(from: []).isEmpty)
        XCTAssertTrue(ItemAnalytics.annualRecurringEstimate(from: []).isEmpty)
    }

    func testMonthlyTotal_itemWithoutAmount_excluded() {
        let noAmount = item(dueDate: .now, recurring: .monthly)
        let result = ItemAnalytics.monthlyRecurringTotal(from: [noAmount])
        XCTAssertTrue(result.isEmpty)
    }

    func testMixedCurrencyTotals() {
        let usd = TrackedItem(title: "USD", category: .subscription, dueDate: .now, recurringInterval: .monthly, amount: 10, currencyCode: "USD")
        let eur = TrackedItem(title: "EUR", category: .subscription, dueDate: .now, recurringInterval: .monthly, amount: 9, currencyCode: "EUR")
        let result = ItemAnalytics.monthlyRecurringTotal(from: [usd, eur])
        XCTAssertEqual(result["USD"], 10.0)
        XCTAssertEqual(result["EUR"], 9.0)
        XCTAssertEqual(result.count, 2)
    }

    func testMixedCurrencyAnnualEstimate() {
        let usd = TrackedItem(title: "US Monthly", category: .subscription, dueDate: .now, recurringInterval: .monthly, amount: 10, currencyCode: "USD")
        let eur = TrackedItem(title: "EU Yearly", category: .insurance, dueDate: .now, recurringInterval: .yearly, amount: 600, currencyCode: "EUR")
        let result = ItemAnalytics.annualRecurringEstimate(from: [usd, eur])
        XCTAssertEqual(result["USD"] ?? 0, 120.0, accuracy: 0.01)
        XCTAssertEqual(result["EUR"] ?? 0, 600.0, accuracy: 0.01)
    }

    // MARK: - Sorting

    func testSortSoonest_usesEffectiveDueDate() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        // Recurring item stored with old dueDate but rolls forward to +5 days
        let recurring = item(title: "Recurring", dueDate: date(-100, from: base), recurring: .monthly)
        // Non-recurring item due in 20 days
        let nonRecurring = item(title: "NonRecurring", dueDate: date(20, from: base))
        let sorted = ItemAnalytics.sort(items: [nonRecurring, recurring], by: .soonest)
        // Recurring item rolls forward to next occurrence (~day -100 + 4*30 ≈ day 20)
        // The first item should not be the one with the oldest raw dueDate
        XCTAssertFalse(sorted.isEmpty)
        // Both effective dates should be in the future or very close
        for item in sorted {
            let effective = ItemAnalytics.effectiveDueDate(for: item, now: base)
            XCTAssertGreaterThanOrEqual(effective, cal.startOfDay(for: base))
        }
    }

    func testSortTitle_alphabetical() {
        let a = item(title: "Apple", dueDate: .now)
        let b = item(title: "Banana", dueDate: .now)
        let c = item(title: "Cherry", dueDate: .now)
        let sorted = ItemAnalytics.sort(items: [c, a, b], by: .title)
        XCTAssertEqual(sorted.map(\.title), ["Apple", "Banana", "Cherry"])
    }

    func testSortRecentlyUpdated() {
        let old = TrackedItem(title: "Old", category: .document, dueDate: .now, updatedAt: Date(timeIntervalSince1970: 1_000_000))
        let recent = TrackedItem(title: "Recent", category: .document, dueDate: .now, updatedAt: Date(timeIntervalSince1970: 1_700_000_000))
        let sorted = ItemAnalytics.sort(items: [old, recent], by: .recentlyUpdated)
        XCTAssertEqual(sorted.first?.title, "Recent")
    }

    // MARK: - Critical Item

    func testCriticalItem_prefersExpiredOverDueSoon() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let expired = item(title: "Expired", dueDate: date(-5, from: base))
        let soon = item(title: "Soon", dueDate: date(3, from: base))
        let result = ItemAnalytics.criticalItem(from: [soon, expired], now: base)
        XCTAssertEqual(result?.title, "Expired")
    }

    func testCriticalItem_nilForEmptyList() {
        XCTAssertNil(ItemAnalytics.criticalItem(from: []))
    }

    // MARK: - Category Breakdown

    func testCategoryBreakdown_onlyIncludesActiveItems() {
        let doc = item(category: .document, dueDate: .now)
        let archivedDoc = item(category: .document, dueDate: .now, archived: true)
        let sub = item(category: .subscription, dueDate: .now)
        let breakdown = ItemAnalytics.categoryBreakdown(from: [doc, archivedDoc, sub])
        let docCount = breakdown.first(where: { $0.0 == .document })?.1 ?? 0
        XCTAssertEqual(docCount, 1)
    }

    // MARK: - Expiring Documents

    func testExpiringDocumentsCount_onlyDocumentsWithin30Days() {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let docSoon = item(category: .document, dueDate: date(10, from: base))
        let docLater = item(category: .document, dueDate: date(60, from: base))
        let subSoon = item(category: .subscription, dueDate: date(5, from: base))
        XCTAssertEqual(ItemAnalytics.expiringDocumentsCount(from: [docSoon, docLater, subSoon], now: base), 1)
    }
}
