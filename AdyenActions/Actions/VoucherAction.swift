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

    /// E-Context Stores
    case econtextStores = "econtext_stores"

    /// E-Context ATM
    case econtextATM = "econtext_atm"
}

/// Describes any Voucher action.
public enum VoucherAction: Decodable {

    /// Indicates Doku Indomaret Voucher type.
    case dokuIndomaret(DokuVoucherAction)

    /// Indicates Doku Alfamart Voucher type.
    case dokuAlfamart(DokuVoucherAction)

    /// Indicates an EContext Stores Voucher type.
    case econtextStores(EContextStoresVoucherAction)

    /// Indicates an EContext ATM Voucher type.
    case econtextATM(EContextATMVoucherAction)

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)

        switch type {
        case .dokuIndomaret:
            self = .dokuIndomaret(try DokuVoucherAction(from: decoder))
        case .dokuAlfamart:
            self = .dokuAlfamart(try DokuVoucherAction(from: decoder))
        case .econtextStores:
            self = .econtextStores(try EContextStoresVoucherAction(from: decoder))
        case .econtextATM:
            self = .econtextATM(try EContextATMVoucherAction(from: decoder))
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

    /// Expirey Date.
    public let expiresAt: Date

    /// Merchant Name.
    public let merchantName: String

    /// The instruction url.
    public let instructionsUrl: String

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        initialAmount = try container.decode(Payment.Amount.self, forKey: .initialAmount)
        totalAmount = try container.decode(Payment.Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        merchantName = try container.decode(String.self, forKey: .merchantName)
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
    internal init(paymentMethodType: VoucherPaymentMethod,
                  initialAmount: Payment.Amount,
                  totalAmount: Payment.Amount,
                  reference: String,
                  expiresAt: Date,
                  merchantName: String,
                  instructionsUrl: String) {
        self.paymentMethodType = paymentMethodType
        self.initialAmount = initialAmount
        self.totalAmount = totalAmount
        self.reference = reference
        self.expiresAt = expiresAt
        self.merchantName = merchantName
        self.instructionsUrl = instructionsUrl
    }

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
