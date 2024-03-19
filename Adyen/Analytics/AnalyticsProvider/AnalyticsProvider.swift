//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public protocol AnalyticsProviderProtocol {
    
    var checkoutAttemptId: String? { get }
    
    /// Sends the initial data and retrieves the checkout attempt id as a response.
    func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?)
    
    /// Adds an info event to be sent.
    func add(info: AnalyticsEventInfo)
    
    /// Adds a log event to be sent.
    func add(log: AnalyticsEventLog)
    
    /// Adds an error event to be sent.
    func add(error: AnalyticsEventError)
}

internal final class AnalyticsProvider: AnalyticsProviderProtocol {
    
    private enum Constants {
        static let batchInterval: TimeInterval = 10
        static let infoLimit = 50
        static let logLimit = 5
        static let errorLimit = 5
    }

    // MARK: - Properties

    internal let apiClient: APIClientProtocol
    internal let configuration: AnalyticsConfiguration
    internal private(set) var checkoutAttemptId: String?
    internal let eventDataSource: AnyAnalyticsEventDataSource
    
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<InitialAnalyticsResponse>
    
    private var batchTimer: Timer?
    private let batchInterval: TimeInterval

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        configuration: AnalyticsConfiguration,
        eventDataSource: AnyAnalyticsEventDataSource,
        batchInterval: TimeInterval = Constants.batchInterval
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<InitialAnalyticsResponse>(apiClient: apiClient)
        self.eventDataSource = eventDataSource
        self.batchInterval = batchInterval
        startNextTimer()
    }
    
    deinit {
        // attempt to send remaining events on deallocation
        sendEventsIfNeeded()
    }

    // MARK: - AnalyticsProviderProtocol

    internal func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?) {
        guard configuration.isEnabled else {
            checkoutAttemptId = "do-not-track"
            return
        }
        
        let analyticsData = AnalyticsData(flavor: flavor,
                                          additionalFields: additionalFields,
                                          context: configuration.context)

        let initialAnalyticsRequest = InitialAnalyticsRequest(data: analyticsData)

        uniqueAssetAPIClient.perform(initialAnalyticsRequest) { [weak self] result in
            self?.saveCheckoutAttemptId(from: result)
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
        
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }
            // clear the current events on successful send
            switch result {
            case .success:
                self.eventDataSource.removeAllEvents()
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
              let events = eventDataSource.wrappedEvents() else { return nil }
        
        // as per this call's limitation, we only send up to the
        // limit of each event and discard the older ones
        var request = AnalyticsRequest(checkoutAttemptId: checkoutAttemptId)
        request.infos = events.infos.suffix(Constants.infoLimit)
        request.logs = events.logs.suffix(Constants.logLimit)
        request.errors = events.errors.suffix(Constants.errorLimit)
        return request
    }
    
    private func saveCheckoutAttemptId(from result: Result<InitialAnalyticsResponse, Error>) {
        switch result {
        case let .success(response):
            checkoutAttemptId = response.checkoutAttemptId
        case .failure:
            checkoutAttemptId = nil
        }
    }
    
    private func startNextTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: true) { [weak self] _ in
            self?.sendEventsIfNeeded()
        }
    }
}
