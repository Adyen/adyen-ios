//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import AdyenDropIn
import UIKit

internal final class ComponentsViewController: UIViewController {
    
    internal init() {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = "Components"
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    
    private lazy var componentsView = ComponentsView()
    
    internal override func loadView() {
        view = componentsView
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        componentsView.items = [
            ComponentsItem(title: "Drop In", selectionHandler: presentDropInComponent),
            ComponentsItem(title: "Card", selectionHandler: presentCardComponent),
            ComponentsItem(title: "iDEAL", selectionHandler: presentIdealComponent),
            ComponentsItem(title: "SEPA Direct Debit", selectionHandler: presentSEPADirectDebitComponent)
        ]
        
        requestPaymentMethods()
    }
    
    // MARK: - Components
    
    private var paymentMethods: PaymentMethods?
    private var currentComponent: PresentableComponent?
    private var redirectComponent: RedirectComponent?
    private var threeDS2Component: ThreeDS2Component?
    
    private func present(_ component: PresentableComponent) {
        component.environment = .test
        component.payment = Payment(amount: Configuration.amount)
        component.payment?.countryCode = "NL"
        
        if let paymentComponent = component as? PaymentComponent {
            paymentComponent.delegate = self
        }
        
        if let actionComponent = component as? ActionComponent {
            actionComponent.delegate = self
        }
        
        present(component.viewController, animated: true)
        
        currentComponent = component
    }
    
    private func presentDropInComponent() {
        guard let paymentMethods = paymentMethods else { return }
        let configuration = DropInComponent.PaymentMethodsConfiguration()
        configuration.card.publicKey = Configuration.cardPublicKey
        configuration.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        configuration.applePay.summaryItems = Configuration.applePaySummaryItems
        
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        paymentMethodsConfiguration: configuration)
        component.delegate = self
        present(component)
    }
    
    private func presentCardComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: CardPaymentMethod.self) else { return }
        let component = CardComponent(paymentMethod: paymentMethod, publicKey: Configuration.cardPublicKey)
        present(component)
    }
    
    private func presentIdealComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: IssuerListPaymentMethod.self) else { return }
        let component = IdealComponent(paymentMethod: paymentMethod)
        present(component)
    }
    
    private func presentSEPADirectDebitComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: SEPADirectDebitPaymentMethod.self) else { return }
        let component = SEPADirectDebitComponent(paymentMethod: paymentMethod)
        component.delegate = self
        present(component)
    }
    
    // MARK: - Networking
    
    private lazy var apiClient = APIClient(environment: Configuration.environment)
    
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
        if let dropInComponent = currentComponent as? DropInComponent {
            dropInComponent.handle(action)
            
            return
        }
        
        switch action {
        case let .redirect(redirectAction):
            redirect(with: redirectAction)
        case let .threeDS2Fingerprint(threeDS2FingerprintAction):
            performThreeDS2Fingerprint(with: threeDS2FingerprintAction)
        case let .threeDS2Challenge(threeDS2ChallengeAction):
            performThreeDS2Challenge(with: threeDS2ChallengeAction)
        }
    }
    
    private func redirect(with action: RedirectAction) {
        let redirectComponent = RedirectComponent(action: action)
        redirectComponent.delegate = self
        self.redirectComponent = redirectComponent
        
        (presentedViewController ?? self).present(redirectComponent.viewController, animated: true)
    }
    
    private func performThreeDS2Fingerprint(with action: ThreeDS2FingerprintAction) {
        let threeDS2Component = ThreeDS2Component()
        threeDS2Component.delegate = self
        self.threeDS2Component = threeDS2Component
        
        threeDS2Component.handle(action)
    }
    
    private func performThreeDS2Challenge(with action: ThreeDS2ChallengeAction) {
        guard let threeDS2Component = threeDS2Component else { return }
        threeDS2Component.handle(action)
    }
    
    private func finish(with resultCode: PaymentsResponse.ResultCode) {
        let success = resultCode == .authorised || resultCode == .received || resultCode == .pending
        
        currentComponent?.stopLoading(withSuccess: success) { [weak self] in
            self?.dismiss(animated: true) {
                self?.presentAlert(withTitle: resultCode.rawValue)
            }
        }
        
        redirectComponent = nil
        threeDS2Component = nil
    }
    
    private func finish(with error: Error) {
        let isCancelled = ((error as? ComponentError) == .cancelled)
        
        dismiss(animated: true) {
            if !isCancelled {
                self.presentAlert(with: error)
            }
        }
        
        redirectComponent = nil
        threeDS2Component = nil
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
        
        (presentedViewController ?? self).present(alertController, animated: true)
    }
    
    private func presentAlert(withTitle title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        (presentedViewController ?? self).present(alertController, animated: true)
    }
    
}

extension ComponentsViewController: DropInComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
        performPayment(with: data)
    }
    
    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        performPaymentDetails(with: data)
    }
    
    internal func didFail(with error: Error, from component: DropInComponent) {
        finish(with: error)
    }
    
}

extension ComponentsViewController: PaymentComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        performPayment(with: data)
    }
    
    internal func didFail(with error: Error, from component: PaymentComponent) {
        finish(with: error)
    }
    
}

extension ComponentsViewController: ActionComponentDelegate {
    
    internal func didFail(with error: Error, from component: ActionComponent) {
        finish(with: error)
    }
    
    internal func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        performPaymentDetails(with: data)
    }
}
