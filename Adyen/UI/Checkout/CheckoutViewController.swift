//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import SafariServices

/// The starting point for [Quick integration](https://docs.adyen.com/developers/payments/accepting-payments/in-app-integration). Initialize with `CheckoutViewContollerDelegate` and present this view controller in your app to start the payment flow. If you don't embed the `CheckoutViewController` in an existing `UINavigationController`, a new one will be created automatically.
public final class CheckoutViewController: UIViewController {
    
    /// The delegate for Quick integration.
    internal(set) public weak var delegate: CheckoutViewControllerDelegate?
    
    /// The delegate implementing card scanning functionality for card payment methods.
    public weak var cardScanDelegate: CheckoutViewControllerCardScanDelegate?
    
    /// The appearance configuration that was used to initialize the view controller.
    fileprivate let appearanceConfiguration: AppearanceConfiguration
    
    /// Initializes the checkout view controller.
    ///
    /// - Parameters:
    ///   - delegate: The delegate to receive the checkout view controller's events.
    ///   - appearanceConfiguration: The configuration to use for customizing the checkout view controller's appearance.
    public init(delegate: CheckoutViewControllerDelegate, appearanceConfiguration: AppearanceConfiguration = .default) {
        self.delegate = delegate
        self.appearanceConfiguration = appearanceConfiguration.copied
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .formSheet
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Child View Controllers
    
    fileprivate var rootViewController: UIViewController? {
        willSet {
            rootViewController?.removeFromParentViewController()
            rootViewController?.viewIfLoaded?.removeFromSuperview()
        }
        
        didSet {
            guard let rootViewController = rootViewController else { return }
            
            addChildViewController(rootViewController)
            viewIfLoaded?.addSubview(rootViewController.view)
        }
    }
    
    fileprivate lazy var paymentMethodPickerViewController: PaymentMethodPickerViewController = {
        PaymentMethodPickerViewController(delegate: self, appearanceConfiguration: self.appearanceConfiguration)
    }()
    
    /// :nodoc:
    public override var navigationItem: UINavigationItem {
        return paymentMethodPickerViewController.navigationItem
    }
    
    // MARK: View
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rootView = rootViewController?.view {
            view.addSubview(rootView)
        }
        
        paymentRequest.start()
    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard rootViewController == nil else {
            return
        }
        
        // If we're being presented inside a UINavigationController, skip the use of our own navigation controller.
        if parent is UINavigationController {
            rootViewController = paymentMethodPickerViewController
        } else {
            rootViewController = NavigationController(rootViewController: paymentMethodPickerViewController, appearanceConfiguration: appearanceConfiguration)
        }
    }
    
    /// :nodoc:
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        rootViewController?.view.frame = view.bounds
    }
    
    // MARK: Status Bar
    
    /// :nodoc:
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return appearanceConfiguration.preferredStatusBarStyle
    }
    
    // MARK: Payment Request
    
    fileprivate lazy var paymentRequest: PaymentRequest = {
        PaymentRequest(delegate: self)
    }()
    
    fileprivate var paymentMethodCompletion: MethodCompletion?
    
    fileprivate var paymentDetailsCompletion: PaymentDetailsCompletion?
    
    fileprivate var paymentDetailsPresenter: PaymentDetailsPresenter?
    
}

// MARK: PaymentRequestDelegate

extension CheckoutViewController: PaymentRequestDelegate {
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        delegate?.checkoutViewController(self, requiresPaymentDataForToken: token, completion: completion)
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresPaymentMethodFrom preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
        paymentMethodCompletion = completion
        
        paymentMethodPickerViewController.displayMethods(preferred: preferredMethods, available: availableMethods)
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresReturnURLFrom url: URL, completion: @escaping URLCompletion) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .formSheet
        
        delegate?.checkoutViewController(self, requiresReturnURL: completion)
        
        present(safariViewController, animated: true, completion: nil)
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresPaymentDetails details: PaymentDetails, completion: @escaping PaymentDetailsCompletion) {
        guard
            let hostViewController = navigationController ?? paymentMethodPickerViewController.navigationController,
            let paymentMethod = request.paymentMethod,
            let plugin = request.pluginManager?.plugin(for: paymentMethod) as? PluginPresentsPaymentDetails
        else {
            completion(details)
            
            return
        }
        
        if var cardScanPlugin = plugin as? CardScanPlugin,
            let cardScanDelegate = cardScanDelegate,
            cardScanDelegate.shouldShowCardScanButton(for: self) {
            cardScanPlugin.cardScanButtonHandler = { [weak self] cardScanCompletion in
                if let strongSelf = self {
                    strongSelf.cardScanDelegate?.scanCard(for: strongSelf, completion: cardScanCompletion)
                }
            }
        }
        
        let detailsPresenter = plugin.newPaymentDetailsPresenter(hostViewController: hostViewController, appearanceConfiguration: appearanceConfiguration)
        detailsPresenter.delegate = self
        detailsPresenter.start()
        
        paymentDetailsCompletion = completion
        paymentDetailsPresenter = detailsPresenter
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
        paymentMethodPickerViewController.reset()
        
        delegate?.checkoutViewController(self, didFinishWith: result)
    }
    
}

// MARK: PaymentMethodPickerViewControllerDelegate

extension CheckoutViewController: PaymentMethodPickerViewControllerDelegate {
    
    /// :nodoc:
    func paymentMethodPickerViewController(_ paymentMethodPickerViewController: PaymentMethodPickerViewController, didSelectPaymentMethod paymentMethod: PaymentMethod) {
        paymentMethodCompletion?(paymentMethod)
        
        if paymentMethod.inputDetails.isNilOrEmpty {
            paymentMethodPickerViewController.displayPaymentMethodActivityIndicator()
        }
    }
    
    /// :nodoc:
    func paymentMethodPickerViewController(_ paymentMethodPickerViewController: PaymentMethodPickerViewController, didSelectDeletePaymentMethod paymentMethod: PaymentMethod) {
        paymentRequest.deletePreferred(paymentMethod: paymentMethod) { _ in
            
        }
    }
    
    /// :nodoc:
    func paymentMethodPickerViewControllerDidCancel(_ paymentMethodPickerViewController: PaymentMethodPickerViewController) {
        delegate?.checkoutViewController(self, didFinishWith: .error(.canceled))
    }
    
}

extension CheckoutViewController: PaymentDetailsPresenterDelegate {
    
    /// :nodoc:
    func paymentDetailsPresenter(_ paymentDetailsPresenter: PaymentDetailsPresenter, didSubmit paymentDetails: PaymentDetails) {
        paymentMethodPickerViewController.displayPaymentMethodActivityIndicator()
        
        paymentDetailsCompletion?(paymentDetails)
        paymentDetailsCompletion = nil
        
        self.paymentDetailsPresenter = nil
    }
    
}

// MARK: SFSafariViewControllerDelegate

extension CheckoutViewController: SFSafariViewControllerDelegate {
    
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        paymentMethodPickerViewController.reset()
    }
    
}
