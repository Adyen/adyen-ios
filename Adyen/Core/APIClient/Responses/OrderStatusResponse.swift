//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

package struct OrderStatusResponse: Response {

    /// The remaining amount to be paid.
    package let remainingAmount: Amount

    /// The payment methods already used to partially pay.
    package let paymentMethods: [OrderPaymentMethod]?

    /// Initializes an instance of `OrderStatusResponse`.
    ///
    /// - Parameters:
    ///   - remainingAmount: The remaining amount to be paid.
    ///   - paymentMethods: The payment methods already used to partially pay.
    package init(
        remainingAmount: Amount,
        paymentMethods: [OrderPaymentMethod]?
    ) {
        self.remainingAmount = remainingAmount
        self.paymentMethods = paymentMethods
    }

    internal enum CodingKeys: String, CodingKey {
        case remainingAmount
        case paymentMethods
    }
}

package struct OrderPaymentMethod: PaymentMethod, PaymentMethodDisplayCustomizable {

    package var name: String {
        String.Adyen.securedString + lastFour
    }
    
    package let lastFour: String

    package let type: PaymentMethodType

    package let transactionLimit: Amount?

    package let amount: Amount

    package init(
        lastFour: String,
        type: PaymentMethodType,
        transactionLimit: Amount?,
        amount: Amount
    ) {
        self.lastFour = lastFour
        self.type = type
        self.transactionLimit = transactionLimit
        self.amount = amount
    }

    package func customizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let disclosureText = AmountFormatter.formatted(
            amount: -amount.value,
            currencyCode: amount.currencyCode,
            localeIdentifier: parameters?.locale
        )
        let lastFourSeparated = lastFour.map { String($0) }.joined(separator: ", ")
        let accessibilityLabel = [
            self.type.name,
            AmountFormatter.formatted(amount: amount.value, currencyCode: amount.currencyCode),
            "\(localizedString(.accessibilityLastFourDigits, parameters)): \(lastFourSeparated)"
        ].compactMap { $0 }.joined(separator: ", ")
        
        return DisplayInformation(
            title: name,
            subtitle: nil,
            logoName: type.rawValue,
            disclosureText: disclosureText,
            accessibilityLabel: accessibilityLabel
        )
    }

    package func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        nil
    }

    private enum CodingKeys: String, CodingKey {
        case lastFour
        case amount
        case transactionLimit
        case type
    }
}
