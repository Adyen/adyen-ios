//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure challenge is presented to the user.
package struct ThreeDS2ChallengeAction: Decodable {

    /// The 3D Secure challenge token.
    package let challengeToken: String

    /// The 3D Secure authorization token.
    package let authorisationToken: String?
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    package let paymentData: String?
    
    /// Initializes a 3D Secure challenge action.
    ///
    /// - Parameters:
    ///   - token: The 3D Secure challenge token.
    ///   - authorisationToken: The 3D Secure authorization token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    package init(challengeToken: String, authorisationToken: String? = nil, paymentData: String?) {
        self.authorisationToken = authorisationToken
        self.challengeToken = challengeToken
        self.paymentData = paymentData
    }

    private enum CodingKeys: String, CodingKey {
        case challengeToken = "token", paymentData, authorisationToken
    }
    
}
