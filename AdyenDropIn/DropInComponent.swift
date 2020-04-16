//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

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
    private lazy var componentManager = ComponentManager(paymentMethods: paymentMethods,
                                                         payment: payment,
                                                         configuration: configuration,
                                                         style: style)
    
    private lazy var rootComponent: PresentableComponent = {
        if let preselectedComponents = self.componentManager.components.stored.first {
            return preselectedPaymentMethodComponent(for: preselectedComponents)
        } else {
            return paymentMethodListComponent()
        }
    }()
    
    private lazy var actionComponent: DropInActionComponent = {
        let handler = DropInActionComponent()
        handler._isDropIn = true
        handler.environment = environment
        handler.presenterViewController = navigationController
        handler.redirectComponentStyle = style.redirectComponent
        handler.delegate = self
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
    
    private func didSelectCancelButton(isRoot: Bool, component: PaymentComponent?) {
        if isRoot || paymentInProgress {
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        } else {
            navigationController.dismiss()
        }
    }
}

/// :nodoc:
extension DropInComponent: PaymentMethodListComponentDelegate {
    
    /// :nodoc:
    internal func didSelect(_ component: PaymentComponent, in paymentMethodListComponent: PaymentMethodListComponent) {
        didSelect(component)
    }
    
}

/// :nodoc:
extension DropInComponent: PaymentComponentDelegate {
    
    /// :nodoc:
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        paymentInProgress = true
        delegate?.didSubmit(data, from: self)
        (rootComponent as? PaymentMethodListComponent)?.startLoading(for: component)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: PaymentComponent) {
        if case ComponentError.cancelled = error {
            stopLoading(withSuccess: false)
        } else {
            delegate?.didFail(with: error, from: self)
        }
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
            stopLoading(withSuccess: false)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }
    
}

extension DropInComponent: PreselectedPaymentMethodComponentDelegate {
    internal func didProceed(with component: PaymentComponent) {
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
        navigationController.present(root: paymentMethodListComponent())
    }
}

private extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}
