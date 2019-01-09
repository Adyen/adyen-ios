//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A request to delete a stored payment method.
internal struct StoredPaymentMethodDeletionRequest: Request {
    /// The type of response expected from the request.
    typealias ResponseType = StoredPaymentMethodDeletionResponse
    
    /// The payment session.
    internal var paymentSession: PaymentSession
    
    /// The payment method to delete.
    internal var paymentMethod: PaymentMethod
    
    /// The URL to which the request should be made.
    internal var url: URL {
        return paymentSession.deleteStoredPaymentMethodURL
    }
    
    // MARK: - Encoding
    
    internal func encode(to encoder: Encoder) throws {
        try encodePaymentData(to: encoder)
    }
    
}
