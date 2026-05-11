//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import struct AdyenCheckout.CheckoutConfiguration
import AdyenNetworking
import AdyenSession

@MainActor
internal protocol InitialDataFlowProtocol: AnyObject {
    var context: AdyenContext? { get set }
    var apiClient: APIClientProtocol { get }
    func requestSessionInitialInfo(completion: @escaping (Result<SessionResponse, Error>) -> Void)

    func start()
}

extension InitialDataFlowProtocol {

    internal func requestSessionInitialInfo(completion: @escaping (Result<SessionResponse, Error>) -> Void) {
        let request = SessionRequest()
        apiClient.perform(request, completionHandler: completion)
    }
    
    func initializeExampleAppAdyenContext() async throws {
        let analyticsConfiguration = AnalyticsConfiguration(
            isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
        )

        let publicKey = try await PublicKeyFetcher().fetchPublicKey(
            apiClient: APIClient(apiContext: ConfigurationConstants.apiContext),
            clientKey: ConfigurationConstants.apiContext.clientKey
        )

        // TODO: This has to be removed from the demo code. AdyenContext will not be exposed to the merchants in V6
        self.context = AdyenContext(
            apiContext: ConfigurationConstants.apiContext,
            amount: ConfigurationConstants.current.amount,
            publicKey: publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: CheckoutConfiguration.createAnalyticsAPIContext(apiContext: ConfigurationConstants.apiContext),
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
