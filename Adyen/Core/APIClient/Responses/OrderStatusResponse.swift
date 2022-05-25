//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public struct OrderStatusResponse: Response {

    /// The remaining amount to be paid.
    public let remainingAmount: Amount

    /// The payment methods already used to partially pay.
    public let paymentMethods: [OrderPaymentMethod]?
    
    /// Initializes an instance of `OrderStatusResponse`.
    ///
    /// - Parameters:
    ///   - remainingAmount: The remaining amount to be paid.
    ///   - paymentMethods: The payment methods already used to partially pay.
    public init(remainingAmount: Amount,
                paymentMethods: [OrderPaymentMethod]?) {
        self.remainingAmount = remainingAmount
        self.paymentMethods = paymentMethods
    }

    internal enum CodingKeys: String, CodingKey {
        case remainingAmount
        case paymentMethods
    }
}

@_spi(AdyenInternal)
public struct OrderPaymentMethod: PaymentMethod {

    public var name: String {
        String.Adyen.securedString + lastFour
    }
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    public let lastFour: String

    public let type: PaymentMethodType

    public let transactionLimit: Amount?

    public let amount: Amount

    public init(lastFour: String,
                type: PaymentMethodType,
                transactionLimit: Amount?,
                amount: Amount) {
        self.lastFour = lastFour
        self.type = type
        self.transactionLimit = transactionLimit
        self.amount = amount
    }

    @_spi(AdyenInternal)
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let disclosureText = AmountFormatter.formatted(amount: -amount.value,
                                                       currencyCode: amount.currencyCode,
                                                       localeIdentifier: parameters?.locale)
        return DisplayInformation(title: name,
                                  subtitle: nil,
                                  logoName: type.rawValue,
                                  disclosureText: disclosureText)
    }

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        AlreadyPaidPaymentComponent(paymentMethod: self,
                                    context: builder.context)
    }

    private enum CodingKeys: String, CodingKey {
        case lastFour
        case amount
        case transactionLimit
        case type
    }
}
