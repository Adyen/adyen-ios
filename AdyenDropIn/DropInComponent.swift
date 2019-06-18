//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A component that handles the entire flow of payment selection and payment details entry.s
public final class DropInComponent: PresentableComponent {
    
    /// The payment methods to display.
    public let paymentMethods: PaymentMethods
    
    /// The delegate of the drop in component.
    public weak var delegate: DropInComponentDelegate?
    
    /// Initializes the drop in component.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods to display.
    ///   - paymentMethodsConfiguration: The payment method specific configuration.
    public init(paymentMethods: PaymentMethods,
                paymentMethodsConfiguration: PaymentMethodsConfiguration) {
        self.configuration = paymentMethodsConfiguration
        self.paymentMethods = paymentMethods
    }
    
    // MARK: - Handling Actions
    
    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        switch action {
        case let .redirect(redirectAction):
            presentRedirectComponent(with: redirectAction)
        case let .threeDS2Fingerprint(fingerprintAction):
            performThreeDS2Fingerprint(with: fingerprintAction)
        case let .threeDS2Challenge(challengeAction):
            performThreeDS2Challenge(with: challengeAction)
        }
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: componentName, flavor: .dropin, environment: environment)
        return ComponentViewController(rootViewController: listViewController, cancelButtonHandler: didSelectCancelButton)
    }()
    
    // MARK: - Private
    
    private let componentName = "dropin"
    private let configuration: PaymentMethodsConfiguration
    
    private var redirectComponent: RedirectComponent?
    private var threeDS2Component: ThreeDS2Component?
    private var selectedPaymentComponent: PaymentComponent?
    
    private lazy var componentManager = ComponentManager(paymentMethods: paymentMethods, configuration: configuration)
    private lazy var components = componentManager.components
    
    private lazy var listViewController: ListViewController = {
        func itemsMapping(_ component: PaymentComponent) -> ListItem {
            let showsDisclosureIndicator = !(component is EmptyPaymentComponent) && !(component.paymentMethod is StoredPaymentMethod)
            
            var listItem = ListItem(title: component.paymentMethod.displayName)
            listItem.imageURL = LogoURLProvider.logoURL(for: component.paymentMethod, environment: environment)
            listItem.showsDisclosureIndicator = showsDisclosureIndicator
            listItem.selectionHandler = { [unowned self] in
                self.didSelect(component: component)
            }
            
            return listItem
        }
        
        let storedSection = ListSection(items: components.stored.map(itemsMapping))
        let regularSectionTitle = components.stored.isEmpty ? nil : ADYLocalizedString("adyen.paymentMethods.otherMethods")
        let regularSection = ListSection(title: regularSectionTitle, items: components.regular.map(itemsMapping))
        
        let listViewController = ListViewController()
        listViewController.title = ADYLocalizedString("adyen.paymentMethods.title")
        listViewController.sections = [storedSection, regularSection]
        
        return listViewController
    }()
    
    private func presentRedirectComponent(with action: RedirectAction) {
        let redirectComponent = RedirectComponent(action: action)
        redirectComponent.delegate = self
        redirectComponent._isDropIn = true
        redirectComponent.environment = environment
        self.redirectComponent = redirectComponent
        
        listViewController.navigationController?.present(redirectComponent.viewController, animated: true)
    }
    
    private func performThreeDS2Fingerprint(with action: ThreeDS2FingerprintAction) {
        let threeDS2Component = ThreeDS2Component()
        threeDS2Component._isDropIn = true
        threeDS2Component.delegate = self
        threeDS2Component.environment = environment
        self.threeDS2Component = threeDS2Component
        
        threeDS2Component.handle(action)
    }
    
    private func performThreeDS2Challenge(with action: ThreeDS2ChallengeAction) {
        guard let threeDS2Component = threeDS2Component else { return }
        threeDS2Component.handle(action)
    }
    
    private func didSelect(component: PaymentComponent) {
        selectedPaymentComponent = component
        component.delegate = self
        component._isDropIn = true
        component.environment = environment
        
        if let presentableComponent = component as? PresentableComponent {
            presentableComponent.payment = payment
            
            if presentableComponent.viewController is UIAlertController {
                listViewController.present(presentableComponent.viewController, animated: true)
            } else {
                listViewController.navigationController?.pushViewController(presentableComponent.viewController, animated: true)
            }
        }
        
        if let emptyComponent = component as? EmptyPaymentComponent {
            emptyComponent.generateDetails()
        }
    }
    
    private lazy var didSelectCancelButton: (() -> Void) = { [weak self] in
        guard let self = self else { return }
        
        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
}

/// :nodoc:
extension DropInComponent: PaymentComponentDelegate {
    
    /// :nodoc:
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        delegate?.didSubmit(data, from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: PaymentComponent) {
        if let error = error as? ComponentError, error == .cancelled {
            return
        }
        
        delegate?.didFail(with: error, from: self)
    }
    
}

/// :nodoc:
extension DropInComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didFail(with error: Error, from component: ActionComponent) {
        if case ComponentError.cancelled = error, let presentableComponent = selectedPaymentComponent as? PresentableComponent {
            presentableComponent.stopLoading()
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }
    
}
