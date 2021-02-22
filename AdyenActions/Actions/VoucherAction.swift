//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Indicates the Voucher payment methods.
public enum VoucherPaymentMethod: String, Codable, CaseIterable {
    case dokuIndomaret = "doku_indomaret"
    case dokuAlfamart = "doku_alfamart"
}

/// Describes any Voucher action.
public enum VoucherAction: Decodable {

    /// Indicates Doku Indomaret Voucher type.
    case dokuIndomaret(GenericVoucherAction)

    /// Indicates Doku Alfamart Voucher type.
    case dokuAlfamart(GenericVoucherAction)

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)

        switch type {
        case .dokuIndomaret, .dokuAlfamart:
            self = .dokuIndomaret(try GenericVoucherAction(from: decoder))
        }
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case paymentMethodType
    }
}

/// Describes an action in which a voucher is presented to the shopper.
public class GenericVoucherAction: Codable {

    /// The `paymentMethodType` for which the voucher is presented.
    public let paymentMethodType: VoucherPaymentMethod

    /// The initial  amount.
    public let initialAmount: Payment.Amount

    /// The totalAmount  amount.
    public let totalAmount: Payment.Amount

    /// The payment reference.
    public let reference: String

    /// The shopper email.
    public let shopperEmail: String

    /// Expirey Date.
    public let expiresAt: Date

    /// Merchant Name.
    public let merchantName: String

    /// Shopper Name.
    public let shopperName: String

    /// The instruction url.
    public let instructionsUrl: String

    /// The action signature.
    public let signature: String?

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        initialAmount = try container.decode(Payment.Amount.self, forKey: .initialAmount)
        totalAmount = try container.decode(Payment.Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        shopperEmail = try container.decode(String.self, forKey: .shopperEmail)
        merchantName = try container.decode(String.self, forKey: .merchantName)
        shopperName = try container.decode(String.self, forKey: .shopperName)
        instructionsUrl = try container.decode(String.self, forKey: .instructionsUrl)
        signature = try container.decodeIfPresent(String.self, forKey: .signature)

        let expiresAtString = try container.decode(String.self, forKey: .expiresAt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: expiresAtString)

        if let date = date {
            expiresAt = date
        } else {
            let codingPath = [CodingKeys.expiresAt]
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "expiresAt is in the wrong format")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentMethodType.rawValue, forKey: .paymentMethodType)
        try container.encode(initialAmount, forKey: .initialAmount)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(reference, forKey: .reference)
        try container.encode(shopperEmail, forKey: .shopperEmail)
        try container.encode(merchantName, forKey: .merchantName)
        try container.encode(shopperName, forKey: .shopperName)
        try container.encode(instructionsUrl, forKey: .instructionsUrl)
        try container.encode(signature, forKey: .signature)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let expiresAtString = dateFormatter.string(from: expiresAt)

        try container.encode(expiresAtString, forKey: .expiresAt)
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case paymentMethodType,
             initialAmount,
             totalAmount,
             reference,
             shopperEmail,
             merchantName,
             shopperName,
             instructionsUrl,
             expiresAt,
             signature

    }
}
