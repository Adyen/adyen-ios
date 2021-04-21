//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which a 3D Secure device fingerprint is taken.
public struct ThreeDS2FingerprintAction: Decodable {

    /// The 3D Secure fingerprint token.
    public let fingerprintToken: String

    /// The 3D Secure authorization token.
    public let authorisationToken: String?
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String?
    
    /// Initializes a 3D Secure fingerprint action.
    ///
    /// - Parameters:
    ///   - fingerprintToken: The 3D Secure fingerprint token.
    ///   - authorisationToken: The 3D Secure authorization token.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public init(fingerprintToken: String, authorisationToken: String? = nil, paymentData: String?) {
        self.authorisationToken = authorisationToken
        self.fingerprintToken = fingerprintToken
        self.paymentData = paymentData
    }

    private enum CodingKeys: String, CodingKey {
        case fingerprintToken = "token", paymentData, authorisationToken
    }
    
}
