//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Delegate to handle different viewController events.
package protocol ViewControllerDelegate: AnyObject {

    /// Handles the UIViewController.viewDidLoad() event.
    func viewDidLoad(viewController: UIViewController)

    /// Handles the UIViewController.viewDidAppear() event.
    func viewDidAppear(viewController: UIViewController)

    /// Handles the UIViewController.viewWillAppear() event.
    func viewWillAppear(viewController: UIViewController)
}

package extension ViewControllerDelegate {

    func viewDidLoad(viewController: UIViewController) { /* Empty implementation */ }

    func viewDidAppear(viewController: UIViewController) { /* Empty implementation */ }

    func viewWillAppear(viewController: UIViewController) { /* Empty implementation */ }
}
