//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenCheckout
@testable import AdyenComponents
@testable import AdyenSession
import UIKit
import XCTest

@MainActor
final class CheckoutCoreFinishTests: XCTestCase {

    private var paymentMethods: PaymentMethods!
    private var paymentMethod: BLIKPaymentMethod!
    private var callbackStore: AdvancedCheckoutCallbackStore!
    private var sut: CheckoutCore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethods = try AdyenCoder.decode(["paymentMethods": [blik]]) as PaymentMethods
        paymentMethod = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        callbackStore = AdvancedCheckoutCallbackStore()
        sut = CheckoutCore(
            configuration: makeConfiguration(),
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            resultCallbacks: callbackStore,
            callbackHandler: AdvancedCallbackHandler(callbackStore: callbackStore)
        )
    }

    override func tearDown() {
        sut = nil
        callbackStore = nil
        paymentMethod = nil
        paymentMethods = nil
        super.tearDown()
    }

    // MARK: - Waiting for the component

    func test_submitCompletion_shouldNotifyMerchantOnlyAfterComponentFinalizes() async {
        let component = FinalizablePaymentComponentMock(paymentMethod: paymentMethod)
        let finalizeStarted = expectation(description: "finalize started")
        component.onFinalize = { finalizeStarted.fulfill() }
        callbackStore.onSubmit = { _ in .completion(resultCode: CheckoutResultCode.authorised.rawValue) }
        var completionCount = 0
        let earlyCompletion = expectation(description: "onComplete before finalize returns")
        earlyCompletion.isInverted = true
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            completionCount += 1
            earlyCompletion.fulfill()
        }

        sut.didSubmit(makePaymentData(), from: component)
        await fulfillment(of: [finalizeStarted], timeout: 1)
        await fulfillment(of: [earlyCompletion], timeout: 0.2)
        XCTAssertEqual(component.finalizeCalls, [true])
        XCTAssertEqual(completionCount, 0)

        let completed = expectation(description: "onComplete called")
        callbackStore.onComplete = { _ in
            completionCount += 1
            completed.fulfill()
        }
        component.releaseFinalize()

        await fulfillment(of: [completed], timeout: 1)
        XCTAssertEqual(completionCount, 1)
    }

    func test_componentFailure_shouldNotifyMerchantOnlyAfterComponentFinalizes() async {
        let component = FinalizablePaymentComponentMock(paymentMethod: paymentMethod)
        let finalizeStarted = expectation(description: "finalize started")
        component.onFinalize = { finalizeStarted.fulfill() }
        var failureCount = 0
        let earlyFailure = expectation(description: "onFailure before finalize returns")
        earlyFailure.isInverted = true
        callbackStore.onFailure = { _ in
            failureCount += 1
            earlyFailure.fulfill()
        }

        sut.didFail(with: TestError(), from: component)
        await fulfillment(of: [finalizeStarted], timeout: 1)
        await fulfillment(of: [earlyFailure], timeout: 0.2)
        XCTAssertEqual(component.finalizeCalls, [false])
        XCTAssertEqual(failureCount, 0)

        let failed = expectation(description: "onFailure called")
        callbackStore.onFailure = { _ in
            failureCount += 1
            failed.fulfill()
        }
        component.releaseFinalize()

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertEqual(failureCount, 1)
    }

    func test_newSubmitWhileComponentFinalizes_shouldProceedAndStillDeliverPreviousOutcome() async {
        let firstComponent = FinalizablePaymentComponentMock(paymentMethod: paymentMethod)
        let secondComponent = PaymentComponentMock(paymentMethod: paymentMethod)
        let finalizeStarted = expectation(description: "finalize started")
        firstComponent.onFinalize = { finalizeStarted.fulfill() }
        let secondSubmitHandled = expectation(description: "second onSubmit called")
        let (secondSubmitGate, openSecondSubmitGate) = AsyncStream<Void>.makeStream()
        var submitCount = 0
        callbackStore.onSubmit = { _ in
            submitCount += 1
            guard submitCount > 1 else {
                return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
            }
            secondSubmitHandled.fulfill()
            for await _ in secondSubmitGate {}
            return .retry()
        }
        let completed = expectation(description: "onComplete called")
        var completionCount = 0
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            completionCount += 1
            completed.fulfill()
        }

        sut.didSubmit(makePaymentData(), from: firstComponent)
        await fulfillment(of: [finalizeStarted], timeout: 1)
        XCTAssertNil(sut.pendingPaymentComponent)

        sut.didSubmit(makePaymentData(), from: secondComponent)
        await fulfillment(of: [secondSubmitHandled], timeout: 1)
        XCTAssertTrue(sut.pendingPaymentComponent === secondComponent)

        firstComponent.releaseFinalize()
        await fulfillment(of: [completed], timeout: 1)
        XCTAssertEqual(completionCount, 1)
        openSecondSubmitGate.finish()
    }

    // MARK: - Ending an attempt without a result

    func test_retry_shouldEndComponentAttemptWithoutNotifyingMerchant() async {
        let component = FinalizablePaymentComponentMock(paymentMethod: paymentMethod)
        component.releaseFinalize()
        let finalized = expectation(description: "finalize called")
        component.onFinalize = { finalized.fulfill() }
        callbackStore.onSubmit = { _ in .retry() }
        let notified = expectation(description: "merchant must not be notified")
        notified.isInverted = true
        callbackStore.onComplete = { _ in notified.fulfill() }
        callbackStore.onFailure = { _ in notified.fulfill() }

        sut.didSubmit(makePaymentData(), from: component)

        await fulfillment(of: [finalized], timeout: 1)
        await fulfillment(of: [notified], timeout: 0.3)
        XCTAssertEqual(component.finalizeCalls, [false])
        XCTAssertNil(sut.pendingPaymentComponent)
    }

    func test_beforeSubmitAbort_shouldEndComponentAttemptWithoutNotifyingMerchant() async {
        let session = makeSessionMock()
        let sessionCallbackStore = SessionCheckoutCallbackStore()
        sessionCallbackStore.onBeforeSubmit = { _ in .abort }
        let notified = expectation(description: "merchant must not be notified")
        notified.isInverted = true
        sessionCallbackStore.onComplete = { _ in notified.fulfill() }
        sessionCallbackStore.onFailure = { _ in notified.fulfill() }
        let checkout = CheckoutCore(
            configuration: makeConfiguration(),
            session: session,
            adyenContext: Dummy.context,
            resultCallbacks: sessionCallbackStore,
            callbackHandler: BeforeSubmitCallbackHandler(
                handler: SessionCallbackHandler(session: session),
                session: session,
                callbackStore: sessionCallbackStore
            )
        )
        let component = FinalizablePaymentComponentMock(paymentMethod: paymentMethod)
        component.releaseFinalize()
        let finalized = expectation(description: "finalize called")
        component.onFinalize = { finalized.fulfill() }

        checkout.didSubmit(makePaymentData(), from: component)

        await fulfillment(of: [finalized], timeout: 1)
        await fulfillment(of: [notified], timeout: 0.3)
        XCTAssertEqual(component.finalizeCalls, [false])
        XCTAssertNil(checkout.pendingPaymentComponent)
        XCTAssertFalse(session.performSubmitCalled)
    }

    // MARK: - First outcome wins

    func test_closingDropInWhileSubmitting_shouldReportOnlyTheCancellation() async {
        let component = PaymentComponentMock(paymentMethod: paymentMethod)
        let dropIn = DropInComponentMock()
        let (submitGate, openSubmitGate) = AsyncStream<Void>.makeStream()
        let submitStarted = expectation(description: "onSubmit started")
        let submitReturned = expectation(description: "onSubmit returned")
        callbackStore.onSubmit = { _ in
            submitStarted.fulfill()
            for await _ in submitGate {}
            submitReturned.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        let failed = expectation(description: "onFailure called")
        var failureCodes: [CheckoutError.Code] = []
        callbackStore.onFailure = { error in
            failureCodes.append(error.code)
            failed.fulfill()
        }
        let completed = expectation(description: "onComplete must not be called")
        completed.isInverted = true
        callbackStore.onComplete = { _ in completed.fulfill() }

        sut.didSubmit(makePaymentData(), from: component, in: dropIn)
        await fulfillment(of: [submitStarted], timeout: 1)
        sut.didFail(with: ComponentError.cancelled, from: dropIn)
        await fulfillment(of: [failed], timeout: 1)

        openSubmitGate.finish()
        await fulfillment(of: [submitReturned], timeout: 1)
        await fulfillment(of: [completed], timeout: 0.3)
        XCTAssertEqual(failureCodes, [.cancelled])
    }

    func test_closingDropInWhileSubmitting_shouldIgnoreLateAction() async {
        let component = PaymentComponentMock(paymentMethod: paymentMethod)
        let dropIn = DropInComponentMock()
        let actionHandled = expectation(description: "late action must not be handled")
        actionHandled.isInverted = true
        dropIn.onHandle = { _ in actionHandled.fulfill() }
        let (submitGate, openSubmitGate) = AsyncStream<Void>.makeStream()
        let submitStarted = expectation(description: "onSubmit started")
        let submitReturned = expectation(description: "onSubmit returned")
        callbackStore.onSubmit = { _ in
            submitStarted.fulfill()
            for await _ in submitGate {}
            submitReturned.fulfill()
            return .action(.await(AwaitAction(paymentData: "payment-data", paymentMethodType: .blik)))
        }
        let failed = expectation(description: "onFailure called")
        callbackStore.onFailure = { _ in failed.fulfill() }

        sut.didSubmit(makePaymentData(), from: component, in: dropIn)
        await fulfillment(of: [submitStarted], timeout: 1)
        sut.didFail(with: ComponentError.cancelled, from: dropIn)
        await fulfillment(of: [failed], timeout: 1)

        openSubmitGate.finish()
        await fulfillment(of: [submitReturned], timeout: 1)
        await fulfillment(of: [actionHandled], timeout: 0.3)
    }

    func test_closingDropInWhileProvidingDetails_shouldReportOnlyTheCancellation() async {
        let dropIn = DropInComponentMock()
        let component = PaymentComponentMock(paymentMethod: paymentMethod)
        sut.pendingPaymentComponent = component
        let (detailsGate, openDetailsGate) = AsyncStream<Void>.makeStream()
        let detailsStarted = expectation(description: "onAdditionalDetails started")
        let detailsReturned = expectation(description: "onAdditionalDetails returned")
        callbackStore.onAdditionalDetails = { _ in
            detailsStarted.fulfill()
            for await _ in detailsGate {}
            detailsReturned.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        let failed = expectation(description: "onFailure called")
        var failureCount = 0
        callbackStore.onFailure = { _ in
            failureCount += 1
            failed.fulfill()
        }
        let completed = expectation(description: "onComplete must not be called")
        completed.isInverted = true
        callbackStore.onComplete = { _ in completed.fulfill() }
        let data = ActionComponentData(details: AwaitActionDetails(payload: "payload"), paymentData: "payment-data")

        sut.didProvide(data, from: ActionComponentMock(), in: dropIn)
        await fulfillment(of: [detailsStarted], timeout: 1)
        sut.didFail(with: ComponentError.cancelled, from: dropIn)
        await fulfillment(of: [failed], timeout: 1)

        openDetailsGate.finish()
        await fulfillment(of: [detailsReturned], timeout: 1)
        await fulfillment(of: [completed], timeout: 0.3)
        XCTAssertEqual(failureCount, 1)
    }

    // MARK: - Ending the drop in payment attempt

    func test_dropInSubmitCompletion_shouldEndTheDropInPaymentAttempt() async {
        let dropIn = DropInComponentMock()
        callbackStore.onSubmit = { _ in .completion(resultCode: CheckoutResultCode.authorised.rawValue) }
        let completed = expectation(description: "onComplete called")
        callbackStore.onComplete = { _ in completed.fulfill() }

        sut.didSubmit(makePaymentData(), from: PaymentComponentMock(paymentMethod: paymentMethod), in: dropIn)

        await fulfillment(of: [completed], timeout: 1)
        XCTAssertEqual(dropIn.endPaymentAttemptCallsCount, 1)
    }

    func test_dropInFailureWhileSubmitting_shouldEndTheDropInPaymentAttempt() async {
        let dropIn = DropInComponentMock()
        let component = PaymentComponentMock(paymentMethod: paymentMethod)
        let (submitGate, openSubmitGate) = AsyncStream<Void>.makeStream()
        let submitStarted = expectation(description: "onSubmit started")
        callbackStore.onSubmit = { _ in
            submitStarted.fulfill()
            for await _ in submitGate {}
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        let failed = expectation(description: "onFailure called")
        callbackStore.onFailure = { _ in failed.fulfill() }

        sut.didSubmit(makePaymentData(), from: component, in: dropIn)
        await fulfillment(of: [submitStarted], timeout: 1)
        sut.didFail(with: TestError(), from: component, in: dropIn)

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertEqual(dropIn.endPaymentAttemptCallsCount, 1)
        openSubmitGate.finish()
    }

    func test_dropInRetry_shouldEndTheDropInPaymentAttempt() async {
        let dropIn = DropInComponentMock()
        let component = FinalizablePaymentComponentMock(paymentMethod: paymentMethod)
        component.releaseFinalize()
        let finalized = expectation(description: "finalize called")
        component.onFinalize = { finalized.fulfill() }
        callbackStore.onSubmit = { _ in .retry() }

        sut.didSubmit(makePaymentData(), from: component, in: dropIn)

        await fulfillment(of: [finalized], timeout: 1)
        XCTAssertEqual(dropIn.endPaymentAttemptCallsCount, 1)
    }

    func test_dropInSubmitAction_shouldKeepTheDropInPaymentAttempt() async {
        let dropIn = DropInComponentMock()
        let actionHandled = expectation(description: "action handled")
        dropIn.onHandle = { _ in actionHandled.fulfill() }
        callbackStore.onSubmit = { _ in .action(.await(AwaitAction(paymentData: "payment-data", paymentMethodType: .blik))) }

        sut.didSubmit(makePaymentData(), from: PaymentComponentMock(paymentMethod: paymentMethod), in: dropIn)

        await fulfillment(of: [actionHandled], timeout: 1)
        XCTAssertEqual(dropIn.endPaymentAttemptCallsCount, 0)
    }

    // MARK: - Outcomes without a submit

    func test_closingDropInWithoutSubmit_shouldReportTheCancellation() async {
        let failed = expectation(description: "onFailure called")
        var failureCodes: [CheckoutError.Code] = []
        callbackStore.onFailure = { error in
            failureCodes.append(error.code)
            failed.fulfill()
        }

        sut.didFail(with: ComponentError.cancelled, from: DropInComponentMock())

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertNil(sut.pendingPaymentComponent)
        XCTAssertEqual(failureCodes, [.cancelled])
    }

    func test_cancellingTwiceWithoutSubmit_shouldReportBothCancellations() async {
        let component = PaymentComponentMock(paymentMethod: paymentMethod)
        let failed = expectation(description: "onFailure called twice")
        failed.expectedFulfillmentCount = 2
        var failureCodes: [CheckoutError.Code] = []
        callbackStore.onFailure = { error in
            failureCodes.append(error.code)
            failed.fulfill()
        }

        sut.didFail(with: ComponentError.cancelled, from: component)
        sut.didFail(with: ComponentError.cancelled, from: component)

        await fulfillment(of: [failed], timeout: 1)
        XCTAssertEqual(failureCodes, [.cancelled, .cancelled])
    }

    // MARK: - Helpers

    private func makeConfiguration() -> CheckoutConfiguration {
        CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
    }

    private func makeSessionMock() -> AdyenSessionMock {
        AdyenSessionMock(state: .init(
            data: "session-data",
            identifier: "session-id",
            countryCode: "NL",
            shopperLocale: "en_US",
            amount: Amount(value: 1000, currencyCode: "EUR"),
            paymentMethods: paymentMethods,
            responseConfiguration: .init(installmentOptions: nil, enableStoreDetails: true)
        ))
    }

    private func makePaymentData() -> PaymentComponentData {
        PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: paymentMethod, blikCode: "code"),
            order: nil
        )
    }
}

/// Stays in `finalize(success:)` until the test calls `releaseFinalize()`.
private final class FinalizablePaymentComponentMock: PaymentComponentMock, FinalizableComponent {

    private(set) var finalizeCalls: [Bool] = []
    var onFinalize: (() -> Void)?

    private var isReleased = false
    private var release: CheckedContinuation<Void, Never>?

    @MainActor
    func finalize(success: Bool) async {
        finalizeCalls.append(success)
        onFinalize?()
        guard !isReleased else { return }
        await withCheckedContinuation { release = $0 }
    }

    func releaseFinalize() {
        isReleased = true
        release?.resume()
        release = nil
    }
}

@MainActor
private final class DropInComponentMock: @preconcurrency AnyDropInComponent, ActionHandlingComponent {

    let context = Dummy.context
    let viewController = UIViewController()
    weak var delegate: DropInComponentDelegate?
    var onHandle: ((Action) -> Void)?

    func handle(_ action: Action) {
        onHandle?(action)
    }

    func reload(with order: PartialPaymentOrder, _ paymentMethods: PaymentMethods) throws {}

    private(set) var endPaymentAttemptCallsCount = 0

    func endPaymentAttempt() {
        endPaymentAttemptCallsCount += 1
    }
}

@MainActor
private final class ActionComponentMock: ActionComponent {
    let context = Dummy.context
    weak var delegate: ActionComponentDelegate?
}
