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
    
    var checkoutAttemptId: String?

    // MARK: - checkoutAttemptId
    
    func sendInitialAnalytics(with flavor: TelemetryFlavor, additionalFields: AdditionalAnalyticsFields?) {
        initialTelemetryEventCallsCount += 1
        checkoutAttemptId = _checkoutAttemptId
    }
    
    var _checkoutAttemptId: String?

    var initialTelemetryEventCallsCount = 0
    var initialTelemetryEventCalled: Bool {
        initialTelemetryEventCallsCount > 0
    }
}
