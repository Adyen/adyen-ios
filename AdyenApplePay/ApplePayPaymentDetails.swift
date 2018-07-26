//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    /// The payment detail for Apple Pay Token
    public var applePayToken: PaymentDetail? {
        get {
            return self[applePayTokenKey]
        }
        
        set {
            self[applePayTokenKey] = newValue
        }
    }
}

private let applePayTokenKey = "additionalData.applepay.token"
