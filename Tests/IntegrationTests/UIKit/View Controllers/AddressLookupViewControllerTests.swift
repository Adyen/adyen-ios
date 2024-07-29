//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class AddressLookupViewControllerTests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testViewControllerBinding() {
        
        // Given
        
        let expectation = expectation(description: "Lookup provider was called on viewDidLoad")
        
        let results: [LookupAddressModel] = PostalAddressMocks.all.map {
            .init(identifier: UUID().uuidString, postalAddress: $0)
        }
        
        let mockLookupProvider = MockAddressLookupProvider { _ in
            expectation.fulfill()
            return results
        }
        
        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: results.first?.postalAddress,
            lookupProvider: mockLookupProvider
        ) { address in
            XCTFail("Completion handler should not have been called")
        } cancelHandler: {
            XCTFail("Cancel handler should not have been called")
        }

        // When
        
        let addressLookupViewController = AddressLookupViewController(viewModel: viewModel)
        
        setupRootViewController(addressLookupViewController)
        
        // Then
        
        // Should show form initially as a prefillAddress was provided
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressInputFormViewController)
        
        viewModel.interfaceState = .search
        wait(for: [expectation], timeout: 10)
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressLookupSearchViewController)
        
        viewModel.handleSwitchToManualEntryTapped()
        wait(for: .aMoment)
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: results.first?.postalAddress))
        XCTAssertNotNil(addressLookupViewController.viewControllers.first as? AddressInputFormViewController)
    }
    
    func testSearchDismissalNoPrefillNoAction() {

        // Given

        let cancelHandlerExpectation = expectation(description: "Cancel handler was called")
        
        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: nil,
            lookupProvider: MockAddressLookupProvider.alwaysFailing
        ) { _ in
            XCTFail("Completion handler should not have been called")
        } cancelHandler: {
            cancelHandlerExpectation.fulfill()
        }

        // Then

        viewModel.handleDismissSearchTapped()

        wait(for: [cancelHandlerExpectation], timeout: 10)
    }

    func testSearchDismissalAfterInteraction() {

        // Given

        let completionHandlerExpectation = expectation(description: "Completion handler called")

        let mockLookupProvider = MockAddressLookupProvider { _ in [] }
        
        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: nil,
            lookupProvider: mockLookupProvider
        ) { address in
            XCTAssertEqual(address, .init())
            completionHandlerExpectation.fulfill()
        } cancelHandler: {
            XCTFail("Cancel handler should not have been called")
        }

        // Then

        let addressLookupViewController = AddressLookupViewController(viewModel: viewModel)

        setupRootViewController(addressLookupViewController)

        addressLookupViewController.viewModel.handleSwitchToManualEntryTapped()
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: nil))

        addressLookupViewController.viewModel.handleShowSearchTapped(currentInput: PostalAddress())
        XCTAssertEqual(viewModel.interfaceState, .search)

        addressLookupViewController.viewModel.handleDismissSearchTapped() // Should not cancel the flow
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: PostalAddress()))

        addressLookupViewController.viewModel.handleAddressInputFormCompletion(validAddress: .init()) // Should trigger completion handler with postal address

        wait(for: [completionHandlerExpectation], timeout: 10)
    }

    // MARK: - ViewModel

    func testViewModelInitialization() {

        // Given

        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: nil,
            lookupProvider: MockAddressLookupProvider.alwaysFailing
        ) { address in
            XCTFail("Completion handler should not have been called")
        } cancelHandler: {
            XCTFail("Cancel handler should not have been called")
        }

        // Then

        XCTAssertTrue(viewModel.shouldDismissOnSearchDismissal)
        XCTAssertEqual(viewModel.interfaceState, .search)
    }

    func testViewModelInitializationPrefilled() {

        // Given

        let prefillAddress = PostalAddressMocks.all.first!

        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: prefillAddress,
            lookupProvider: MockAddressLookupProvider.alwaysFailing
        ) { address in
            XCTFail("Completion handler should not have been called")
        } cancelHandler: {
            XCTFail("Cancel handler should not have been called")
        }

        // Then

        XCTAssertFalse(viewModel.shouldDismissOnSearchDismissal)
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: prefillAddress))
    }

    func testViewModelInteraction() {

        // Given
        let expectedSearchTerm = "Test"
        let results: [LookupAddressModel] = PostalAddressMocks.all.map {
            .init(identifier: UUID().uuidString, postalAddress: $0)
        }
        
        let currentInput = results.last!.postalAddress
        var expectedCompletionHandlerAddress: PostalAddress?

        let completionHandlerExpectation = expectation(description: "Completion handler was called on submit")
        completionHandlerExpectation.expectedFulfillmentCount = 2

        let mockLookupProvider = MockAddressLookupProvider { searchTerm in
            XCTAssertEqual(searchTerm, expectedSearchTerm)
            return results
        }
        
        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: results.first?.postalAddress,
            lookupProvider: mockLookupProvider
        ) { address in
            XCTAssertEqual(address, expectedCompletionHandlerAddress)
            completionHandlerExpectation.fulfill()
        } cancelHandler: {
            XCTFail("Cancel handler should not have been called")
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

        let loadingExpectation = expectation(description: "Loading handler was called")
        loadingExpectation.expectedFulfillmentCount = 2
        
        let addressSearchViewModel = viewModel.buildAddressSearchViewModel { _ in
            XCTFail("Presentation handler should not have been called")
        }

        addressSearchViewModel.handleLookUp(searchTerm: expectedSearchTerm) { listItems in
            // We don't have a ListViewController that provides the loadingHandler
            // so we provide one here which also allows us to test if it's called correctly
            listItems.forEach {
                $0.loadingHandler = { _, _ in loadingExpectation.fulfill() }
            }
            
            // Selecting the 2nd item in the list as the first one is the manual input cell
            listItems[1].selectionHandler?()
        }

        // Then

        let firstAddressResult = results.first!.postalAddress

        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: firstAddressResult))

        // When - Submitting address

        expectedCompletionHandlerAddress = firstAddressResult
        // Check if the AddressLookupViewController.ViewModel completionHandler was called with the expected address
        viewModel.handleAddressInputFormCompletion(validAddress: firstAddressResult)

        expectedCompletionHandlerAddress = nil
        // Check if the AddressLookupViewController.ViewModel completionHandler was called with the expected address
        viewModel.handleAddressInputFormCompletion(validAddress: nil)

        // Then

        wait(for: [completionHandlerExpectation, loadingExpectation], timeout: 10)
    }
    
    func test_cancel_shouldNotAlterValue() throws {
        
        let cancelExpectation = expectation(description: "Cancel was called")
        
        let results: [LookupAddressModel] = PostalAddressMocks.all.map {
            .init(identifier: UUID().uuidString, postalAddress: $0)
        }
        
        let expectedPrefillAddress = results.first?.postalAddress
        
        let mockLookupProvider = MockAddressLookupProvider { searchTerm in
            XCTFail("Lookup Provider should not have been called")
            return results
        }
        
        let viewModel = AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: expectedPrefillAddress,
            lookupProvider: mockLookupProvider
        ) { _ in
            XCTFail("Completion handler should not have been called")
        } cancelHandler: {
            cancelExpectation.fulfill()
        }
        
        viewModel.handleDismissAddressLookup()
        XCTAssertEqual(viewModel.prefillAddress, expectedPrefillAddress)
        
        wait(for: [cancelExpectation], timeout: 1)
    }
}
