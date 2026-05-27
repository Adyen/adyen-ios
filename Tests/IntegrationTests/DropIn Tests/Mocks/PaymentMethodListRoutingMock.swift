//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Foundation

class PaymentMethodListRoutingMock: PaymentMethodListRouting {
    var presentComponentCallsCount = 0
    var presentComponentReceivedComponent: PaymentComponent?

    func present(component: PaymentComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
    }

    var presentViewControllerCallsCount = 0
    var presentViewControllerReceivedViewController: UIViewController?

    func present(viewController: UIViewController) {
        presentViewControllerCallsCount += 1
        presentViewControllerReceivedViewController = viewController
    }

    var presentActionComponentOnCancelCallsCount = 0
    var presentActionComponentOnCancelReceivedArguments: (actionComponent: PresentableComponent, onCancel: (() -> Void)?)?

    func present(actionComponent: PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
        presentActionComponentOnCancelReceivedArguments = (actionComponent, onCancel)
    }

    var dismissCompletionCallsCount = 0
    var dismissCompletionReceivedCompletion: (() -> Void)?

    func dismiss(completion: (() -> Void)?) {
        dismissCompletionCallsCount += 1
        dismissCompletionReceivedCompletion = completion
        completion?()
    }
}
