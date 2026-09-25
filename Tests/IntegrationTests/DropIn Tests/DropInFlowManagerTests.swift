//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
@testable import AdyenUI
import Testing
import UIKit

@MainActor
struct DropInFlowManagerTests {

    // MARK: - Submission Tests

    @Test
    func submit_shouldNotifyTheMerchantOfTheSubmittedData() async {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()
        let data = makePaymentComponentData()

        // When
        environment.sut.submit(data, from: component)
        await waitUntil { environment.dropInComponentDelegate.didSubmitFromInCalled }

        // Then
        #expect(environment.dropInComponentDelegate.didSubmitFromInCallsCount == 1)
        let receivedArguments = environment.dropInComponentDelegate.didSubmitFromInReceivedArguments
        #expect(receivedArguments?.component === component)
        #expect(receivedArguments?.dropInComponent === environment.dropInComponent)
    }

    @Test("The data is prepared by the component before being submitted, to let it inject the amount to pay.")
    func submit_shouldSubmitTheDataPreparedByTheComponent() async {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()
        let data = makePaymentComponentData()

        // When
        environment.sut.submit(data, from: component)
        await waitUntil { environment.dropInComponentDelegate.didSubmitFromInCalled }

        // Then
        let submittedData = environment.dropInComponentDelegate.didSubmitFromInReceivedArguments?.data
        #expect((submittedData?.paymentMethod as? GenericPaymentDetails)?.type == component.paymentMethod.type)
    }

    // MARK: - Action Receipt Tests

    @Test("An action can arrive when none is expected, for example when the drop in was closed while the payment was in flight.")
    func receive_whenNoPaymentWasSubmitted_shouldNotHandleTheAction() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.receive(action: makeAction())

        // Then
        #expect(environment.dropInFlowRouter.presentPaymentActionRouterCallsCount == 0)
        #expect(environment.paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelCallsCount == 0)
    }

    @Test
    func receive_afterTheSubmissionWasCancelled_shouldNotHandleTheAction() async {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()
        environment.sut.submit(makePaymentComponentData(), from: component)
        await waitUntil { environment.dropInComponentDelegate.didSubmitFromInCalled }
        environment.sut.cancel(component: component)

        // When
        environment.sut.receive(action: makeAction())

        // Then
        #expect(environment.dropInFlowRouter.presentPaymentActionRouterCallsCount == 0)
    }

    @Test
    func receive_afterTheActionFlowCompleted_shouldNotHandleTheAction() throws {
        // Given
        let environment = makeSUT()
        let actionComponent = ActionComponentMock()
        // The details of a 3DS2 fingerprint are provided, so a follow up action is expected,
        try environment.sut.didProvide(ActionComponentData(details: makeActionDetails(), paymentData: nil), from: actionComponent)
        // until the action flow reports completion.
        environment.sut.didComplete(from: actionComponent)

        // When
        environment.sut.receive(action: makeAction())

        // Then
        #expect(environment.dropInFlowRouter.presentPaymentActionRouterCallsCount == 0)
    }

    // MARK: - Failure Tests

    @Test
    func fail_shouldNotifyTheMerchantOfTheComponentFailure() {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()
        let error = ErrorMock(errorDescription: "Payment component's error")

        // When
        environment.sut.fail(with: error, from: component)

        // Then
        #expect(environment.dropInComponentDelegate.didFailWithFromInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didFailWithFromInReceivedArguments?.component === component)
    }

    @Test("The merchant is looked up on the drop in, so a delegate set after initialisation is notified too.")
    func fail_withADelegateSetAfterInitialisation_shouldNotifyTheNewDelegate() {
        // Given
        let environment = makeSUT()
        let newDelegate = DropInComponentDelegateMock()
        environment.dropInComponent.delegate = newDelegate

        // When
        environment.sut.fail(with: ErrorMock(errorDescription: "Payment component's error"), from: makePaymentComponent())

        // Then
        #expect(newDelegate.didFailWithFromInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didFailWithFromInCallsCount == 0)
    }

    // MARK: - Cancellation Tests

    @Test
    func cancelComponent_shouldNotifyTheMerchantOfTheCancelledComponent() {
        // Given
        let environment = makeSUT()
        let component = makePaymentComponent()

        // When
        environment.sut.cancel(component: component)

        // Then
        #expect(environment.dropInComponentDelegate.didCancelComponentFromCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didCancelComponentFromReceivedArguments?.component === component)
    }

    @Test
    func cancelDropIn_shouldNotifyTheMerchantWithACancellationError() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()

        // Then
        #expect(environment.dropInComponentDelegate.didFailWithFromCallsCount == 1)
        #expect(isCancellation(environment.dropInComponentDelegate.didFailWithFromReceivedArguments?.error))
    }

    @Test
    func cancelDropIn_shouldSendAClosedAnalyticsEvent() throws {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()

        // Then
        let log = try #require(environment.analyticsProvider.logs.first)
        #expect(log.component == "dropin")
        #expect(log.type == .closed)
    }

    @Test("The drop in can be cancelled from several places at once, for example by a swipe that also dismisses an action.")
    func cancelDropIn_whenCalledRepeatedly_shouldOnlyNotifyTheMerchantOnce() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()
        environment.sut.cancelDropIn()

        // Then
        #expect(environment.dropInComponentDelegate.didFailWithFromCallsCount == 1)
        #expect(environment.analyticsProvider.logs.count == 1)
    }

    @Test("Cancelling the drop in only notifies the merchant, so the drop in is dismissed separately.")
    func cancelDropIn_shouldNotDismissTheDropIn() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.cancelDropIn()

        // Then
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 0)
    }

    @Test
    func dismissDropIn_shouldDismissThroughTheRouter() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.dismissDropIn()

        // Then
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 1)
    }

    // MARK: - ActionComponentDelegate Tests

    @Test("The loading state is reset when the shopper leaves the app, as they can come back without completing the action.")
    func didOpenExternalApplication_shouldStopTheActionComponentLoading() {
        // Given
        let environment = makeSUT()
        let actionComponent = ActionComponentMock()

        // When
        environment.sut.didOpenExternalApplication(component: actionComponent)

        // Then
        #expect(actionComponent.stopLoadingCallsCount == 1)
    }

    @Test
    func didOpenExternalApplication_shouldNotifyTheMerchant() {
        // Given
        let environment = makeSUT()
        let actionComponent = ActionComponentMock()

        // When
        environment.sut.didOpenExternalApplication(component: actionComponent)

        // Then
        #expect(environment.dropInComponentDelegate.didOpenExternalApplicationComponentInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didOpenExternalApplicationComponentInReceivedArguments?.component === actionComponent)
    }

    @Test
    func didProvide_shouldNotifyTheMerchantOfTheActionDetails() throws {
        // Given
        let environment = makeSUT()
        let actionComponent = ActionComponentMock()
        let data = try ActionComponentData(details: makeActionDetails(), paymentData: "payment_data")

        // When
        environment.sut.didProvide(data, from: actionComponent)

        // Then
        #expect(environment.dropInComponentDelegate.didProvideFromInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didProvideFromInReceivedArguments?.component === actionComponent)
    }

    @Test
    func didComplete_shouldNotifyTheMerchant() {
        // Given
        let environment = makeSUT()
        let actionComponent = ActionComponentMock()

        // When
        environment.sut.didComplete(from: actionComponent)

        // Then
        #expect(environment.dropInComponentDelegate.didCompleteFromInCallsCount == 1)
        #expect(environment.dropInComponentDelegate.didCompleteFromInReceivedArguments?.component === actionComponent)
    }

    @Test
    func didFailAction_givenAnError_shouldNotifyTheMerchantWithoutDismissingTheDropIn() {
        // Given
        let environment = makeSUT()
        let actionComponent = ActionComponentMock()
        let error = ErrorMock(errorDescription: "Action component's error")

        // When
        environment.sut.didFail(with: error, from: actionComponent)

        // Then
        #expect(environment.dropInComponentDelegate.didFailActionWithFromInCallsCount == 1)
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 0)
    }

    @Test("Dismissing an action, for example by closing the web page of a redirect, dismisses the drop in.")
    func didFailAction_givenACancellation_shouldCancelAndDismissTheDropIn() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.didFail(with: ComponentError.cancelled, from: ActionComponentMock())

        // Then
        #expect(environment.dropInComponentDelegate.didFailActionWithFromInCallsCount == 0)
        #expect(isCancellation(environment.dropInComponentDelegate.didFailWithFromReceivedArguments?.error))
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 1)
    }

    // MARK: - PresentationDelegate Tests

    @Test
    func present_shouldResolveThePaymentActionRouterForTheActionViewController() throws {
        // Given
        let environment = makeSUT()
        let actionViewController = UIViewController()

        // When
        environment.sut.present(viewController: actionViewController)

        // Then
        #expect(environment.paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelCallsCount == 1)
        let receivedArguments = try #require(environment.paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelReceivedArguments)
        #expect(receivedArguments.actionViewController === actionViewController)
        #expect(receivedArguments.listener === environment.dropInFlowRouter)
    }

    @Test
    func present_shouldPresentTheResolvedRouterOnTheDropInRouter() {
        // Given
        let environment = makeSUT()
        let paymentActionRouter = RouterMock()
        environment.paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelReturnValue = paymentActionRouter

        // When
        environment.sut.present(viewController: UIViewController())

        // Then
        #expect(environment.dropInFlowRouter.presentPaymentActionRouterCallsCount == 1)
        #expect(environment.dropInFlowRouter.presentPaymentActionRouterReceivedPaymentActionRouter === paymentActionRouter)
    }

    @Test("The action module dismisses the drop in through its listener, so only the merchant needs to be notified on cancellation.")
    func present_whenTheResolvedActionIsCancelled_shouldOnlyCancelTheDropIn() throws {
        // Given
        let environment = makeSUT()
        environment.sut.present(viewController: UIViewController())
        let onCancel = try #require(environment.paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelReceivedArguments?.onCancel)

        // When
        onCancel()

        // Then
        #expect(isCancellation(environment.dropInComponentDelegate.didFailWithFromReceivedArguments?.error))
        #expect(environment.dropInFlowRouter.dismissDropInCompletionCallsCount == 0)
    }

    @Test
    func present_withoutARouter_shouldNotResolveAPaymentActionRouter() {
        // Given
        let environment = makeSUT()
        environment.sut.dropInFlowRouter = nil

        // When
        environment.sut.present(viewController: UIViewController())

        // Then
        #expect(environment.paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelCallsCount == 0)
    }

    // MARK: - Mocks

    @MainActor
    private final class ActionComponentMock: ActionComponent, LoadingComponent {
        let context = Dummy.context
        weak var delegate: ActionComponentDelegate?

        var stopLoadingCallsCount = 0

        func stopLoading() {
            stopLoadingCallsCount += 1
        }
    }

    // MARK: - Helpers

    /// The flow manager holds the drop in, its delegate and its router weakly, so they are kept alive by the environment.
    @MainActor
    private struct Environment {
        let sut: DropInFlowManager
        let dropInComponent: DropInComponent
        let dropInComponentDelegate: DropInComponentDelegateMock
        let dropInFlowRouter: DropInFlowRoutingMock
        let paymentActionAssembler: PaymentActionAssemblerProtocolMock
        let analyticsProvider: AnalyticsProviderMock
    }

    private func makeSUT() -> Environment {
        let analyticsProvider = AnalyticsProviderMock()
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Amount(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: analyticsProvider
        )

        let dropInComponent = DropInComponent(
            paymentMethods: PaymentMethods(regular: [], stored: []),
            context: context,
            paymentComponentBuilder: { PaymentComponentMock(paymentMethod: $0) }
        )

        let dropInComponentDelegate = DropInComponentDelegateMock()
        dropInComponent.delegate = dropInComponentDelegate

        let paymentActionAssembler = PaymentActionAssemblerProtocolMock()
        paymentActionAssembler.resolvePaymentActionRouterForListenerOnCancelReturnValue = RouterMock()

        let sut = DropInFlowManager(
            dropInComponent: dropInComponent,
            context: context,
            actionComponentConfiguration: .init(),
            paymentActionAssembler: paymentActionAssembler
        )

        let dropInFlowRouter = DropInFlowRoutingMock()
        sut.dropInFlowRouter = dropInFlowRouter

        return Environment(
            sut: sut,
            dropInComponent: dropInComponent,
            dropInComponentDelegate: dropInComponentDelegate,
            dropInFlowRouter: dropInFlowRouter,
            paymentActionAssembler: paymentActionAssembler,
            analyticsProvider: analyticsProvider
        )
    }

    private func makePaymentComponent() -> PaymentComponentMock {
        PaymentComponentMock(paymentMethod: PaymentMethodMock(type: .other("genericPaymentMethod"), name: "Generic"))
    }

    private func makePaymentComponentData() -> PaymentComponentData {
        PaymentComponentData(
            paymentMethodDetails: GenericPaymentDetails(type: .other("genericPaymentMethod")),
            order: nil
        )
    }

    private func makeAction() -> Action {
        .redirect(RedirectAction(url: URL(string: "https://adyen.com")!, paymentData: "payment_data"))
    }

    private func makeActionDetails() throws -> AdditionalDetails {
        try RedirectDetails(returnURL: URL(string: "https://adyen.com?redirectResult=result")!)
    }

    private func isCancellation(_ error: Error?) -> Bool {
        guard let error = error as? ComponentError, case .cancelled = error else { return false }
        return true
    }
}
