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
    }

    func testDropIn() throws {
        app.launch()

        XCUIApplication().tables.buttons["Drop In"].tap()
        XCTAssertTrue(app.buttons["Pay €174.08"].exists)
        XCTAssertTrue(app.staticTexts["Adyen Demo"].exists)
        XCTAssertTrue(app.buttons["Change Payment Method"].exists)
    }

    func testCardComponent() throws {
        app.launch()
        app.tables.buttons["Card"].tap()

        XCTAssertTrue(app.buttons["Pay €174.08"].exists)
        XCTAssertTrue(app.staticTexts["Credit Card"].exists)
        XCTAssertTrue(app.textFields["1234 5678 9012 3456"].exists)
        XCTAssertTrue(app.textFields["MM/YY"].exists)
        XCTAssertTrue(app.textFields["3 digits"].exists)
    }

    func testSepaComponent() throws {
        app.launch()
        app.tables.buttons["SEPA Direct Debit"].tap()

        XCTAssertTrue(app.buttons["Pay €174.08"].exists)
        XCTAssertTrue(app.staticTexts["SEPA Direct Debit"].exists)
        XCTAssertTrue(app.textFields["J. Smith"].exists)
        XCTAssertTrue(app.textFields["NL26 INGB 0336 1691 16"].exists)
    }
}
