//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A request for a GiroPay Issuers lookup.
internal struct GiroPayIssuersRequest: Request {
    typealias ResponseType = GiroPayIssuersResponse
    
    /// The search string.
    internal var searchString: String
    
    /// The payment session.
    var paymentSession: PaymentSession
    
    /// The payment method for which to initiate a payment.
    var paymentMethod: PaymentMethod
    
    /// The URL to which the request should be made.
    internal var url: URL {
        if let urlString = paymentMethod.configuration?[urlConfigurationKey] as? String {
            return URL(string: urlString)!
        } else {
            return URL(string: "")!
        }
    }
    
    // MARK: - Private
    
    private let urlConfigurationKey = "giroPayIssuersUrl"
    
    // MARK: - Encoding
    
    func encode(to encoder: Encoder) throws {
        try encodePaymentData(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(searchString, forKey: .searchString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case searchString
    }
    
}
