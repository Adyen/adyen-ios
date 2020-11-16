//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure is successful.
/// :nodoc:
public struct ThreeDS2AuthenticatedAction: Decodable {

    /// The 3D Secure token.
    /// :nodoc:
    public let token: String

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    /// :nodoc:
    public let paymentData: String

    /// Initializes a 3D Secure authenticated action.
    ///
    /// - Parameters:
    ///   - token: The 3D Secure token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    /// :nodoc:
    public init(token: String, paymentData: String) {
        self.token = token
        self.paymentData = paymentData
    }

}
