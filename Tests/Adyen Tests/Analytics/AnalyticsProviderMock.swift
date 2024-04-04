//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Foundation

class AnalyticsProviderMock: AnalyticsProviderProtocol {
    
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
    
    var infoCount = 0
    func add(info: Adyen.AnalyticsEventInfo) {
        infoCount += 1
    }
    
    var logCount = 0
    func add(log: Adyen.AnalyticsEventLog) {
        logCount += 1
    }
    
    var errorCount = 0
    func add(error: Adyen.AnalyticsEventError) {
        errorCount += 1
    }
}
