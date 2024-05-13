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
    
    // MARK: - AnalyticsEventDataAddition
    
    internal func add(info: AnalyticsEventInfo) {
        infos.append(info)
    }
    
    internal func add(log: AnalyticsEventLog) {
        logs.append(log)
    }
    
    internal func add(error: AnalyticsEventError) {
        errors.append(error)
    }
    
    internal func allEvents() -> AnalyticsEventWrapper? {
        if infos.isEmpty, logs.isEmpty, errors.isEmpty {
            return nil
        }
        return AnalyticsEventWrapper(infos: infos,
                                     logs: logs,
                                     errors: errors)
    }
    
    // MARK: - AnalyticsEventDataRemoval
    
    internal func removeAllEvents() {
        infos = []
        logs = []
        errors = []
    }
    
    internal func removeEvents(matching collection: AnalyticsEventWrapper) {
        remove(infoEvents: collection.infos)
        remove(logEvents: collection.logs)
        remove(errorEvents: collection.errors)
    }
    
    private func remove(infoEvents: [AnalyticsEventInfo]) {
        let infoIds = infoEvents.map(\.id)
        infos.removeAll { infoIds.contains($0.id) }
    }
    
    private func remove(logEvents: [AnalyticsEventLog]) {
        let logIds = logEvents.map(\.id)
        logs.removeAll { logIds.contains($0.id) }
    }
    
    private func remove(errorEvents: [AnalyticsEventError]) {
        let errorIds = errorEvents.map(\.id)
        errors.removeAll { errorIds.contains($0.id) }
    }
}
