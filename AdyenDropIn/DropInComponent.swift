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

    private let configuration: PaymentMethodsConfiguration

    private var paymentInProgress: Bool = false

    private var selectedPaymentComponent: PaymentComponent?

    private var order: PartialPaymentOrder?

    /// The payment methods to display.
    public private(set) var paymentMethods: PaymentMethods
    
    /// The delegate of the drop in component.
    public weak var delegate: DropInComponentDelegate?

    /// The gift card component delegate.
    public weak var partialPaymentDelegate: PartialPaymentDelegate?
    
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
    }
    
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
        actionComponent.handle(action)
    }

    // MARK: - Handling Partial Payments

    /// :nodoc:
    private lazy var apiClient: APIClientProtocol = {
        let scheduler = SimpleScheduler(maximumCount: 3)
        let baseAPIClient = APIClient(environment: environment)
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
        let paymentMethod1 = OrderPaymentMethod(lastFour: "1234", type: "giftcard", transactionLimit: .init(value: 100, currencyCode: "CAD"), amount: .init(value: 200, currencyCode: "CAD"))
        let paymentMethod2 = OrderPaymentMethod(lastFour: "3455", type: "giftcard", transactionLimit: .init(value: 100, currencyCode: "CAD"), amount: .init(value: 100, currencyCode: "CAD"))
        let result = OrderStatusResponse(remainingAmount: .init(value: 7408, currencyCode: "CAD"), paymentMethods: [paymentMethod1, paymentMethod2])
        handle(result)
//        let request = OrderStatusRequest(orderData: order.orderData)
//        apiClient.perform(request) { [weak self] result in
//            self?.handle(result)
//        }
    }

    private func handle(_ result: Result<OrderStatusResponse, Error>) {
        switch result {
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        case let .success(response):
            handle(response)
        }
    }

    private func handle(_ response: OrderStatusResponse) {
        guard response.remainingAmount.value > 0 else {
            delegate?.didFail(with: PartialPaymentError.zeroRemainingAmount, from: self)
            return
        }
        paymentMethods.paid = response.paymentMethods ?? []
        componentManager = createComponentManager(response.remainingAmount)
        paymentInProgress = false
        showPaymentMethodsList()
    }
    
    // MARK: - Private

    private lazy var componentManager = createComponentManager()

    private func createComponentManager(_ remainingAmount: Payment.Amount? = nil) -> ComponentManager {
        ComponentManager(paymentMethods: paymentMethods,
                         configuration: configuration,
                         style: style,
                         partialPaymentEnabled: partialPaymentDelegate != nil,
                         remainingAmount: remainingAmount)
    }
    
    private lazy var rootComponent: PresentableComponent & ComponentLoader = {
        if let preselectedComponents = componentManager.firstStoredComponent {
            return preselectedPaymentMethodComponent(for: preselectedComponents)
        } else {
            return paymentMethodListComponent()
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
    
    private func paymentMethodListComponent() -> PaymentMethodListComponent {
        let paymentComponents = componentManager.sections
        let component = PaymentMethodListComponent(components: paymentComponents, style: style.listComponent)
        component.localizationParameters = configuration.localizationParameters
        component.delegate = self
        component._isDropIn = true
        component.environment = environment
        return component
    }
    
    private func preselectedPaymentMethodComponent(for storedPaymentComponent: PaymentComponent) -> PreselectedPaymentMethodComponent {
        let component = PreselectedPaymentMethodComponent(component: storedPaymentComponent,
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
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = self
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
        case let component as EmptyPaymentComponent:
            component.initiatePayment()
        default:
            break
        }
    }
    
    private func didSelectCancelButton(isRoot: Bool, component: PresentableComponent) {
        guard !paymentInProgress || component is Cancellable else { return }
        
        if isRoot {
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        } else {
            navigationController.popViewController(animated: true)
            userDidCancel(component)
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

        if let component = component as? ReadyToSubmitPaymentComponent {
            delegate?.didSubmit(component.paymentData, for: component.paymentMethod, from: self)
        } else {
            didSelect(component)
        }
    }
    
    internal func didRequestAllPaymentMethods() {
        showPaymentMethodsList()
    }

    private func showPaymentMethodsList() {
        let newRoot = paymentMethodListComponent()
        navigationController.present(root: newRoot)
        rootComponent = newRoot
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
    public func showConfirmation(for component: ReadyToSubmitPaymentComponent) {
        let newRoot = preselectedPaymentMethodComponent(for: component)
        navigationController.present(root: newRoot)
        rootComponent = newRoot
    }
}

extension DropInComponent: PartialPaymentDelegate {

    /// :nodoc:
    public func requestOrder(_ data: PaymentComponentData,
                             from component: PaymentComponent,
                             completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void) {
        if let order = order {
            completion(.success(order))
        } else {
            partialPaymentDelegate?.requestOrder(data, from: component, completion: completion)
        }
    }

    /// :nodoc:
    public func cancelOrder(_ order: PartialPaymentOrder,
                            from component: PaymentComponent,
                            completion: @escaping (Error?) -> Void) {
        partialPaymentDelegate?.cancelOrder(order, from: component, completion: completion)
    }

    /// :nodoc:
    public func checkBalance(_ data: PaymentComponentData,
                             from component: PaymentComponent,
                             completion: @escaping (Result<Balance, Error>) -> Void) {
        partialPaymentDelegate?.checkBalance(data, from: component, completion: completion)
    }
}

private extension Bundle {

    // Name of the app - title under the icon.
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

}
