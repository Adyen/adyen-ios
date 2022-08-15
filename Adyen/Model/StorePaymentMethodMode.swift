//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public protocol StorePaymentMethodModeAware {
    var storePaymentMethodMode: StorePaymentMethodMode? { get }
}

/// Model depicting the options for storing a payment method.
public enum StorePaymentMethodMode: String, Decodable {
    
    /// Storing the payment method is enabled.
    case enabled
    
    /// Storing the payment method is determined by shopper's action
    case askForConsent
    
    /// Storing the payment method is disabled.
    case disabled
}
