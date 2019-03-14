//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import SafariServices
import UIKit

internal protocol CheckoutPresenterDelegate: AnyObject {
    func didSelectCancel(in checkoutPresenter: CheckoutPresenter)
    func didSelectChange(in checkoutPresenter: CheckoutPresenter)
    func didSelect(_ paymentMethod: PaymentMethod, in checkoutPresenter: CheckoutPresenter)
    func didDelete(_ paymentMethod: PaymentMethod, in checkoutPresenter: CheckoutPresenter)
}

/// Handles the presentation and interaction of the UI of the checkout process.
internal final class CheckoutPresenter: NSObject {
    /// The view controller that will present the checkout UI.
    internal let presentingViewController: UIViewController
    
    /// The delegate of the presentation controller.
    internal weak var delegate: CheckoutPresenterDelegate?
    
    internal var allowUserInteraction: Bool = true {
        didSet {
            navigationController?.enableAllActionItems(allowUserInteraction)
        }
    }
    
    /// Initializes the presentation controller.
    ///
    /// - Parameter presentingViewController: The view controller that will present the checkout UI.
    internal init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    /// Shows the checkout loading screen.
    internal func showLoadingScreen() {
        makeNavigationController()
        
        let loadingViewController = LoadingViewController()
        loadingViewController.title = ADYLocalizedString("checkoutTitle")
        loadingViewController.activityIndicatorColor = Appearance.shared.activityIndicatorColor
        
        navigationController?.viewControllers = [loadingViewController]
        presentingViewController.present(navigationController!, animated: true)
    }
    
    internal func dismiss(topOnly: Bool, completion: @escaping () -> Void) {
        if topOnly {
            if navigationController?.presentedViewController != nil {
                navigationController?.dismiss(animated: true, completion: completion)
            } else {
                completion()
            }
        } else {
            presentingViewController.dismiss(animated: true, completion: completion)
        }
    }
    
    /// Shows the confirmation screen for a single payment method.
    internal func show(_ paymentMethod: PaymentMethod, amount: PaymentSession.Payment.Amount, shouldShowChangeButton: Bool) {
        let viewController = PreselectedPaymentMethodViewController(paymentMethod: paymentMethod)
        viewController.title = ADYLocalizedString("checkoutTitle")
        viewController.payButtonHandler = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.didSelect(paymentMethod, in: strongSelf)
            }
        }
        viewController.payButtonTitle = Appearance.shared.checkoutButtonAttributes.title(for: amount)
        
        if shouldShowChangeButton {
            viewController.changeButtonHandler = { [weak self] in
                if let strongSelf = self {
                    strongSelf.delegate?.didSelectChange(in: strongSelf)
                }
            }
        }
        
        navigationController?.viewControllers = [viewController]
    }
    
    /// Shows a list of payment methods.
    internal func show(_ paymentMethods: SectionedPaymentMethods, pluginManager: PluginManager) {
        let viewController = ListViewController()
        viewController.title = ADYLocalizedString("paymentMethods.title")
        viewController.sections = listSections(for: paymentMethods, pluginManager: pluginManager)
        
        navigationController?.viewControllers = [viewController]
    }
    
    internal func show(_ details: [PaymentDetail], using plugin: PaymentDetailsPlugin, asRoot: Bool = false, completion: @escaping Completion<[PaymentDetail]>) {
        let viewController = plugin.viewController(for: details, appearance: .shared, completion: completion)
        switch plugin.preferredPresentationMode {
        case .push:
            if asRoot {
                navigationController?.viewControllers = [viewController]
            } else {
                navigationController?.pushViewController(viewController, animated: true)
            }
        case .present:
            navigationController?.present(viewController, animated: true)
        }
    }
    
    internal func show(_ details: AdditionalPaymentDetails, using plugin: AdditionalPaymentDetailsPlugin, completion: @escaping Completion<Result<[PaymentDetail]>>) {
        guard let navigationController = navigationController else {
            return
        }
        
        plugin.present(details, using: navigationController, appearance: Appearance.shared, completion: completion)
    }
    
    /// Redirects to the given URL.
    internal func redirect(to url: URL) {
        guard let navigationController = navigationController else {
            return
        }
        
        RedirectPresenter.open(url: url, from: navigationController, safariDelegate: self) { [weak self] success in
            if success == false {
                self?.showPaymentProcessing(false)
            }
        }
    }
    
    internal func showPaymentProcessing(_ show: Bool) {
        show ? navigationController?.startProcessing() : navigationController?.stopProcessing()
        
        guard let viewController = navigationController?.topViewController as? PaymentProcessingElement else {
            return
        }
        
        show ? viewController.startProcessing() : viewController.stopProcessing()
    }
    
    // MARK: - Private
    
    private var navigationController: CheckoutNavigationController?
    
    private func listSections(for paymentMethods: SectionedPaymentMethods, pluginManager: PluginManager) -> [ListSection] {
        func paymentMethodMap(_ paymentMethod: PaymentMethod) -> ListItem {
            let plugin = pluginManager.plugin(for: paymentMethod) as? PaymentDetailsPlugin
            let subtitle = paymentMethod.surcharge.flatMap { "(" + $0.formatted + ")" }
            
            var item = ListItem(title: paymentMethod.displayName, subtitle: subtitle)
            item.imageURL = paymentMethod.logoURL
            item.accessibilityLabel = paymentMethod.accessibilityLabel
            item.showsDisclosureIndicator = plugin?.showsDisclosureIndicator ?? false
            item.selectionHandler = { [weak self] in
                if let strongSelf = self {
                    strongSelf.delegate?.didSelect(paymentMethod, in: strongSelf)
                }
            }
            
            if paymentMethods.preferred.contains(paymentMethod) {
                item.deletionHandler = { [weak self] in
                    if let strongSelf = self {
                        strongSelf.delegate?.didDelete(paymentMethod, in: strongSelf)
                    }
                }
            }
            
            return item
        }
        
        let preferredSection = ListSection(items: paymentMethods.preferred.map(paymentMethodMap))
        let otherSectionTitle = paymentMethods.preferred.isEmpty ? nil : ADYLocalizedString("paymentMethods.otherMethods")
        let otherSection = ListSection(title: otherSectionTitle, items: paymentMethods.other.map(paymentMethodMap))
        
        return [preferredSection, otherSection]
    }
    
    private func makeNavigationController() {
        let checkoutNavigationController = CheckoutNavigationController()
        checkoutNavigationController.cancelButtonHandler = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.didSelectCancel(in: strongSelf)
            }
        }
        checkoutNavigationController.view.tintColor = Appearance.shared.tintColor
        navigationController = checkoutNavigationController
    }
    
}

// MARK: - SFSafariViewControllerDelegate

extension CheckoutPresenter: SFSafariViewControllerDelegate {
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        showPaymentProcessing(false)
    }
    
}
