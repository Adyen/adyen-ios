//
//  AdyenSwiftUITests.swift
//  AdyenSwiftUITests
//
//  Created by Mohamed Eldoheiri on 10/7/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest

class AdyenSwiftUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["-UITests"]
    }

    func testDropInAdvanced() throws {
        app.launch()
        XCTAssertEqual(sessionSwitch.value as! String, "1", "Session switch should be on by default")
        
        // Enabling Advanced Flow
        sessionSwitch.tap()
        XCTAssertEqual(sessionSwitch.value as! String, "0")
        
        app.buttons["Drop In"].tap()

        wait(for: [app.buttons["Pay €174.08"],
                   app.staticTexts["Adyen Demo"],
                   app.buttons["Change Payment Method"]]
        )
    }

    func testCardComponentAdvanced() throws {
        app.launch()
        XCTAssertEqual(sessionSwitch.value as! String, "1", "Session switch should be on by default")
        
        // Enabling Advanced Flow
        sessionSwitch.tap()
        XCTAssertEqual(sessionSwitch.value as! String, "0")
        
        app.buttons["Card"].tap()

        wait(for: [app.buttons["Pay €174.08"],
                   app.staticTexts["Credit Card"],
                   app.textFields["1234 5678 9012 3456"],
                   app.textFields["MM/YY"],
                   app.textFields["3 digits"]]
        )
    }

    // TODO: Enable again once implemented
//    func testSepaComponentAdvanced() throws {
//        app.launch()
//        sessionSwitch.tap() // Enabling Advanced Flow
//        XCTAssertFalse(sessionSwitch.isEnabled)
//        app.buttons["SEPA Direct Debit"].tap()
//
//        wait(for: [app.buttons["Pay €174.08"],
//                   app.staticTexts["SEPA Direct Debit"],
//                   app.textFields["J. Smith"],
//                   app.textFields["NL26 INGB 0336 1691 16"]]
//        )
//    }
    
    private var sessionSwitch: XCUIElement {
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
