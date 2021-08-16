//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen
@testable import AdyenComponents

class AffirmComponentTests: XCTestCase {
    
    private var paymentMethod: PaymentMethod!
    private var apiContext: APIContext!
    private var style: FormComponentStyle!
    private var sut: AffirmComponent!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AffirmPaymentMethod(type: "affirm", name: "Affirm")
        apiContext = Dummy.context
        style = FormComponentStyle()
        sut = AffirmComponent(paymentMethod: paymentMethod,
                              apiContext: apiContext,
                              style: style)
    }
    
    override func tearDownWithError() throws {
        paymentMethod = nil
        apiContext = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testComponent_shouldPaymentMethodTypeBeAffirm() throws {
        // Given
        let expectedPaymentMethodType: PaymentMethodType = .affirm
        
        // Then
        let paymentMethodType = sut.paymentMethod.type
        XCTAssertEqual(paymentMethodType, expectedPaymentMethodType.rawValue)
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
        let paymentDetails = sut.createPaymentDetails()
        
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
        let paymentDetails = sut.createPaymentDetails()
        
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
                                  apiContext: apiContext, style: style)
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
        
        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.firstNameItem"))
        populate(textItemView: firstNameView, with: "Katrina")
        
        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.lastNameItem"))
        populate(textItemView: lastNameView, with: "Del Mar")
        
        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.phoneNumberItem"))
        populate(textItemView: phoneNumberView, with: "2025550146")
        
        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.emailItem"))
        populate(textItemView: emailView, with: "katrina@mail.com")
                
        let billingAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.addressItem"))
        fill(addressView: billingAddressView, with: expectedBillingAddress)
                
        let deliveryAddressToggleView: FormToggleItemView! = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.deliveryAddressToggleItem"))
        deliveryAddressToggleView.switchControl.isOn = true
        deliveryAddressToggleView.switchControl.sendActions(for: .valueChanged)
                
        let deliveryAddressView: FormVerticalStackItemView<FormAddressItem> = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.deliveryAddressItem"))
        fill(addressView: deliveryAddressView, with: expectedDeliveryAddress)
        
        let submitButton: UIControl = try XCTUnwrap(view.findView(by: "AdyenComponents.AffirmComponent.payButtonItem.button"))
        submitButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetPhoneExtensions_shouldReturnNonEmptyPhoneExtensionList() throws {
        // When
        let phoneExtensions = sut.getPhoneExtensions()
        
        // Then
        XCTAssertFalse(phoneExtensions.isEmpty)
    }
}
