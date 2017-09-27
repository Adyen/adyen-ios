//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class SEPADirectDebitTests: TestCase {
    
    func testSuccessfulPayment() {
        let table = app.tables.first
        table.cells["SEPA Direct Debit"].tap()
        
        // Find the pay button and ensure it's disabled.
        XCTAssertFalse(payButton.isEnabled)
        
        // Enter the IBAN.
        ibanField.typeText("nl13test0123456789")
        
        // The pay button should be disabled while waiting for the user to complete input.
        XCTAssertFalse(payButton.isEnabled)
        
        // Enter the name.
        nameField.tap()
        nameField.typeText("A. Klaassen")
        
        // The pay button should still be disabled while waiting for the user to complete input.
        XCTAssertFalse(payButton.isEnabled)
        
        // Agree to the direct debit.
        consentButton.tap()
        
        // After selecting the consent button, the pay button should be enabled.
        XCTAssertTrue(payButton.isEnabled)
        
        // Tap the pay button.
        payButton.tap()
        
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
    
    private var consentButton: XCUIElement {
        return contentView.buttons["consent-button"]
    }
    
    private var payButton: XCUIElement {
        return contentView.buttons["pay-button"]
    }
    
}
