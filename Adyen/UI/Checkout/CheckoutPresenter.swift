//
// Copyright (c) 2018 Adyen B.V.
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
    
    internal func dismiss(completion: @escaping () -> Void) {
        presentingViewController.dismiss(animated: true, completion: completion)
    }
    
    /// Shows the confirmation screen for a single payment method.
    internal func show(_ paymentMethod: PaymentMethod, amount: PaymentSession.Payment.Amount) {
        let viewController = PreselectedPaymentMethodViewController(paymentMethod: paymentMethod)
        viewController.title = ADYLocalizedString("checkoutTitle")
        viewController.changeButtonHandler = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.didSelectChange(in: strongSelf)
            }
        }
        viewController.payButtonHandler = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.didSelect(paymentMethod, in: strongSelf)
            }
        }
        viewController.logoURL = paymentMethod.logoURL
        viewController.payButtonTitle = Appearance.shared.checkoutButtonAttributes.title(forAmount: amount.value, currencyCode: amount.currencyCode)
        
        navigationController?.viewControllers = [viewController]
    }
    
    /// Shows a list of payment methods.
    internal func show(_ paymentMethods: SectionedPaymentMethods, pluginManager: PluginManager) {
        let viewController = ListViewController()
        viewController.title = ADYLocalizedString("paymentMethods.title")
        viewController.sections = listSections(for: paymentMethods, pluginManager: pluginManager)
        
        navigationController?.viewControllers = [viewController]
    }
    
    internal func showPaymentDetails(for plugin: Plugin, completion: @escaping Completion<[PaymentDetail]>) {
        guard let navigationController = navigationController else {
            return
        }
        
        plugin.present(using: navigationController, completion: completion)
    }
    
    /// Redirects to the given URL.
    internal func redirect(to url: URL) {
        guard let navigationController = navigationController else {
            return
        }
        
        RedirectPresenter.open(url: url, from: navigationController, safariDelegate: self)
    }
    
    internal func showPaymentProcessing(_ show: Bool) {
        guard let viewController = navigationController?.topViewController as? PaymentProcessingElement else {
            return
        }
        
        if show {
            viewController.startProcessing()
        } else {
            viewController.stopProcessing()
        }
    }
    
    // MARK: - Private
    
    private var navigationController: CheckoutNavigationController?
    
    private func listSections(for paymentMethods: SectionedPaymentMethods, pluginManager: PluginManager) -> [ListSection] {
        func paymentMethodMap(_ paymentMethod: PaymentMethod) -> ListItem {
            let plugin = pluginManager.plugin(for: paymentMethod)
            
            var item = ListItem(title: paymentMethod.displayName)
            item.imageURL = paymentMethod.logoURL
            item.accessibilityLabel = paymentMethod.accessibilityLabel
            item.showsDisclosureIndicator = plugin?.showsDisclosureIndicator ?? false
            item.selectionHandler = {
                self.delegate?.didSelect(paymentMethod, in: self)
            }
            
            if paymentMethods.preferred.contains(paymentMethod) {
                item.deletionHandler = {
                    self.delegate?.didDelete(paymentMethod, in: self)
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
