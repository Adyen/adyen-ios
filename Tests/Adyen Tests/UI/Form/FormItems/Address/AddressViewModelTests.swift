//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class AddressViewModelTests: XCTestCase {

    func testAddressValidation() throws {
        
        var address = PostalAddress()
        XCTAssertFalse(address.satisfies(requiredFields: [.postalCode]))
        
        address.postalCode = ""
        XCTAssertFalse(address.satisfies(requiredFields: [.postalCode]))
        
        address.postalCode = "1234AB"
        XCTAssertTrue(address.satisfies(requiredFields: [.postalCode]))
        
        address.city = "Amsterdam"
        address.country = "NL"
        address.stateOrProvince = "Noord Holland"
        address.street = "Singel"
        address.apartment = "1"
        address.houseNumberOrName = "1"
        XCTAssertTrue(address.satisfies(requiredFields: Set(AddressField.allCases)))
    }
}
