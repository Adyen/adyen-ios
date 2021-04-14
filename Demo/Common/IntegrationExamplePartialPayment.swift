//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import UIKit

extension IntegrationExample: PartialPaymentDelegate {

    internal enum GiftCardError: Error, LocalizedError {
        case nonBalance

        internal var errorDescription: String? {
            switch self {
            case .nonBalance:
                return "No Balance"
            }
        }
    }

    internal func checkBalance(_ data: PaymentComponentData,
                               from component: PaymentComponent,
                               completion: @escaping (Result<Balance, Error>) -> Void) {
//        completion(.success(Payment.Amount(value: 100000, currencyCode: "EUR")))
        let request = BalanceCheckRequest(data: data)
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
            finish(with: GiftCardError.nonBalance)
            completion(.failure(GiftCardError.nonBalance))
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }

    private func handle(error: Error, completion: @escaping (Result<Balance, Error>) -> Void) {
        finish(with: error)
        completion(.failure(error))
    }

    internal func requestOrder(_ data: PaymentComponentData,
                               from component: PaymentComponent,
                               completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(amount: payment.amount, reference: UUID().uuidString)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, completion: completion)
        }
    }

    private func handle(result: Result<CreateOrderResponse, Error>,
                        completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        switch result {
        case let .success(response):
            self.order = response.order
            completion(.success(response.order))
        case let .failure(error):
            finish(with: error)
            completion(.failure(error))
        }
    }

    internal func cancelOrder(_ order: PartialPaymentOrder,
                              from component: PaymentComponent,
                              completion: @escaping (Error?) -> Void) {
        let request = CancelOrderRequest(order: order)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result, with: component, completion: completion)
        }
    }

    private func handle(result: Result<CancelOrderResponse, Error>,
                        with component: PaymentComponent,
                        completion: @escaping (Error?) -> Void) {
        currentComponent?.cancelIfNeeded()
        component.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
        order = nil

        switch result {
        case .success:
            completion(nil)
        case let .failure(error):
            completion(error)
        }
    }
}
