//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents

class AffirmComponentUITests: XCTestCase {

    private var paymentMethod: PaymentMethod!
    private var context = Dummy.context
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AtomePaymentMethod(type: .atome, name: "Affirm")
        style = FormComponentStyle()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        style = nil
        BrowserInfo.cachedUserAgent = nil
        try super.tearDownWithError()
    }

    func testSubmitForm_shouldCallDelegateWithProperParameters() throws {
        // Given
        let expectedBillingAddress = PostalAddressMocks.newYorkPostalAddress
        let expectedDeliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let sut = AffirmComponent(paymentMethod: paymentMethod,
                                  context: Dummy.context(with: nil),
                                  configuration: AffirmComponent.Configuration(style: style,
                                                                               shopperInformation: PrefilledShopperInformation(
                                                                                   shopperName: ShopperName(
                                                                                       firstName: "Katrina",
                                                                                       lastName: "Del Mar"
                                                                                   ),
                                                                                   emailAddress: "katrina@mail.com",
                                                                                   telephoneNumber: "2025550146",
                                                                                   billingAddress: expectedBillingAddress,
                                                                                   deliveryAddress: expectedDeliveryAddress
                                                                               )))
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        
        setupRootViewController(sut.viewController)

        // Then
        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! AffirmDetails
            XCTAssertEqual(details.shopperName?.firstName, "Katrina")
            XCTAssertEqual(details.shopperName?.lastName, "Del Mar")
            XCTAssertEqual(details.telephoneNumber, "2025550146")
            XCTAssertEqual(details.emailAddress, "katrina@mail.com")
            XCTAssertEqual(details.billingAddress, expectedBillingAddress)
            XCTAssertEqual(details.deliveryAddress, expectedDeliveryAddress)
            
            sut.stopLoadingIfNeeded()
            didSubmitExpectation.fulfill()
        }

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "shopper-info-prefilled")
        
        let view: UIView = sut.viewController.view
        let submitButton: UIControl = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.payButton))
        submitButton.sendActions(for: .touchUpInside)
        
        XCTAssertNotNil(view.findView(by: "AdyenComponents.AffirmComponent.addressItem"))
        XCTAssertNotNil(view.findView(by: "AdyenComponents.AffirmComponent.addressItem.title"))

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAffirmPrefilling_givenDeliveryAddressIsSet() throws {
        // Given
        let config = AffirmComponent.Configuration(style: style,
                                                   shopperInformation: shopperInformation)
        let prefillSut = AffirmComponent(paymentMethod: paymentMethod,
                                         context: context,
                                         configuration: config)
        
        setupRootViewController(prefillSut.viewController)

        // Then

        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = try XCTUnwrap(prefillSut.firstNameItem?.value)
        XCTAssertEqual(expectedFirstName, firstName)

        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = try XCTUnwrap(prefillSut.lastNameItem?.value)
        XCTAssertEqual(expectedLastName, lastName)

        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
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
        
        assertViewControllerImage(matching: prefillSut.viewController, named: "shopper-info-prefilled")
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

        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
        let phoneNumber = try XCTUnwrap(prefillSut.phoneItem?.value)
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)

        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = try XCTUnwrap(prefillSut.emailItem?.value)
        XCTAssertEqual(expectedEmail, email)

        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = try XCTUnwrap(prefillSut.addressItem?.value)
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        XCTAssertFalse(prefillSut.deliveryAddressToggleItem.value)

        let expectedDeliveryAddress = PostalAddressMocks.emptyUSPostalAddress
        let deliveryAddress = try XCTUnwrap(prefillSut.deliveryAddressItem?.value)
        XCTAssertEqual(expectedDeliveryAddress, deliveryAddress)
        
        assertViewControllerImage(matching: prefillSut.viewController, named: "shopper-info-prefilled")
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

        let expectedBillingAddress = PostalAddressMocks.emptyUSPostalAddress
        let billingAddress = try XCTUnwrap(sut.addressItem?.value)
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        XCTAssertFalse(sut.deliveryAddressToggleItem.value)

        let expectedDeliveryAddress = PostalAddressMocks.emptyUSPostalAddress
        let deliveryAddress = try XCTUnwrap(sut.deliveryAddressItem?.value)
        XCTAssertEqual(expectedDeliveryAddress, deliveryAddress)
        
        assertViewControllerImage(matching: sut.viewController, named: "shopper-info-not-filled")
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
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }

    private var shopperInformationNoDeliveryAddress: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: nil,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }

}
