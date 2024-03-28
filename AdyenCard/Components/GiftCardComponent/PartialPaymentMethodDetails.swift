//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Describes the details a partial payment method (e.g. a gift card) needs to provide.
public protocol PartialPaymentMethodDetails: PaymentMethodDetails {
    
    /// The payment method type.
    var type: PaymentMethodType { get }
    
    /// The encrypted card number.
    var encryptedCardNumber: String { get }
    
    /// The encrypted security code.
    var encryptedSecurityCode: String { get }
}
