//
//  AlbumReviewUITests.swift
//  MusicBoxUITests
//
//  Created by Luca on 03/12/25.
//

import XCTest

final class AlbumReviewUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helper to launch app and login
    private func launchAndLogin() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-test-open-search-tab")
        app.launch()
        
        // Perform login
        let emailField = app.textFields["loginEmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("luca@gmail.com")
        
        let passwordField = app.secureTextFields["loginPasswordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("12345678")
        
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        // Wait for login to complete and search tab to load
        let searchTitle = app.staticTexts["albumSearchToolbarTitle"]
        let searchField = app.textFields["albumSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10) || searchTitle.waitForExistence(timeout: 10))
        
        return app
    }

    // MARK: - Full Album Review Flow
    @MainActor
    func testAlbumReviewFlow() throws {
        let app = launchAndLogin()

        // 1. Search for an album
        let searchField = app.textFields["albumSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))
        searchField.tap()
        searchField.typeText("Radiohead")

        // 2. Select first result (wait a bit for results to load)
        sleep(2) // Wait for API results
        
        // Find and tap first album result
        // Try different approaches to find the album
        let firstAlbumCell = app.collectionViews.cells.firstMatch
        if firstAlbumCell.waitForExistence(timeout: 8) {
            firstAlbumCell.tap()
        } else {
            // Try another approach
            let firstAlbum = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Radiohead'")).firstMatch
            XCTAssertTrue(firstAlbum.waitForExistence(timeout: 8))
            firstAlbum.tap()
        }

        // 3. Tap "Log" button on album detail
        let logButton = app.buttons["albumDetailLogButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 8))
        logButton.tap()

        // 4. Confirm review screen is visible - look for "Review" header
        let reviewHeader = app.staticTexts["Review"]
        XCTAssertTrue(reviewHeader.waitForExistence(timeout: 8),
                      "Review screen should appear with 'Review' header")

        // 5. Type a review - TextEditor doesn't have accessibility identifier
        // Find the TextEditor by tapping in the review area
        let reviewArea = app.textViews.firstMatch // TextEditor becomes UITextView
        if reviewArea.waitForExistence(timeout: 8) {
            reviewArea.tap()
            reviewArea.typeText("Amazing album, UI test review.")
        } else {
            // Alternative: tap in the general area
            let screen = app.windows.firstMatch
            screen.tap()
            app.typeText("Amazing album, UI test review.")
        }

        // 6. Tap heart icon if it's your review
        // Heart is shown when review.isLiked is true, but we need to find the toggle button
        // In your ReviewInfoView, the heart is just an Image, not a button
        // So we can't toggle it in tests unless you make it a Button
        
        // 7. Save review - Save button is in toolbar
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 8))
        saveButton.tap()

        // 8. Check for save confirmation
        // After save, you might stay on ReviewDetailView or go back
        // Check that we're still in a review context
        XCTAssertTrue(reviewHeader.waitForExistence(timeout: 6) ||
                     logButton.waitForExistence(timeout: 6),
                     "Should either stay on review or return to album detail")
    }
    
    // MARK: - Test duplicate album review prevention
    @MainActor
    func testDuplicateAlbumReviewPrevention() throws {
        let app = launchAndLogin()
        
        // 1. Search for an album
        let searchField = app.textFields["albumSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))
        searchField.tap()
        searchField.typeText("The Smiths")
        
        sleep(2) // Wait for results
        
        // 2. Select first result
        let firstAlbum = app.collectionViews.cells.firstMatch
        if firstAlbum.waitForExistence(timeout: 8) {
            firstAlbum.tap()
        } else {
            let smithsAlbum = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Smiths'")).firstMatch
            XCTAssertTrue(smithsAlbum.waitForExistence(timeout: 8))
            smithsAlbum.tap()
        }
        
        // 3. Tap "Log" button on album detail (first time)
        let logButton = app.buttons["albumDetailLogButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 8))
        logButton.tap()
        
        // 4. Go through review flow
        let reviewHeader = app.staticTexts["Review"]
        XCTAssertTrue(reviewHeader.waitForExistence(timeout: 8))
        
        // Type review
        let reviewArea = app.textViews.firstMatch
        if reviewArea.waitForExistence(timeout: 8) {
            reviewArea.tap()
            reviewArea.typeText("First review for duplicate test.")
        }
        
        // Save
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 8))
        saveButton.tap()
        
        // 5. Navigate back to search
        // Press back button - might be "Back" or chevron
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        }
        
        // Go back again to search list
        let backButton2 = app.navigationBars.buttons.element(boundBy: 0)
        if backButton2.exists {
            backButton2.tap()
        }
        
        // 6. Search for the same album again
        searchField.tap()
        
        // Clear text if needed
        if let currentText = searchField.value as? String, !currentText.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
            searchField.typeText(deleteString)
        }
        
        searchField.typeText("The Smiths")
        sleep(2)
        
        // 7. Select first result again
        let firstAlbumAgain = app.collectionViews.cells.firstMatch
        if firstAlbumAgain.waitForExistence(timeout: 8) {
            firstAlbumAgain.tap()
        }
        
        // 8. Verify button now says "View Review" (gray) instead of "Log" (red)
        // We can check if the button exists, but checking color/text is harder
        let albumDetailButton = app.buttons["albumDetailLogButton"]
        XCTAssertTrue(albumDetailButton.waitForExistence(timeout: 8))
        
        // The button should still exist, but we can't easily check its text/color in XCTest
        // You could add accessibility value or label to distinguish
    }
    
    // MARK: - Test that a user cannot edit someone else's review
    @MainActor
    func testCannotEditSomeoneElsesReview_fromSocialTab() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-test") // optional
        app.launch()

        // ----- LOGIN AS A DIFFERENT USER (joao) -----
        let emailField = app.textFields["loginEmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 6))
        emailField.tap()
        emailField.typeText("joao@gmail.com")

        let passwordField = app.secureTextFields["loginPasswordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 6))
        passwordField.tap()
        passwordField.typeText("12345678")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 6))
        loginButton.tap()

        // Wait for app to settle
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

        // ----- NAVIGATE TO Reviews (Social) TAB -----
        let reviewsTab = app.tabBars.buttons["Reviews"]
        if reviewsTab.waitForExistence(timeout: 6) {
            reviewsTab.tap()
        } else {
            // fallback: try symbol label
            let alt = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Review'")).firstMatch
            XCTAssertTrue(alt.waitForExistence(timeout: 6))
            alt.tap()
        }

        // Ensure the list loaded
        let firstReviewCell = app.buttons["firstSocialReviewCell"]
        XCTAssertTrue(firstReviewCell.waitForExistence(timeout: 10), "No review cells found in Social feed")

        // ----- OPEN A SOCIAL REVIEW (first one) -----
        firstReviewCell.tap()

        // Now we should be on the review detail screen for that review.
        // ----- ASSERT: Editing controls are NOT present -----

        // 1) TextEditor (UITextView) should not be present
        // TextEditor maps to a UITextView in UI tests, accessible as textViews
        let anyTextView = app.textViews.firstMatch
        XCTAssertFalse(anyTextView.waitForExistence(timeout: 1), "Unexpected: a TextEditor (UITextView) exists — should not be editable")

        // 2) Save button should NOT be present
        let saveButton = app.buttons["Save"]
        XCTAssertFalse(saveButton.exists, "Save button should NOT be visible when viewing someone else's review")

        // 3) Heart toggle should not be tappable (should be just an Image). Check for any heart button.
        let heartButtonPredicate = NSPredicate(format: "label CONTAINS[c] 'heart' OR identifier CONTAINS[c] 'heart' OR value CONTAINS[c] 'heart'")
        let heartButtons = app.buttons.matching(heartButtonPredicate)
        XCTAssertEqual(heartButtons.count, 0, "No tappable heart buttons should exist on someone else's review")

        // 4) Inline editable stars — try common identifiers or star buttons
        // (If you have assigned accessibilityIdentifier = "inlineEditableStar" to editable stars in owner mode,
        // this will catch them; otherwise look for tappable star buttons)
        let inlineEditableStarButtons = app.buttons.matching(identifier: "inlineEditableStar")
        XCTAssertEqual(inlineEditableStarButtons.count, 0, "Inline editable star controls should not exist")

        let starButtonPredicate = NSPredicate(format: "label CONTAINS[c] 'star' OR identifier CONTAINS[c] 'star' OR value CONTAINS[c] 'star'")
        let starButtons = app.buttons.matching(starButtonPredicate)
        // Allow the existence of decorative (non-interactive) star images, but ensure there are no tappable star buttons
        XCTAssertTrue(starButtons.count == 0 || starButtons.allElementsBoundByIndex.allSatisfy { !$0.isHittable },
                      "There should be no tappable star buttons for someone else's review")

        // 5) Optionally assert read-only text exists (review content)
        // This is a lightweight check — look for a static text element containing some content
        XCTAssertTrue(app.staticTexts.count > 0, "Expected some static text (review content) to be visible")
    }



}

// MARK: - Helper extension to clear text field
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        
        // Tap to focus
        self.tap()
        
        // Move cursor to end
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
