//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Describes an action in which a Boleto voucher is presented to the shopper.
public final class BoletoVoucherAction: Codable, OpaqueEncodable {
    
    /// The `paymentMethodType` for which the voucher is presented.
    public let paymentMethodType: VoucherPaymentMethod

    /// The totalAmount  amount.
    public let totalAmount: Amount

    /// The payment reference.
    public let reference: String

    /// Expiry Date.
    public let expiresAt: Date
    
    /// Download URL
    public let downloadUrl: URL
    
    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        totalAmount = try container.decode(Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
        
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
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentMethodType, forKey: .paymentMethodType)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(reference, forKey: .reference)
        try container.encode(downloadUrl, forKey: .downloadUrl)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withYear, .withMonth, .withDay, .withTime,
            .withDashSeparatorInDate, .withColonSeparatorInTime
        ]

        try container.encode(dateFormatter.string(from: self.expiresAt), forKey: .expiresAt)
    }
    
    /// :nodoc:
    internal init(paymentMethodType: VoucherPaymentMethod,
                  totalAmount: Amount,
                  reference: String,
                  expiresAt: Date,
                  downloadUrl: URL) {
        self.paymentMethodType = paymentMethodType
        self.totalAmount = totalAmount
        self.reference = reference
        self.expiresAt = expiresAt
        self.downloadUrl = downloadUrl
    }
    
    private enum CodingKeys: String, CodingKey {
        case paymentMethodType,
             totalAmount,
             reference,
             expiresAt,
             downloadUrl
    }
    
}
