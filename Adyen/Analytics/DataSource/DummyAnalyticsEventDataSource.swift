//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal final class DummyAnalyticsEventDataSource: AnyAnalyticsEventDataSource {
    func add(info: AnalyticsEventInfo) {}
    func add(log: AnalyticsEventLog) {}
    func add(error: AnalyticsEventError) {}
    
    func allEvents() -> AnalyticsEventWrapper? { nil }
    func removeAllEvents() {}
    func removeEvents(matching collection: AnalyticsEventWrapper) {}
}
