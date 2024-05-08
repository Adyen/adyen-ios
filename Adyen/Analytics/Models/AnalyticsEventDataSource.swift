//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Handles adding/removing events
internal class AnalyticsEventDataSource: AnyAnalyticsEventDataSource {
    
    private var infoList: [AnalyticsEventInfo] = []
    private var logList: [AnalyticsEventLog] = []
    private var errorList: [AnalyticsEventError] = []
    
    // MARK: - AnalyticsEventDataAddition
    
    internal func add(info: AnalyticsEventInfo) {
        infoList.append(info)
    }
    
    internal func add(log: AnalyticsEventLog) {
        logList.append(log)
    }
    
    internal func add(error: AnalyticsEventError) {
        errorList.append(error)
    }
    
    internal func allEvents() -> AnalyticsEventWrapper? {
        if infoList.isEmpty, logList.isEmpty, errorList.isEmpty {
            return nil
        }
        return AnalyticsEventWrapper(infos: infoList,
                                     logs: logList,
                                     errors: errorList)
    }
    
    // MARK: - AnalyticsEventDataRemoval
    
    internal func removeAllEvents() {
        infoList = []
        logList = []
        errorList = []
    }
    
    internal func removeElements(matching collection: AnalyticsEventWrapper) {
        remove(infos: collection.infos)
        remove(logs: collection.logs)
        remove(errors: collection.errors)
    }
    
    private func remove(infos: [AnalyticsEventInfo]) {
        let infoIds = infos.map(\.id)
        infoList.removeAll { infoIds.contains($0.id) }
    }
    
    private func remove(logs: [AnalyticsEventLog]) {
        let logIds = logs.map(\.id)
        logList.removeAll { logIds.contains($0.id) }
    }
    
    private func remove(errors: [AnalyticsEventError]) {
        let errorIds = errors.map(\.id)
        errorList.removeAll { errorIds.contains($0.id) }
    }
}
