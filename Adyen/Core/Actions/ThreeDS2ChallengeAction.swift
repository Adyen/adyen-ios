//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure challenge is presented to the user.
public struct ThreeDS2ChallengeAction: Decodable {
    
    /// The 3D Secure challenge token.
    public let token: String
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String
    
    /// Initializes a 3D Secure challenge action.
    ///
    /// - Parameters:
    ///   - token: The 3D Secure challenge token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public init(token: String, paymentData: String) {
        self.token = token
        self.paymentData = paymentData
    }
    
}
