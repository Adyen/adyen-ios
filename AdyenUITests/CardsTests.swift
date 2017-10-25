//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class CardsTests: TestCase {
    
    func testSuccessfulPayment() {
        let table = app.tables.first
        table.cells["Credit Card"].tap()
        
        // Find the checkout button and ensure it's disabled.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the credit card number.
        numberField.typeText("5555444433331111")
        
        // The checkout button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the expiration date.
        expiryField.tap()
        expiryField.typeText("0818")
        
        // The checkout button should still be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the CVC.
        cvcField.tap()
        cvcField.typeText("737")
        
        // After selecting the agree button, the checkout button should be enabled.
        XCTAssertTrue(checkoutButton.isEnabled)
        
        // Tap the checkout button.
        checkoutButton.tap()
        
        dismissSuccessAlert()
    }
    
    func testSuccessfulOneClickPayment() {
        app.cells.first.tap()
        
        // Enter a valid CVC and submit.
        oneClickVerificationAlert.textFields.first.typeText("737")
        oneClickVerificationAlert.buttons.last.tap()
        
        dismissSuccessAlert()
    }
    
    func testOneClickPaymentWithInvalidCVC() {
        app.cells.first.tap()
        
        // Enter an invalid CVC and submit.
        oneClickVerificationAlert.textFields.first.typeText("123")
        oneClickVerificationAlert.buttons.last.tap()
        
        dismissFailureAlert()
    }
    
    // MARK: Elements
    
    private var contentView: XCUIElement {
        return app.scrollViews.first
    }
    
    private var numberField: XCUIElement {
        return contentView.textFields["number-field"]
    }
    
    private var expiryField: XCUIElement {
        return contentView.textFields["expiry-field"]
    }
    
    private var cvcField: XCUIElement {
        return contentView.textFields["cvc-field"]
    }
    
    private var checkoutButton: XCUIElement {
        return contentView.buttons["pay-button"]
    }
    
    private var oneClickVerificationAlert: XCUIElement {
        return app.alerts["Verify your card"]
    }
    
}
