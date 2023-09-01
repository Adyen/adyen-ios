//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

struct TelemetryResponse: Response { /* Empty response */ }

struct TelemetryRequest: APIRequest {

    typealias ResponseType = TelemetryResponse

    let path: String = "checkoutshopper/v2/analytics/log"

    var counter: UInt = 0

    let headers: [String: String] = [:]

    let queryParameters: [URLQueryItem] = []

    let method: HTTPMethod = .post

    private var version: String
    private let channel: String
    private let locale: String
    private let flavor: String
    private let userAgent: String?
    private var deviceBrand: String
    private let systemVersion: String
    private let referrer: String
    private let screenWidth: Int
    private let containerWidth: Int?
    private let paymentMethods: [String]
    private let component: String
    let amount: Amount?
    let checkoutAttemptId: String?

    // MARK: - Initializers

    init(data: TelemetryData, checkoutAttemptId: String?) {
        self.version = data.version
        self.channel = data.channel
        self.locale = data.locale
        self.flavor = data.flavor
        self.userAgent = data.userAgent
        self.deviceBrand = data.deviceBrand
        self.systemVersion = data.systemVersion
        self.referrer = data.referrer
        self.screenWidth = data.screenWidth
        self.containerWidth = data.containerWidth
        self.paymentMethods = data.paymentMethods
        self.component = data.component
        self.amount = data.amount
        self.checkoutAttemptId = checkoutAttemptId
    }

    enum CodingKeys: CodingKey {
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
        case amount
    }
}
