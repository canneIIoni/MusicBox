//
//  AlbumSearchUITests.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//

import XCTest

final class AlbumSearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Prepare App With Auto-Login for UI Tests
    private func launchTestApp() -> XCUIApplication {
        let app = XCUIApplication()
        
        // 🔥 Tell the app to:
        // 1. Auto-login using the debug user
        // 2. Automatically switch to the Search tab
        app.launchArguments.append("--ui-test-debug-login")
        app.launchArguments.append("--ui-test-open-search-tab")
        
        app.launch()
        return app
    }

    // MARK: - 1. Test that search field exists
    @MainActor
    func testSearchFieldExists() throws {
        let app = launchTestApp()

        let textField = app.textFields["albumSearchField"]

        XCTAssertTrue(
            textField.waitForExistence(timeout: 5),
            "The search field should exist on the Album Search screen"
        )
    }

    // MARK: - 2. Typing a query should show results
    @MainActor
    func testTypingSearchShowsResults() throws {
        let app = launchTestApp()

        let textField = app.textFields["albumSearchField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))

        textField.tap()
        textField.typeText("Radiohead")

        // Look for first result cell
        let firstResult = app.otherElements
            .containing(NSPredicate(format: "identifier BEGINSWITH 'albumRow_'"))
            .firstMatch

        XCTAssertTrue(
            firstResult.waitForExistence(timeout: 5),
            "Search results should appear after typing a query"
        )
    }

    // MARK: - 3. Tapping a result navigates to album detail screen
    @MainActor
    func testSelectingAlbumOpensDetailScreen() throws {
        let app = launchTestApp()

        let textField = app.textFields["albumSearchField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))

        textField.tap()
        textField.typeText("Radiohead")

        let firstResult = app.otherElements
            .containing(NSPredicate(format: "identifier BEGINSWITH 'albumRow_'"))
            .firstMatch
        
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))

        firstResult.tap()

        let detailTitle = app.staticTexts["albumDetailTitle"]

        XCTAssertTrue(
            detailTitle.waitForExistence(timeout: 5),
            "Tapping a search result should open the detail screen"
        )
    }
}
