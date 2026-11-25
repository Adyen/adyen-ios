//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure device fingerprint is taken.
package struct ThreeDS2FingerprintAction: Decodable {

    /// The 3D Secure fingerprint token.
    package let fingerprintToken: String

    /// The 3D Secure authorization token.
    package let authorisationToken: String?
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    package let paymentData: String?
    
    /// Initializes a 3D Secure fingerprint action.
    ///
    /// - Parameters:
    ///   - fingerprintToken: The 3D Secure fingerprint token.
    ///   - authorisationToken: The 3D Secure authorization token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    package init(fingerprintToken: String, authorisationToken: String? = nil, paymentData: String?) {
        self.authorisationToken = authorisationToken
        self.fingerprintToken = fingerprintToken
        self.paymentData = paymentData
    }

    private enum CodingKeys: String, CodingKey {
        case fingerprintToken = "token", paymentData, authorisationToken
    }
    
}
