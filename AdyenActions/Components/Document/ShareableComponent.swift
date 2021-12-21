//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Defines an interface for components to support share activity controller.
internal protocol ShareableComponent: AnyObject {
    var presenterViewController: UIViewController { get }
    
    func setUpPresenterViewController(parentViewController: UIViewController)
    
    func presentSharePopover(with item: Any, sourceView: UIView)
}

extension ShareableComponent {
    
    internal func setUpPresenterViewController(parentViewController: UIViewController) {
        // Ugly hack to work around the following bug
        // https://stackoverflow.com/questions/59413850/uiactivityviewcontroller-dismissing-current-view-controller-after-sharing-file
        
        parentViewController.addChild(presenterViewController)
        parentViewController.view.insertSubview(presenterViewController.view, at: 0)
        presenterViewController.view.frame = .zero
        presenterViewController.didMove(toParent: parentViewController)
    }
    
    internal func presentSharePopover(with item: Any, sourceView: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: [item],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sourceView
        presenterViewController.present(activityViewController, animated: true, completion: nil)
    }
}
