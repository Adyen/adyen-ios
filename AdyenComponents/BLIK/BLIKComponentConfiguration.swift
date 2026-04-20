//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for BLIK Component.
public struct BLIKComponentConfiguration: CheckoutComponentConfiguration {
    
    package let componentType: Adyen.CheckoutComponentType = .payment(.blik)
    
    package var showsSubmitButton: Bool = true

    package var style: FormComponentStyle

    package var theme: AdyenTheme = .default

    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?
    
    public init(style: FormComponentStyle) {
        self.init(style: style, localizationParameters: nil)
    }

    package init(
        style: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
    }

    public init(
        theme: AdyenTheme = .default,
        style: FormComponentStyle = .init()
    ) {
        self.init(localizationParameters: nil, theme: theme, style: style)
    }

    package init(
        localizationParameters: LocalizationParameters? = nil,
        theme: AdyenTheme = .default,
        style: FormComponentStyle = .init()
    ) {
        self.theme = theme
        self.localizationParameters = localizationParameters
        self.style = style
    }
}
