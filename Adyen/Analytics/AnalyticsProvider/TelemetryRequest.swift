//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
internal struct TelemetryResponse: Response { /* Empty response */ }

internal struct TelemetryRequest: APIRequest {

    /// :nodoc:
    internal typealias ResponseType = TelemetryResponse

    /// :nodoc:
    internal let path: String = "v2/analytics/log"

    /// :nodoc:
    internal var counter: UInt = 0

    /// :nodoc:
    internal let headers: [String: String] = [:]

    /// :nodoc:
    internal let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    internal let method: HTTPMethod = .post

    internal let version: String?
    internal let channel: String
    internal let locale: String
    internal let flavor: String
    internal let userAgent: String?
    internal let deviceBrand: String
    internal let systemVersion: String
    internal let referrer: String
    internal let screenWidth: Int
    internal let containerWidth: Int?
    internal let paymentMethods: [String]
    internal let component: String
    internal let checkoutAttemptId: String?

    // MARK: - Initializers

    internal init(data: TelemetryData, checkoutAttemptId: String?) {
        self.version = data.version
        self.channel = data.channel
        self.locale = data.locale
        self.flavor = data.flavor.rawValue
        self.userAgent = data.userAgent
        self.deviceBrand = data.deviceBrand
        self.systemVersion = data.systemVersion
        self.referrer = data.referrer
        self.screenWidth = data.screenWidth
        self.containerWidth = data.containerWidth
        self.paymentMethods = data.paymentMethods
        self.component = data.component
        self.checkoutAttemptId = checkoutAttemptId
    }

    internal enum CodingKeys: CodingKey {
        case version
        case channel
        case locale
        case flavor
        case userAgent
        case deviceBrand
        case systemVersion
        case referrer
        case screenWidth
        case containerWidth
        case paymentMethods
        case component
        case checkoutAttemptId
    }
}
