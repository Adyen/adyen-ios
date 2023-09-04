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
import AdyenNetworking
import UIKit

extension IntegrationExample: PartialPaymentDelegate {

    enum GiftCardError: Error, LocalizedError {
        case noBalance

        var errorDescription: String? {
            switch self {
            case .noBalance:
                return "No Balance"
            }
        }
    }

    func checkBalance(with data: PaymentComponentData,
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
            handle(error: error, completion: completion)
        }
    }

    private func handle(response: BalanceCheckResponse, completion: @escaping (Result<Balance, Error>) -> Void) {
        guard let availableAmount = response.balance else {
            finish(with: GiftCardError.noBalance)
            completion(.failure(GiftCardError.noBalance))
            return
        }
        let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
        completion(.success(balance))
    }

    private func handle(error: Error, completion: @escaping (Result<Balance, Error>) -> Void) {
        finish(with: error)
        completion(.failure(error))
    }

    func requestOrder(_ completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(amount: payment.amount, reference: UUID().uuidString)
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
            finish(with: error)
            completion(.failure(error))
        }
    }

    func cancelOrder(_ order: PartialPaymentOrder) {
        let request = CancelOrderRequest(order: order)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<CancelOrderResponse, Error>) {
        switch result {
        case let .success(response):
            if response.resultCode == .received {
                presentAlert(withTitle: "Order Cancelled")
            } else {
                presentAlert(withTitle: "Something went wrong, order is not canceled but will expire.")
            }
        case let .failure(error):
            finish(with: error)
        }
    }
}
