//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen
@testable import AdyenComponents

class AtomeComponentUITests: XCTestCase {

    private var paymentMethod: PaymentMethod!
    private var apiContext: APIContext!
    private var style: FormComponentStyle!
    private var sut: AtomeComponent!
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AtomePaymentMethod(type: .atome, name: "Atome")
        apiContext = Dummy.context
        style = FormComponentStyle()
        sut = AtomeComponent(paymentMethod: paymentMethod,
                             apiContext: apiContext,
                             configuration: AtomeComponent.Configuration(style: style))
        configAtomePayLater()
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        apiContext = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testAllRequiredTextField_shouldExist() throws {
        let atomeComponentFirstNameItem = app.otherElements.textFields["AdyenComponents.AtomeComponent.firstNameItem.textField"]
        let atomeComponentlastNameItem = app.otherElements.textFields["AdyenComponents.AtomeComponent.lastNameItem.textField"]
        let atomeComponentPhoneNumberItem = app.otherElements.textFields["AdyenComponents.AtomeComponent.phoneNumberItem.textField"]
        let atomeComponentBillingAddressItem = app.otherElements["AdyenComponents.AtomeComponent.addressItem"]

        // Assert
        XCTAssertTrue(atomeComponentFirstNameItem.exists)
        XCTAssertTrue(atomeComponentlastNameItem.exists)
        XCTAssertTrue(atomeComponentPhoneNumberItem.exists)
        XCTAssertTrue(atomeComponentBillingAddressItem.exists)
    }

    func testPayButton_shouldExist() throws {
        let atomeComponentPayButton = app.otherElements.buttons["AdyenComponents.AtomeComponent.payButtonItem.button"]

        // Assert
        XCTAssertTrue(atomeComponentPayButton.exists)
    }

    func testCompleteAtomeflow_shouldsuccess() {
        let firstNameTextfield = app.otherElements.textFields[AtomeViewIdentifier.firstName]
        firstNameTextfield.tap()
        firstNameTextfield.typeText("John")

        let lastNameTextfield = app.otherElements.textFields[AtomeViewIdentifier.lastName]
        lastNameTextfield.tap()
        lastNameTextfield.typeText("Smith")

        let phoneNumberTextfield = app.otherElements.textFields[AtomeViewIdentifier.phone]
        phoneNumberTextfield.tap()
        phoneNumberTextfield.typeText("80002018")

        let streetTextfield = app.otherElements.textFields[AtomeViewIdentifier.streetName]
        streetTextfield.tap()
        streetTextfield.typeText("North-Ridge")

        let apartmentTextfield = app.otherElements.textFields[AtomeViewIdentifier.apartmentName]
        apartmentTextfield.tap()
        apartmentTextfield.typeText("FlowerStreet Bell")

        let houseNumberTextfield = app.otherElements.textFields[AtomeViewIdentifier.houseNumberOrName]
        houseNumberTextfield.tap()
        houseNumberTextfield.typeText("345")

        let postalCodeTextfield = app.otherElements.textFields[AtomeViewIdentifier.postalCode]
        postalCodeTextfield.tap()
        postalCodeTextfield.typeText("1089")

        app.otherElements.buttons[AtomeViewIdentifier.payButton].tap()

        wait(for: .seconds(5))

        if app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Pay in Browser'")).element.exists {
            app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Pay in Browser'")).element.tap()
            
            XCTAssertTrue(app.webViews.textFields[AtomeViewIdentifier.inputOTP].exists)

            app.otherElements.webViews.textFields[AtomeViewIdentifier.inputOTP].tap()
            app.otherElements.webViews.textFields[AtomeViewIdentifier.inputOTP].typeText("3153")
            
            XCTAssertTrue(app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Next'")).element.exists)

            app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Next'")).element.tap()
            
            wait(for: .seconds(2))

            let confirmButton = app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Confirm payment'"))
            if confirmButton.element.exists {
                confirmButton.element.tap()
            }
            wait(for: .seconds(2))

            app.swipeUp()

            app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Back to merchant'")).element.tap()
            app.alerts["Authorised"].scrollViews.otherElements.buttons["OK"].tap()
        }
    }

    func testCompleteAtomeflow_through_loginRegster_shouldsuccess() {
        let firstNameTextfield = app.otherElements.textFields[AtomeViewIdentifier.firstName]
        firstNameTextfield.tap()
        firstNameTextfield.typeText("John")
        
        let lastNameTextfield = app.otherElements.textFields[AtomeViewIdentifier.lastName]
        lastNameTextfield.tap()
        lastNameTextfield.typeText("Smith")

        let phoneNumberTextfield = app.otherElements.textFields[AtomeViewIdentifier.phone]
        phoneNumberTextfield.tap()
        phoneNumberTextfield.typeText("80002018")

        let streetTextfield = app.otherElements.textFields[AtomeViewIdentifier.streetName]
        streetTextfield.tap()
        streetTextfield.typeText("North-Ridge")

        let apartmentTextfield = app.otherElements.textFields[AtomeViewIdentifier.apartmentName]
        apartmentTextfield.tap()
        apartmentTextfield.typeText("FlowerStreet Bell")

        let houseNumberTextfield = app.otherElements.textFields[AtomeViewIdentifier.houseNumberOrName]
        houseNumberTextfield.tap()
        houseNumberTextfield.typeText("345")

        let postalCodeTextfield = app.otherElements.textFields[AtomeViewIdentifier.postalCode]
        postalCodeTextfield.tap()
        postalCodeTextfield.typeText("1089")

        app.otherElements.buttons[AtomeViewIdentifier.payButton].tap()

        wait(for: .seconds(5))

        if app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Login/Register to Pay'")).element.exists {
            app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Login/Register to Pay'")).element.tap()

            XCTAssertTrue(app.webViews.textFields[AtomeViewIdentifier.inputOTP].exists)

            app.otherElements.webViews.textFields[AtomeViewIdentifier.inputOTP].tap()
            app.otherElements.webViews.textFields[AtomeViewIdentifier.inputOTP].typeText("3153")

            XCTAssertTrue(app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Next'")).element.exists)
            app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Next'")).element.tap()

            wait(for: .seconds(2))

            let confirmButton = app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Confirm payment'"))
            if confirmButton.element.exists {
                confirmButton.element.tap()
            }
            wait(for: .seconds(2))

            app.swipeUp()

            app.webViews.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Back to merchant'")).element.tap()
            app.alerts["Authorised"].scrollViews.otherElements.buttons["OK"].tap()
        }
    }

    // MARK: - Private

    private func configAtomePayLater() {
        app.launch()
        app.navigationBars["Components"].buttons["settings"].tap()

        let tablesQuery = app.tables
        tablesQuery.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Country code'")).element.tap()
        tablesQuery.searchFields.element.tap()

        let singaporeCell = tablesQuery.cells.containing(NSPredicate(format: "label BEGINSWITH 'SG'"))
        singaporeCell.element.tap()

        app.navigationBars.buttons["Configuration"].tap()
        tablesQuery.cells.containing(NSPredicate(format: "label BEGINSWITH 'Set to country'")).element.tap()
        app.navigationBars["Configuration"].buttons["Save"].tap()

        tablesQuery.staticTexts["Drop In"].tap()

        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.buttons.containing(NSPredicate(format: "label BEGINSWITH 'Change Payment Method'")).element.tap()
        tablesQuery.staticTexts["Atome Paylater"].tap()
    }

    private enum AtomeViewIdentifier {
        static let firstName = "AdyenComponents.AtomeComponent.firstNameItem.textField"
        static let lastName = "AdyenComponents.AtomeComponent.lastNameItem.textField"
        static let phone = "AdyenComponents.AtomeComponent.phoneNumberItem.textField"
        static let streetName = "AdyenComponents.AtomeComponent.addressItem.street.textField"
        static let apartmentName = "AdyenComponents.AtomeComponent.addressItem.apartment.textField"
        static let houseNumberOrName = "AdyenComponents.AtomeComponent.addressItem.houseNumberOrName.textField"
        static let postalCode = "AdyenComponents.AtomeComponent.addressItem.postalCode.textField"
        static let payButton = "AdyenComponents.AtomeComponent.payButtonItem.button"
        static let inputOTP = "Input OTP"
    }
}
