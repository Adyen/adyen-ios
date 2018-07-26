//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

internal class TestCase: XCTestCase {
    internal let app = XCUIApplication()
    
    private static var didSetUp = false
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        app.activate()
        
        let table = app.tables.first
        
        if !TestCase.didSetUp {
            let shopperReferenceField = table.textFields["shopper-reference-field"]
            shopperReferenceField.tap()
            table.buttons["Clear text"].tap()
            shopperReferenceField.typeText("uitests@uitests.ui")
        }
        
        table.buttons["start-button"].tap()
        
        TestCase.didSetUp = true
    }
    
    internal func selectPaymentMethod(_ name: String? = nil) {
        app.buttons["change-payment-method-button"].tap()
        
        if let name = name {
            let table = app.tables.last
            table.cells[name].tap()
        }
    }
    
    internal func dismissSuccessAlert() {
        let alert = app.alerts["Payment successful"]
        waitForElementToAppear(alert)
        alert.buttons.first.tap()
    }
    
    internal func dismissFailureAlert() {
        let alert = app.alerts["Payment failed"]
        waitForElementToAppear(alert)
        alert.buttons.first.tap()
    }
    
    internal func waitForElementToAppear(_ element: XCUIElement) {
        guard element.exists == false else {
            return
        }
        
        let predicate = NSPredicate(format: "exists == true")
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}
