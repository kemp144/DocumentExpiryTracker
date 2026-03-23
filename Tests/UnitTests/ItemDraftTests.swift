import XCTest
@testable import Document_Expiry_Tracker

final class ItemDraftTests: XCTestCase {
    func testInvalidWithoutTitle() {
        var draft = ItemDraft()
        draft.title = "   "
        XCTAssertFalse(draft.isValid)
        XCTAssertEqual(draft.validationMessage, "Title is required.")
    }

    func testNegativeAmountIsInvalid() {
        var draft = ItemDraft()
        draft.title = "Netflix"
        draft.amountText = "-4"
        XCTAssertFalse(draft.isValid)
    }

    func testValidRecurringDraftAllowsMonthly() {
        var draft = ItemDraft()
        draft.title = "Spotify"
        draft.recurringInterval = .monthly
        draft.amountText = "10.99"
        XCTAssertTrue(draft.isValid)
    }
}
