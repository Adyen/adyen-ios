//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import Foundation

/// `CheckoutConfigurable` represents any type of configuration the SDK may require for its components,
/// such as `CardComponentConfiguration`,  `DropInConfiguration`, `ActionComponentConfiguration`.
public protocol CheckoutConfigurable {}

/// Configuration interface for all Checkout Components.
package protocol CheckoutComponentConfiguration: CheckoutConfigurable {
    
    var componentType: CheckoutComponentType { get }
    
    var showsSubmitButton: Bool { get set }
    
    // These are here to work with the current way,
    // to be changed with new styling/localization

    var style: FormComponentStyle { get }

    var theme: AdyenTheme { get set }

    var localizationParameters: LocalizationParameters? { get }
}

public extension CheckoutConfigurable {
    
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

    // Providing theme using AdyenTheme object
    func theme(_ theme: AdyenTheme) -> any CheckoutConfigurable {
        guard let self = self as? CheckoutComponentConfiguration else { return self }
        var copy = self
        copy.theme = theme
        return copy
    }

    func theme(_ label: AdyenLabelStyle) -> any CheckoutConfigurable {
        guard let self = self as? CheckoutComponentConfiguration else { return self }
        var copy = self
        copy.theme.labelStyle = label
        return copy
    }

    func theme(_ button: AdyenButtonStyles) -> any CheckoutConfigurable {
        guard let self = self as? CheckoutComponentConfiguration else { return self }
        var copy = self
        copy.theme.buttonStyle = button
        return copy
    }

    func theme(_ label: AdyenLabelStyle, button: AdyenButtonStyles) -> any CheckoutConfigurable {
        guard let self = self as? CheckoutComponentConfiguration else { return self }
        var copy = self
        copy.theme.labelStyle = label
        copy.theme.buttonStyle = button
        return copy
    }
}

internal struct CompositeCheckoutConfiguration: CheckoutConfigurable {
    
    internal var configurations: [CheckoutConfigurable]
}
