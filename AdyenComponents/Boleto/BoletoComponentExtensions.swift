//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

extension BoletoComponent {
    
    /// Boleto component configuration.
    public struct Configuration: AnyPersonalInformationConfiguration {
        
        /// Describes the component's UI style.
        public let style: FormComponentStyle
        
        public var localizationParameters: LocalizationParameters?
        
        /// Pre-filled optional personal information about the shopper
        public let shopperInformation: PrefilledShopperInformation?
        
        /// Indicates whether to show `sendCopyByEmail` checkbox and email text field
        internal let showEmailAddress: Bool
        
        /// Initializes the configuration for Boleto Component.
        /// - Parameters:
        ///   - style: The UI style of the component.
        ///   - localizationParameters: Localization parameters.
        ///   - shopperInformation: Pre-filled optional personal information about the shopper
        ///   - showEmailAddress: Indicates whether to show `sendCopyByEmail` checkbox and email text field
        public init(style: FormComponentStyle = FormComponentStyle(),
                    localizationParameters: LocalizationParameters? = nil,
                    shopperInformation: PrefilledShopperInformation?,
                    showEmailAddress: Bool) {
            self.style = style
            self.localizationParameters = localizationParameters
            self.shopperInformation = shopperInformation
            self.showEmailAddress = showEmailAddress
        }
    }
    
}
