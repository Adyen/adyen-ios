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
            configuration: .init(
                supportedCountryCodes: ["NL", "US"]
            ),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertEqual(formAddressItem.countryPickerItem.value!.identifier, "NL")
        
        formAddressItem.value = .init(country: "US")
        XCTAssertEqual(formAddressItem.countryPickerItem.value!.identifier, "US")
    }
    
    func testCountryPickerItemUpdateUnsupportedCountry() throws {
        
        let formAddressItem = FormAddressItem(
            initialCountry: "NL",
            configuration: .init(
                supportedCountryCodes: ["NL", "US"]
            ),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        let expectation = XCTestExpectation(description: "Setting unsupported country should fail")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "The provided country 'XX' is not supported per configuration.")
            expectation.fulfill()
        }
        
        formAddressItem.value = .init(country: "XX")
        
        wait(for: [expectation], timeout: 0)
    }
    
    func testShowsHeader() throws {
        
        let formAddressItemWithHeader = FormAddressItem(
            initialCountry: "NL",
            configuration: .init(),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertTrue(formAddressItemWithHeader.flatSubitems.contains { $0 === formAddressItemWithHeader.headerItem })
        
        let formAddressItemWithOutHeader = FormAddressItem(
            initialCountry: "NL",
            configuration: .init(showsHeader: false),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        XCTAssertFalse(formAddressItemWithHeader.flatSubitems.contains { $0 === formAddressItemWithOutHeader.headerItem })
    }
    
    func testUpdateContext() {
        
        let expectation = expectation(description: "Should call delegate.didUpdateItems")
        
        let formAddressDelegate = AddressDelegateDummy { items in
            expectation.fulfill()
        }
        
        let formAddressItem = FormAddressItem(
            initialCountry: "NL",
            configuration: .init(),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        
        formAddressItem.delegate = formAddressDelegate
        
        formAddressItem.updateOptionalStatus(isOptional: true)
        
        wait(for: [expectation], timeout: 2)
    }
}

// MARK: - Helpers

fileprivate class AddressDelegateDummy: SelfRenderingFormItemDelegate {
    let didUpdateItemsHandler: (_ items: [FormItem]) -> Void
    
    init(didUpdateItemsHandler: @escaping (_ items: [FormItem]) -> Void) {
        self.didUpdateItemsHandler = didUpdateItemsHandler
    }
    
    func didUpdateItems(_ items: [Adyen.FormItem]) {
        didUpdateItemsHandler(items)
    }
}
