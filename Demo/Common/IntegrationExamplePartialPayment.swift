//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import AdyenNetworking
import UIKit

extension IntegrationExample: PartialPaymentDelegate {

    internal enum GiftCardError: Error, LocalizedError {
        case noBalance

        internal var errorDescription: String? {
            switch self {
            case .noBalance:
                return "No Balance"
            }
        }
    }

    internal func checkBalance(with data: PaymentComponentData,
                               component: Component,
                               completion: @escaping (Result<Balance, Error>) -> Void) {
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
            completion(.failure(error))
        }
    }

    private func handle(response: BalanceCheckResponse, completion: @escaping (Result<Balance, Error>) -> Void) {
        guard let availableAmount = response.balance else {
            completion(.failure(GiftCardError.noBalance))
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }

    internal func requestOrder(for component: Component,
                               completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(amount: ConfigurationConstants.current.amount,
                                         reference: UUID().uuidString)
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

    internal func cancelOrder(_ order: PartialPaymentOrder, component: Component) {
        let request = CancelOrderRequest(order: order)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<CancelOrderResponse, Error>) {
        switch result {
        case let .success(response):
            if response.resultCode == .received {
                presenter?.presentAlert(withTitle: "Order Cancelled", message: nil)
            } else {
                presenter?.presentAlert(withTitle: "Something went wrong, order is not canceled but will expire.", message: nil)
            }
        case let .failure(error):
            finish(with: error)
        }
    }
}
