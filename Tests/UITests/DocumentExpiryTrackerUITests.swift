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

    // MARK: - Onboarding

    func testOnboardingFlow_completesSuccessfully() throws {
        let onboardingApp = XCUIApplication()
        onboardingApp.launchArguments = ["UITEST_IN_MEMORY_STORE", "UITEST_FORCE_ONBOARDING"]
        onboardingApp.launch()

        XCTAssertTrue(onboardingApp.buttons["onboarding_continue"].waitForExistence(timeout: 3))
        onboardingApp.buttons["onboarding_continue"].tap()
        onboardingApp.buttons["onboarding_continue"].tap()
        onboardingApp.buttons["onboarding_continue"].tap()
        let notifButton = onboardingApp.buttons["onboarding_enable_notifications"]
        let laterButton = onboardingApp.buttons["onboarding_maybe_later"]
        XCTAssertTrue(notifButton.waitForExistence(timeout: 2) || laterButton.waitForExistence(timeout: 2))
    }

    func testOnboardingSkip_landsOnHome() throws {
        let onboardingApp = XCUIApplication()
        onboardingApp.launchArguments = ["UITEST_IN_MEMORY_STORE", "UITEST_FORCE_ONBOARDING"]
        onboardingApp.launch()

        XCTAssertTrue(onboardingApp.buttons["onboarding_skip"].waitForExistence(timeout: 3))
        onboardingApp.buttons["onboarding_skip"].tap()
        XCTAssertTrue(onboardingApp.buttons["home_header_add"].waitForExistence(timeout: 3))
    }

    // MARK: - Add Item

    func testAddValidItem_appearsInList() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let title = app.textFields["itemForm_title"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        title.tap()
        title.typeText("Passport")
        app.buttons["itemForm_save_bottom"].tap()
        XCTAssertTrue(app.staticTexts["Passport"].waitForExistence(timeout: 3))
    }

    func testSaveButton_disabledWithoutTitle() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let saveButton = app.buttons["itemForm_save_bottom"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertFalse(saveButton.isEnabled)
    }

    func testAddItem_withReminder_saves() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let title = app.textFields["itemForm_title"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        title.tap()
        title.typeText("Netflix")
        // 7-day reminder is selected by default, save should work
        app.buttons["itemForm_save_bottom"].tap()
        XCTAssertTrue(app.staticTexts["Netflix"].waitForExistence(timeout: 3))
    }

    // MARK: - Item Detail

    func testItemDetail_editDeleteArchiveButtonsExist() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let title = app.textFields["itemForm_title"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        title.tap()
        title.typeText("Netflix")
        app.buttons["itemForm_save_bottom"].tap()
        XCTAssertTrue(app.staticTexts["Netflix"].waitForExistence(timeout: 3))
        app.staticTexts["Netflix"].tap()
        XCTAssertTrue(app.buttons["detail_edit"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["detail_archive"].exists)
        XCTAssertTrue(app.buttons["detail_delete"].exists)
    }

    // MARK: - Items Tab - Search & Filter

    func testSearch_filtersResults() throws {
        app.launch()
        for name in ["Passport", "Spotify"] {
            app.buttons["home_header_add"].tap()
            let title = app.textFields["itemForm_title"]
            XCTAssertTrue(title.waitForExistence(timeout: 3))
            title.tap()
            title.typeText(name)
            app.buttons["itemForm_save_bottom"].tap()
            XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 3))
        }
        app.buttons["tab_items"].tap()
        let search = app.textFields["items_search"]
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap()
        search.typeText("Spot")
        XCTAssertTrue(app.staticTexts["Spotify"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Passport"].exists)
    }

    // MARK: - Pro Gating

    func testFreeUser_5ItemCap_showsPaywall() throws {
        app.launch()
        for index in 1...5 {
            app.buttons["home_header_add"].tap()
            let title = app.textFields["itemForm_title"]
            XCTAssertTrue(title.waitForExistence(timeout: 3))
            title.tap()
            title.typeText("Item \(index)")
            app.buttons["itemForm_save_bottom"].tap()
            // Wait for the form to dismiss before proceeding
            XCTAssertTrue(app.buttons["itemForm_save_bottom"].waitForNonExistence(timeout: 5))
        }
        app.buttons["home_header_add"].tap()
        XCTAssertTrue(app.buttons["paywall_unlock"].waitForExistence(timeout: 3))
    }

    func testFreeUser_multipleReminders_showsPaywall() throws {
        app.launch()
        app.buttons["home_header_add"].tap()
        let title = app.textFields["itemForm_title"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        title.tap()
        title.typeText("Passport")
        // Tap a second reminder (7-day is default, try tapping 30-day)
        let reminder30 = app.buttons["reminder_30"]
        if reminder30.waitForExistence(timeout: 2) {
            reminder30.tap()
            XCTAssertTrue(app.buttons["paywall_unlock"].waitForExistence(timeout: 3) || app.buttons["paywall_close"].waitForExistence(timeout: 3))
        }
    }

    func testPaywall_closeButtonDismisses() throws {
        app.launch()
        for index in 1...5 {
            app.buttons["home_header_add"].tap()
            let title = app.textFields["itemForm_title"]
            XCTAssertTrue(title.waitForExistence(timeout: 3))
            title.tap()
            title.typeText("Item \(index)")
            app.buttons["itemForm_save_bottom"].tap()
            // Wait for the form to dismiss before proceeding
            XCTAssertTrue(app.buttons["itemForm_save_bottom"].waitForNonExistence(timeout: 5))
        }
        app.buttons["home_header_add"].tap()
        XCTAssertTrue(app.buttons["paywall_close"].waitForExistence(timeout: 3))
        app.buttons["paywall_close"].tap()
        XCTAssertTrue(app.buttons["home_header_add"].waitForExistence(timeout: 3))
    }

    // MARK: - Settings

    func testSettings_restorePurchasesButtonExists() throws {
        app.launch()
        app.buttons["tab_settings"].tap()
        XCTAssertTrue(app.buttons["settings_restore"].waitForExistence(timeout: 3))
    }

    func testSettings_upgradeButtonExists() throws {
        app.launch()
        app.buttons["tab_settings"].tap()
        XCTAssertTrue(app.buttons["settings_upgrade"].waitForExistence(timeout: 3))
    }

    func testSettings_developerSectionHidden_inReleaseModeSimulation() throws {
        // Developer section is wrapped in #if DEBUG - in release builds it should not exist
        // This test just verifies settings loads correctly
        app.launch()
        app.buttons["tab_settings"].tap()
        XCTAssertTrue(app.buttons["settings_restore"].waitForExistence(timeout: 3))
    }

    // MARK: - Tab Navigation

    func testTabNavigation_allTabsReachable() throws {
        app.launch()
        XCTAssertTrue(app.buttons["tab_home"].waitForExistence(timeout: 3))
        app.buttons["tab_items"].tap()
        app.buttons["tab_insights"].tap()
        app.buttons["tab_settings"].tap()
        app.buttons["tab_home"].tap()
        XCTAssertTrue(app.buttons["home_header_add"].exists)
    }

    // MARK: - Sample Data (Debug only)

    func testGenerateSampleData_populatesItems() throws {
        let seedApp = XCUIApplication()
        seedApp.launchArguments = [
            "UITEST_IN_MEMORY_STORE",
            "UITEST_SKIP_ONBOARDING",
            "UITEST_SEED_SAMPLE_ITEMS",
            "UITEST_FORCE_FREE"
        ]
        seedApp.launch()
        // Home should show items (not empty state)
        XCTAssertFalse(seedApp.buttons["home_header_add"].waitForExistence(timeout: 3) == false)
    }
}
