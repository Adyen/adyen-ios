//
// Copyright (c) 2021 Adyen N.V.
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
#if canImport(AdyenCard)
    import AdyenCard
#endif
import UIKit

/// A component that handles the entire flow of payment selection and payment details entry.
public final class DropInComponent: NSObject, PresentableComponent {

    private var configuration: PaymentMethodsConfiguration

    private var paymentInProgress: Bool = false

    private var selectedPaymentComponent: PaymentComponent?

    /// The payment methods to display.
    public private(set) var paymentMethods: PaymentMethods
    
    /// Indicates the UI configuration of the drop in component.
    public let style: Style
    
    /// The title text on the first page of drop in component.
    public let title: String

    /// :nodoc:
    public let environment: Environment

    /// :nodoc:
    public let clientKey: String?
    
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
        self.clientKey = configuration.clientKey
        self.environment = configuration.environment
        super.init()
    }

    // MARK: - Delegates

    /// The delegate of the drop in component.
    public weak var delegate: DropInComponentDelegate?

    /// The partial payment flow delegate.
    public weak var partialPaymentDelegate: PartialPaymentDelegate?

    /// The delegate for user activity on card component.
    public weak var cardComponentDelegate: CardComponentDelegate?
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        navigationController
    }

    // MARK: - Handling Actions

    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        rootComponent.stopLoadingIfNeeded()
        actionComponent.handle(action)
    }

    // MARK: - Handling Partial Payments

    /// :nodoc:
    private lazy var apiClient: APIClientProtocol = {
        let scheduler = SimpleScheduler(maximumCount: 3)
        let baseAPIClient = APIClient(environment: configuration.environment)
        let retryApiClient = RetryAPIClient(apiClient: baseAPIClient, scheduler: scheduler)
        let apiClient = RetryOnErrorAPIClient(apiClient: retryApiClient)
        return apiClient
    }()

    /// Handles a partial payment.
    ///
    /// - Parameter order: The partial payment order.
    /// - Parameter paymentMethods: The new payment methods.
    public func reload(with order: PartialPaymentOrder,
                       _ paymentMethods: PaymentMethods) {
        let request = OrderStatusRequest(orderData: order.orderData)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result, order)
        }
    }

    private func handle(_ result: Result<OrderStatusResponse, Error>, _ order: PartialPaymentOrder) {
        result.handle(success: {
            self.handle($0, order)
        }, failure: {
            self.delegate?.didFail(with: $0, from: self)
        })
    }

    private func handle(_ response: OrderStatusResponse, _ order: PartialPaymentOrder) {
        guard response.remainingAmount.value > 0 else {
            delegate?.didFail(with: PartialPaymentError.zeroRemainingAmount, from: self)
            return
        }
        paymentMethods.paid = response.paymentMethods ?? []
        componentManager = createComponentManager(order, response.remainingAmount)
        paymentInProgress = false
        showPaymentMethodsList(onCancel: { [weak self] in
            self?.partialPaymentDelegate?.cancelOrder(order)
        })
    }
    
    // MARK: - Private

    private lazy var componentManager = createComponentManager(nil, nil)

    private func createComponentManager(_ order: PartialPaymentOrder?,
                                        _ remainingAmount: Payment.Amount?) -> ComponentManager {
        ComponentManager(paymentMethods: paymentMethods,
                         configuration: configuration,
                         style: style,
                         partialPaymentEnabled: partialPaymentDelegate != nil,
                         remainingAmount: remainingAmount,
                         order: order)
    }
    
    private lazy var rootComponent: PresentableComponent & ComponentLoader = {
        if let preselectedComponents = componentManager.storedComponents.first {
            return preselectedPaymentMethodComponent(for: preselectedComponents)
        } else {
            return paymentMethodListComponent(onCancel: nil)
        }
    }()
    
    private lazy var navigationController = DropInNavigationController(rootComponent: rootComponent,
                                                                       style: style.navigation,
                                                                       cancelHandler: { [weak self] isRoot, component in
                                                                           self?.didSelectCancelButton(isRoot: isRoot,
                                                                                                       component: component)
                                                                       })

    private lazy var actionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent()
        handler._isDropIn = true
        handler.environment = environment
        handler.clientKey = configuration.clientKey
        handler.redirectComponentStyle = style.redirectComponent
        handler.delegate = self
        handler.presentationDelegate = self
        handler.localizationParameters = configuration.localizationParameters
        return handler
    }()
    
    private func paymentMethodListComponent(onCancel: (() -> Void)?) -> PaymentMethodListComponent {
        let paymentComponents = componentManager.sections
        let component = PaymentMethodListComponent(components: paymentComponents, style: style.listComponent)
        component.onCancel = onCancel
        component.localizationParameters = configuration.localizationParameters
        component.delegate = self
        component._isDropIn = true
        component.environment = environment
        return component
    }
    
    private func preselectedPaymentMethodComponent(for paymentComponent: PaymentComponent) -> PreselectedPaymentMethodComponent {
        let component = PreselectedPaymentMethodComponent(component: paymentComponent,
                                                          title: title,
                                                          style: style.formComponent,
                                                          listItemStyle: style.listComponent.listItem)
        component.payment = configuration.payment
        component.localizationParameters = configuration.localizationParameters
        component.delegate = self
        component._isDropIn = true
        component.environment = environment
        return component
    }
    
    private func didSelect(_ component: PaymentComponent) {
        selectedPaymentComponent = component
        component.delegate = self
        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
        component._isDropIn = true
        component.environment = environment
        component.payment = configuration.payment
        
        switch component {
        case let component as PreApplePayComponent:
            component.presentationDelegate = self
            navigationController.present(asModal: component)
        case let component as PresentableComponent where component.requiresModalPresentation:
            navigationController.present(asModal: component)
        case let component as PresentableComponent where component.viewController is UIAlertController:
            navigationController.present(component.viewController, customPresentation: false)
        case let component as PresentableComponent:
            navigationController.present(component.viewController, customPresentation: true)
        case let component as InstantPaymentComponent:
            component.initiatePayment()
        default:
            break
        }
    }
    
    private func didSelectCancelButton(isRoot: Bool, component: PresentableComponent) {
        guard !paymentInProgress || component is Cancellable else { return }

        userDidCancel(component)
        
        if isRoot {
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        } else {
            navigationController.popViewController(animated: true)
        }
    }

    private func userDidCancel(_ component: Component) {
        stopLoading()
        component.cancelIfNeeded()

        if let component = (component as? PaymentComponent) ?? selectedPaymentComponent, paymentInProgress {
            delegate?.didCancel(component: component, from: self)
        }

        paymentInProgress = false
    }

    /// :nodoc:
    private func stopLoading() {
        rootComponent.stopLoading()
        selectedPaymentComponent?.stopLoadingIfNeeded()
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
        delegate?.didSubmit(data, for: component.paymentMethod, from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: PaymentComponent) {
        if case ComponentError.cancelled = error {
            userDidCancel(component)
        } else {
            delegate?.didFail(with: error, from: self)
        }
    }

}

/// :nodoc:
extension DropInComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didOpenExternalApplication(_ component: ActionComponent) {
        stopLoading()
    }

    /// :nodoc:
    public func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: ActionComponent) {
        if case ComponentError.cancelled = error {
            userDidCancel(component)
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
        rootComponent.startLoading(for: component)
        didSelect(component)
    }
    
    internal func didRequestAllPaymentMethods() {
        showPaymentMethodsList(onCancel: nil)
    }

    private func showPaymentMethodsList(onCancel: (() -> Void)?) {
        let newList = paymentMethodListComponent(onCancel: onCancel)
        navigationController.present(root: newList)
        rootComponent = newList
    }
}

extension DropInComponent: PresentationDelegate {

    /// :nodoc:
    public func present(component: PresentableComponent) {
        navigationController.present(asModal: component)
    }
}

extension DropInComponent: FinalizableComponent {

    /// Stops loading and finalise DropIn's selected payment if nececery.
    /// This method must be called after certan payment methods (e.x. ApplePay)
    /// - Parameter success: Status of the payment.
    public func didFinalize(with success: Bool) {
        stopLoading()
        selectedPaymentComponent?.finalizeIfNeeded(with: success)
    }
}

extension DropInComponent: ReadyToSubmitPaymentComponentDelegate {

    /// :nodoc:
    public func showConfirmation(for component: InstantPaymentComponent) {
        let newRoot = preselectedPaymentMethodComponent(for: component)
        navigationController.present(root: newRoot)
        rootComponent = newRoot
    }
}

private extension Bundle {

    // Name of the app - title under the icon.
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

}
