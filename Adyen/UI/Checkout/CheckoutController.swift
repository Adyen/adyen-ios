//
// Copyright (c) 2019 Adyen B.V.
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
        
        assert(!paymentController.isPaymentSessionActive, "CheckoutController was deallocated during an active payment session.")
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
    
    private var pluginManager: PluginManager? {
        return paymentController?.pluginManager
    }
    
    private func select(_ paymentMethod: PaymentMethod, asRoot: Bool = false) {
        guard let selectionHandler = methodSelectionCompletion else { return }
        
        let plugin = pluginManager?.plugin(for: paymentMethod) as? PaymentDetailsPlugin
        
        if let plugin = plugin, !paymentMethod.details.isEmpty {
            selectedMethodPlugin = plugin
            
            presenter.show(paymentMethod.details, using: plugin, asRoot: asRoot) { filledDetails in
                var paymentMethod = paymentMethod
                paymentMethod.details = filledDetails
                selectionHandler(paymentMethod)
            }
        } else {
            selectedMethodPlugin = nil
            
            presenter.showPaymentProcessing(true)
            selectionHandler(paymentMethod)
        }
    }
    
    private func reset() {
        paymentController = nil
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
        guard
            let paymentSession = paymentController.paymentSession,
            let pluginManager = pluginManager
        else {
            return
        }
        
        methodSelectionCompletion = selectionHandler
        
        // Show a preselected payment method when available.
        if showsPreselectedPaymentMethod, let paymentMethod = PreselectedPaymentMethodManager.preselectedPaymentMethod(for: paymentSession) {
            let amount = paymentSession.payment.amount(for: paymentMethod)
            presenter.show(paymentMethod, amount: amount, shouldShowChangeButton: paymentMethods.count > 1)
            
            return
        }
        
        // If there's only one payment method available, gather details directly or show a confirmation screen.
        if paymentMethods.other.count == 1 {
            let paymentMethod = paymentMethods.other[0]
            let plugin = pluginManager.plugin(for: paymentMethod) as? PaymentDetailsPlugin
            
            if let plugin = plugin, plugin.canSkipPaymentMethodSelection {
                select(paymentMethod, asRoot: true)
            } else {
                let amount = paymentSession.payment.amount(for: paymentMethod)
                presenter.show(paymentMethod, amount: amount, shouldShowChangeButton: false)
            }
            
            return
        }
        
        presenter.show(paymentMethods, pluginManager: pluginManager)
    }
    
    /// :nodoc:
    public func redirect(to url: URL, for paymentController: PaymentController) {
        presenter.redirect(to: url)
    }
    
    /// :nodoc:
    public func provideAdditionalDetails(_ additionalDetails: AdditionalPaymentDetails, for paymentMethod: PaymentMethod, detailsHandler: @escaping ([PaymentDetail]) -> Void) {
        guard let plugin = pluginManager?.plugin(for: paymentMethod) as? AdditionalPaymentDetailsPlugin else {
            selectedMethodPlugin = nil
            presenter.showPaymentProcessing(true)
            detailsHandler(additionalDetails.details)
            return
        }
        
        selectedMethodPlugin = plugin
        
        presenter.show(additionalDetails, using: plugin) { [weak self] result in
            switch result {
            case let .success(details):
                self?.presenter.showPaymentProcessing(true)
                
                detailsHandler(details)
            case let .failure(error):
                self?.paymentController?.finish(with: error)
            }
        }
    }
    
    /// :nodoc:
    public func didFinish(with result: Result<PaymentResult>, for paymentController: PaymentController) {
        guard let selectedMethodPlugin = selectedMethodPlugin as? PaymentDetailsPlugin else {
            finish(with: result)
            return
        }
        
        if case let .success(paymentResult) = result, paymentResult.status == .authorised || paymentResult.status == .received {
            PreselectedPaymentMethodManager.saveSelectedPaymentMethod(selectedMethodPlugin.paymentMethod)
        }
        
        selectedMethodPlugin.finish(with: result) { [weak self] in
            self?.finish(with: result)
        }
    }
    
    private func finish(with result: Result<PaymentResult>) {
        presenter.allowUserInteraction = false
        // Dismiss any of the topmost screens that have been presented, i.e. safari view controller.
        presenter.dismiss(topOnly: true, completion: {
            self.delegate?.willFinish(with: result, for: self, completionHandler: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.presenter.allowUserInteraction = true
                strongSelf.presenter.showPaymentProcessing(false)
                // Now dismiss the entire flow.
                strongSelf.presenter.dismiss(topOnly: false, completion: {
                    strongSelf.reset()
                    strongSelf.delegate?.didFinish(with: result, for: strongSelf)
                })
            })
        })
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
        select(paymentMethod)
    }
    
    func didDelete(_ paymentMethod: PaymentMethod, in checkoutPresenter: CheckoutPresenter) {
        paymentController?.deleteStoredPaymentMethod(paymentMethod) { _ in
            
        }
    }
}
