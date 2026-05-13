//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

// MARK: - DropInComponentDelegate

extension Checkout: DropInComponentDelegate {

    package func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent, in dropInComponent: any AnyDropInComponent) {
        performSubmit(data, source: .dropIn(component: component, dropInComponent: dropInComponent))
    }

    package func didFail(with error: any Error, from component: any PaymentComponent, in dropInComponent: any AnyDropInComponent) {
        handle(error, from: component)
    }

    package func didProvide(_ data: ActionComponentData, from component: any ActionComponent, in dropInComponent: any AnyDropInComponent) {
        performAdditionalDetails(data, from: component)
    }

    package func didComplete(from component: any ActionComponent, in dropInComponent: any AnyDropInComponent) {
        completeAction(from: pendingPaymentComponent)
    }

    package func didFail(with error: any Error, from component: any ActionComponent, in dropInComponent: any AnyDropInComponent) {
        handle(error, from: pendingPaymentComponent)
    }

    package func didFail(with error: any Error, from dropInComponent: any AnyDropInComponent) {
        handle(error, from: pendingPaymentComponent)
    }

    package func didOpenExternalApplication(component: any ActionComponent, in dropInComponent: any AnyDropInComponent) {
        // TODO: expose a Checkout callback for external app handoff if needed.
    }
}
