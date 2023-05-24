//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Describes any configuration for the gift card component.
public protocol AnyGiftCardConfiguration {
    
    /// Indicates whether to show the security code field at all.
    var showsSecurityCodeField: Bool { get }
}

extension GiftCardComponent {
    
    /// Gift card component configuration.
    public struct Configuration: AnyGiftCardConfiguration {
        
        /// Describes the component's UI style.
        public var style: FormComponentStyle
        
        /// Indicates whether to show the security code field at all.
        public var showsSecurityCodeField: Bool
        
        /// Configuration of Card component.
        /// - Parameters:
        ///   - style: The component's UI style.
        ///   - showsSecurityCodeField: Indicates whether to show the security code field at all. Defaults to `true`
        public init(style: FormComponentStyle = FormComponentStyle(),
                    showsSecurityCodeField: Bool = true) {
            self.style = style
            self.showsSecurityCodeField = showsSecurityCodeField
        }
    }
}
