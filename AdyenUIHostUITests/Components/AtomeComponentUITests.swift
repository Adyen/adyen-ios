//
// Copyright (c) 2022 Adyen N.V.
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
        let config = AtomeComponent.Configuration(style: style, shopperInformation: shopperInformation)
        sut = AtomeComponent(paymentMethod: paymentMethod,
                             apiContext: apiContext,
                             configuration: config)
        let atomeComponentFirstNameItem = app.otherElements.textFields[AtomeViewIdentifier.firstName]
        let atomeComponentlastNameItem = app.otherElements.textFields[AtomeViewIdentifier.lastName]
        let atomeComponentPhoneNumberItem = app.otherElements.textFields[AtomeViewIdentifier.phone]
        let atomeComponentBillingAddressItem = app.otherElements[AtomeViewIdentifier.billingAddress]

        // Assert
        XCTAssertTrue(atomeComponentFirstNameItem.exists)
        XCTAssertTrue(atomeComponentlastNameItem.exists)
        XCTAssertTrue(atomeComponentPhoneNumberItem.exists)
        XCTAssertTrue(atomeComponentBillingAddressItem.exists)
    }

    func testPayButton_shouldExist() throws {
        let atomeComponentPayButton = app.otherElements.buttons[AtomeViewIdentifier.payButton]

        // Assert
        XCTAssertTrue(atomeComponentPayButton.exists)
    }

    func testSubmitForm_shouldCallDelegateWithProperParameters() {
        let config = AtomeComponent.Configuration(style: style, shopperInformation: shopperInformation)
        sut = AtomeComponent(paymentMethod: paymentMethod,
                             apiContext: apiContext,
                             configuration: config)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        UIApplication.shared.mainKeyWindow?.rootViewController = sut.viewController
        let expectedBillingAddress = PostalAddressMocks.singaporePostalAddress

        // Then
        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            let details = data.paymentMethod as! AtomeDetails
            XCTAssertEqual(details.shopperName?.firstName, "Katrina")
            XCTAssertEqual(details.shopperName?.lastName, "Del Mar")
            XCTAssertEqual(details.telephoneNumber, "80002018")
            XCTAssertEqual(details.billingAddress, expectedBillingAddress)
            self.sut.stopLoadingIfNeeded()
            didSubmitExpectation.fulfill()
        }

        wait(for: .milliseconds(300))

        let view: UIView = sut.viewController.view
        do {
            let submitButton: UIControl =  try XCTUnwrap(view.findView(by: AtomeViewIdentifier.payButton))
            submitButton.sendActions(for: .touchUpInside)
        } catch let error {
            print(error)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAtome_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        sut = AtomeComponent(paymentMethod: paymentMethod,
                              apiContext: apiContext,
                              configuration: AffirmComponent.Configuration(style: style))

        // Then
        let atomeComponentFirstNameItem = app.otherElements.textFields[AtomeViewIdentifier.firstName]
        let firstName: String = atomeComponentFirstNameItem.value as! String

        // Assert
        XCTAssertTrue(firstName.isEmpty)

        let  atomeComponentLastNameItem = app.otherElements.textFields[AtomeViewIdentifier.lastName]
        let lastName: String = atomeComponentLastNameItem.value as! String

        // Assert
        XCTAssertTrue(lastName.isEmpty)

        let atomeComponentPhoneNumber = app.otherElements.textFields[AtomeViewIdentifier.phone]
        let phoneNumber: String = atomeComponentPhoneNumber.value as! String

        // Assert
        XCTAssertTrue(phoneNumber.isEmpty)

        let atomeComponentStreetAddressItem  = app.otherElements.textFields[AtomeViewIdentifier.streetName]
        let streetAddress: String = atomeComponentStreetAddressItem.value as! String

        // Assert
        XCTAssertTrue(streetAddress.isEmpty)

        let atomeComponentApartmentAddressItem  = app.otherElements.textFields[AtomeViewIdentifier.apartmentName]
        let apartmentName: String = atomeComponentApartmentAddressItem.value as! String

        // Assert
        XCTAssertTrue(apartmentName.isEmpty)

        let atomeComponentHouseNumberOrNameAddressItem  = app.otherElements.textFields[AtomeViewIdentifier.houseNumberOrName]
        let houseNumberOrName: String = atomeComponentHouseNumberOrNameAddressItem.value as! String

        // Assert
        XCTAssertTrue(houseNumberOrName.isEmpty)

        let atomeComponentPostalCodeAddressItem  = app.otherElements.textFields[AtomeViewIdentifier.postalCode]
        let postalCode: String = atomeComponentPostalCodeAddressItem.value as! String

        // Assert
        XCTAssertTrue(postalCode.isEmpty)
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
        static let billingAddress = "AdyenComponents.AtomeComponent.addressItem"
        static let streetName = "AdyenComponents.AtomeComponent.addressItem.street.textField"
        static let apartmentName = "AdyenComponents.AtomeComponent.addressItem.apartment.textField"
        static let houseNumberOrName = "AdyenComponents.AtomeComponent.addressItem.houseNumberOrName.textField"
        static let postalCode = "AdyenComponents.AtomeComponent.addressItem.postalCode.textField"
        static let payButton = "AdyenComponents.AtomeComponent.payButtonItem.button"
        static let inputOTP = "Input OTP"
    }

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.singaporePostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina",
                                                                                      lastName: "Del Mar"),
                                                             telephoneNumber: "80002018",
                                                             billingAddress: billingAddress)
        return shopperInformation
    }
}
