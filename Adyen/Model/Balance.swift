//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an account balance.
public struct Balance {

    /// Indicates the available balance.
    public let availableAmount: Amount

    /// Indicates the maximum spendable balance for a single transaction,
    /// as mandated by the account issuer, regardless of the account balance.
    public let transactionLimit: Amount?

    /// Initializes a Balance.
    ///
    /// - Parameters:
    ///   - availableAmount: The available balance.
    ///   - transactionLimit: The maximum spendable balance for a single transaction as mandated by the account issuer,
    ///    regardless of the account balance.
    public init(availableAmount: Amount, transactionLimit: Amount?) {
        self.availableAmount = availableAmount
        self.transactionLimit = transactionLimit
    }
}
