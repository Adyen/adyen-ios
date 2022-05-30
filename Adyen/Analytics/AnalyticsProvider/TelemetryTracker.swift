//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum TelemetryFlavor {
    case components(type: PaymentMethodType)
    case dropIn(type: String = "dropin", paymentMethods: [String])

    // The `dropInComponent` type describes a component within the drop-in component.
    // In telemetry, we need to distinguish when a component is used from the drop-in
    // and when it's used as standalone.
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

@_spi(AdyenInternal)
public protocol TelemetryTrackerProtocol {
    func sendTelemetryEvent(flavor: TelemetryFlavor)
}

// MARK: - TelemetryTrackerProtocol

@_spi(AdyenInternal)
extension AnalyticsProvider: TelemetryTrackerProtocol {

    internal func sendTelemetryEvent(flavor: TelemetryFlavor) {
        guard configuration.isEnabled else { return }
        guard configuration.isTelemetryEnabled else { return }
        if case .dropInComponent = flavor { return }

        let telemetryData = TelemetryData(flavor: flavor)

        fetchCheckoutAttemptId { [weak self] checkoutAttemptId in
            let telemetryRequest = TelemetryRequest(data: telemetryData,
                                                    checkoutAttemptId: checkoutAttemptId)
            self?.apiClient.perform(telemetryRequest) { _ in }
        }
    }
}
