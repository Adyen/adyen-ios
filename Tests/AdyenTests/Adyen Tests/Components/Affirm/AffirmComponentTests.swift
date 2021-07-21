//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen
@testable import AdyenComponents

class AffirmComponentTests: XCTestCase {
    
    private var sut: AffirmComponent!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let paymentMethod = AffirmPaymentMethod(type: "affirm", name: "Affirm")
        let style = FormComponentStyle()
        sut = AffirmComponent(paymentMethod: paymentMethod,
                              apiContext: Dummy.context, style: style)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testCreatePaymentDetails_withSeparateDeliveryAddressDisabled_shouldCreateDetailsWithSameBillingAndDeliveryAddress() throws {
        // Given
        let expectedDeliveryAddress = PostalAddress(city: "New York",
                                                    country: "US",
                                                    houseNumberOrName: "14",
                                                    postalCode: "10019",
                                                    stateOrProvince: "New York",
                                                    street: "8th Ave",
                                                    apartment: "8")
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
        let billingAddress = PostalAddress(city: "New York",
                                           country: "US",
                                           houseNumberOrName: "14",
                                           postalCode: "10019",
                                           stateOrProvince: "New York",
                                           street: "8th Ave",
                                           apartment: "8")
        let expectedDeliveryAddress = PostalAddress(city: "Los Angeles",
                                                    country: "US",
                                                    houseNumberOrName: "3310",
                                                    postalCode: "90040",
                                                    stateOrProvince: "California",
                                                    street: "Garfield Ave",
                                                    apartment: "24")
        sut.firstNameItem?.value = "Katrina"
        sut.lastNameItem?.value = "Del Mar"
        sut.emailItem?.value = "katrina@mail.com"
        sut.phoneItem?.value = "202 555 0146"
        sut.addressItem?.value = billingAddress
        sut.deliveryAddressToggleItem.value = true
        sut.deliveryAddressItem.value = expectedDeliveryAddress
        
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
        XCTAssertFalse(sut.deliveryAddressItem.isHidden.wrappedValue)
    }
    
    func testDeliveryAddressToggleItem_whenDisabled_shouldHideDeliveryAddressItem() throws {
        // When
        sut.deliveryAddressToggleItem.value = false
        
        // Then
        XCTAssertTrue(sut.deliveryAddressItem.isHidden.wrappedValue)
    }
}
