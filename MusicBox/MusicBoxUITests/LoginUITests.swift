//
//  LoginUITests.swift
//  MusicBoxUITests
//
//  Created by Luca on 03/12/25.
//

import XCTest

final class LoginUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLoginWithRealTestUser() throws {
        let app = XCUIApplication()
        app.launchArguments += ["--ui-test-open-search-tab"]   // ✅ switch to Search tab after login
        app.launch()

        let emailField = app.textFields["loginEmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("teste@teste.com")

        let passwordField = app.secureTextFields["loginPasswordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))

        passwordField.tap()
        passwordField.typeText("password123")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // After login → app loads AlbumTabView → UI test flag switches to tab 1 → Search View appears
        let searchTitle = app.staticTexts["albumSearchToolbarTitle"]

        XCTAssertTrue(
            searchTitle.waitForExistence(timeout: 10),
            "After logging in, app should navigate to AlbumSearchView"
        )
    }

}
