//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

internal protocol InitialDataFlowProtocol: AnyObject {
    var context: AdyenContext { get }
    var apiClient: APIClientProtocol { get }
    func requestSessionInitialInfo(completion: @escaping (Result<SessionResponse, Error>) -> Void)
    func generateContext() -> AdyenContext
    func start()
}

extension InitialDataFlowProtocol {

    internal func requestSessionInitialInfo(completion: @escaping (Result<SessionResponse, Error>) -> Void) {
        let request = SessionRequest()
        apiClient.perform(request, completionHandler: completion)
    }
    
    func generateContext() -> AdyenContext {
        let analyticsConfiguration = AnalyticsConfiguration(
            isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
        )
        return AdyenContext(
            apiContext: ConfigurationConstants.apiContext,
            payment: ConfigurationConstants.current.payment,
            amount: ConfigurationConstants.current.amount,
            analyticsConfiguration: analyticsConfiguration
        )
    }
    
    internal func requestSessionInitialInfo() async throws -> SessionResponse {
        let request = SessionRequest()
        return try await withCheckedThrowingContinuation { continuation in
            apiClient.perform(request) { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension CheckoutResultCode {
    var isSuccess: Bool {
        self == .authorised || self == .received || self == .pending
    }
}
