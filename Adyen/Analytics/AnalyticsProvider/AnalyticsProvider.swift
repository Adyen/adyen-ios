//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// A configuration object that defines the behavior for the analytics.
public struct AnalyticsConfiguration {

    // MARK: - Properties

    /// A Boolean value that determines whether analytics is enabled.
    public var isEnabled = true

    @_spi(AdyenInternal)
    public var isTelemetryEnabled = true

    // MARK: - Initializers
    
    /// Initializes a new instance of `AnalyticsConfiguration`
    public init() { /* Empty implementation */ }
}

@_spi(AdyenInternal)
/// Additional fields to be provided with a ``TelemetryRequest``
public struct AdditionalAnalyticsFields {
    /// The amount of the payment
    public let amount: Amount?
    
    public let sessionId: String?
    
    public init(amount: Amount? = nil, sessionId: String? = nil) {
        self.amount = amount
        self.sessionId = sessionId
    }
}

@_spi(AdyenInternal)
public protocol InitialTelemetryProtocol {
    
    /// Sends the initial data and retrieves the checkout attempt id as a response.
    func fetchCheckoutAttemptId(with flavor: TelemetryFlavor, additionalFields: AdditionalAnalyticsFields?)
}

@_spi(AdyenInternal)
public protocol AnalyticsProviderProtocol: InitialTelemetryProtocol {
    
    var checkoutAttemptId: String? { get }
}

internal final class AnalyticsProvider: AnalyticsProviderProtocol {

    // MARK: - Properties

    internal let apiClient: APIClientProtocol
    internal let configuration: AnalyticsConfiguration
    internal private(set) var checkoutAttemptId: String?
    private let uniqueAssetAPIClient: UniqueAssetAPIClient<CheckoutAttemptIdResponse>
    
    private var batchTimer: Timer?
    
    private var events: [AdyenAnalytics.Event] = []
    private var logs: [AdyenAnalytics.Log] = []
    private var errors: [AdyenAnalytics.Error] = []

    // MARK: - Initializers

    internal init(
        apiClient: APIClientProtocol,
        configuration: AnalyticsConfiguration
    ) {
        self.apiClient = apiClient
        self.configuration = configuration
        self.uniqueAssetAPIClient = UniqueAssetAPIClient<CheckoutAttemptIdResponse>(apiClient: apiClient)
    }

    // MARK: - Internal

    internal func fetchCheckoutAttemptId(with flavor: TelemetryFlavor, additionalFields: AdditionalAnalyticsFields?) {
        guard configuration.isEnabled, configuration.isTelemetryEnabled else {
            checkoutAttemptId = "do-not-track"
            return
        }
        if case .dropInComponent = flavor { return }
        
        let telemetryData = TelemetryData(flavor: flavor,
                                          additionalFields: additionalFields)

        let checkoutAttemptIdRequest = CheckoutAttemptIdRequest(data: telemetryData)

        uniqueAssetAPIClient.perform(checkoutAttemptIdRequest) { [weak self] result in
            switch result {
            case let .success(response):
                self?.checkoutAttemptId = response.identifier
            case .failure:
                self?.checkoutAttemptId = nil
            }
        }
    }
    
    internal func send(event: AdyenAnalytics.Event) {
        events.append(event)
    }
    
    internal func send(log: AdyenAnalytics.Log) {
        logs.append(log)
    }
    
    internal func send(error: AdyenAnalytics.Error) {
        errors.append(error)
        sendAll()
    }
    
    private func setupTimer() {
        let timer = Timer(timeInterval: 10, target: self, selector: #selector(sendAll), userInfo: nil, repeats: true)
        timer.tolerance = 1
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc private func sendAll() {
        guard configuration.isEnabled,
              let checkoutAttemptId else { return }
        var request = AdyenAnalyticsRequest(checkoutAttemptId: checkoutAttemptId)
        
        request.events = events
        request.logs = logs
        request.errors = errors
        
        apiClient.perform(request) { [weak self] _ in
            guard let self else { return }
            self.clearAll()
        }
    }
    
    private func clearAll() {
        events = []
        logs = []
        errors = []
    }
}
