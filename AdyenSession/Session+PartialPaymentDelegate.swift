//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
extension Session: PartialPaymentDelegate {
    
    public func checkBalance(with data: PaymentComponentData,
                             completion: @escaping (Result<Balance, Error>) -> Void) {
        let request = BalanceCheckRequest(sessionId: sessionContext.identifier,
                                          sessionData: sessionContext.data,
                                          data: data)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }
    
    private func handle(result: Result<BalanceCheckResponse, Error>,
                        completion: @escaping (Result<Balance, Error>) -> Void) {
        switch result {
        case let .success(response):
            handle(response: response, completion: completion)
        case let .failure(error):
            handle(error: error, completion: completion)
        }
    }

    private func handle(response: BalanceCheckResponse, completion: @escaping (Result<Balance, Error>) -> Void) {
        guard let availableAmount = response.balance else {
            let error = BalanceChecker.Error.zeroBalance
            completion(.failure(error))
            finish(with: error)
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }

    private func handle(error: Error, completion: @escaping (Result<Balance, Error>) -> Void) {
        completion(.failure(error))
        finish(with: error)
    }
    
    public func requestOrder(_ completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
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
            finish(with: error)
        }
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder) {
        let request = CancelOrderRequest(sessionId: sessionContext.identifier,
                                         sessionData: sessionContext.data,
                                         order: order)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result)
        }
    }
    
    private func handle(result: Result<CancelOrderResponse, Error>) {
        switch result {
        case .success:
            finish()
        case let .failure(error):
            finish(with: error)
        }
    }
    
}
