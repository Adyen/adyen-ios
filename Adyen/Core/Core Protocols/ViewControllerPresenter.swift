//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Types that keep a presenter should hold it weakly: a `weak var`, or a ``WeakReferenceViewControllerPresenter`` they own.
package protocol ViewControllerPresenter: AnyObject {
    func presentViewController(_ viewController: UIViewController, animated: Bool)
    func dismissViewController(_ viewController: UIViewController, animated: Bool)
}

package class WeakReferenceViewControllerPresenter: ViewControllerPresenter {

    private weak var presenter: ViewControllerPresenter?
    
    package init(_ presenter: ViewControllerPresenter) {
        self.presenter = presenter
    }
    
    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.presentViewController(viewController, animated: animated)
    }
    
    package func dismissViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.dismissViewController(viewController, animated: animated)
    }
}
