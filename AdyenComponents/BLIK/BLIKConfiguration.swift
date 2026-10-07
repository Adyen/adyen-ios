//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for BLIK Component.
public struct BLIKConfiguration: CheckoutComponentConfiguration {
    
    package let componentType: CheckoutComponentType = .payment(.blik)
    
    package var showsSubmitButton: Bool = true

    package var style: FormComponentStyle = .init()

    package var theme: CheckoutTheme = .default

    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// Initializes the configuration for BLIK.
    public init() {}
}
