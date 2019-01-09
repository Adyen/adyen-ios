//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class HomeViewController: UIViewController, CheckoutStartDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Object Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPaymentRequest), name: PaymentRequestManager.didFinishRequestNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.frame = view.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        
        var checkoutFlowFrame = view.bounds
        checkoutFlowFrame.origin.y = 130
        checkoutFlowFrame.size.height -= checkoutFlowFrame.minY
        checkoutStatusNavigationController.view.frame = checkoutFlowFrame
        
        self.addChildViewController(checkoutStatusNavigationController)
        view.addSubview(checkoutStatusNavigationController.view)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PartialSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    // MARK: - CheckoutStartDelegate
    
    func startCheckout() {
        if PaymentRequestManager.shared.startNewRequest() {
            presentCheckoutFlow()
        }
    }
    
    lazy var checkoutStatusNavigationController: UINavigationController = {
        let viewController = CartViewController()
        viewController.checkoutStartDelegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()
    
    // MARK: - Private
    
    private let backgroundImageView = UIImageView(image: UIImage(named: "background"))
    
    private func presentCheckoutFlow() {
        let paymentMethodSelection = PaymentMethodSelectionViewController(nibName: nil, bundle: nil)
        let navigationController = CheckoutFlowNavigationController(rootViewController: paymentMethodSelection)
        
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func didFinishPaymentRequest(_ notification: NSNotification) {
        if let requestStatus = notification.userInfo?[PaymentRequestManager.finishedRequestStatusKey] as? PaymentRequestManager.RequestStatus {
            switch requestStatus {
            case .success:
                let success = CheckoutSuccessViewController()
                checkoutStatusNavigationController.pushViewController(success, animated: false)
            case .failure:
                let failure = CheckoutFailureViewController()
                checkoutStatusNavigationController.pushViewController(failure, animated: false)
            default:
                break
            }
        }
    }
    
}

class PartialSizePresentationController: UIPresentationController {
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
            let presentingViewController = presentingViewController as? HomeViewController else {
            return
        }
        
        dimmedView.frame = containerView.bounds
        dimmedView.alpha = 0.0
        containerView.addSubview(dimmedView)
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmedView.alpha = 0.6
                presentingViewController.checkoutStatusNavigationController.view.alpha = 0.0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let presentingViewController = presentingViewController as? HomeViewController,
            let coordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        isDismissing = true
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.dimmedView.alpha = 0
            presentingViewController.checkoutStatusNavigationController.view.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        dimmedView.removeFromSuperview()
        isDismissing = false
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedFrame = CGRect.zero
        presentedFrame.size = presentedViewController.preferredContentSize
        if let containerView = containerView {
            presentedFrame.origin.y = containerView.bounds.height - presentedFrame.height
        }
        
        return presentedFrame
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard let presentedView = presentedView, !isDismissing else {
            return
        }
        
        let presentedFrame = frameOfPresentedViewInContainerView
        UIView.animate(withDuration: 0.2) {
            presentedView.frame = presentedFrame
        }
    }
    
    // MARK: - Private
    
    private var isDismissing = false
    
    private var dimmedView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black
        return view
    }()
    
}
