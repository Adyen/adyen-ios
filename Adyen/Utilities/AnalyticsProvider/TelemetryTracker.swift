//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum TelemetryFlavor: String {
    case components
    case dropin
}

internal protocol TelemetryTrackerProtocol {
    func sendTelemetryEvent(flavor: TelemetryFlavor, paymentMethods: [String], component: String)
}

// MARK: - TelemetryTrackerProtocol

extension AnalyticsProvider: TelemetryTrackerProtocol {

    func sendTelemetryEvent(flavor: TelemetryFlavor, paymentMethods: [String], component: String) {
        guard enabled else { return }
        guard telemetry else { return }

        let paymentMethods = flavor == .dropin ? paymentMethods : []
        let telemetryData = TelemetryData(flavor: flavor,
                                          paymentMethods: paymentMethods,
                                          component: component)
        let queryParameters = apiContext.queryParameters

        fetchCheckoutAttemptId { [weak self] checkoutAttemptId in
            var telemetryRequest = TelemetryRequest(data: telemetryData,
                                                    checkoutAttemptId: checkoutAttemptId)
            telemetryRequest.queryParameters = queryParameters

            self?.apiClient.perform(telemetryRequest) { _ in }
        }
    }
}
