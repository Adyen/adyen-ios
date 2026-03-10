//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class FormAddressPickerItemTests: XCTestCase {
    
    func test_addressStyle_reflectsComponentStyleChanges() {
        
        var style = FormComponentStyle()
        XCTAssertEqual(style.addressStyle.title, style.sectionHeader)
        XCTAssertEqual(style.addressStyle.textField.title, style.textField.title)
        
        let expectedSectonHeaderStyle = TextStyle(font: .systemFont(ofSize: 200), color: .yellow)
        let expectedTextFieldStyle = FormTextItemStyle(tintColor: .green)
        
        style.sectionHeader = expectedSectonHeaderStyle
        style.textField = expectedTextFieldStyle
        
        XCTAssertEqual(style.addressStyle.title, expectedSectonHeaderStyle)
        XCTAssertEqual(style.addressStyle.textField.title, expectedTextFieldStyle.title)
    }
    
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
    
    func testCancel() throws {
        
        let presentationExpectation = expectation(description: "Address lookup should have been presented")
        let dismissExpectation = expectation(description: "Dismiss should have been presented")
        
        var presentedViewController: UIViewController?
        
        let presenter = PresenterMock(
            present: { viewController, animated in
                presentedViewController = viewController
                presentationExpectation.fulfill()
            },
            dismiss: { animated in
                dismissExpectation.fulfill()
            }
        )
        
        let addressLookupItem = FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: PostalAddressMocks.singaporePostalAddress,
            style: .init(),
            presenter: presenter
        )
        
        XCTAssertEqual(addressLookupItem.value, PostalAddressMocks.singaporePostalAddress)
        XCTAssertTrue(addressLookupItem.isValid())
        
        addressLookupItem.selectionHandler()
        
        wait(for: [presentationExpectation], timeout: 1)
        
        let securedViewController = try XCTUnwrap(presentedViewController as? SecuredViewController<UIViewController>)
        let navigationController = try XCTUnwrap(securedViewController.childViewController as? UINavigationController)
        let addressInputFormViewController = try XCTUnwrap(navigationController.viewControllers.first as? AddressInputFormViewController)
        
        addressInputFormViewController.dismissAddressLookup()
        
        // Dismiss should not affect the value
        XCTAssertEqual(addressLookupItem.value, PostalAddressMocks.singaporePostalAddress)
        
        wait(for: [dismissExpectation], timeout: 1)
    }
    
    func testValueUpdate() throws {
        
        let presentationExpectation = expectation(description: "Address lookup should have been presented")
        let dismissExpectation = expectation(description: "Dismiss should have been presented")
        
        var presentedViewController: UIViewController?
        
        let presenter = PresenterMock(
            present: { viewController, animated in
                presentedViewController = viewController
                presentationExpectation.fulfill()
            },
            dismiss: { animated in
                dismissExpectation.fulfill()
            }
        )
        
        let addressLookupItem = FormAddressPickerItem(
            for: .billing,
            initialCountry: "NL",
            supportedCountryCodes: nil,
            prefillAddress: PostalAddressMocks.singaporePostalAddress,
            style: .init(),
            presenter: presenter
        )
        
        XCTAssertEqual(addressLookupItem.value, PostalAddressMocks.singaporePostalAddress)
        XCTAssertTrue(addressLookupItem.isValid())
        
        addressLookupItem.selectionHandler()
        
        wait(for: [presentationExpectation], timeout: 1)
        
        let securedViewController = try XCTUnwrap(presentedViewController as? SecuredViewController<UIViewController>)
        let navigationController = try XCTUnwrap(securedViewController.childViewController as? UINavigationController)
        let addressInputFormViewController = try XCTUnwrap(navigationController.viewControllers.first as? AddressInputFormViewController)
        
        addressInputFormViewController.addressItem.value = PostalAddressMocks.newYorkPostalAddress
        addressInputFormViewController.submitTapped()
        
        // Dismiss should not affect the value
        XCTAssertEqual(addressLookupItem.value, PostalAddressMocks.newYorkPostalAddress)
        
        wait(for: [dismissExpectation], timeout: 1)
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
    
    // MARK: - PostalAddress formattedSingleLine Tests
    
    func testFormattedSingleLine_withAllComponents_shouldJoinWithCommas() {
        let address = PostalAddress(
            street: "Professor Van Gogh",
            houseNumberOrName: "123",
            apartment: nil,
            postalCode: "1222aa",
            city: "Edam",
            stateOrProvince: "North Holland",
            country: "NL"
        )
        
        let result = address.formattedSingleLine(using: nil)
        
        XCTAssertEqual(result, "Professor Van Gogh 123, 1222aa, Edam, North Holland, Netherlands")
    }
    
    func testFormattedSingleLine_withMinimalComponents_shouldOmitEmptyValues() {
        let address = PostalAddress(
            street: "Main Street",
            houseNumberOrName: "1",
            apartment: nil,
            postalCode: "12345",
            city: "New York",
            stateOrProvince: nil,
            country: "US"
        )
        
        let result = address.formattedSingleLine(using: nil)
        
        XCTAssertEqual(result, "Main Street 1, 12345, New York, United States")
    }
    
    func testFormattedSingleLine_withApartment_shouldIncludeInStreetPart() {
        let address = PostalAddress(
            street: "Oak Avenue",
            houseNumberOrName: "42",
            apartment: "Apt 5B",
            postalCode: "90210",
            city: "Beverly Hills",
            stateOrProvince: "CA",
            country: "US"
        )
        
        let result = address.formattedSingleLine(using: nil)
        
        XCTAssertTrue(result.contains("Oak Avenue 42 Apt 5B"))
        XCTAssertTrue(result.contains("90210"))
        XCTAssertTrue(result.contains("Beverly Hills"))
        XCTAssertTrue(result.contains("CA"))
    }
    
    func testFormattedSingleLine_shouldNotContainNewlines() {
        let address = PostalAddressMocks.newYorkPostalAddress
        
        let result = address.formattedSingleLine(using: nil)
        
        XCTAssertFalse(result.contains("\n"), "Single line format should not contain newlines")
        XCTAssertTrue(result.contains(","), "Single line format should use comma separators")
    }
}
    
    // MARK: - PostalAddress formattedSingleLine Tests
    
    func testFormattedSingleLine_usesLocaleAwareFormatting() {
        // Given - Netherlands address
        let nlAddress = PostalAddress(
            street: "Professor Van Gogh",
            houseNumberOrName: "123",
            apartment: nil,
            postalCode: "1222aa",
            city: "Edam",
            stateOrProvince: nil,
            country: "NL"
        )
        
        // When
        let nlResult = nlAddress.formattedSingleLine(using: nil)
        
        // Then - CNPostalAddressFormatter formats NL addresses as: Street, PostalCode City, Country
        XCTAssertEqual(nlResult, "Professor Van Gogh 123, 1222aa Edam, Netherlands")
    }
    
    func testFormattedSingleLine_withUSAddress_usesUSFormatting() {
        // Given - US address
        let usAddress = PostalAddress(
            street: "Main Street",
            houseNumberOrName: "1",
            apartment: nil,
            postalCode: "12345",
            city: "New York",
            stateOrProvince: "NY",
            country: "US"
        )
        
        // When
        let usResult = usAddress.formattedSingleLine(using: nil)
        
        // Then - CNPostalAddressFormatter formats US addresses as: Street, City State PostalCode, Country
        XCTAssertEqual(usResult, "Main Street 1, New York NY 12345, United States")
    }
    
    func testFormattedSingleLine_withApartment_includesInStreetPart() {
        // Given
        let address = PostalAddress(
            street: "Oak Avenue",
            houseNumberOrName: "42",
            apartment: "Apt 5B",
            postalCode: "90210",
            city: "Beverly Hills",
            stateOrProvince: "CA",
            country: "US"
        )
        
        // When
        let result = address.formattedSingleLine(using: nil)
        
        // Then - Apartment should be included in street portion
        XCTAssertTrue(result.contains("Oak Avenue 42 Apt 5B"))
        XCTAssertTrue(result.contains("Beverly Hills"))
        XCTAssertTrue(result.contains("CA"))
        XCTAssertTrue(result.contains("90210"))
    }
    
    func testFormattedSingleLine_shouldNotContainNewlines() {
        // Given
        let address = PostalAddressMocks.newYorkPostalAddress
        
        // When
        let result = address.formattedSingleLine(using: nil)
        
        // Then
        XCTAssertFalse(result.contains("\n"), "Single line format should not contain newlines")
        XCTAssertTrue(result.contains(","), "Single line format should use comma separators")
    }
}
