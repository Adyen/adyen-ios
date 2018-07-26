//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class IdealTests: TestCase {
    func testSuccessfulPayment() {
        testPayment(withIssuer: "Test Issuer")
        
        dismissSuccessAlert()
    }
    
    func testCancelledPayment() {
        testPayment(withIssuer: "Test Issuer Cancelled")
        
        dismissFailureAlert()
    }
    
    func testRefusedPayment() {
        testPayment(withIssuer: "Test Issuer Refused")
        
        dismissFailureAlert()
    }
    
    private func testPayment(withIssuer issuer: String) {
        selectPaymentMethod("iDEAL")
        
        // Select the issuer.
        app.tables.last.cells[issuer].tap()
        
        // Wait for the continue button to appear in the web view, then select it.
        let continueButton = app.webViews.buttons["Continue"]
        waitForElementToAppear(continueButton)
        continueButton.tap()
    }
    
}
