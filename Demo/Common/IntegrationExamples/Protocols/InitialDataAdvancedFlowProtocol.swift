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
internal protocol InitialDataAdvancedFlowProtocol: AnyObject {
    var context: AdyenContext? { get set }

    var apiClient: APIClientProtocol { get }
    func requestPaymentMethods(
        order: PartialPaymentOrder?,
        amount: Amount,
        completion: @escaping (Result<PaymentMethods, Error>) -> Void
    )

    func start()
}

extension InitialDataAdvancedFlowProtocol {

    internal func requestPaymentMethods(
        order: PartialPaymentOrder?,
        amount: Amount = ConfigurationConstants.current.amount,
        completion: @escaping (Result<PaymentMethods, Error>) -> Void
    ) {
        let request = PaymentMethodsRequest(order: order, amount: amount)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                completion(.success(response.paymentMethods))
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
    
    internal func requestPaymentMethods(
        order: PartialPaymentOrder?,
        amount: Amount = ConfigurationConstants.current.amount
    ) async throws -> PaymentMethods {
        let request = PaymentMethodsRequest(order: order, amount: amount)
        let response = try await withCheckedThrowingContinuation { continuation in
            apiClient.perform(request) { result in
                continuation.resume(with: result)
            }
        }
            
        return response.paymentMethods
    }

}
