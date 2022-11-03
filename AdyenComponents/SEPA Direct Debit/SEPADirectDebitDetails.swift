//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Contains the details supplied by the SEPA Direct Debit component.
public struct SEPADirectDebitDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The account IBAN number.
    public let iban: String
    
    /// The account owner name.
    public let ownerName: String
    
    /// Initializes the SEPA Direct Debit details.
    ///
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
