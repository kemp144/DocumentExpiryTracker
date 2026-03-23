import XCTest

final class DocumentExpiryTrackerUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "UITEST_IN_MEMORY_STORE",
            "UITEST_SKIP_ONBOARDING",
            "UITEST_MOCK_PRO_PURCHASES",
            "UITEST_FORCE_FREE"
        ]
    }

    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_IN_MEMORY_STORE", "UITEST_FORCE_ONBOARDING"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding_continue"].waitForExistence(timeout: 2))
        app.buttons["onboarding_continue"].tap()
        app.buttons["onboarding_continue"].tap()
        app.buttons["onboarding_continue"].tap()
        XCTAssertTrue(app.buttons["onboarding_enable_notifications"].exists || app.buttons["onboarding_maybe_later"].exists)
    }

    func testAddValidItem() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let title = app.textFields["itemForm_title"]
        XCTAssertTrue(title.waitForExistence(timeout: 2))
        title.tap()
        title.typeText("Passport")
        app.buttons["itemForm_save"].tap()
        XCTAssertTrue(app.staticTexts["Passport"].waitForExistence(timeout: 2))
    }

    func testValidationPreventsInvalidSave() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        XCTAssertFalse(app.buttons["itemForm_save"].isEnabled)
    }

    func testEditDeleteAndArchiveButtonsExist() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let title = app.textFields["itemForm_title"]
        title.tap()
        title.typeText("Netflix")
        app.buttons["itemForm_save"].tap()
        app.staticTexts["Netflix"].tap()
        XCTAssertTrue(app.buttons["detail_edit"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["detail_archive"].exists)
        XCTAssertTrue(app.buttons["detail_delete"].exists)
    }

    func testSearchAndFilterBehavior() throws {
        app.launch()
        for name in ["Passport", "Spotify"] {
            app.buttons["home_header_add"].tap()
            let title = app.textFields["itemForm_title"]
            title.tap()
            title.typeText(name)
            app.buttons["itemForm_save"].tap()
        }
        app.buttons["tab_items"].tap()
        let search = app.textFields["items_search"]
        XCTAssertTrue(search.waitForExistence(timeout: 2))
        search.tap()
        search.typeText("Spot")
        XCTAssertTrue(app.staticTexts["Spotify"].waitForExistence(timeout: 2))
    }

    func testFreeUserHittingFiveItemCapShowsPaywall() throws {
        app.launch()
        for index in 1...5 {
            app.buttons["home_header_add"].tap()
            let title = app.textFields["itemForm_title"]
            title.tap()
            title.typeText("Item \(index)")
            app.buttons["itemForm_save"].tap()
        }
        app.buttons["home_header_add"].tap()
        XCTAssertTrue(app.buttons["paywall_unlock"].waitForExistence(timeout: 2))
    }

    func testMockedProUnlockPath() throws {
        app.launch()
        for index in 1...5 {
            app.buttons["home_header_add"].tap()
            let title = app.textFields["itemForm_title"]
            title.tap()
            title.typeText("Item \(index)")
            app.buttons["itemForm_save"].tap()
        }
        app.buttons["home_header_add"].tap()
        app.buttons["paywall_unlock"].tap()
        XCTAssertTrue(app.buttons["paywall_close"].waitForExistence(timeout: 2) || app.buttons["home_header_add"].exists)
    }

    func testSettingsRestorePurchasesEntryPointExists() throws {
        app.launch()
        app.buttons["tab_settings"].tap()
        XCTAssertTrue(app.buttons["settings_restore"].waitForExistence(timeout: 2))
    }
}
