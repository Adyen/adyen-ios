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
        #expect(sut.navigationItem.largeTitleDisplayMode == .never)
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
    func viewDidLoad_shouldSetupScrollView() {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then - verify view hierarchy is set up (scrollView is added to view)
        #expect(sut.view.subviews.contains { $0 is UIScrollView })
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
    func stateLoaded_shouldUpdateUI() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item = PaymentMethodItem(
            title: "Test Item",
            logoURLProvider: logoURLProvider,
            theme: .init()
        )
        let section = PaymentMethodSection(items: [item], theme: .init())

        // When
        viewModelMock.setState(.loaded(sections: [section]))

        // Allow state to propagate on main queue
        await Task.yield()

        // Then - verify section views are added to the view hierarchy
        let sectionViews = sut.view.findAllSubviews(ofType: PaymentMethodSectionView.self)
        #expect(sectionViews.isEmpty == false, "Section views should be present in the view hierarchy")
    }

    @Test
    func stateIdle_shouldHideLoadingOverlay() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item = PaymentMethodItem(
            title: "Test Item",
            logoURLProvider: logoURLProvider,
            theme: .init()
        )
        let section = PaymentMethodSection(items: [item], theme: .init())
        viewModelMock.setState(.loaded(sections: [section]))
        await Task.yield()

        // First show loading overlay
        viewModelMock.setState(.loading)
        await Task.yield()

        // When
        viewModelMock.setState(.idle)
        await Task.yield()

        // Then - loading overlay should be hidden (alpha = 0)
        let loadingOverlay: UIView? = sut.view.findView(with: "paymentMethodList.loadingOverlay")
        #expect(loadingOverlay?.alpha == 0, "Loading overlay should be hidden (alpha = 0) in idle state")
    }

    @Test
    func stateLoading_shouldShowLoadingOverlay() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        // When
        viewModelMock.setState(.loading)
        await Task.yield()

        // Then - loading overlay should be visible (alpha = 1)
        let loadingOverlay: UIView? = sut.view.findView(with: "paymentMethodList.loadingOverlay")
        #expect(loadingOverlay != nil, "Loading overlay should be present")
        #expect(loadingOverlay?.alpha == 1, "Loading overlay should be visible (alpha = 1) in loading state")
    }

    @Test
    func viewDidLoad_shouldApplyThemeBackgroundColor() {
        // Given
        let (sut, _) = makeSUT()
        let expectedBackgroundColor = CheckoutTheme.default.colors.background

        // When
        sut.loadViewIfNeeded()

        // Then - background color should match theme's background color
        #expect(sut.view.backgroundColor == expectedBackgroundColor)
    }

    @Test
    func viewDidLoad_shouldSetupHeaderView() {
        // Given
        let (sut, _) = makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then - header view should be in the view hierarchy
        let headerView: UIView? = sut.view.findView(with: "paymentMethodList.headerView")
        #expect(headerView != nil, "Header view should be present in the view hierarchy")
    }

    @Test
    func stateLoaded_shouldPopulatePaymentMethodSections() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item1 = PaymentMethodItem(
            title: "Card",
            logoURLProvider: logoURLProvider,
            theme: .init()
        )
        let item2 = PaymentMethodItem(
            title: "iDEAL",
            logoURLProvider: logoURLProvider,
            theme: .init()
        )
        let section1 = PaymentMethodSection(items: [item1], theme: .init())
        let section2 = PaymentMethodSection(items: [item2], theme: .init())

        // When
        viewModelMock.setState(.loaded(sections: [section1, section2]))
        await Task.yield()

        // Then - section views should be added
        let sectionViews: [UIView] = sut.view.findAllViews(with: "paymentMethodList.sectionView")
        #expect(sectionViews.count == 2, "Expected 2 section views but found \(sectionViews.count)")
    }

    @Test
    func stateLoaded_shouldClearPreviousSectionsBeforeReloading() async {
        // Given
        let (sut, viewModelMock) = makeSUT()
        sut.loadViewIfNeeded()

        let logoURLProvider = LogoURLProvider(environment: Dummy.apiContext.environment)
        let item = PaymentMethodItem(
            title: "Card",
            logoURLProvider: logoURLProvider,
            theme: .init()
        )
        let section = PaymentMethodSection(items: [item], theme: .init())

        // Load initial sections
        viewModelMock.setState(.loaded(sections: [section, section, section]))
        await Task.yield()

        // When - reload with fewer sections
        viewModelMock.setState(.loaded(sections: [section]))
        await Task.yield()

        // Then - only the new sections should be present
        let sectionViews: [UIView] = sut.view.findAllViews(with: "paymentMethodList.sectionView")
        #expect(sectionViews.count == 1, "Expected 1 section view after reload but found \(sectionViews.count)")
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
    let theme: CheckoutTheme = .init()
    let formattedAmount: String = "€1.00"
    let subtitle: String = "Select your preferred payment option"
    let applePayButtonState: PaymentMethodListHeaderViewModel.ApplePayButtonState = .hidden

    @Published private var state: PaymentMethodListState = .idle
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
}
