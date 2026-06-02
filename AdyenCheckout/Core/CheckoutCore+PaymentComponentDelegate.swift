//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

// MARK: - PaymentComponentDelegate

extension CheckoutCore: PaymentComponentDelegate {

    package func didSubmit(_ data: PaymentComponentData, from component: any PaymentComponent) {
        performSubmit(data, source: .component(component))
    }

    package func didFail(with error: any Error, from component: any PaymentComponent) {
        handle(error, from: component)
    }
}
