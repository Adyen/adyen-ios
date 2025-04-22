//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// Configuration for BLIK Component.
public struct BLIKComponentConfiguration: CheckoutComponentConfiguration {
    public let componentType: Adyen.CheckoutComponentType = .payment(.blik)
    
    public var showsSubmitButton: Bool
    
    public var style: FormComponentStyle
    
    public var localizationParameters: LocalizationParameters?
    
    public init(
        showsSubmitButton: Bool = true,
        style: FormComponentStyle = .init(),
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.showsSubmitButton = showsSubmitButton
        self.style = style
        self.localizationParameters = localizationParameters
    }
    
    public func showsSubmitButton(_ showsSubmitButton: Bool) -> Self {
        var copy = self
        copy.showsSubmitButton = showsSubmitButton
        return copy
    }
    
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
