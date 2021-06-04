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

/**
 A component that handles the entire flow of payment selection and payment details entry.

 - SeeAlso:
 [Implementation Reference](https://docs.adyen.com/online-payments/ios/drop-in)
 */
public final class DropInComponent: NSObject, PresentableComponent {

    private var configuration: Configuration

    private var paymentInProgress: Bool = false

    private var selectedPaymentComponent: PaymentComponent?

    /// The payment methods to display.
    public private(set) var paymentMethods: PaymentMethods
    
    /// Indicates the UI configuration of the drop in component.
    public let style: Style
    
    /// The title text on the first page of drop in component.
    public let title: String

    /// :nodoc:
    public var apiContext: APIContext { configuration.apiContext }
    
    /// Initializes the drop in component.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods to display.
    ///   - configuration: The payment method specific configuration.
    ///   - style: The UI styles of the components.
    ///   - title: Name of the application. To be displayed on a firstpayment page.
    ///            If no external value provided, the Main Bundle's name would be used.
    public init(paymentMethods: PaymentMethods,
                configuration: Configuration,
                style: Style = Style(),
                title: String? = nil) {
        self.title = title ?? Bundle.main.displayName
        self.configuration = configuration
        self.paymentMethods = paymentMethods
        self.style = style
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
    public var viewController: UIViewController { navigationController }

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
        return APIClient(apiContext: apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()
    }()

    /// Reloads the DropIn with a partial payment order and a new `PaymentMethods` object.
    ///
    /// - Parameter order: The partial payment order.
    /// - Parameter paymentMethods: The new payment methods.
    /// - Throws: `PartialPaymentError.missingOrderData` in case `order.orderData` is `nil`.
    public func reload(with order: PartialPaymentOrder,
                       _ paymentMethods: PaymentMethods) throws {
        guard let orderData = order.orderData else { throw PartialPaymentError.missingOrderData }
        let request = OrderStatusRequest(orderData: orderData)
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
                                        _ remainingAmount: Amount?) -> ComponentManager {
        ComponentManager(paymentMethods: paymentMethods,
                         configuration: configuration,
                         style: style,
                         partialPaymentEnabled: partialPaymentDelegate != nil,
                         remainingAmount: remainingAmount,
                         order: order)
    }
    
    private lazy var rootComponent: PresentableComponent & ComponentLoader = {
        if let preselectedComponents = componentManager.storedComponents.first {
            return preselectedPaymentMethodComponent(for: preselectedComponents, onCancel: nil)
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
        let handler = AdyenActionComponent(apiContext: apiContext, style: style.actionComponent)
        handler._isDropIn = true
        handler.delegate = self
        handler.presentationDelegate = self
        handler.localizationParameters = configuration.localizationParameters
        return handler
    }()
    
    private func paymentMethodListComponent(onCancel: (() -> Void)?) -> PaymentMethodListComponent {
        let paymentComponents = componentManager.sections
        let component = PaymentMethodListComponent(apiContext: apiContext,
                                                   components: paymentComponents,
                                                   style: style.listComponent)
        component.onCancel = onCancel
        component.localizationParameters = configuration.localizationParameters
        component.delegate = self
        component._isDropIn = true
        return component
    }
    
    private func preselectedPaymentMethodComponent(for paymentComponent: PaymentComponent,
                                                   onCancel: (() -> Void)?) -> PreselectedPaymentMethodComponent {
        let component = PreselectedPaymentMethodComponent(component: paymentComponent,
                                                          title: title,
                                                          style: style.formComponent,
                                                          listItemStyle: style.listComponent.listItem)
        component.payment = configuration.payment
        component.localizationParameters = configuration.localizationParameters
        component.delegate = self
        component.onCancel = onCancel
        component._isDropIn = true
        return component
    }
    
    private func didSelect(_ component: PaymentComponent) {
        selectedPaymentComponent = component
        component.delegate = self
        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
        component._isDropIn = true
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
        delegate?.didOpenExternalApplication(self)
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
    public func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?) {
        let newRoot = preselectedPaymentMethodComponent(for: component, onCancel: { [weak self] in
            guard let order = order else { return }
            self?.partialPaymentDelegate?.cancelOrder(order)
        })
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
