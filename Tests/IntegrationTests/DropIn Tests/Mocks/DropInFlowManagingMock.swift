//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Foundation

@MainActor
internal class DropInFlowManagingMock: DropInFlowManaging {

    // MARK: - submit

    var submitFromActionPresenterCallsCount = 0
    var submitFromActionPresenterCalled: Bool {
        submitFromActionPresenterCallsCount > 0
    }

    var submitFromActionPresenterReceivedArguments: (
        data: PaymentComponentData,
        component: PaymentComponent,
        actionPresenter: ActionPresenter
    )?

    func submit(
        _ data: PaymentComponentData,
        from component: PaymentComponent,
        actionPresenter: ActionPresenter
    ) {
        submitFromActionPresenterCallsCount += 1
        submitFromActionPresenterReceivedArguments = (data, component, actionPresenter)
    }

    // MARK: - fail

    var failWithFromCallsCount = 0
    var failWithFromCalled: Bool {
        failWithFromCallsCount > 0
    }

    var failWithFromReceivedArguments: (error: Error, component: PaymentComponent)?

    func fail(with error: Error, from component: PaymentComponent) {
        failWithFromCallsCount += 1
        failWithFromReceivedArguments = (error, component)
    }

    // MARK: - cancel

    var cancelComponentCallsCount = 0
    var cancelComponentCalled: Bool {
        cancelComponentCallsCount > 0
    }

    var cancelComponentReceivedComponent: PaymentComponent?

    func cancel(component: PaymentComponent) {
        cancelComponentCallsCount += 1
        cancelComponentReceivedComponent = component
    }

    // MARK: - handle

    var handleActionCallsCount = 0
    var handleActionCalled: Bool {
        handleActionCallsCount > 0
    }

    var handleActionReceivedAction: Action?

    func handle(action: Action) {
        handleActionCallsCount += 1
        handleActionReceivedAction = action
    }
}
