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
    
    package var showsSubmitButton: Bool

    package var style: FormComponentStyle

    package var theme: CheckoutTheme = AdyenTheme()

    package var localizationParameters: LocalizationParameters?
    
    public init(
        showsSubmitButton: Bool = true,
        style: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.showsSubmitButton = showsSubmitButton
        self.style = style
        self.localizationParameters = localizationParameters
    }

    public init(
        showsSubmitButton: Bool = true,
        localizationParameters: LocalizationParameters? = nil,
        theme: AdyenTheme = .init(),
        style: FormComponentStyle = .init()
    ) {
        self.showsSubmitButton = showsSubmitButton
        self.theme = theme
        self.localizationParameters = localizationParameters
        self.style = style
    }
}

extension BLIKComponentConfiguration {
    
    public func style(_ style: FormComponentStyle) -> Self {
        var copy = self
        copy.style = style
        return copy
    }

    public func localization(_ localizationParameters: LocalizationParameters) -> Self {
        var copy = self
        copy.localizationParameters = localizationParameters
        return copy
    }
}
