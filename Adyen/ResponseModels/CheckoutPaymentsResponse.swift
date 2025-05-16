//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Data model to contain relevant parts of `/payments` and `/payment/details` call responses.
public struct CheckoutPaymentsResponse: Decodable, Sendable {
    
    // TODO: should it be string or enum?
    public let resultCode: String
    
    public let action: Action?
    
    public let order: PartialPaymentOrder?
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultCode = try container.decode(String.self, forKey: .resultCode)
        self.action = try container.decodeIfPresent(Action.self, forKey: .action)
        self.order = try container.decodeIfPresent(PartialPaymentOrder.self, forKey: .order)
    }
    
    private enum CodingKeys: CodingKey {
        case resultCode
        case action
        case order
    }
}

/// Data model that contains information regarding the status of a payment.
public struct CheckoutResult {
    
    // TODO: string or enum?
    public let resultCode: String
    
    package init(resultCode: String) {
        self.resultCode = resultCode
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
