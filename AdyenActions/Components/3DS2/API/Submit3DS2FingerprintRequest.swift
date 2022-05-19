//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct Submit3DS2FingerprintRequest: APIRequest {

    internal typealias ResponseType = Submit3DS2FingerprintResponse

    internal var path: String { "checkoutshopper/v1/submitThreeDS2Fingerprint" }

    internal var counter: UInt = 0

    internal var headers: [String: String] = [:]

    internal let queryParameters: [URLQueryItem] = []

    internal let method: HTTPMethod = .post

    internal let fingerprint: String

    internal let paymentData: String?

    internal let clientKey: String

    internal init(clientKey: String, fingerprint: String, paymentData: String?) {
        self.fingerprint = fingerprint
        self.paymentData = paymentData
        self.clientKey = clientKey
    }

    internal enum CodingKeys: String, CodingKey {
        case fingerprint = "fingerprintResult"
        case paymentData
        case clientKey
    }

}
