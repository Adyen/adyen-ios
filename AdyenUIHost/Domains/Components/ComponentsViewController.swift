//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import AdyenDropIn
import UIKit

internal final class ComponentsViewController: UIViewController {
    
    private lazy var componentsView = ComponentsView()
    private let payment = Payment(amount: Configuration.amount, countryCode: Configuration.countryCode)
    private let environment: Environment = .test
    
    private var paymentMethods: PaymentMethods?
    private var currentComponent: PresentableComponent?
    private var paymentInProgress: Bool = false
    
    // MARK: - View
    
    internal override func loadView() {
        view = componentsView
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Components"
        
        componentsView.items = [
            [
                ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent)
            ],
            [
                ComponentsItem(title: "Card", selectionHandler: presentCardComponent),
                ComponentsItem(title: "iDEAL", selectionHandler: presentIdealComponent),
                ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent)
            ]
        ]
        
        requestPaymentMethods()
    }
    
    // MARK: - Components
    
    private lazy var actionComponent: DropInActionComponent = {
        let handler = DropInActionComponent()
        handler.presenterViewController = self
        handler.redirectComponentStyle = dropInComponentStyle.redirectComponent
        handler.delegate = self
        return handler
    }()
    
    private func present(_ component: PresentableComponent) {
        component.environment = environment
        component.payment = payment
        
        if let paymentComponent = component as? PaymentComponent {
            paymentComponent.delegate = self
        }
        
        if let actionComponent = component as? ActionComponent {
            actionComponent.delegate = self
        }
        
        currentComponent = component
        guard component.requiresModalPresentation else {
            return present(component.viewController, animated: true)
        }
        
        let navigation = UINavigationController(rootViewController: component.viewController)
        component.viewController.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                          target: self,
                                                                          action: #selector(cancelDidPress))
        present(navigation, animated: true)
    }
    
    @objc private func cancelDidPress() {
        guard let paymentComponent = self.currentComponent as? PaymentComponent else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        paymentComponent.delegate?.didFail(with: ComponentError.cancelled, from: paymentComponent)
    }
    
    // MARK: - DropIn Component
    
    private lazy var dropInComponentStyle: DropInComponent.Style = DropInComponent.Style()
    
    private func presentDropInComponent() {
        guard let paymentMethods = paymentMethods else { return }
        let configuration = DropInComponent.PaymentMethodsConfiguration()
        configuration.card.publicKey = Configuration.cardPublicKey
        configuration.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        configuration.applePay.summaryItems = Configuration.applePaySummaryItems
        configuration.localizationParameters = nil
        
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        paymentMethodsConfiguration: configuration,
                                        style: dropInComponentStyle,
                                        title: Configuration.appName)
        component.delegate = self
        present(component)
    }
    
    private func presentCardComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: CardPaymentMethod.self) else { return }
        let component = CardComponent(paymentMethod: paymentMethod,
                                      publicKey: Configuration.cardPublicKey,
                                      style: dropInComponentStyle.formComponent)
        present(component)
    }
    
    private func presentIdealComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return }
        let component = IdealComponent(paymentMethod: paymentMethod,
                                       style: dropInComponentStyle.listComponent)
        present(component)
    }
    
    private func presentSEPADirectDebitComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return }
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                                 style: dropInComponentStyle.formComponent)
        component.delegate = self
        present(component)
    }
    
    // MARK: - Networking
    
    private lazy var apiClient = RetryAPIClient(apiClient: APIClient(environment: Configuration.environment))
    
    private func requestPaymentMethods() {
        let request = PaymentMethodsRequest()
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                self.paymentMethods = response.paymentMethods
            case let .failure(error):
                self.presentAlert(with: error, retryHandler: self.requestPaymentMethods)
            }
        }
    }
    
    private func performPayment(with data: PaymentComponentData) {
        let request = PaymentsRequest(data: data)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }
    
    private func performPaymentDetails(with data: ActionComponentData) {
        let request = PaymentDetailsRequest(details: data.details, paymentData: data.paymentData)
        apiClient.perform(request, completionHandler: paymentResponseHandler)
    }
    
    private func paymentResponseHandler(result: Result<PaymentsResponse, Error>) {
        switch result {
        case let .success(response):
            if let action = response.action {
                handle(action)
            } else {
                finish(with: response.resultCode)
            }
        case let .failure(error):
            currentComponent?.stopLoading(withSuccess: false) { [weak self] in
                self?.presentAlert(with: error)
            }
        }
    }
    
    private func handle(_ action: Action) {
        guard paymentInProgress else { return }
        
        if let dropInComponent = currentComponent as? DropInComponent {
            return dropInComponent.handle(action)
        }
        
        actionComponent.perform(action)
    }
    
    private func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending
        
        currentComponent?.stopLoading(withSuccess: success) { [weak self] in
            self?.dismiss(animated: true) {
                self?.presentAlert(withTitle: resultCode.rawValue)
            }
        }
    }
    
    private func finish(with error: Error) {
        let isCancelled = ((error as? ComponentError) == .cancelled)
        
        dismiss(animated: true) {
            if !isCancelled {
                self.presentAlert(with: error)
            }
        }
    }
    
    private func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        adyen.topPresenter.present(alertController, animated: true)
    }
    
    private func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        adyen.topPresenter.present(alertController, animated: true)
    }
}

extension ComponentsViewController: DropInComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
        performPayment(with: data)
        paymentInProgress = true
    }
    
    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        performPaymentDetails(with: data)
    }
    
    internal func didFail(with error: Error, from component: DropInComponent) {
        paymentInProgress = false
        finish(with: error)
    }
    
}

extension ComponentsViewController: PaymentComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        performPayment(with: data)
    }
    
    internal func didFail(with error: Error, from component: PaymentComponent) {
        paymentInProgress = false
        finish(with: error)
    }
    
}

extension ComponentsViewController: ActionComponentDelegate {
    
    internal func didFail(with error: Error, from component: ActionComponent) {
        paymentInProgress = false
        finish(with: error)
    }
    
    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        performPaymentDetails(with: data)
    }
}
