//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package extension UIImage {

    static var adyenLock: UIImage? {
        image(named: "bento-lock")?.withRenderingMode(.alwaysTemplate)
    }

    static var systemLock: UIImage? {
        UIImage(systemName: "lock")?.withRenderingMode(.alwaysTemplate)
    }

    static var adyenCheckmark: UIImage? {
        image(named: "ic_checkmark")
    }

    static var adyenChevronRight: UIImage? {
        image(named: "ic_chevron_right")?.imageFlippedForRightToLeftLayoutDirection()
    }

    static var adyenWarning: UIImage? {
        image(named: "ic_warning")
    }

    // MARK: - Private

    private static func image(named name: String) -> UIImage? {
        UIImage(named: name, in: Bundle.adyenUIInternalResources, compatibleWith: nil)
    }
}
