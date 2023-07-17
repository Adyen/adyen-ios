//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class AddressLookupViewControllerTests: XCTestCase {
    
    func testViewControllerBinding() {
        
        // Given
        
        let results = PostalAddressMocks.all
        
        let expectation = expectation(description: "Lookup provider was called on viewDidLoad")
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: results.first
        ) { searchTerm, resultProvider in
            resultProvider(results)
            expectation.fulfill()
        } completionHandler: { address in
            XCTAssert(false, "Completion handler should not have been called")
        }

        // When
        
        let addressLookupViewController = AddressLookupViewController(viewModel: viewModel)
        
        UIApplication.shared.keyWindow?.rootViewController = addressLookupViewController
        wait(for: .milliseconds(300))
        
        // Then
        
        // Should show form initially as a prefillAddress was provided
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupFormViewController)
        
        viewModel.interfaceState = .search
        wait(for: [expectation], timeout: 2)
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupSearchViewController)
        
        viewModel.interfaceState = .form(prefillAddress: nil)
        wait(for: .milliseconds(300))
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupFormViewController)
    }
    
    // MARK: - ViewModel
    
    func testViewModelInitialization() {
        
        // Given
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: nil
        ) { searchTerm, resultProvider in
            XCTAssert(false, "Lookup provider should not have been called")
        } completionHandler: { address in
            XCTAssert(false, "Completion handler should not have been called")
        }
        
        // Then
        
        XCTAssertTrue(viewModel.shouldDismissOnSearchDismissal)
        XCTAssertEqual(viewModel.interfaceState, .search)
    }
    
    func testViewModelInitializationPrefilled() {
        
        // Given
        
        let prefillAddress = PostalAddressMocks.all.first!
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: prefillAddress
        ) { searchTerm, resultProvider in
            XCTAssert(false, "Lookup provider should not have been called")
        } completionHandler: { address in
            XCTAssert(false, "Completion handler should not have been called")
        }
        
        // Then
        
        XCTAssertFalse(viewModel.shouldDismissOnSearchDismissal)
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: prefillAddress))
    }
    
    func testViewModelInteraction() {
        
        // Given
        
        let results = PostalAddressMocks.all
        let currentInput = results.last!
        var expectedCompletionHandlerAddress: PostalAddress?
        
        let completionHandlerExpectation = expectation(description: "Completion handler was called on submit")
        completionHandlerExpectation.expectedFulfillmentCount = 2
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: results.first
        ) { searchTerm, resultProvider in
            resultProvider(results)
        } completionHandler: { address in
            XCTAssertEqual(address, expectedCompletionHandlerAddress)
            completionHandlerExpectation.fulfill()
        }
        
        // When - Showing Search
        
        viewModel.handleShowSearchTapped(currentInput: currentInput)
        
        // Then
        
        XCTAssertEqual(viewModel.prefillAddress, currentInput)
        XCTAssertEqual(viewModel.interfaceState, .search)
        
        // When - Dismissing Search
        
        viewModel.handleDismissSearchTapped()
        
        // Then
        
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: viewModel.prefillAddress))
        
        // When - Selecting address from lookup
        
        viewModel.lookUp(searchTerm: "") { $0.first!.selectionHandler?() }
        
        // Then
        
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: results.first!))
        
        // When - Submitting address
        
        expectedCompletionHandlerAddress = results.first!
        viewModel.handleSubmit(address: results.first!)
        
        expectedCompletionHandlerAddress = nil
        viewModel.handleDismissAddressLookupTapped()
        
        // Then
        
        wait(for: [completionHandlerExpectation], timeout: 2)
    }
}
