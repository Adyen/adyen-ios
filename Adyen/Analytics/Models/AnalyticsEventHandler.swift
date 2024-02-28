//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import AdyenNetworking

/// Handles accumulating and sending of events in a thread safe manner.
/// Events are sent either in an interval or immediately when an error/log event is received.
internal class AnalyticsEventHandler {
    
    private enum Constants {
        static let batchInterval: TimeInterval = 15
        static let infoLimit = 50
        static let logLimit = 5
        static let errorLimit = 5
        static let queueLabel = "com.adyen.analytics.queue"
    }
    
    private(set) internal var infos: [AnalyticsEventInfo] = []
    private(set) internal var logs: [AnalyticsEventLog] = []
    private(set) internal var errors: [AnalyticsEventError] = []
    
    private let queue: DispatchQueue
    private var batchTimer: Timer?
    
    private let apiClient: APIClientProtocol
    private var checkoutAttemptId: String?
    
    internal init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
        self.queue = DispatchQueue(label: Constants.queueLabel, attributes: .concurrent)
        self.startNextTimer()
    }
    
    deinit {
        // attempt to send remaining events on deallocation
        sendEventsIfNeeded()
    }
    
    internal func update(checkoutAttemptId: String) {
        // Fetching checkout attempt id is async
        // The event handler needs to be alive beforehand to start accumulating events
        // but can't send events without attempt id so it should be set when fetched
        self.checkoutAttemptId = checkoutAttemptId
    }
    
    // MARK: - Event handling
    
    internal func add(info: AnalyticsEventInfo) {
        queue.sync(flags: .barrier) { [weak self] in
            self?.infos.append(info)
        }
    }
    
    internal func add(log: AnalyticsEventLog) {
        queue.sync(flags: .barrier) { [weak self] in
            self?.logs.append(log)
        }
        sendEventsIfNeeded()
    }
    
    internal func add(error: AnalyticsEventError) {
        queue.sync(flags: .barrier) { [weak self] in
            self?.errors.append(error)
        }
        sendEventsIfNeeded()
    }
    
    internal func sendEventsIfNeeded() {
        guard let request = requestWithAllEvents() else { return }
        
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }
            // clear the current events on succesful send
            switch result {
            case .success:
                self.removeAllEvents()
                self.startNextTimer()
            case .failure:
                break
            }
        }
    }
    
    internal func removeAllEvents() {
        queue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            self.infos = []
            self.logs = []
            self.errors = []
        }
    }
    
    // MARK: - Private
    
    /// Checks the event arrays safely and creates the request with them if there is any to send.
    private func requestWithAllEvents() -> AnalyticsRequest? {
        guard let checkoutAttemptId else { return nil }
        
        return queue.sync {
            if infos.isEmpty && logs.isEmpty && errors.isEmpty {
                return nil
            }
            
            var request = AnalyticsRequest(checkoutAttemptId: checkoutAttemptId)
            request.infos = infos.suffix(Constants.infoLimit)
            request.logs = logs.suffix(Constants.logLimit)
            request.errors = errors.suffix(Constants.errorLimit)
            return request
        }
    }
    
    private func startNextTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: Constants.batchInterval, repeats: true) { [weak self] _ in
            self?.sendEventsIfNeeded()
        }
    }
    
}
