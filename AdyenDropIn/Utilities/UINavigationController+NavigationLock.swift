//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension UINavigationController {

    internal func setNavigationLock(active isActive: Bool) {
        navigationBar.isUserInteractionEnabled = !isActive
        popGestureRecognizers.forEach { $0.isEnabled = !isActive }
    }

    private var popGestureRecognizers: [UIGestureRecognizer] {
        var recognizers = [interactivePopGestureRecognizer].compactMap { $0 }
        #if compiler(>=6.2)
            if #available(iOS 26.0, *), let contentPopGestureRecognizer = interactiveContentPopGestureRecognizer {
                recognizers.append(contentPopGestureRecognizer)
            }
        #endif
        return recognizers
    }
}
