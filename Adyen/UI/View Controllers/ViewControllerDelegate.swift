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

}

/// :nodoc:
/// Delegate to handle events of viewController with dynamic content .
public protocol DynamicViewControllerDelegate: AnyObject {

    /// :nodoc:
    /// Handles the event when UIViewController changed prefered content size.
    func viewDidChangeContentSize(viewController: UIViewController)

}

/// :nodoc:
/// Base class for all ViewControllers
public protocol DynamicViewController: UIViewController {

    /// :nodoc:
    /// Delegate to handle events of viewController's dynamic content .
    var dynamicContentDelegate: DynamicViewControllerDelegate? { get set }

}

extension DynamicViewController {

    public var dynamicContentDelegate: DynamicViewControllerDelegate? {
        get {
            objc_getAssociatedObject(self, &AdyenViewControllerAssociatedKeys.dynamicContentDelegate) as? DynamicViewControllerDelegate
        }
        set {
            objc_setAssociatedObject(self,
                                     &AdyenViewControllerAssociatedKeys.dynamicContentDelegate,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

}

private enum AdyenViewControllerAssociatedKeys {
    internal static var dynamicContentDelegate = "dynamicContentDelegate"
}
