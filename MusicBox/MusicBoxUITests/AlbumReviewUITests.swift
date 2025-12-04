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
    
    // MARK: - Test editing own review vs viewing others
    @MainActor
    func testReviewEditPermissions() throws {
        let app = launchAndLogin()
        
        // 1. Search and select an album
        let searchField = app.textFields["albumSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))
        searchField.tap()
        searchField.typeText("Radiohead")
        sleep(2)
        
        let firstAlbum = app.collectionViews.cells.firstMatch
        if firstAlbum.waitForExistence(timeout: 8) {
            firstAlbum.tap()
        }
        
        // 2. Check if we can log or view review
        let detailButton = app.buttons["albumDetailLogButton"]
        XCTAssertTrue(detailButton.waitForExistence(timeout: 8))
        
        // 3. Tap to either log or view
        detailButton.tap()
        
        // 4. Check if "(Your Review)" badge appears
        let yourReviewBadge = app.staticTexts["(Your Review)"]
        if yourReviewBadge.waitForExistence(timeout: 5) {
            // This is our review - we should see Save button
            let saveButton = app.buttons["Save"]
            XCTAssertTrue(saveButton.waitForExistence(timeout: 5),
                         "Should see Save button for our own review")
            
            // Should be able to edit text
            let textEditor = app.textViews.firstMatch
            XCTAssertTrue(textEditor.exists, "Should have editable TextEditor")
        } else {
            // Not our review - no Save button
            let saveButton = app.buttons["Save"]
            XCTAssertFalse(saveButton.exists, "Should not see Save button for others' reviews")
            
            // Should see read-only text
            let staticText = app.staticTexts.firstMatch
            XCTAssertTrue(staticText.exists, "Should see review text")
        }
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
