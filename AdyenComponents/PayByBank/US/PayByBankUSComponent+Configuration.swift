//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

extension PayByBankUSComponent {
    
    public struct Configuration: AnyBasicComponentConfiguration {
        
        /// The UI style of the component.
        public var style: PayByBankUSComponent.Style
        
        public var localizationParameters: LocalizationParameters?
        
        /// Initializes a new instance of `PayByBankUSComponent.Configuration`
        ///
        /// - Parameters:
        ///   - style: The form style.
        ///   - localizationParameters: The localization parameters.
        public init(
            style: PayByBankUSComponent.Style = .init(),
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
}
