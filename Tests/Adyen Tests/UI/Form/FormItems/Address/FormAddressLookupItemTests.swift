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
        
        XCTAssertEqual(addressLookupItem.value, PostalAddress(country: "NL"))
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
        
        XCTAssertEqual(addressLookupItem.validationFailureMessage, "Invalid Address")
        addressLookupItem.value = nil
        XCTAssertEqual(addressLookupItem.validationFailureMessage, "Address required")
    }
    
    func testFormattedValue() {
        let addressLookupItem = FormAddressLookupItem(
            initialCountry: "NL",
            prefillAddress: nil,
            style: .init(),
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertEqual(addressLookupItem.formattedValue, "Netherlands")
    }
}
