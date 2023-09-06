//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class AddressInputFormViewControllerTests: XCTestCase {
    
    override class func setUp() {
        UIApplication.shared.keyWindow?.layer.speed = 10
    }
    
    override class func tearDown() {
        UIApplication.shared.keyWindow?.layer.speed = 1
    }
    
    func testAddressNL() throws {
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        // When
        wait(for: .milliseconds(5))

        let view: UIView = viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.houseNumberOrName"))
        let countryItemView: FormPickerItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.street"))
        let apartmentSuiteItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.apartment"))
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.city"))
        let provinceOrTerritoryItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.stateOrProvince"))
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.postalCode"))

        XCTAssertNil(view.findView(by: "AddressInputFormViewController.billingAddressItem.title"))
        
        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.item.value!.title, "Netherlands")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(apartmentSuiteItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "Province or Territory")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertTrue(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(apartmentSuiteItemView.alertLabel.isHidden)
        XCTAssertTrue(cityItemView.alertLabel.isHidden)
        XCTAssertTrue(provinceOrTerritoryItemView.alertLabel.isHidden)
        XCTAssertTrue(postalCodeItemView.alertLabel.isHidden)
        
        let doneButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        try doneButton.tap()
        
        wait(for: .milliseconds(50))
        
        XCTAssertFalse(houseNumberItemView.alertLabel.isHidden)
        XCTAssertFalse(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(apartmentSuiteItemView.alertLabel.isHidden)
        XCTAssertFalse(cityItemView.alertLabel.isHidden)
        XCTAssertFalse(provinceOrTerritoryItemView.alertLabel.isHidden)
        XCTAssertFalse(postalCodeItemView.alertLabel.isHidden)
    }
    
    func testAddressUS() throws {
        
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "US",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = viewController

        // When
        wait(for: .milliseconds(5))

        let view: UIView = viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.houseNumberOrName"))
        let countryItemView: FormPickerItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.street"))
        let apartmentSuiteItemView = view.findView(with: "AddressInputFormViewController.billingAddress.apartment") as? FormTextInputItemView
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.city"))
        let provinceOrTerritoryItemView: FormPickerItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.stateOrProvince"))
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.postalCode"))
        let searchItemView = view.findView(with: "AddressInputFormViewController.searchBar") as? FormSearchButtonItemView

        // Then
        XCTAssertNil(searchItemView)
        XCTAssertNil(apartmentSuiteItemView)

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.item.value!.title, "United States")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(addressItemView.titleLabel.text, "Address")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "State")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Zip code")

        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertTrue(addressItemView.alertLabel.isHidden)
        XCTAssertTrue(cityItemView.alertLabel.isHidden)
        XCTAssertTrue(postalCodeItemView.alertLabel.isHidden)

        let doneButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        try doneButton.tap()
        
        wait(for: .milliseconds(50))
        
        XCTAssertTrue(houseNumberItemView.alertLabel.isHidden)
        XCTAssertFalse(addressItemView.alertLabel.isHidden)
        XCTAssertFalse(cityItemView.alertLabel.isHidden)
        XCTAssertFalse(postalCodeItemView.alertLabel.isHidden)
    }

    func testAddressUK() throws {
        
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "GB",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)

        wait(for: .milliseconds(5))
        
        let view: UIView = viewController.view

        let houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.houseNumberOrName"))
        let countryItemView: FormPickerItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.country"))
        let addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.street"))
        let apartmentSuiteItemView = view.findView(with: "AddressInputFormViewController.billingAddress.apartment") as? FormTextInputItemView
        let cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.city"))
        let provinceOrTerritoryItemView = view.findView(with: "AddressInputFormViewController.billingAddress.stateOrProvince") as? FormPickerItemView
        let postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.postalCode"))

        XCTAssertNil(apartmentSuiteItemView)
        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.item.value!.title, "United Kingdom")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(cityItemView.titleLabel.text, "City / Town")
        XCTAssertNil(provinceOrTerritoryItemView)
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
    }

    func testAddressSelectCountry() throws {

        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "CA",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)

        wait(for: .milliseconds(5))

        let view: UIView = viewController.view

        var houseNumberItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.houseNumberOrName"))
        var countryItemView: FormPickerItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.country"))
        var addressItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.street"))
        var apartmentSuiteItemView: FormTextInputItemView! = view.findView(with: "AddressInputFormViewController.billingAddress.apartment")
        var cityItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.city"))
        var provinceOrTerritoryItemView: FormPickerItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.stateOrProvince"))
        var postalCodeItemView: FormTextInputItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.postalCode"))

        XCTAssertNil(apartmentSuiteItemView)

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.item.value!.title, "Canada")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "Apartment / Suite (optional)")
        XCTAssertEqual(addressItemView.titleLabel.text, "Address")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "Province or Territory")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertNil(apartmentSuiteItemView)

        countryItemView.item.value = countryItemView.item.selectableValues.first { $0.identifier == "BR" }!

        houseNumberItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.houseNumberOrName"))
        countryItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.country"))
        addressItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.street"))
        apartmentSuiteItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.apartment"))
        cityItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.city"))
        provinceOrTerritoryItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.stateOrProvince"))
        postalCodeItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.billingAddress.postalCode"))

        XCTAssertEqual(countryItemView.titleLabel.text, "Country")
        XCTAssertEqual(countryItemView.item.value!.title, "Brazil")
        XCTAssertEqual(houseNumberItemView.titleLabel.text, "House number")
        XCTAssertEqual(addressItemView.titleLabel.text, "Street")
        XCTAssertEqual(cityItemView.titleLabel.text, "City")
        XCTAssertEqual(provinceOrTerritoryItemView.titleLabel.text, "State")
        XCTAssertEqual(postalCodeItemView.titleLabel.text, "Postal code")
        XCTAssertEqual(apartmentSuiteItemView.titleLabel.text, "Apartment / Suite (optional)")
    }
    
    func testSearchBarVisibility() throws {
        // Given
        
        let searchExpectation = expectation(description: "Search handler triggered")
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "CA",
                prefillAddress: nil,
                searchHandler: { currentInput in
                    XCTAssertEqual(currentInput, .init(country: "CA"))
                    searchExpectation.fulfill()
                }
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)

        wait(for: .milliseconds(5))
        
        let view: UIView = viewController.view
        let searchItemView: FormSearchButtonItemView = try XCTUnwrap(view.findView(with: "AddressInputFormViewController.searchBar"))
        
        _ = searchItemView.becomeFirstResponder()
        
        wait(for: [searchExpectation], timeout: 1)
    }
    
    func testDoneButtonStateNoPrefill() {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: nil,
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)
        self.wait(for: .milliseconds(5))
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            false
        )
    }
    
    func testDoneButtonStatePrefillCountryAddingStreet() {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: .init(country: "US"),
                searchHandler: nil
            )
        )

        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)
        self.wait(for: .milliseconds(5))
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            false
        )
        
        // Adding street name value
        
        let countryItemView: FormPickerItemView? = viewController.view.findView(with: "AddressInputFormViewController.billingAddress.country")
        countryItemView?.item.value = .init(identifier: "DE", title: "DE", subtitle: nil)
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            true
        )
    }
    
    func testDoneButtonStatePrefillCountryAndStreet() {
        
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: .init(country: "NL", street: "Singel"),
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: viewController)
        self.wait(for: .milliseconds(5))
        
        XCTAssertEqual(
            viewController.navigationItem.rightBarButtonItem?.isEnabled,
            true
        )
    }
    
    func testClearShouldAssignEmptyStreet() throws {
        // Given
        let viewController = AddressInputFormViewController(
            viewModel: self.viewModel(
                initialCountry: "NL",
                prefillAddress: .init(country: "NL", street: "Singel"),
                searchHandler: nil
            )
        )
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
        wait(for: .milliseconds(5))
        
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
        wait(for: .milliseconds(5))

        XCTAssertEqual(
            viewController.billingAddressItem.value.street,
            ""
        )
    }
}

private extension AddressInputFormViewControllerTests {
    
    func viewModel(
        initialCountry: String,
        prefillAddress: PostalAddress?,
        searchHandler: AddressInputFormViewController.ShowSearchHandler?
    ) -> AddressInputFormViewController.ViewModel {
        
        .init(
            style: .init(),
            localizationParameters: nil,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            supportedCountryCodes: nil,
            handleShowSearch: searchHandler,
            completionHandler: { _ in }
        )
    }
}
