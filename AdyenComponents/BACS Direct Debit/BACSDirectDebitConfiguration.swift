//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for BACS Direct Debit.
public struct BACSDirectDebitConfiguration: CheckoutComponentConfiguration {

    package let componentType: CheckoutComponentType = .payment(.bacsDirectDebit)

    package var style: FormComponentStyle

    package var theme: CheckoutTheme

    package var showsSubmitButton: Bool

    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// Initializes the configuration for BACS Direct Debit.
    public init() {
        self.style = FormComponentStyle()
        self.theme = .init()
        self.showsSubmitButton = true
        self.localizationParameters = nil
    }
}
