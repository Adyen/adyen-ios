//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// : nodoc:
public enum TelemetryFlavor: String {
    case components
    // TODO: - dropin(paymentMethods: [String])
    case dropin
}

/// : nodoc:
public protocol TelemetryTrackerProtocol {
    func sendTelemetryEvent(flavor: TelemetryFlavor, paymentMethods: [String], component: String)
}

// MARK: - TelemetryTrackerProtocol

extension AnalyticsProvider: TelemetryTrackerProtocol {

    func sendTelemetryEvent(flavor: TelemetryFlavor, paymentMethods: [String], component: String) {
        guard enabled, telemetry else { return }

        let paymentMethods = flavor == .dropin ? paymentMethods : []
        let telemetryData = TelemetryData(flavor: flavor,
                                          paymentMethods: paymentMethods,
                                          component: component)

        fetchCheckoutAttemptId { [weak self] checkoutAttemptId in
            let telemetryRequest = TelemetryRequest(data: telemetryData,
                                                    checkoutAttemptId: checkoutAttemptId)
            self?.apiClient.perform(telemetryRequest) { _ in }
        }
    }
}
