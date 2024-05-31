//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol AnalyticsEventDataAddition {
    func add(info: AnalyticsEventInfo)
    func add(log: AnalyticsEventLog)
    func add(error: AnalyticsEventError)
    
    func allEvents() -> AnalyticsEventWrapper?
}

internal protocol AnalyticsEventDataRemoval {
    
    func removeAllEvents()
    
    /// Removes events matching given collection.
    func removeEvents(matching collection: AnalyticsEventWrapper)
}

internal protocol AnyAnalyticsEventDataSource: AnalyticsEventDataAddition & AnalyticsEventDataRemoval {}

internal struct AnalyticsEventWrapper {
    internal var infos: [AnalyticsEventInfo]
    internal var logs: [AnalyticsEventLog]
    internal var errors: [AnalyticsEventError]
}

/// Composes handling of events in a thread safe manner.
internal final class ThreadSafeAnalyticsEventDataSource: AnyAnalyticsEventDataSource {
    
    private enum Constants {
        static let queueLabel = "com.adyen.analytics.queue"
    }
    
    private let dataSource: AnyAnalyticsEventDataSource
    private let queue: DispatchQueue

    internal init(dataSource: AnyAnalyticsEventDataSource) {
        self.dataSource = dataSource
        self.queue = DispatchQueue(label: Constants.queueLabel, attributes: .concurrent)
    }
    
    // MARK: - AnalyticsEventDataAddition

    internal func add(info: AnalyticsEventInfo) {
        queue.sync(flags: .barrier) {
            dataSource.add(info: info)
        }
    }
    
    internal func add(log: AnalyticsEventLog) {
        queue.sync(flags: .barrier) {
            dataSource.add(log: log)
        }
    }
    
    internal func add(error: AnalyticsEventError) {
        queue.sync(flags: .barrier) {
            dataSource.add(error: error)
        }
    }
    
    internal func allEvents() -> AnalyticsEventWrapper? {
        queue.sync {
            dataSource.allEvents()
        }
    }
    
    // MARK: - AnalyticsEventDataRemoval
    
    internal func removeEvents(matching collection: AnalyticsEventWrapper) {
        queue.sync(flags: .barrier) {
            dataSource.removeEvents(matching: collection)
        }
    }
    
    internal func removeAllEvents() {
        queue.sync(flags: .barrier) {
            dataSource.removeAllEvents()
        }
    }
    
}
