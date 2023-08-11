//
//  AdyenSwiftUITests.swift
//  AdyenSwiftUITests
//
//  Created by Mohamed Eldoheiri on 10/7/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest

class AdyenSwiftUITests: XCTestCase {

    func buildTestableApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        return app
    }

    func testDropInAdvanced() throws {
        
        let app = buildTestableApp()
        app.launch()
        let sessionSwitch = sessionSwitch(in: app)
        
        XCTAssertEqual(sessionSwitch.value as! String, "1", "Session switch should be on by default")
        
        // Enabling Advanced Flow
        sessionSwitch.tap()
        wait { (sessionSwitch.value as! String) == "0" }
        
        app.buttons["Drop In"].tap()

        wait(for: [app.buttons["Pay €174.08"],
                   app.staticTexts["Adyen Demo"],
                   app.buttons["Change Payment Method"]]
        )
    }

    func testCardComponentAdvanced() throws {
        
        let app = buildTestableApp()
        app.launch()
        let sessionSwitch = sessionSwitch(in: app)
        
        XCTAssertEqual(sessionSwitch.value as! String, "1", "Session switch should be on by default")
        
        // Enabling Advanced Flow
        sessionSwitch.tap()
        wait { (sessionSwitch.value as! String) == "0" }
        
        app.buttons["Card"].tap()

        wait(for: [app.buttons["Pay €174.08"],
                   app.staticTexts["Credit Card"],
                   app.textFields["1234 5678 9012 3456"],
                   app.textFields["MM/YY"],
                   app.textFields["3 digits"]]
        )
    }
    
    private func sessionSwitch(in app: XCUIApplication) -> XCUIElement {
        
        app.switches["sessionSwitch"]
            .children(matching: .switch)
            .firstMatch
    }

    private func wait(for elements: [XCUIElement]) {
        elements.forEach {
            let predicate = NSPredicate(format: "exists == 1")

            expectation(for: predicate, evaluatedWith: $0, handler: nil)
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
}
