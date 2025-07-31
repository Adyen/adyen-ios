//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI
import Foundation
import UIKit

/// Configuration for BLIK Component.
public struct BLIKComponentConfiguration: CheckoutComponentConfiguration {
    
    package let componentType: Adyen.CheckoutComponentType = .payment(.blik)
    
    package var showsSubmitButton: Bool

    package var themeManager: AdyenCheckoutThemeManager?

    package var localizationParameters: LocalizationParameters?
    
    public init(
        showsSubmitButton: Bool = true,
        themeManager: AdyenCheckoutThemeManager? = nil,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.showsSubmitButton = showsSubmitButton
        self.themeManager = themeManager
        self.localizationParameters = localizationParameters
    }
}

extension BLIKComponentConfiguration {
    
    public func style(_ themeManager: AdyenCheckoutThemeManager) -> Self {
        var copy = self
        copy.themeManager = themeManager
        return copy
    }
    
    public func localization(_ localizationParameters: LocalizationParameters) -> Self {
        var copy = self
        copy.localizationParameters = localizationParameters
        return copy
    }
}
