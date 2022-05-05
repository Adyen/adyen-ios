//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest

class AffirmComponentTests: XCTestCase {
    
    private var paymentMethod: PaymentMethod!
    private var apiContext: APIContext!
    private var style: FormComponentStyle!
    private var sut: AffirmComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = AffirmPaymentMethod(type: .affirm, name: "Affirm")
        apiContext = Dummy.context
        style = FormComponentStyle()
        sut = AffirmComponent(paymentMethod: paymentMethod,
                              apiContext: apiContext,
                              configuration: AffirmComponent.Configuration(style: style))
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
    
    func testGetPhoneExtensions_shouldReturnNonEmptyPhoneExtensionList() throws {
        // When
        let phoneExtensions = sut.phoneExtensions()
        
        // Then
        XCTAssertFalse(phoneExtensions.isEmpty)
    }

}
