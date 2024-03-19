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
