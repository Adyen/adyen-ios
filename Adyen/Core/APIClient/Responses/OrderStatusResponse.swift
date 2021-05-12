//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct OrderStatusResponse: Response {

    /// The remaining amount to be paid.
    /// :nodoc:
    public let remainingAmount: Payment.Amount

    /// The payment methods already used to partially pay.
    /// :nodoc:
    public let paymentMethods: [OrderPaymentMethod]?

    /// :nodoc:
    public init(remainingAmount: Payment.Amount,
                paymentMethods: [OrderPaymentMethod]?) {
        self.remainingAmount = remainingAmount
        self.paymentMethods = paymentMethods
    }

    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case remainingAmount
        case paymentMethods
    }
}

/// :nodoc:
public struct OrderPaymentMethod: PaymentMethod {

    /// :nodoc:
    public var name: String {
        "••••\u{00a0}" + lastFour
    }

    /// :nodoc:
    public let lastFour: String

    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let transactionLimit: Payment.Amount

    /// :nodoc:
    public let amount: Payment.Amount

    /// :nodoc:
    public var displayInformation: DisplayInformation {
        localizedDisplayInformation(using: nil)
    }

    /// :nodoc:
    public init(lastFour: String,
                type: String,
                transactionLimit: Payment.Amount,
                amount: Payment.Amount) {
        self.lastFour = lastFour
        self.type = type
        self.transactionLimit = transactionLimit
        self.amount = amount
    }

    /// :nodoc:
    public func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let disclosureText = AmountFormatter.formatted(amount: -amount.value,
                                                       currencyCode: amount.currencyCode)
        return DisplayInformation(title: name,
                                  subtitle: nil,
                                  logoName: type,
                                  disclosureText: disclosureText)
    }

    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        EmptyPaymentComponent(paymentMethod: self)
    }

    private enum CodingKeys: String, CodingKey {
        case lastFour
        case amount
        case transactionLimit
        case type
    }
}
