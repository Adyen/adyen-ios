//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenDropIn)
    import AdyenDropIn
#endif

extension CheckoutCore {

    package func createDropIn() throws -> CheckoutDropInComponent {
        guard let paymentMethods else {
            throw CheckoutError(code: .paymentMethodFailure, message: "No payment methods are available for Drop-in.")
        }

        let checkoutConfiguration = configuration
        let sessionConfiguration = session?.componentConfiguration
        let context = adyenContext
        let paymentComponentBuilder: DropInPaymentComponentBuilder = { paymentMethod in
            try CheckoutComponentBuilder.build(
                forAnyPaymentMethod: paymentMethod,
                configuration: checkoutConfiguration,
                sessionConfiguration: sessionConfiguration,
                context: context
            )
        }
        let dropInComponent = CheckoutComponentBuilder.buildDropIn(
            paymentMethods: paymentMethods,
            configuration: checkoutConfiguration,
            context: context,
            actionComponentConfiguration: actionComponentConfiguration,
            storedPaymentMethodManagementCapability: sessionManagementCapability,
            paymentComponentBuilder: paymentComponentBuilder
        )
        dropInComponent.delegate = self
        guard dropInComponent.hasSupportedPaymentMethods else {
            throw CheckoutError(code: .paymentMethodFailure, message: "No supported payment methods are available for Drop-in.")
        }
        return CheckoutDropInComponent(dropInComponent: dropInComponent)
    }
}

private extension CheckoutCore {

    var sessionManagementCapability: StoredPaymentMethodManagementCapability? {
        guard let session, session.showRemovePaymentMethodButton else { return nil }

        return StoredPaymentMethodManagementCapability { [weak session] storedPaymentMethod in
            guard let session else {
                throw StoredPaymentMethodRemovalError.unavailable
            }
            try await session.disable(storedPaymentMethod: storedPaymentMethod)
        }
    }
}
