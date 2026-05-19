//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

// MARK: - ActionComponentDelegate

extension CheckoutCore: ActionComponentDelegate {

    public func didProvide(_ data: ActionComponentData, from component: any ActionComponent) {
        performAdditionalDetails(data, from: component)
    }

    public func didComplete(from component: any ActionComponent) {
        completeAction(from: pendingPaymentComponent)
    }

    public func didFail(with error: any Error, from component: any ActionComponent) {
        // Route back to the payment component that started this flow so any UI
        // it's still holding open (e.g. the Apple Pay sheet) can dismiss.
        handle(error, from: pendingPaymentComponent)
    }
}
