//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for the Twint Component.
public struct TwintComponentConfiguration: CheckoutComponentConfiguration {

    package var componentType: CheckoutComponentType = .payment(.twint)

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
    package var showsSubmitButton: Bool = true

    /// The theming to apply to the component's UI.
    package var theme: CheckoutTheme = .default

    /// The localization parameters, leave it nil to use the default parameters.
    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// Initializes a new instance of `TwintComponentConfiguration`.
    public init() {}
}
