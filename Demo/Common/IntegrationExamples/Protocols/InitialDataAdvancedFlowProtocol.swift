//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import AdyenSession

@MainActor
internal protocol InitialDataAdvancedFlowProtocol: AnyObject {

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
