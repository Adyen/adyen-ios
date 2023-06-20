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
    
    /// Boleto Bancairo Santander
    case boletoBancairoSantander = "boletobancario_santander"
    
    /// OXXO
    case oxxo
    
    /// Multibanco
    case multibanco
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
    
    /// Indicates a Boleto Bancairo Santander Voucher type.
    case boletoBancairoSantander(BoletoVoucherAction)
    
    /// Indicates an OXXO voucher type
    case oxxo(OXXOVoucherAction)
    
    /// Indicates an Multibanco voucher type
    case multibanco(MultibancoVoucherAction)

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)

        switch type {
        case .dokuIndomaret:
            self = try .dokuIndomaret(DokuVoucherAction(from: decoder))
        case .dokuAlfamart:
            self = try .dokuAlfamart(DokuVoucherAction(from: decoder))
        case .econtextStores:
            self = try .econtextStores(EContextStoresVoucherAction(from: decoder))
        case .econtextATM:
            self = try .econtextATM(EContextATMVoucherAction(from: decoder))
        case .boletoBancairoSantander:
            self = try .boletoBancairoSantander(BoletoVoucherAction(from: decoder))
        case .oxxo:
            self = try .oxxo(OXXOVoucherAction(from: decoder))
        case .multibanco:
            self = try .multibanco(MultibancoVoucherAction(from: decoder))
        }
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case paymentMethodType
    }
    
    /// :nodoc:
    public var anyAction: AnyVoucherAction {
        switch self {
        case let .boletoBancairoSantander(action):
            return action
        case let .dokuAlfamart(action):
            return action
        case let .dokuIndomaret(action):
            return action
        case let .econtextATM(action):
            return action
        case let .econtextStores(action):
            return action
        case let .oxxo(action):
            return action
        case let .multibanco(action):
            return action
        }
    }
}

/// :nodoc:
/// Describes a voucher that has an instructions url.
internal protocol InstructionAwareVoucherAction {
    
    /// :nodoc:
    /// The instruction url.
    var instructionsURL: URL { get }
}

/// Describes an action in which a voucher is presented to the shopper.
public class GenericVoucherAction: Decodable, AnyVoucherAction {

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

    /// :nodoc:
    public let passCreationToken: String?

    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        initialAmount = try container.decode(Amount.self, forKey: .initialAmount)
        totalAmount = try container.decode(Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        merchantName = try container.decode(String.self, forKey: .merchantName)
        passCreationToken = try container.decodeIfPresent(String.self, forKey: .passCreationToken)

        let expiresAtString = try container.decode(String.self, forKey: .expiresAt)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withYear, .withMonth, .withDay, .withTime,
            .withDashSeparatorInDate, .withColonSeparatorInTime
        ]

        if let date = dateFormatter.date(from: expiresAtString) {
            expiresAt = date
        } else {
            let codingPath = [CodingKeys.expiresAt]
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "expiresAt is in the wrong format")
            throw DecodingError.dataCorrupted(context)
        }
    }

    /// :nodoc:
    internal init(paymentMethodType: VoucherPaymentMethod,
                  initialAmount: Amount,
                  totalAmount: Amount,
                  reference: String,
                  expiresAt: Date,
                  merchantName: String,
                  passCreationToken: String? = nil) {
        self.paymentMethodType = paymentMethodType
        self.initialAmount = initialAmount
        self.totalAmount = totalAmount
        self.reference = reference
        self.expiresAt = expiresAt
        self.merchantName = merchantName
        self.passCreationToken = passCreationToken
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
             expiresAt,
             passCreationToken

    }
}
