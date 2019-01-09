//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

class KlarnaTests: TestCase {
    
    func testKlarnaFlowForNetherlands() {
        setCountry("NL", currency: "EUR")
        startCheckout()
        
        selectPaymentMethod("Achteraf betalen. Klarna.")
        
        // Personal details
        firstNameField.typeText("Testperson-nl")
        lastNameField.tapAndType("Approved")
        setDate(day: "10", month: "July", year: "1970")
        telephoneNumberField.tapAndType("0612345678")
        emailField.tapAndType("youremail@email.com")
        
        // Address
        streetField.tapAndType("Neherkade")
        houseNumberField.tapAndType("1")
        cityField.tapAndType("Gravenhage")
        postalCodeField.tapAndType("2521VA")
        
        // Pay
        payButton.tap()
        dismissSuccessAlert()
    }
    
    func testKlarnaFlowForNorway() {
        setCountry("NO", currency: "NOK")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")
        
        // Personal details
        firstNameField.typeText("Testperson-no")
        lastNameField.tapAndType("Approved")
        telephoneNumberField.tapAndType("40 123 456")
        emailField.tapAndType("youremail@email.com")
        ssnField.tapAndType("01087000571")
        
        // Address
        streetField.tapAndType("Sæffleberggate")
        houseNumberField.tapAndType("56")
        cityField.tapAndType("Oslo")
        postalCodeField.tapAndType("0563")
        
        // Pay
        payButton.tap()
        dismissSuccessAlert()
    }
    
    func testKlarnaFlowForSweden() {
        setCountry("SE", currency: "SEK")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")
        
        // Personal details
        ssnField.tapAndType("4103219202")
        
        waitForElementToAppear(telephoneNumberField)
        
        telephoneNumberField.tapAndType("0765260000")
        emailField.tapAndType("youremail@email.com")
        
        // Pay
        payButton.tap()
        dismissSuccessAlert()
    }
    
    func testKlarnaFlowForFinland() {
        setCountry("FI", currency: "EUR")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")
        
        // Personal details
        firstNameField.typeText("Testperson-fi")
        lastNameField.tapAndType("Approved")
        telephoneNumberField.tapAndType("0401234567")
        emailField.tapAndType("youremail@email.com")
        ssnField.tapAndType("190122-829F")
        
        // Address
        streetField.tapAndType("Kiväärikatu")
        houseNumberField.tapAndType("10")
        cityField.tapAndType("Pori")
        postalCodeField.tapAndType("28100")
        
        // Pay
        payButton.tap()
        dismissSuccessAlert()
    }
    
    func testKlarnaFlowForGermany() {
        setCountry("DE", currency: "EUR")
        startCheckout()
        selectPaymentMethod("Achteraf betalen. Klarna.")
        
        // Personal details
        firstNameField.typeText("Testperson-de")
        lastNameField.tapAndType("Approved")
        telephoneNumberField.tapAndType("01522113356")
        emailField.tapAndType("youremail@email.com")
        setDate(day: "7", month: "July", year: "1960")
        
        // Address
        streetField.tapAndType("Hellersbergstraße")
        houseNumberField.tapAndType("14")
        cityField.tapAndType("Neuss")
        postalCodeField.tapAndType("41460")
        
        consentButton.tap()
        
        // Pay
        payButton.tap()
        dismissSuccessAlert()
    }
    
    // MARK: Helpers
    
    private func setDate(day: String, month: String, year: String) {
        dateField.tap()
        
        app.pickerWheels.allElementsBoundByIndex[0].adjust(toPickerWheelValue: month)
        app.pickerWheels.allElementsBoundByIndex[1].adjust(toPickerWheelValue: day)
        app.pickerWheels.allElementsBoundByIndex[2].adjust(toPickerWheelValue: year)
    }
    
    // MARK: Elements
    
    private var contentView: XCUIElement {
        return app.scrollViews.first
    }
    
    private var firstNameField: XCUIElement {
        return contentView.textFields["first-name-field"]
    }
    
    private var lastNameField: XCUIElement {
        return contentView.textFields["last-name-field"]
    }
    
    private var genderField: XCUIElement {
        return contentView.buttons["gender-field"]
    }
    
    private var dateField: XCUIElement {
        return contentView.buttons["date-field"]
    }
    
    private var telephoneNumberField: XCUIElement {
        return contentView.textFields["telephone-number-field"]
    }
    
    private var emailField: XCUIElement {
        return contentView.textFields["email-field"]
    }
    
    private var ssnField: XCUIElement {
        return contentView.textFields["social-security-number-field"]
    }
    
    private var streetField: XCUIElement {
        return contentView.textFields["street-field"]
    }
    
    private var houseNumberField: XCUIElement {
        return contentView.textFields["house-number-field"]
    }
    
    private var cityField: XCUIElement {
        return contentView.textFields["city-field"]
    }
    
    private var postalCodeField: XCUIElement {
        return contentView.textFields["postal-code-field"]
    }
    
    private var payButton: XCUIElement {
        return contentView.buttons["pay-button"]
    }
    
    private var consentButton: XCUIElement {
        return contentView.otherElements["consent-button"].switches.first
    }
}
