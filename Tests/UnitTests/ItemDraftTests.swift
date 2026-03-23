import XCTest
@testable import Document_Expiry_Tracker

final class ItemDraftTests: XCTestCase {

    // MARK: - Validation

    func testInvalid_emptyTitle() {
        var draft = ItemDraft()
        draft.title = ""
        XCTAssertFalse(draft.isValid)
        XCTAssertEqual(draft.validationMessage, "Title is required.")
    }

    func testInvalid_whitespaceOnlyTitle() {
        var draft = ItemDraft()
        draft.title = "   "
        XCTAssertFalse(draft.isValid)
        XCTAssertEqual(draft.validationMessage, "Title is required.")
    }

    func testValid_titleOnly() {
        var draft = ItemDraft()
        draft.title = "Passport"
        XCTAssertTrue(draft.isValid)
        XCTAssertNil(draft.validationMessage)
    }

    func testInvalid_negativeAmount() {
        var draft = ItemDraft()
        draft.title = "Netflix"
        draft.amountText = "-4"
        XCTAssertFalse(draft.isValid)
        XCTAssertEqual(draft.validationMessage, "Amount cannot be negative.")
    }

    func testValid_zeroAmount() {
        var draft = ItemDraft()
        draft.title = "Free Tier"
        draft.amountText = "0"
        XCTAssertTrue(draft.isValid)
    }

    func testValid_recurringMonthly() {
        var draft = ItemDraft()
        draft.title = "Spotify"
        draft.recurringInterval = .monthly
        draft.amountText = "10.99"
        XCTAssertTrue(draft.isValid)
    }

    func testValid_recurringYearly() {
        var draft = ItemDraft()
        draft.title = "Car Insurance"
        draft.recurringInterval = .yearly
        draft.amountText = "1200"
        XCTAssertTrue(draft.isValid)
    }

    // MARK: - Amount Parsing

    func testNormalizedAmount_dotSeparator() {
        var draft = ItemDraft()
        draft.amountText = "9.99"
        XCTAssertEqual(draft.normalizedAmount, 9.99)
    }

    func testNormalizedAmount_commaSeparator_europeanLocale() {
        var draft = ItemDraft()
        draft.amountText = "9,99"
        XCTAssertEqual(draft.normalizedAmount, 9.99, "European comma separator should parse correctly")
    }

    func testNormalizedAmount_empty_returnsNil() {
        var draft = ItemDraft()
        draft.amountText = ""
        XCTAssertNil(draft.normalizedAmount)
    }

    func testNormalizedAmount_whitespaceOnly_returnsNil() {
        var draft = ItemDraft()
        draft.amountText = "   "
        XCTAssertNil(draft.normalizedAmount)
    }

    func testNormalizedAmount_invalid_returnsNil() {
        var draft = ItemDraft()
        draft.amountText = "abc"
        XCTAssertNil(draft.normalizedAmount)
    }

    func testNormalizedAmount_largeValue() {
        var draft = ItemDraft()
        draft.amountText = "9999.99"
        XCTAssertEqual(draft.normalizedAmount ?? 0, 9999.99, accuracy: 0.001)
    }

    // MARK: - makeItem

    func testMakeItem_setsAllFields() {
        var draft = ItemDraft()
        draft.title = "  Netflix  "
        draft.category = .subscription
        draft.provider = "  Netflix Inc.  "
        draft.recurringInterval = .monthly
        draft.amountText = "15.99"
        draft.currencyCode = "USD"
        draft.notes = "  Shared account  "
        draft.owner = "  Robert  "
        draft.reminders = [.sevenDays, .oneDay]

        let item = draft.makeItem()
        XCTAssertEqual(item.title, "Netflix")
        XCTAssertEqual(item.category, .subscription)
        XCTAssertEqual(item.provider, "Netflix Inc.")
        XCTAssertEqual(item.recurringInterval, .monthly)
        XCTAssertEqual(item.amount, 15.99)
        XCTAssertEqual(item.currencyCode, "USD")
        XCTAssertEqual(item.notesText, "Shared account")
        XCTAssertEqual(item.ownerName, "Robert")
        XCTAssertTrue(item.reminders.contains(.sevenDays))
        XCTAssertTrue(item.reminders.contains(.oneDay))
        XCTAssertFalse(item.isArchived)
    }

    func testMakeItem_noAmount_nilAmount() {
        var draft = ItemDraft()
        draft.title = "Passport"
        draft.amountText = ""
        let item = draft.makeItem()
        XCTAssertNil(item.amount)
    }

    func testMakeItem_trimTitle() {
        var draft = ItemDraft()
        draft.title = "   Passport   "
        let item = draft.makeItem()
        XCTAssertEqual(item.title, "Passport")
    }

    // MARK: - apply(to:)

    func testApply_updatesExistingItem() {
        let original = TrackedItem(title: "Old Title", category: .document, dueDate: .now)
        var draft = ItemDraft(item: original)
        draft.title = "New Title"
        draft.category = .subscription
        draft.amountText = "9.99"
        draft.apply(to: original)

        XCTAssertEqual(original.title, "New Title")
        XCTAssertEqual(original.category, .subscription)
        XCTAssertEqual(original.amount, 9.99)
    }

    func testApply_archiveSetsArchivedAt() {
        let item = TrackedItem(title: "Test", category: .document, dueDate: .now)
        var draft = ItemDraft(item: item)
        draft.isArchived = true
        draft.apply(to: item)
        XCTAssertNotNil(item.archivedAt)
        XCTAssertTrue(item.isArchived)
    }

    func testApply_unarchiveClearsArchivedAt() {
        let item = TrackedItem(title: "Test", category: .document, dueDate: .now, archivedAt: .now)
        var draft = ItemDraft(item: item)
        draft.isArchived = false
        draft.apply(to: item)
        XCTAssertNil(item.archivedAt)
        XCTAssertFalse(item.isArchived)
    }

    func testApply_updatesTimestamp() {
        let old = Date(timeIntervalSince1970: 1_000_000)
        let item = TrackedItem(title: "Test", category: .document, dueDate: .now, updatedAt: old)
        var draft = ItemDraft(item: item)
        draft.title = "Changed"
        draft.apply(to: item)
        XCTAssertGreaterThan(item.updatedAt, old)
    }

    // MARK: - Init from TrackedItem

    func testInitFromItem_roundTrips() {
        let original = TrackedItem(
            title: "Car Insurance",
            category: .insurance,
            provider: "Generali",
            dueDate: Calendar.current.date(byAdding: .day, value: 90, to: .now)!,
            recurringInterval: .yearly,
            amount: 350.0,
            currencyCode: "EUR",
            notesText: "Kasko",
            ownerName: "Robert",
            reminders: [.thirtyDays, .sevenDays]
        )
        let draft = ItemDraft(item: original)
        XCTAssertEqual(draft.title, original.title)
        XCTAssertEqual(draft.category, original.category)
        XCTAssertEqual(draft.provider, original.provider)
        XCTAssertEqual(draft.recurringInterval, original.recurringInterval)
        XCTAssertEqual(draft.normalizedAmount, original.amount)
        XCTAssertEqual(draft.currencyCode, original.currencyCode)
        XCTAssertTrue(draft.reminders.contains(.thirtyDays))
        XCTAssertTrue(draft.reminders.contains(.sevenDays))
    }
}
