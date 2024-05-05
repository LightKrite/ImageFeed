//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Egor Partenko on 05.05.2024.
//

@testable import ImageFeed
import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["AuthenticateButton"].tap()

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        sleep(5)
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        sleep(3)
        passwordTextField.tap()
        passwordTextField.typeText("")
        sleep(3)
        webView.swipeUp()
        sleep(3)
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        sleep(3)
        let tableQuery = app.tables
        sleep(5)
        let cell = tableQuery.descendants(matching: .cell).element(boundBy: 0)
        sleep(5)
        cell.swipeUp()
        
        sleep(5)
        
        let cellToLike = tableQuery.descendants(matching: .cell).element(boundBy: 1)
        sleep(5)

        cellToLike.buttons["LikeButton"].tap()
        
        sleep(5)
        
        cellToLike.buttons["LikeButton"].tap()
        
        sleep(5)
        
        cellToLike.tap()
        
        sleep(5)

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 20))
        image.pinch(withScale: 3, velocity: 1)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 0.5, velocity: -1)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        let singleImageBackButton = app.buttons["backwardButton"]
        singleImageBackButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        let tabBars = app.tabBars
        let button = tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        sleep(5)
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["nicknameLabel"].exists)
        
        app.buttons["logout"].tap()
        sleep(5)
        app.alerts["До встречи!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(5)
        XCTAssertTrue(app.buttons["AuthenticateButton"].exists)
    }
}
