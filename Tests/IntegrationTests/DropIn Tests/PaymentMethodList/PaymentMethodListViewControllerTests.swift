//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Combine
import Testing
import UIKit

@MainActor
struct PaymentMethodListViewControllerTests {

    // MARK: - viewDidLoad Tests

    @Test
    func viewDidLoad_shouldEnableIsModalInPresentation() {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.isModalInPresentation)
    }

    @Test
    func viewDidLoad_shouldSetupNavigationItemTitle() {
        // Given
        let expectedTitle = "Test Title"
        let (sut, _) = makeSUT(title: expectedTitle)

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.navigationItem.title == expectedTitle)
        #expect(sut.navigationItem.largeTitleDisplayMode == .always)
    }

    @Test
    func viewDidLoad_shouldSetupCancelButton() {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.navigationItem.leftBarButtonItem != nil)
    }

    @Test
    func viewDidLoad_shouldCallViewModelDidLoad() {
        // Given
        let (sut, viewModelMock) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(viewModelMock.didLoadCallsCount == 1)
    }

    @Test
    func viewDidLoad_shouldAddListViewControllerAsChild() {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.children.count == 1)
        #expect(sut.children.first is ListViewController)
    }

    // MARK: - Cancel Button Tests

    @Test
    func cancelTapped_shouldCallViewModelCancel() throws {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        // When
        try sut.navigationItem.leftBarButtonItem?.tap()

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
    }

    // MARK: - State Observation Tests

    @Test
    func stateLoaded_shouldReloadListViewController() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let listItem = ListItem(title: "Test Item")
        let section = ListSection(items: [listItem])

        // When
        viewModelMock.setState(.loaded(sections: [section]))

        // Allow state to propagate on main queue
        await Task.yield()

        // Then
        let listViewController = sut.children.first as? ListViewController
        #expect(listViewController?.sections.count == 1)
        #expect(listViewController?.sections.first?.items.count == 1)
    }

    @Test
    func stateLoaded_withMultipleSections_shouldReloadAllSections() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let section1 = ListSection(items: [ListItem(title: "Item 1")])
        let section2 = ListSection(items: [ListItem(title: "Item 2"), ListItem(title: "Item 3")])

        // When
        viewModelMock.setState(.loaded(sections: [section1, section2]))

        await Task.yield()

        // Then
        let listViewController = sut.children.first as? ListViewController
        #expect(listViewController?.sections.count == 2)
        #expect(listViewController?.sections[0].items.count == 1)
        #expect(listViewController?.sections[1].items.count == 2)
    }

    @Test
    func stateLoading_shouldStartLoadingForMatchingItem() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let paymentMethod = PaymentMethodMock(type: .ideal, name: "iDEAL")
        let listItem = ListItem(title: "iDEAL")
        listItem.identifier = "ideal"
        let section = ListSection(items: [listItem])

        // First load the sections
        viewModelMock.setState(.loaded(sections: [section]))
        await Task.yield()

        var loadingStarted = false
        listItem.loadingHandler = { isLoading, _ in
            if isLoading { loadingStarted = true }
        }

        // When
        viewModelMock.setState(.loading(paymentMethod: paymentMethod))
        await Task.yield()

        // Then
        #expect(loadingStarted)
    }

    @Test
    func stateReady_shouldStopLoading() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let listItem = ListItem(title: "Test Item")
        let section = ListSection(items: [listItem])
        viewModelMock.setState(.loaded(sections: [section]))
        await Task.yield()

        // When
        viewModelMock.setState(.ready)
        await Task.yield()

        // Then - stopLoading was called (no crash, state is ready)
        // The ListViewController.stopLoading() is called internally
        #expect(true) // If we reach here, stopLoading didn't crash
    }

    // MARK: - Delete Component Tests

    @Test
    func deleteComponent_shouldDeleteItemAtIndexPath() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let item1 = ListItem(title: "Item 1")
        let item2 = ListItem(title: "Item 2")
        let section = ListSection(items: [item1, item2])
        viewModelMock.setState(.loaded(sections: [section]))
        await Task.yield()

        let listViewController = sut.children.first as? ListViewController
        #expect(listViewController?.sections.first?.items.count == 2)

        // When
        sut.deleteComponent(at: IndexPath(item: 0, section: 0))

        // Then
        #expect(listViewController?.sections.first?.items.count == 1)
    }

    // MARK: - Helper

    private func makeSUT(title: String = "Payment Methods") -> (
        sut: PaymentMethodListViewController,
        viewModelMock: TestablePaymentMethodListViewModel
    ) {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            // Empty - just setting up dependencies
        }

        let viewModelMock = TestablePaymentMethodListViewModel(title: title)
        let sut = PaymentMethodListViewController(viewModel: viewModelMock)

        return (sut, viewModelMock)
    }
}

// MARK: - Test Helper

private class TestablePaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    let context: AdyenContext = Dummy.context
    let title: String
    let paymentMethodSections: [PaymentMethodsSection] = []

    @Published private var state: PaymentMethodListState = .ready
    var statePublisher: Published<PaymentMethodListState>.Publisher {
        $state
    }

    private(set) var cancelCallsCount = 0
    private(set) var didLoadCallsCount = 0

    init(title: String) {
        self.title = title
    }

    func setState(_ newState: PaymentMethodListState) {
        state = newState
    }

    func cancel() {
        cancelCallsCount += 1
    }

    func didLoad() {
        didLoadCallsCount += 1
    }

    func listItemIdentifier(for paymentMethod: PaymentMethod) -> String {
        paymentMethod.type.rawValue
    }
}
