//
//  OrderStatusResponse.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 5/6/21.
//  Copyright © 2021 Adyen. All rights reserved.
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
    internal enum CodingKeys: String, CodingKey {
        case remainingAmount
        case paymentMethods
    }
}

/// :nodoc:
public struct OrderPaymentMethod: Decodable {

    /// :nodoc:
    public let lastFourDigits: String

    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let transactionLimit: Payment.Amount

    /// :nodoc:
    public let amount: Payment.Amount
}
