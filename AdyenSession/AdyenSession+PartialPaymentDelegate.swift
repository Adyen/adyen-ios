//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

@_spi(AdyenInternal)
extension AdyenSession: PartialPaymentDelegate {
    
    public func checkBalance(with data: PaymentComponentData, component: Component,
                             completion: @escaping (Result<Balance, Error>) -> Void) {
        let request = BalanceCheckRequest(sessionId: sessionContext.identifier,
                                          sessionData: sessionContext.data,
                                          data: data)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, component: component, completion: completion)
        }
    }
    
    private func handle(result: Result<BalanceCheckResponse, Error>,
                        component: Component,
                        completion: @escaping (Result<Balance, Error>) -> Void) {
        switch result {
        case let .success(response):
            handle(response: response, completion: completion)
        case let .failure(error):
            completion(.failure(error))
        }
    }

    private func handle(response: BalanceCheckResponse,
                        completion: @escaping (Result<Balance, Error>) -> Void) {
        guard let availableAmount = response.balance else {
            let error = BalanceChecker.Error.zeroBalance
            completion(.failure(error))
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }
    
    public func requestOrder(for component: Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }
    
    private func handle(result: Result<CreateOrderResponse, Error>,
                        completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        switch result {
        case let .success(response):
            completion(.success(response.order))
        case let .failure(error):
            completion(.failure(error))
        }
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder, component: Component) {
        let request = CancelOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data,
                                         order: order)
        // no feedback needed from cancelOrder as the delegate will be called
        // when cancel button in dropIn is pressed
        // we may need to update that flow first if feedback is needed from here
        apiClient.perform(request) { _ in }
    }
    
}
