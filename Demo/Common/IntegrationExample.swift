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

internal protocol Presenter: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}

internal final class IntegrationExample: APIClientAware {
    
    internal var payment: Payment { ConfigurationConstants.current.payment }

    internal var paymentMethods: PaymentMethods?
    internal var currentComponent: PresentableComponent?

    internal weak var presenter: Presenter?
    
    internal lazy var palApiClient: APIClientProtocol = {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }()

    // MARK: - Action Handling for Components

    internal lazy var adyenActionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(adyenContext: ConfigurationConstants.adyenContext)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Networking

    internal func requestPaymentMethods(order: PartialPaymentOrder? = nil,
                                        completion: ((PaymentMethods) -> Void)? = nil) {
        let request = PaymentMethodsRequest(order: order)
        apiClient.perform(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.paymentMethods = response.paymentMethods
                completion?(response.paymentMethods)
            case let .failure(error):
                self.presentAlert(with: error) { [weak self] in
                    self?.requestPaymentMethods(order: order, completion: completion)
                }
            }
        }
    }

    internal func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending
        currentComponent?.finalizeIfNeeded(with: success) { [weak self] in
            guard let self = self else { return }
            self.presenter?.dismiss {
                // Payment is processed. Add your code here.
                self.presentAlert(withTitle: resultCode.rawValue)
            }
        }
    }

    internal func finish(with error: Error) {
        currentComponent?.finalizeIfNeeded(with: false) { [weak self] in
            guard let self = self else { return }
            self.presenter?.dismiss {
                // Payment is unsuccessful. Add your code here.
                if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
                    self.presentAlert(withTitle: "Cancelled")
                } else {
                    self.presentAlert(with: error)
                }
            }
        }
    }

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func presentAlert(withTitle title: String) {
        presenter?.presentAlert(withTitle: title)
    }

    // MARK: - BACS Direct Debit Component

    internal var bacsDirectDebitPresenter: BACSDirectDebitPresentationDelegate?
}
