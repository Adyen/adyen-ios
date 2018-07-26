//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Presents the default checkout UI. This provides the starting point for the quick integration.
public final class CheckoutController {

    // MARK: - Initializing the Checkout Controller
    
    /// Initializes the checkout controller.
    ///
    /// - Parameters:
    ///   - presentingViewController: The view controller that will present the checkout UI.
    ///   - delegate: The delegate of the checkout controller.
    public init(presentingViewController: UIViewController, delegate: CheckoutControllerDelegate, appearance: Appearance? = nil) {
        self.presentingViewController = presentingViewController
        self.delegate = delegate
        
        if let appearance = appearance {
            Appearance.shared = appearance
        }
    }
    
    deinit {
        guard let paymentController = paymentController else {
            return
        }
        
        assert(!paymentController.isPaymentSessionActive, "CheckoutController was allocated during an active payment session.")
    }
    
    // MARK: - Accessing the Delegate
    
    /// The delegate of the checkout controller.
    public private(set) weak var delegate: CheckoutControllerDelegate?
    
    // MARK: - Presenting and Dismissing the UI
    
    /// The view controller that will present the checkout UI.
    public let presentingViewController: UIViewController
    
    /// Determines whether the preselected payment method should be shown when available. Default value is `true`.
    public var showsPreselectedPaymentMethod = true
    
    /// Starts the checkout process and presents the checkout UI on the provided presentingViewController.
    public func start() {
        paymentController = PaymentController(delegate: self)
        
        var token = PaymentSessionToken()
        token.integrationType = .quick
        paymentController?.start(with: token)
        
        presenter.showLoadingScreen()
    }
    
    /// Cancels the checkout process and dismisses the checkout UI.
    public func cancel() {
        paymentController?.cancel()
    }
    
    // MARK: - Private
    
    private var methodSelectionCompletion: Completion<PaymentMethod>?
    private var selectedMethodPlugin: Plugin?
    
    private lazy var presenter: CheckoutPresenter = {
        let presenter = CheckoutPresenter(presentingViewController: self.presentingViewController)
        presenter.delegate = self
        
        return presenter
    }()
    
    private var paymentController: PaymentController?
    
    private var pluginManager: PluginManager?
    
    private func reset() {
        paymentController = nil
        pluginManager = nil
        methodSelectionCompletion = nil
        selectedMethodPlugin = nil
    }
}

extension CheckoutController: PaymentControllerDelegate {
    /// :nodoc:
    public func requestPaymentSession(withToken token: String, for paymentController: PaymentController, responseHandler: @escaping (String) -> Void) {
        delegate?.requestPaymentSession(withToken: token, for: self, responseHandler: responseHandler)
    }
    
    /// :nodoc:
    public func selectPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController, selectionHandler: @escaping (PaymentMethod) -> Void) {
        guard let paymentSession = paymentController.paymentSession else {
            return
        }
        
        let pluginManager = PluginManager(paymentSession: paymentSession)
        self.pluginManager = pluginManager
        
        methodSelectionCompletion = selectionHandler
        
        let amount = paymentSession.payment.amount
        if showsPreselectedPaymentMethod,
            let preselectedPaymentMethod = PreselectedPaymentMethodManager.preselectedPaymentMethod(for: paymentSession) {
            presenter.show(preselectedPaymentMethod, amount: amount)
        } else {
            presenter.show(paymentMethods, pluginManager: pluginManager)
        }
    }
    
    /// :nodoc:
    public func redirect(to url: URL, for paymentController: PaymentController) {
        presenter.redirect(to: url)
    }
    
    /// :nodoc:
    public func didFinish(with result: Result<PaymentResult>, for paymentController: PaymentController) {
        presenter.showPaymentProcessing(false)
        
        let completion = {
            self.presenter.dismiss {
                self.reset()
                self.delegate?.didFinish(with: result, for: self)
            }
        }
        
        if let selectedMethodPlugin = selectedMethodPlugin {
            if case let .success(paymentResult) = result, paymentResult.status == .authorised || paymentResult.status == .received {
                PreselectedPaymentMethodManager.saveSelectedPaymentMethod(selectedMethodPlugin.paymentMethod)
            }
            
            selectedMethodPlugin.finish(with: result, completion: completion)
        } else {
            completion()
        }
    }
}

extension CheckoutController: CheckoutPresenterDelegate {
    func didSelectCancel(in checkoutPresenter: CheckoutPresenter) {
        cancel()
    }
    
    func didSelectChange(in checkoutPresenter: CheckoutPresenter) {
        guard let paymentSession = paymentController?.paymentSession,
            let pluginManager = pluginManager else {
            return
        }
        
        presenter.show(paymentSession.paymentMethods, pluginManager: pluginManager)
    }
    
    func didSelect(_ paymentMethod: PaymentMethod, in checkoutPresenter: CheckoutPresenter) {
        guard let plugin = pluginManager?.plugin(for: paymentMethod) else {
            selectedMethodPlugin = nil
            checkoutPresenter.showPaymentProcessing(true)
            methodSelectionCompletion?(paymentMethod)
            return
        }
        
        selectedMethodPlugin = plugin
        checkoutPresenter.showPaymentDetails(for: plugin) { details in
            checkoutPresenter.showPaymentProcessing(true)
            
            var filledPaymentMethod = paymentMethod
            filledPaymentMethod.details = details
            self.methodSelectionCompletion?(filledPaymentMethod)
        }
    }
    
    func didDelete(_ paymentMethod: PaymentMethod, in checkoutPresenter: CheckoutPresenter) {
        paymentController?.deleteStoredPaymentMethod(paymentMethod) { _ in
            // TODO: Consider doing something meaningful with the result.
        }
    }
}
