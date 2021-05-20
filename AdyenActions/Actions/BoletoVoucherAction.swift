//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Describes an action in which a Boleto voucher is presented to the shopper.
public final class BoletoVoucherAction: Decodable {
    
    /// The `paymentMethodType` for which the voucher is presented.
    public let paymentMethodType: VoucherPaymentMethod

    /// The totalAmount  amount.
    public let totalAmount: Payment.Amount

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
        totalAmount = try container.decode(Payment.Amount.self, forKey: .totalAmount)
        reference = try container.decode(String.self, forKey: .reference)
        downloadUrl = try container.decode(URL.self, forKey: .downloadUrl)
        
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
                  totalAmount: Payment.Amount,
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
