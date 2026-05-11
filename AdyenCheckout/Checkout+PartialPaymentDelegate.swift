//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif
import UIKit

// MARK: - PartialPaymentDelegate

extension Checkout: PartialPaymentDelegate {

    public func checkBalance(
        with data: PaymentComponentData,
        component: any Component,
        completion: @escaping (Result<Balance, Error>) -> Void
    ) {
        guard let session else {
            completion(.failure(PartialPaymentError.notSupportedForComponent))
            return
        }

        Task { [weak self] in
            guard self != nil else { return }
            do {
                let balance = try await session.performBalanceCheck(with: data)
                completion(.success(balance))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func requestOrder(for component: any Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        guard let session else {
            completion(.failure(PartialPaymentError.notSupportedForComponent))
            return
        }

        Task { [weak self] in
            guard self != nil else { return }
            do {
                let order = try await session.requestOrder()
                completion(.success(order))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func cancelOrder(_ order: PartialPaymentOrder, component: any Component) {
        Task { [weak self] in
            await self?.session?.cancelOrder(order)
        }
    }
}

internal extension Checkout {

    func handle(partialPayment: PartialPayment, source: CheckoutCallbackSource) {
        guard let dropInComponent = source.dropInComponent else {
            handle(PartialPaymentError.notSupportedForComponent, from: source.paymentComponent)
            return
        }

        let reloadDropIn = { [weak self] in
            self?.reload(dropInComponent, with: partialPayment, from: source.paymentComponent)
        } as () -> Void

        if session?.currentResult?.resultCode == .refused {
            showPaymentFailedAlert(on: dropInComponent, completion: reloadDropIn)
        } else {
            reloadDropIn()
        }
    }

    func reload(_ dropInComponent: any AnyDropInComponent, with partialPayment: PartialPayment, from component: (any PaymentComponent)?) {
        do {
            try dropInComponent.reload(with: partialPayment.order, partialPayment.paymentMethods)
        } catch {
            handle(error, from: component)
        }
    }

    func showPaymentFailedAlert(on dropInComponent: any AnyDropInComponent, completion: @escaping () -> Void) {
        let localizationParameters = (dropInComponent as? Localizable)?.localizationParameters
        let title = localizedString(.errorTitle, localizationParameters)
        let message = localizedString(.paymentRefusedMessage, localizationParameters)

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let doneTitle = localizedString(.dismissButton, localizationParameters)
        let doneAction = UIAlertAction(title: doneTitle, style: .default) { _ in
            completion()
        }
        alertController.addAction(doneAction)

        dropInComponent.viewController.present(alertController, animated: true)
    }
}
