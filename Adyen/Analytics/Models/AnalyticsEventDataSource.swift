//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import AdyenNetworking

/// Handles adding/removing events
internal class AnalyticsEventDataSource: AnyAnalyticsEventDataSource {
    
    private(set) internal var infos: [AnalyticsEventInfo] = []
    private(set) internal var logs: [AnalyticsEventLog] = []
    private(set) internal var errors: [AnalyticsEventError] = []
    
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
    
    internal func wrappedEvents() -> AnalyticsEventWrapper? {
        if infos.isEmpty && logs.isEmpty && errors.isEmpty {
            return nil
        }
        return AnalyticsEventWrapper(infos: infos,
                                     logs: logs,
                                     errors: errors)
    }
    
}
