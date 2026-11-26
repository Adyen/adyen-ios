//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a Multibanco voucher is presented to the shopper.
public final class MultibancoVoucherAction: Decodable, AnyVoucherAction, Sendable {

    /// The `paymentMethodType` for which the voucher is presented.
    public let paymentMethodType: VoucherPaymentMethod

    /// The initial  amount.
    public let initialAmount: Amount

    /// The totalAmount  amount.
    public let totalAmount: Amount

    /// The payment reference.
    public let reference: String

    /// Expiry Date.
    public let expiresAt: Date

    /// Merchant Name.
    public let merchantName: String

    @_spi(AdyenInternal)
    public let passCreationToken: String?

    /// Multibanco entity.
    public let entity: String

    /// The reference to uniquely identify a payment.
    /// This reference is used in all communication with you about the payment status.
    public let merchantReference: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        initialAmount = try container.decode(Amount.self, forKey: .initialAmount)
        totalAmount = try container.decode(Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        merchantName = try container.decode(String.self, forKey: .merchantName)
        passCreationToken = try container.decodeIfPresent(String.self, forKey: .passCreationToken)
        entity = try container.decode(String.self, forKey: .entity)
        merchantReference = try container.decode(String.self, forKey: .merchantReference)

        let expiresAtString = try container.decode(String.self, forKey: .expiresAt)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime
        ]

        if let date = dateFormatter.date(from: expiresAtString) {
            expiresAt = date
        } else {
            let codingPath = [CodingKeys.expiresAt]
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "expiresAt is in the wrong format")
            throw DecodingError.dataCorrupted(context)
        }
    }

    internal init(
        paymentMethodType: VoucherPaymentMethod,
        initialAmount: Amount,
        totalAmount: Amount,
        reference: String,
        expiresAt: Date,
        merchantName: String,
        entity: String,
        merchantReference: String,
        passCreationToken: String? = nil
    ) {
        self.paymentMethodType = paymentMethodType
        self.initialAmount = initialAmount
        self.totalAmount = totalAmount
        self.reference = reference
        self.expiresAt = expiresAt
        self.merchantName = merchantName
        self.entity = entity
        self.merchantReference = merchantReference
        self.passCreationToken = passCreationToken
    }

    private enum CodingKeys: String, CodingKey {
        case paymentMethodType,
             initialAmount,
             totalAmount,
             reference,
             merchantName,
             expiresAt,
             passCreationToken,
             entity,
             merchantReference
    }
}
