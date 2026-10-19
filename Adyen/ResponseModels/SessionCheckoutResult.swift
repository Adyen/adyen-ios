//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The result of a completed session-based checkout flow.
public struct SessionCheckoutResult {

    /// The result code indicating the outcome of the payment.
    public let resultCode: CheckoutResultCode

    /// The session identifier.
    public let sessionId: String

    /// An encoded string that can be used to get the payment outcome on your server.
    /// Pass this value as the `sessionResult` query parameter to the `/sessions/{sessionId}` endpoint,
    /// where `sessionId` is the ``SessionCheckoutResult/sessionId`` property on this result type.
    public let sessionResult: String

    package init(resultCode: CheckoutResultCode, sessionId: String, sessionResult: String) {
        self.resultCode = resultCode
        self.sessionId = sessionId
        self.sessionResult = sessionResult
    }
}
