//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A styled navigation controller.
/// :nodoc:
public final class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    /// :nodoc:
    private let style: NavigationStyle
    
    /// :nodoc:
    public init(rootViewController: UIViewController, style: NavigationStyle = NavigationStyle()) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
        
        delegate = self
        viewControllers = [rootViewController]
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = style.tintColor
        view.backgroundColor = style.backgroundColor
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = style.barBackgroundColor
        navigationBar.tintColor = style.barTintColor
        navigationBar.backgroundColor = style.barBackgroundColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: style.barTitle.font,
                                             NSAttributedString.Key.foregroundColor: style.barTitle.color,
                                             NSAttributedString.Key.backgroundColor: style.barTitle.backgroundColor]
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default) // Hide separator on iOS 10.
    }
    
    // MARK: - UINavigationControllerDelegate
    
    /// :nodoc:
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                          style: .plain,
                                                                          target: nil,
                                                                          action: nil)
    }
    
}
