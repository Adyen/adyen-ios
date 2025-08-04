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

    package var theme: AdyenTheme?

    package var localizationParameters: LocalizationParameters?
    
    public init(
        showsSubmitButton: Bool = true,
        theme: AdyenTheme? = nil,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.showsSubmitButton = showsSubmitButton
        self.theme = theme
        self.localizationParameters = localizationParameters
    }
}

extension BLIKComponentConfiguration {
    
    public func style(_ theme: AdyenTheme) -> Self {
        var copy = self
        copy.theme = theme
        return copy
    }
    
    public func localization(_ localizationParameters: LocalizationParameters) -> Self {
        var copy = self
        copy.localizationParameters = localizationParameters
        return copy
    }
}
