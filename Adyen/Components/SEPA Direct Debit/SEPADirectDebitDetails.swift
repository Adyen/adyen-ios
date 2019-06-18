//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the details supplied by the SEPA Direct Debit component.
public struct SEPADirectDebitDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String?
    
    /// The account IBAN number.
    public let iban: String?
    
    /// The account owner name.
    public let ownerName: String?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case iban = "sepa.ibanNumber"
        case ownerName = "sepa.ownerName"
    }
    
}
