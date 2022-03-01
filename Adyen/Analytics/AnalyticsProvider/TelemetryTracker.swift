//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// : nodoc:
public enum TelemetryFlavor {
    case components(type: String)
    case dropIn(type: String = "dropin", paymentMethods: [String])
    case dropInComponent

    public var value: String {
        switch self {
        case .components:
            return "components"
        case .dropIn:
            return "dropin"
        case .dropInComponent:
            return "dropInComponent"
        }
    }
}

/// : nodoc:
public protocol TelemetryTrackerProtocol {
    func trackTelemetryEvent(flavor: TelemetryFlavor)
}

// MARK: - TelemetryTrackerProtocol

extension AnalyticsProvider: TelemetryTrackerProtocol {

    func trackTelemetryEvent(flavor: TelemetryFlavor) {
        guard configuration.isTelemetryEnabled else { return }
        guard case .dropInComponent = flavor else { return }

        let telemetryData = TelemetryData(flavor: flavor)

        fetchCheckoutAttemptId { [weak self] checkoutAttemptId in
            let telemetryRequest = TelemetryRequest(data: telemetryData,
                                                    checkoutAttemptId: checkoutAttemptId)
            self?.apiClient.perform(telemetryRequest) { _ in }
        }
    }
}
