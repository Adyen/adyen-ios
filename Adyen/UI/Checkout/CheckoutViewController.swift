//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import SafariServices

/// The starting point for [Quick integration](https://docs.adyen.com/developers/payments/accepting-payments/in-app-integration). Initialize and present this view controller in your app to start the payment flow. If you don't embed the `CheckoutViewController` in a `UINavigationController` instance, a new one will be created automatically.
///
/// Communication is performed through a `delegate` object that conforms to `CheckoutViewControllerDelegate` and a `cardScanDelegate` object that conforms to `CheckoutViewControllerCardScanDelegate`.
///
/// Providing a `delegate` is required during initialization. This object is used to request and provide data during the payment flow process.
///
/// Providing a `cardScanDelegate` is optional. This object is used when integrating card scanning functionality. The Adyen SDK does not perform card scanning, but allows you to integrate your own or third-party scanning behaviour. Through this object, you can let `CheckoutViewController` know whether or not a card scan button should be shown, receive a callback when this button is tapped, and provide scan results back to the SDK through a completion block.
public final class CheckoutViewController: UIViewController, PaymentRequestDelegate, PaymentMethodPickerViewControllerDelegate, PaymentDetailsPresenterDelegate, SFSafariViewControllerDelegate {
    
    // MARK: - Initializing
    
    /// Initializes the Checkout View Controller.
    ///
    /// - Parameters:
    ///   - delegate: The delegate to receive the checkout view controller's events.
    ///   - appearanceConfiguration: The configuration for customizing the checkout view controller's appearance.
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
    
    // MARK: - Accessing the Delegates
    
    /// The delegate for payment processing.
    internal(set) public weak var delegate: CheckoutViewControllerDelegate?
    
    /// The delegate for card scanning functionality for card payments.
    public weak var cardScanDelegate: CheckoutViewControllerCardScanDelegate?
    
    // MARK: - UIViewController
    
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
    
    /// :nodoc:
    public override var navigationItem: UINavigationItem {
        return paymentMethodPickerViewController.navigationItem
    }
    
    /// :nodoc:
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return appearanceConfiguration.preferredStatusBarStyle
    }
    
    /// :nodoc:
    public override var shouldAutorotate: Bool {
        return traitCollection.userInterfaceIdiom == .pad
    }
    
    /// :nodoc:
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard shouldAutorotate else {
            return .portrait
        }
        
        return .all
    }
    
    // MARK: - PaymentRequestDelegate
    
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
        // Notify the delegate to listen to the return URL.
        delegate?.checkoutViewController(self, requiresReturnURL: completion)
        
        // Try to open the URL as a universal link.
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [UIApplicationOpenURLOptionUniversalLinksOnly: true]) { [weak self] success in
                guard let strongSelf = self else {
                    return
                }
                
                // If opening the URL as a universal link was not possible, open it as a website instead.
                if !success {
                    strongSelf.presentWebPage(with: url)
                }
            }
        } else {
            // Fallback on earlier versions.
            presentWebPage(with: url)
        }
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
        
        paymentMethodCompletion = nil
        paymentDetailsCompletion = nil
        paymentDetailsPresenter = nil
        
        delegate?.checkoutViewController(self, didFinishWith: result)
    }
    
    // MARK: - PaymentMethodPickerViewControllerDelegate
    
    /// :nodoc:
    func paymentMethodPickerViewController(_ paymentMethodPickerViewController: PaymentMethodPickerViewController, didSelectPaymentMethod paymentMethod: PaymentMethod) {
        //  If payment method doesn't require input, for better UX, ask user to confirm before proceeding with the actual payment.
        if paymentMethod.isOneClick && paymentMethod.inputDetails.isNilOrEmpty {
            presentConfirmationAlert(with: paymentMethod, for: paymentRequest) { confirmed in
                if confirmed {
                    paymentMethodPickerViewController.displayPaymentMethodActivityIndicator()
                    self.paymentMethodCompletion?(paymentMethod)
                }
            }
            return
        }
        
        if paymentMethod.inputDetails.isNilOrEmpty {
            paymentMethodPickerViewController.displayPaymentMethodActivityIndicator()
        }
        
        paymentMethodCompletion?(paymentMethod)
    }
    
    /// :nodoc:
    func paymentMethodPickerViewController(_ paymentMethodPickerViewController: PaymentMethodPickerViewController, didSelectDeletePaymentMethod paymentMethod: PaymentMethod) {
        paymentRequest.deletePreferred(paymentMethod: paymentMethod) { _, _ in
            
        }
    }
    
    /// :nodoc:
    func paymentMethodPickerViewControllerDidCancel(_ paymentMethodPickerViewController: PaymentMethodPickerViewController) {
        delegate?.checkoutViewController(self, didFinishWith: .error(.cancelled))
    }
    
    // MARK: - PaymentDetailsPresenterDelegate
    
    /// :nodoc:
    func paymentDetailsPresenter(_ paymentDetailsPresenter: PaymentDetailsPresenter, didSubmit paymentDetails: PaymentDetails) {
        paymentMethodPickerViewController.displayPaymentMethodActivityIndicator()
        
        paymentDetailsCompletion?(paymentDetails)
        paymentDetailsPresenter.delegate = nil
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        paymentMethodPickerViewController.reset()
        paymentDetailsPresenter?.delegate = self
    }
    
    // MARK: - Private
    
    /// The appearance configuration that was used to initialize the view controller.
    private let appearanceConfiguration: AppearanceConfiguration
    
    private var rootViewController: UIViewController? {
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
    
    private lazy var paymentMethodPickerViewController: PaymentMethodPickerViewController = {
        PaymentMethodPickerViewController(delegate: self, appearanceConfiguration: self.appearanceConfiguration)
    }()
    
    private lazy var paymentRequest: PaymentRequest = {
        PaymentRequest(delegate: self)
    }()
    
    private var paymentMethodCompletion: MethodCompletion?
    private var paymentDetailsCompletion: PaymentDetailsCompletion?
    private var paymentDetailsPresenter: PaymentDetailsPresenter?
    
    private func presentConfirmationAlert(with method: PaymentMethod, for request: PaymentRequest, completion: @escaping (Bool) -> Void) {
        let alertTitle = ADYLocalizedString("oneClick.confirmationAlert.title", method.name)
        let alertMessage = method.displayName
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        //  Confirm alert action
        let confirmActionTitle: String
        if let amount = request.amount, let currencyCode = request.currency {
            let formattedAmount = CurrencyFormatter.format(amount, currencyCode: currencyCode) ?? ""
            confirmActionTitle = ADYLocalizedString("payButton.formatted", formattedAmount)
        } else {
            confirmActionTitle = ADYLocalizedString("payButton.formatted")
        }
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { action in
            completion(true)
        }
        alertController.addAction(confirmAction)
        
        //  Cancel alert action
        let cancelActionTitle = ADYLocalizedString("cancelButton")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel) { action in
            completion(false)
        }
        alertController.addAction(cancelAction)
        
        paymentMethodPickerViewController.present(alertController, animated: true)
    }
    
    private func presentWebPage(with url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .formSheet
        
        if #available(iOS 11, *) {
            safariViewController.dismissButtonStyle = .cancel
        }
        
        present(safariViewController, animated: true)
    }
    
}
