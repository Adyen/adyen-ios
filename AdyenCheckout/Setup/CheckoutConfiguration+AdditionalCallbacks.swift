//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif

internal extension CheckoutConfiguration {

    /// Checks that the additional callbacks provide every callback the component configurations require.
    ///
    /// - Throws: `CheckoutError` with ``CheckoutError/Code/invalidConfiguration`` when a required callback is missing.
    func validate(additionalCallbacks: AdditionalCallbacksStore) throws {
        #if canImport(AdyenCard)
            let requiresAddressCallbacks = configurations.values.contains {
                ($0 as? CardConfiguration)?.requiresAddressCallbacks == true
            }
            if requiresAddressCallbacks, additionalCallbacks.callbacks(of: AddressCallbacks.self) == nil {
                throw CheckoutError(
                    code: .invalidConfiguration,
                    message: "Address lookup requires AddressCallbacks in the checkout callbacks."
                )
            }
        #endif
    }
}
