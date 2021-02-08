//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation
import UIKit

public extension DropInComponent {
    
    /// Indicates the UI configuration of the drop in components.
    struct Style {
        
        /// Indicates any navigation style.
        public var navigation = NavigationStyle()
        
        /// Indicates the UI configuration of any list component.
        public var listComponent = ListComponentStyle()
        
        /// Indicates any form component UI style.
        public var formComponent = FormComponentStyle()
        
        /// Indicates any `RedirectComponent` UI style.
        public var redirectComponent: RedirectComponentStyle?
        
        /// Indicates the await action component UI style.
        public var awaitComponent = AwaitComponentStyle()

        /// Indicates the voucher action component UI style.
        public var voucherComponent = VoucherComponentStyle()
        
        /// The color for separator element.
        /// When set, updates separator colors for all undelying styles unless the value were set previously.
        /// If value is nil, the default color would be used.
        public var separatorColor: UIColor? {
            didSet {
                formComponent.separatorColor = formComponent.separatorColor ?? separatorColor
                navigation.separatorColor = navigation.separatorColor ?? separatorColor
            }
        }
        
        /// Initializes the instance of DropIn style with the default values.
        public init() {}
        
        /// Initializes the instance of DropIn style with the default values.
        public init(tintColor: UIColor) {
            formComponent = FormComponentStyle(tintColor: tintColor)
            navigation.tintColor = tintColor
        }
    }
}
