//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

final class ViewControllerSpy: UIViewController {

    var presentCallsCount = 0
    var capturedPresentedViewController: UIViewController?
    var presentAnimated: Bool?
    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentCallsCount += 1
        capturedPresentedViewController = viewControllerToPresent
        presentAnimated = flag
        completion?()
    }

    var dismissCallsCount = 0
    var dismissAnimated: Bool?
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallsCount += 1
        dismissAnimated = flag
        completion?()
    }

    private var _navigationController: NavigationControllerSpy?
    override var navigationController: UINavigationController? {
        _navigationController
    }

    func setNavigationController(_ nav: NavigationControllerSpy) {
        self._navigationController = nav
    }
}

final class NavigationControllerSpy: UINavigationController {
    
    var pushViewControllerCallsCount = 0
    var capturedPushedViewController: UIViewController?
    var pushAnimated: Bool?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCallsCount += 1
        capturedPushedViewController = viewController
        pushAnimated = animated
    }
}
