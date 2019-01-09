//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class CardsTests: TestCase {
    
    override func setUp() {
        super.setUp()
        setCountry("NL", currency: "EUR")
        startCheckout()
    }
    
    func testSuccessfulPayment() {
        selectPaymentMethod("Credit Card")
        
        // Find the checkout button and ensure it's disabled.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the holder name.
        holderNameField.tap()
        holderNameField.typeText("Checkout Shopper")
        
        // The checkout button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the credit card number.
        numberField.tap()
        numberField.typeText("5555444433331111")
        
        // The checkout button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the expiration date.
        expiryDateField.tap()
        expiryDateField.typeText("1020")
        
        // The checkout button should still be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the CVC.
        cvcField.tap()
        cvcField.typeText("737")
        
        // After completing the input, the checkout button should be enabled.
        XCTAssertTrue(checkoutButton.isEnabled)
        
        // Tap the checkout button.
        checkoutButton.tap()
        
        dismissSuccessAlert()
    }
    
    func testSuccessfulOneClickPayment() {
        selectPaymentMethod()
        
        app.tables.last.cells.first.tap()
        
        // Enter a valid CVC and submit.
        oneClickVerificationAlert.textFields.first.typeText("737")
        oneClickVerificationAlert.buttons.last.tap()
        
        dismissSuccessAlert()
    }
    
    func testOneClickPaymentWithInvalidCVC() {
        selectPaymentMethod()
        
        app.tables.last.cells.first.tap()
        
        // Enter an invalid CVC and submit.
        oneClickVerificationAlert.textFields.first.typeText("123")
        oneClickVerificationAlert.buttons.last.tap()
        
        dismissFailureAlert()
    }
    
    // MARK: Elements
    
    private var contentView: XCUIElement {
        return app.scrollViews.first
    }
    
    private var holderNameField: XCUIElement {
        return contentView.textFields["holder-name-field"]
    }
    
    private var numberField: XCUIElement {
        return contentView.textFields["number-field"]
    }
    
    private var expiryDateField: XCUIElement {
        return contentView.textFields["expiry-date-field"]
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
