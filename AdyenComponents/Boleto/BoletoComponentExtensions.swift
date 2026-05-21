//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

extension BoletoComponent {
    
    /// Boleto component configuration.
    package struct Configuration: AnyPersonalInformationConfiguration {
        
        /// Describes the component's UI style.
        package let style: FormComponentStyle

        /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
        package let showsSubmitButton: Bool

        package var localizationParameters: LocalizationParameters?
        
        /// Pre-filled optional personal information about the shopper
        package let shopperInformation: PrefilledShopperInformation?
        
        /// Indicates whether to show `sendCopyByEmail` checkbox and email text field
        package let showEmailAddress: Bool
        
        /// Initializes the configuration for Boleto Component.
        /// - Parameters:
        ///   - style: The UI style of the component.
        ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
        ///   Defaults to`true`.
        ///   - localizationParameters: Localization parameters.
        ///   - shopperInformation: Pre-filled optional personal information about the shopper
        ///   - showEmailAddress: Indicates whether to show `sendCopyByEmail` checkbox and email text field
        package init(
            style: FormComponentStyle = FormComponentStyle(),
            showsSubmitButton: Bool = true,
            localizationParameters: LocalizationParameters? = nil,
            shopperInformation: PrefilledShopperInformation?,
            showEmailAddress: Bool
        ) {
            self.style = style
            self.showsSubmitButton = showsSubmitButton
            self.localizationParameters = localizationParameters
            self.shopperInformation = shopperInformation
            self.showEmailAddress = showEmailAddress
        }
    }
    
}
