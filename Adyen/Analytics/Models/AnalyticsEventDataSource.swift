//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Handles adding/removing events
internal class AnalyticsEventDataSource: AnyAnalyticsEventDataSource {
    
    private var infos: [AnalyticsEventInfo] = []
    private var logs: [AnalyticsEventLog] = []
    private var errors: [AnalyticsEventError] = []
    
    // MARK: - AnyAnalyticsEventDataSource
    
    internal func add(info: AnalyticsEventInfo) {
        infos.append(info)
    }
    
    internal func add(log: AnalyticsEventLog) {
        logs.append(log)
    }
    
    internal func add(error: AnalyticsEventError) {
        errors.append(error)
    }
    
    internal func removeAllEvents() {
        infos = []
        logs = []
        errors = []
    }
    
    internal func allEvents() -> AnalyticsEventWrapper? {
        if infos.isEmpty, logs.isEmpty, errors.isEmpty {
            return nil
        }
        return AnalyticsEventWrapper(infos: infos,
                                     logs: logs,
                                     errors: errors)
    }
    
}
