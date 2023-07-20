//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormAddressLookupItemTests: XCTestCase {
    
    func testEmptyPrefillAddress() {
        
        let addressLookupItem = FormAddressLookupItem(
            initialCountry: "NL",
            prefillAddress: nil,
            style: .init(),
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertNil(addressLookupItem.value)
        XCTAssertFalse(addressLookupItem.isValid())
        
        addressLookupItem.updateOptionalStatus(isOptional: true)
        
        XCTAssertTrue(addressLookupItem.isValid())
    }
    
    func testPrefillAddress() {
        
        let addressLookupItem = FormAddressLookupItem(
            initialCountry: "NL",
            prefillAddress: PostalAddressMocks.singaporePostalAddress,
            style: .init(),
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertEqual(addressLookupItem.value, PostalAddressMocks.singaporePostalAddress)
        XCTAssertTrue(addressLookupItem.isValid())
    }
    
    func testValidationFailureMessage() {
        
        let addressLookupItem = FormAddressLookupItem(
            initialCountry: "NL",
            prefillAddress: nil,
            style: .init(),
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertEqual(addressLookupItem.validationFailureMessage, "Address required")
        addressLookupItem.value = PostalAddressMocks.emptyUSPostalAddress
        XCTAssertEqual(addressLookupItem.validationFailureMessage, "Invalid Address")
    }
    
    func testFormattedValue() {
        let addressLookupItem = FormAddressLookupItem(
            initialCountry: "NL",
            prefillAddress: nil,
            style: .init(),
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertNil(addressLookupItem.formattedValue)
        addressLookupItem.value = PostalAddress(country: "NL")
        XCTAssertEqual(addressLookupItem.formattedValue, "Netherlands")
    }
}
