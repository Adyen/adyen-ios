//
//  AnalyticsProviderMock.swift
//  AdyenUIHost
//
//  Created by Naufal Aros on 4/11/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
@_spi(AdyenInternal) @testable import Adyen

class AnalyticsProviderMock: AnalyticsProviderProtocol {
    var checkoutAttemptId: String? { underlyingCheckoutAttemptId }

    // MARK: - checkoutAttemptId

    func fetchCheckoutAttemptId(completion: @escaping (String?) -> Void) {
        completion(underlyingCheckoutAttemptId)
    }
    
    func fetchAndCacheCheckoutAttemptIdIfNeeded() {
        fetchCheckoutAttemptId(completion: { _ in })
    }
    
    var underlyingCheckoutAttemptId: String?

    // MARK: - sendTelemetryEvent

    var sendTelemetryEventCallsCount = 0
    var sendTelemetryEventCalled: Bool {
        sendTelemetryEventCallsCount > 0
    }

    func sendTelemetryEvent(flavor: TelemetryFlavor) {
        sendTelemetryEventCallsCount += 1
    }
}
