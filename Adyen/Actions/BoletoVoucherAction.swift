//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a voucher that can be downloaded.
package protocol Downloadable {
    
    /// Download URL.
    var downloadUrl: URL { get }
}

/// Describes an action in which a Boleto voucher is presented to the shopper.
package final class BoletoVoucherAction: Decodable, AnyVoucherAction, Downloadable {
    
    /// The `paymentMethodType` for which the voucher is presented.
    package let paymentMethodType: PaymentMethodType

    /// The totalAmount  amount.
    package let totalAmount: Amount

    /// The payment reference.
    package let reference: String

    /// Expiry Date.
    package let expiresAt: Date
    
    /// Download URL
    package let downloadUrl: URL

    package let passCreationToken: String?
    
    package required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paymentMethodType = try container.decode(PaymentMethodType.self, forKey: .paymentMethodType)
        totalAmount = try container.decode(Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
        passCreationToken = try container.decodeIfPresent(String.self, forKey: .passCreationToken)
        
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
        paymentMethodType: PaymentMethodType,
        totalAmount: Amount,
        reference: String,
        expiresAt: Date,
        downloadUrl: URL,
        passCreationToken: String? = nil
    ) {
        self.paymentMethodType = paymentMethodType
        self.totalAmount = totalAmount
        self.reference = reference
        self.expiresAt = expiresAt
        self.downloadUrl = downloadUrl
        self.passCreationToken = passCreationToken
    }
    
    private enum CodingKeys: String, CodingKey {
        case paymentMethodType,
             totalAmount,
             reference,
             expiresAt,
             downloadUrl,
             passCreationToken
    }
    
}
