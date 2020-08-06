//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public enum AwaitPaymentMethod: String, Decodable {
    case mbway
}

/// Describes an action in which the SDK is waiting for user action.
public struct AwaitAction: Decodable {
    
    /// The `paymentMethodType` for which the await action is used.
    public let paymentMethodType: AwaitPaymentMethod
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String
    
    /// Initializes a redirect action.
    ///
    /// - Parameters:
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - paymentMethodType: The `paymentMethodType` for which the await action is used.
    public init(paymentData: String, paymentMethodType: AwaitPaymentMethod) {
        self.paymentData = paymentData
        self.paymentMethodType = paymentMethodType
    }
    
}
