//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A styled navigation controller.
/// :nodoc:
public final class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    /// :nodoc:
    public override init(rootViewController: UIViewController) {
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
        
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
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
