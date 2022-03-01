//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol BACSDirectDebitComponentTrackerProtocol: AnyObject {
    func sendEvent()
}

/// :nodoc:
internal class BACSDirectDebitComponentTracker: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    private let apiContext: APIContext
    private let telemetryTracker: TelemetryTrackerProtocol
    private let isDropIn: Bool

    // MARK: - Initializers

    internal init(paymentMethod: BACSDirectDebitPaymentMethod,
                  apiContext: APIContext,
                  telemetryTracker: TelemetryTrackerProtocol,
                  isDropIn: Bool) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.telemetryTracker = telemetryTracker
        self.isDropIn = isDropIn
    }

    // MARK: - BACSDirectDebitComponentTrackerProtocol

    internal func sendEvent() {
        telemetryTracker.sendTelemetryEvent(flavor: isDropIn ? .dropin(paymentMethods: []) : .components,
                                            component: paymentMethod.type)
    }

}
