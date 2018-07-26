//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// A navigation controller that applies styling.
internal final class CheckoutNavigationController: DynamicHeightNavigationController {

    // MARK: - UINavigationController
    
    override func popViewController(animated: Bool) -> UIViewController? {
        // The navigation bar background may have been reset in Form View Controller.
        let navigationBarAttributes = Appearance.shared.navigationBarAttributes
        navigationBar.barTintColor = navigationBarAttributes.backgroundColor
        navigationBar.isTranslucent = navigationBarAttributes.isNavigationBarTranslucent
        
        return super.popViewController(animated: animated)
    }
    
    // MARK: - View
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Appearance.shared.backgroundColor
        
        let navigationBarAttributes = Appearance.shared.navigationBarAttributes
        navigationBar.titleTextAttributes = navigationBarAttributes.titleAttributes
        navigationBar.tintColor = navigationBarAttributes.tintColor
        navigationBar.barTintColor = navigationBarAttributes.backgroundColor
        navigationBar.isTranslucent = navigationBarAttributes.isNavigationBarTranslucent
        
        // Hiding the separator.
        // Setting shadow image to an empty image to force hide separator.
        navigationBar.shadowImage = UIImage()
        
        // Have to also do it like this instead of setting an empty shadow image because this approach works on iOS 10.
        for child in navigationBar.subviews {
            for view in child.subviews where view is UIImageView {
                view.alpha = 0
                break
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    internal override func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, willShow: viewController, animated: animated)
        
        viewController.view.backgroundColor = view.backgroundColor
        
        let navigationItem = viewController.navigationItem
        navigationItem.backBarButtonItem = UIBarButtonItem(title: ADYLocalizedString("backButton"), style: .plain, target: nil, action: nil)
        
        if viewController == navigationController.viewControllers.first {
            navigationItem.leftBarButtonItem = Appearance.shared.cancelButtonItem(target: self, selector: #selector(didSelect(cancelButtonItem:)))
        }
    }
    
    // MARK: - Internal
    
    /// The handler to invoke when the cancel button is selected.
    internal var cancelButtonHandler: (() -> Void)?
    
    // MARK: - Private
    
    @objc private func didSelect(cancelButtonItem: UIBarButtonItem) {
        cancelButtonHandler?()
    }
    
}
