//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
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
