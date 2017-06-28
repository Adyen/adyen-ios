//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import SafariServices

/// Starting point for [Quick integration](https://docs.adyen.com/developers/payments/accepting-payments/in-app-integration). Intialize with `CheckoutViewContollerDelegate` and present this ViewController in your app to start the payment flow.
public final class CheckoutViewController: UIViewController {
    
    /// Delegate for Quick integration.
    internal(set) public weak var delegate: CheckoutViewControllerDelegate?
    
    var paymentRequest: PaymentRequest?
    var methodCompletion: MethodCompletion?
    var currentPresenter: PaymentMethodDetailsPresenter?
    
    /// Initialise the ViewController with `CheckoutViewControllerDelegate`.
    public init(delegate: CheckoutViewControllerDelegate) {
        self.init()
        
        self.delegate = delegate
        
        addChildViewController(rootViewController)
        
        modalPresentationStyle = .formSheet
    }
    
    /// :nodoc:
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Child View Controllers
    
    fileprivate lazy var rootViewController: UIViewController = {
        UINavigationController(rootViewController: self.paymentPickerViewController)
    }()
    
    fileprivate lazy var paymentPickerViewController: PaymentPickerViewController = {
        PaymentPickerViewController(delegate: self)
    }()
    
    // MARK: View
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(rootViewController.view)
        
        startPaymentRequest()
    }
}

// MARK: Payment Request

extension CheckoutViewController {
    
    func startPaymentRequest() {
        paymentRequest = PaymentRequest(delegate: self)
        paymentRequest?.start()
    }
}

// MARK: PaymentRequestDelegate

extension CheckoutViewController: PaymentRequestDelegate {
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        delegate?.checkoutViewController(self, requiresPaymentDataForToken: token, completion: completion)
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresPaymentMethodFrom preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
        methodCompletion = completion
        
        paymentPickerViewController.displayMethods(preferred: preferredMethods, available: availableMethods)
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
        guard let method = request.paymentMethod,
            let plugin = method.plugin as? UIPresentable,
            let presenter = plugin.detailsPresenter() else {
            completion(details)
            return
        }
        
        currentPresenter = presenter
        
        presenter.setup(with: rootViewController, paymentRequest: request, paymentDetails: details) { completeDetails in
            self.paymentPickerViewController.displayPaymentMethodActivityIndicator()
            
            completion(details)
        }
        
        presenter.present()
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
        paymentPickerViewController.reset()
        
        delegate?.checkoutViewController(self, didFinishWith: result)
    }
}

// MARK: PaymentPickerViewControllerDelegate

extension CheckoutViewController: PaymentPickerViewControllerDelegate {
    
    func paymentPickerViewController(_ paymentPickerViewController: PaymentPickerViewController, didSelectPaymentMethod paymentMethod: PaymentMethod) {
        methodCompletion?(paymentMethod)
        
        if paymentMethod.inputDetails.isEmpty {
            paymentPickerViewController.displayPaymentMethodActivityIndicator()
        }
    }
    
    func paymentPickerViewController(_ paymentPickerViewController: PaymentPickerViewController, didSelectDeletePaymentMethod paymentMethod: PaymentMethod) {
        paymentRequest?.deletePreferred(paymentMethod: paymentMethod) { _ in
            
        }
    }
    
    func paymentPickerViewControllerDidCancel(_ paymentPickerViewController: PaymentPickerViewController) {
        delegate?.checkoutViewController(self, didFinishWith: .error(.canceled))
    }
}

// MARK: SFSafariViewControllerDelegate

extension CheckoutViewController: SFSafariViewControllerDelegate {
    
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        paymentPickerViewController.reset()
        
        paymentRequest?.paymentMethod?.plugin?.reset()
    }
}
