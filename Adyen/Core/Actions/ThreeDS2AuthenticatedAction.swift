//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure is successful.
public struct ThreeDS2AuthenticatedAction: Decodable {

    /// The 3D Secure token.
    public let token: String

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

    /// Initializes a 3D Secure authenticated action.
    ///
    /// - Parameters:
    ///   - token: The 3D Secure token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public init(token: String, paymentData: String) {
        self.token = token
        self.paymentData = paymentData
    }

}
