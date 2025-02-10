//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Adyen3DS2_Swift
import UIKit

extension ADYLabelAppearance {
    internal var labelAppearance: LabelAppearance {
        LabelAppearance(
            font: font,
            textColor: textColor,
            headingFont: headingFont,
            headingTextColor: headingTextColor,
            headingLineHeight: headingLineHeight,
            subheadingFont: subheadingFont,
            subheadingTextColor: subheadingTextColor,
            errorTextColor: errorTextColor,
            lineHeight: lineHeight
        )
    }
}
