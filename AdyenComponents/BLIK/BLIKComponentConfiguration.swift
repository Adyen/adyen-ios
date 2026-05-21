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
package struct BLIKComponentConfiguration: CheckoutComponentConfiguration {
    
    package let componentType: Adyen.CheckoutComponentType = .payment(.blik)
    
    package var showsSubmitButton: Bool = true

    package var style: FormComponentStyle

    package var theme: CheckoutTheme = .default

    package var localizationParameters: LocalizationParameters?
    
    package init(
        style: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
    }

    package init(
        localizationParameters: LocalizationParameters? = nil,
        theme: CheckoutTheme = .default,
        style: FormComponentStyle = .init()
    ) {
        self.theme = theme
        self.localizationParameters = localizationParameters
        self.style = style
    }
}
