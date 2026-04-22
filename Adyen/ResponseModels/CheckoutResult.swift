//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A model that holds information regarding the result status of a payment.
public struct CheckoutResult {
    
    public let resultCode: CheckoutResultCode
    
    /// An encoded string that can be used to get the payment outcome on your server.
    /// - Description: Use this value with the new  `/sessions/id` endpoint
    /// as a query string on your server to get a synchronous result for your payment.
    public let sessionResult: String?
    
    package init(resultCode: CheckoutResultCode, sessionResult: String? = nil) {
        self.resultCode = resultCode
        self.sessionResult = sessionResult
    }
}

/// Wrapper type to contain checkout related errors.
// TODO: if not needed, can remove?
public struct CheckoutError: Error {
    
    private let error: Error
    
    public init(error: Error) {
        self.error = error
    }
}
