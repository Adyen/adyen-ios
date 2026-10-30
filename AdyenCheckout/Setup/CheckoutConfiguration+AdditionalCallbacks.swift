//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

internal extension CheckoutConfiguration {

    /// Checks that the additional callbacks provide every callback the component configurations require.
    ///
    /// - Throws: `CheckoutError` with ``CheckoutError/Code/invalidConfiguration`` when a required callback is missing.
    func validate(additionalCallbacks: AdditionalCallbacksStore) throws {
        for componentConfiguration in configurations.values {
            try componentConfiguration.validate(additionalCallbacks)
        }
    }
}
