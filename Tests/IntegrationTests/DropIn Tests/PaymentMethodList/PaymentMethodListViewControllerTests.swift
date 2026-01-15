//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Testing

@MainActor
struct PaymentMethodListViewControllerTests {

    @Test
    func viewDidLoad_should_enableIsModalInPresentation() async throws {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.isModalInPresentation)
    }

    @Test
    func viewDidLoad_should_setupNavigationItem() async throws {
        // Given
        let (sut, viewModelMock) = makeSUT()
        let expectedTitle = "Payment Methods"
        viewModelMock.paymentMethodListView.title = expectedTitle

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(expectedTitle == sut.navigationItem.title)
        #expect(sut.navigationItem.largeTitleDisplayMode == .always)
    }

    @Test
    func viewDidLoad_should_setupCancelButton() async throws {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.navigationItem.leftBarButtonItem != nil)
    }

    @Test
    func cancelTapped_should_callViewModelCancel() async throws {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        // When
        try sut.navigationItem.leftBarButtonItem?.tap()

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
    }

    @Test
    func viewDidLoad_should_setupPaymentMethodListView() async throws {
        // Given
        let (sut, viewModelMock) = makeSUT()
        let paymentMethodListViewMock = UIViewController()
        viewModelMock.paymentMethodListView = paymentMethodListViewMock

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.children.first === paymentMethodListViewMock)
    }

    // MARK: - Helper

    private func makeSUT() -> (
        sut: PaymentMethodListViewController,
        viewModelMock: PaymentMethodListViewModelProtocolMock
    ) {
        let viewModel = PaymentMethodListViewModelProtocolMock()
        viewModel.paymentMethodListView = UIViewController()

        let sut = PaymentMethodListViewController(viewModel: viewModel)

        return (sut, viewModel)
    }
}
