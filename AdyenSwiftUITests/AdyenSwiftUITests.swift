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

        XCUIApplication().tables/*@START_MENU_TOKEN@*/.buttons["Drop In"]/*[[".cells.buttons[\"Drop In\"]",".buttons[\"Drop In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertTrue(app.buttons["Pay €174.08"].exists)
        XCTAssertTrue(app.staticTexts["Adyen Demo"].exists)
        XCTAssertTrue(app.buttons["Change Payment Method"].exists)
    }

    func testCardComponent() throws {
        app.launch()
        app.tables/*@START_MENU_TOKEN@*/.buttons["Card"]/*[[".cells.buttons[\"Card\"]",".buttons[\"Card\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

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
