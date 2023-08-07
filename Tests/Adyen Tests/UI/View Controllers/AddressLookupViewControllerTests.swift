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
            XCTFail("Completion handler should not have been called")
        }

        // When
        
        let addressLookupViewController = AddressLookupViewController(viewModel: viewModel)
        
        UIApplication.shared.keyWindow?.rootViewController = addressLookupViewController
        wait(for: .milliseconds(50))
        
        // Then
        
        // Should show form initially as a prefillAddress was provided
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupFormViewController)
        
        viewModel.interfaceState = .search
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupSearchViewController)
        
        addressLookupViewController.addressLookupSearchSwitchToManualEntry()
        wait(for: .milliseconds(50))
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: results.first))
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupFormViewController)
    }
    
    func testDoneButtonState() {
        // Given
        
        let results = PostalAddressMocks.all
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: results.first
        ) { _, _ in
            // Nothing to do...
        } completionHandler: { address in
            XCTFail("Completion handler should not have been called")
        }

        let addressLookupViewController = AddressLookupViewController(viewModel: viewModel)
        
        UIApplication.shared.keyWindow?.rootViewController = addressLookupViewController
        wait(for: .milliseconds(50))
        
        // When - No prefill
        
        _ = {
            viewModel.interfaceState = .form(prefillAddress: nil)
            self.wait(for: .milliseconds(50))
            
            // Then
            
            XCTAssertEqual(
                addressLookupViewController.viewControllers.first?.navigationItem.rightBarButtonItem?.isEnabled,
                false
            )
        }
        
        // When - Prefill with country only
        
        _ = {
            viewModel.interfaceState = .form(prefillAddress: .init(country: "US"))
            self.wait(for: .milliseconds(50))
            
            let formViewController = addressLookupViewController.viewControllers.first as! AddressLookupFormViewController
            
            // Then
            
            XCTAssertEqual(
                formViewController.navigationItem.rightBarButtonItem?.isEnabled,
                false
            )
            
            // + Adding street name value
            
            formViewController.billingAddressItem.value.street = "Random Street"
            
            // Then
            
            XCTAssertEqual(
                formViewController.navigationItem.rightBarButtonItem?.isEnabled,
                true
            )
        }()
        
        // When - Prefill with country + any other field
        
        _ = {
            viewModel.interfaceState = .form(prefillAddress: .init(country: "NL", street: "Singel"))
            self.wait(for: .milliseconds(50))
            
            // Then
            
            XCTAssertEqual(
                addressLookupViewController.viewControllers.first?.navigationItem.rightBarButtonItem?.isEnabled,
                true
            )
        }()
    }
    
    func testSearchDismissalNoPrefillNoAction() {
        
        // Given
        
        let emptyCompletionExpectation = expectation(description: "Completion handler called with nil object")
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: nil
        ) { searchTerm, resultProvider in
            XCTFail("Lookup provider should not have been called")
        } completionHandler: { address in
            XCTAssertNil(address)
            emptyCompletionExpectation.fulfill()
        }
        
        // Then
        
        viewModel.handleDismissSearchTapped()
        
        wait(for: [emptyCompletionExpectation], timeout: 1)
    }
    
    func testSearchDismissalAfterInteraction() {
        
        // Given
        
        let completionHandlerExpectation = expectation(description: "Completion handler called")
        
        var expectedCompletionResults: [PostalAddress?] = [nil, .init()]
        
        let viewModel = AddressLookupViewController.ViewModel(
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: nil
        ) { searchTerm, resultProvider in
            // Nothing to do...
        } completionHandler: { address in
            XCTAssertEqual(expectedCompletionResults.first!, address)
            expectedCompletionResults = Array(expectedCompletionResults.dropFirst())
            if expectedCompletionResults.count == 0 {
                completionHandlerExpectation.fulfill()
            }
        }
        
        // Then
        
        let addressLookupViewController = AddressLookupViewController(viewModel: viewModel)
        
        UIApplication.shared.keyWindow?.rootViewController = addressLookupViewController
        wait(for: .milliseconds(50))
        
        addressLookupViewController.addressLookupSearchSwitchToManualEntry()
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: nil))
        
        addressLookupViewController.addressLookupFormShowSearch(currentInput: .init())
        XCTAssertEqual(viewModel.interfaceState, .search)
        
        addressLookupViewController.addressLookupSearchCancel() // Should not cancel the flow
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: .init()))
        
        addressLookupViewController.addressLookupFormDismiss()
        addressLookupViewController.addressLookupFormSubmit(validAddress: .init())
        
        wait(for: [completionHandlerExpectation], timeout: 1)
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
            XCTFail("Lookup provider should not have been called")
        } completionHandler: { address in
            XCTFail("Completion handler should not have been called")
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
            XCTFail("Lookup provider should not have been called")
        } completionHandler: { address in
            XCTFail("Completion handler should not have been called")
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
        
        wait(for: [completionHandlerExpectation], timeout: 1)
    }
}
