//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure challenge is presented to the user.
public struct ThreeDS2ChallengeAction: Decodable {

    /// The 3D Secure challenge token.
    public let challengeToken: String

    /// The 3D Secure authorization token.
    public let authorisationToken: String?
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String?
    
    /// Initializes a 3D Secure challenge action.
    ///
    /// - Parameters:
    ///   - token: The 3D Secure challenge token.
    ///   - authorisationToken: The 3D Secure authorization token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public init(challengeToken: String, authorisationToken: String? = nil, paymentData: String?) {
        self.authorisationToken = authorisationToken
        self.challengeToken = challengeToken
        self.paymentData = paymentData
    }

    private enum CodingKeys: String, CodingKey {
        case challengeToken = "token", paymentData, authorisationToken
    }
    
}
