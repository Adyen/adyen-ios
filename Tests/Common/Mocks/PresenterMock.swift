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
    
    func dismissViewController(animated: Bool) {
        dismiss(animated)
    }
}
