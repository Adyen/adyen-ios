//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct BalanceValidator {

    /// Indicates balance related errors.
    public enum Error: LocalizedError {

        /// Indicates there is a currency code mismatch.
        case unexpectedCurrencyCode

        /// Indicates there is zero amount in the balance.
        case zeroBalance

        public var errorDescription: String? {
            switch self {
            case .unexpectedCurrencyCode:
                return "All amounts used should have the same currency code."
            case .zeroBalance:
                return "There is zero amount in the balance."
            }
        }
    }

    /// :nodoc:
    public init() { /* Empty initializer */ }

    /// Check if a Balance is enough to pay an amount.
    ///
    /// - Parameters:
    ///   - balance: The balance to validate.
    ///   - amount: The amount to pay.
    /// :nodoc:
    public func check(balance: Balance, isEnoughToPay amount: Payment.Amount) throws -> Bool {
        guard balance.availableAmount.value > 0 else {
            throw Error.zeroBalance
        }
        guard validateTransactionLimit(of: balance) else {
            throw Error.unexpectedCurrencyCode
        }
        let expendableLimit = calculateExpendableLimit(with: balance)
        let availableAmount = balance.availableAmount

        guard expendableLimit.currencyCode == availableAmount.currencyCode else {
            throw Error.unexpectedCurrencyCode
        }
        guard availableAmount.currencyCode == amount.currencyCode else {
            throw Error.unexpectedCurrencyCode
        }

        return expendableLimit.value >= amount.value
    }

    private func validateTransactionLimit(of balance: Balance) -> Bool {
        guard let transactionLimit = balance.transactionLimit else {
            return true
        }
        return transactionLimit.currencyCode == balance.availableAmount.currencyCode
    }

    private func calculateExpendableLimit(with balance: Balance) -> Payment.Amount {
        let result: Payment.Amount
        let availableAmount = balance.availableAmount
        if let balanceTransactionLimit = balance.transactionLimit {
            result = min(balanceTransactionLimit, availableAmount)
        } else {
            result = availableAmount
        }
        return result
    }
}
