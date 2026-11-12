//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class PresenterMock: ViewControllerPresenter {
    
    var present: (UIViewController, Bool) -> Void
    var dismiss: (Bool) -> Void
    
    init(
        present: @escaping (UIViewController, Bool) -> Void,
        dismiss: @escaping (Bool) -> Void
    ) {
        self.present = present
        self.dismiss = dismiss
    }
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        present(viewController, animated)
    }
    
    func dismissViewController(_ viewController: UIViewController, animated: Bool) {
        dismiss(animated)
    }
}

/// Presents on a source view controller so presented screens become part of the real view hierarchy in tests.
final class SecondaryScreenPresenterMock: ViewControllerPresenter {
    
    weak var source: UIViewController?
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        source?.adyen.topPresenter.present(viewController, animated: animated)
    }
    
    func dismissViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.dismiss(animated: animated)
    }
}
