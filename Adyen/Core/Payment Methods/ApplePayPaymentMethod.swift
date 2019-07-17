//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An Apple pay payment method.
public struct ApplePayPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let name: String
    
}
