//
// Copyright (c) 2022 Adyen N.V.
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

    internal let apiClient: AsyncAPIClientProtocol
    internal let eventDataSource: AnyAnalyticsEventDataSource
    private var batchTimer: Timer?
    private let batchInterval: TimeInterval
    private let checkoutAttemptId: String

    internal init(
        apiClient: AsyncAPIClientProtocol,
        eventDataSource: AnyAnalyticsEventDataSource,
        checkoutAttemptId: String,
        batchInterval: TimeInterval = Constants.batchInterval
    ) {
        self.apiClient = apiClient
        self.eventDataSource = eventDataSource
        self.batchInterval = batchInterval
        self.checkoutAttemptId = checkoutAttemptId
        
        Task { await startNextTimer() }
    }
    
    deinit {
        batchTimer?.invalidate()
        // fire-and-forget remaining events without capturing self
        if let request = requestWithAllEvents() {
            let apiClient = apiClient
            Task {
                _ = try? await apiClient.performAsync(request)
            }
        }
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
        
        Task {
            do {
                _ = try await apiClient.performAsync(request)
                removeEvents(sentBy: request)
                await startNextTimer()
            } catch {}
        }
    }
    
    // MARK: - Private
    
    /// Checks the event arrays safely and creates the request with them if there is any to send.
    private func requestWithAllEvents() -> AnalyticsRequest? {
        guard let events = eventDataSource.allEvents() else { return nil }

        // as per this call's limitation, we only send up to the
        // limit of each event and discard the older ones
        let platform = checkoutPlatformParams.platform.rawValue
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
    
    @MainActor
    private func startNextTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: true) { [weak self] _ in
            self?.sendEventsIfNeeded()
        }
    }
}
