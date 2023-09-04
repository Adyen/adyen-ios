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

protocol Presenter: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}

final class IntegrationExample: APIClientAware {
    
    var payment: Payment { ConfigurationConstants.current.payment }

    var paymentMethods: PaymentMethods?
    var currentComponent: PresentableComponent?

    weak var presenter: Presenter?
    
    lazy var palApiClient: APIClientProtocol = {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }()

    var clientKey: String {
        if CommandLine.arguments.contains("-UITests") {
            return "local_DUMMYKEYFORTESTING"
        }
        return ConfigurationConstants.clientKey
    }
    
    lazy var apiContext = APIContext(
        environment: ConfigurationConstants.componentsEnvironment,
        clientKey: clientKey
    )

    // MARK: - Action Handling for Components

    lazy var actionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(apiContext: apiContext)
        handler.delegate = self
        handler.presentationDelegate = self
        return handler
    }()

    // MARK: - Networking

    func requestPaymentMethods(order: PartialPaymentOrder? = nil,
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

    func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending
        currentComponent?.finalizeIfNeeded(with: success) { [weak self] in
            self?.presenter?.dismiss { [weak self] in
                // Payment is processed. Add your code here.
                self?.presentAlert(withTitle: resultCode.rawValue)
            }
        }
    }

    func finish(with error: Error) {
        currentComponent?.finalizeIfNeeded(with: false, completion: { [weak self] in
            self?.presenter?.dismiss { [weak self] in
                // Payment is unsuccessful. Add your code here.
                if let componentError = (error as? ComponentError), componentError == ComponentError.cancelled {
                    self?.presentAlert(withTitle: "Cancelled")
                } else {
                    self?.presentAlert(with: error)
                }
            }
        })
    }

    func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    func presentAlert(withTitle title: String) {
        presenter?.presentAlert(withTitle: title)
    }

    // MARK: - BACS Direct Debit Component

    var bacsDirectDebitPresenter: BACSDirectDebitPresentationDelegate?
}
