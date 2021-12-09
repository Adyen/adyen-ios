//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a partial payment order, for partial payments.
public struct PartialPaymentOrder: Codable, Equatable {

    /// A compact version of `PartialPaymentOrder`.
    public struct CompactOrder: Encodable, Equatable {

        /// The psp reference.
        public let pspReference: String

        /// The order data.
        public let orderData: String?
    }

    /// A compact version of `PartialPaymentOrder`.
    public let compactOrder: CompactOrder

    /// The psp reference.
    public let pspReference: String

    /// The order data.
    public let orderData: String?

    /// A unique reference to the payment.
    public let reference: String?

    /// The initial amount of the order.
    public let amount: Amount?

    /// The remaining amount to be paid.
    public let remainingAmount: Amount?

    /// The expiry date.
    public let expiresAt: Date?

    /// Initializes a payment order.
    ///
    /// - Parameter pspReference: The psp reference.
    /// - Parameter orderData: The order data.
    /// - Parameter reference: A unique reference to the payment.
    /// - Parameter amount: The initial amount of the order.
    /// - Parameter remainingAmount: The remaining amount to be paid.
    /// - Parameter expiresAt: The expiry date.
    public init(pspReference: String,
                orderData: String?,
                reference: String? = nil,
                amount: Amount? = nil,
                remainingAmount: Amount? = nil,
                expiresAt: Date? = nil) {
        self.pspReference = pspReference
        self.orderData = orderData
        self.reference = reference
        self.amount = amount
        self.remainingAmount = remainingAmount
        self.expiresAt = expiresAt
        self.compactOrder = CompactOrder(pspReference: pspReference,
                                         orderData: orderData)
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pspReference = try container.decode(String.self, forKey: .pspReference)
        self.orderData = try container.decodeIfPresent(String.self, forKey: .orderData)
        self.reference = try container.decodeIfPresent(String.self, forKey: .reference)
        self.amount = try container.decodeIfPresent(Amount.self, forKey: .amount)
        self.remainingAmount = try container.decodeIfPresent(Amount.self, forKey: .remainingAmount)
        self.expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.compactOrder = CompactOrder(pspReference: pspReference,
                                         orderData: orderData)
    }

    private enum CodingKeys: String, CodingKey {
        case pspReference
        case orderData
        case reference
        case amount
        case remainingAmount
        case expiresAt
    }
}
