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

        let dropInComponent = CheckoutComponentBuilder.buildDropIn(
            paymentMethods: paymentMethods,
            configuration: configuration,
            context: adyenContext,
            actionComponentConfiguration: actionComponentConfiguration,
            storedPaymentMethodManagementCapability: sessionManagementCapability,
            paymentComponentProvider: makeDropInPaymentComponentProvider()
        )
        dropInComponent.delegate = self
        guard dropInComponent.hasSupportedPaymentMethods else {
            throw CheckoutError(code: .paymentMethodFailure, message: "No supported payment methods are available for Drop-in.")
        }
        return CheckoutDropInComponent(dropInComponent: dropInComponent)
    }
}

extension CheckoutCore {

    internal func makeDropInPaymentComponentProvider() -> DropInPaymentComponentProvider {
        let checkoutConfiguration = configuration
        let sessionConfiguration = session?.componentConfiguration
        let context = adyenContext
        return DropInPaymentComponentProvider(
            isAvailable: { paymentMethod in
                CheckoutComponentBuilder.isAvailable(
                    forAnyPaymentMethod: paymentMethod,
                    configuration: checkoutConfiguration
                )
            },
            build: { paymentMethod in
                try CheckoutComponentBuilder.build(
                    forAnyPaymentMethod: paymentMethod,
                    configuration: checkoutConfiguration,
                    policy: .dropIn,
                    sessionConfiguration: sessionConfiguration,
                    context: context
                )
            }
        )
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
