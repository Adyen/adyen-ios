//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Which is the response?
// TODO: - Document
// Empty Response
public struct TelemetryResponse: Response {}

public struct TelemetryRequest: APIRequest {

    /// :nodoc:
    public typealias ResponseType = TelemetryResponse

    /// :nodoc:
    public let path: String = "v2/analytics/log"

    /// :nodoc:
    public var counter: UInt = 0

    /// :nodoc:
    public let headers: [String: String] = [:]

    /// :nodoc:
    public var queryParameters: [URLQueryItem] = []

    /// :nodoc:
    public let method: HTTPMethod = .post

    public let version: String?
    public let channel: String
    public let locale: String
    public let flavor: String
    public let userAgent: String?
    public let referrer: String
    public let screenWidth: Int
    public let containerWidth: Int?
    public let paymentMethods: [String]
    public let component: String
    public let checkoutAttemptId: String?

    // MARK: - Initializers

    internal init(data: TelemetryData, checkoutAttemptId: String?) {
        self.version = data.version
        self.channel = data.channel
        self.locale = data.locale
        self.flavor = data.flavor.rawValue
        self.userAgent = data.userAgent
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
        case referrer
        case containerWidth
        case paymentMethods
        case component
        case checkoutAttemptId
    }
}
