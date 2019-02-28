//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    /// The payment detail for a SEPA Direct Debit owner name.
    var sepaName: PaymentDetail? {
        get {
            return self[sepaNameKey]
        }
        
        set {
            self[sepaNameKey] = newValue
        }
    }
    
    /// The payment detail for SEPA Direct Debit IBAN.
    var sepaIBAN: PaymentDetail? {
        get {
            return self[sepaIBANKey]
        }
        
        set {
            self[sepaIBANKey] = newValue
        }
    }
}

private let sepaNameKey = "sepa.ownerName"
private let sepaIBANKey = "sepa.ibanNumber"
