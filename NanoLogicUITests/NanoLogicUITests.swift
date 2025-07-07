import XCTest

final class NanoLogicUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-bypassSplashScreen", "-resetAppState"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func testSplashScreenTransition() throws {
        // Verify splash screen appears or is bypassed
        let splashScreenLabel = app.staticTexts["NanoLogic Splash Screen"]
        let splashScreenExists = splashScreenLabel.waitForExistence(timeout: 2.0)
        if splashScreenExists {
            print("Splash screen detected, waiting for it to disappear")
        } else {
            print("Splash screen bypassed")
        }
        
        // Wait for transition to main view
        try waitForMainView()
    }
    
    @MainActor
    func testNavigationToSimulationView() throws {
        try waitForMainView()
        
        let simulationTile = app.buttons["Simulation"]
        XCTAssertTrue(simulationTile.waitForExistence(timeout: 2.0), "Simulation tile should be visible")
        simulationTile.tap()
        
        let welcomeSheet = app.staticTexts["Welcome to the Simulation"]
        if welcomeSheet.waitForExistence(timeout: 2.0) {
            let gotItButton = app.buttons["Got It"]
            XCTAssertTrue(gotItButton.waitForExistence(timeout: 2.0), "Got It button should be visible")
            gotItButton.tap()
        }
        
        let simulationTitle = app.staticTexts["Simulation"]
        XCTAssertTrue(simulationTitle.waitForExistence(timeout: 2.0), "Should navigate to Simulation view")
    }
    
    @MainActor
    func testSimulationViewFunctionality() throws {
        try navigateToSimulationView()
        
        let simulateButton = app.buttons["Simulate"]
        XCTAssertTrue(simulateButton.waitForExistence(timeout: 2.0), "Simulate button should be visible")
        
        simulateButton.tap()
        
        let groundStateButton = app.buttons["Ground State"]
        XCTAssertTrue(groundStateButton.waitForExistence(timeout: 2.0), "Ground State button should appear after simulation starts")
        
        let firstExcitedButton = app.buttons["1st Excited"]
        XCTAssertTrue(firstExcitedButton.waitForExistence(timeout: 2.0), "1st Excited button should be visible")
        firstExcitedButton.tap()
        
        let simulationImage = app.images["0"]
        XCTAssertTrue(simulationImage.waitForExistence(timeout: 2.0), "Simulation image should update to 1st excited state")
        
        let resetButton = app.buttons["Reset Simulation"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 2.0), "Reset Simulation button should be visible")
        resetButton.tap()
        
        XCTAssertTrue(simulateButton.waitForExistence(timeout: 2.0), "Simulate button should reappear after reset")
    }
    
    @MainActor
    func testCircuitDesignView() throws {
        try waitForMainView()
        
        let circuitTile = app.buttons["Circuit Design"]
        XCTAssertTrue(circuitTile.waitForExistence(timeout: 2.0), "Circuit Design tile should be visible")
        circuitTile.tap()
        
        let circuitTitle = app.staticTexts["Circuit Design"]
        XCTAssertTrue(circuitTitle.waitForExistence(timeout: 2.0), "Should navigate to Circuit Design view")
        
        let c17Button = app.buttons["c17"]
        XCTAssertTrue(c17Button.waitForExistence(timeout: 2.0), "C17 circuit button should be visible")
        c17Button.tap()
        
        let computeButton = app.buttons["Find Placement & Routing for Skeletons"]
        XCTAssertTrue(computeButton.waitForExistence(timeout: 2.0), "Compute button should be visible")
        computeButton.tap()
        
        let progressIndicator = app.staticTexts["Computing placement and routing for c17..."].firstMatch
        XCTAssertTrue(progressIndicator.waitForExistence(timeout: 2.0), "Progress indicator should appear during computation")
        
        let skeletonsButton = app.buttons["On-the-Fly Gate Design"]
        XCTAssertTrue(skeletonsButton.waitForExistence(timeout: 2.0), "Should progress to skeletons stage")
    }
    
    @MainActor
    func testLogicDesignView() throws {
        try waitForMainView()
        
        let logicTile = app.buttons["Logic Design"]
        XCTAssertTrue(logicTile.waitForExistence(timeout: 2.0), "Logic Design tile should be visible")
        logicTile.tap()
        
        let logicTitle = app.staticTexts["Logic Design"]
        XCTAssertTrue(logicTitle.waitForExistence(timeout: 2.0), "Should navigate to Logic Design view")
        
        let designButton = app.buttons["Design AND Gate"]
        XCTAssertTrue(designButton.waitForExistence(timeout: 2.0), "Design AND Gate button should be visible")
        designButton.tap()
        
        let simulateButton = app.buttons["Simulate"]
        XCTAssertTrue(simulateButton.waitForExistence(timeout: 2.0), "Simulate button should appear after designing AND gate")
        
        simulateButton.tap()
        
        let input01Button = app.buttons["01"]
        XCTAssertTrue(input01Button.waitForExistence(timeout: 2.0), "Input 01 button should be visible")
        input01Button.tap()
        
        let outputText = app.staticTexts["AND Output: 0"]
        XCTAssertTrue(outputText.waitForExistence(timeout: 2.0), "AND gate output should be 0 for input 01")
    }
    
    @MainActor
    func testAnalysisView() throws {
        try waitForMainView()
        
        let analysisTile = app.buttons["Analysis"]
        XCTAssertTrue(analysisTile.waitForExistence(timeout: 2.0), "Analysis tile should be visible")
        analysisTile.tap()
        
        let analysisTitle = app.staticTexts["Analysis"]
        let analysisTitleExists = analysisTitle.waitForExistence(timeout: 2.0)
        if !analysisTitleExists {
            let hierarchy = app.debugDescription
            print("Accessibility Hierarchy: \(hierarchy)")
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .keepAlways
            add(attachment)
            XCTFail("Analysis view did not appear within 2 seconds")
        }
        XCTAssertTrue(analysisTitleExists, "Should navigate to Analysis view")
        
        let operationalPicker = app.buttons["Operational"]
        XCTAssertTrue(operationalPicker.waitForExistence(timeout: 2.0), "Operational Domain picker should be visible")
        operationalPicker.tap()
        
        let operationalSectionPicker = app.buttons["Operational Domain"]
        XCTAssertTrue(operationalSectionPicker.waitForExistence(timeout: 2.0), "Operational Domain section picker should be visible")
        operationalSectionPicker.tap()
        
        let gridSearchButton = app.buttons["Grid Search"]
        XCTAssertTrue(gridSearchButton.waitForExistence(timeout: 2.0), "Grid Search button should be visible")
        gridSearchButton.tap()
        
        let videoPlayer = app.otherElements["VideoPlayer"]
        XCTAssertTrue(videoPlayer.waitForExistence(timeout: 2.0), "Video player should be visible")
        
        let playButton = app.buttons.containing(.image, identifier: "play.fill").firstMatch
        XCTAssertTrue(playButton.waitForExistence(timeout: 2.0), "Play button should be visible")
        playButton.tap()
        
        let pauseButton = app.buttons.containing(.image, identifier: "pause.fill").firstMatch
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2.0), "Pause button should appear when video is playing")
    }
    
    @MainActor
    func testInfoButtonAccessibility() throws {
        try waitForMainView()
        
        let infoButton = app.buttons["info.circle.fill"]
        XCTAssertTrue(infoButton.waitForExistence(timeout: 2.0), "Info button should be visible")
        XCTAssertTrue(infoButton.isHittable, "Info button should be hittable")
        infoButton.tap()
        
        let infoPanel = app.staticTexts["Silicon Dangling Bond Logic"]
        XCTAssertTrue(infoPanel.waitForExistence(timeout: 2.0), "Info panel should appear")
        
        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 2.0), "Close button should be visible")
        closeButton.tap()
        
        XCTAssertFalse(infoPanel.waitForExistence(timeout: 2.0), "Info panel should disappear after closing")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["-ui-testing", "-bypassSplashScreen", "-resetAppState"]
            app.launch()
        }
    }
    
    // Helper function to navigate to main view
    private func waitForMainView() throws {
        let splashScreenLabel = app.staticTexts["NanoLogic Splash Screen"]
        let splashScreenExists = splashScreenLabel.waitForExistence(timeout: 2.0)
        if splashScreenExists {
            print("Splash screen detected, waiting for it to disappear")
            let splashScreenGone = NSPredicate(format: "exists == FALSE")
            expectation(for: splashScreenGone, evaluatedWith: splashScreenLabel, handler: nil)
            waitForExpectations(timeout: 3.0) { error in
                if error != nil {
                    print("Splash screen did not disappear within 3 seconds: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("Splash screen bypassed")
        }
        
        // Check if app is in an unexpected view (e.g., SimulationView) and navigate back
        let backButton = app.buttons["Back"]
        if backButton.waitForExistence(timeout: 1.0) {
            print("Unexpected navigation detected, tapping Back button")
            backButton.tap()
        }
        
        // Wait for main view with retry logic
        let contentView = app.otherElements["Nanotech Toolkit Logo"]
        var exists = contentView.waitForExistence(timeout: 15.0)
        if !exists {
            // Retry once after a short delay
            print("Retrying main view check after 1-second delay")
            Thread.sleep(forTimeInterval: 1.0)
            exists = contentView.waitForExistence(timeout: 5.0)
        }
        
        if !exists {
            let hierarchy = app.debugDescription
            print("Accessibility Hierarchy after 20 seconds: \(hierarchy)")
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .keepAlways
            add(attachment)
            XCTFail("Main content view did not appear within 20 seconds")
        }
        
        // Verify main view by checking navigation tiles
        let simulationTile = app.buttons["Simulation"]
        let logicTile = app.buttons["Logic Design"]
        let circuitTile = app.buttons["Circuit Design"]
        let analysisTile = app.buttons["Analysis"]
        XCTAssertTrue(simulationTile.waitForExistence(timeout: 2.0), "Simulation tile should be visible")
        XCTAssertTrue(logicTile.waitForExistence(timeout: 2.0), "Logic Design tile should be visible")
        XCTAssertTrue(circuitTile.waitForExistence(timeout: 2.0), "Circuit Design tile should be visible")
        XCTAssertTrue(analysisTile.waitForExistence(timeout: 2.0), "Analysis tile should be visible")
        
        XCTAssertTrue(exists, "Main content view should appear")
    }
    
    // Helper function to navigate to Simulation view
    private func navigateToSimulationView() throws {
        try waitForMainView()
        
        let simulationTile = app.buttons["Simulation"]
        XCTAssertTrue(simulationTile.waitForExistence(timeout: 2.0), "Simulation tile should be visible")
        simulationTile.tap()
        
        let welcomeSheet = app.staticTexts["Welcome to the Simulation"]
        if welcomeSheet.waitForExistence(timeout: 2.0) {
            let gotItButton = app.buttons["Got It"]
            XCTAssertTrue(gotItButton.waitForExistence(timeout: 2.0), "Got It button should be visible")
            gotItButton.tap()
        }
        
        let simulationTitle = app.staticTexts["Simulation"]
        XCTAssertTrue(simulationTitle.waitForExistence(timeout: 2.0), "Should navigate to Simulation view")
    }
}
