//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Combine

final class DropInFlowManagingMock: DropInFlowManaging {

    var dropInFlowRouter: DropInFlowRouting?

    // MARK: - paymentInProgressPublisher

    let paymentInProgressSubject = CurrentValueSubject<Bool, Never>(false)

    var paymentInProgressPublisher: AnyPublisher<Bool, Never> {
        paymentInProgressSubject.eraseToAnyPublisher()
    }

    // MARK: - submit

    var submitFromCallsCount = 0
    var submitFromCalled: Bool {
        submitFromCallsCount > 0
    }

    var submitFromReceivedArguments: (data: PaymentComponentData, component: PaymentComponent)?
    var submitFromReceivedInvocations: [(data: PaymentComponentData, component: PaymentComponent)] = []
    var submitFromClosure: ((PaymentComponentData, PaymentComponent) -> Void)?

    func submit(_ data: PaymentComponentData, from component: PaymentComponent) {
        submitFromCallsCount += 1
        submitFromReceivedArguments = (data: data, component: component)
        submitFromReceivedInvocations.append((data: data, component: component))
        submitFromClosure?(data, component)
    }

    // MARK: - receive

    var receiveActionCallsCount = 0
    var receiveActionCalled: Bool {
        receiveActionCallsCount > 0
    }

    var receiveActionReceivedAction: Action?
    var receiveActionReceivedInvocations: [Action] = []
    var receiveActionClosure: ((Action) -> Void)?

    func receive(action: Action) {
        receiveActionCallsCount += 1
        receiveActionReceivedAction = action
        receiveActionReceivedInvocations.append(action)
        receiveActionClosure?(action)
    }

    // MARK: - fail

    var failWithFromCallsCount = 0
    var failWithFromCalled: Bool {
        failWithFromCallsCount > 0
    }

    var failWithFromReceivedArguments: (error: Error, component: PaymentComponent)?
    var failWithFromReceivedInvocations: [(error: Error, component: PaymentComponent)] = []
    var failWithFromClosure: ((Error, PaymentComponent) -> Void)?

    func fail(with error: Error, from component: PaymentComponent) {
        failWithFromCallsCount += 1
        failWithFromReceivedArguments = (error: error, component: component)
        failWithFromReceivedInvocations.append((error: error, component: component))
        failWithFromClosure?(error, component)
    }

    // MARK: - cancel

    var cancelComponentCallsCount = 0
    var cancelComponentCalled: Bool {
        cancelComponentCallsCount > 0
    }

    var cancelComponentReceivedComponent: PaymentComponent?
    var cancelComponentReceivedInvocations: [PaymentComponent] = []
    var cancelComponentClosure: ((PaymentComponent) -> Void)?

    func cancel(component: PaymentComponent) {
        cancelComponentCallsCount += 1
        cancelComponentReceivedComponent = component
        cancelComponentReceivedInvocations.append(component)
        cancelComponentClosure?(component)
    }

    // MARK: - cancelDropIn

    var cancelDropInCallsCount = 0
    var cancelDropInCalled: Bool {
        cancelDropInCallsCount > 0
    }

    var cancelDropInClosure: (() -> Void)?

    func cancelDropIn() {
        cancelDropInCallsCount += 1
        cancelDropInClosure?()
    }

    // MARK: - dismissDropIn

    var dismissDropInCallsCount = 0
    var dismissDropInCalled: Bool {
        dismissDropInCallsCount > 0
    }

    var dismissDropInClosure: (() -> Void)?

    func dismissDropIn() {
        dismissDropInCallsCount += 1
        dismissDropInClosure?()
    }

    // MARK: - endPaymentAttempt

    var endPaymentAttemptCallsCount = 0
    var endPaymentAttemptCalled: Bool {
        endPaymentAttemptCallsCount > 0
    }

    var onEndPaymentAttempt: (() -> Void)?

    func endPaymentAttempt() {
        endPaymentAttemptCallsCount += 1
        onEndPaymentAttempt?()
    }
}
