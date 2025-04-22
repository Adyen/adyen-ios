//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public protocol CheckoutConfigurable {
    
}

/// Configuration interface for all Checkout Components.
public protocol CheckoutComponentConfiguration: CheckoutConfigurable {
    
    var componentType: CheckoutComponentType { get }
    
    var showsSubmitButton: Bool { get }
    
    // These are here to work with the current way,
    // to be changed with new styling/localization
    var style: FormComponentStyle { get }
    
    var localizationParameters: LocalizationParameters? { get }
}


internal struct CompositeCheckoutConfiguration: CheckoutConfigurable {
    
    internal var configurations: [CheckoutComponentConfiguration]
}
