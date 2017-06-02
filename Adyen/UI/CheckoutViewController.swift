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
    
    var paymentPickerVC: PaymentPickerViewController?
    var paymentRequest: PaymentRequest?
    var methodCompletion: MethodCompletion?
    var rootViewController: UINavigationController?
    var currentPresenter: PaymentMethodDetailsPresenter?
    
    /// Initialise the ViewController with `CheckoutViewControllerDelegate`.
    public init(delegate: CheckoutViewControllerDelegate) {
        self.init()
        
        self.delegate = delegate
        
        let viewController = PaymentPickerViewController()
        rootViewController = UINavigationController(rootViewController: viewController)
        
        if let rootView = rootViewController?.view {
            view.addSubview(rootView)
        }
        
        viewController.didSelectMethodCompletion = { method in
            self.methodCompletion?(method)
        }
        
        viewController.didCancel = {
            self.delegate?.checkoutViewController(self, didFinishWith: .error(.canceled))
        }
        
        paymentPickerVC = viewController
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
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
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
        
        DispatchQueue.main.async {
            self.paymentPickerVC?.displayMethods(preferred: preferredMethods, available: availableMethods)
        }
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresReturnURLFrom url: URL, completion: @escaping URLCompletion) {
        if #available(iOS 9.0, *) {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            safariViewController.modalPresentationStyle = .formSheet
            
            delegate?.checkoutViewController(self, requiresReturnURL: completion)
            
            self.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, requiresPaymentDetails details: PaymentDetails, completion: @escaping PaymentDetailsCompletion) {
        guard let method = request.paymentMethod,
            let plugin = method.plugin as? UIPresentable,
            let presenter = plugin.detailsPresenter(),
            let rootController = rootViewController else {
            completion(details)
            return
        }
        
        currentPresenter = presenter
        
        presenter.setup(with: rootController, paymentRequest: request, paymentDetails: details) { completeDetails in
            completion(details)
        }
        
        presenter.present()
    }
    
    /// :nodoc:
    public func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
        delegate?.checkoutViewController(self, didFinishWith: result)
    }
}

// MARK: SFSafariViewControllerDelegate

extension CheckoutViewController: SFSafariViewControllerDelegate {
    
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        paymentPickerVC?.reset()
        paymentRequest?.paymentMethod?.plugin?.reset()
    }
}
