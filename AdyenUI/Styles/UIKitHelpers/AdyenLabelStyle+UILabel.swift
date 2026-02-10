//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package extension UILabel {
    func apply(_ style: AdyenLabelStyle) {
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
    }
}
