import XCTest

final class NanoLogicUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-bypassSplashScreen", "-resetAppState"]
        app.launch()
    }
    
    override func tearDownWithError() throws {}
    
    @MainActor
    func testAppStarts() throws {
        let app = XCUIApplication()
        let contentView = app.otherElements["Nanotech Toolkit Logo"]
        XCTAssertTrue(contentView.waitForExistence(timeout: 10.0), "Main content view should appear")
    }
}
