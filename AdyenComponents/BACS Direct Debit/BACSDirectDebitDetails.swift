//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

// TODO: - Complete documentation

public struct BACSDirectDebitDetails: PaymentMethodDetails {

    public let type: String

    public let holderName: String

    public let bankAccountNumber: String

    public let bankLocationId: String

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
