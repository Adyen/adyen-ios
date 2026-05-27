//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
import Combine
import Testing
import UIKit

@MainActor
struct PaymentMethodListViewModelTests {

    // MARK: - Protocol Conformance Tests

    @Test
    func title_shouldReturnLocalizedPaymentMethodsTitle() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        let expectedTitle = localizedString(.paymentMethodsTitle, LocalizationParameters())
        #expect(sut.title == expectedTitle)
    }

    @Test
    func paymentMethodSections_shouldMatchComponentManagerSections() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        #expect(sut.paymentMethodSections.isEmpty == false)
    }

    // MARK: - State Tests

    @Test
    func initialState_shouldBeIdle() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle")
        }
    }

    @Test
    func didLoad_shouldTransitionToLoadedState() {
        // Given
        let (sut, _, _) = makeSUT()

        // When
        sut.didLoad()

        // Then
        if case let .loaded(sections) = sut.state {
            #expect(sections.isEmpty == false)
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }

    // MARK: - Cancel Tests

    @Test
    func cancel_shouldCallRouterDismiss() {
        // Given
        let (sut, _, routerMock) = makeSUT()

        // When
        sut.cancel()

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
    }

    // MARK: - PaymentComponentDelegate Tests

    @Test
    func didSubmit_shouldCallDropInFlowManagerSubmit() {
        // Given
        let (sut, dropInFlowManagerMock, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        let data = makePaymentComponentDataMock()

        // When
        sut.didSubmit(data, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.submitFromActionPresenterCallsCount == 1)

        let receivedActionPresenter = dropInFlowManagerMock.submitFromActionPresenterReceivedArguments?.actionPresenter
        #expect(sut === receivedActionPresenter)
    }

    @Test
    func didFail_givenError_shouldCallDropInFlowManagerFail() {
        // Given
        let (sut, dropInFlowManagerMock, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        let error = ErrorMock(errorDescription: "Failure")

        // When
        sut.didFail(with: error, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 1)
    }

    @Test
    func didFail_givenError_shouldTransitionToIdleState() {
        // Given
        let (sut, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()
        let error = ErrorMock(errorDescription: "Failure")

        // When
        sut.didFail(with: error, from: paymentComponentMock)

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle after failure")
        }
    }

    @Test
    func didFail_givenCancellation_shouldNotCallDropInFlowManagerFail() {
        // Given
        let (sut, dropInFlowManagerMock, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()

        // When
        sut.didFail(with: ComponentError.cancelled, from: paymentComponentMock)

        // Then
        #expect(dropInFlowManagerMock.failWithFromCallsCount == 0)
    }

    @Test
    func didFail_givenCancellation_shouldTransitionToIdleState() {
        // Given
        let (sut, _, _) = makeSUT()
        let paymentComponentMock = makePaymentComponentMock()

        // When
        sut.didFail(with: ComponentError.cancelled, from: paymentComponentMock)

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle after cancellation")
        }
    }

    // MARK: - FormattedAmount Tests

    @Test
    func formattedAmount_shouldReturnFormattedContextAmount() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then
        #expect(sut.formattedAmount.isEmpty == false)
    }

    // MARK: - Subtitle Tests

    @Test
    func subtitle_shouldReturnNonEmptyString() {
        // Given
        let (sut, _, _) = makeSUT()

        // Then - verify subtitle is not empty (actual string may change with localization)
        #expect(sut.subtitle.isEmpty == false, "Subtitle should not be empty")
    }

    // MARK: - ApplePayButtonState Tests

    @Test
    func applePayButtonState_givenNoApplePay_shouldReturnHidden() {
        // Given - paymentMethods without Apple Pay
        let (sut, _, _) = makeSUT(includeApplePay: false)

        // Then
        if case .hidden = sut.applePayButtonState {
            // Success
        } else {
            Issue.record("Expected applePayButtonState to be .hidden when no Apple Pay available")
        }
    }

    @Test
    func applePayButtonState_givenApplePay_shouldReturnVisible() {
        // Given - paymentMethods with Apple Pay
        let (sut, _, _) = makeSUT(includeApplePay: true)

        // Then
        if case .visible = sut.applePayButtonState {
            // Success
        } else {
            Issue.record("Expected applePayButtonState to be .visible when Apple Pay is available")
        }
    }

    // MARK: - Select Payment Method Tests

    @Test
    func selectPaymentMethod_givenRegularComponent_shouldCallRouterPresent() throws {
        // Given
        let (sut, _, routerMock) = makeSUT()
        sut.didLoad()
        let paymentMethod = try #require(sut.paymentMethodSections.flatMap(\.paymentMethods).first { $0.type == .scheme })

        // When
        sut.select(paymentMethod: paymentMethod)

        // Then
        #expect(routerMock.presentComponentCallsCount == 1)
    }

    // MARK: - GetSections Tests

    @Test
    func didLoad_shouldFilterOutApplePayFromSections() {
        // Given
        let (sut, _, _) = makeSUT(includeApplePay: true)

        // When
        sut.didLoad()

        // Then
        if case let .loaded(sections) = sut.state {
            let allItems = sections.flatMap(\.items)
            let hasApplePay = allItems.contains { $0.title.lowercased().contains("apple") }
            #expect(hasApplePay == false, "Apple Pay should be filtered from the main list")
        } else {
            Issue.record("Expected state to be .loaded")
        }
    }

    // MARK: - ActionPresenter Tests

    @Test
    func presentActionComponent_shouldCallRouterPresentActionComponent() {
        // Given
        let (sut, _, routerMock) = makeSUT()
        let actionComponentMock = makeActionComponentMock()

        // When
        sut.present(actionComponent: actionComponentMock)

        // Then
        #expect(routerMock.presentActionComponentOnCancelCallsCount == 1)
    }

    @Test
    func didCancelActionComponent_shouldTransitionToIdleState() {
        // Given
        let (sut, _, _) = makeSUT()
        let actionComponentMock = RedirectComponent(context: contextMock)

        // When
        sut.didCancel(actionComponent: actionComponentMock)

        // Then
        if case .idle = sut.state {
            // Success
        } else {
            Issue.record("Expected state to be .idle after action cancel")
        }
    }

    // MARK: - Helpers

    private func makeSUT(includeApplePay: Bool = true) -> (
        sut: PaymentMethodListViewModel,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: PaymentMethodListRoutingMock
    ) {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: .init(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )

        let methods = includeApplePay ? paymentMethods : paymentMethodsWithoutApplePay
        let componentManagerMock = ComponentManager(
            paymentMethods: methods,
            context: context,
            configuration: .init(),
            order: nil,
            presentationDelegate: nil
        )
        let dropInFlowManagerMock = DropInFlowManagingMock()
        let logoURLProvider = LogoURLProvider(environment: context.apiContext.environment)

        let sut = PaymentMethodListViewModel(
            context: context,
            localizationParameters: LocalizationParameters(),
            componentManager: componentManagerMock,
            configuration: DropInComponent.Configuration(),
            dropInFlowManager: dropInFlowManagerMock,
            logoURLProvider: logoURLProvider,
            theme: TestTheme.distinctive()
        )

        let routerMock = PaymentMethodListRoutingMock()
        sut.router = routerMock

        return (sut, dropInFlowManagerMock, routerMock)
    }

    private func makePaymentComponentDataMock() -> PaymentComponentData {
        let encryptedCard = EncryptedCard(
            number: "4111111111111111",
            securityCode: "737",
            expiryMonth: "03",
            expiryYear: "30"
        )

        let cardDetails = CardDetails(
            paymentMethod: CardPaymentMethodMock(
                type: .scheme,
                name: "Card",
                brands: [.visa]
            ),
            encryptedCard: encryptedCard,
            holderName: "Katrina del Mar"
        )

        return PaymentComponentData(
            paymentMethodDetails: cardDetails,
            amount: Amount(value: 1000, currencyCode: "EUR"),
            order: nil
        )
    }

    private var paymentMethods: PaymentMethods {
        let paymentMethodsDictionary = PaymentMethodsMock.paymentMethodsDictionary
        return try! AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
    }

    private var paymentMethodsWithoutApplePay: PaymentMethods {
        var methods = paymentMethods
        methods.regular = methods.regular.filter { $0.type != .applePay }
        return methods
    }

    private func makePaymentComponentMock() -> PresentableComponentMock {
        let cardPaymentMethodMock = CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )
        let viewControllerMock = UIViewController()

        return PresentableComponentMock(
            paymentMethod: cardPaymentMethodMock,
            viewController: viewControllerMock
        )
    }

    private func makeActionComponentMock() -> PresentableComponent {
        let redirectComponent = RedirectComponent(context: contextMock)
        let viewControllerMock = UIViewController()
        return PresentableComponentWrapper(
            component: redirectComponent,
            viewController: viewControllerMock
        )
    }

    private let contextMock = AdyenContext(
        apiContext: Dummy.apiContext,
        amount: .init(value: 100, currencyCode: "EUR"),
        publicKey: Dummy.publicKey,
        analyticsProvider: AnalyticsProviderMock()
    )
}
