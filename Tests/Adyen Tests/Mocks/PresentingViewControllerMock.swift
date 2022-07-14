//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

final class PresentingViewControllerMock: UIViewController {
    
    var onPresent: ((_ viewControllerToPresent: UIViewController, _ flag: Bool, _ completion: (() -> Void)?) -> Void)?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        onPresent?(viewControllerToPresent, flag, completion)
    }
}
