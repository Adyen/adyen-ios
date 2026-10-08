//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn

@MainActor
final class DropInFlowManagingMock: DropInFlowManaging {

    var dropInFlowRouter: DropInFlowRouting?

    var submitCallsCount = 0
    var submitCalled: Bool {
        submitCallsCount > 0
    }

    var submitReceivedArguments: (data: PaymentComponentData, component: PaymentComponent)?
    func submit(_ data: PaymentComponentData, from component: PaymentComponent) {
        submitCallsCount += 1
        submitReceivedArguments = (data: data, component: component)
    }

    var receiveCallsCount = 0
    var receiveCalled: Bool {
        receiveCallsCount > 0
    }

    var receiveReceivedArguments: Action?
    func receive(action: Action) {
        receiveCallsCount += 1
        receiveReceivedArguments = action
    }

    var failCallsCount = 0
    var failCalled: Bool {
        failCallsCount > 0
    }

    var failReceivedArguments: (error: Error, component: PaymentComponent)?
    func fail(with error: Error, from component: PaymentComponent) {
        failCallsCount += 1
        failReceivedArguments = (error: error, component: component)
    }

    var discardPendingSubmissionCallsCount = 0
    var discardPendingSubmissionCalled: Bool {
        discardPendingSubmissionCallsCount > 0
    }

    func discardPendingSubmission() {
        discardPendingSubmissionCallsCount += 1
    }

    var cancelDropInCallsCount = 0
    var cancelDropInCalled: Bool {
        cancelDropInCallsCount > 0
    }

    func cancelDropIn() {
        cancelDropInCallsCount += 1
    }

    var dismissDropInCallsCount = 0
    var dismissDropInCalled: Bool {
        dismissDropInCallsCount > 0
    }

    func dismissDropIn() {
        dismissDropInCallsCount += 1
    }
}
