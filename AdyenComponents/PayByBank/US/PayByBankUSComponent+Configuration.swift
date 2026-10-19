//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

extension PayByBankUSComponent {
    
    package struct Configuration {

        /// The UI style of the component.
        ///
        package var style: PayByBankUSComponent.Style

        package var localizationParameters: LocalizationParameters?

        /// Initializes a new instance of `PayByBankUSComponent.Configuration`
        ///
        /// - Parameters:
        ///   - style: The form style.
        ///   - localizationParameters: The localization parameters.
        package init(style: PayByBankUSComponent.Style = .init()) {
            self.init(style: style, localizationParameters: nil)
        }

        package init(
            style: PayByBankUSComponent.Style = .init(),
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
}
