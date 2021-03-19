//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Indicates the Voucher payment methods.
public enum VoucherPaymentMethod: String, Codable, CaseIterable {

    /// Doku Indomaret.
    case dokuIndomaret = "doku_indomaret"

    /// Doku Alfamart.
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
        case .dokuIndomaret:
            self = .dokuIndomaret(try GenericVoucherAction(from: decoder))
        case .dokuAlfamart:
            self = .dokuAlfamart(try GenericVoucherAction(from: decoder))
        }
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case paymentMethodType
    }
}

/// Describes an action in which a voucher is presented to the shopper.
public class GenericVoucherAction: Decodable {

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
             expiresAt

    }
}
