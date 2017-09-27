//
// Copyright (c) 2017 Adyen B.V.
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
            shopperReferenceField.typeText("uitests@uitests.ui")
        }
        
        table.buttons["start-button"].tap()
        
        TestCase.didSetUp = true
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
