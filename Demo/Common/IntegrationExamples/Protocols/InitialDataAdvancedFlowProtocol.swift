//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import struct AdyenCheckout.CheckoutConfiguration
import AdyenNetworking
import AdyenSession

@MainActor
internal protocol InitialDataAdvancedFlowProtocol: AnyObject {
    var context: AdyenContext { get }
    var apiClient: APIClientProtocol { get }
    func requestPaymentMethods(
        order: PartialPaymentOrder?,
        amount: Amount,
        completion: @escaping (Result<PaymentMethods, Error>) -> Void
    )
    func generateContext() -> AdyenContext
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
    
    func generateContext() -> AdyenContext {
        let analyticsConfiguration = AnalyticsConfiguration(
            isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
        )
        // TODO: This has to be removed from the demo code. AdyenContext will not be exposed to the merchants in V6
        return AdyenContext(
            apiContext: ConfigurationConstants.apiContext,
            amount: ConfigurationConstants.current.amount,
            publicKey: "",
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
