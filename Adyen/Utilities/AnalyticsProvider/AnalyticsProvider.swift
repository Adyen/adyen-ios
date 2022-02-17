//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal protocol TelemetryTrackerProtocol {}

internal class TelemetryTracker: TelemetryTrackerProtocol {

    internal enum Flavor: String {
        case components
        case dropin
    }

    // MARK: - Propertiess

    private let checkoutAttemptId: String?
    private let apiClient: APIClientProtocol

    private var version: String? {
        Bundle(for: Self.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }

    private let channel: String = "iOS"
    private var localeIdentifier: String {
        let languageCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }

    private var referrer: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    private var screenWidth: Int {
        Int(UIScreen.main.bounds.width)
    }

    // MARK: - Initializers

    internal init(checkoutAttemptId: String?,
                  apiClient: APIClientProtocol) {
        self.checkoutAttemptId = checkoutAttemptId
        self.apiClient = apiClient
    }

    // MARK: - TelemetryTrackerProtocol

    // TODO: - Perform tracking
    // Properties to send
    // 1. version (✅)
    // 2. channel (✅)
    // 3. locale (✅)
    // 4. flavor (✅)
    // 5. userAgent (null)
    // 6. referrer (✅)
    // 7. screenWidth (✅)
    // 8. containerWidth (null)
    // 9. component
    // 10. checkoutAttemptId
    internal func sendEvent(flavor: Flavor, paymentMethods: [String], component: String) {
        // 1. Build request object
        let request = TelemetryRequest(version: version,
                                       channel: channel,
                                       locale: localeIdentifier,
                                       flavor: flavor.rawValue,
                                       userAgent: nil,
                                       referrer: referrer,
                                       screenWidth: screenWidth,
                                       containerWidth: nil,
                                       paymentMethods: paymentMethods,
                                       component: component,
                                       checkoutAttemptId: checkoutAttemptId)

        // 2. Send telemetry request
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                // TODO: This is an empty response. Nothing to do
                break
            case let .failure(error):
                // TODO: Handle error
                break
            }
        }

    }
}

internal protocol AnalyticsProviderProtocol {}

internal class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    private var enabled: Bool
    private var conversion: Bool
    private var telemetry: Bool

    private let apiClient: APIClientProtocol
    private let apiContext: APIContext

    // MARK: - Initializers

    internal init(apiClient: APIClientProtocol,
                  apiContext: APIContext,
                  enabled: Bool,
                  conversion: Bool,
                  telemetry: Bool) {
        self.apiClient = apiClient
        self.apiContext = apiContext
        self.enabled = enabled
        self.conversion = conversion
        self.telemetry = telemetry
    }

    // MARK: - AnalyticsProviderProtocol
}
