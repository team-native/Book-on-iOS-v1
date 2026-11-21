import XCTest

final class LoginUITests: XCTestCase {
    func testLoginScreenLoads() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["환영합니다!"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["로그인"].exists)
    }

    func testSubmittingEmptyLoginShowsValidationMessage() {
        let app = launchApp()
        let loginButton = app.buttons["로그인"]

        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        XCTAssertTrue(app.staticTexts["이메일 주소를 입력해주세요"].waitForExistence(timeout: 2))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        return app
    }
}
