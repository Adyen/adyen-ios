//
// Copyright (c) Adyen N.V.
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
    
    package let configurationType: Adyen.CheckoutConfigurationType = .payment(.blik)
    
    package var showsSubmitButton: Bool = true

    package var style: FormComponentStyle

    package var theme: AdyenTheme = .default

    package var localizationParameters: LocalizationParameters?
    
    public init(
        style: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
    }

    public init(
        localizationParameters: LocalizationParameters? = nil,
        theme: AdyenTheme = .default,
        style: FormComponentStyle = .init()
    ) {
        self.theme = theme
        self.localizationParameters = localizationParameters
        self.style = style
    }
}
