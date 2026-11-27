//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension UIViewController {

    /// Whether the screen goes away for good, because it is popped or its sheet is dismissed.
    ///
    /// `false` when the screen is only covered by another screen pushed on top, like a secondary screen or an action.
    /// Only meaningful from `viewWillDisappear` or `viewDidDisappear`.
    internal var isLeavingScreen: Bool {
        isMovingFromParent || isBeingDismissed || navigationController?.isBeingDismissed == true
    }
}
