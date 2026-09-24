//
// Copyright (c) 2019 Adyen N.V.
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
    ActionHandlingComponent {

    // MARK: - Properties

    internal private(set) lazy var dropInFlowManager: DropInFlowManaging = {
        DropInFlowManager(
            dropInComponent: self,
            dropInComponentDelegate: delegate,
            context: context,
            actionComponentConfiguration: actionComponentConfiguration,
            paymentActionAssembler: PaymentActionAssembler()
        )
    }()

    private lazy var dropInAssembler = DropInAssembler(
        title: title,
        paymentMethods: paymentMethods,
        context: context,
        configuration: configuration,
        dropInFlowManager: dropInFlowManager,
        partialPaymentDelegate: partialPaymentDelegate,
        storedPaymentMethodManagementCapability: storedPaymentMethodManagementCapability,
        paymentComponentBuilder: paymentComponentBuilder
    )

    internal private(set) lazy var router: DropInRouting = {
        let router = dropInAssembler.resolveDropInRouter()
        dropInFlowManager.dropInFlowRouter = router
        return router
    }()

    internal var configuration: DropInConfiguration

    private let actionComponentConfiguration: CheckoutActionComponent.Configuration
    internal let storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?
    private let paymentComponentBuilder: DropInPaymentComponentBuilder

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
    ///   - configuration: Drop-in behavior and checkout-wide presentation configuration.
    ///   - actionComponentConfiguration: The resolved configuration for action handling.
    ///   - storedPaymentMethodManagementCapability: The optional stored payment method management behavior.
    ///   - paymentComponentBuilder: The payment component builder to handle component creation.
    ///   - title: Name of the application. To be displayed on a first payment page.
    ///            If no external value provided, the Main Bundle's name would be used.
    package init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInConfiguration = .init(),
        actionComponentConfiguration: CheckoutActionComponent.Configuration = .init(),
        storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability? = nil,
        paymentComponentBuilder: @escaping DropInPaymentComponentBuilder,
        title: String? = nil
    ) {
        self.title = title ?? Bundle.main.displayName
        self.configuration = configuration
        self.actionComponentConfiguration = actionComponentConfiguration
        self.storedPaymentMethodManagementCapability = storedPaymentMethodManagementCapability
        self.paymentComponentBuilder = paymentComponentBuilder
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
    //        configuration: DropInConfiguration = .init(),
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

    // MARK: - Presentable Component Protocol

    package var hasSupportedPaymentMethods: Bool {
        dropInAssembler.hasSupportedPaymentMethods
    }

    package private(set) lazy var viewController: UIViewController = {
        router.rootViewController
    }()

    // MARK: - Handling Actions

    /// Handles an action to complete a payment.
    ///
    /// - Parameter action: The action to handle.
    package func handle(_ action: Action) {
        dropInFlowManager.receive(action: action)
    }

    // MARK: - Handling Partial Payments

    private var apiClient: AsyncAPIClientProtocol

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
        // TODO: Partial payments need a dedicated design for updating the assembler-owned ComponentManager.
        paymentInProgress = false
//        displayPaymentMethodsList(onCancel: { [weak self] in
//            guard let self else { return }
//            self.partialPaymentDelegate?.cancelOrder(order, component: self)
//        })
    }

    internal func userDidCancel(_ component: Component) {
        component.cancel()

        if let component = (component as? PaymentComponent) ?? selectedPaymentComponent, paymentInProgress {
            delegate?.didCancel(component: component, from: self)
        }
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
}

private extension Bundle {

    /// Name of the app - title under the icon.
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

}
