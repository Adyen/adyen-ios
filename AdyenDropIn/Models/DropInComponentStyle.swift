//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import UIKit

package extension DropInComponent {

    /// Indicates the UI configuration of the drop in components.
    struct Style {
        
        /// Indicates any navigation style.
        package var navigation = NavigationStyle()

        /// Indicates the UI configuration of any list component.
        package var listComponent = ListComponentStyle()

        /// Indicates any form component UI style.
        package var formComponent = FormComponentStyle()

        /// Indicates the UI configuration of Action Components
        package var actionComponent = ActionComponentStyle()

        /// Indicates the UI configuration for the Apple Pay component.
        package var applePay = ApplePayStyle()

        /// The color for separator element.
        /// When set, updates separator colors for all underlying styles unless the value were set previously.
        /// If value is nil, the default color would be used.
        package var separatorColor: UIColor? {
            didSet {
                formComponent.separatorColor = formComponent.separatorColor ?? separatorColor
                navigation.separatorColor = navigation.separatorColor ?? separatorColor
            }
        }
        
        /// Initializes the instance of DropIn style with the default values.
        package init() {}

        /// Initializes the instance of DropIn style with the default values.
        package init(tintColor: UIColor) {
            formComponent = FormComponentStyle(tintColor: tintColor)
            navigation.tintColor = tintColor
        }
    }
}
