//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Adyen3DS2_Swift
import UIKit

extension ADYButtonAppearance {
    internal var buttonAppearance: ButtonAppearance {
        ButtonAppearance(
            font: font,
            textColor: textColor,
            textTransform: textTransform.buttonAppearanceTextTransform,
            backgroundColor: backgroundColor,
            disabledTextColor: disabledTextColor,
            disabledBackgroundColor: disabledBackgroundColor,
            highlightedBackgroundColor: highlightedBackgroundColor,
            cornerRadius: cornerRadius
        )
    }
}

extension ADYButtonAppearanceTextTransform {
    var buttonAppearanceTextTransform: ButtonAppearanceTextTransform {
        switch self {
        case .lowercase:
            return .lowercase
        case .uppercase:
            return .uppercase
        case .none:
            return .none
        }
    }
}
