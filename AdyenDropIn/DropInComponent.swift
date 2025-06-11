//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
#if canImport(AdyenCard)
    @_spi(AdyenInternal) import AdyenCard
#endif
import AdyenNetworking
#if canImport(AdyenTwint)
    import AdyenTwint
#endif
import UIKit

/**
 A component that handles the entire flow of payment selection and payment details entry.

 - SeeAlso:
 [Implementation Reference](https://docs.adyen.com/online-payments/ios/drop-in)
 */
public final class DropInComponent: NSObject,
    AnyDropInComponent,
    ActionHandlingComponent,
    LoadingComponent {

    // MARK: - Properties

    private lazy var componentManager: ComponentManager = {
        let componentManager = createComponentManager(nil)
        return componentManager
    }()

    internal var configuration: Configuration

    internal var paymentInProgress: Bool = false

    internal var selectedPaymentComponent: PaymentComponent?

    /// The payment methods to display.
    public internal(set) var paymentMethods: PaymentMethods

    /// The title text on the first page of drop in component.
    public let title: String

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// Initializes the drop in component.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods to display.
    ///   - context: The context object for this component.
    ///   - configuration: The payment method specific configuration.
    ///   - title: Name of the application. To be displayed on a first payment page.
    ///            If no external value provided, the Main Bundle's name would be used.
    public init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: Configuration = .init(),
        title: String? = nil
    ) {
        self.title = title ?? Bundle.main.displayName
        self.configuration = configuration
        self.context = context
        self.paymentMethods = paymentMethods

        let scheduler = SimpleScheduler(maximumCount: 3)
        self.apiClient = APIClient(apiContext: context.apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()

        super.init()
    }

    //    /// For testing only
    //    internal init(
    //        paymentMethods: PaymentMethods,
    //        context: AdyenContext,
    //        configuration: Configuration = .init(),
    //        title: String? = nil,
    //        apiClient: APIClientProtocol
    //    ) {
    //        self.title = title ?? Bundle.main.displayName
    //        self.configuration = configuration
    //        self.context = context
    //        self.paymentMethods = paymentMethods
    //        self.apiClient = apiClient
    //
    //        super.init()
    //    }

    // MARK: - Delegates

    /// The delegate of the drop in component.
    public weak var delegate: DropInComponentDelegate?

    /// The partial payment flow delegate.
    public weak var partialPaymentDelegate: PartialPaymentDelegate?

    /// The stored payment methods delegate.
    public weak var storedPaymentMethodsDelegate: StoredPaymentMethodsDelegate? {
        didSet {
            guard let sessionAsStoredPaymentMethodsDelegate else { return }

            let showRemoveStoredPaymentButton = sessionAsStoredPaymentMethodsDelegate.showRemovePaymentMethodButton
            configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = showRemoveStoredPaymentButton
        }
    }

    /// The delegate for user activity on card component.
    public weak var cardComponentDelegate: CardComponentDelegate?

    // MARK: - Presentable Component Protocol

    public var viewController: UIViewController { navigationController }

    // MARK: - Handling Actions

    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    public func handle(_ action: Action) {
        actionComponent.handle(action)
    }

    // MARK: - Handling Partial Payments

    private var apiClient: APIClientProtocol

    internal func reloadComponentManager() {
        componentManager = createComponentManager(componentManager.order)
    }

    /// Convenience accessor to the session if it's the delegate for removing stored payment methods
    internal var sessionAsStoredPaymentMethodsDelegate: SessionStoredPaymentMethodsDelegate? {
        if let storedPaymentRemovable = storedPaymentMethodsDelegate as? SessionStoredPaymentMethodsDelegate,
           storedPaymentRemovable.isSession {
            return storedPaymentRemovable
        }
        return nil
    }

    /// Reloads the DropIn with a partial payment order and a new `PaymentMethods` object.
    ///
    /// - Parameter order: The partial payment order.
    /// - Parameter paymentMethods: The new payment methods.
    /// - Throws: `PartialPaymentError.missingOrderData` in case `order.orderData` is `nil`.
    public func reload(
        with order: PartialPaymentOrder,
        _ paymentMethods: PaymentMethods
    ) throws {
        guard let orderData = order.orderData else { throw PartialPaymentError.missingOrderData }
        let request = OrderStatusRequest(orderData: orderData)
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(orderResponse):
                self.paymentMethods = paymentMethods
                self.handle(orderResponse, order)
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
    }

    private func handle(_ response: OrderStatusResponse, _ order: PartialPaymentOrder) {
        guard response.remainingAmount.value > 0 else {
            delegate?.didFail(with: PartialPaymentError.zeroRemainingAmount, from: self)
            return
        }
        paymentMethods.paid = response.paymentMethods ?? []
        componentManager = createComponentManager(order)
        paymentInProgress = false
//        displayPaymentMethodsList(onCancel: { [weak self] in
//            guard let self else { return }
//            self.partialPaymentDelegate?.cancelOrder(order, component: self)
//        })
    }

    // MARK: - Private

    private func createComponentManager(_ order: PartialPaymentOrder?) -> ComponentManager {
        ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            partialPaymentEnabled: partialPaymentDelegate != nil,
            order: order,
            supportsEditingStoredPaymentMethods: storedPaymentMethodsDelegate != nil,
            presentationDelegate: self
        )
    }

//    internal lazy var navigationController = DropInNavigationController(
//        rootViewController: rootViewController,
//        style: configuration.style.navigation,
//        cancelHandler: { [weak self] isRoot, component in
//            self?.didSelectCancelButton(isRoot: isRoot, component: component)
//        }
//    )

    internal lazy var navigationController: UIViewController = {
        let dropInRootAssembler = DropInRootAssembler(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration
        )
        let dropInRootViewController = dropInRootAssembler.resolveDropInRootView()
        return dropInRootViewController
    }()

    private lazy var actionComponent: AdyenActionComponent = {
        let handler = AdyenActionComponent(context: context)
        handler.configuration.style = configuration.style.actionComponent
        handler._isDropIn = true
        handler.delegate = self
        handler.presentationDelegate = self
        handler.configuration.localizationParameters = configuration.localizationParameters
        handler.configuration.threeDS = configuration.actionComponent.threeDS
        handler.configuration.twint = configuration.actionComponent.twint
        return handler
    }()

    // ================= ROOT VIEW CONTROLLER ===============

    internal lazy var rootViewController: UIViewController = {
//        if configuration.allowPreselectedPaymentView,
//           let preselectedComponent = componentManager.storedComponents.first {
//            let view = resolvePreselectedPaymentMethodView(for: preselectedComponent, onCancel: nil)
//            self.preselectedPaymentMethodView = view
//            return view
//        } else if configuration.allowsSkippingPaymentList,
//                  let singleRegularComponent = componentManager.singleRegularComponent {
//            setNecessaryDelegates(on: singleRegularComponent)
//            let componentView = resolveComponentView(from: singleRegularComponent)
//            self.componentView = componentView
//            return componentView
//        } else {
//            let view = resolvePaymentMethodListView(onCancel: nil)
//            self.paymentMethodListView = view
//            return view
//        }
        let dropInRootAssembler = DropInRootAssembler(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration
        )
        let view = dropInRootAssembler.resolveDropInRootView()
        return view
    }()

    // ================= COMPONENT MODULE - ASSEMBLER ===============

    internal func resolveComponentView(
        from component: PresentableComponent
    ) -> UIViewController {
        let viewModel = ComponentContainerViewModel(
            component: component,
            isRoot: false,
            cancelHandler: nil
        )

        let componentViewController = ComponentContainerViewController(viewModel: viewModel)
        return componentViewController
    }

    // ================= COMPONENT MODULE - ASSEMBLER ===============

    // ================= PAYMENT METHOD LIST MODULE - ASSEMBLER ===============

    internal func resolvePaymentMethodListView(onCancel: (() -> Void)?) -> UIViewController {
        // TODO: - Review if needed with new architecture
        // component.onCancel = onCancel
        // component._isDropIn = true

        let viewModel = PaymentMethodListViewModel(
            router: self,
            context: context,
            componentManager: componentManager,
            configuration: configuration
        )
        let view = PaymentMethodListViewController(viewModel: viewModel)
        return view
    }

    // ================= PAYMENT METHOD LIST MODULE - ASSEMBLER ===============

    internal func didSelect(_ component: PaymentComponent) {
        setNecessaryDelegates(on: component)

        switch component {
        case let component as PresentableComponent:
            let componentView = resolveComponentView(from: component)
            navigationController.present(componentView, animated: true)
        case let component as PaymentInitiable:
            component.initiatePayment()
        default:
            break
        }
    }

    private func didSelectCancelButton(isRoot: Bool, component: PresentableComponent) {
        guard !paymentInProgress || component is Cancellable else { return }

        userDidCancel(component)

        if isRoot {
            sendExitEvent()
            //            delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }

    internal func userDidCancel(_ component: Component) {
        component.cancelIfNeeded()

        defer {
            // As `stopLoading` sets the paymentInProgress to false
            // we make sure to call it at the end of the function
            stopLoading()
        }

        if let component = (component as? PaymentComponent) ?? selectedPaymentComponent, paymentInProgress {
            delegate?.didCancel(component: component, from: self)
        }
    }

    public func stopLoading() {
        paymentInProgress = false
        // TODO: - Handle loading logic in its own module
        (rootViewController as? ComponentLoader)?.stopLoading()
        selectedPaymentComponent?.stopLoadingIfNeeded()
    }

    private func setNecessaryDelegates(on component: PaymentComponent) {
        selectedPaymentComponent = component
        component.delegate = self
        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
        (component as? PreApplePayComponent)?.presentationDelegate = self

        component._isDropIn = true
    }

    private func sendExitEvent() {
        let logEvent = AnalyticsEventLog(component: "dropin", type: .closed)
        context.analyticsProvider?.add(log: logEvent)
    }
}

private extension Bundle {

    // Name of the app - title under the icon.
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

}

@_spi(AdyenInternal)
extension DropInComponent: AdyenSessionAware {
    public var isSession: Bool {
        delegate is AdyenSessionAware
    }
}

@_spi(AdyenInternal)
extension DropInComponent: StorePaymentMethodFieldAware {

    public var showStorePaymentMethodField: Bool? {
        (delegate as? StorePaymentMethodFieldAware)?.showStorePaymentMethodField
    }
}

@_spi(AdyenInternal)
extension DropInComponent: InstallmentConfigurationAware {

    public var installmentConfiguration: InstallmentConfiguration? {
        (delegate as? InstallmentConfigurationAware)?.installmentConfiguration
    }
}

// ============= PAYMENT METHOD LIST ===============

extension DropInComponent: PaymentMethodListRouterProtocol {

    func dismiss() {
        //
    }

    func didLoad() {
        sendInitialAnalytics()
        sendDidLoadEvent()
    }

    func present(_ component: any PresentableComponent) {
//        (rootViewController as? ComponentLoader)?.startLoading(for: component)
//        didSelect(component)
    }

    func delete(
        storedPaymentMethod: any StoredPaymentMethod,
        completion: @escaping (Bool) -> Void
    ) {
        let deletionCompletion = { [weak self] (success: Bool) in
            defer {
                completion(success)
            }
            guard success else { return }
            self?.paymentMethods.stored.removeAll(where: { $0 == storedPaymentMethod })
            self?.reloadComponentManager()
        }

        if let sessionAsStoredPaymentMethodsDelegate {
            sessionAsStoredPaymentMethodsDelegate.disable(
                storedPaymentMethod: storedPaymentMethod,
                dropInComponent: self,
                completion: deletionCompletion
            )
        } else {
            storedPaymentMethodsDelegate?.disable(
                storedPaymentMethod: storedPaymentMethod,
                completion: deletionCompletion
            )
        }
    }

}

// ============= PAYMENT METHOD LIST ===============
