//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) @testable import Adyen

class AnalyticsProviderMock: AnyAnalyticsProvider {
    
    var checkoutAttemptId: String?

    // MARK: - checkoutAttemptId
    
    func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?) {
        initialEventCallsCount += 1
        checkoutAttemptId = _checkoutAttemptId
    }
    
    var _checkoutAttemptId: String?

    var initialEventCallsCount = 0
    var initialEventCalled: Bool {
        initialEventCallsCount > 0
    }
    
    var infos: [AnalyticsEventInfo] = []
    func add(info: AnalyticsEventInfo) {
        infos.append(info)
    }
    
    var logs: [AnalyticsEventLog] = []
    func add(log: AnalyticsEventLog) {
        logs.append(log)
    }
    
    var errors: [AnalyticsEventError] = []
    func add(error: AnalyticsEventError) {
        errors.append(error)
    }
    
    func clearAll() {
        infos = []
        logs = []
        errors = []
    }
}
