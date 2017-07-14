//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class SEPADirectDebitTests: TestCase {
    
    func testSuccessfulPayment() {
        let table = app.tables.first
        table.buttons["SEPA Direct Debit"].tap()
        
        // Find the checkout button and ensure it's disabled.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the IBAN.
        ibanField.typeText("nl13test0123456789")
        
        // The checkout button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Enter the name.
        nameField.tap()
        nameField.typeText("A. Klaassen")
        
        // The checkout button should still be disabled while waiting for the user to complete input.
        XCTAssertFalse(checkoutButton.isEnabled)
        
        // Agree to the direct debit.
        agreeButton.tap()
        
        // After selecting the agree button, the checkout button should be enabled.
        XCTAssertTrue(checkoutButton.isEnabled)
        
        // Tap the checkout button.
        checkoutButton.tap()
        
        dismissSuccessAlert()
    }
    
    // MARK: Elements
    
    private var contentView: XCUIElement {
        return app.scrollViews.first
    }
    
    private var ibanField: XCUIElement {
        return contentView.textFields["iban-field"]
    }
    
    private var nameField: XCUIElement {
        return contentView.textFields["name-field"]
    }
    
    private var agreeButton: XCUIElement {
        return contentView.buttons["agree-button"]
    }
    
    private var checkoutButton: XCUIElement {
        return contentView.buttons["checkout-button"]
    }
    
}
