//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the SEPA Direct Debit component.
public struct SEPADirectDebitDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String
    
    /// The account IBAN number.
    public let iban: String
    
    /// The account owner name.
    public let ownerName: String
    
    /// Initializes the SEPA Direct Debit details.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - paymentMethod: The SEPA Direct Debit payment method.
    ///   - iban: The account IBAN number.
    ///   - ownerName: The account owner name.
    public init(paymentMethod: SEPADirectDebitPaymentMethod, iban: String, ownerName: String) {
        self.type = paymentMethod.type
        self.iban = iban
        self.ownerName = ownerName
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case iban
        case ownerName
    }
    
}
