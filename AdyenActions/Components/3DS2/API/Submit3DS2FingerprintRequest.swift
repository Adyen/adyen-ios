//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

struct Submit3DS2FingerprintRequest: APIRequest {

    typealias ResponseType = Submit3DS2FingerprintResponse

    var path: String { "checkoutshopper/v1/submitThreeDS2Fingerprint" }

    var counter: UInt = 0

    var headers: [String: String] = [:]

    let queryParameters: [URLQueryItem] = []

    let method: HTTPMethod = .post

    let fingerprint: String

    let paymentData: String?

    let clientKey: String

    init(clientKey: String, fingerprint: String, paymentData: String?) {
        self.fingerprint = fingerprint
        self.paymentData = paymentData
        self.clientKey = clientKey
    }

    enum CodingKeys: String, CodingKey {
        case fingerprint = "fingerprintResult"
        case paymentData
        case clientKey
    }

}
