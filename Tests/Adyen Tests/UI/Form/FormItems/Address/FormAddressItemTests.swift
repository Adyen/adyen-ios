//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormAddressItemTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        AdyenAssertion.listener = nil
    }
    
    func testCountryPickerItemUpdate() throws {
        
        let formAddressItem = FormAddressItem(
            initialCountry: "NL",
            style: .init(),
            supportedCountryCodes: ["NL", "US"],
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertEqual(formAddressItem.countryPickerItem.value.identifier, "NL")
        
        formAddressItem.value = .init(country: "US")
        XCTAssertEqual(formAddressItem.countryPickerItem.value.identifier, "US")
    }
    
    func testCountryPickerItemUpdateUnsupportedCountry() throws {
        
        let formAddressItem = FormAddressItem(
            initialCountry: "NL",
            style: .init(),
            supportedCountryCodes: ["NL", "US"],
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        let expectation = XCTestExpectation(description: "Setting unsupported country should fail")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "The provided country 'XX' is not supported per configuration.")
            expectation.fulfill()
        }
        
        formAddressItem.value = .init(country: "XX")
        
        wait(for: [expectation])
    }
}
