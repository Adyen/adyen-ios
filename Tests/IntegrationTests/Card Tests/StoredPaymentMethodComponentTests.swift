//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
internal struct StoredPaymentMethodComponentTests {

    // MARK: - Submission

    @Test
    internal func storedPaymentMethod_whenSubmitting_thenProvidesStoredPaymentDetails() async throws {
        // Given
        let (sut, delegate) = makeSUT()

        // When
        let data = try await submittedData(from: sut, delegate: delegate) {
            sut.performSubmit()
        }

        // Then
        let details = try #require(data.paymentMethod as? StoredPaymentDetails)
        #expect(details.type == .other("type"))
        #expect(details.storedPaymentMethodIdentifier == "id")
    }

    /// The payment button is the only way a shopper can pay on this screen, so tapping it has to
    /// reach the same submission path as calling the component directly.
    @Test
    internal func storedPaymentMethod_whenTappingPaymentButton_thenSubmitsStoredDetails() async throws {
        // Given
        let (sut, delegate) = makeSUT()
        let viewController = try #require(sut.viewController as? PaymentButtonViewController)

        // When
        let data = try await submittedData(from: sut, delegate: delegate) {
            viewController.onSubmit?()
        }

        // Then
        #expect(data.paymentMethod is StoredPaymentDetails)
    }

    // MARK: - Payment method types

    // TODO: Robert: Different Stored Payments should have different button titles, but it isn't clear what exactly.
    @Test(arguments: DirectStoredPaymentMethod.allCases)
    internal func storedPaymentMethod_whenRenderingButtonScreen_thenShowsAmountAwarePayButtonTitle(
        storedMethod: DirectStoredPaymentMethod
    ) throws {
        // Given
        let (sut, _) = makeSUT(paymentMethod: storedMethod.paymentMethod)
        let viewController = try #require(sut.viewController as? PaymentButtonViewController)

        // When
        viewController.loadViewIfNeeded()

        // Then
        #expect(try payButtonTitle(in: viewController) == "Pay €1.00")
    }

    /// Submitting must reference the stored method the shopper selected. There shouldn't be any modification of the identifier when passed back to PaymentComponentsData.
    /// example: charge a different stored method of the same shopper.
    @Test(arguments: DirectStoredPaymentMethod.allCases)
    internal func storedPaymentMethod_whenSubmitting_thenReferencesSelectedStoredMethod(
        storedMethod: DirectStoredPaymentMethod
    ) async throws {
        // Given
        let (sut, delegate) = makeSUT(paymentMethod: storedMethod.paymentMethod)

        // When
        let data = try await submittedData(from: sut, delegate: delegate) {
            sut.performSubmit()
        }

        // Then
        let details = try #require(data.paymentMethod as? StoredPaymentDetails)
        #expect(details.type == storedMethod.expectedType)
        #expect(details.storedPaymentMethodIdentifier == storedMethod.expectedIdentifier)
    }

    // MARK: - Loading state

    /// Drop-in stops loading on the component, never on the view controller it embedded, so the
    /// component must keep hold of the rendered controller and reset the state it started.
    @Test
    internal func storedPaymentMethod_whenSubmittingThenStoppingLoading_thenRestoresInteraction() throws {
        // Given
        let (sut, _) = makeSUT()
        let viewController = try #require(sut.viewController as? PaymentButtonViewController)
        viewController.loadViewIfNeeded()

        // When
        sut.performSubmit()

        // Then
        #expect(viewController.view.isUserInteractionEnabled == false)

        // When
        sut.stopLoading()

        // Then
        #expect(viewController.view.isUserInteractionEnabled == true)
    }

    // MARK: - Analytics

    /// `sendDidLoadEvent()` reports that the shopper actually saw the payment screen, as a
    /// `.rendered` info event. It regressed once when the component stopped owning its UI.
    @Test
    internal func storedPaymentMethod_whenViewControllerLoads_thenSendsDidLoadEvent() throws {
        // Given
        let analyticsProvider = AnalyticsProviderMock()
        let (sut, _) = makeSUT(context: makeContext(analyticsProvider: analyticsProvider))
        let viewController = try #require(sut.viewController as? PaymentButtonViewController)

        // When
        viewController.loadViewIfNeeded()

        // Then
        #expect(analyticsProvider.initialEventCallsCount == 1)
        // Did load info event should be sent
        #expect(analyticsProvider.infos.count == 1)
        #expect(analyticsProvider.infos.first?.type == .rendered)
    }

    @Test
    internal func storedPaymentMethod_whenSubmittingMultipleTimes_thenSendsInitialAnalyticsOnce() {
        // Given
        let analyticsProvider = AnalyticsProviderMock()
        let (sut, _) = makeSUT(context: makeContext(analyticsProvider: analyticsProvider))

        // When
        sut.performSubmit()
        sut.performSubmit()

        // Then
        #expect(analyticsProvider.initialEventCallsCount == 1)
        // Did load info event should NOT be sent
        #expect(analyticsProvider.infos.isEmpty)
    }

    /// Rendering and submitting both trigger initial analytics, so the deduplication has to hold
    /// across those two entry points, and submitting must not report a second render.
    @Test
    internal func storedPaymentMethod_whenRenderedThenSubmitted_thenReportsEachEventOnce() throws {
        // Given
        let analyticsProvider = AnalyticsProviderMock()
        let (sut, _) = makeSUT(context: makeContext(analyticsProvider: analyticsProvider))
        let viewController = try #require(sut.viewController as? PaymentButtonViewController)

        // When
        viewController.loadViewIfNeeded()
        sut.performSubmit()

        // Then
        #expect(analyticsProvider.initialEventCallsCount == 1)
        #expect(analyticsProvider.infos.filter { $0.type == .rendered }.count == 1)
    }

    // MARK: - SUT

    private func makeSUT(
        paymentMethod: StoredPaymentMethod = StoredPaymentMethodMock(
            identifier: "id",
            supportedShopperInteractions: [.shopperPresent],
            type: .other("type"),
            name: "name"
        ),
        context: AdyenContext = Dummy.context
    ) -> (sut: StoredPaymentMethodComponent, delegate: PaymentComponentDelegateMock) {
        let sut = StoredPaymentMethodComponent(paymentMethod: paymentMethod, context: context)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate
        return (sut, delegate)
    }

    private func makeContext(analyticsProvider: AnalyticsProviderMock) -> AdyenContext {
        AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: analyticsProvider
        )
    }

    private func payButtonTitle(in viewController: PaymentButtonViewController) throws -> String {
        let titleLabel: UILabel = try #require(
            viewController.view.findView(by: "payButtonItem.button.titleLabel"),
            "Cannot find the pay button title"
        )
        return try #require(titleLabel.text)
    }

    /// Bridges the delegate callback that submission reports asynchronously.
    private func submittedData(
        from component: StoredPaymentMethodComponent,
        delegate: PaymentComponentDelegateMock,
        when action: () -> Void
    ) async throws -> PaymentComponentData {
        try await withCheckedThrowingContinuation { continuation in
            delegate.onDidSubmit = { data, submittingComponent in
                #expect(submittingComponent === component)
                continuation.resume(returning: data)
            }
            delegate.onDidFail = { error, _ in
                continuation.resume(throwing: error)
            }
            action()
        }
    }
}

// MARK: - Stored payment methods

/// The stored payment methods this component handles, each submitting without shopper input.
internal enum DirectStoredPaymentMethod: String, CaseIterable, CustomTestStringConvertible {
    case achDirectDebit
    case cashAppPay
    case twint
    case payTo

    internal var testDescription: String {
        rawValue
    }

    internal var expectedType: PaymentMethodType {
        switch self {
        case .achDirectDebit: .achDirectDebit
        case .cashAppPay: .cashAppPay
        case .twint: .twint
        case .payTo: .payTo
        }
    }

    internal var expectedIdentifier: String {
        "\(rawValue)-id"
    }

    internal var paymentMethod: StoredPaymentMethod {
        switch self {
        case .achDirectDebit:
            StoredACHDirectDebitPaymentMethod(
                type: expectedType,
                name: "ACH Direct Debit",
                identifier: expectedIdentifier,
                supportedShopperInteractions: [.shopperPresent],
                bankAccountNumber: "123456789"
            )
        case .cashAppPay:
            StoredCashAppPayPaymentMethod(
                type: expectedType,
                name: "Cash App Pay",
                cashtag: "$adyen",
                identifier: expectedIdentifier,
                supportedShopperInteractions: [.shopperPresent]
            )
        case .twint:
            StoredTwintPaymentMethod(
                type: expectedType,
                name: "Twint",
                identifier: expectedIdentifier,
                supportedShopperInteractions: [.shopperPresent]
            )
        case .payTo:
            StoredPayToPaymentMethod(
                type: expectedType,
                name: "PayTo",
                identifier: expectedIdentifier,
                label: "***123",
                supportedShopperInteractions: [.shopperPresent]
            )
        }
    }
}
