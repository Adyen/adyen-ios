//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package extension FormAddressItem {
    
    /// The configuration of the form address item
    struct Configuration {
        
        /// The form style.
        internal let style: AddressStyle
        /// The localization parameters.
        internal let localizationParameters: LocalizationParameters?
        /// Supported country codes. If `nil`, all country codes are listed.
        internal let supportedCountryCodes: [String]?
        /// Whether to show a title header.
        internal let showsHeader: Bool
        
        /// Initializes the form address item configuration.
        /// - Parameters:
        ///   - style: The form style.
        ///   - localizationParameters: The localization parameters.
        ///   - supportedCountryCodes: Supported country codes. If `nil`, all country codes are listed.
        ///   - showsHeader: Whether to show a title header.
        public init(
            style: AddressStyle = AddressStyle(),
            localizationParameters: LocalizationParameters? = nil,
            supportedCountryCodes: [String]? = nil,
            showsHeader: Bool = true
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
            self.supportedCountryCodes = supportedCountryCodes
            self.showsHeader = showsHeader
        }
    }
}
