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
        let (sut, viewModelMock) = makeSUT(title: expectedTitle)

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
    func cancelTapped_shouldCallViewModelCancel() throws {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        // When
        try sut.navigationItem.leftBarButtonItem?.tap()

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
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

    // MARK: - Helper

    private func makeSUT(title: String = "Payment Methods") -> (
        sut: PaymentMethodListViewController,
        viewModelMock: TestablePaymentMethodListViewModel
    ) {
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
