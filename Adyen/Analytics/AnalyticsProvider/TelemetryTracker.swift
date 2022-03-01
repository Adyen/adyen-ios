//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// : nodoc:
public enum TelemetryFlavor {
    case components
    case dropin(paymentMethods: [String])

    public var rawValue: String {
        switch self {
        case .components:
            return "components"
        case .dropin:
            return "dropin"
        }
    }
}

/// : nodoc:
public protocol TelemetryTrackerProtocol {
    func sendTelemetryEvent(flavor: TelemetryFlavor, component: String)
}

// MARK: - TelemetryTrackerProtocol

extension AnalyticsProvider: TelemetryTrackerProtocol {

    func sendTelemetryEvent(flavor: TelemetryFlavor, component: String) {
        guard configuration.isTelemetryEnabled else { return }

        let telemetryData = TelemetryData(flavor: flavor,
                                          component: component)

        fetchCheckoutAttemptId { [weak self] checkoutAttemptId in
            let telemetryRequest = TelemetryRequest(data: telemetryData,
                                                    checkoutAttemptId: checkoutAttemptId)
            self?.apiClient.perform(telemetryRequest) { _ in }
        }
    }
}
