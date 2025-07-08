import XCTest

final class NanoLogicUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testAppStarts() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-bypassSplashScreen", "-resetAppState"]
        app.launch()
    }
}
