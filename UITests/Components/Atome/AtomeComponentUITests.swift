//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents

class AtomeComponentUITests: XCTestCase {

    private var paymentMethod: PaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!
    private var sut: AtomeComponent!
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AtomePaymentMethod(type: .atome, name: "Atome")
        app.launchArguments = ["SG", "SGD"]
        context = Dummy.context
        style = FormComponentStyle()
        sut = AtomeComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: AtomeComponent.Configuration(style: style))
        BrowserInfo.cachedUserAgent = "some_value"
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        context = nil
        style = nil
        sut = nil
        BrowserInfo.cachedUserAgent = nil
        try super.tearDownWithError()
    }

    func testAllRequiredTextField_shouldExist() throws {
        let config = AtomeComponent.Configuration(shopperInformation: shopperInformation)
        UIApplication.shared.mainKeyWindow?.rootViewController = sut.viewController
        let sut = AtomeComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)

        let view: UIView = sut.viewController.view

        let atomeComponentFirstNameItem = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.firstName))
        let atomeComponentlastNameItem = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.lastName))
        let atomeComponentPhoneNumberItem = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.phone))
        let atomeComponentBillingAddressItem = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.billingAddress))
        let atomeComponentPayButton = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.payButton))

        // Assert
        XCTAssertTrue(atomeComponentFirstNameItem.isDescendant(of: view))
        XCTAssertTrue(atomeComponentlastNameItem.isDescendant(of: view))
        XCTAssertTrue(atomeComponentPhoneNumberItem.isDescendant(of: view))
        XCTAssertTrue(atomeComponentBillingAddressItem.isDescendant(of: view))
        XCTAssertTrue(atomeComponentPayButton.isDescendant(of: view))
    }

    func testSubmitForm_shouldCallDelegateWithProperParameters() {
        let config = AtomeComponent.Configuration(shopperInformation: shopperInformation)
        let sut = AtomeComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let expectedBillingAddress = PostalAddressMocks.singaporePostalAddress

        UIApplication.shared.mainKeyWindow?.rootViewController = sut.viewController

        // Then
        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
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
            let submitButton: UIControl = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.payButton))
            submitButton.sendActions(for: .touchUpInside)
        } catch {
            print(error)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAtome_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        UIApplication.shared.mainKeyWindow?.rootViewController = sut.viewController

        wait(for: .milliseconds(300))

        let view: UIView = sut.viewController.view

        // Then
        let atomeComponentFirstNameItem: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.firstName))
        let firstName = atomeComponentFirstNameItem.item.value
        XCTAssertTrue(firstName.isEmpty)

        let atomeComponentLastNameItem: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.lastName))
        let lastName = atomeComponentLastNameItem.item.value
        XCTAssertTrue(lastName.isEmpty)

        let atomeComponentPhoneNumber: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.phone))
        let phoneNumber = atomeComponentPhoneNumber.item.value
        XCTAssertTrue(phoneNumber.isEmpty)

        let atomeComponentStreetAddressItem: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.streetName))
        let streetName = atomeComponentStreetAddressItem.item.value
        XCTAssertTrue(streetName.isEmpty)

        let atomeComponentApartmentAddressItem: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.apartmentName))
        let apartmentName = atomeComponentApartmentAddressItem.item.value
        XCTAssertTrue(apartmentName.isEmpty)

        let atomeComponentHouseNumberOrNameAddressItem: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.houseNumberOrName))
        let houseNumberOrName = atomeComponentHouseNumberOrNameAddressItem.item.value
        XCTAssertTrue(houseNumberOrName.isEmpty)

        let atomeComponentPostalCodeAddressItem: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.postalCode))
        let postalCode = atomeComponentPostalCodeAddressItem.item.value
        XCTAssertTrue(postalCode.isEmpty)
    }

    // MARK: - Private

    private enum AtomeViewIdentifier {
        static let firstName = "AdyenComponents.AtomeComponent.firstNameItem"
        static let lastName = "AdyenComponents.AtomeComponent.lastNameItem"
        static let phone = "AdyenComponents.AtomeComponent.phoneNumberItem"
        static let billingAddress = "AdyenComponents.AtomeComponent.addressItem"
        static let streetName = "AdyenComponents.AtomeComponent.addressItem.street"
        static let apartmentName = "AdyenComponents.AtomeComponent.addressItem.apartment"
        static let houseNumberOrName = "AdyenComponents.AtomeComponent.addressItem.houseNumberOrName"
        static let postalCode = "AdyenComponents.AtomeComponent.addressItem.postalCode"
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
