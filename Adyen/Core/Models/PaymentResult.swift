//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A completed payment.
public struct PaymentResult: Decodable {
    
    // MARK: - Accessing Payment Result
    
    /// The status of the payment.
    public let status: Status
    
    /// The payload usable to verify the integrity of the payment.
    public let payload: String
    
    /// The type of payment method that was used.
    public let paymentMethodType: String
    
    // MARK: - Decoding
    
    /// Initializes the payment result by decoding a return URL.
    ///
    /// - Parameters:
    ///   - url: The return URL to decode the payment result from.
    ///   - paymentMethodType: The type of payment method that was used.
    internal init?(url: URL, paymentMethodType: String) {
        let queryParameters = url.queryParameters()
        
        guard
            let statusRawValue = queryParameters?["resultCode"],
            let status = Status(rawValue: statusRawValue),
            let payload = queryParameters?["payload"]
        else {
            return nil
        }
        
        self.status = status
        self.payload = payload
        self.paymentMethodType = paymentMethodType
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
        self.payload = try container.decode(String.self, forKey: .payload)
        
        let paymentMethodContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .paymentMethod)
        self.paymentMethodType = try paymentMethodContainer.decode(String.self, forKey: .paymentMethodType)
    }
    
    private enum CodingKeys: String, CodingKey {
        case status = "resultCode"
        case payload
        case paymentMethod
        case paymentMethodType = "type"
    }
    
}

// MARK: - PaymentResult.Status

public extension PaymentResult {
    /// The result of a payment.
    enum Status: String, Decodable {
        /// Indicates the payment has been received by Adyen and will be processed.
        case received
        
        /// Indicates the payment has been authorised successfully.
        case authorised
        
        /// Indicates the payment has failed with an error.
        case error
        
        /// Indicates the payment has been refused.
        case refused
        
        /// Indicates the payment was cancelled by the shopper.
        case cancelled
        
        /// Indicates the payment is still pending completion.
        case pending
        
    }
    
}
