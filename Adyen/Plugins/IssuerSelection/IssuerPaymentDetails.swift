//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    /// The payment detail for an issuer.
    var issuer: PaymentDetail? {
        get {
            return self[issuerKey]
        }
        
        set {
            self[issuerKey] = newValue
        }
    }
    
}

private let issuerKey = "issuer"
