//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Contains the details supplied by the BACS Direct Debit component.
public struct BACSDirectDebitDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String

    /// The BACS account's holder name.
    public let holderName: String

    /// The BACS account's number.
    public let bankAccountNumber: String

    /// The BACS location's ID.
    public let bankLocationId: String

    /// Creates and returns a BACS Direct Debit details instance.
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - holderName: The BACS account's holder name.
    ///   - bankAccountNumber: The BACS account's number.
    ///   - bankLocationId: The BACS location's ID.
    public init(paymentMethod: BACSDirectDebitPaymentMethod,
                holderName: String,
                bankAccountNumber: String,
                bankLocationId: String) {
        self.type = paymentMethod.type
        self.holderName = holderName
        self.bankAccountNumber = bankAccountNumber
        self.bankLocationId = bankLocationId
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case holderName
        case bankAccountNumber
        case bankLocationId
    }
}
