//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A request for a SSN lookup.
internal struct KlarnaSSNLookupRequest: Request {
    typealias ResponseType = KlarnaSSNLookupResponse
    
    internal var shopperSSN: String
    
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
    
    private let urlConfigurationKey = "shopperInfoSSNLookupUrl"
    
    // MARK: - Encoding
    
    func encode(to encoder: Encoder) throws {
        try encodePaymentData(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shopperSSN, forKey: .socialSecurityNumber)
    }
    
    private enum CodingKeys: String, CodingKey {
        case socialSecurityNumber
    }
    
}
