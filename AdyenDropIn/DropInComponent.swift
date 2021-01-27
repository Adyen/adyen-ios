//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    import AdyenActions
#endif
import UIKit

/// A component that handles the entire flow of payment selection and payment details entry.
public final class DropInComponent: NSObject, PresentableComponent {
    
    /// The payment methods to display.
    public let paymentMethods: PaymentMethods
    
    /// The delegate of the drop in component.
    public weak var delegate: DropInComponentDelegate?
    
    /// Indicates the UI configuration of the drop in component.
    public let style: Style
    
    /// The title text on the first page of drop in component.
    public let title: String
    
    /// Initializes the drop in component.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods to display.
    ///   - paymentMethodsConfiguration: The payment method specific configuration.
    ///   - style: The UI styles of the components.
    ///   - title: Name of the application. To be displayed on a firstpayment page.
    ///            If no external value provided, the Main Bundle's name would be used.
    public init(paymentMethods: PaymentMethods,
                paymentMethodsConfiguration: PaymentMethodsConfiguration,
                style: Style = Style(),
                title: String? = nil) {
        self.title = title ?? Bundle.main.displayName
        self.configuration = paymentMethodsConfiguration
        self.paymentMethods = paymentMethods
        self.style = style
        super.init()
        self.environment = configuration.environment
    }
    
    // MARK: - Handling Actions
    
    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        actionComponent.perform(action)
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        navigationController
    }
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        paymentInProgress = false
        let rootComponent = self.rootComponent
        if let topComponent = selectedPaymentComponent as? PresentableComponent {
            topComponent.stopLoading(withSuccess: success) {
                rootComponent.stopLoading(withSuccess: success, completion: completion)
            }
        } else {
            rootComponent.stopLoading(withSuccess: success, completion: completion)
        }
    }
    
    // MARK: - Private
    
    private let componentName = "dropin"
    private let configuration: PaymentMethodsConfiguration
    private var paymentInProgress: Bool = false
    private var selectedPaymentComponent: PaymentComponent?
    private lazy var componentManager: ComponentManager = {
        let manager = ComponentManager(paymentMethods: self.paymentMethods,
                                       payment: self.payment,
                                       configuration: self.configuration,
                                       style: self.style)
        
        manager.environment = environment
        return manager
    }()
    
    private lazy var rootComponent: LoadingComponent = {
        if let preselectedComponents = self.componentManager.components.stored.first {
            return preselectedPaymentMethodComponent(for: preselectedComponents)
        } else {
            return paymentMethodListComponent()
        }
    }()
    
    private lazy var actionComponent: AdyenActionHandler = {
        let handler = AdyenActionHandler()
        handler._isDropIn = true
        handler.environment = environment
        handler.clientKey = configuration.clientKey
        handler.redirectComponentStyle = style.redirectComponent
        handler.delegate = self
        handler.presentationDelegate = self
        handler.localizationParameters = configuration.localizationParameters
        return handler
    }()
    
    private lazy var navigationController: DropInNavigationController = {
        DropInNavigationController(rootComponent: self.rootComponent,
                                   style: style.navigation,
                                   cancelHandler: { [weak self] isRoot, component in
                                       self?.didSelectCancelButton(isRoot: isRoot, component: component)
                                   })
    }()
    
    private func paymentMethodListComponent() -> PaymentMethodListComponent {
        let paymentMethodListComponent = PaymentMethodListComponent(components: componentManager.components,
                                                                    style: style.listComponent)
        paymentMethodListComponent.localizationParameters = configuration.localizationParameters
        paymentMethodListComponent.delegate = self
        paymentMethodListComponent._isDropIn = true
        paymentMethodListComponent.environment = environment
        
        return paymentMethodListComponent
    }
    
    private func preselectedPaymentMethodComponent(for storedPaymentComponent: PaymentComponent) -> PreselectedPaymentMethodComponent {
        let component = PreselectedPaymentMethodComponent(component: storedPaymentComponent,
                                                          title: self.title,
                                                          style: self.style.formComponent,
                                                          listItemStyle: self.style.listComponent.listItem)
        component.payment = payment
        component.localizationParameters = configuration.localizationParameters
        component.delegate = self
        component._isDropIn = true
        component.environment = environment
        
        return component
    }
    
    private func didSelect(_ component: PaymentComponent) {
        selectedPaymentComponent = component
        component.delegate = self
        component._isDropIn = true
        component.environment = environment
        
        if let presentableComponent = component as? PresentableComponent {
            presentableComponent.payment = payment
        }
        
        switch component {
        case let component as PresentableComponent where component.requiresModalPresentation:
            navigationController.present(asModal: component)
        case let component as PresentableComponent:
            let exceptions = (component.viewController is UIAlertController) || (component is ApplePayComponent)
            navigationController.present(component.viewController, customPresentation: !exceptions)
        case let component as EmptyPaymentComponent:
            component.initiatePayment()
        default:
            break
        }
    }
    
    private func didSelectCancelButton(isRoot: Bool, component: PresentableComponent) {
        guard !paymentInProgress else { return }
        
        component.didCancel()
        
        if isRoot {
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        } else {
            navigationController.popViewController(animated: true)
            stopLoading()
            delegate?.didCancel(component: component, from: self)
        }
    }
}

/// :nodoc:
extension DropInComponent: PaymentMethodListComponentDelegate {
    
    /// :nodoc:
    internal func didSelect(_ component: PaymentComponent, in paymentMethodListComponent: PaymentMethodListComponent) {
        rootComponent.startLoading(for: component)
        didSelect(component)
    }
    
}

/// :nodoc:
extension DropInComponent: PaymentComponentDelegate {
    
    /// :nodoc:
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        delegate?.didSubmit(data, from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: PaymentComponent) {
        paymentInProgress = false
        if case ComponentError.cancelled = error {
            stopLoading(withSuccess: false)
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    private func userDidCancel(_ component: PaymentComponent) {
        guard let component = component as? PresentableComponent else { return }
        delegate?.didCancel(component: component, from: self)
    }
}

/// :nodoc:
extension DropInComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didOpenExternalApplication(_ component: ActionComponent) {
        stopLoading(withSuccess: true)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: ActionComponent) {
        if case ComponentError.cancelled = error {
            paymentInProgress = false
            stopLoading(withSuccess: false)
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    private func userDidCancel(_ component: ActionComponent) {
        guard let component = component as? PresentableComponent else { return }
        delegate?.didCancel(component: component, from: self)
    }
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }
    
}

extension DropInComponent: PreselectedPaymentMethodComponentDelegate {
    internal func didProceed(with component: PaymentComponent) {
        rootComponent.startLoading(for: component)
        
        guard let storedPaymentMethod = component.paymentMethod as? StoredPaymentMethod else {
            return didSelect(component)
        }
        
        if storedPaymentMethod is StoredCardPaymentMethod {
            return didSelect(component)
        }
        
        let details = StoredPaymentDetails(paymentMethod: storedPaymentMethod)
        self.delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
    }
    
    internal func didRequestAllPaymentMethods() {
        let newRoot = paymentMethodListComponent()
        navigationController.present(root: newRoot)
        rootComponent = newRoot
    }
}

extension DropInComponent: PresentationDelegate {
    public func present(component: PresentableComponent, disableCloseButton: Bool) {
        paymentInProgress = disableCloseButton
        navigationController.present(asModal: component)
    }
}

private extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}
