//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.PresentableComponent

#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenCard)
    import AdyenCard
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
@MainActor
package final class DropInComponent: NSObject,
    AnyDropInComponent,
    ActionHandlingComponent,
    LoadingComponent {

    // MARK: - Properties

    internal private(set) lazy var dropInFlowManager: DropInFlowManaging = {
        DropInFlowManager(
            dropInComponent: self,
            dropInComponentDelegate: delegate,
            context: context,
            configuration: configuration
        )
    }()

    internal private(set) lazy var router: DropInRouting = {
        let dropInAssembler = DropInAssembler(
            title: title,
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: partialPaymentDelegate
        )
        return dropInAssembler.resolveDropInRouter()
    }()

    private lazy var componentManager: ComponentManager = {
        createComponentManager(order: nil)
    }()

    internal var configuration: Configuration

    internal var paymentInProgress: Bool = false

    internal var selectedPaymentComponent: PaymentComponent?

    /// The payment methods to display.
    package internal(set) var paymentMethods: PaymentMethods

    /// The title text on the first page of drop in component.
    package let title: String

    /// The context object for this component.
    package var context: AdyenContext

    /// Initializes the drop in component.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods to display.
    ///   - context: The context object for this component.
    ///   - configuration: The payment method specific configuration.
    ///   - title: Name of the application. To be displayed on a first payment page.
    ///            If no external value provided, the Main Bundle's name would be used.
    package init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: Configuration = .init(),
        title: String? = nil
    ) {
        self.title = title ?? Bundle.main.displayName
        self.configuration = configuration
        self.context = context
        self.paymentMethods = paymentMethods

        self.apiClient = APIClient(apiContext: context.apiContext)
        super.init()
        
        sendInitialAnalytics()
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
    package weak var delegate: DropInComponentDelegate?

    /// The partial payment flow delegate.
    package weak var partialPaymentDelegate: PartialPaymentDelegate?

    /// The stored payment methods delegate.
    package weak var storedPaymentMethodsDelegate: StoredPaymentMethodsDelegate? {
        didSet {
            guard let sessionAsStoredPaymentMethodsDelegate else { return }

            let showRemoveStoredPaymentButton = sessionAsStoredPaymentMethodsDelegate.showRemovePaymentMethodButton
            configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = showRemoveStoredPaymentButton
        }
    }

    // MARK: - Presentable Component Protocol

    package private(set) lazy var viewController: UIViewController = {
        router.rootViewController
    }()

    // MARK: - Handling Actions

    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    package func handle(_ action: Action) {
        dropInFlowManager.handle(action: action)
    }

    // MARK: - Handling Partial Payments

    private var apiClient: AsyncAPIClientProtocol

    internal func reloadComponentManager() {
        componentManager = createComponentManager(order: componentManager.order)
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
    package func reload(
        with order: PartialPaymentOrder,
        _ paymentMethods: PaymentMethods
    ) throws {
        guard let orderData = order.orderData else { throw PartialPaymentError.missingOrderData }
        let request = OrderStatusRequest(orderData: orderData)
        Task { [weak self] in
            guard let self else { return }
            do {
                let response: OrderStatusResponse = try await apiClient.performAsync(request)
                self.paymentMethods = paymentMethods
                self.handle(response, order)
            } catch {
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
        componentManager = createComponentManager(order: order)
        paymentInProgress = false
//        displayPaymentMethodsList(onCancel: { [weak self] in
//            guard let self else { return }
//            self.partialPaymentDelegate?.cancelOrder(order, component: self)
//        })
    }

    // MARK: - Private

    private func createComponentManager(order: PartialPaymentOrder?) -> ComponentManager {
        ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            partialPaymentEnabled: partialPaymentDelegate != nil,
            order: order,
            supportsEditingStoredPaymentMethods: storedPaymentMethodsDelegate != nil
        )
    }

//    internal lazy var navigationController = DropInNavigationController(
//        rootViewController: rootViewController,
//        style: configuration.style.navigation,
//        cancelHandler: { [weak self] isRoot, component in
//            self?.didSelectCancelButton(isRoot: isRoot, component: component)
//        }
//    )

//    internal lazy var navigationController: UIViewController = {
//        self.dropInRootRouter.rootViewController
//    }()

    // ================= ROOT VIEW CONTROLLER ===============
    // TODO: Make sure Analytic events are preserved
//    internal lazy var rootViewController: UIViewController = {
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
//    }()

    private func didSelectCancelButton(isRoot: Bool, component: PresentableComponent) {
        guard !paymentInProgress || component is Cancellable else { return }

        userDidCancel(component)

        if isRoot {
            sendExitEvent()
            //            delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }

    internal func userDidCancel(_ component: Component) {
        component.cancel()

        defer {
            // As `stopLoading` sets the paymentInProgress to false
            // we make sure to call it at the end of the function
            stopLoading()
        }

        if let component = (component as? PaymentComponent) ?? selectedPaymentComponent, paymentInProgress {
            delegate?.didCancel(component: component, from: self)
        }
    }

    package func stopLoading() {
        paymentInProgress = false
        // TODO: - Handle loading logic in its own module
//        (rootViewController as? ComponentLoader)?.stopLoading()
        selectedPaymentComponent?.stopLoading()
    }

    private func setNecessaryDelegates(on component: PaymentComponent) {
        selectedPaymentComponent = component
//        component.delegate = self
//        (component as? CardComponent)?.cardComponentDelegate = cardComponentDelegate
//        (component as? PartialPaymentComponent)?.partialPaymentDelegate = partialPaymentDelegate
        (component as? PartialPaymentComponent)?.readyToSubmitComponentDelegate = self
//        (component as? PreApplePayComponent)?.presentationDelegate = self

        component._isDropIn = true
    }

    private func sendExitEvent() {
        let logEvent = AnalyticsEventLog(component: AnalyticsConstants.dropInComponentIdentifier, type: .closed)
        context.analyticsProvider?.add(log: logEvent)
    }
}

private extension Bundle {

    /// Name of the app - title under the icon.
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

}

extension DropInComponent: AdyenSessionAware {
    package var isSession: Bool {
        delegate is AdyenSessionAware
    }
}

extension DropInComponent: StorePaymentMethodFieldAware {

    package var showStorePaymentMethodField: Bool? {
        (delegate as? StorePaymentMethodFieldAware)?.showStorePaymentMethodField
    }
}

extension DropInComponent: InstallmentConfigurationAware {

    package var installmentConfiguration: InstallmentConfiguration? {
        (delegate as? InstallmentConfigurationAware)?.installmentConfiguration
    }
}

// ============= PAYMENT METHOD LIST ===============

//    func didLoad() {
//        sendInitialAnalytics()
//        sendDidLoadEvent()
//    }

//    func delete(
//        storedPaymentMethod: any StoredPaymentMethod,
//        completion: @escaping (Bool) -> Void
//    ) {
//        let deletionCompletion = { [weak self] (success: Bool) in
//            defer {
//                completion(success)
//            }
//            guard success else { return }
//            self?.paymentMethods.stored.removeAll(where: { $0 == storedPaymentMethod })
//            self?.reloadComponentManager()
//        }
//
//        if let sessionAsStoredPaymentMethodsDelegate {
//            sessionAsStoredPaymentMethodsDelegate.disable(
//                storedPaymentMethod: storedPaymentMethod,
//                dropInComponent: self,
//                completion: deletionCompletion
//            )
//        } else {
//            storedPaymentMethodsDelegate?.disable(
//                storedPaymentMethod: storedPaymentMethod,
//                completion: deletionCompletion
//            )
//        }
//    }
