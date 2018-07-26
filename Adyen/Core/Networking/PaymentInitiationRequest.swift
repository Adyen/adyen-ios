//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A request to initiate a payment.
internal struct PaymentInitiationRequest: Request {
    /// The type of response expected from the request.
    typealias ResponseType = PaymentInitiationResponse
    
    /// The payment session.
    internal var paymentSession: PaymentSession
    
    /// The payment method for which to initiate a payment.
    internal var paymentMethod: PaymentMethod
    
    /// The URL to which the request should be made.
    internal var url: URL {
        return paymentSession.initiationURL
    }
    
    // MARK: - Encoding
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(paymentSession.paymentData, forKey: .paymentData)
        try container.encode(paymentMethod.paymentMethodData, forKey: .paymentMethodData)
        try container.encode(paymentMethod.details.serialized, forKey: .paymentDetails)
    }
    
    private enum CodingKeys: String, CodingKey {
        case paymentData
        case paymentMethodData
        case paymentDetails
    }
    
}
