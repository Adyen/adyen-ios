//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormAddressPickerItemTests: XCTestCase {
    
    func testEmptyPrefillAddress() {
        
        let addressLookupItem = FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: nil,
            style: .init(),
            presenter: PresenterMock(present: { _, _ in }, dismiss: { _ in })
        )
        
        XCTAssertNil(addressLookupItem.value)
        XCTAssertFalse(addressLookupItem.isValid())
        
        addressLookupItem.updateOptionalStatus(isOptional: true)
        
        XCTAssertTrue(addressLookupItem.isValid())
    }
    
    func testPrefillAddress() {
        
        let addressLookupItem = FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: PostalAddressMocks.singaporePostalAddress,
            style: .init(),
            presenter: PresenterMock(present: { _, _ in }, dismiss: { _ in })
        )
        
        XCTAssertEqual(addressLookupItem.value, PostalAddressMocks.singaporePostalAddress)
        XCTAssertTrue(addressLookupItem.isValid())
    }
    
    func testValidationFailureMessage() {
        
        let addressLookupItem = FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: nil,
            style: .init(),
            presenter: PresenterMock(present: { _, _ in }, dismiss: { _ in })
        )
        
        XCTAssertEqual(addressLookupItem.validationFailureMessage, "Address required")
        addressLookupItem.value = PostalAddressMocks.emptyUSPostalAddress
        XCTAssertEqual(addressLookupItem.validationFailureMessage, "Invalid Address")
    }
    
    func testFormattedValue() {
        let addressLookupItem = FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: nil,
            style: .init(),
            presenter: PresenterMock(present: { _, _ in }, dismiss: { _ in })
        )
        
        XCTAssertNil(addressLookupItem.formattedValue)
        addressLookupItem.value = PostalAddress(country: "NL")
        XCTAssertEqual(addressLookupItem.formattedValue, "Netherlands")
    }
}
