//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class AffirmComponentTests: XCTestCase {

    private var paymentMethod: PaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!
    private var sut: AffirmComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AffirmPaymentMethod(type: .affirm, name: "Affirm")
        context = Dummy.context(with: nil)
        style = FormComponentStyle()
        sut = AffirmComponent(paymentMethod: paymentMethod,
                              context: context,
                              configuration: AffirmComponent.Configuration(style: style))
    }
    
    override func tearDownWithError() throws {
        paymentMethod = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testComponent_shouldPaymentMethodTypeBeAffirm() throws {
        // Given
        let expectedPaymentMethodType: PaymentMethodType = .affirm
        
        // Then
        let paymentMethodType = sut.paymentMethod.type
        XCTAssertEqual(paymentMethodType, expectedPaymentMethodType)
    }
    
    func testComponent_shouldRequireModalPresentation() throws {
        // Then
        XCTAssertTrue(sut.requiresModalPresentation)
    }
    
    func testCreatePaymentDetails_withSeparateDeliveryAddressDisabled_shouldCreateDetailsWithSameBillingAndDeliveryAddress() throws {
        // Given
        let expectedDeliveryAddress = PostalAddressMocks.newYorkPostalAddress
        sut.firstNameItem?.value = "Katrina"
        sut.lastNameItem?.value = "Del Mar"
        sut.emailItem?.value = "katrina@mail.com"
        sut.phoneItem?.value = "202 555 0146"
        sut.addressItem?.value = expectedDeliveryAddress
        sut.deliveryAddressToggleItem.value = false
        
        // When
        let paymentDetails = try sut.createPaymentDetails()
        
        // Then
        let shopperInformation = try XCTUnwrap(paymentDetails as? ShopperInformation)
        let deliveryAddress = try XCTUnwrap(shopperInformation.deliveryAddress)
        XCTAssertEqual(deliveryAddress, expectedDeliveryAddress)
    }
    
    func testCreatePaymentDetails_withSeparateDeliveryAddressEnabled_shouldCreateDetailsWithDifferentBillingAndDeliveryAddress() throws {
        // Given
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let expectedDeliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        
        sut.firstNameItem?.value = "Katrina"
        sut.lastNameItem?.value = "Del Mar"
        sut.emailItem?.value = "katrina@mail.com"
        sut.phoneItem?.value = "202 555 0146"
        sut.addressItem?.value = billingAddress
        sut.deliveryAddressToggleItem.value = true
        sut.deliveryAddressItem?.value = expectedDeliveryAddress
        
        // When
        let paymentDetails = try sut.createPaymentDetails()
        
        // Then
        let shopperInformation = try XCTUnwrap(paymentDetails as? ShopperInformation)
        let deliveryAddress = try XCTUnwrap(shopperInformation.deliveryAddress)
        XCTAssertTrue(billingAddress != expectedDeliveryAddress)
        XCTAssertEqual(deliveryAddress, expectedDeliveryAddress)
    }
    
    func testDeliveryAddressToggleItem_whenEnabled_shouldUnhideDeliveryAddressItem() throws {
        // When
        sut.deliveryAddressToggleItem.value = true
        
        // Then
        let deliveryAddressItem = try XCTUnwrap(sut.deliveryAddressItem)
        XCTAssertFalse(deliveryAddressItem.isHidden.wrappedValue)
    }
    
    func testDeliveryAddressToggleItem_whenDisabled_shouldHideDeliveryAddressItem() throws {
        // When
        sut.deliveryAddressToggleItem.value = false
        
        // Then
        let deliveryAddressItem = try XCTUnwrap(sut.deliveryAddressItem)
        XCTAssertTrue(deliveryAddressItem.isHidden.wrappedValue)
    }
    
    func testSubmitForm_shouldCallDelegateWithProperParameters() throws {
        // Given
        let sut = AffirmComponent(paymentMethod: paymentMethod,
                                  context: context,
                                  configuration: AffirmComponent.Configuration(style: style))
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        let expectedBillingAddress = PostalAddressMocks.newYorkPostalAddress
        let expectedDeliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
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
        
        wait(for: .seconds(1))
        
        let view: UIView = sut.viewController.view
        
        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.firstName))
        populate(textItemView: firstNameView, with: "Katrina")
        
        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.lastName))
        populate(textItemView: lastNameView, with: "Del Mar")
        
        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.phone))
        populate(textItemView: phoneNumberView, with: "2025550146")
        
        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.email))
        populate(textItemView: emailView, with: "katrina@mail.com")

        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.billingAddress))
        fill(addressView: billingAddressView, with: expectedBillingAddress)

        let deliveryAddressToggleView: FormToggleItemView! = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddressToggle))
        deliveryAddressToggleView.switchControl.isOn = true
        deliveryAddressToggleView.switchControl.sendActions(for: .valueChanged)

        let deliveryAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddress))
        fill(addressView: deliveryAddressView, with: expectedDeliveryAddress)
        
        let submitButton: UIControl = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.payButton))
        submitButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetPhoneExtensions_shouldReturnNonEmptyPhoneExtensionList() throws {
        // When
        let phoneExtensions = sut.phoneExtensions()
        
        // Then
        XCTAssertFalse(phoneExtensions.isEmpty)
    }

    func testAffirmPrefilling_givenDeliveryAddressIsSet() throws {
        // Given
        let config = AffirmComponent.Configuration(style: style,
                                                   shopperInformation: shopperInformation)
        let prefillSut = AffirmComponent(paymentMethod: paymentMethod,
                                         context: context,
                                         configuration: config)
        UIApplication.shared.keyWindow?.rootViewController = prefillSut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = prefillSut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.firstName))
        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = firstNameView.item.value
        XCTAssertEqual(expectedFirstName, firstName)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.lastName))
        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = lastNameView.item.value
        XCTAssertEqual(expectedLastName, lastName)

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.phone))
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
        let phoneNumber = phoneNumberView.item.value
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.email))
        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = emailView.item.value
        XCTAssertEqual(expectedEmail, email)

        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        let deliveryAddressToggleView: FormToggleItemView! = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddressToggle))
        XCTAssertTrue(deliveryAddressToggleView.item.value)

        let deliveryAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddress))
        let expectedDeliveryAddress = try XCTUnwrap(shopperInformation.deliveryAddress)
        let deliveryAddress = deliveryAddressView.item.value
        XCTAssertEqual(expectedDeliveryAddress, deliveryAddress)
    }

    func testAffirmPrefilling_givenDeliveryAddressIsNotSet() throws {
        // Given
        let config = AffirmComponent.Configuration(style: style,
                                                   shopperInformation: shopperInformationNoDeliveryAddress)
        let prefillSut = AffirmComponent(paymentMethod: paymentMethod,
                                         context: context,
                                         configuration: config)
        UIApplication.shared.keyWindow?.rootViewController = prefillSut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = prefillSut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.firstName))
        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = firstNameView.item.value
        XCTAssertEqual(expectedFirstName, firstName)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.lastName))
        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = lastNameView.item.value
        XCTAssertEqual(expectedLastName, lastName)

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.phone))
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.telephoneNumber)
        let phoneNumber = phoneNumberView.item.value
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.email))
        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = emailView.item.value
        XCTAssertEqual(expectedEmail, email)

        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.billingAddress))
        let expectedBillingAddress = try XCTUnwrap(shopperInformation.billingAddress)
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        let deliveryAddressToggleView: FormToggleItemView! = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddressToggle))
        XCTAssertFalse(deliveryAddressToggleView.item.value)

        let deliveryAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddress))
        let expectedDeliveryAddress = PostalAddressMocks.emptyUSPostalAddress
        let deliveryAddress = deliveryAddressView.item.value
        XCTAssertEqual(expectedDeliveryAddress, deliveryAddress)
    }

    func testAffirm_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        wait(for: .seconds(1))

        // Then
        let view: UIView = sut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.firstName))
        let firstName = firstNameView.item.value
        XCTAssertTrue(firstName.isEmpty)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.lastName))
        let lastName = lastNameView.item.value
        XCTAssertTrue(lastName.isEmpty)

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.phone))
        let phoneNumber = phoneNumberView.item.value
        XCTAssertTrue(phoneNumber.isEmpty)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.email))
        let email = emailView.item.value
        XCTAssertTrue(email.isEmpty)

        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.billingAddress))
        let expectedBillingAddress = PostalAddressMocks.emptyUSPostalAddress
        let billingAddress = billingAddressView.item.value
        XCTAssertEqual(expectedBillingAddress, billingAddress)

        let deliveryAddressToggleView: FormToggleItemView! = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddressToggle))
        XCTAssertFalse(deliveryAddressToggleView.item.value)

        let deliveryAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: AffirmViewIdentifier.deliveryAddress))
        let expectedDeliveryAddress = PostalAddressMocks.emptyUSPostalAddress
        let deliveryAddress = deliveryAddressView.item.value
        XCTAssertEqual(expectedDeliveryAddress, deliveryAddress)
    }

    private func testViewWillAppear_shouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        sut = AffirmComponent(paymentMethod: paymentMethod, context: context)
        let mockViewController = UIViewController()

        // When
        sut.viewWillAppear(viewController: mockViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
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
