//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal final class EventAnalyticsProvider: AnyEventAnalyticsProvider {
    
    private enum Constants {
        static let batchInterval: TimeInterval = 10
        static let infoLimit = 50
        static let logLimit = 5
        static let errorLimit = 5
    }
    
    internal var checkoutAttemptId: String?
    internal let apiClient: APIClientProtocol
    internal let eventDataSource: AnyAnalyticsEventDataSource
    
    private let context: AnalyticsContext
    private var batchTimer: Timer?
    private let batchInterval: TimeInterval
    
    internal init(
        apiClient: APIClientProtocol,
        context: AnalyticsContext,
        eventDataSource: AnyAnalyticsEventDataSource,
        batchInterval: TimeInterval = Constants.batchInterval
    ) {
        self.apiClient = apiClient
        self.eventDataSource = eventDataSource
        self.context = context
        self.batchInterval = batchInterval
        startNextTimer()
    }
    
    deinit {
        // attempt to send remaining events on deallocation
        batchTimer?.invalidate()
        sendEventsIfNeeded()
    }
    
    internal func add(info: AnalyticsEventInfo) {
        eventDataSource.add(info: info)
    }
    
    internal func add(log: AnalyticsEventLog) {
        eventDataSource.add(log: log)
        sendEventsIfNeeded()
    }
    
    internal func add(error: AnalyticsEventError) {
        eventDataSource.add(error: error)
        sendEventsIfNeeded()
    }
    
    internal func sendEventsIfNeeded() {
        guard let request = requestWithAllEvents() else { return }
        
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }
            // clear the sent events on successful send
            switch result {
            case .success:
                self.removeEvents(sentBy: request)
                self.startNextTimer()
            case .failure:
                break
            }
        }
    }
    
    // MARK: - Private
    
    /// Checks the event arrays safely and creates the request with them if there is any to send.
    private func requestWithAllEvents() -> AnalyticsRequest? {
        guard let checkoutAttemptId,
              let events = eventDataSource.allEvents() else { return nil }
        
        // as per this call's limitation, we only send up to the
        // limit of each event and discard the older ones
        let platform = context.platform.rawValue
        var request = AnalyticsRequest(
            checkoutAttemptId: checkoutAttemptId,
            platform: platform
        )
        request.infos = events.infos.suffix(Constants.infoLimit)
        request.logs = events.logs.suffix(Constants.logLimit)
        request.errors = events.errors.suffix(Constants.errorLimit)
        return request
    }
    
    private func removeEvents(sentBy request: AnalyticsRequest) {
        let collection = AnalyticsEventWrapper(
            infos: request.infos,
            logs: request.logs,
            errors: request.errors
        )
        eventDataSource.removeEvents(matching: collection)
    }
    
    private func startNextTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: true) { [weak self] _ in
            self?.sendEventsIfNeeded()
        }
    }
}
