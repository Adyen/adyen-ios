//
//  AdyenIntegration.swift
//  Adyen
//
//  Created by Vladimir Abramichev on 05/02/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenDropIn
import AdyenComponents
import UIKit

internal protocol Presenter: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}

open class AdyenIntegrationController: HasAPIClient {

    internal let payment = Payment(amount: Configuration.amount, countryCode: Configuration.countryCode)
    internal let environment = Configuration.componentsEnvironment

    internal var paymentMethods: PaymentMethods?
    internal var paymentInProgress: Bool = false
    internal var currentComponent: PresentableComponent?

    internal weak var presenter: Presenter?

    // MARK: - Networking

    internal func performPayment(with data: PaymentComponentData) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func performPaymentDetails(with data: ActionComponentData) {
        let request = PaymentDetailsRequest(details: data.details,
                                            paymentData: data.paymentData,
                                            merchantAccount: Configuration.merchantAccount)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }

    internal func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                handle(action)
            } else {
                finish(with: response.resultCode)
            }
        case let .failure(error):
            currentComponent?.stopLoading(withSuccess: false) { [weak self] in
                self?.presenter?.dismiss(completion: nil)
                self?.presentAlert(with: error)
            }
        }
    }

    internal func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending

        currentComponent?.stopLoading(withSuccess: success) { [weak self] in
            self?.presenter?.dismiss(completion: nil)
            self?.presentAlert(withTitle: resultCode.rawValue)
        }
    }

    internal func finish(with error: Error) {
        let isCancelled = ((error as? ComponentError) == .cancelled)

        presenter?.dismiss { [weak self] in
            if !isCancelled {
                self?.presentAlert(with: error)
            }
        }
    }

    // MARK: - Action handling

    open func handle(_ action: Action) {
        assertionFailure("This is abstract method. Please, provide implementation in on higher descendant.")
    }

    // MARK: - Alerts

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func presentAlert(withTitle title: String) {
        presenter?.presentAlert(withTitle: title)
    }
}
