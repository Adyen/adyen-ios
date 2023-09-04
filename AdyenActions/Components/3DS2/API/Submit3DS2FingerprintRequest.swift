//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// :nodoc:
struct Submit3DS2FingerprintRequest: APIRequest {

    /// :nodoc:
    typealias ResponseType = Submit3DS2FingerprintResponse

    /// :nodoc:
    var path: String { "checkoutshopper/v1/submitThreeDS2Fingerprint" }

    /// :nodoc:
    var counter: UInt = 0

    /// :nodoc:
    var headers: [String: String] = [:]

    /// :nodoc:
    let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    let method: HTTPMethod = .post

    /// :nodoc:
    let fingerprint: String

    /// :nodoc:
    let paymentData: String?

    /// :nodoc:
    let clientKey: String

    /// :nodoc:
    init(clientKey: String, fingerprint: String, paymentData: String?) {
        self.fingerprint = fingerprint
        self.paymentData = paymentData
        self.clientKey = clientKey
    }

    /// :nodoc:
    enum CodingKeys: String, CodingKey {
        case fingerprint = "fingerprintResult"
        case paymentData
        case clientKey
    }

}
