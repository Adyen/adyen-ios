//
// Copyright (c) 2018 Adyen B.V.
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
    
    // MARK: - Decoding
    
    /// Initializes the payment result by decoding a return URL.
    ///
    /// - Parameter url: The return URL to decode the payment result from.
    internal init?(url: URL) {
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
    }
    
    private enum CodingKeys: String, CodingKey {
        case status = "resultCode"
        case payload
    }
    
}

// MARK: - PaymentResult.Status

public extension PaymentResult {
    /// The result of a payment.
    public enum Status: String, Decodable {
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
