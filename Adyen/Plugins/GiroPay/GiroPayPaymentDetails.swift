//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    
    /// The payment detail for a Giro Pay BIC.
    var giroPayBic: PaymentDetail? {
        get {
            return self[bicKey]
        }
        
        set {
            self[bicKey] = newValue
        }
    }
    
}

private let bicKey = "bic"
