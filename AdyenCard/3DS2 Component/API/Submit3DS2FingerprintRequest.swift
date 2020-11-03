//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal struct Submit3DS2FingerprintRequest: Request {

    /// :nodoc:
    internal typealias ResponseType = Submit3DS2FingerprintResponse

    /// :nodoc:
    internal var path: String { "checkoutshopper/v1/submitThreeDS2Fingerprint" }

    /// :nodoc:
    internal var counter: UInt = 0

    /// :nodoc:
    internal var headers: [String: String]

    /// :nodoc:
    internal let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    internal let method: HTTPMethod = .post

    /// :nodoc:
    internal let fingerprint: String

    /// :nodoc:
    internal let paymentData: String

    /// :nodoc:
    internal let clientKey: String

    /// :nodoc:
    internal init(clientKey: String, fingerprint: String, paymentData: String) {
        self.headers = ["x-client-key": clientKey]
        self.fingerprint = fingerprint
        self.paymentData = paymentData
        self.clientKey = clientKey
    }

    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case fingerprint = "fingerprintResult", paymentData, clientKey
    }

}
