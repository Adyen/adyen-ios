//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which an EContext ATM voucher is presented to the shopper.
public final class EContextATMVoucherAction: Decodable,
    AnyVoucherAction,
    InstructionAwareVoucherAction,
    Sendable {

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

    /// Masked shopper telephone number.
    public let maskedTelephoneNumber: String

    /// The instruction `URL` object.
    public let instructionsURL: URL

    /// Collection institution number.
    public let collectionInstitutionNumber: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        initialAmount = try container.decode(Amount.self, forKey: .initialAmount)
        totalAmount = try container.decode(Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        merchantName = try container.decode(String.self, forKey: .merchantName)
        passCreationToken = try container.decodeIfPresent(String.self, forKey: .passCreationToken)
        maskedTelephoneNumber = try container.decode(String.self, forKey: .maskedTelephoneNumber)
        instructionsURL = try container.decode(URL.self, forKey: .instructionsUrl)
        collectionInstitutionNumber = try container.decode(String.self, forKey: .collectionInstitutionNumber)

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
        maskedTelephoneNumber: String,
        instructionsUrl: URL,
        collectionInstitutionNumber: String,
        passCreationToken: String? = nil
    ) {
        self.paymentMethodType = paymentMethodType
        self.initialAmount = initialAmount
        self.totalAmount = totalAmount
        self.reference = reference
        self.expiresAt = expiresAt
        self.merchantName = merchantName
        self.maskedTelephoneNumber = maskedTelephoneNumber
        self.instructionsURL = instructionsUrl
        self.collectionInstitutionNumber = collectionInstitutionNumber
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
             maskedTelephoneNumber,
             instructionsUrl,
             collectionInstitutionNumber
    }
}
