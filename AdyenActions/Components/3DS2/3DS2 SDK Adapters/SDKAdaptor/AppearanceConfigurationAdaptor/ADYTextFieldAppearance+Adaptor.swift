//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Adyen3DS2_Swift
import UIKit

extension ADYTextFieldAppearance {
    internal var textFieldAppearance: TextFieldAppearance {
        TextFieldAppearance(
            font: font,
            textColor: textColor,
            borderWidth: borderWidth,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            keyboardAppearance: keyboardAppearance
        )
    }
}
