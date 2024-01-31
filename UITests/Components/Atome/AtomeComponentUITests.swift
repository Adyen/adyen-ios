//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_documentation(visibility: internal) @testable import Adyen
@testable import AdyenComponents

class AtomeComponentUITests: XCTestCase {

    private var paymentMethod: PaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AtomePaymentMethod(type: .atome, name: "Atome")
        context = Dummy.context
        style = FormComponentStyle()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        context = nil
        style = nil
        BrowserInfo.cachedUserAgent = nil
        try super.tearDownWithError()
    }
    
    func testUIConfiguration() throws {
        style.backgroundColor = .green

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// Text field
        style.textField.text.color = .yellow
        style.textField.text.font = .systemFont(ofSize: 5)
        style.textField.text.textAlignment = .center
        style.textField.placeholderText = TextStyle(font: .preferredFont(forTextStyle: .headline),
                                                    color: .systemOrange,
                                                    textAlignment: .center)
        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .green
        style.textField.title.font = .systemFont(ofSize: 18)
        style.textField.title.textAlignment = .left
        style.textField.backgroundColor = .blue
        let config = AtomeComponent.Configuration(style: style, shopperInformation: shopperInformation)
        let sut = AtomeComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)
        
        XCTAssertNotNil(sut.viewController.view.findView(by: "AdyenComponents.AtomeComponent.addressItem"))
        
        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testAllRequiredTextField_shouldExist() throws {
        let config = AtomeComponent.Configuration(shopperInformation: shopperInformation)
        let sut = AtomeComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)

        assertViewControllerImage(matching: sut.viewController, named: "all_required_fields_exist")
    }

    func testSubmitForm_shouldCallDelegateWithProperParameters() throws {
        let config = AtomeComponent.Configuration(shopperInformation: shopperInformation)
        let sut = AtomeComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let expectedBillingAddress = PostalAddressMocks.singaporePostalAddress
        
        // Then
        assertViewControllerImage(matching: sut.viewController, named: "prefilled_shopper_info")

        // Then
        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! AtomeDetails
            XCTAssertEqual(details.shopperName?.firstName, "Katrina")
            XCTAssertEqual(details.shopperName?.lastName, "Del Mar")
            XCTAssertEqual(details.telephoneNumber, "+11234567")
            XCTAssertEqual(details.billingAddress, expectedBillingAddress)
            sut.stopLoadingIfNeeded()
            didSubmitExpectation.fulfill()
        }

        setupRootViewController(sut.viewController)
        let view: UIView = sut.viewController.view
        
        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.firstName))
        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.lastName))
        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.phone))
        
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.billingAddress))
        
        wait(until: firstNameView, at: \.isValid, is: true)
        wait(until: lastNameView, at: \.isValid, is: true)
        wait(until: phoneNumberView, at: \.isValid, is: true)
        
        wait(until: billingAddressView, at: \.isValid, is: true)
        
        let submitButton: UIControl = try XCTUnwrap(view.findView(by: AtomeViewIdentifier.payButton))
        submitButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAtome_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        let sut = AtomeComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: AtomeComponent.Configuration(style: style))
        
        // Then
        assertViewControllerImage(matching: sut.viewController, named: "empty_form")

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
                                                             phoneNumber: PhoneNumber(value: "1234567", callingCode: "+1"),
                                                             billingAddress: billingAddress)
        return shopperInformation
    }
}
