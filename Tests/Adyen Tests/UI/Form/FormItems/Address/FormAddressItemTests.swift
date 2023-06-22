//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormAddressItemTests: XCTestCase {

    func testCountrySelectItemUpdate() throws {
        
        let formAddressItem = FormAddressItem(
            initialCountry: "NL",
            style: .init(),
            supportedCountryCodes: ["NL", "US"],
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertEqual(formAddressItem.countrySelectItem.value.identifier, "NL")
        
        formAddressItem.value = .init(country: "US")
        XCTAssertEqual(formAddressItem.countrySelectItem.value.identifier, "US")
    }
}
