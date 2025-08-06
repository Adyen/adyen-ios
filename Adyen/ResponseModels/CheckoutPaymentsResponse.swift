//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// TODO: this could also just be a protocol and they can conform to it (CheckoutCallbackResult below may replace it)
/// Data model to contain relevant parts of `/payments` and `/payment/details` call responses.
public struct CheckoutPaymentsResponse: Decodable, Sendable {
    
    public let resultCode: CheckoutResultCode
    
    public let action: Action?
    
    public let order: PartialPaymentOrder?
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultCode = try container.decode(CheckoutResultCode.self, forKey: .resultCode)
        self.action = try container.decodeIfPresent(Action.self, forKey: .action)
        self.order = try container.decodeIfPresent(PartialPaymentOrder.self, forKey: .order)
    }
    
    public init(
        resultCode: CheckoutResultCode,
        action: Action? = nil,
        order: PartialPaymentOrder? = nil
    ) {
        self.resultCode = resultCode
        self.action = action
        self.order = order
    }
    
    private enum CodingKeys: CodingKey {
        case resultCode
        case action
        case order
    }
}

/// Represents the interface to contain the relevant parts of `/payments` and `/payment/details` call responses.
public protocol CheckoutCallbackResult: Decodable, Sendable {
    
    /// Result code of the response.
    var resultCode: CheckoutResultCode { get }
    
    /// Action object, if there is any.
    var action: Action? { get }
    
    /// Order object related to the partial payment, if there is any.
    var order: PartialPaymentOrder? { get }
}

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
