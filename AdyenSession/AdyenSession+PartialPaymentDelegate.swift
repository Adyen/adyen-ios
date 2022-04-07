//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
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
            handle(response: response, component: component, completion: completion)
        case let .failure(error):
            handle(error: error, component: component, completion: completion)
        }
    }

    private func handle(response: BalanceCheckResponse,
                        component: Component,
                        completion: @escaping (Result<Balance, Error>) -> Void) {
        guard let availableAmount = response.balance else {
            let error = BalanceChecker.Error.zeroBalance
            completion(.failure(error))
            finish(with: error, component: component)
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }

    private func handle(error: Error,
                        component: Component,
                        completion: @escaping (Result<Balance, Error>) -> Void) {
        completion(.failure(error))
        finish(with: error, component: component)
    }
    
    public func requestOrder(for component: Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, component: component, completion: completion)
        }
    }
    
    private func handle(result: Result<CreateOrderResponse, Error>,
                        component: Component,
                        completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        switch result {
        case let .success(response):
            completion(.success(response.order))
        case let .failure(error):
            completion(.failure(error))
            finish(with: error, component: component)
        }
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder, component: Component) {
        let request = CancelOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data,
                                         order: order)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, component: component)
        }
    }
    
    private func handle(result: Result<CancelOrderResponse, Error>, component: Component) {
        switch result {
        case .success:
            finish(with: ComponentError.cancelled, component: component)
        case let .failure(error):
            finish(with: error, component: component)
        }
    }
    
}
