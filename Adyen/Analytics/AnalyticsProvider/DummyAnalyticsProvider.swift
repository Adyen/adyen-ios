//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

final class DummyAnalyticsProvider: AnalyticsProviderProtocol {
    var checkoutAttemptId: String?
    
    func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?) {
        
    }
    
    func add(info: AnalyticsEventInfo) {
    
    }
    
    func add(log: AnalyticsEventLog) {
        
    }
    
    func add(error: AnalyticsEventError) {
        
    }
    
    
}
