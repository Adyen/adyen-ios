//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

internal class TestCase: XCTestCase {
    
    internal let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        app.launch()
        
        let table = app.tables.first
        
        let shopperReferenceField = table.textFields["shopper-reference-field"]
        shopperReferenceField.tap()
        shopperReferenceField.typeText("uitests@uitests.ui")
        
        table.buttons["start-button"].tap()
    }
    
    internal func dismissSuccessAlert() {
        let alert = app.alerts["Payment successful"]
        alert.buttons.first.tap()
    }
    
    internal func dismissFailureAlert() {
        let alert = app.alerts["Payment failed"]
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
