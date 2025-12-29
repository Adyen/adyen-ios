//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class AddressLookupViewControllerTests: XCTestCase {

    // MARK: - Test Data

    private var mockAddressResults: [AddressLookupResult] {
        PostalAddressMocks.all.map {
            .init(identifier: UUID().uuidString, postalAddress: $0)
        }
    }

    // MARK: - Setup

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }

    // MARK: - ViewController Binding Tests

    func testViewControllerBinding_showsFormInitially_whenPrefillAddressProvided() {
        // Given
        let results = mockAddressResults
        let (viewModel, sut) = makeSUTWithViewController(
            prefillAddress: results.first?.postalAddress)

        // When
        sut.loadViewIfNeeded()

        // Then
        XCTAssertNotNil(sut.viewControllers.first as? AddressInputFormViewController)
    }

    func testViewControllerBinding_showsSearch_whenInterfaceStateChangesToSearch() {
        // Given
        let lookupExpectation = expectation(description: "Lookup provider called")
        let results = mockAddressResults
        let (viewModel, sut) = makeSUTWithViewController(
            prefillAddress: results.first?.postalAddress,
            onLookup: { _ in
                lookupExpectation.fulfill()
                return results
            }
        )
        setupRootViewController(sut)

        // When
        viewModel.interfaceState = .search

        // Then
        wait(for: [lookupExpectation], timeout: 10)
        XCTAssertNotNil(sut.viewControllers.first as? AddressLookupSearchViewController)
    }

    func testViewControllerBinding_showsForm_whenSwitchingToManualEntry() {
        // Given
        let results = mockAddressResults
        let (viewModel, sut) = makeSUTWithViewController(
            prefillAddress: results.first?.postalAddress)
        sut.loadViewIfNeeded()
        viewModel.interfaceState = .search

        // When
        viewModel.handleSwitchToManualEntryTapped()
        wait(for: .aMoment)

        // Then
        XCTAssertEqual(
            viewModel.interfaceState, .form(prefillAddress: results.first?.postalAddress)
        )
        XCTAssertNotNil(sut.viewControllers.first as? AddressInputFormViewController)
    }

    // MARK: - Search Dismissal Tests

    func testSearchDismissal_completesWithNil_whenNoPrefillAndNoAction() {
        // Given
        let completionExpectation = expectation(description: "Completion called with nil")
        let viewModel = makeSUT(prefillAddress: nil) { address in
            XCTAssertNil(address)
            completionExpectation.fulfill()
        }

        // When
        viewModel.handleDismissSearchTapped()

        // Then
        wait(for: [completionExpectation], timeout: 10)
    }

    func testSearchDismissal_returnsToForm_afterUserInteraction() {
        // Given
        let completionExpectation = expectation(description: "Completion called")
        let (viewModel, sut) = makeSUTWithViewController(prefillAddress: nil) { address in
            XCTAssertEqual(address, PostalAddress())
            completionExpectation.fulfill()
        }
        sut.loadViewIfNeeded()

        // When - User switches to manual entry then back to search
        viewModel.handleSwitchToManualEntryTapped()
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: nil))

        viewModel.handleShowSearchTapped(currentInput: PostalAddress())
        XCTAssertEqual(viewModel.interfaceState, .search)

        viewModel.handleDismissSearchTapped()

        // Then - Should return to form, not dismiss
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: PostalAddress()))

        // When - User submits
        viewModel.handleAddressInputFormCompletion(validAddress: PostalAddress())

        // Then
        wait(for: [completionExpectation], timeout: 10)
    }

    // MARK: - ViewModel Initialization Tests

    func testViewModelInitialization_startsInSearchState_whenNoPrefillAddress() {
        // Given/When
        let viewModel = makeSUT(prefillAddress: nil)

        // Then
        XCTAssertTrue(viewModel.shouldDismissOnSearchDismissal)
        XCTAssertEqual(viewModel.interfaceState, .search)
    }

    func testViewModelInitialization_startsInFormState_whenPrefillAddressProvided() {
        // Given
        let prefillAddress = PostalAddressMocks.newYorkPostalAddress

        // When
        let viewModel = makeSUT(prefillAddress: prefillAddress)

        // Then
        XCTAssertFalse(viewModel.shouldDismissOnSearchDismissal)
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: prefillAddress))
    }

    // MARK: - Search Interaction Tests

    func testShowSearch_updatesPrefillAddressAndState() {
        // Given
        let currentInput = PostalAddressMocks.losAngelesPostalAddress
        let viewModel = makeSUT(prefillAddress: PostalAddressMocks.newYorkPostalAddress)

        // When
        viewModel.handleShowSearchTapped(currentInput: currentInput)

        // Then
        XCTAssertEqual(viewModel.prefillAddress, currentInput)
        XCTAssertEqual(viewModel.interfaceState, .search)
    }

    func testDismissSearch_returnsToFormWithPrefillAddress() {
        // Given
        let prefillAddress = PostalAddressMocks.newYorkPostalAddress
        let viewModel = makeSUT(prefillAddress: prefillAddress)
        viewModel.handleShowSearchTapped(currentInput: prefillAddress)

        // When
        viewModel.handleDismissSearchTapped()

        // Then
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: prefillAddress))
    }

    // MARK: - Address Selection Tests

    func testAddressSelection_updatesStateWithSelectedAddress() {
        // Given
        let results = mockAddressResults
        let expectedAddress = results.first!.postalAddress
        let stateChangeExpectation = expectation(description: "State changed")

        let viewModel = makeSUT(
            prefillAddress: nil,
            onLookup: { _ in results }
        )
        let searchViewModel = viewModel.buildAddressSearchViewModel { _ in
            XCTFail("Presentation handler should not be called")
        }

        // When
        performAddressSelection(
            on: searchViewModel,
            searchTerm: "Test",
            selectingIndex: 1, // Index 0 is manual entry cell
            onComplete: { stateChangeExpectation.fulfill() }
        )

        // Then
        wait(for: [stateChangeExpectation], timeout: 5)
        XCTAssertEqual(viewModel.interfaceState, .form(prefillAddress: expectedAddress))
    }

    func testAddressSelection_triggersLoadingHandler() {
        // Given
        let results = mockAddressResults
        let loadingExpectation = expectation(description: "Loading handler called")

        let viewModel = makeSUT(
            prefillAddress: nil,
            onLookup: { _ in results }
        )
        let searchViewModel = viewModel.buildAddressSearchViewModel { _ in }

        // When
        searchViewModel.handleLookUp(searchTerm: "Test") { listItems in
            listItems.forEach { $0.loadingHandler = { _, _ in loadingExpectation.fulfill() } }
            listItems[1].selectionHandler?()
        }

        // Then
        wait(for: [loadingExpectation], timeout: 5)
    }

    // MARK: - Form Completion Tests

    func testFormCompletion_callsCompletionHandler_withValidAddress() {
        // Given
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress
        let completionExpectation = expectation(description: "Completion called")

        let viewModel = makeSUT(prefillAddress: expectedAddress) { address in
            XCTAssertEqual(address, expectedAddress)
            completionExpectation.fulfill()
        }

        // When
        viewModel.handleAddressInputFormCompletion(validAddress: expectedAddress)

        // Then
        wait(for: [completionExpectation], timeout: 5)
    }

    func testFormCompletion_callsCompletionHandler_withNilAddress() {
        // Given
        let completionExpectation = expectation(description: "Completion called")

        let viewModel = makeSUT(prefillAddress: nil) { address in
            XCTAssertNil(address)
            completionExpectation.fulfill()
        }

        // When
        viewModel.handleAddressInputFormCompletion(validAddress: nil)

        // Then
        wait(for: [completionExpectation], timeout: 5)
    }
}

// MARK: - SUT Factory Methods

extension AddressLookupViewControllerTests {

    private func makeSUT(
        prefillAddress: PostalAddress?,
        onLookup: @escaping (String) -> [AddressLookupResult] = { _ in [] },
        completionHandler: @escaping (PostalAddress?) -> Void = { _ in }
    ) -> AddressLookupViewController.ViewModel {
        let provider = MockAddressLookupProvider(resultProvider: onLookup)
        return AddressLookupViewController.ViewModel(
            for: .billing,
            style: .init(),
            localizationParameters: nil,
            supportedCountryCodes: nil,
            initialCountry: "NL",
            prefillAddress: prefillAddress,
            lookupProvider: provider,
            completionHandler: completionHandler
        )
    }

    private func makeSUTWithViewController(
        prefillAddress: PostalAddress?,
        onLookup: @escaping (String) -> [AddressLookupResult] = { _ in [] },
        completionHandler: @escaping (PostalAddress?) -> Void = { _ in }
    ) -> (
        viewModel: AddressLookupViewController.ViewModel,
        viewController: AddressLookupViewController
    ) {
        let viewModel = makeSUT(
            prefillAddress: prefillAddress,
            onLookup: onLookup,
            completionHandler: completionHandler
        )
        let viewController = AddressLookupViewController(viewModel: viewModel)
        return (viewModel, viewController)
    }
}

// MARK: - Action Helpers

extension AddressLookupViewControllerTests {

    private func performAddressSelection(
        on searchViewModel: AddressLookupSearchViewController.ViewModel,
        searchTerm: String,
        selectingIndex index: Int,
        onComplete: @escaping () -> Void
    ) {
        searchViewModel.handleLookUp(searchTerm: searchTerm) { listItems in
            listItems[index].selectionHandler?()
            DispatchQueue.main.async { onComplete() }
        }
    }
}
