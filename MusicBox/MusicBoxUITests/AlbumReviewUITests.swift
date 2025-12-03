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

    // MARK: - Launch app with automatic debug login
    private func launchTestApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-test-debug-login")
        app.launchArguments.append("--ui-test-open-search-tab")
        app.launch()
        return app
    }

    // MARK: - Full Album Review Flow
    @MainActor
    func testAlbumReviewFlow() throws {
        let app = launchTestApp()

        // 1. Search for an album
        let searchField = app.textFields["albumSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))
        searchField.tap()
        searchField.typeText("Radiohead")

        // 2. Select first result
        let firstResult = app.otherElements
            .containing(NSPredicate(format: "identifier BEGINSWITH 'albumRow_'"))
            .firstMatch
        XCTAssertTrue(firstResult.waitForExistence(timeout: 8))
        firstResult.tap()

        // 3. Tap "Log" button on album detail
        let logButton = app.buttons["albumDetailLogButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 8))
        logButton.tap()

        // 4. Confirm review screen is visible
        let reviewField = app.textFields["albumReviewTextField"]
        XCTAssertTrue(reviewField.waitForExistence(timeout: 8),
                      "Review text field must appear")

        // 5. Type a review
        reviewField.tap()
        reviewField.typeText("Amazing album, UI test review.")

        // 6. Toggle Like button
        let likeButton = app.buttons["albumReviewLikeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 8))
        likeButton.tap()

        // 7. Save review
        let saveButton = app.buttons["albumReviewSaveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 8))
        saveButton.tap()

        // 8. Back in detail screen → Verify the UI updated
        let detailTitle = app.staticTexts["albumDetailTitle"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 6),
                      "Should return to AlbumDetailView after saving")

        // Rating + Like icon should now be visible
        XCTAssertTrue(app.images["heart.circle.fill"].waitForExistence(timeout: 6),
                      "Album should be marked as liked")

        // Optional: review saved in database → skipped in UI tests
    }
}
