//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// `CheckoutConfigurable` represents any type of configuration the SDK may require for its components,
/// such as `CardComponentConfiguration`,  `DropInConfiguration`, `ActionComponentConfiguration`.
public protocol CheckoutConfigurable {}

/// Configuration interface for all Checkout Components.
package protocol CheckoutComponentConfiguration: CheckoutConfigurable {
    
    var componentType: CheckoutComponentType { get }
    
    var showsSubmitButton: Bool { get set }
    
    // Internal runtime localization state. Merchant-facing checkout flows configure
    // localization through `CheckoutConfiguration.localizationProvider(...)`.

    var localizationParameters: LocalizationParameters? { get set }

    var localizationProvider: (any CheckoutLocalizationProvider)? { get set }

    //  var style: FormComponentStyle { get }

    var theme: CheckoutTheme { get set }
}

package extension CheckoutConfigurable {

    // TODO: add descriptions
    // having this function here instead of re writing it for all configurations
    // prevents duplication, but the returned value will be seen as CheckoutConfigurable
    // after calling this function, as opposed to actual type
    // like BLIKComponentConfiguration before calling this.
    func showsSubmitButton(_ showsSubmitButton: Bool) -> any CheckoutConfigurable {
        guard let self = self as? CheckoutComponentConfiguration else { return self }
        var copy = self
        copy.showsSubmitButton = showsSubmitButton
        return copy
    }
}

package struct CompositeCheckoutConfiguration: CheckoutConfigurable {
    
    package var configurations: [CheckoutConfigurable]
    
    package init(configurations: [CheckoutConfigurable]) {
        self.configurations = configurations
    }
}
