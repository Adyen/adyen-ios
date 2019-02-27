//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A request to initiate a payment.
internal struct PaymentInitiationRequest: Request {
    
    /// The payment session.
    internal var paymentSession: PaymentSession
    
    /// The payment method for which to initiate a payment.
    internal var paymentMethod: PaymentMethod
    
    /// The payment details.
    internal var paymentDetails: [PaymentDetail] = []
    
    /// The payment data containing the state of the payment.
    internal var paymentData: String
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod, paymentDetails: [PaymentDetail]? = nil, paymentData: String? = nil) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
        self.paymentDetails = paymentDetails ?? paymentMethod.details
        self.paymentData = paymentData ?? paymentSession.paymentData
    }
    
    // MARK: - Request
    
    /// The type of response expected from the request.
    typealias ResponseType = PaymentInitiationResponse
    
    /// The URL to which the request should be made.
    internal var url: URL {
        return paymentSession.initiationURL
    }
    
    // MARK: - Encoding
    
    func encode(to encoder: Encoder) throws {
        try encodePaymentData(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentDetails.serialized, forKey: .paymentDetails)
    }
    
    private enum CodingKeys: String, CodingKey {
        case paymentDetails
    }
    
}
