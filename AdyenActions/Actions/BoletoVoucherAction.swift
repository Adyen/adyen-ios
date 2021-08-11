//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
/// Describes a voucher that can be downloaded.
internal protocol DownloadableVoucher {
    
    /// :nodoc:
    /// Download URL.
    var downloadUrl: URL { get }
}

/// Describes an action in which a Boleto voucher is presented to the shopper.
public final class BoletoVoucherAction: Decodable, AnyVoucherAction, DownloadableVoucher {
    
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
    public let passCreationToken: String?
    
    /// :nodoc:
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paymentMethodType = try container.decode(VoucherPaymentMethod.self, forKey: .paymentMethodType)
        totalAmount = try container.decode(Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
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
                  totalAmount: Amount,
                  reference: String,
                  expiresAt: Date,
                  downloadUrl: URL,
                  passCreationToken: String? = nil) {
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
