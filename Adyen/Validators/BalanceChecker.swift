//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct BalanceChecker {

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
    /// The balance check result.
    public struct Result {

        /// :nodoc:
        /// Indicates whether the balance is enough to pay a certain amount.
        public let isBalanceEnough: Bool

        /// :nodoc:
        /// The remaining amount in the balance after payment.
        /// It is at minimum zero when the whole available balance covers part or all the amount to be paid.
        public let remainingBalanceAmount: Amount

        /// :nodoc:
        /// The amount that can be paid.
        public let amountToPay: Amount
    }

    /// :nodoc:
    public init() { /* Empty initializer */ }

    /// Check if a Balance is enough to pay an amount.
    ///
    /// - Parameters:
    ///   - balance: The balance to validate.
    ///   - amount: The amount to pay.
    /// - Throws: `Error.zeroBalance` in case the balance has zero available amount
    /// - Throws: `Error.unexpectedCurrencyCode` in case there is inconsistencies regarding currency codes.
    /// - Returns: an instance of `BalanceValidator.Result`.
    /// :nodoc:
    public func check(balance: Balance, isEnoughToPay amount: Amount) throws -> Result {
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

        let amountToPay = min(expendableLimit, amount)

        return Result(isBalanceEnough: expendableLimit >= amount,
                      remainingBalanceAmount: balance.availableAmount - amountToPay,
                      amountToPay: amountToPay)
    }

    private func validateTransactionLimit(of balance: Balance) -> Bool {
        guard let transactionLimit = balance.transactionLimit else {
            return true
        }
        return transactionLimit.currencyCode == balance.availableAmount.currencyCode
    }

    private func calculateExpendableLimit(with balance: Balance) -> Amount {
        let result: Amount
        let availableAmount = balance.availableAmount
        if let balanceTransactionLimit = balance.transactionLimit {
            result = min(balanceTransactionLimit, availableAmount)
        } else {
            result = availableAmount
        }
        return result
    }
}
