//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

@_spi(AdyenInternal)
extension Session: PartialPaymentDelegate {
    
    public func checkBalance(
        with data: PaymentComponentData,
        component: Component,
        completion: @escaping (Result<Balance, Error>) -> Void
    ) {
        let request = BalanceCheckRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            data: data
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                let response: BalanceCheckResponse = try await apiClient.performAsync(request)
                guard let availableAmount = response.balance else {
                    completion(.failure(BalanceChecker.Error.zeroBalance))
                    return
                }
                let balance = Balance(availableAmount: availableAmount, transactionLimit: response.transactionLimit)
                completion(.success(balance))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func requestOrder(for component: Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        let request = CreateOrderRequest(
            sessionId: state.identifier,
            sessionData: state.data
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                let response: CreateOrderResponse = try await apiClient.performAsync(request)
                completion(.success(response.order))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder, component: Component) {
        let request = CancelOrderRequest(
            sessionId: state.identifier,
            sessionData: state.data,
            order: order
        )
        // no feedback needed from cancelOrder as the delegate will be called
        // when cancel button in dropIn is pressed
        Task { [weak self] in _ = try? await self?.apiClient.performAsync(request) }
    }
    
}
