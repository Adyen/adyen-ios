//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_documentation(visibility: internal) @testable import Adyen
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
    
    func testViewModelRequiredFields() throws {
        
        let viewModelBuilder = DefaultAddressViewModelBuilder()

        // MARK: Default Cases
        
        // Generic Country Code - All optional fields
        XCTAssertTrue(
            viewModelBuilder.build(context: .init(countryCode: "XX", isOptional: true)).requiredFields.isEmpty
        )
        
        // Generic Country Code
        XCTAssertEqual(
            viewModelBuilder.build(context: .init(countryCode: "XX", isOptional: false)).requiredFields,
            [
                .street,
                .houseNumberOrName,
                .postalCode,
                .city,
                .stateOrProvince
            ]
        )
        
        // MARK: Specific cases
        
        // United States
        XCTAssertEqual(
            viewModelBuilder.build(context: .init(countryCode: "US", isOptional: false)).requiredFields,
            [
                .street,
                .city,
                .postalCode,
                .stateOrProvince
            ]
        )
        
        // Canada
        XCTAssertEqual(
            viewModelBuilder.build(context: .init(countryCode: "CA", isOptional: false)).requiredFields,
            [
                .street,
                .city,
                .postalCode,
                .stateOrProvince
            ]
        )
        
        // Great Britain
        XCTAssertEqual(
            viewModelBuilder.build(context: .init(countryCode: "GB", isOptional: false)).requiredFields,
            [
                .street,
                .city,
                .postalCode,
                .houseNumberOrName
            ]
        )
    }
}
