//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents

class AffirmComponentUITests: XCTestCase {
    
    private var paymentMethod: PaymentMethod { AtomePaymentMethod(type: .atome, name: "Affirm") }
    private var style: FormComponentStyle { FormComponentStyle() }

    override func setUpWithError() throws {
        try super.setUpWithError()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    override func tearDownWithError() throws {
        BrowserInfo.cachedUserAgent = nil
        try super.tearDownWithError()
    }

    func testSubmitForm_shouldCallDelegateWithProperParameters() throws {
        // Given
        let expectedBillingAddress = PostalAddressMocks.newYorkPostalAddress
        let expectedDeliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let sut = AffirmComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context(with: nil),
            configuration: AffirmComponent.Configuration(
                style: style,
                shopperInformation: PrefilledShopperInformation(
                    shopperName: .init(
                        firstName: "Katrina",
                        lastName: "Del Mar"
                    ),
                    emailAddress: "katrina@mail.com",
                    phoneNumber: .init(
                        value: "2025550146",
                        callingCode: "+1"
                    ),
                    billingAddress: expectedBillingAddress,
                    deliveryAddress: expectedDeliveryAddress
                )
            )
        )
        
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)

        // Then
        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.didSubmitClosure = { data, component in
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! AffirmDetails
            XCTAssertEqual(details.shopperName?.firstName, "Katrina")
            XCTAssertEqual(details.shopperName?.lastName, "Del Mar")
            XCTAssertEqual(details.telephoneNumber, "+12025550146")
            XCTAssertEqual(details.emailAddress, "katrina@mail.com")
            XCTAssertEqual(details.billingAddress, expectedBillingAddress)
            XCTAssertEqual(details.deliveryAddress, expectedDeliveryAddress)

            sut.stopLoadingIfNeeded()
            
            self.verifyViewControllerImage(matching: sut.viewController, named: "shopper-info-prefilled")
            
            didSubmitExpectation.fulfill()
        }

        let view: UIView = sut.viewController.view
        
        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.firstName))
        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.lastName))
        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.phone))
        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.email))
        
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.billingAddress))
        let deliveryAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddress))
        
        wait(until: firstNameView, at: \.isValid, is: true)
        wait(until: lastNameView, at: \.isValid, is: true)
        wait(until: phoneNumberView, at: \.isValid, is: true)
        wait(until: emailView, at: \.isValid, is: true)
        
        wait(until: billingAddressView, at: \.isValid, is: true)
        wait(until: deliveryAddressView, at: \.isValid, is: true)
        
        let submitButton: UIControl = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.payButton))
        submitButton.sendActions(for: .touchUpInside)

        wait(for: [didSubmitExpectation], timeout: 100)
    }

    func testAffirmPrefilling_givenDeliveryAddressIsSet() throws {
        // Given
        let config = AffirmComponent.Configuration(
            style: style,
            shopperInformation: shopperInformation
        )
        let prefillSut = AffirmComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: config
        )
        
        setupRootViewController(prefillSut.viewController)

        // Then

        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = try XCTUnwrap(prefillSut.firstNameItem?.value)
        XCTAssertEqual(expectedFirstName, firstName)

        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = try XCTUnwrap(prefillSut.lastNameItem?.value)
        XCTAssertEqual(expectedLastName, lastName)

        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.phoneNumber?.value)
        let phoneNumber = try XCTUnwrap(prefillSut.phoneItem?.value)
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)

        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = try XCTUnwrap(prefillSut.emailItem?.value)
        XCTAssertEqual(expectedEmail, email)

        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = try XCTUnwrap(prefillSut.addressItem?.value)
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        XCTAssertTrue(prefillSut.deliveryAddressToggleItem.value)

        let expectedDeliveryAddress = try XCTUnwrap(shopperInformation.deliveryAddress)
        let deliveryAddress = try XCTUnwrap(prefillSut.deliveryAddressItem?.value)
        XCTAssertEqual(expectedDeliveryAddress, deliveryAddress)
        
        let view = try XCTUnwrap(prefillSut.viewController.view)
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: "addressItem"))
        wait(until: billingAddressView, at: \.isValid, is: true)
        
        endEditing(for: prefillSut.viewController.view)
        
        verifyViewControllerImage(matching: prefillSut.viewController, named: "shopper-info-prefilled-address-set")

    }

    func testAffirmPrefilling_givenDeliveryAddressIsNotSet() throws {
        // Given
        let config = AffirmComponent.Configuration(style: style,
                                                   shopperInformation: shopperInformationNoDeliveryAddress)
        let prefillSut = AffirmComponent(paymentMethod: paymentMethod,
                                         context: Dummy.context(with: nil),
                                         configuration: config)
        
        setupRootViewController(prefillSut.viewController)

        // Then
        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = try XCTUnwrap(prefillSut.firstNameItem?.value)
        XCTAssertEqual(expectedFirstName, firstName)

        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = try XCTUnwrap(prefillSut.lastNameItem?.value)
        XCTAssertEqual(expectedLastName, lastName)

        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.phoneNumber?.value)
        let phoneNumber = try XCTUnwrap(prefillSut.phoneItem?.value)
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)

        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = try XCTUnwrap(prefillSut.emailItem?.value)
        XCTAssertEqual(expectedEmail, email)

        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = try XCTUnwrap(prefillSut.addressItem?.value)
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        XCTAssertFalse(prefillSut.deliveryAddressToggleItem.value)

        let deliveryAddress = try XCTUnwrap(prefillSut.deliveryAddressItem)
        XCTAssertNil(deliveryAddress.value)
        
        let view = try XCTUnwrap(prefillSut.viewController.view)
        let billingAddressView: FormAddressPickerItemView = try XCTUnwrap(view.findView(by: "addressItem"))
        wait(until: billingAddressView, at: \.isValid, is: true)
        
        endEditing(for: prefillSut.viewController.view)
        
        verifyViewControllerImage(matching: prefillSut.viewController, named: "shopper-info-prefilled-address-not-set")
    }

    func testAffirm_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        let context = Dummy.context(with: Payment(amount: .init(value: 100, currencyCode: "USD"),
                                                  countryCode: "US"))
        let sut = AffirmComponent(paymentMethod: paymentMethod,
                                  context: context)
        
        setupRootViewController(sut.viewController)

        // Then
        let firstName = try XCTUnwrap(sut.firstNameItem?.value)
        XCTAssertTrue(firstName.isEmpty)

        let lastName = try XCTUnwrap(sut.lastNameItem?.value)
        XCTAssertTrue(lastName.isEmpty)

        let phoneNumber = try XCTUnwrap(sut.phoneItem?.value)
        XCTAssertTrue(phoneNumber.isEmpty)

        let email = try XCTUnwrap(sut.emailItem?.value)
        XCTAssertTrue(email.isEmpty)

        let billingAddress = try XCTUnwrap(sut.addressItem)
        XCTAssertNil(billingAddress.value)

        XCTAssertFalse(sut.deliveryAddressToggleItem.value)

        let deliveryAddress = try XCTUnwrap(sut.deliveryAddressItem)
        XCTAssertNil(deliveryAddress.value)
        
        endEditing(for: sut.viewController.view)
        
        verifyViewControllerImage(matching: sut.viewController, named: "shopper-info-not-filled")
    }

    // MARK: - Private

    private enum AffirmViewIdentifier {
        static let firstName = "AdyenComponents.AffirmComponent.firstNameItem"
        static let lastName = "AdyenComponents.AffirmComponent.lastNameItem"
        static let phone = "AdyenComponents.AffirmComponent.phoneNumberItem"
        static let email = "AdyenComponents.AffirmComponent.emailItem"
        static let billingAddress = "AdyenComponents.AffirmComponent.addressItem"
        static let deliveryAddress = "AdyenComponents.AffirmComponent.deliveryAddressItem"
        static let deliveryAddressToggle = "AdyenComponents.AffirmComponent.deliveryAddressToggleItem"
        static let payButton = "AdyenComponents.AffirmComponent.payButtonItem.button"
    }

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             phoneNumber: PhoneNumber(value: "123456677", callingCode: "+1"),
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }

    private var shopperInformationNoDeliveryAddress: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             phoneNumber: PhoneNumber(value: "123456677", callingCode: "+1"),
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: nil,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }

}
