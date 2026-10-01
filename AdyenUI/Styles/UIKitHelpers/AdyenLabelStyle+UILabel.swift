//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package extension UILabel {
    func apply(_ style: AdyenLabelStyle) {
        if let label = self as? AdyenLabel {
            label.style = style
            return
        }
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
    }
}
