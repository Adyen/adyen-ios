//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Session-owned configuration that is applied while assembling payment components.
package struct SessionComponentConfiguration {

    package let installmentConfiguration: InstallmentConfiguration?

    package let showStorePaymentMethod: Bool

    package init(
        installmentConfiguration: InstallmentConfiguration?,
        showStorePaymentMethod: Bool
    ) {
        self.installmentConfiguration = installmentConfiguration
        self.showStorePaymentMethod = showStorePaymentMethod
    }
}
