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
        
        // Load payment methods from json file. This should be requested to /paymentMethods endpoint via merchant backend
        if let path = Bundle.main.path(forResource: "PaymentMethods", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            self.paymentMethods = try? Coder.decode(data) as PaymentMethods
        }
    }
    
    // MARK: - Components
    
    private var paymentMethods: PaymentMethods?
    private var currentComponent: Component?
    private var redirectComponent: RedirectComponent?
    private var threeDS2Component: ThreeDS2Component?
    
    private func present(_ component: PresentableComponent) {
        component.environment = .test
        component.payment = Payment(amount: amount)
        
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
        configuration.card.publicKey = cardPublicKey
        
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        paymentMethodsConfiguration: configuration)
        component.delegate = self
        present(component)
    }
    
    private func presentCardComponent() {
        guard let paymentMethod = paymentMethods?.paymentMethod(ofType: CardPaymentMethod.self) else { return }
        let component = CardComponent(paymentMethod: paymentMethod, publicKey: cardPublicKey)
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
    
    private func finish() {
        dismiss(animated: true) {
            self.presentAlert(withTitle: "Finished")
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
        // Should call /payment via merchant backend
        finish()
    }
    
    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        // Should call /payment/details via merchant backend
        finish()
    }
    
    internal func didFail(with error: Error, from component: DropInComponent) {
        finish(with: error)
    }
    
}

extension ComponentsViewController: PaymentComponentDelegate {
    
    internal func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        // Should call /payment via merchant backend
        finish()
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
        // Should call /payment/details via merchant backend
        finish()
    }
}
