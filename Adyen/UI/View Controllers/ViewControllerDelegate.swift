//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
/// Delegate to handle different viewController events.
public protocol ViewControllerDelegate: AnyObject {

    /// :nodoc:
    /// Handles the UIViewController.viewDidLoad() event.
    func viewDidLoad(viewController: UIViewController)

    /// :nodoc:
    /// Handles the UIViewController.viewDidAppear() event.
    func viewDidAppear(viewController: UIViewController)

    /// :nodoc
    /// Handles the UIViewController.viewWillAppear() event.
    func viewWillAppear(viewController: UIViewController)
}
